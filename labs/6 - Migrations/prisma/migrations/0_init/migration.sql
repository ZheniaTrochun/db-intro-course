-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "methods" AS ENUM ('by card', 'online', 'by cash on delivery');

-- CreateEnum
CREATE TYPE "payment_status_name" AS ENUM ('paid', 'not paid');

-- CreateEnum
CREATE TYPE "role_name" AS ENUM ('admin', 'courier', 'operator', 'manager');

-- CreateEnum
CREATE TYPE "status_name" AS ENUM ('confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded');

-- CreateEnum
CREATE TYPE "stock_status_name" AS ENUM ('in stock', 'out of stock', 'coming soon');

-- CreateTable
CREATE TABLE "address" (
    "address_id" SERIAL NOT NULL,
    "street" VARCHAR(32) NOT NULL,
    "location_id" INTEGER NOT NULL,
    "client_id" INTEGER NOT NULL,

    CONSTRAINT "address_pkey" PRIMARY KEY ("address_id")
);

-- CreateTable
CREATE TABLE "carrier" (
    "carrier_id" SERIAL NOT NULL,
    "carrier_name" VARCHAR(64) NOT NULL,

    CONSTRAINT "carrier_pkey" PRIMARY KEY ("carrier_id")
);

-- CreateTable
CREATE TABLE "category" (
    "category_id" SERIAL NOT NULL,
    "category_name" VARCHAR(32) NOT NULL,
    "description" VARCHAR(255) NOT NULL,

    CONSTRAINT "category_pkey" PRIMARY KEY ("category_id")
);

-- CreateTable
CREATE TABLE "client" (
    "client_id" SERIAL NOT NULL,
    "client_name" VARCHAR(32) NOT NULL,
    "last_name" VARCHAR(32) NOT NULL,
    "email" VARCHAR(32) NOT NULL,
    "phone_number" VARCHAR(20),

    CONSTRAINT "client_pkey" PRIMARY KEY ("client_id")
);

-- CreateTable
CREATE TABLE "order_item" (
    "order_item_id" SERIAL NOT NULL,
    "quantity" INTEGER NOT NULL,
    "order_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,

    CONSTRAINT "order_item_pkey" PRIMARY KEY ("order_item_id")
);

-- CreateTable
CREATE TABLE "orders" (
    "order_id" SERIAL NOT NULL,
    "order_date" DATE NOT NULL DEFAULT CURRENT_DATE,
    "order_price" DECIMAL(10,2) NOT NULL,
    "status" "status_name" NOT NULL,
    "discount" INTEGER,
    "address_id" INTEGER NOT NULL,
    "worker_id" INTEGER NOT NULL,

    CONSTRAINT "orders_pkey" PRIMARY KEY ("order_id")
);

-- CreateTable
CREATE TABLE "payment" (
    "payment_id" SERIAL NOT NULL,
    "payment_date" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "payment_method" "methods" NOT NULL,
    "payment_status" "payment_status_name" NOT NULL,
    "price" DECIMAL(10,2) NOT NULL,
    "order_id" INTEGER NOT NULL,

    CONSTRAINT "payment_pkey" PRIMARY KEY ("payment_id")
);

-- CreateTable
CREATE TABLE "postal_location" (
    "location_id" SERIAL NOT NULL,
    "country" VARCHAR(32) NOT NULL,
    "city" VARCHAR(32) NOT NULL,
    "postal_code" VARCHAR(32) NOT NULL,

    CONSTRAINT "postal_location_pkey" PRIMARY KEY ("location_id")
);

-- CreateTable
CREATE TABLE "product" (
    "product_id" SERIAL NOT NULL,
    "product_name" TEXT NOT NULL,
    "price" DECIMAL(10,2) NOT NULL,
    "quantity" INTEGER NOT NULL,
    "description" VARCHAR(255) NOT NULL,
    "stock_status" "stock_status_name" NOT NULL,
    "image_url" TEXT,
    "category_id" INTEGER NOT NULL,

    CONSTRAINT "product_pkey" PRIMARY KEY ("product_id")
);

-- CreateTable
CREATE TABLE "shipment" (
    "shipment_id" SERIAL NOT NULL,
    "carrier_id" INTEGER,
    "tracking_number" TEXT,
    "shipment_status" VARCHAR(50) NOT NULL DEFAULT 'processing',
    "shipping_date" DATE,
    "order_id" INTEGER NOT NULL,
    "worker_id" INTEGER,

    CONSTRAINT "shipment_pkey" PRIMARY KEY ("shipment_id")
);

-- CreateTable
CREATE TABLE "worker" (
    "worker_id" SERIAL NOT NULL,
    "worker_role" "role_name" NOT NULL,
    "first_name" VARCHAR(32) NOT NULL,
    "last_name" VARCHAR(32) NOT NULL,
    "phone_number" VARCHAR(13),

    CONSTRAINT "worker_pkey" PRIMARY KEY ("worker_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "carrier_carrier_name_key" ON "carrier"("carrier_name");

-- CreateIndex
CREATE UNIQUE INDEX "unique_order_item" ON "order_item"("order_id", "product_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_postal_location" ON "postal_location"("country", "postal_code");

-- CreateIndex
CREATE UNIQUE INDEX "shipment_tracking_number_key" ON "shipment"("tracking_number");

-- CreateIndex
CREATE UNIQUE INDEX "worker_phone_number_key" ON "worker"("phone_number");

-- AddForeignKey
ALTER TABLE "address" ADD CONSTRAINT "address_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "client"("client_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "address" ADD CONSTRAINT "address_location_id_fkey" FOREIGN KEY ("location_id") REFERENCES "postal_location"("location_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "order_item" ADD CONSTRAINT "order_item_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "orders"("order_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "order_item" ADD CONSTRAINT "order_item_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("product_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "orders" ADD CONSTRAINT "orders_address_id_fkey" FOREIGN KEY ("address_id") REFERENCES "address"("address_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "orders" ADD CONSTRAINT "orders_worker_id_fkey" FOREIGN KEY ("worker_id") REFERENCES "worker"("worker_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "payment" ADD CONSTRAINT "payment_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "orders"("order_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "product" ADD CONSTRAINT "product_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "category"("category_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "shipment" ADD CONSTRAINT "shipment_carrier_id_fkey" FOREIGN KEY ("carrier_id") REFERENCES "carrier"("carrier_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "shipment" ADD CONSTRAINT "shipment_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "orders"("order_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "shipment" ADD CONSTRAINT "shipment_worker_id_fkey" FOREIGN KEY ("worker_id") REFERENCES "worker"("worker_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
