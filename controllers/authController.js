import crypto from "crypto";
import users from "../models/users";
import sessions from "../models/sessions";
import generarAuthToken from "../middlewares/generarAuthToken";


const login = async (req, res) => {
    const { identifier, password } = req.body;

    const hash = crypto.createHash('sha256')
    hash.update(password);
    const passEncriptada = hash.digest('hex');

    try {
        const usuario = await users.login({ correo: identifier, password: passEncriptada });

        const activeSession = await sessions.checkActive(usuario?.id);

        if (activeSession === false){
            const token = generarAuthToken(usuario);

            const newSession = await sessions.createWithToken(usuario, token);

            return res.json({ token, session: newSession });
        }

        return res.json({ session: activeSession });

    } catch (err) {
        return res.status(401).json({ error: err.message || 'Authentication failed' });
    }
}
export default login