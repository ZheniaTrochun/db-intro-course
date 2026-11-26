-- CreateTable
CREATE TABLE "achievement" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(128) NOT NULL,
    "description" VARCHAR(500) NOT NULL,
    "points" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "achievement_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "achievement_name_key" ON "achievement"("name");
