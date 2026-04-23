import { describe, it, expect, vi, beforeEach } from "vitest";
import { 
    getAllSolicitudes, 
    createSolicitud, 
    getOneSolicitud, 
    updateEstadoSolicitud 
} from "../../controllers/equivalenciasController.js"; 
import sequelize from "../../config/db.js";
import emailService from "../../services/emailService.js";

vi.mock("../../config/db.js", () => ({
  default: {
    query: vi.fn(),
    transaction: vi.fn(() => ({
      commit: vi.fn(),
      rollback: vi.fn(),
    })),
  }
}));

vi.mock("../../services/emailService.js", () => ({
  default: {
    sendEmail: vi.fn().mockResolvedValue(true)
  }
}));

describe("equivalenciasController.js", () => {
  let req, res;

  beforeEach(() => {
    vi.clearAllMocks();
    res = {
      status: vi.fn().mockReturnThis(),
      json: vi.fn().mockReturnThis(),
    };
  });

  describe("getAllSolicitudes", () => {
    it("debería llamar al procedimiento almacenado y retornar las solicitudes", async () => {
      const fakeSolicitudes = [{ id: "sol-1", carnet: "20201010" }];
      sequelize.query.mockResolvedValueOnce([fakeSolicitudes, {}]);

      await getAllSolicitudes({}, res);

      expect(sequelize.query).toHaveBeenCalledWith(expect.stringContaining("sp_equivalencias_getSolicitudes()"));
      expect(res.json).toHaveBeenCalledWith(fakeSolicitudes);
    });
  });

  describe("createSolicitud", () => {
    it("debería retornar 400 si faltan campos obligatorios", async () => {
      req = { body: { carnet: "20201010" } }; // Faltan correo y cursos
      await createSolicitud(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
    });

    it("debería crear la solicitud y enviar email exitosamente", async () => {
      req = {
        body: {
          nombre: "Estudiante Prueba",
          //correo: "test@correo.com", <- simular error de email no adjunto
          carnet: "20201010",
          carrera: "Ingeniería",
          codigoCursoAprobado: "001",
          codigoCursoEquivalencia: "002",
          docente: "Docente Prueba"
        }
      };

      sequelize.query
        .mockResolvedValueOnce([[{ id: "user-1" }], {}])    // Creador
        .mockResolvedValueOnce([[{ id: "teach-1" }], {}])   // Docente
        .mockResolvedValueOnce([[{ id: "stud-1" }], {}])    // Estudiante
        .mockResolvedValueOnce([[{ id: "car-1" }], {}])     // Carrera
        .mockResolvedValueOnce([[{ id: "plan-1" }], {}])    // Plan
        .mockResolvedValueOnce([[{ id: "c1", credits: 3 }], {}]) // findOrCreate Curso Origen
        .mockResolvedValueOnce([[{ id: "c2", credits: 3 }], {}]) // findOrCreate Curso Destino
        .mockResolvedValueOnce([[{ id: "stat-1" }], {}])    // Status SUBMITTED
        .mockResolvedValueOnce([[], {}])                    // Insert Request
        .mockResolvedValueOnce([[], {}]);                   // Insert Course link

      await createSolicitud(req, res);

      expect(res.status).toHaveBeenCalledWith(201);
      expect(emailService.sendEmail).toHaveBeenCalled();
      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
        message: "Solicitud de equivalencia creada"
      }));
    });

    it("debería retornar 404 si la carrera no existe", async () => {
      req = { body: { carnet: "20201010", correo: "a@b.com", codigoCursoAprobado: "1", codigoCursoEquivalencia: "2", carrera: "Inexistente" } };
      
      sequelize.query
        .mockResolvedValueOnce([[{ id: "u-1" }], {}]) // Creador
        .mockResolvedValueOnce([[{ id: "t-1" }], {}]) // Docente
        .mockResolvedValueOnce([[{ id: "s-1" }], {}]) // Estudiante
        .mockResolvedValueOnce([[], {}]);             // CARRERA NO ENCONTRADA

      await createSolicitud(req, res);

      expect(res.status).toHaveBeenCalledWith(404);
      expect(res.json).toHaveBeenCalledWith({ error: "No se encontró la carrera indicada" });
    });
  });

  describe("getOneSolicitud", () => {
    it("debería retornar una solicitud por ID", async () => {
      req = { params: { id: "req-123" } };
      const fakeRow = { id: "req-123", carnet: "20201010", estado: "SUBMITTED" };
      sequelize.query.mockResolvedValueOnce([[fakeRow], {}]);

      await getOneSolicitud(req, res);

      expect(res.json).toHaveBeenCalledWith(fakeRow);
    });

    it("debería retornar 404 si la solicitud no existe", async () => {
      req = { params: { id: "no-existe" } };
      sequelize.query.mockResolvedValueOnce([[], {}]);

      await getOneSolicitud(req, res);

      expect(res.status).toHaveBeenCalledWith(404);
    });
  });

  describe("updateEstadoSolicitud", () => {
    it("debería actualizar estado y notificar por correo", async () => {
      req = { 
        params: { id: "req-123" },
        body: { status_name: "APPROVED", change_reason: "Aceptada" }
      };

      sequelize.query
        .mockResolvedValueOnce([[{ id: "stat-app" }], {}]) 
        .mockResolvedValueOnce([[{ status_id: "old", student_id: "s1", created_by: "u1" }], {}]) 
        .mockResolvedValueOnce([[], {}]) 
        .mockResolvedValueOnce([[], {}]) 
        .mockResolvedValueOnce([[{ user_id: "u-stud" }], {}]) 
        .mockResolvedValueOnce([[], {}]) 
        .mockResolvedValueOnce([[{ email: "test@test.com", first_name: "Juan" }], {}]); 

      await updateEstadoSolicitud(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(emailService.sendEmail).toHaveBeenCalled();
      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
        new_status: "APPROVED"
      }));
    });
  });
});