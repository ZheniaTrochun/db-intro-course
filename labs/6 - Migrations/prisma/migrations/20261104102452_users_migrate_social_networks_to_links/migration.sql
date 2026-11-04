-- DataMigration
UPDATE "users" SET "avatar_url" = '' WHERE "avatar_url" IS NULL;

-- DataMigration
INSERT INTO "user_links" ("user_id", "user_link_url")
SELECT "user_id", unnest("social_networks")
FROM "users"
WHERE "social_networks" IS NOT NULL AND array_length("social_networks", 1) > 0
ON CONFLICT ("user_id", "user_link_url") DO NOTHING;

-- DropIndex
ALTER TABLE "users" DROP CONSTRAINT IF EXISTS "users_email_key";
ALTER TABLE "users" DROP CONSTRAINT IF EXISTS "users_nickname_key";

-- AlterTable
ALTER TABLE "users" 
DROP COLUMN "social_networks",
ALTER COLUMN "avatar_url" SET DEFAULT '',
ALTER COLUMN "avatar_url" SET NOT NULL,
ALTER COLUMN "timezone" SET DEFAULT 'Europe/Kyiv';

-- RenameIndex
ALTER INDEX "idx_user_status" RENAME TO "idx_users_status";

-- CreateIndex
CREATE UNIQUE INDEX "idx_users_unique_lower_nickname" ON "users"(lower("nickname"));
CREATE UNIQUE INDEX "idx_users_unique_lower_email" ON "users"(lower("email"));