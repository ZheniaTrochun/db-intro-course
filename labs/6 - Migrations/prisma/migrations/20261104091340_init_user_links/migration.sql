-- CreateTable
CREATE TABLE "user_links" (
    "user_link_id" BIGSERIAL NOT NULL,
    "user_id" UUID NOT NULL,
    "user_link_url" TEXT NOT NULL,

    CONSTRAINT "user_links_pkey" PRIMARY KEY ("user_link_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "user_links_user_id_user_link_url_key" ON "user_links"("user_id", "user_link_url");

-- AddForeignKey
ALTER TABLE "user_links" ADD CONSTRAINT "user_links_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("user_id") ON DELETE CASCADE ON UPDATE CASCADE;
