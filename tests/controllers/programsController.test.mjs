import { describe, it, expect, vi, beforeEach } from "vitest";
import { getTeacherCourses, uploadProgram } from "../../controllers/programsController.js";
import sequelize from "../../config/db.js";
import cloudinary from "../../config/cloudinary.js";

// Mock de Sequelize
vi.mock("../../config/db.js", () => ({
  default: {
    query: vi.fn(),
    transaction: vi.fn(() => ({
      commit: vi.fn(),
      rollback: vi.fn(),
    })),
    QueryTypes: { INSERT: "INSERT" }
  }
}));

// Mock de Cloudinary
vi.mock("../../config/cloudinary.js", () => ({
  default: {
    uploader: {
      upload_stream: vi.fn((options, callback) => ({
        end: vi.fn(() => callback(null, { secure_url: "http://res.com/pdf", public_id: "pdf_123" }))
      }))
    }
  }
}));

describe("programsController.js", () => {
  let req, res;

  beforeEach(() => {
    vi.clearAllMocks();
    res = {
      status: vi.fn().mockReturnThis(),
      json: vi.fn().mockReturnThis(),
    };
    // Simulamos usuario autenticado
    req = { user: { id: "user-123" } };
  });

  describe("getTeacherCourses", () => {
    it("debería retornar los cursos asociados al docente logueado", async () => {
      const fakeCourses = [{ id: "tc-1", name: "Matemática discreta" }];
      sequelize.query.mockResolvedValueOnce([fakeCourses, {}]);

      await getTeacherCourses(req, res);

      expect(res.json).toHaveBeenCalledWith(fakeCourses);
    });

    it("debería retornar 500 si falla la base de datos", async () => {
      sequelize.query.mockRejectedValueOnce(new Error("DB error"));
      await getTeacherCourses(req, res);
      expect(res.status).toHaveBeenCalledWith(500);
    });
  });

  describe("uploadProgram", () => {
    it("debería retornar 400 si no se envía un archivo", async () => {
      req.body = { teacher_course_id: "tc-1" };
      req.file = null;

      await uploadProgram(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
    });

    it("debería retornar 400 si el archivo no es PDF", async () => {
      req.file = { mimetype: "image/png", buffer: Buffer.from("...") };
      req.body = { teacher_course_id: "tc-1" };

      await uploadProgram(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
    });

    it("debería subir a Cloudinary y guardar en BD exitosamente", async () => {
      req.file = { 
        mimetype: "application/pdf", 
        buffer: Buffer.from("fake-pdf"),
        size: 1024 
      };
      req.body = { teacher_course_id: "tc-1" };

      const fakeProgram = { id: "prog-1", document_url: "http://res.com/pdf" };
      
      // Sequelize devuelve [[registros], metadata]
      // Tu controlador hace const [program] = await sequelize.query(...)
      // Por tanto, 'program' es el array de registros.
      sequelize.query.mockResolvedValueOnce([[fakeProgram], {}]);

      await uploadProgram(req, res);

      expect(cloudinary.uploader.upload_stream).toHaveBeenCalled();
      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
        message: "Programa subido y guardado correctamente",
        // Aquí estaba el detalle: 'data' contiene el ARRAY retornado por RETURNING *
        data: [expect.objectContaining(fakeProgram)]
      }));
    });

    it("debería hacer rollback y retornar 500 si falla Cloudinary", async () => {
      req.file = { mimetype: "application/pdf", buffer: Buffer.from("...") };
      req.body = { teacher_course_id: "tc-1" };

      // Forzamos error en Cloudinary
      cloudinary.uploader.upload_stream.mockImplementationOnce((opts, cb) => ({
        end: vi.fn(() => cb(new Error("Cloudinary fail"), null))
      }));

      await uploadProgram(req, res);

      expect(res.status).toHaveBeenCalledWith(500);
    });
  });
});