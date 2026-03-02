import sequelize from "../config/db.js";
import {DataTypes} from "sequelize";


const users = sequelize.define('users', {
    id: {
        type: DataTypes.UUID,
        allowNull: false,
        primaryKey: true,
        defaultValue: DataTypes.UUIDV4,
    },
    username: {
        type: DataTypes.STRING(50),
        allowNull: false,
        unique: true,
    },
    email: {
        type: DataTypes.STRING(120),
        allowNull: true,
        unique: true,
    },
    password_hash: {
        type: DataTypes.STRING(255),
        allowNull: false,
    },
    first_name: {
        type: DataTypes.STRING(120),
        allowNull: false,
    },
    last_name: {
        type: DataTypes.STRING(120),
        allowNull: false,
    },
    photo_url: {
        type: DataTypes.STRING(500),
        allowNull: true,
    },
    enabled: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: true,
    },
    locked: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: false,
    },
}, {
    tableName: 'users',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
});

users.login = async function ({ correo, password }) {
    const user = await users.findOne({ where: { email: correo, password_hash: password } });
    if (!user) {
        throw new Error('Usuario no encontrado');
    }

    return user;
}

export default users;
