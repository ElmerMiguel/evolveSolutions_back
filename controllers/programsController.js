import sequelize from "../config/db.js";
import { v4 as uuidv4 } from "uuid";
import cloudinary from "../config/cloudinary.js";

// GET /programas
export const getPrograms = async (req, res) => {};

// Get Vista /programa
// export const uploadProgramsView = async (req, res) => {};

// GET /teacher-courses
export const getTeacherCourses = async (req, res) => {

  try {
    const userId = req.user.id;

    const [rows] = await sequelize.query(`
      SELECT 
        tc.id,
        c.code,
        c.name,
        c.description,
        c.credits,
        tc.year_teaching,
        tc.semester
      FROM teacher_courses tc
      JOIN teacher_profiles tp ON tc.teacher_id = tp.id
      JOIN courses c ON tc.course_id = c.id
      WHERE tp.user_id = :userId
      ORDER BY c.name
    `, {
      replacements: { userId }
    });

    res.json(rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error al obtener cursos del docente" });
  }
};


// POST /programa
export const uploadProgram = async (req, res) => {
  const transaction = await sequelize.transaction();

  try {
    const file = req.file;
    const { teacher_course_id } = req.body;

    if (!file) {
      return res.status(400).json({ message: "No subió ningún archivo" });
    }

    if (!teacher_course_id) {
      return res.status(400).json({ message: "teacher_course_id requerido" });
    }

    if (file.mimetype !== "application/pdf") {
      return res.status(400).json({
        message: "Solo archivos PDF son permitidos",
      });
    }

    // Subir a Cloudinary
    const result = await new Promise((resolve, reject) => {
      cloudinary.uploader
        .upload_stream(
          {
            resource_type: "raw",
            folder: "course_programs",
          },
          (error, result) => {
            if (error) reject(error);
            else resolve(result);
          }
        )
        .end(file.buffer);
    });

    // Guardar en BD
    const [program] = await sequelize.query(
      `
      INSERT INTO course_programs (
        id,
        teacher_course_id,
        document_url,
        document_key,
        file_size,
        mime_type,
        uploaded_by
      )
      VALUES (
        :id,
        :teacher_course_id,
        :url,
        :key,
        :size,
        :mime,
        :user
      )
      RETURNING *
      `,
      {
        replacements: {
          id: uuidv4(),
          teacher_course_id,
          url: result.secure_url,
          key: result.public_id,
          size: file.size,
          mime: file.mimetype,
          user: req.user.id,
        },
        type: sequelize.QueryTypes.INSERT,
        transaction,
      }
    );

    await transaction.commit();

    return res.json({
      message: "Programa subido y guardado correctamente",
      data: program,
    });

  } catch (error) {
    await transaction.rollback();
    console.error(error);

    return res.status(500).json({
      message: "Error al guardar programa",
    });
  }
};
