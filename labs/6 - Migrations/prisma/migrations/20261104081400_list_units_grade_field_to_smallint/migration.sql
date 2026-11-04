/*
  Warnings:

  - You are about to alter the column `grade` on the `anime_list_units` table. The data in that column could be lost. The data in that column will be cast from `Integer` to `SmallInt`.

*/
-- AlterTable
ALTER TABLE "anime_list_units" ALTER COLUMN "grade" SET DATA TYPE SMALLINT;
