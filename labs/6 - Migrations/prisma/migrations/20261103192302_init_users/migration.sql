-- CreateEnum
CREATE TYPE "user_status_enum" AS ENUM ('admin', 'banned', 'deactivated');

-- CreateTable
CREATE TABLE "users" (
    "user_id" UUID NOT NULL DEFAULT uuidv7(),
    "nickname" VARCHAR(30) NOT NULL,
    "full_name" VARCHAR(100) NOT NULL,
    "email" TEXT NOT NULL,
    "google_id" TEXT,
    "bio" TEXT NOT NULL DEFAULT '',
    "password_hash" TEXT,
    "avatar_url" TEXT,
    "social_networks" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "max_streak" INTEGER NOT NULL DEFAULT 0,
    "timezone" TEXT NOT NULL DEFAULT 'UTC',
    "last_watch_date" DATE,
    "profile_frame_url" TEXT,
    "profile_background_url" TEXT,
    "user_status" "user_status_enum",
    "crated_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "users_pkey" PRIMARY KEY ("user_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_nickname_key" ON "users"("nickname");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "users_google_id_key" ON "users"("google_id");

-- CreateIndex
CREATE INDEX "idx_user_status" ON "users"("user_status");

-- CreateIndex
CREATE INDEX "idx_nickname" ON "users"("nickname");
