import nodemailer from "nodemailer";
import dotenv from "dotenv";

dotenv.config();

const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
        user: process.env.MAIL_USER,
        pass: process.env.MAIL_PASS,
    },
});

transporter
    .verify()
    .then(() => console.log("Gmail conectado (ESM)"))
    .catch((err) => console.error("Error:", err));

export default transporter;
