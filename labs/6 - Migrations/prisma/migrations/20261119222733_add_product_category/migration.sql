-- AlterTable
ALTER TABLE "product" ADD COLUMN     "category_id" INTEGER;

-- CreateTable
CREATE TABLE "product_category" (
    "category_id" SERIAL NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "product_category_pkey" PRIMARY KEY ("category_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "product_category_name_key" ON "product_category"("name");

-- CreateIndex
CREATE INDEX "idx_product_category_name" ON "product_category"("name");

-- CreateIndex
CREATE INDEX "idx_product_category" ON "product"("category_id");

-- AddForeignKey
ALTER TABLE "product" ADD CONSTRAINT "product_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "product_category"("category_id") ON DELETE SET NULL ON UPDATE NO ACTION;
