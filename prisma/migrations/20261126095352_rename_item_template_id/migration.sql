/*
  Warnings:

  - You are about to drop the column `item_tmpl_id` on the `item` table. All the data in the column will be lost.
  - Added the required column `item_template_id` to the `item` table without a default value. This is not possible if the table is not empty.

*/
ALTER TABLE "public"."item"
RENAME COLUMN "item_tmpl_id" TO "item_template_id";

ALTER TABLE "public"."item"
RENAME CONSTRAINT "item_item_tmpl_id_fkey"
TO "item_item_template_id_fkey";