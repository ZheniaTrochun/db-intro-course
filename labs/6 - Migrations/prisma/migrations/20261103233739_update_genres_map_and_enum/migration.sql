-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "genre_type_enum" ADD VALUE 'thriller';
ALTER TYPE "genre_type_enum" ADD VALUE 'vampire';

-- DropForeignKey
ALTER TABLE "genres" DROP CONSTRAINT "genres_anime_id_fkey";

-- CreateIndex
CREATE INDEX "idx_genres_genre_type" ON "genres"("genre_type");

-- AddForeignKey
ALTER TABLE "genres" ADD CONSTRAINT "genres_anime_id_fkey" FOREIGN KEY ("anime_id") REFERENCES "animes"("anime_id") ON DELETE CASCADE ON UPDATE CASCADE;
