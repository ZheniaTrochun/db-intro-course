import dotenv from "dotenv";

dotenv.config();

export const config = {
  DB_URL: process.env.DATABASE_URL!,
};
