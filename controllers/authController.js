import crypto from "crypto";
import sessions from "../models/sessions.js";
import generarAuthToken from "../middlewares/generarAuthToken.js";
import users from "../models/users.js";

import sequelize from "../config/db.js";

// ... existing imports
import { blacklistToken } from "../middlewares/autenticacionToken.js";
import {QueryTypes} from "sequelize";

// Cambiamos el export por default a exports nombrados
export const login = async (req, res) => {
    // ... resto del login existente ...
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

        // OBTENER LOS PERMISOS DEL USUARIO
        const userPermissions = await sequelize.query(
            `    
            SELECT p.code, p.name, p.resource, rp.auth_level
            FROM user_roles ur
            JOIN roles r ON ur.role_id = r.id
            JOIN role_permissions rp ON r.id = rp.role_id
            JOIN permissions p ON rp.permission_id = p.id
            WHERE ur.user_id = :userId AND r.enabled = true AND p.enabled = true
        `,
            {
                replacements: { userId: usuario.id },
                type: QueryTypes.SELECT
            }
        );

        const permisos = userPermissions.map(p => ({
            PermisoID: p.name,
            NivelEscritura: p.auth_level,
        }));

        // Si el usuario es ADMIN, darle acceso total para pruebas
        const [userRoles] = await sequelize.query(
            `SELECT r.code FROM user_roles ur JOIN roles r ON ur.role_id = r.id WHERE ur.user_id = :userId`,
            {
                replacements: { userId: usuario.id },
            }
        );

        let sessionObj = null;
        const activeSession = await sessions.checkActive(usuario?.id);

        if (activeSession === false) {
            sessionObj = await sessions.createWithToken({
                user: usuario,
                token: token,
            });
        } else {
            sessionObj = activeSession;
        }

        res.cookie("authToken", token, {
            httpOnly: true,
            secure: false,
            sameSite: "lax",
            maxAge: 24 * 60 * 60 * 1000,
        });

        const roles = userRoles.map(r => r.code);
        return res.json({ token, session: sessionObj, permisos, role : roles });
    } catch (err) {
        console.error("ERROR EN LOGIN:", err);
        return res.status(401).json({
            error: err.message || "Authentication failed",
        });
    }
};

export const registrar = async (req, res) => {
    const { username, email, password, firstName, lastName, photoUrl } =
        req.body;

    try {
        const hash = crypto.createHash("sha256");
        hash.update(password);
        const passEncriptada = hash.digest("hex");

        const t = await sequelize.transaction();

        // Crear usuario
        const newUser = await users.create(
            {
                username: username || email.split("@")[0], // Fallback if no username
                email,
                password_hash: passEncriptada,
                first_name: firstName,
                last_name: lastName,
                photo_url: photoUrl,
            },
            { transaction: t }
        );

        // Buscar rol STUDENT
        const [roles] = await sequelize.query(
            `SELECT id FROM roles WHERE code = 'STUDENT' LIMIT 1`
        );
        if (roles.length > 0) {
            await sequelize.query(
                `
                INSERT INTO user_roles (user_id, role_id) VALUES (:userId, :roleId)
            `,
                {
                    replacements: { userId: newUser.id, roleId: roles[0].id },
                    transaction: t,
                }
            );
        }

        // Crear student_profile si es necesario (simplificado)
        console.log("start")
        await t.commit();
        res.status(201).json({ message: "Usuario registrado con éxito" });
    } catch (error) {
        console.error("Error al registrar: ", error);
        res.status(500).json({
            error: error.message || "No se pudo registrar",
        });
    }
};

export const logout = async (req, res) => {
    const token =
        req.cookies.authToken ||
        req.headers.authorization?.split(" ")[1] ||
        req.body.token;
    if (token) {
        blacklistToken(token);
    }
    res.json({ message: "Sesión cerrada exitosamente" });
};

export const verificarToken = async (req, res) => {
    // Si llega a este punto, autenticacionToken ya verificó el JWT
    res.json({
        valid: true,
        user: req.user,
    });
};
