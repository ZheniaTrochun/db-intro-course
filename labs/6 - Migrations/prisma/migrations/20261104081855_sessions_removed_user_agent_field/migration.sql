/*
  Warnings:

  - You are about to drop the column `user_agent` on the `sessions` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "sessions" DROP COLUMN "user_agent";
