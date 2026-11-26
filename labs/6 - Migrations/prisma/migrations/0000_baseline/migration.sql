-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "movement_kind" AS ENUM ('transfer', 'write_off');

-- CreateEnum
CREATE TYPE "order_status" AS ENUM ('draft', 'received', 'cancelled');

-- CreateEnum
CREATE TYPE "unit_type" AS ENUM ('piece', 'kg', 'liter', 'box', 'pallet');

-- CreateTable
CREATE TABLE "inventory_movement" (
    "movement_id" SERIAL NOT NULL,
    "movement_type" "movement_kind" NOT NULL,
    "product_id" INTEGER NOT NULL,
    "from_location_id" INTEGER NOT NULL,
    "to_location_id" INTEGER,
    "quantity" INTEGER NOT NULL,
    "reason" VARCHAR(255),
    "movement_date" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_by" VARCHAR(100) NOT NULL,

    CONSTRAINT "inventory_movement_pkey" PRIMARY KEY ("movement_id")
);

-- CreateTable
CREATE TABLE "inventory_stock" (
    "product_id" INTEGER NOT NULL,
    "location_id" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL,

    CONSTRAINT "inventory_stock_pkey" PRIMARY KEY ("product_id","location_id")
);

-- CreateTable
CREATE TABLE "product" (
    "product_id" SERIAL NOT NULL,
    "sku_code" VARCHAR(50) NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "unit" "unit_type" NOT NULL DEFAULT 'piece',
    "min_stock_level" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "product_pkey" PRIMARY KEY ("product_id")
);

-- CreateTable
CREATE TABLE "supplier" (
    "supplier_id" SERIAL NOT NULL,
    "company_name" VARCHAR(100) NOT NULL,
    "contact_person" VARCHAR(100) NOT NULL,
    "phone" VARCHAR(20) NOT NULL,
    "email" VARCHAR(100) NOT NULL,
    "address" VARCHAR(255) NOT NULL,
    "version" INTEGER NOT NULL DEFAULT 1,
    "deleted_at" TIMESTAMP(6),

    CONSTRAINT "supplier_pkey" PRIMARY KEY ("supplier_id")
);

-- CreateTable
CREATE TABLE "supply_item" (
    "order_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "location_id" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL,
    "unit_price" DECIMAL(10,2) NOT NULL,
    "expiry_date" DATE,

    CONSTRAINT "supply_item_pkey" PRIMARY KEY ("order_id","product_id")
);

-- CreateTable
CREATE TABLE "supply_order" (
    "order_id" SERIAL NOT NULL,
    "order_number" VARCHAR(50) NOT NULL,
    "supplier_id" INTEGER NOT NULL,
    "supply_date" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "total_cost" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "status" "order_status" NOT NULL DEFAULT 'draft',
    "batch_number" VARCHAR(50) NOT NULL,

    CONSTRAINT "supply_order_pkey" PRIMARY KEY ("order_id")
);

-- CreateTable
CREATE TABLE "warehouse_location" (
    "location_id" SERIAL NOT NULL,
    "location_code" VARCHAR(50) NOT NULL,
    "zone" VARCHAR(50) NOT NULL,
    "shelf_number" VARCHAR(50) NOT NULL,
    "max_capacity" INTEGER NOT NULL,

    CONSTRAINT "warehouse_location_pkey" PRIMARY KEY ("location_id")
);

-- CreateIndex
CREATE INDEX "idx_inventory_movement_from" ON "inventory_movement"("from_location_id");

-- CreateIndex
CREATE INDEX "idx_inventory_movement_product_date" ON "inventory_movement"("product_id", "movement_date");

-- CreateIndex
CREATE INDEX "idx_inventory_stock_location" ON "inventory_stock"("location_id");

-- CreateIndex
CREATE UNIQUE INDEX "product_sku_code_key" ON "product"("sku_code");

-- CreateIndex
CREATE UNIQUE INDEX "supplier_email_key" ON "supplier"("email");

-- CreateIndex
CREATE INDEX "idx_supply_item_location" ON "supply_item"("location_id");

-- CreateIndex
CREATE INDEX "idx_supply_item_product" ON "supply_item"("product_id");

-- CreateIndex
CREATE UNIQUE INDEX "supply_order_order_number_key" ON "supply_order"("order_number");

-- CreateIndex
CREATE INDEX "idx_supply_order_supplier" ON "supply_order"("supplier_id");

-- CreateIndex
CREATE UNIQUE INDEX "warehouse_location_location_code_key" ON "warehouse_location"("location_code");

-- CreateIndex
CREATE UNIQUE INDEX "uk_zone_shelf" ON "warehouse_location"("zone", "shelf_number");

-- AddForeignKey
ALTER TABLE "inventory_movement" ADD CONSTRAINT "inventory_movement_from_location_id_fkey" FOREIGN KEY ("from_location_id") REFERENCES "warehouse_location"("location_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "inventory_movement" ADD CONSTRAINT "inventory_movement_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("product_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "inventory_movement" ADD CONSTRAINT "inventory_movement_to_location_id_fkey" FOREIGN KEY ("to_location_id") REFERENCES "warehouse_location"("location_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "inventory_stock" ADD CONSTRAINT "inventory_stock_location_id_fkey" FOREIGN KEY ("location_id") REFERENCES "warehouse_location"("location_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "inventory_stock" ADD CONSTRAINT "inventory_stock_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("product_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "supply_item" ADD CONSTRAINT "supply_item_location_id_fkey" FOREIGN KEY ("location_id") REFERENCES "warehouse_location"("location_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "supply_item" ADD CONSTRAINT "supply_item_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "supply_order"("order_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "supply_item" ADD CONSTRAINT "supply_item_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("product_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "supply_order" ADD CONSTRAINT "supply_order_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "supplier"("supplier_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
