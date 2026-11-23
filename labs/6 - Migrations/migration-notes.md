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

---

## 2. Add `is_active` Flag to `club` (`20261123142110_add_club_is_active`)

- **Command:** `npx prisma migrate dev --name add-club-is-active --config prisma7.config.ts`
- **What changed:** Added a non-nullable boolean column `is_active` (defaulting to `true`) to `club` so clubs can be deactivated without deleting historical tournament records.

### Prisma Schema — Before (`prisma/models/club.prisma`)

```prisma
model club {
  club_id        Int              @id @default(autoincrement())
  club_name      String           @db.VarChar(100)
  city           String           @db.VarChar(100)
  address        String           @db.VarChar(200)
  created_at     DateTime         @default(now()) @db.Timestamptz(6)
  billiard_table billiard_table[]
  tournament     tournament[]
}
```

### Prisma Schema — After (`prisma/models/club.prisma`)

```prisma
model club {
  club_id        Int              @id @default(autoincrement())
  club_name      String           @db.VarChar(100)
  city           String           @db.VarChar(100)
  address        String           @db.VarChar(200)
  is_active      Boolean          @default(true)
  created_at     DateTime         @default(now()) @db.Timestamptz(6)
  billiard_table billiard_table[]
  tournament     tournament[]
}
```

### Generated SQL (`20261123142110_add_club_is_active/migration.sql`)

```sql
ALTER TABLE "club" ADD COLUMN     "is_active" BOOLEAN NOT NULL DEFAULT true;
```

---

## 3. Drop `time_limit_minutes` from `match` (`20261123142151_drop_match_time_limit`)

- **Command:** `npx prisma migrate dev --name drop-match-time-limit --config prisma7.config.ts`
- **What changed:** Removed the nullable `time_limit_minutes` column from `match` since match progression is governed by `race_to_frames` / `race_to_points`.

### Prisma Schema — Before (`prisma/models/match.prisma`)

```prisma
model match {
  match_id           Int                 @id @default(autoincrement())
  tournament_id      Int
  table_id           Int?
  stage              match_stage
  race_to_frames     Int?                @db.SmallInt
  race_to_points     Int?                @db.SmallInt
  time_limit_minutes Int?                @db.SmallInt
  match_status       match_status        @default(SCHEDULED)
  // ...
}
```

### Prisma Schema — After (`prisma/models/match.prisma`)

```prisma
model match {
  match_id       Int                 @id @default(autoincrement())
  tournament_id  Int
  table_id       Int?
  stage          match_stage
  race_to_frames Int?                @db.SmallInt
  race_to_points Int?                @db.SmallInt
  match_status   match_status        @default(SCHEDULED)
  // ...
}
```

### Generated SQL (`20261123142151_drop_match_time_limit/migration.sql`)

```sql
ALTER TABLE "match" DROP COLUMN "time_limit_minutes";
```

---

## 4. Verification with Prisma Client (`src/player-pairs.ts`)

- **Command:** `npx tsx src/player-pairs.ts`
- **Summary:** Verified the migrated and seeded database using the shared Prisma Client (`src/prisma.ts`) by querying all unique unordered player pairs (`p1.player_id < p2.player_id`) for a tournament bracket.

### Output

```text
┌─────────┬─────────────┬────────────────────────┬─────────────┬────────────────────────┐
│ (index) │ player_1_id │ player_1_name          │ player_2_id │ player_2_name          │
├─────────┼─────────────┼────────────────────────┼─────────────┼────────────────────────┤
│ 0       │ 1           │ 'Дмитро Білозеров'     │ 2           │ 'Олександр Паламар'    │
│ 1       │ 1           │ 'Дмитро Білозеров'     │ 3           │ 'Сергій Крижановський' │
│ 2       │ 1           │ 'Дмитро Білозеров'     │ 4           │ 'Євген Сталєв'         │
│ 3       │ 2           │ 'Олександр Паламар'    │ 3           │ 'Сергій Крижановський' │
│ 4       │ 2           │ 'Олександр Паламар'    │ 4           │ 'Євген Сталєв'         │
│ 5       │ 3           │ 'Сергій Крижановський' │ 4           │ 'Євген Сталєв'         │
└─────────┴─────────────┴────────────────────────┴─────────────┴────────────────────────┘
```

### Listing Sponsors & Sponsored Tournaments (`src/list-sponsors.ts`)

- **Command:** `npx tsx src/list-sponsors.ts`
- **Summary:** Queries the newly added `sponsor` and `tournament_sponsor` tables together with `tournament` and the altered `club.is_active` column.

```text
┌─────────┬────────────┬─────────────────┬───────────────────────────────┬──────────────────────────────┬──────────────────────────────┬─────────────┬──────────────┐
│ (index) │ sponsor_id │ sponsor_name    │ contact_email                 │ tournament                   │ club                         │ club_active │ contribution │
├─────────┼────────────┼─────────────────┼───────────────────────────────┼──────────────────────────────┼──────────────────────────────┼─────────────┼──────────────┤
│ 0       │ 1          │ 'Predator Cues' │ 'events@predatorcues.com'     │ 'Кубок Чемпіонів — Піраміда' │ 'Більярдний клуб "Піраміда"' │ true        │ 15000        │
│ 1       │ 1          │ 'Predator Cues' │ 'events@predatorcues.com'     │ 'Командна Битва Титанів'     │ 'Більярдний клуб "Піраміда"' │ true        │ 20000        │
│ 2       │ 2          │ 'Aramith'       │ 'partners@aramith.com'        │ 'Кубок Чемпіонів — Піраміда' │ 'Більярдний клуб "Піраміда"' │ true        │ 10000        │
│ 3       │ 2          │ 'Aramith'       │ 'partners@aramith.com'        │ 'Одеський Турнір — Пул 9-ка' │ 'Brooklyn Billiards'         │ true        │ 5000         │
│ 4       │ 3          │ 'Simonis Cloth' │ 'sponsorship@iwansimonis.com' │ 'Командна Битва Титанів'     │ 'Більярдний клуб "Піраміда"' │ true        │ 15000        │
└─────────┴────────────┴─────────────────┴───────────────────────────────┴──────────────────────────────┴──────────────────────────────┴─────────────┴──────────────┘
```
