import {Router} from "express";
import {
    createCursosDocenteAsignacion, deleteCursosDocenteAsignacion,
    getCursosDocenteAsignacion
} from "../controllers/docentesAsignacionController.js";


const router = Router();

router.get("/", getCursosDocenteAsignacion);
router.post("/", createCursosDocenteAsignacion);
router.delete("/:id", deleteCursosDocenteAsignacion);

export default router;