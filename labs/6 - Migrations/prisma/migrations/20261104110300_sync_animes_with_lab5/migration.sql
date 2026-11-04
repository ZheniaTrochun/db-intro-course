-- Add description column
ALTER TABLE "animes" ADD COLUMN "anime_description" TEXT NOT NULL DEFAULT '';

-- Update cover_url and production_studio to NOT NULL DEFAULT ''
ALTER TABLE "animes" ALTER COLUMN "cover_url" SET NOT NULL;
ALTER TABLE "animes" ALTER COLUMN "cover_url" SET DEFAULT '';
ALTER TABLE "animes" ALTER COLUMN "production_studio" SET NOT NULL;
ALTER TABLE "animes" ALTER COLUMN "production_studio" SET DEFAULT '';

-- Change types
ALTER TABLE "animes" ALTER COLUMN "mal_id" TYPE BIGINT;
ALTER TABLE "animes" ALTER COLUMN "anilist_id" TYPE BIGINT;
ALTER TABLE "animes" ALTER COLUMN "year_released" TYPE SMALLINT;
ALTER TABLE "animes" ALTER COLUMN "avg_episode_duration" TYPE SMALLINT;
ALTER TABLE "animes" ALTER COLUMN "episode_count" TYPE SMALLINT;

-- Add unique constraints
ALTER TABLE "animes" ADD CONSTRAINT "animes_mal_id_key" UNIQUE ("mal_id");
ALTER TABLE "animes" ADD CONSTRAINT "animes_anilist_id_key" UNIQUE ("anilist_id");
ALTER TABLE "animes" ADD CONSTRAINT "animes_hikka_id_key" UNIQUE ("hikka_id");
ALTER TABLE "animes" ADD CONSTRAINT "animes_imdb_id_key" UNIQUE ("imdb_id");

-- Add CHECK constraints
ALTER TABLE "animes" ADD CONSTRAINT "animes_year_released_check" CHECK (year_released >= 1900);
ALTER TABLE "animes" ADD CONSTRAINT "animes_avg_episode_duration_check" CHECK (avg_episode_duration >= 0);
ALTER TABLE "animes" ADD CONSTRAINT "animes_episode_count_check" CHECK (episode_count >= 0);

-- Rename enum value 'dropped' to 'cancelled'
CREATE TYPE "anime_status_enum_new" AS ENUM ('upcoming', 'ongoing', 'cancelled', 'finished');
ALTER TABLE "animes" ALTER COLUMN "anime_status" TYPE "anime_status_enum_new" USING ("anime_status"::text::"anime_status_enum_new");
DROP TYPE "anime_status_enum";
ALTER TYPE "anime_status_enum_new" RENAME TO "anime_status_enum";
