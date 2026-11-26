-- CreateTable
CREATE TABLE "character_achievement" (
    "character_id" INTEGER NOT NULL,
    "achievement_id" INTEGER NOT NULL,
    "unlocked_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "character_achievement_pkey" PRIMARY KEY ("character_id","achievement_id")
);

-- CreateIndex
CREATE INDEX "character_achievement_achievement_id_idx" ON "character_achievement"("achievement_id");

-- AddForeignKey
ALTER TABLE "character_achievement" ADD CONSTRAINT "character_achievement_character_id_fkey" FOREIGN KEY ("character_id") REFERENCES "character"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "character_achievement" ADD CONSTRAINT "character_achievement_achievement_id_fkey" FOREIGN KEY ("achievement_id") REFERENCES "achievement"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
