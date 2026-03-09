import express from 'express';
import login from '../controllers/authController.js';
const router = express.Router();

// router.get('/',autenticacionToken, verificarToken);
router.post('/login', login);
// router.post('/logout', autenticacionToken, logout);
// router.post('/register', registrar)

export default router;