-- CreateTable
CREATE TABLE "review_comments" (
    "comment_id" BIGSERIAL NOT NULL,
    "review_id" BIGINT NOT NULL,
    "user_id" BIGINT NOT NULL,
    "content" VARCHAR(1000) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "review_comments_pkey" PRIMARY KEY ("comment_id")
);

-- AddForeignKey
ALTER TABLE "review_comments" ADD CONSTRAINT "review_comments_review_id_fkey" FOREIGN KEY ("review_id") REFERENCES "review"("review_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "review_comments" ADD CONSTRAINT "review_comments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("user_id") ON DELETE CASCADE ON UPDATE CASCADE;
