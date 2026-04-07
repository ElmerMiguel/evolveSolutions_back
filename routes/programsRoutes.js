import { Router } from "express";
// import { getPrograms, uploadProgramsView, uploadProgram } from "../controllers/programsController.js";
import { getPrograms, uploadProgram } from "../controllers/programsController.js";
import upload from "../middlewares/fileUploadMiddleware.js";

const router = Router();


router.get("/", getPrograms);
// router.post("/", uploadProgramsView);
router.post("/upload", upload.single('file'), uploadProgram); 

export default router;