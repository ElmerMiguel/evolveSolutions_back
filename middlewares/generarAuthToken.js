import jwt from 'jsonwebtoken';

const generarAuthToken = (user) => {
    const usuario = {
        UsuarioID: user.id,
        roles: user.roles,
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        photo_url: user.photo_url,
    }; //Usamos la informacion del usuario para generar el token
    return jwt.sign(usuario, process.env.JWT_SECRET, { expiresIn: '24h' });
};

export default generarAuthToken;