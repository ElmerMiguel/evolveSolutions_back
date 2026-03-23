import express from 'express';
import { login, registrar, logout, verificarToken } from '../controllers/authController.js';
import autenticacionToken from '../middlewares/autenticacionToken.js';

const router = express.Router();

// router.get('/',autenticacionToken, verificarToken);
router.post('/login', login);
router.post('/logout', autenticacionToken, logout);
router.post('/register', registrar);
router.get('/me', autenticacionToken, verificarToken);

export default router;