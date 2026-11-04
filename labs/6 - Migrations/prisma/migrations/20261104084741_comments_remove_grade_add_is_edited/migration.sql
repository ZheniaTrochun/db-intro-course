-- DropIndex
DROP INDEX "idx_comments_anime_id";

-- AlterTable
ALTER TABLE "comments" 
DROP COLUMN "grade",
ADD COLUMN "is_edited" BOOLEAN NOT NULL DEFAULT false,
ALTER COLUMN "created_at" SET DATA TYPE TIMESTAMPTZ(6) USING "created_at" AT TIME ZONE 'UTC';

-- CreateIndex
CREATE INDEX "idx_comments_anime_created" ON "comments"("anime_id", "comment_id" DESC);

-- AddConstraints
ALTER TABLE "comments" ADD CONSTRAINT "comments_content_check" CHECK (length(trim("content")) > 0);