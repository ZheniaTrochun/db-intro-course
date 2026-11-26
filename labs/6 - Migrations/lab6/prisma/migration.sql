-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "country_enum" AS ENUM ('USA', 'China', 'Ukraine', 'Sweden', 'Brazil', 'Other');

-- CreateEnum
CREATE TYPE "game_genre" AS ENUM ('FPS', 'strategy', 'RTS', 'card game', 'MOBA', 'other');

-- CreateEnum
CREATE TYPE "match_status" AS ENUM ('planned', 'in progress', 'finished', 'cancelled');

-- CreateEnum
CREATE TYPE "role_enum" AS ENUM ('Captain', 'Player');

-- CreateEnum
CREATE TYPE "tournament_status" AS ENUM ('planned', 'in works', 'happeninng', 'done', 'cancelled');

-- CreateTable
CREATE TABLE "game" (
    "game_id" SERIAL NOT NULL,
    "game_name" TEXT NOT NULL,
    "genre" "game_genre" NOT NULL DEFAULT 'other',

    CONSTRAINT "game_pkey" PRIMARY KEY ("game_id")
);

-- CreateTable
CREATE TABLE "game_match" (
    "game_match_id" SERIAL NOT NULL,
    "tournament_id" INTEGER NOT NULL,
    "status" "match_status" NOT NULL DEFAULT 'planned',
    "match_date" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "game_match_pkey" PRIMARY KEY ("game_match_id")
);

-- CreateTable
CREATE TABLE "game_team" (
    "game_team_id" SERIAL NOT NULL,
    "game_id" INTEGER NOT NULL,
    "team_id" INTEGER NOT NULL,
    "coach_name" TEXT,

    CONSTRAINT "game_team_pkey" PRIMARY KEY ("game_team_id")
);

-- CreateTable
CREATE TABLE "match_participant" (
    "game_match_id" INTEGER NOT NULL,
    "game_team_id" INTEGER NOT NULL,
    "is_winner" BOOLEAN,

    CONSTRAINT "pk_game_match_game_team" PRIMARY KEY ("game_match_id","game_team_id")
);

-- CreateTable
CREATE TABLE "orginizer" (
    "orginizer_id" SERIAL NOT NULL,
    "orginizer_name" TEXT NOT NULL,

    CONSTRAINT "orginizer_pkey" PRIMARY KEY ("orginizer_id")
);

-- CreateTable
CREATE TABLE "player" (
    "player_id" SERIAL NOT NULL,
    "nickname" TEXT NOT NULL,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "country" "country_enum" NOT NULL,
    "date_of_birth" DATE NOT NULL,

    CONSTRAINT "player_pkey" PRIMARY KEY ("player_id")
);

-- CreateTable
CREATE TABLE "prize" (
    "tournament_id" INTEGER NOT NULL,
    "place" INTEGER NOT NULL,
    "prize" TEXT NOT NULL,

    CONSTRAINT "pk" PRIMARY KEY ("tournament_id","place")
);

-- CreateTable
CREATE TABLE "team" (
    "team_id" SERIAL NOT NULL,
    "team_name" TEXT NOT NULL,
    "country" "country_enum" NOT NULL,

    CONSTRAINT "team_pkey" PRIMARY KEY ("team_id")
);

-- CreateTable
CREATE TABLE "team_player" (
    "player_id" INTEGER NOT NULL,
    "game_team_id" INTEGER NOT NULL,
    "join_date" DATE NOT NULL,
    "leave_date" DATE,
    "team_role" "role_enum" NOT NULL,

    CONSTRAINT "pk_team_player" PRIMARY KEY ("player_id","game_team_id","join_date")
);

-- CreateTable
CREATE TABLE "tournament" (
    "tournament_id" SERIAL NOT NULL,
    "game_id" INTEGER NOT NULL,
    "orginizer_id" INTEGER NOT NULL,
    "tournament_name" TEXT NOT NULL,
    "start_date" TIMESTAMPTZ(6) NOT NULL,
    "status" "tournament_status" NOT NULL DEFAULT 'planned',

    CONSTRAINT "tournament_pkey" PRIMARY KEY ("tournament_id")
);

-- CreateTable
CREATE TABLE "tournament_participation" (
    "game_team_id" INTEGER,
    "tournament_id" INTEGER NOT NULL,
    "place" INTEGER NOT NULL,

    CONSTRAINT "pk_tournament_participation" PRIMARY KEY ("tournament_id","place")
);

-- CreateIndex
CREATE UNIQUE INDEX "uq_game_name" ON "game"("game_name");

-- CreateIndex
CREATE UNIQUE INDEX "uq_orginizer_name" ON "orginizer"("orginizer_name");

-- CreateIndex
CREATE UNIQUE INDEX "uq_nickname" ON "player"("nickname");

-- CreateIndex
CREATE UNIQUE INDEX "uq_team_name" ON "team"("team_name");

-- CreateIndex
CREATE UNIQUE INDEX "uq_no_double_participation" ON "team_player"("player_id", "game_team_id", "leave_date");

-- AddForeignKey
ALTER TABLE "game_match" ADD CONSTRAINT "fk_tournament" FOREIGN KEY ("tournament_id") REFERENCES "tournament"("tournament_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "game_team" ADD CONSTRAINT "fk_game_id" FOREIGN KEY ("game_id") REFERENCES "game"("game_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "game_team" ADD CONSTRAINT "fk_team_id" FOREIGN KEY ("team_id") REFERENCES "team"("team_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "match_participant" ADD CONSTRAINT "fk_game_match" FOREIGN KEY ("game_match_id") REFERENCES "game_match"("game_match_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "match_participant" ADD CONSTRAINT "fk_game_team" FOREIGN KEY ("game_team_id") REFERENCES "game_team"("game_team_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "prize" ADD CONSTRAINT "fk_tournament_id" FOREIGN KEY ("tournament_id") REFERENCES "tournament"("tournament_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "team_player" ADD CONSTRAINT "fk_game_team_id" FOREIGN KEY ("game_team_id") REFERENCES "game_team"("game_team_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "team_player" ADD CONSTRAINT "fk_player_id" FOREIGN KEY ("player_id") REFERENCES "player"("player_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tournament" ADD CONSTRAINT "fk_game" FOREIGN KEY ("game_id") REFERENCES "game"("game_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tournament" ADD CONSTRAINT "fk_orginizer" FOREIGN KEY ("orginizer_id") REFERENCES "orginizer"("orginizer_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tournament_participation" ADD CONSTRAINT "fk_game_team_id" FOREIGN KEY ("game_team_id") REFERENCES "game_team"("game_team_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tournament_participation" ADD CONSTRAINT "fk_tournament_id" FOREIGN KEY ("tournament_id") REFERENCES "tournament"("tournament_id") ON DELETE CASCADE ON UPDATE CASCADE;

