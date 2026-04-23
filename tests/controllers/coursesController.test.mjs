import { describe, it, expect, vi, beforeEach } from "vitest";
import { getCourses, createCourse, getCourseOptions } from "../../controllers/coursesController.js";
import sequelize from "../../config/db.js";

vi.mock("../../config/db.js", () => ({
  default: {
    query: vi.fn(),
    transaction: vi.fn(() => ({
      commit: vi.fn(),
      rollback: vi.fn(),
    })),
  }
}));

describe("coursesController.js", () => {
  let req, res;

  beforeEach(() => {
    vi.clearAllMocks();
    res = {
      status: vi.fn().mockReturnThis(),
      json: vi.fn().mockReturnThis(),
    };
  });

  describe("getCourses", () => {
    it("debería retornar una lista de cursos exitosamente", async () => {
      const fakeCourses = [{ id: "1", name: "Matemáticas", enabled: true }];
      sequelize.query.mockResolvedValueOnce([fakeCourses, {}]);

      await getCourses({}, res);

      expect(res.json).toHaveBeenCalledWith(fakeCourses);
    });

    it("debería retornar 500 si la base de datos falla", async () => {
      sequelize.query.mockRejectedValueOnce(new Error("DB Error"));

      await getCourses({}, res);

      expect(res.status).toHaveBeenCalledWith(500);
      expect(res.json).toHaveBeenCalledWith({ error: "Error al obtener los cursos" });
    });
  });

  describe("createCourse", () => {
    it("debería crear un curso y retornar 201", async () => {
      req = {
        body: {
          codigo: "INF101",
          nombre: "Programación I",
          descripcion: "Intro",
          creditos: 5,
          pensum: "uuid-pensum"
        }
      };

      sequelize.query.mockResolvedValue([[], {}]); // Mock para el insert del curso y del pensum

      await createCourse(req, res);

      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
        message: "Curso creado exitosamente"
      }));
    });

    it("debería retornar 400 si faltan campos obligatorios", async () => {
      req = { body: { codigo: "INF101" } }; // Falta nombre y créditos

      await createCourse(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: "Código, nombre y créditos son obligatorios" });
    });

    it("debería retornar 400 si el código ya existe (Error 23505)", async () => {
      req = { body: { codigo: "DUPLICADO", nombre: "Test", creditos: 3 } };
      
      const errorDuplicate = new Error("Unique Constraint");
      errorDuplicate.original = { code: '23505' };
      sequelize.query.mockRejectedValueOnce(errorDuplicate);

      await createCourse(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: "Ya existe un curso con ese código." });
    });
  });

  describe("getCourseOptions", () => {
    it("debería retornar las opciones de pensum formateadas", async () => {
      const fakeOptions = [{ value: "p1", nombre: "Ingeniería - Plan 1" }];
      sequelize.query.mockResolvedValueOnce([fakeOptions, {}]);

      await getCourseOptions({}, res);

      expect(res.json).toHaveBeenCalledWith({ pensums: fakeOptions });
    });

    it("debería retornar 500 si falla la consulta de opciones", async () => {
      sequelize.query.mockRejectedValueOnce(new Error("DB Error"));

      await getCourseOptions({}, res);

      expect(res.status).toHaveBeenCalledWith(500);
      expect(res.json).toHaveBeenCalledWith({ error: "Error al obtener opciones de pensum" });
    });
  });
});