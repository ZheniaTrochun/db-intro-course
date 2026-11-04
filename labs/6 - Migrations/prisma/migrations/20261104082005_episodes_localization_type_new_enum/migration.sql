-- CreateEnum
CREATE TYPE "episode_localization_type_enum" AS ENUM ('sub', 'dub');

-- AlterTable
ALTER TABLE "episodes"
  ALTER COLUMN "localization_type" TYPE "episode_localization_type_enum"
  USING ("localization_type"::text::"episode_localization_type_enum");
