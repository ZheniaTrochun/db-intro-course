/*
  Warnings:

  - You are about to drop the column `comment` on the `review` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "collection" ADD COLUMN     "description" VARCHAR(255),
ADD COLUMN     "updated_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- AlterTable
ALTER TABLE "review" DROP COLUMN "comment";
