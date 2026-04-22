import { describe, it, expect, vi, beforeEach } from "vitest";
import { 
    getCursosAsignacion, 
    createCursosAsignacion, 
    deleteCursosAsignacion 
} from "../../controllers/estudianteAsignacionController.js";
import sequelize from "../../config/db.js";

// Mock de Sequelize
vi.mock("../../config/db.js", () => ({
  default: {
    query: vi.fn(),
    transaction: vi.fn(() => ({
      commit: vi.fn(),
      rollback: vi.fn(),
    })),
  }
}));

describe("estudianteAsignacionController.js", () => {
  let req, res;

  beforeEach(() => {
    vi.clearAllMocks();
    res = {
      status: vi.fn().mockReturnThis(),
      json: vi.fn().mockReturnThis(),
    };
  });

  describe("getCursosAsignacion", () => {
    it("debería retornar la lista de cursos asignados a estudiantes", async () => {
      const fakeRows = [{ nombreEstudiante: "Alumno Test", carnet: "2023001", nota: 85 }];
      sequelize.query.mockResolvedValueOnce([fakeRows, {}]);

      await getCursosAsignacion({}, res);

      expect(res.json).toHaveBeenCalledWith(fakeRows);
    });

    it("debería retornar 500 si falla la base de datos", async () => {
      sequelize.query.mockRejectedValueOnce(new Error("Database failure"));
      await getCursosAsignacion({}, res);
      expect(res.status).toHaveBeenCalledWith(500);
    });
  });

  describe("createCursosAsignacion", () => {
    it("debería retornar 400 si no se envía carnet o código de curso", async () => {
      req = { body: { carnet: "2023001" } }; // Falta codigoCurso
      await createCursosAsignacion(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
    });

    it("debería retornar 404 si el estudiante no existe", async () => {
      req = { body: { carnet: "999", codigoCurso: "CS101" } };
      sequelize.query.mockResolvedValueOnce([[], {}]); // Mock de búsqueda de estudiante vacío

      await createCursosAsignacion(req, res);

      expect(res.status).toHaveBeenCalledWith(404);
      expect(res.json).toHaveBeenCalledWith({ error: "No existe un estudiante con ese carnet" });
    });

    it("debería retornar 400 si la nota no es un número", async () => {
        req = { body: { carnet: "2023001", codigoCurso: "CS101", nota: "no-es-numero" } };
        
        sequelize.query
          .mockResolvedValueOnce([[{ id: "stud-1" }], {}]) // Encuentra estudiante
          .mockResolvedValueOnce([[{ id: "prog-1" }], {}]); // Encuentra programa

        await createCursosAsignacion(req, res);

        expect(res.status).toHaveBeenCalledWith(400);
        expect(res.json).toHaveBeenCalledWith({ error: "La nota debe ser numérica" });
    });

    it("debería crear la asignación exitosamente con nota nula", async () => {
      req = { body: { carnet: "2023001", codigoCurso: "CS101", nota: "" } };

      sequelize.query
        .mockResolvedValueOnce([[{ id: "stud-1" }], {}]) // 1. Estudiante
        .mockResolvedValueOnce([[{ id: "prog-1" }], {}]) // 2. Programa
        .mockResolvedValueOnce([[], {}]);                // 3. Insert

      await createCursosAsignacion(req, res);

      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
        message: "Curso asignado creado exitosamente",
        cursoAsignacion: expect.objectContaining({ grade: null })
      }));
    });
  });

  describe("deleteCursosAsignacion", () => {
    it("debería eliminar la asignación si existe", async () => {
      req = { params: { id: "uuid-asignacion" } };
      
      sequelize.query
        .mockResolvedValueOnce([[{ id: "uuid-asignacion" }], {}]) // Encuentra registro
        .mockResolvedValueOnce([[], {}]);                        // Ejecuta delete

      await deleteCursosAsignacion(req, res);

      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
        message: "Curso asignado eliminado correctamente"
      }));
    });

    it("debería retornar 404 si el ID no existe", async () => {
        req = { params: { id: "inexistente" } };
        sequelize.query.mockResolvedValueOnce([[], {}]);
  
        await deleteCursosAsignacion(req, res);
  
        expect(res.status).toHaveBeenCalledWith(404);
    });
  });
});