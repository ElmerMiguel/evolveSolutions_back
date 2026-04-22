import { Router } from "express";
import { getCourses, createCourse, getCourseOptions } from "../controllers/coursesController.js";

const router = Router();

// /cursos (the logic expects router to be mounted at /cursos)
router.get("/", getCourses);
router.post("/", createCourse);
router.post("/crear", createCourse); // Added /crear because frontend explicitly hits this
router.get("/options", getCourseOptions);

export default router;
