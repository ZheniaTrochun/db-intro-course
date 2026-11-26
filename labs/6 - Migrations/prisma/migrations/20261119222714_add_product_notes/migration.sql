-- AlterTable
ALTER TABLE "product" ADD COLUMN     "notes" TEXT;

-- Data migration: copy legacy description into new notes column (expand step)
UPDATE "product" SET "notes" = "description" WHERE "notes" IS NULL;