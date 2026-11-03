/*
  Warnings:

  - You are about to drop the `users` table. If the table is not empty, all the data it contains will be lost.

*/
-- CreateEnum
CREATE TYPE "mpaa_rating_enum" AS ENUM ('g', 'pg', 'pg13', 'r', 'nc17');

-- CreateEnum
CREATE TYPE "anime_status_enum" AS ENUM ('upcoming', 'ongoing', 'finished');

-- CreateEnum
CREATE TYPE "anime_format_enum" AS ENUM ('tv', 'ova', 'ona', 'movie', 'special', 'music', 'other');

-- DropTable
DROP TABLE "users";

-- DropEnum
DROP TYPE "user_status_enum";

-- CreateTable
CREATE TABLE "animes" (
    "anime_id" UUID NOT NULL,
    "slug" TEXT NOT NULL,
    "title_ua" TEXT NOT NULL,
    "title_en" TEXT NOT NULL,
    "title_original" TEXT NOT NULL,
    "anime_description" TEXT NOT NULL DEFAULT '',
    "cover_url" TEXT,
    "production_studio" TEXT,
    "mal_id" TEXT,
    "anilist_id" TEXT,
    "hikka_id" TEXT,
    "imdb_id" TEXT,
    "year_released" INTEGER,
    "avg_episode_duration" INTEGER NOT NULL,
    "episode_count" INTEGER NOT NULL,
    "age_restriction" "mpaa_rating_enum",
    "anime_status" "anime_status_enum",
    "anime_format" "anime_format_enum" NOT NULL DEFAULT 'tv',
    "is_exist" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "animes_pkey" PRIMARY KEY ("anime_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "animes_slug_key" ON "animes"("slug");
