import express from 'express';
import login, {
    logout, registrar, verificarToken,
} from '../controllers/authController.js';
import autenticacionToken from '../middlewares/autenticacionToken.js';

const router = express.Router();

router.get('/',autenticacionToken, verificarToken);
router.post('/login', login);
router.post('/logout', autenticacionToken, logout);
router.post('/register', registrar)

export default router;