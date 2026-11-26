-- CreateTable
CREATE TABLE "sponsor" (
    "sponsor_id" SERIAL NOT NULL,
    "sponsor_name" VARCHAR(100) NOT NULL,
    "budget" DECIMAL(12,2),
    "tournament_id" INTEGER NOT NULL,

    CONSTRAINT "sponsor_pkey" PRIMARY KEY ("sponsor_id")
);

-- AddForeignKey
ALTER TABLE "sponsor" ADD CONSTRAINT "sponsor_tournament_id_fkey" FOREIGN KEY ("tournament_id") REFERENCES "tournament"("tournament_id") ON DELETE CASCADE ON UPDATE CASCADE;
