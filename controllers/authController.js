import crypto from "crypto";
import sessions from "../models/sessions.js";
import generarAuthToken from "../middlewares/generarAuthToken.js";
import users from "../models/users.js";

const login = async (req, res) => {
    const { identifier, password } = req.body;

    const hash = crypto.createHash("sha256");
    hash.update(password);
    const passEncriptada = hash.digest("hex");

    try {
        const usuario = await users.login({
            correo: identifier,
            password: passEncriptada,
        });

        // GENERAR EL TOKEN SIEMPRE (Si el login fue exitoso)
        const token = generarAuthToken(usuario);

        const activeSession = await sessions.checkActive(usuario?.id);

        if (activeSession === false) {
            // CREAR SESIÓN NUEVA SI NO HAY UNA ACTIVA
            const newSession = await sessions.createWithToken({
                user: usuario,
                token: token,
            });

            return res.json({ token, session: newSession });
        }

        // SI YA HABÍA SESIÓN, DEVOLVEMOS EL TOKEN NUEVO Y LA SESIÓN EXISTENTE
        return res.json({ token, session: activeSession });
    } catch (err) {
        console.error("ERROR EN LOGIN:", err);
        return res.status(401).json({
            error: err.message || "Authentication failed",
        });
    }
};

export default login;
