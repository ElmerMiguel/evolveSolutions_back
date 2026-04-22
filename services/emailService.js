import transporter from "../config/mailer.js";

const emailService = {
    // Método genérico para enviar cualquier correo
    sendEmail: async (to, subject, htmlContent) => {
        try {
            await transporter.sendMail({
                from: `"${process.env.MAIL_FROM_NAME}" <${process.env.MAIL_USER}>`,
                to,
                subject,
                html: htmlContent,
            });
            return true;
        } catch (error) {
            console.error("Error en el servicio de correo:", error);
            return false;
        }
    },

    // Plantilla: Notificación de Cambio de Estado
    // Úsala cuando aprueben o rechacen una equivalencia
    sendStatusUpdate: async (studentEmail, studentName, status) => {
        const html = `
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #e0e0e0; border-radius: 8px; overflow: hidden;">
                <div style="background-color: #004a99; color: white; padding: 20px; text-align: center;">
                    <h1>Estado de tu Trámite</h1>
                </div>
                <div style="padding: 20px; color: #333;">
                    <p>Hola <strong>${studentName}</strong>,</p>
                    <p>Te informamos que tu solicitud de equivalencia ha sido actualizada.</p>
                    <div style="background-color: #f8f9fa; border-left: 4px solid #004a99; padding: 15px; margin: 20px 0;">
                        <p style="margin: 0;">Nuevo estado: <strong>${status}</strong></p>
                    </div>
                    <p>Puedes consultar más detalles ingresando al portal del estudiante.</p>
                </div>
                <div style="background-color: #f1f1f1; padding: 10px; text-align: center; font-size: 12px; color: #777;">
                    <p>Este es un correo automático, por favor no respondas a este mensaje.<br>
                    © 2026 Evolve Solutions - CUNOC</p>
                </div>
            </div>
        `;
        return await emailService.sendEmail(
            studentEmail,
            "Actualización de tu Equivalencia",
            html
        );
    },

    // Plantilla: Aviso de Nueva Solicitud (Para el administrador)
    sendAdminNotification: async (adminEmail, studentName) => {
        const html = `
            <div style="font-family: Arial, sans-serif; padding: 20px; border: 1px solid #ddd;">
                <h2 style="color: #d32f2f;">Aviso: Nueva Solicitud Recibida</h2>
                <p>Se ha registrado una nueva solicitud de equivalencia en el sistema.</p>
                <p><strong>Estudiante:</strong> ${studentName}</p>
                <p>Por favor, ingresa al panel de administración para revisarla.</p>
            </div>
        `;
        return await emailService.sendEmail(
            adminEmail,
            "URGENTE: Nueva Solicitud de Equivalencia",
            html
        );
    },
};

export default emailService;
