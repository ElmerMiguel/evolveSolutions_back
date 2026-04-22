import {Router} from "express";
import { getCursosAsignacion, createCursosAsignacion, deleteCursosAsignacion } from "../controllers/estudianteAsignacionController.js";


const router = Router();

router.get("/", getCursosAsignacion);
router.post("/", createCursosAsignacion);
router.delete("/:id", deleteCursosAsignacion);

export default router;
