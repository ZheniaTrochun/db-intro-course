-- AlterEnum
ALTER TYPE "anime_status_enum" ADD VALUE 'dropped';

-- is_exist -> available (перейменування, а не drop)
ALTER TABLE "animes" RENAME COLUMN "is_exist" TO "available";
ALTER TABLE "animes" ALTER COLUMN "available" SET DEFAULT true;
UPDATE "animes" SET "available" = true;

-- defaults
ALTER TABLE "animes"
  ALTER COLUMN "title_ua" SET DEFAULT '',
  ALTER COLUMN "title_en" SET DEFAULT '',
  ALTER COLUMN "title_original" SET DEFAULT '',
  ALTER COLUMN "avg_episode_duration" SET DEFAULT 0,
  ALTER COLUMN "episode_count" SET DEFAULT 0;

-- mal_id / anilist_id: text -> integer зі збереженням даних
ALTER TABLE "animes"
  ALTER COLUMN "mal_id" TYPE INTEGER USING NULLIF(trim("mal_id"), '')::integer,
  ALTER COLUMN "anilist_id" TYPE INTEGER USING NULLIF(trim("anilist_id"), '')::integer;

-- CreateIndex
CREATE INDEX "idx_anime_available" ON "animes"("available");