import sequelize from "../config/db.js";
import { v4 as uuidv4 } from "uuid";


export const getCursosDocenteAsignacion = async (req, res) => {
    try {
        const [rows] = await sequelize.query(`
            SELECT
                concat(u.first_name, ' ', u.last_name) AS nombreProfesor,
                c.code as codigoCurso,
                c.name as nombreCurso,
                sp.name as carrera,
                tc.semester as semestre,
                tc.section as seccion
            FROM teacher_courses tc
                     INNER JOIN courses c on tc.course_id = c.id
                     INNER JOIN study_plans sp on tc.study_plan_id = sp.id
                     INNER JOIN teacher_profiles tp on tc.teacher_id = tp.id
                     INNER JOIN users u on tp.user_id = u.id;
`);
        return res.json(rows);
    } catch (error) {
        console.error("Error in getCursosDocenteAsignacion:", error);
        return res.status(500).json({ error: "Error al obtener cursos por docente" });
    }
};

export const createCursosDocenteAsignacion = async (req, res) => {
    const { nombreDocente, codigoCurso, nombreCurso, carrera, semestre, seccion } = req.body;

    if (!nombreDocente || !codigoCurso || !nombreCurso || !carrera || !semestre) {
        return res.status(400).json({ error: "nombreDocente, codigoCurso, nombreCurso, carrera y semestre son obligatorios" });
    }

    const t = await sequelize.transaction();
    try {
        const [teachers] = await sequelize.query(
            `
            SELECT tp.id as teacher_id
            FROM teacher_profiles tp
            JOIN users u ON tp.user_id = u.id
            WHERE concat(u.first_name, ' ', u.last_name) ILIKE :namePattern
            LIMIT 1
            `,
            { replacements: { namePattern: `%${nombreDocente}%` }, transaction: t }
        );

        if (!teachers.length) {
            await t.rollback();
            return res.status(404).json({ error: "No se encontró un docente con ese nombre" });
        }
        const teacher_id = teachers[0].teacher_id;

        let course_id;
        const [courses] = await sequelize.query(
            `SELECT id FROM courses WHERE code = :code LIMIT 1`,
            { replacements: { code: codigoCurso }, transaction: t }
        );

        if (courses.length) {
            course_id = courses[0].id;
        } else {
            course_id = uuidv4();
            await sequelize.query(
                `
                INSERT INTO courses (id, code, name, credits, hours_theory, hours_practice)
                VALUES (:id, :code, :name, 3, 0, 0)
                `,
                { replacements: { id: course_id, code: codigoCurso, name: nombreCurso }, transaction: t }
            );
        }

        const [careers] = await sequelize.query(
            `SELECT id FROM careers WHERE name ILIKE :career LIMIT 1`,
            { replacements: { career: `%${carrera}%` }, transaction: t }
        );

        if (!careers.length) {
            await t.rollback();
            return res.status(404).json({ error: "No se encontró la carrera indicada" });
        }
        const career_id = careers[0].id;

        const [plans] = await sequelize.query(
            `
            SELECT id
            FROM study_plans
            WHERE career_id = :careerId AND enabled = true
            ORDER BY effective_date DESC, created_at DESC
            LIMIT 1
            `,
            { replacements: { careerId: career_id }, transaction: t }
        );

        if (!plans.length) {
            await t.rollback();
            return res.status(404).json({ error: "No existe un plan de estudio activo para esa carrera" });
        }
        const study_plan_id = plans[0].id;

        let year_teaching = new Date().getFullYear();
        const yearMatch = String(semestre).match(/\b(20\d{2}|19\d{2})\b/);
        if (yearMatch) year_teaching = parseInt(yearMatch[0], 10);

        const semLower = String(semestre).toLowerCase();
        let semester = 1;
        if (semLower.includes('segundo') || /\b2\b/.test(semLower) || semLower.includes('second')) semester = 2;
        else if (semLower.includes('primer') || /\b1\b/.test(semLower) || semLower.includes('first')) semester = 1;

        const [existing] = await sequelize.query(
            `
            SELECT id
            FROM teacher_courses
            WHERE teacher_id = :teacherId
              AND course_id = :courseId
              AND study_plan_id = :planId
              AND year_teaching = :year
              AND semester = :semester
            LIMIT 1
            `,
            { replacements: { teacherId: teacher_id, courseId: course_id, planId: study_plan_id, year: year_teaching, semester }, transaction: t }
        );

        if (existing.length) {
            await t.rollback();
            return res.status(409).json({ error: "Ya existe una asignación para ese docente/curso/plan/año/semestre" });
        }

        const newId = uuidv4();
        await sequelize.query(
            `
            INSERT INTO teacher_courses (id, teacher_id, course_id, study_plan_id, year_teaching, semester, section)
            VALUES (:id, :teacher_id, :course_id, :study_plan_id, :year_teaching, :semester, :section)
            `,
            {
                replacements: {
                    id: newId,
                    teacher_id,
                    course_id,
                    study_plan_id,
                    year_teaching,
                    semester,
                    section: seccion || null
                },
                transaction: t
            }
        );

        await t.commit();
        return res.status(201).json({
            message: "Asignación de docente creada correctamente",
            docenteAsignacion: {
                id: newId,
                teacher_id,
                course_id,
                study_plan_id,
                year_teaching,
                semester,
                section: seccion || null
            }
        });
    } catch (error) {
        await t.rollback();
        console.error("Error in createCursosDocenteAsignacion:", error);
        return res.status(500).json({ error: "Error al crear la asignación de docente" });
    }
};

export const deleteCursosDocenteAsignacion = async (req, res) => {
    const { id } = req.params;

    if (!id) {
        return res.status(400).json({ error: "ID es requerido" });
    }

    const t = await sequelize.transaction();
    try {
        const [rows] = await sequelize.query(
            `
            SELECT id, enrolled_students
            FROM teacher_courses
            WHERE id = :id
            LIMIT 1
            `,
            { replacements: { id }, transaction: t }
        );

        if (!rows.length) {
            await t.rollback();
            return res.status(404).json({ error: "No existe una asignación de docente con ese id" });
        }

        const enrolled = rows[0].enrolled_students;
        if (enrolled && Number(enrolled) > 0) {
            await t.rollback();
            return res.status(409).json({ error: "No se puede eliminar la asignación: hay estudiantes inscritos" });
        }

        await sequelize.query(
            `
            DELETE FROM teacher_courses
            WHERE id = :id
            `,
            { replacements: { id }, transaction: t }
        );

        await t.commit();
        return res.json({ message: "Asignación de docente eliminada correctamente", id });
    } catch (error) {
        await t.rollback();
        console.error("Error in deleteCursosDocenteAsignacion:", error);
        return res.status(500).json({ error: "Error al eliminar asignación de docente" });
    }
};
