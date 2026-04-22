import sequelize from "../config/db.js";
import { v4 as uuidv4 } from "uuid";
import emailService from "../services/emailService.js";

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
};

export const createSolicitud = async (req, res) => {
    try {
        const {
            nombre,
            correo,
            carnet,
            carrera,
            cursoAprobado,
            codigoCursoAprobado,
            cursoEquivalencia,
            codigoCursoEquivalencia,
            observaciones,
            docente,
        } = req.body;

        if (
            !carnet ||
            !codigoCursoAprobado ||
            !codigoCursoEquivalencia ||
            !correo
        ) {
            return res.status(400).json({
                error: "carnet, correo, codigoCursoAprobado y codigoCursoEquivalencia son obligatorios",
            });
        }

        const t = await sequelize.transaction();

        try {
            const [userRows] = await sequelize.query(
                `SELECT id FROM users WHERE email = :correo LIMIT 1`,
                { replacements: { correo }, transaction: t }
            );
            const creatorId = userRows.length ? userRows[0].id : null;

            const [teacherRows] = await sequelize.query(
                `SELECT tp.id 
                 FROM teacher_profiles tp
                 JOIN users u ON tp.user_id = u.id
                 WHERE concat(u.first_name, ' ', u.last_name) ILIKE :docente
                 LIMIT 1`,
                { replacements: { docente: `%${docente}%` }, transaction: t }
            );

            const assignedTeacherId = teacherRows.length
                ? teacherRows[0].id
                : null;

            const [students] = await sequelize.query(
                `SELECT id FROM student_profiles WHERE student_code = :carnet LIMIT 1`,
                { replacements: { carnet }, transaction: t }
            );
            if (!students.length) {
                await t.rollback();
                return res.status(404).json({
                    error: "No se encontró el estudiante (crear perfil de estudiante primero)",
                });
            }
            const student_id = students[0].id;

            const [careers] = await sequelize.query(
                `SELECT id FROM careers WHERE name ILIKE :career LIMIT 1`,
                {
                    replacements: { career: `%${carrera || ""}%` },
                    transaction: t,
                }
            );
            if (!careers.length) {
                await t.rollback();
                return res
                    .status(404)
                    .json({ error: "No se encontró la carrera indicada" });
            }
            const career_id = careers[0].id;

            const [plans] = await sequelize.query(
                `SELECT id FROM study_plans WHERE career_id = :careerId AND enabled = true ORDER BY effective_date DESC, created_at DESC LIMIT 1`,
                { replacements: { careerId: career_id }, transaction: t }
            );
            if (!plans.length) {
                await t.rollback();
                return res.status(404).json({
                    error: "No existe un plan de estudio activo para esa carrera",
                });
            }
            const destination_study_plan_id = plans[0].id;

            const origin_study_plan_id = destination_study_plan_id;

            const findOrCreateCourse = async (code, name) => {
                const [rows] = await sequelize.query(
                    `SELECT id, credits FROM courses WHERE code = :code LIMIT 1`,
                    { replacements: { code }, transaction: t }
                );
                if (rows.length)
                    return { id: rows[0].id, credits: rows[0].credits || 3 };
                const newId = uuidv4();
                await sequelize.query(
                    `INSERT INTO courses (id, code, name, credits, hours_theory, hours_practice, enabled) VALUES (:id, :code, :name, :credits, 0, 0, true)`,
                    {
                        replacements: {
                            id: newId,
                            code,
                            name: name || code,
                            credits: 3,
                        },
                        transaction: t,
                    }
                );
                return { id: newId, credits: 3 };
            };

            const originCourse = await findOrCreateCourse(
                codigoCursoAprobado,
                cursoAprobado
            );
            const destCourse = await findOrCreateCourse(
                codigoCursoEquivalencia,
                cursoEquivalencia
            );

            let status_id = null;
            const [statusRows] = await sequelize.query(
                `SELECT id FROM status WHERE name ILIKE 'SUBMITTED' LIMIT 1`,
                { transaction: t }
            );
            if (statusRows.length) status_id = statusRows[0].id;
            else {
                const [firstStatus] = await sequelize.query(
                    `SELECT id FROM status LIMIT 1`,
                    { transaction: t }
                );
                if (firstStatus.length) status_id = firstStatus[0].id;
            }

            const newRequestId = uuidv4();
            await sequelize.query(
                `INSERT INTO equivalence_requests
                    (id, student_id, origin_study_plan_id, destination_study_plan_id, status_id, observations, assigned_teacher_id, created_by)
                 VALUES
                    (:id, :student_id, :origin_sp, :dest_sp, :status_id, :observations, :teacher_id, :creatorId)`,
                {
                    replacements: {
                        id: newRequestId,
                        student_id,
                        origin_sp: origin_study_plan_id,
                        dest_sp: destination_study_plan_id,
                        status_id,
                        observations: observaciones || null,
                        teacher_id: assignedTeacherId,
                        creatorId: creatorId,
                    },
                    transaction: t,
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
                        statusId: status_id,
                    },
                    transaction: t,
                }
            );

            await t.commit();

            try {
                await emailService.sendEmail(
                    correo,
                    "Solicitud de Equivalencia Recibida",
                    `<div style="font-family: sans-serif; border: 1px solid #e0e0e0; border-radius: 8px; overflow: hidden; max-width: 600px;">
                        <div style="background-color: #1a73e8; color: white; padding: 20px; text-align: center;">
                            <h2 style="margin: 0;">¡Solicitud Recibida!</h2>
                        </div>
                        <div style="padding: 20px; color: #3c4043; line-height: 1.5;">
                            <p>Hola <strong>${
                                nombre || "Estudiante"
                            }</strong>,</p>
                            <p>Tu solicitud para el curso <b>${cursoEquivalencia}</b> ha sido recibida exitosamente en el sistema.</p>
                            <div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0; border-left: 4px solid #1a73e8;">
                                <p style="margin: 5px 0;"><strong>Carnet:</strong> ${carnet}</p>
                                <p style="margin: 5px 0;"><strong>Carrera:</strong> ${carrera}</p>
                                <p style="margin: 5px 0;"><strong>Docente Evaluador:</strong> ${
                                    docente || "Pendiente"
                                }</p>
                            </div>
                            <p>Pronto recibirás noticias por este medio sobre el estado de tu trámite.</p>
                        </div>
                        <div style="background-color: #f1f3f4; padding: 15px; text-align: center; font-size: 12px; color: #70757a;">
                            Este es un correo automático, por favor no respondas a este mensaje.
                        </div>
                    </div>`
                );
                console.log(`Correo enviado con éxito a: ${correo}`);
            } catch (mailError) {
                console.error(
                    "Error en el proceso de notificación:",
                    mailError
                );
            }

            return res.status(201).json({
                message: "Solicitud de equivalencia creada",
                solicitud: {
                    id: newRequestId,
                    student_id,
                    origin_study_plan_id,
                    destination_study_plan_id,
                    origin_course_id: originCourse.id,
                    destination_course_id: destCourse.id,
                    assigned_teacher_id: assignedTeacherId,
                },
            });
        } catch (innerError) {
            await t.rollback();
            console.error(
                "Error in createSolicitud (transaction):",
                innerError
            );
            return res
                .status(500)
                .json({ error: "Error al crear la solicitud de equivalencia" });
        }
    } catch (error) {
        console.error("Error in createSolicitud:", error);
        return res
            .status(500)
            .json({ error: "Error al procesar la solicitud" });
    }
};

