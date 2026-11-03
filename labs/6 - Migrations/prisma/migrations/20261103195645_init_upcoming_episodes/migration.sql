-- CreateTable
CREATE TABLE "upcoming_episodes" (
    "anime_id" UUID NOT NULL,
    "episode_name" TEXT NOT NULL,
    "episode_date" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "upcoming_episodes_pkey" PRIMARY KEY ("anime_id","episode_name")
);

-- AddForeignKey
ALTER TABLE "upcoming_episodes" ADD CONSTRAINT "upcoming_episodes_anime_id_fkey" FOREIGN KEY ("anime_id") REFERENCES "animes"("anime_id") ON DELETE RESTRICT ON UPDATE CASCADE;
