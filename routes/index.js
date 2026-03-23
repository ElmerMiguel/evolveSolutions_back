import { Router } from "express";
import authRouter from "./authRouter.js";
import coursesRouter from "./coursesRouter.js";

const router = Router();

router.use('/auth', authRouter);
router.use('/cursos', coursesRouter);

export default router;
