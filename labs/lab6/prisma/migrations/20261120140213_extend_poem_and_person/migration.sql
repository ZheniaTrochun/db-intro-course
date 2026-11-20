-- AlterTable
ALTER TABLE "person" ADD COLUMN     "bio" VARCHAR(300);

-- AlterTable
ALTER TABLE "poem" ADD COLUMN     "is_featured" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "language" VARCHAR(10) NOT NULL DEFAULT 'uk',
ADD COLUMN     "views_count" INTEGER NOT NULL DEFAULT 0;
