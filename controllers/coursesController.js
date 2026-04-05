import sequelize from "../config/db.js";
import { v4 as uuidv4 } from "uuid";

// GET /cursos
export const getCourses = async (req, res) => {
    try {
        const [courses] = await sequelize.query(`
            SELECT id, code, name, description, credits, hours_theory, hours_practice, course_level, course_type, enabled
            FROM courses
            WHERE enabled = true
            ORDER BY name ASC
        `);
        return res.json(courses);
    } catch (error) {
        console.error("Error in getCourses:", error);
        return res.status(500).json({ error: "Error al obtener los cursos" });
    }
};

// POST /cursos
export const createCourse = async (req, res) => {
    // Frontend sends: nombre, codigo, descripcion, pensum, creditos, horasTeoricas, horasPracticas
    const { codigo, nombre, descripcion, creditos, horasTeoricas, horasPracticas, pensum } = req.body;

    if (!codigo || !nombre || !creditos) {
        return res.status(400).json({ error: "Código, nombre y créditos son obligatorios" });
    }

    const t = await sequelize.transaction();

    try {
        // Create the course
        const newCourseId = uuidv4();
        await sequelize.query(`
            INSERT INTO courses (id, code, name, description, credits, hours_theory, hours_practice)
            VALUES (:id, :code, :name, :description, :credits, :hours_theory, :hours_practice)
        `, {
            replacements: { 
                id: newCourseId, code: codigo, name: nombre, description: descripcion || null, credits: creditos, 
                hours_theory: horasTeoricas || 0, hours_practice: horasPracticas || 0
            },
            transaction: t
        });

        // If a study plan (pensum) is provided, link it
        if (pensum) {
            await sequelize.query(`
                INSERT INTO study_plan_courses (id, study_plan_id, course_id, semester, is_mandatory)
                VALUES (:spc_id, :study_plan_id, :course_id, :semester, true)
            `, {
                replacements: {
                    spc_id: uuidv4(),
                    study_plan_id: pensum,
                    course_id: newCourseId,
                    semester: 1 // default semester to 1
                },
                transaction: t
            });
        }

        await t.commit();
        
        return res.status(201).json({ 
            message: "Curso creado exitosamente",
            course: { id: newCourseId, code: codigo, name: nombre, credits: creditos } 
        });
    } catch (error) {
        await t.rollback();
        console.error("Error in createCourse:", error);
        
        // Handle common DB errors like unique constraint violation
        if (error.original && error.original.code === '23505') {
            return res.status(400).json({ error: "Ya existe un curso con ese código." });
        }
        
        return res.status(500).json({ error: "Error al crear el curso" });
    }
};

// GET /cursos/options
export const getCourseOptions = async (req, res) => {
    try {
        // According to the DB schema, study plans (pensums) are linked to careers.
        // We will return the list of active study plans.
        const [options] = await sequelize.query(`
            SELECT sp.id as value, 
                   CONCAT(c.name, ' - ', sp.name, ' (', sp.version, ')') as nombre 
            FROM study_plans sp
            JOIN careers c ON sp.career_id = c.id
            WHERE sp.enabled = true
            ORDER BY c.name, sp.version DESC
        `);
        return res.json({ pensums: options });
    } catch (error) {
        console.error("Error in getCourseOptions:", error);
        return res.status(500).json({ error: "Error al obtener opciones de pensum" });
    }
};
