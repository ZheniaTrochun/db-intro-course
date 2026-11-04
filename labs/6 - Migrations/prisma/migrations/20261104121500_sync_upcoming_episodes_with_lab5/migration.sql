-- Add surrogate key
ALTER TABLE "upcoming_episodes" ADD COLUMN "upcoming_episode_id" UUID NOT NULL DEFAULT uuidv7();

-- Drop old composite primary key
ALTER TABLE "upcoming_episodes" DROP CONSTRAINT "upcoming_episodes_pkey";

-- Add new primary key on surrogate key
ALTER TABLE "upcoming_episodes" ADD PRIMARY KEY ("upcoming_episode_id");

-- Add unique constraint on (anime_id, episode_name)
ALTER TABLE "upcoming_episodes" ADD CONSTRAINT "upcoming_episodes_anime_id_episode_name_key" UNIQUE ("anime_id", "episode_name");

-- Add CHECK constraint on episode_name
ALTER TABLE "upcoming_episodes" ADD CONSTRAINT "upcoming_episodes_episode_name_check" CHECK (length(trim(episode_name)) > 0);
