-- CreateTable
CREATE TABLE "sponsor" (
    "sponsor_id" SERIAL NOT NULL,
    "sponsor_name" VARCHAR(150) NOT NULL,
    "website_url" VARCHAR(255),
    "contact_email" VARCHAR(320),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sponsor_pkey" PRIMARY KEY ("sponsor_id")
);

-- CreateTable
CREATE TABLE "tournament_sponsor" (
    "tournament_id" INTEGER NOT NULL,
    "sponsor_id" INTEGER NOT NULL,
    "contribution_amount" DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    "sponsored_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "tournament_sponsor_pkey" PRIMARY KEY ("tournament_id","sponsor_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "uq_sponsor_name" ON "sponsor"("sponsor_name");

-- CreateIndex
CREATE INDEX "idx_tournament_sponsor_sponsor_id" ON "tournament_sponsor"("sponsor_id");

-- AddForeignKey
ALTER TABLE "tournament_sponsor" ADD CONSTRAINT "tournament_sponsor_tournament_id_fkey" FOREIGN KEY ("tournament_id") REFERENCES "tournament"("tournament_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "tournament_sponsor" ADD CONSTRAINT "tournament_sponsor_sponsor_id_fkey" FOREIGN KEY ("sponsor_id") REFERENCES "sponsor"("sponsor_id") ON DELETE CASCADE ON UPDATE NO ACTION;
