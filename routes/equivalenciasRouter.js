import { Router } from "express";
import {
    createSolicitud,
    getAllSolicitudes,
    getDocumentosSolicitud,
    getOneSolicitud,
    updateEstadoSolicitud,
} from "../controllers/equivalenciasController.js";

const router = Router();

router.get("/", getAllSolicitudes);
router.get("/documentos/:id", getDocumentosSolicitud);
router.get("/:id", getOneSolicitud);
router.post("/", createSolicitud);
router.patch("/:id/status", updateEstadoSolicitud);

export default router;
