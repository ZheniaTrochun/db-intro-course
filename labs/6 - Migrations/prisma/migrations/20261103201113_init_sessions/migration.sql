-- CreateTable
CREATE TABLE "sessions" (
    "session_id" BIGSERIAL NOT NULL,
    "user_id" UUID NOT NULL,
    "refresh_token" BYTEA NOT NULL,
    "expire_time" TIMESTAMPTZ(6) NOT NULL DEFAULT (now() + '180 days'::interval),
    "device_type" TEXT,
    "device_name" TEXT,
    "os" TEXT,
    "browser" TEXT,
    "user_location" TEXT,
    "ip_address" INET,
    "user_agent" TEXT,

    CONSTRAINT "sessions_pkey" PRIMARY KEY ("session_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "sessions_refresh_token_key" ON "sessions"("refresh_token");

-- CreateIndex
CREATE INDEX "idx_sessions_user_id" ON "sessions"("user_id");

-- AddForeignKey
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("user_id") ON DELETE CASCADE ON UPDATE CASCADE;
