# Lab 6 — Prisma Schema Migration Notes

## 0. Initial Schema (`20261123125741_init`)

- **Command:** `npx prisma db pull --config prisma7.config.ts` followed by multi-file schema decomposition (`prisma/models/`, `prisma/enums/`) and `npx prisma migrate dev --name init --config prisma7.config.ts`.
- **Summary:** Captured the normalized Lab 5 PostgreSQL billiard tournament schema (10 tables and 10 enums) as the initial Prisma migration.

---

## 1. Add Sponsor Tables (`20261123142022_add_sponsor_tables`)

- **Command:** `npx prisma migrate dev --name add-sponsor-tables --config prisma7.config.ts`
- **What changed:** Added a `sponsor` table for sponsoring companies and an explicit `tournament_sponsor` junction table modeling the many-to-many relationship between tournaments and sponsors (tracking `contribution_amount` and `sponsored_at`). Updated `tournament` with the `tournament_sponsor` relation field.

### Prisma Schema — Before

`sponsor` and `tournament_sponsor` did not exist. `prisma/models/tournament.prisma`:

```prisma
model tournament {
  // ...
  tournament_registration tournament_registration[]
}
```

### Prisma Schema — After

`prisma/models/sponsor.prisma`:

```prisma
model sponsor {
  sponsor_id         Int                  @id @default(autoincrement())
  sponsor_name       String               @unique(map: "uq_sponsor_name") @db.VarChar(150)
  website_url        String?              @db.VarChar(255)
  contact_email      String?              @db.VarChar(320)
  created_at         DateTime             @default(now()) @db.Timestamptz(6)
  tournament_sponsor tournament_sponsor[]
}
```

`prisma/models/tournament_sponsor.prisma`:

```prisma
model tournament_sponsor {
  tournament_id       Int
  sponsor_id          Int
  contribution_amount Decimal    @default(0.00) @db.Decimal(10, 2)
  sponsored_at        DateTime   @default(now()) @db.Timestamptz(6)
  tournament          tournament @relation(fields: [tournament_id], references: [tournament_id], onDelete: Cascade, onUpdate: NoAction)
  sponsor             sponsor    @relation(fields: [sponsor_id], references: [sponsor_id], onDelete: Cascade, onUpdate: NoAction)

  @@id([tournament_id, sponsor_id])
  @@index([sponsor_id], map: "idx_tournament_sponsor_sponsor_id")
}
```

`prisma/models/tournament.prisma`:

```prisma
model tournament {
  // ...
  tournament_registration tournament_registration[]
  tournament_sponsor      tournament_sponsor[]
}
```

### Generated SQL (`20261123142022_add_sponsor_tables/migration.sql`)

```sql
CREATE TABLE "sponsor" (
    "sponsor_id" SERIAL NOT NULL,
    "sponsor_name" VARCHAR(150) NOT NULL,
    "website_url" VARCHAR(255),
    "contact_email" VARCHAR(320),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sponsor_pkey" PRIMARY KEY ("sponsor_id")
);

CREATE TABLE "tournament_sponsor" (
    "tournament_id" INTEGER NOT NULL,
    "sponsor_id" INTEGER NOT NULL,
    "contribution_amount" DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    "sponsored_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "tournament_sponsor_pkey" PRIMARY KEY ("tournament_id","sponsor_id")
);

CREATE UNIQUE INDEX "uq_sponsor_name" ON "sponsor"("sponsor_name");
CREATE INDEX "idx_tournament_sponsor_sponsor_id" ON "tournament_sponsor"("sponsor_id");

ALTER TABLE "tournament_sponsor" ADD CONSTRAINT "tournament_sponsor_tournament_id_fkey" FOREIGN KEY ("tournament_id") REFERENCES "tournament"("tournament_id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "tournament_sponsor" ADD CONSTRAINT "tournament_sponsor_sponsor_id_fkey" FOREIGN KEY ("sponsor_id") REFERENCES "sponsor"("sponsor_id") ON DELETE CASCADE ON UPDATE NO ACTION;
```
