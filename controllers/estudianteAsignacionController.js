import sequelize from "../config/db.js";
import { v4 as uuidv4 } from "uuid";


export const getCursosAsignacion = async (req, res) => {
    try {
        const [rows] = await sequelize.query(`
            SELECT * FROM sp_cursos_getcursosasignados()
        `);
        return res.json(rows);
    } catch (error) {
        console.error("Error in getCursosAsignacion:", error);
        return res.status(500).json({ error: "Error al obtener cursos asignados" });
    }
};

export const createCursosAsignacion = async (req, res) => {
   const { carnet, codigoCurso, nota } = req.body;

    if (!carnet || !codigoCurso) {
        return res.status(400).json({ error: "Carnet y código del curso son obligatorios" });
    }

    const t = await sequelize.transaction();
    try {
        const [students] = await sequelize.query(
            `
            SELECT id
            FROM student_profiles
            WHERE student_code = :carnet
            LIMIT 1
            `,
            { replacements: { carnet }, transaction: t }
        );

        if (!students.length) {
            await t.rollback();
            return res.status(404).json({ error: "No existe un estudiante con ese carnet" });
        }

        const student_uuid = students[0].id;

    const [programs] = await sequelize.query(
            `
            SELECT cp.id
            FROM course_programs cp
            INNER JOIN teacher_courses tc ON cp.teacher_course_id = tc.id
            INNER JOIN courses c ON tc.course_id = c.id
            WHERE c.code = :codigoCurso
            ORDER BY cp.upload_date DESC NULLS LAST, cp.created_at DESC
            LIMIT 1
            `,
            { replacements: { codigoCurso }, transaction: t }
        );

        if (!programs.length) {
            await t.rollback();
            return res.status(404).json({ error: "No existe un programa de curso para ese código de curso" });
        }

        const course_program_uuid = programs[0].id;

        const newId = uuidv4();
        const grade =
            nota === undefined || nota === null || nota === ""
                ? null
                : Number(nota);

        if (grade !== null && Number.isNaN(grade)) {
            await t.rollback();
            return res.status(400).json({ error: "La nota debe ser numérica" });
        }

        await sequelize.query(
            `
            INSERT INTO student_course (id, student_uuid, course_program_uuid, grade)
            VALUES (:id, :student_uuid, :course_program_uuid, :grade)
            `,
            {
                replacements: { id: newId, student_uuid, course_program_uuid, grade },
                transaction: t,
            }
        );

        await t.commit();
        return res.status(201).json({
            message: "Curso asignado creado exitosamente",
            cursoAsignacion: { id: newId, student_uuid, course_program_uuid, grade },
        });
    } catch (error) {
        await t.rollback();
        console.error("Error in createCursosAsignacion:", error);
        return res.status(500).json({ error: "Error al crear cursos asignados" });
    }
};

export const deleteCursosAsignacion = async (req, res) => {
    const { id } = req.params;

    if (!id) {
        return res.status(400).json({ error: "ID es requerido" });
    }

    const t = await sequelize.transaction();
    try {
        const [rows] = await sequelize.query(
            `
            SELECT id
            FROM student_course
            WHERE id = :id
            LIMIT 1
            `,
            { replacements: { id }, transaction: t }
        );

        if (!rows.length) {
            await t.rollback();
            return res.status(404).json({ error: "No existe una asignación con ese id" });
        }

        await sequelize.query(
            `
            DELETE FROM student_course
            WHERE id = :id
            `,
            { replacements: { id }, transaction: t }
        );

        await t.commit();
        return res.json({ message: "Curso asignado eliminado correctamente", id });
    } catch (error) {
        await t.rollback();
        console.error("Error in deleteCursosAsignacion:", error);
        return res.status(500).json({ error: "Error al eliminar curso asignado" });
    }
};

