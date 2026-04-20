import sequelize from "../config/db.js";
import { v4 as uuidv4 } from "uuid";


export const getAllSolicitudes = async (req, res) => {
    try {
        const [solicitudes] = await sequelize.query(
            `SELECT * FROM sp_equivalencias_getSolicitudes()`
        );
        return res.json(solicitudes);
    } catch (error) {
        console.error("Error in getAllSolicitudes:", error);
        return res.status(500).json({ error: "Error al obtener solicitudes" });
    }
}

export const createSolicitud = async (req, res) => {
    try {
        const {
            nombre,
            carnet,
            carrera,
            cursoAprobado,
            codigoCursoAprobado,
            cursoEquivalencia,
            codigoCursoEquivalencia,
            observaciones
        } = req.body;

        if (!carnet || !codigoCursoAprobado || !codigoCursoEquivalencia) {
            return res.status(400).json({ error: "carnet, codigoCursoAprobado y codigoCursoEquivalencia son obligatorios" });
        }

        const t = await sequelize.transaction();

        try {
            const [students] = await sequelize.query(
                `SELECT id FROM student_profiles WHERE student_code = :carnet LIMIT 1`,
                { replacements: { carnet }, transaction: t }
            );
            if (!students.length) {
                await t.rollback();
                return res.status(404).json({ error: "No se encontró el estudiante (crear perfil de estudiante primero)" });
            }
            const student_id = students[0].id;

            const [careers] = await sequelize.query(
                `SELECT id FROM careers WHERE name ILIKE :career LIMIT 1`,
                { replacements: { career: `%${carrera || ''}%` }, transaction: t }
            );
            if (!careers.length) {
                await t.rollback();
                return res.status(404).json({ error: "No se encontró la carrera indicada" });
            }
            const career_id = careers[0].id;

            const [plans] = await sequelize.query(
                `SELECT id FROM study_plans WHERE career_id = :careerId AND enabled = true ORDER BY effective_date DESC, created_at DESC LIMIT 1`,
                { replacements: { careerId: career_id }, transaction: t }
            );
            if (!plans.length) {
                await t.rollback();
                return res.status(404).json({ error: "No existe un plan de estudio activo para esa carrera" });
            }
            const destination_study_plan_id = plans[0].id;

            const origin_study_plan_id = destination_study_plan_id;

            const findOrCreateCourse = async (code, name) => {
                const [rows] = await sequelize.query(
                    `SELECT id, credits FROM courses WHERE code = :code LIMIT 1`,
                    { replacements: { code }, transaction: t }
                );
                if (rows.length) return { id: rows[0].id, credits: rows[0].credits || 3 };
                const newId = uuidv4();
                await sequelize.query(
                    `INSERT INTO courses (id, code, name, credits, hours_theory, hours_practice, enabled) VALUES (:id, :code, :name, :credits, 0, 0, true)`,
                    { replacements: { id: newId, code, name: name || code, credits: 3 }, transaction: t }
                );
                return { id: newId, credits: 3 };
            };

            const originCourse = await findOrCreateCourse(codigoCursoAprobado, cursoAprobado);
            const destCourse = await findOrCreateCourse(codigoCursoEquivalencia, cursoEquivalencia);

            let status_id = null;
            const [statusRows] = await sequelize.query(
                `SELECT id FROM status WHERE name ILIKE 'SUBMITTED' LIMIT 1`,
                { transaction: t }
            );
            if (statusRows.length) status_id = statusRows[0].id;
            else {
                const [firstStatus] = await sequelize.query(`SELECT id FROM status LIMIT 1`, { transaction: t });
                if (firstStatus.length) status_id = firstStatus[0].id;
            }

            const newRequestId = uuidv4();
            await sequelize.query(
                `INSERT INTO equivalence_requests
                    (id, student_id, origin_study_plan_id, destination_study_plan_id, status_id, observations)
                 VALUES
                    (:id, :student_id, :origin_sp, :dest_sp, :status_id, :observations)`,
                {
                    replacements: {
                        id: newRequestId,
                        student_id,
                        origin_sp: origin_study_plan_id,
                        dest_sp: destination_study_plan_id,
                        status_id,
                        observations: observaciones || null
                    },
                    transaction: t
                }
            );

            const newReqCourseId = uuidv4();
            await sequelize.query(
                `INSERT INTO equivalence_request_courses
                    (id, equivalence_request_id, origin_course_id, destination_course_id, origin_course_grade, origin_course_credits, destination_course_credits, status_id)
                 VALUES
                    (:id, :reqId, :originCourseId, :destCourseId, :originGrade, :originCredits, :destCredits, :statusId)`,
                {
                    replacements: {
                        id: newReqCourseId,
                        reqId: newRequestId,
                        originCourseId: originCourse.id,
                        destCourseId: destCourse.id,
                        originGrade: null,
                        originCredits: originCourse.credits || 3,
                        destCredits: destCourse.credits || 3,
                        statusId: status_id
                    },
                    transaction: t
                }
            );

            await t.commit();

            return res.status(201).json({
                message: "Solicitud de equivalencia creada",
                solicitud: {
                    id: newRequestId,
                    student_id,
                    origin_study_plan_id,
                    destination_study_plan_id,
                    origin_course_id: originCourse.id,
                    destination_course_id: destCourse.id
                }
            });
        } catch (innerError) {
            await t.rollback();
            console.error("Error in createSolicitud (transaction):", innerError);
            return res.status(500).json({ error: "Error al crear la solicitud de equivalencia" });
        }
    } catch (error) {
        console.error("Error in createSolicitud:", error);
        return res.status(500).json({ error: "Error al procesar la solicitud" });
    }
}

