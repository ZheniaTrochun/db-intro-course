-- CreateEnum
CREATE TYPE "anime_list_unit_status_enum" AS ENUM ('finished', 'watching', 'delayed', 'dropped');

-- CreateTable
CREATE TABLE "anime_list_units" (
    "user_id" UUID NOT NULL,
    "anime_id" UUID NOT NULL,
    "watched_episodes" INTEGER NOT NULL DEFAULT 0,
    "started_watching" DATE NOT NULL DEFAULT (now())::date,
    "list_unit_status" "anime_list_unit_status_enum" NOT NULL DEFAULT 'watching',
    "grade" INTEGER,

    CONSTRAINT "anime_list_units_pkey" PRIMARY KEY ("user_id","anime_id")
);

-- AddForeignKey
ALTER TABLE "anime_list_units" ADD CONSTRAINT "anime_list_units_anime_id_fkey" FOREIGN KEY ("anime_id") REFERENCES "animes"("anime_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "anime_list_units" ADD CONSTRAINT "anime_list_units_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("user_id") ON DELETE CASCADE ON UPDATE CASCADE;
