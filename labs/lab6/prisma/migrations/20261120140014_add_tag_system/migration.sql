-- CreateEnum
CREATE TYPE "poem_status" AS ENUM ('published', 'notes', 'reviewed');

-- CreateEnum
CREATE TYPE "visibility_status" AS ENUM ('public', 'private', 'deleted');

-- CreateTable
CREATE TABLE "collection" (
    "collection_id" SERIAL NOT NULL,
    "person_id" INTEGER NOT NULL,
    "title" VARCHAR(50) NOT NULL,
    "visibility_status" "visibility_status" NOT NULL DEFAULT 'public',
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "collection_pkey" PRIMARY KEY ("collection_id")
);

-- CreateTable
CREATE TABLE "collection_poem" (
    "collection_id" INTEGER NOT NULL,
    "poem_id" INTEGER NOT NULL,
    "added_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "collection_poem_pkey" PRIMARY KEY ("collection_id","poem_id")
);

-- CreateTable
CREATE TABLE "person" (
    "person_id" SERIAL NOT NULL,
    "username" VARCHAR(35) NOT NULL,
    "email" VARCHAR(45) NOT NULL,
    "password_hash" VARCHAR(255) NOT NULL,
    "registered_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "person_pkey" PRIMARY KEY ("person_id")
);

-- CreateTable
CREATE TABLE "poem" (
    "poem_id" SERIAL NOT NULL,
    "owner_id" INTEGER NOT NULL,
    "title" VARCHAR(50) NOT NULL,
    "content_poem" TEXT NOT NULL,
    "poem_status" "poem_status" NOT NULL DEFAULT 'notes',
    "published_at" TIMESTAMP(6),

    CONSTRAINT "poem_pkey" PRIMARY KEY ("poem_id")
);

-- CreateTable
CREATE TABLE "poem_author" (
    "user_id" INTEGER NOT NULL,
    "poem_id" INTEGER NOT NULL,
    "contribution_type" VARCHAR(50) NOT NULL,

    CONSTRAINT "poem_author_pkey" PRIMARY KEY ("user_id","poem_id")
);

-- CreateTable
CREATE TABLE "review" (
    "user_id" INTEGER NOT NULL,
    "poem_id" INTEGER NOT NULL,
    "rating" INTEGER NOT NULL,
    "comment" TEXT,
    "updated_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "review_pkey" PRIMARY KEY ("user_id","poem_id")
);

-- CreateTable
CREATE TABLE "tag" (
    "tag_id" SERIAL NOT NULL,
    "name" VARCHAR(50) NOT NULL,
    "description" VARCHAR(200),
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "tag_pkey" PRIMARY KEY ("tag_id")
);

-- CreateTable
CREATE TABLE "poem_tag" (
    "poem_id" INTEGER NOT NULL,
    "tag_id" INTEGER NOT NULL,
    "assigned_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "poem_tag_pkey" PRIMARY KEY ("poem_id","tag_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "person_username_key" ON "person"("username");

-- CreateIndex
CREATE UNIQUE INDEX "person_email_key" ON "person"("email");

-- CreateIndex
CREATE UNIQUE INDEX "tag_name_key" ON "tag"("name");

-- AddForeignKey
ALTER TABLE "collection" ADD CONSTRAINT "collection_person_id_fkey" FOREIGN KEY ("person_id") REFERENCES "person"("person_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "collection_poem" ADD CONSTRAINT "collection_poem_collection_id_fkey" FOREIGN KEY ("collection_id") REFERENCES "collection"("collection_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "collection_poem" ADD CONSTRAINT "collection_poem_poem_id_fkey" FOREIGN KEY ("poem_id") REFERENCES "poem"("poem_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "poem" ADD CONSTRAINT "poem_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "person"("person_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "poem_author" ADD CONSTRAINT "poem_author_poem_id_fkey" FOREIGN KEY ("poem_id") REFERENCES "poem"("poem_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "poem_author" ADD CONSTRAINT "poem_author_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "person"("person_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "review" ADD CONSTRAINT "review_poem_id_fkey" FOREIGN KEY ("poem_id") REFERENCES "poem"("poem_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "review" ADD CONSTRAINT "review_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "person"("person_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "poem_tag" ADD CONSTRAINT "poem_tag_poem_id_fkey" FOREIGN KEY ("poem_id") REFERENCES "poem"("poem_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "poem_tag" ADD CONSTRAINT "poem_tag_tag_id_fkey" FOREIGN KEY ("tag_id") REFERENCES "tag"("tag_id") ON DELETE CASCADE ON UPDATE NO ACTION;
