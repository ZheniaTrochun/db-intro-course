-- CreateTable
CREATE TABLE "book_award" (
    "award_id" SERIAL NOT NULL,
    "book_id" INTEGER NOT NULL,
    "award_name" VARCHAR(150) NOT NULL,
    "award_year" SMALLINT NOT NULL,

    CONSTRAINT "book_award_pkey" PRIMARY KEY ("award_id")
);

-- AddForeignKey
ALTER TABLE "book_award" ADD CONSTRAINT "book_award_book_id_fkey" FOREIGN KEY ("book_id") REFERENCES "book"("book_id") ON DELETE CASCADE ON UPDATE NO ACTION;
