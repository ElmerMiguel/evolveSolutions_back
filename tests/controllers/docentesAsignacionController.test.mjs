import { describe, it, expect, vi, beforeEach } from "vitest";
import { 
    getCursosDocenteAsignacion, 
    createCursosDocenteAsignacion, 
    deleteCursosDocenteAsignacion 
} from "../../controllers/docentesAsignacionController.js";
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

describe("docentesAsignacionController.js", () => {
  let req, res;

  beforeEach(() => {
    vi.clearAllMocks();
    res = {
      status: vi.fn().mockReturnThis(),
      json: vi.fn().mockReturnThis(),
    };
  });

  describe("getCursosDocenteAsignacion", () => {
    it("debería retornar la lista de asignaciones", async () => {
      const fakeRows = [{ nombreProfesor: "Juan Perez", codigoCurso: "INF101" }];
      sequelize.query.mockResolvedValueOnce([fakeRows, {}]);

      await getCursosDocenteAsignacion({}, res);

      expect(res.json).toHaveBeenCalledWith(fakeRows);
    });

    it("debería retornar 500 si falla la consulta", async () => {
      sequelize.query.mockRejectedValueOnce(new Error("DB Error"));
      await getCursosDocenteAsignacion({}, res);
      expect(res.status).toHaveBeenCalledWith(500);
    });
  });

  describe("createCursosDocenteAsignacion", () => {
    it("debería retornar 400 si faltan campos", async () => {
      req = { body: { nombreDocente: "Juan" } }; 
      await createCursosDocenteAsignacion(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
    });

    it("debería retornar 404 si no encuentra al docente", async () => {
      req = { 
        body: { 
          nombreDocente: "Inexistente", codigoCurso: "C1", 
          nombreCurso: "N1", carrera: "Ing", semestre: "1" 
        } 
      };
      sequelize.query.mockResolvedValueOnce([[], {}]);

      await createCursosDocenteAsignacion(req, res);

      expect(res.status).toHaveBeenCalledWith(404);
      expect(res.json).toHaveBeenCalledWith({ error: "No se encontró un docente con ese nombre" });
    });

    it("debería crear la asignación exitosamente", async () => {
      req = { 
        body: { 
          nombreDocente: "Juan", codigoCurso: "C1", 
          nombreCurso: "N1", carrera: "Ing", semestre: "Primer Semestre 2024" 
        } 
      };

      // Secuencia de mocks para las consultas internas:
      sequelize.query
        .mockResolvedValueOnce([[{ teacher_id: "t1" }], {}]) // 1. Buscar docente
        .mockResolvedValueOnce([[{ id: "c1" }], {}])        // 2. Buscar curso
        .mockResolvedValueOnce([[{ id: "car1" }], {}])      // 3. Buscar carrera
        .mockResolvedValueOnce([[{ id: "p1" }], {}])        // 4. Buscar plan
        .mockResolvedValueOnce([[], {}])                   // 5. Verificar existencia (vacío = no duplicado)
        .mockResolvedValueOnce([[], {}]);                  // 6. Insert final

      await createCursosDocenteAsignacion(req, res);

      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
        message: "Asignación de docente creada correctamente"
      }));
    });

    it("debería retornar 409 si la asignación ya existe", async () => {
        req = { 
            body: { 
              nombreDocente: "Juan", codigoCurso: "C1", 
              nombreCurso: "N1", carrera: "Ing", semestre: "1" 
            } 
        };

        sequelize.query
            .mockResolvedValueOnce([[{ teacher_id: "t1" }], {}]) // Docente
            .mockResolvedValueOnce([[{ id: "c1" }], {}])        // Curso
            .mockResolvedValueOnce([[{ id: "car1" }], {}])      // Carrera
            .mockResolvedValueOnce([[{ id: "p1" }], {}])        // Plan
            .mockResolvedValueOnce([[{ id: "exis1" }], {}]);    // SI EXISTE DUPLICADO

        await createCursosDocenteAsignacion(req, res);

        expect(res.status).toHaveBeenCalledWith(409);
        expect(res.json).toHaveBeenCalledWith({ error: "Ya existe una asignación para ese docente/curso/plan/año/semestre" });
    });
  });

  describe("deleteCursosDocenteAsignacion", () => {
    it("debería retornar 404 si la asignación no existe", async () => {
      req = { params: { id: "999" } };
      sequelize.query.mockResolvedValueOnce([[], {}]);

      await deleteCursosDocenteAsignacion(req, res);
      expect(res.status).toHaveBeenCalledWith(404);
    });

    it("debería retornar 409 si hay estudiantes inscritos", async () => {
      req = { params: { id: "123" } };
      // simular 5 estuduantes
      sequelize.query.mockResolvedValueOnce([[{ id: "123", enrolled_students: 5 }], {}]);

      await deleteCursosDocenteAsignacion(req, res);

      expect(res.status).toHaveBeenCalledWith(409);
      expect(res.json).toHaveBeenCalledWith({ error: "No se puede eliminar la asignación: hay estudiantes inscritos" });
    });

    it("debería eliminar exitosamente si no hay inscritos", async () => {
      req = { params: { id: "123" } };
      sequelize.query
        .mockResolvedValueOnce([[{ id: "123", enrolled_students: 0 }], {}])
        .mockResolvedValueOnce([[], {}]); 

      await deleteCursosDocenteAsignacion(req, res);

      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
        message: "Asignación de docente eliminada correctamente"
      }));
    });
  });
});