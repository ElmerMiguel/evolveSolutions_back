import { Router } from "express";
import {
    createSolicitud,
    getAllSolicitudes,
    getDocumentosSolicitud,
    getOneSolicitud,
    uploadDocumentoSolicitud,
    updateEstadoSolicitud,
} from "../controllers/equivalenciasController.js";
import upload from "../middlewares/fileUploadMiddleware.js";
import autenticacionToken from "../middlewares/autenticacionToken.js";

const router = Router();

router.get("/", getAllSolicitudes);
router.get("/documentos/:id", getDocumentosSolicitud);
router.get("/:id", getOneSolicitud);
router.post("/", createSolicitud);
router.post(
    "/:id/documentos",
    autenticacionToken,
    upload.single("file"),
    uploadDocumentoSolicitud
);
router.patch("/:id/status", updateEstadoSolicitud);

export default router;
