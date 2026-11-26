/*
  Warnings:

  - You are about to drop the column `genre` on the `game` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "game" RENAME COLUMN "genre" TO "game_genre";

