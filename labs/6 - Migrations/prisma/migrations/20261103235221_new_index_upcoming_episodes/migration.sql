-- DropForeignKey
ALTER TABLE "upcoming_episodes" DROP CONSTRAINT "upcoming_episodes_anime_id_fkey";

-- CreateIndex
CREATE INDEX "idx_upcoming_episodes_date" ON "upcoming_episodes"("episode_date");

-- AddForeignKey
ALTER TABLE "upcoming_episodes" ADD CONSTRAINT "upcoming_episodes_anime_id_fkey" FOREIGN KEY ("anime_id") REFERENCES "animes"("anime_id") ON DELETE CASCADE ON UPDATE CASCADE;