export const getOneSolicitud = async (req, res) => {
    try {
        const { id } = req.params;
        if (!id) return res.status(400).json({ error: "ID es requerido" });

        const [rows] = await sequelize.query(
            `
                SELECT
                    s.name AS estado,
                    CONCAT(u.first_name, ' ', u.last_name) AS nombre,
                    sp.student_code AS carnet,
                    se.name AS carrera,
                    c.name AS cursoAprobado,
                    c.code AS codigoCursoAprobado,
                    d.name AS cursoEquivalencia,
                    d.code AS codigoCursoEquivalencia,
                    COUNT(ds.id) AS cantidadArchivos,
                    er.id AS id,
                    er.submission_date AS fechaSolicitud,
                    er.observations AS observaciones
                FROM equivalence_requests er
                         INNER JOIN student_profiles sp ON er.student_id = sp.id
                         INNER JOIN users u ON sp.user_id = u.id
                         INNER JOIN study_plans se ON se.id = er.destination_study_plan_id
                         INNER JOIN equivalence_request_courses ec ON ec.equivalence_request_id = er.id
                         INNER JOIN courses c ON ec.origin_course_id = c.id
                         INNER JOIN courses d ON ec.destination_course_id = d.id
                         INNER JOIN status s ON er.status_id = s.id
                         LEFT JOIN documents ds ON ds.equivalence_request_id = er.id
                WHERE er.id = :id
                GROUP BY s.name, u.first_name, u.last_name, sp.student_code,
                         se.name, c.name, c.code, d.name, d.code,
                         er.id, er.submission_date, er.observations
            `,
            { replacements: { id } }
        );

        if (!rows || rows.length === 0) {
            return res.status(404).json({ error: "Solicitud no encontrada" });
        }

        return res.json(rows[0]);
    } catch (error) {
        console.error("Error in getOneSolicitud:", error);
        return res.status(500).json({ error: "Error al obtener la solicitud" });
    }
}

export const getDocumentosSolicitud = async (req, res) => {
    try {
        const { id } = req.params;
        if (!id) return res.status(400).json({ error: "ID es requerido" });

        const [documents] = await sequelize.query(
            `SELECT
                 ds.id,
                 COALESCE(dr.name, ds.document_type) AS tipoDocumentoLabel,
                 ds.document_name AS nombre,
                 ds.mime_type AS tipo,
                 ds.file_size AS tamanio,
                 ds.upload_date AS fechaCarga,
                 ds.validation_status AS estado
             FROM documents ds
                      LEFT JOIN document_requirements dr ON dr.code = ds.document_type
             WHERE ds.equivalence_request_id = :id
             ORDER BY ds.upload_date DESC, ds.document_name;`,
            { replacements: { id } }
        );

        return res.json(documents || []);
    } catch (error) {
        console.error("Error in getDocumentosSolicitud:", error);
        return res.status(500).json({ error: "Error al obtener documentos de la solicitud" });
    }
}