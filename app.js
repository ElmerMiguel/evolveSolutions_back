import express from 'express';
import session from 'express-session';
import path from 'path';
import cookieParser from 'cookie-parser';
import logger from 'morgan';
import cors from 'cors';

import sequelize from "./config/db.js";
import router from "./routes/index.js";

const app = express();

app.use(logger('dev'));
app.use(express.json());

sequelize.authenticate()
  .then(() => {
    console.log('Conectado a la db');
  })
  .catch(err => {
    console.error('No se ha realizado la conexion a db: ', err);
  });

app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(path.dirname(''), 'public')));


const allowedOrigins = [
  "http://localhost:5173", 
  "https://prismatic-creponne-fb5e08.netlify.app" 
];

app.use(cors({
  origin: function (origin, callback) {
    // Permite llamadas sin origin (ej. curl, Postman)
    if (!origin) return callback(null, true);
    if (allowedOrigins.includes(origin)) {
      return callback(null, true);
    } else {
      return callback(new Error("Not allowed by CORS"));
    }
  },
  credentials: true
}));

app.use(session({
  secret: process.env.SESSION_SECRET || 'evolvesolutions_fallback_secret_12345',
  resave: false,
  saveUninitialized: true,
  cookie: {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: process.env.NODE_ENV === 'production' ? 'none' : 'lax',
    maxAge: 24 * 60 * 60 * 1000,
  }
}));

app.use(`/`, router);

app.use((err, req, res, next) => {
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};
  res.status(err.status || 500);
  res.json({
    message: res.locals.message,
    error: res.locals.error
  });
});

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server started on port ${PORT}`);
});

export default app;
