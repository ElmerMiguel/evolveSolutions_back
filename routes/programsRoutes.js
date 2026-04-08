import { Router } from "express";
// import { getPrograms, uploadProgramsView, uploadProgram } from "../controllers/programsController.js";
import { getPrograms, getTeacherCourses, uploadProgram } from "../controllers/programsController.js";
import upload from "../middlewares/fileUploadMiddleware.js";
import autenticacionToken from "../middlewares/autenticacionToken.js";

const router = Router();


router.get("/", getPrograms);
router.get("/teacher-courses", autenticacionToken, getTeacherCourses);
// router.post("/", uploadProgramsView);
router.post("/upload", upload.single('file'), uploadProgram); 

export default router;