import { Router } from "express";
import authRouter from "./authRouter.js";
import coursesRouter from "./coursesRouter.js";
import programsRoutes from "./programsRoutes.js";
import estudianteAsignacionRouter from "./estudianteAsignacionRouter.js";
import docentesAsignacionRouter from "./docentesAsignacionRouter.js";
import equivalenciasRouter from "./equivalenciasRouter.js";

const router = Router();

router.use('/auth', authRouter);
router.use('/cursos', coursesRouter);
router.use('/programas', programsRoutes);
router.use('/estudianteCursos', estudianteAsignacionRouter);
router.use('/docenteCursos', docentesAsignacionRouter);
router.use('/equivalencias', equivalenciasRouter);

export default router;
