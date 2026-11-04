/*
  Warnings:

  - The `localization_type` column on the `episodes` table would be dropped and recreated. This will lead to data loss if there is data in the column.

*/
-- CreateEnum
CREATE TYPE "episode_localization_type_enum" AS ENUM ('sub', 'dub');

-- AlterTable
ALTER TABLE "episodes" DROP COLUMN "localization_type",
ADD COLUMN     "localization_type" "episode_localization_type_enum";
