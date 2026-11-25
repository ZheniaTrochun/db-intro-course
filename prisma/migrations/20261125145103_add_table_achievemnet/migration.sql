-- CreateTable
CREATE TABLE "achievement" (
    "achievement_id" SERIAL NOT NULL,
    "app_id" INTEGER NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" VARCHAR(500),
    "points" INTEGER NOT NULL DEFAULT 10,

    CONSTRAINT "achievement_pkey" PRIMARY KEY ("achievement_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "achievement_app_id_name_key" ON "achievement"("app_id", "name");

-- AddForeignKey
ALTER TABLE "achievement" ADD CONSTRAINT "achievement_app_id_fkey" FOREIGN KEY ("app_id") REFERENCES "app"("app_id") ON DELETE CASCADE ON UPDATE CASCADE;
