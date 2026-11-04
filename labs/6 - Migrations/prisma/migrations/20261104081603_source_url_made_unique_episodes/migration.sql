/*
  Warnings:

  - A unique constraint covering the columns `[source_url]` on the table `episodes` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX "episodes_source_url_key" ON "episodes"("source_url");
