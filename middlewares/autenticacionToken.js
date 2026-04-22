import NodeCache from "node-cache";
import jwt from "jsonwebtoken";

const tokenBlacklist = new NodeCache({ stdTTL: 86400, checkperiod: 120 });

const autenticacionToken = (req, res, next) => {
    const token = req.cookies.authToken; //

    if (!token) {
        return res
            .status(401)
            .json({ message: "Acceso denegado. Token no encontrado." });
    }

    // Revisamos si el token ya ha sido registrado en la blacklist
    if (tokenBlacklist.has(token)) {
        return res
            .status(403)
            .json({
                message: "Acceso no autorizado. Tu sesión ha finalizado.",
            });
    }

    try {
        req.user = jwt.verify(token, process.env.JWT_SECRET);
        next();
    } catch (err) {
        res.status(403).json({ message: "Token invalido." });
    }
};

// Funcion para añadir un token a la blacklist al cerrar sesión
const blacklistToken = (token, ttl = 86400) => {
    tokenBlacklist.set(token, true, ttl);
};

export { blacklistToken };
export default autenticacionToken;