export const getOneSolicitud = async (req, res) => {
    try {
        const { id } = req.params;
        if (!id) return res.status(400).json({ error: "ID es requerido" });

        const [rows] = await sequelize.query(
            `SELECT * FROM sp_equivalencias_getSolicitudById(:id)`,
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
};

export const getDocumentosSolicitud = async (req, res) => {
    try {
        const { id } = req.params;
        if (!id) return res.status(400).json({ error: "ID es requerido" });

        const [documents] = await sequelize.query(
            `SELECT * FROM sp_equivalencias_getDocumentosBySolicitud(:id)`,
            { replacements: { id } }
        );

        return res.json(documents || []);
    } catch (error) {
        console.error("Error in getDocumentosSolicitud:", error);
        return res
            .status(500)
            .json({ error: "Error al obtener documentos de la solicitud" });
    }
};

export const updateEstadoSolicitud = async (req, res) => {
    const { id } = req.params;
    const { status_name, change_reason } = req.body;
    const userId = "eb9d1960-d572-4e9e-a7df-d64a756a7bbe";

    if (!status_name) {
        return res
            .status(400)
            .json({ error: "El nombre del estado es obligatorio." });
    }

    const t = await sequelize.transaction();

    try {
        const [statusRows] = await sequelize.query(
            `SELECT id FROM status WHERE name ILIKE :status_name LIMIT 1`,
            { replacements: { status_name }, transaction: t }
        );

        if (!statusRows.length) {
            await t.rollback();
            return res
                .status(404)
                .json({ error: "El estado proporcionado no es válido." });
        }
        const newStatusId = statusRows[0].id;

        const [currentReq] = await sequelize.query(
            `SELECT status_id, student_id, created_by FROM equivalence_requests WHERE id = :id LIMIT 1`,
            { replacements: { id }, transaction: t }
        );

        if (!currentReq.length) {
            await t.rollback();
            return res
                .status(404)
                .json({ error: "No se encontró la solicitud." });
        }
        const {
            status_id: oldStatusId,
            student_id: studentProfileId,
            created_by: creatorId,
        } = currentReq[0];

        await sequelize.query(
            `UPDATE equivalence_requests 
             SET status_id = :newStatusId, 
                 decision_date = CURRENT_TIMESTAMP, 
                 decided_by = :userId, 
                 rejection_reason = :reason,
                 updated_at = CURRENT_TIMESTAMP
             WHERE id = :id`,
            {
                replacements: {
                    newStatusId,
                    userId,
                    reason: change_reason || null,
                    id,
                },
                transaction: t,
            }
        );

        await sequelize.query(
            `INSERT INTO equivalence_request_status_history 
                (id, equivalence_request_id, from_status, to_status, changed_by, change_reason)
             VALUES 
                (:histId, :id, :oldStatusId, :newStatusId, :userId, :reason)`,
            {
                replacements: {
                    histId: uuidv4(),
                    id,
                    oldStatusId,
                    newStatusId,
                    userId,
                    reason: change_reason || "Cambio de estado administrativo",
                },
                transaction: t,
            }
        );

        const [studentUser] = await sequelize.query(
            `SELECT user_id FROM student_profiles WHERE id = :studentProfileId LIMIT 1`,
            { replacements: { studentProfileId }, transaction: t }
        );

        if (studentUser.length) {
            await sequelize.query(
                `INSERT INTO notifications 
                    (id, recipient_user_id, equivalence_request_id, notification_type, title, message, email_status)
                 VALUES 
                    (:notifId, :userId, :reqId, :type, :title, :msg, 'PENDING')`,
                {
                    replacements: {
                        notifId: uuidv4(),
                        userId: studentUser[0].user_id,
                        reqId: id,
                        type: "STATUS_UPDATE",
                        title: "Actualización de tu solicitud",
                        msg: `Tu solicitud de equivalencia ha cambiado al estado: ${status_name}.`,
                    },
                    transaction: t,
                }
            );
        }

        await t.commit();

        try {
            const [userRow] = await sequelize.query(
                `SELECT email, first_name FROM users WHERE id = :creatorId LIMIT 1`,
                { replacements: { creatorId } }
            );

            if (userRow.length) {
                const { email, first_name } = userRow[0];
                await emailService.sendEmail(
                    email,
                    "Actualización de Solicitud - Sistema de Equivalencias",
                    `<div style="font-family: sans-serif; border: 1px solid #e0e0e0; border-radius: 8px; overflow: hidden; max-width: 600px;">
                        <div style="background-color: #34a853; color: white; padding: 20px; text-align: center;">
                            <h2 style="margin: 0;">Actualización de Estado</h2>
                        </div>
                        <div style="padding: 20px; color: #3c4043; line-height: 1.5;">
                            <p>Hola <strong>${
                                first_name || "Estudiante"
                            }</strong>,</p>
                            <p>Te informamos que tu solicitud de equivalencia ha sido actualizada.</p>
                            <div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0; border-left: 4px solid #34a853;">
                                <p style="margin: 5px 0;"><strong>Nuevo Estado:</strong> <span style="color: #1a73e8; font-weight: bold;">${status_name}</span></p>
                                <p style="margin: 5px 0;"><strong>Fecha de Decisión:</strong> ${new Date().toLocaleDateString()}</p>
                                ${
                                    change_reason
                                        ? `<p style="margin: 10px 0 5px 0;"><strong>Observaciones del Docente:</strong></p><p style="margin: 0; font-style: italic; color: #5f6368;">"${change_reason}"</p>`
                                        : ""
                                }
                            </div>
                            <p>Puedes revisar los detalles completos ingresando a tu cuenta en el portal de equivalencias.</p>
                        </div>
                        <div style="background-color: #f1f3f4; padding: 15px; text-align: center; font-size: 12px; color: #70757a;">
                            Este es un correo automático del sistema CUNOC, por favor no respondas.
                        </div>
                    </div>`
                );
                console.log(`Correo de actualización enviado a: ${email}`);
            }
        } catch (error) {
            console.error("Error enviando actualización:", error);
        }

        return res.status(200).json({
            message: "Estado actualizado exitosamente y notificación enviada.",
            new_status: status_name,
        });
    } catch (error) {
        if (t) await t.rollback();
        console.error("Error en updateEstadoSolicitud:", error);
        return res
            .status(500)
            .json({ error: "Error interno al actualizar el estado." });
    }
};
