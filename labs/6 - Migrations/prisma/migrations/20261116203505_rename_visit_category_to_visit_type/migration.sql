/*
  Warnings:

  - You are about to drop the column `category` on the `visit` table. All the data in the column will be lost.

*/
ALTER TABLE "visit" RENAME COLUMN "category" TO "visit_type";