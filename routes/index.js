import { Router } from "express";
import authRouter from "./authRouter.js";
import coursesRouter from "./coursesRouter.js";
import programsRoutes from "./programsRoutes.js";

const router = Router();

router.use('/auth', authRouter);
router.use('/cursos', coursesRouter);
router.use('/programas', programsRoutes);

export default router;
