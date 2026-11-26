-- CreateTable
CREATE TABLE "world_event" (
    "id" SERIAL NOT NULL,
    "zone_id" INTEGER NOT NULL,
    "title" VARCHAR(128) NOT NULL,
    "starts_at" TIMESTAMP(3) NOT NULL,
    "ends_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "world_event_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "world_event" ADD CONSTRAINT "world_event_zone_id_fkey" FOREIGN KEY ("zone_id") REFERENCES "zone"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
