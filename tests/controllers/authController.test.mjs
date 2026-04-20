import { describe, it, expect, beforeEach, vi } from "vitest";

vi.mock("../../models/users", () => ({
    default: {
        login: vi.fn(),
    },
}));

vi.mock("../../models/sessions", () => ({
    default: {
        checkActive: vi.fn(),
        createWithToken: vi.fn(),
    },
}));

vi.mock("../../middlewares/generarAuthToken", () => ({
    default: vi.fn(),
}));

vi.mock("../../config/db", () => ({
    default: {
        query: vi.fn(),
    },
}));

import { login } from "../../controllers/authController.js";
import users from "../../models/users";
import sessions from "../../models/sessions";
import generarAuthToken from "../../middlewares/generarAuthToken";
import sequelize from "../../config/db";

function makeRes() {
    return {
        status: vi.fn(function (code) {
            this.statusCode = code;
            return this;
        }),
        json: vi.fn(function (payload) {
            this.body = payload;
            return this;
        }),
        cookie: vi.fn(function () { return this; }),
        statusCode: 200,
        body: undefined,
    };
}

describe("authController.js login", () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    it("Crea una nueva sesión y token cuando no hay una sesión activa", async () => {
        const req = { body: { identifier: "a@b.com", password: "pw" } };
        const res = makeRes();

        const usuario = { id: "user-uuid", email: "a@b.com" };
        const token = "token-value";
        const newSession = { id: "sess-uuid", user_id: "user-uuid" };

        users.login.mockResolvedValue(usuario);
        sessions.checkActive.mockResolvedValue(false);
        generarAuthToken.mockReturnValue(token);

        // Mock two sequential queries: permissions and roles
        sequelize.query.mockResolvedValueOnce([[]]);
        sequelize.query.mockResolvedValueOnce([[]]);

        sessions.createWithToken.mockResolvedValue(newSession);

        await login(req, res);

        expect(users.login).toHaveBeenCalledTimes(1);
        expect(sessions.checkActive).toHaveBeenCalledWith(usuario.id);
        expect(generarAuthToken).toHaveBeenCalledWith(usuario);
        expect(sessions.createWithToken).toHaveBeenCalledWith({
            user: usuario,
            token: token,
        });

        expect(res.status).not.toHaveBeenCalled();
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ token, session: newSession }));
    });

    it("retorna la sesión y un nuevo token, cuando ya existe una sesión activa", async () => {
        const req = { body: { identifier: "a@b.com", password: "pw" } };
        const res = makeRes();

        const usuario = { id: "user-uuid", email: "a@b.com" };
        const token = "token-value";
        const activeSession = { id: "sess-active", user_id: "user-uuid" };

        users.login.mockResolvedValue(usuario);
        sessions.checkActive.mockResolvedValue(activeSession);
        generarAuthToken.mockReturnValue(token);

        sequelize.query.mockResolvedValueOnce([[]]);
        sequelize.query.mockResolvedValueOnce([[]]);

        await login(req, res);

        expect(users.login).toHaveBeenCalledTimes(1);
        expect(sessions.checkActive).toHaveBeenCalledWith(usuario.id);
        expect(generarAuthToken).toHaveBeenCalledWith(usuario);

        expect(sessions.createWithToken).not.toHaveBeenCalled();

        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
            token,
            session: activeSession,
        }));
    });

    it("retorna 401 cuando el login falla", async () => {
        const req = { body: { identifier: "a@b.com", password: "pw" } };
        const res = makeRes();

        users.login.mockRejectedValue(new Error("Usuario no encontrado"));

        await login(req, res);

        expect(res.status).toHaveBeenCalledWith(401);
        expect(res.json).toHaveBeenCalledWith({
            error: "Usuario no encontrado",
        });
    });

    it("retorna 401 con un mensaje por defecto cuando no hay un error específico", async () => {
        const req = { body: { identifier: "a@b.com", password: "pw" } };
        const res = makeRes();

        users.login.mockRejectedValue({});

        await login(req, res);

        expect(res.status).toHaveBeenCalledWith(401);
        expect(res.json).toHaveBeenCalledWith({
            error: "Authentication failed",
        });
    });
});
