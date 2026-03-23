import sequelize from "../config/db.js";
import { DataTypes, Op } from "sequelize";
import crypto from "crypto";

const Session = sequelize.define(
    "sessions",
    {
        id: {
            type: DataTypes.UUID,
            allowNull: false,
            primaryKey: true,
            defaultValue: DataTypes.UUIDV4,
        },
        user_id: {
            type: DataTypes.UUID,
            allowNull: false,
            references: {
                model: "users",
                key: "id",
            },
            onDelete: "CASCADE",
        },
        session_token_hash: {
            type: DataTypes.STRING(255),
            allowNull: false,
            unique: true,
        },
        created_at: {
            type: DataTypes.DATE,
            allowNull: false,
            defaultValue: DataTypes.NOW,
        },
        expires_at: {
            type: DataTypes.DATE,
            allowNull: false,
            field: "access_token_expires_at",
        },
        revoked_at: {
            type: DataTypes.DATE,
            allowNull: true,
        },
    },
    {
        tableName: "sessions",
        timestamps: false,
    }
);

Session.checkActive = async function (userId) {
    const now = new Date();
    const session = await Session.findOne({
        where: {
            user_id: userId,
            revoked_at: null,
            expires_at: { [Op.gt]: now },
        },
    });

    if (!session) {
        return false;
    }

    const extended = new Date(session.expires_at.getTime() + 15 * 60 * 1000);
    session.expires_at = extended;
    await session.save();

    return session;
};

Session.createWithToken = async function ({ user, token, expiresIn = 15 }) {
    const tokenHash = crypto.createHash("sha256").update(token).digest("hex");
    const now = new Date();
    const expiresAt = new Date(now.getTime() + expiresIn * 60 * 1000);

    const session = await Session.create({
        user_id: user.id,
        session_token_hash: tokenHash,
        created_at: now,
        expires_at: expiresAt,
        revoked_at: null,
    });

    return session;
};

export default Session;
