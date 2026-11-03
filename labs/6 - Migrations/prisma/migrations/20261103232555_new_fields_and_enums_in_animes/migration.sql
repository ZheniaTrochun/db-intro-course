/*
  Warnings:

  - You are about to drop the column `anime_description` on the `animes` table. All the data in the column will be lost.
  - You are about to drop the column `is_exist` on the `animes` table. All the data in the column will be lost.
  - The `mal_id` column on the `animes` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - The `anilist_id` column on the `animes` table would be dropped and recreated. This will lead to data loss if there is data in the column.

*/
-- AlterEnum
ALTER TYPE "anime_status_enum" ADD VALUE 'dropped';

-- AlterTable
ALTER TABLE "animes" DROP COLUMN "anime_description",
DROP COLUMN "is_exist",
ADD COLUMN     "available" BOOLEAN NOT NULL DEFAULT true,
ALTER COLUMN "title_ua" SET DEFAULT '',
ALTER COLUMN "title_en" SET DEFAULT '',
ALTER COLUMN "title_original" SET DEFAULT '',
DROP COLUMN "mal_id",
ADD COLUMN     "mal_id" INTEGER,
DROP COLUMN "anilist_id",
ADD COLUMN     "anilist_id" INTEGER,
ALTER COLUMN "avg_episode_duration" SET DEFAULT 0,
ALTER COLUMN "episode_count" SET DEFAULT 0;

-- CreateIndex
CREATE INDEX "idx_anime_available" ON "animes"("available");
