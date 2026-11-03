-- CreateTable
CREATE TABLE "episodes" (
    "episode_id" BIGSERIAL NOT NULL,
    "anime_id" UUID NOT NULL,
    "source_url" TEXT NOT NULL,
    "episode_name" TEXT NOT NULL,
    "localization_studio" TEXT NOT NULL DEFAULT '',
    "localization_type" TEXT,

    CONSTRAINT "episodes_pkey" PRIMARY KEY ("episode_id")
);

-- CreateIndex
CREATE INDEX "idx_episodes_anime_id" ON "episodes"("anime_id");

-- AddForeignKey
ALTER TABLE "episodes" ADD CONSTRAINT "episodes_anime_id_fkey" FOREIGN KEY ("anime_id") REFERENCES "animes"("anime_id") ON DELETE CASCADE ON UPDATE CASCADE;
