-- CreateTable
CREATE TABLE "guild" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(128) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "member_count" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "guild_pkey" PRIMARY KEY ("id")
);