-- CreateEnum
CREATE TYPE "discipline" AS ENUM ('POOL_8_BALL', 'POOL_9_BALL', 'SNOOKER', 'FREE_PYRAMID', 'COMBINED_PYRAMID', 'DYNAMIC_PYRAMID', 'CARAMBOLE');

-- CreateEnum
CREATE TYPE "format" AS ENUM ('SINGLE_ELIMINATION', 'DOUBLE_ELIMINATION', 'ROUND_ROBIN');

-- CreateEnum
CREATE TYPE "match_stage" AS ENUM ('QUALIFICATION', 'GROUP_STAGE', 'ROUND_OF_64', 'ROUND_OF_32', 'ROUND_OF_16', 'QUARTERFINAL', 'SEMIFINAL', 'FINAL', 'THIRD_PLACE');

-- CreateEnum
CREATE TYPE "match_status" AS ENUM ('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'WALKOVER', 'CANCELLED');

-- CreateEnum
CREATE TYPE "participant_side" AS ENUM ('SIDE_1', 'SIDE_2', 'SIDE_3', 'SIDE_4');

-- CreateEnum
CREATE TYPE "payment_status" AS ENUM ('PENDING', 'PAID', 'WAIVED', 'REFUNDED');

-- CreateEnum
CREATE TYPE "sports_title" AS ENUM ('NONE', 'THIRD_CATEGORY', 'SECOND_CATEGORY', 'FIRST_CATEGORY', 'CANDIDATE_MASTER_OF_SPORTS', 'MASTER_OF_SPORTS', 'INTERNATIONAL_MASTER_OF_SPORTS', 'HONORED_MASTER_OF_SPORTS');

-- CreateEnum
CREATE TYPE "table_status" AS ENUM ('AVAILABLE', 'OCCUPIED', 'RESERVED', 'MAINTENANCE');

-- CreateEnum
CREATE TYPE "table_type" AS ENUM ('PYRAMID_12FT', 'PYRAMID_10FT', 'POOL_9FT', 'POOL_8FT', 'SNOOKER_12FT', 'CARAMBOLE');

-- CreateEnum
CREATE TYPE "tournament_status" AS ENUM ('ANNOUNCED', 'REGISTRATION_OPEN', 'ONGOING', 'FINISHED');

-- CreateTable
CREATE TABLE "billiard_table" (
    "table_id" SERIAL NOT NULL,
    "club_id" INTEGER NOT NULL,
    "table_number" SMALLINT NOT NULL,
    "table_type" "table_type" NOT NULL,
    "table_status" "table_status" NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "billiard_table_pkey" PRIMARY KEY ("table_id")
);

-- CreateTable
CREATE TABLE "club" (
    "club_id" SERIAL NOT NULL,
    "club_name" VARCHAR(100) NOT NULL,
    "city" VARCHAR(100) NOT NULL,
    "address" VARCHAR(200) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "club_pkey" PRIMARY KEY ("club_id")
);

-- CreateTable
CREATE TABLE "match" (
    "match_id" SERIAL NOT NULL,
    "tournament_id" INTEGER NOT NULL,
    "table_id" INTEGER,
    "stage" "match_stage" NOT NULL,
    "race_to_frames" SMALLINT,
    "race_to_points" SMALLINT,
    "time_limit_minutes" SMALLINT,
    "match_status" "match_status" NOT NULL DEFAULT 'SCHEDULED',
    "scheduled_at" TIMESTAMPTZ(6),
    "started_at" TIMESTAMPTZ(6),
    "finished_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "match_pkey" PRIMARY KEY ("match_id")
);

-- CreateTable
CREATE TABLE "match_participant" (
    "match_participant_id" SERIAL NOT NULL,
    "match_id" INTEGER NOT NULL,
    "player_id" INTEGER,
    "team_id" INTEGER,
    "frames_won" SMALLINT,
    "points" SMALLINT,
    "side" "participant_side" NOT NULL,
    "is_winner" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "match_participant_pkey" PRIMARY KEY ("match_participant_id")
);

-- CreateTable
CREATE TABLE "player" (
    "player_id" SERIAL NOT NULL,
    "person_id" INTEGER NOT NULL,
    "rating" INTEGER,
    "sports_title" "sports_title" NOT NULL DEFAULT 'NONE',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "player_pkey" PRIMARY KEY ("player_id")
);

-- CreateTable
CREATE TABLE "team" (
    "team_id" SERIAL NOT NULL,
    "team_name" VARCHAR(100) NOT NULL,
    "captain_id" INTEGER NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "team_pkey" PRIMARY KEY ("team_id")
);

-- CreateTable
CREATE TABLE "team_member" (
    "team_id" INTEGER NOT NULL,
    "player_id" INTEGER NOT NULL,
    "joined_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "team_member_pkey" PRIMARY KEY ("team_id","player_id")
);

-- CreateTable
CREATE TABLE "tournament" (
    "tournament_id" SERIAL NOT NULL,
    "club_id" INTEGER NOT NULL,
    "director_id" INTEGER NOT NULL,
    "tournament_name" VARCHAR(150) NOT NULL,
    "max_participants" SMALLINT NOT NULL,
    "entry_fee" DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    "prize_pool" DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    "discipline" "discipline" NOT NULL,
    "format" "format" NOT NULL,
    "tournament_status" "tournament_status" NOT NULL DEFAULT 'ANNOUNCED',
    "registration_deadline" TIMESTAMPTZ(6) NOT NULL,
    "start_date" TIMESTAMPTZ(6) NOT NULL,
    "end_date" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "tournament_pkey" PRIMARY KEY ("tournament_id")
);

-- CreateTable
CREATE TABLE "tournament_registration" (
    "tournament_registration_id" SERIAL NOT NULL,
    "tournament_id" INTEGER NOT NULL,
    "player_id" INTEGER,
    "team_id" INTEGER,
    "seed_number" SMALLINT,
    "payment_status" "payment_status" NOT NULL DEFAULT 'PENDING',
    "final_placement" SMALLINT,
    "prize_won" DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    "registered_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "tournament_registration_pkey" PRIMARY KEY ("tournament_registration_id")
);

-- CreateTable
CREATE TABLE "users" (
    "user_id" SERIAL NOT NULL,
    "first_name" VARCHAR(100) NOT NULL,
    "last_name" VARCHAR(100) NOT NULL,
    "email" VARCHAR(320) NOT NULL,
    "password_hash" VARCHAR(255) NOT NULL,
    "date_of_birth" DATE NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "users_pkey" PRIMARY KEY ("user_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "uq_billiard_table_club_number" ON "billiard_table"("club_id", "table_number");

-- CreateIndex
CREATE INDEX "idx_match_table_id" ON "match"("table_id");

-- CreateIndex
CREATE INDEX "idx_match_tournament_id" ON "match"("tournament_id");

-- CreateIndex
CREATE INDEX "idx_match_participant_player_id" ON "match_participant"("player_id");

-- CreateIndex
CREATE INDEX "idx_match_participant_team_id" ON "match_participant"("team_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_match_single_winner" ON "match_participant"("match_id") WHERE (is_winner = true);

-- CreateIndex
CREATE UNIQUE INDEX "uq_match_participant_player" ON "match_participant"("match_id", "player_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_match_participant_side" ON "match_participant"("match_id", "side");

-- CreateIndex
CREATE UNIQUE INDEX "uq_match_participant_team" ON "match_participant"("match_id", "team_id");

-- CreateIndex
CREATE UNIQUE INDEX "player_person_id_key" ON "player"("person_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_team_name" ON "team"("team_name");

-- CreateIndex
CREATE INDEX "idx_team_captain_id" ON "team"("captain_id");

-- CreateIndex
CREATE INDEX "idx_team_member_player_id" ON "team_member"("player_id");

-- CreateIndex
CREATE INDEX "idx_tournament_club_id" ON "tournament"("club_id");

-- CreateIndex
CREATE INDEX "idx_tournament_director_id" ON "tournament"("director_id");

-- CreateIndex
CREATE INDEX "idx_tournament_registration_player_id" ON "tournament_registration"("player_id");

-- CreateIndex
CREATE INDEX "idx_tournament_registration_team_id" ON "tournament_registration"("team_id");

-- CreateIndex
CREATE INDEX "idx_tournament_registration_tournament_id" ON "tournament_registration"("tournament_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_registration_tournament_player" ON "tournament_registration"("tournament_id", "player_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_registration_tournament_seed" ON "tournament_registration"("tournament_id", "seed_number");

-- CreateIndex
CREATE UNIQUE INDEX "uq_registration_tournament_team" ON "tournament_registration"("tournament_id", "team_id");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- AddForeignKey
ALTER TABLE "billiard_table" ADD CONSTRAINT "billiard_table_club_id_fkey" FOREIGN KEY ("club_id") REFERENCES "club"("club_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "match" ADD CONSTRAINT "match_table_id_fkey" FOREIGN KEY ("table_id") REFERENCES "billiard_table"("table_id") ON DELETE SET NULL ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "match" ADD CONSTRAINT "match_tournament_id_fkey" FOREIGN KEY ("tournament_id") REFERENCES "tournament"("tournament_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "match_participant" ADD CONSTRAINT "match_participant_match_id_fkey" FOREIGN KEY ("match_id") REFERENCES "match"("match_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "match_participant" ADD CONSTRAINT "match_participant_player_id_fkey" FOREIGN KEY ("player_id") REFERENCES "player"("player_id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "match_participant" ADD CONSTRAINT "match_participant_team_id_fkey" FOREIGN KEY ("team_id") REFERENCES "team"("team_id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "player" ADD CONSTRAINT "player_person_id_fkey" FOREIGN KEY ("person_id") REFERENCES "users"("user_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "team" ADD CONSTRAINT "team_captain_id_fkey" FOREIGN KEY ("captain_id") REFERENCES "player"("player_id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "team_member" ADD CONSTRAINT "team_member_player_id_fkey" FOREIGN KEY ("player_id") REFERENCES "player"("player_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "team_member" ADD CONSTRAINT "team_member_team_id_fkey" FOREIGN KEY ("team_id") REFERENCES "team"("team_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "tournament" ADD CONSTRAINT "tournament_club_id_fkey" FOREIGN KEY ("club_id") REFERENCES "club"("club_id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "tournament" ADD CONSTRAINT "tournament_director_id_fkey" FOREIGN KEY ("director_id") REFERENCES "users"("user_id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "tournament_registration" ADD CONSTRAINT "tournament_registration_player_id_fkey" FOREIGN KEY ("player_id") REFERENCES "player"("player_id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "tournament_registration" ADD CONSTRAINT "tournament_registration_team_id_fkey" FOREIGN KEY ("team_id") REFERENCES "team"("team_id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "tournament_registration" ADD CONSTRAINT "tournament_registration_tournament_id_fkey" FOREIGN KEY ("tournament_id") REFERENCES "tournament"("tournament_id") ON DELETE CASCADE ON UPDATE NO ACTION;
