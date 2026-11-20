-- CreateTable
CREATE TABLE "bookmark" (
    "bookmark_id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "poem_id" INTEGER NOT NULL,
    "note" VARCHAR(255),
    "is_favorite" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "bookmark_pkey" PRIMARY KEY ("bookmark_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "bookmark_user_id_poem_id_key" ON "bookmark"("user_id", "poem_id");

-- AddForeignKey
ALTER TABLE "bookmark" ADD CONSTRAINT "bookmark_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "person"("person_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "bookmark" ADD CONSTRAINT "bookmark_poem_id_fkey" FOREIGN KEY ("poem_id") REFERENCES "poem"("poem_id") ON DELETE CASCADE ON UPDATE NO ACTION;
