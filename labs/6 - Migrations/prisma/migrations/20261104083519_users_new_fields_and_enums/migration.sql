-- CreateEnum
CREATE TYPE "user_role_enum" AS ENUM ('user', 'admin');

-- Add user_role before enum migration to preserve 'admin' values
ALTER TABLE "users" ADD COLUMN "user_role" "user_role_enum" NOT NULL DEFAULT 'user';

-- Migrate users with status 'admin' to the new user_role column
UPDATE "users" SET "user_role" = 'admin' WHERE "user_status"::text = 'admin';

-- AlterEnum
BEGIN;
CREATE TYPE "user_status_enum_new" AS ENUM ('active', 'banned', 'deactivated');

-- Map 'admin' and existing NULL values safely to 'active'
ALTER TABLE "users" ALTER COLUMN "user_status" DROP DEFAULT;
ALTER TABLE "users" ALTER COLUMN "user_status" TYPE "user_status_enum_new" 
  USING (
    CASE 
      WHEN "user_status"::text = 'admin' OR "user_status" IS NULL THEN 'active'::"user_status_enum_new"
      ELSE "user_status"::text::"user_status_enum_new"
    END
  );

ALTER TYPE "user_status_enum" RENAME TO "user_status_enum_old";
ALTER TYPE "user_status_enum_new" RENAME TO "user_status_enum";
DROP TYPE "user_status_enum_old";
COMMIT;

-- DropIndex
DROP INDEX "idx_nickname";

-- RenameColumn
ALTER TABLE "users" RENAME COLUMN "crated_at" TO "created_at";

-- AlterTable
ALTER TABLE "users" 
ADD COLUMN "streak_start_date" DATE,
ALTER COLUMN "created_at" SET DATA TYPE TIMESTAMPTZ(6) USING "created_at" AT TIME ZONE 'UTC',
ALTER COLUMN "updated_at" SET DATA TYPE TIMESTAMPTZ(6) USING "updated_at" AT TIME ZONE 'UTC',
ALTER COLUMN "user_status" SET NOT NULL,
ALTER COLUMN "user_status" SET DEFAULT 'active';

-- AddConstraints
ALTER TABLE "users" ADD CONSTRAINT "users_max_streak_check" CHECK ("max_streak" >= 0);
ALTER TABLE "users" ADD CONSTRAINT "check_user_auth_method" CHECK ("password_hash" IS NOT NULL OR "google_id" IS NOT NULL);