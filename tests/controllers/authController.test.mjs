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

  it("retorna lista de cursos", async () => {
    const fakeCourses = [{ id: 1, name: "Curso Test" }];
    sequelize.query.mockResolvedValueOnce([fakeCourses, {}]);

    await getCourses({}, res);
    expect(res.json).toHaveBeenCalledWith(fakeCourses);
  });

  it("retorna 400 si ya existe curso con mismo código", async () => {
    req = { body: { codigo: "DUPLICADO", nombre: "Test", creditos: 3 } };
    const error = new Error("Unique violation");
    error.original = { code: '23505' };
    sequelize.query.mockRejectedValueOnce(error);

    await createCourse(req, res);
    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith({ error: "Ya existe un curso con ese código." });
  });

  it("retorna 500 si ocurre otro error en createCourse", async () => {
    req = { body: { codigo: "ERROR", nombre: "Test", creditos: 3 } };
    sequelize.query.mockRejectedValueOnce(new Error("Generic DB error"));

    await createCourse(req, res);
    expect(res.status).toHaveBeenCalledWith(500);
  });

  it("retorna lista de pensums", async () => {
    const fakeOptions = [{ value: "p1", nombre: "Ingeniería" }];
    sequelize.query.mockResolvedValueOnce([fakeOptions, {}]);

    await getCourseOptions({}, res);
    expect(res.json).toHaveBeenCalledWith({ pensums: fakeOptions });
  });

  it("retorna 500 si getCourseOptions falla", async () => {
    sequelize.query.mockRejectedValueOnce(new Error("DB error"));
    await getCourseOptions({}, res);
    expect(res.status).toHaveBeenCalledWith(500);
  });
});