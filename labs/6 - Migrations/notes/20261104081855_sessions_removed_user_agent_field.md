# 20261104081855_sessions_removed_user_agent_field

Змінено таблицю sessions
шляхом видалення рядка user_agent.

**Було:**
```prisma
model Session {
  sessionId BigInt @id @default(autoincrement()) @map("session_id")
  userId String @map("user_id") @db.Uuid
  refreshToken Bytes @unique @map("refresh_token")
  expireTime DateTime @default(dbgenerated("(now() + '180 days'::interval)")) @map("expire_time") @db.Timestamptz(6)
  deviceType String? @map("device_type")
  deviceName String? @map("device_name")
  os String?
  browser String?
  userLocation String? @map("user_location")
  ipAddress String? @map("ip_address") @db.Inet
  userAgent String? @map("user_agent")

  user User @relation(fields: [userId], references: [userId], onDelete: Cascade)

  @@index([userId], map: "idx_sessions_user_id")
  @@index([expireTime(sort: Asc)], map: "idx_sessions_expire_time")
  @@map("sessions")
}
```

**Стало:**
```prisma
model Session {
  sessionId BigInt @id @default(autoincrement()) @map("session_id")
  userId String @map("user_id") @db.Uuid
  refreshToken Bytes @unique @map("refresh_token")
  expireTime DateTime @default(dbgenerated("(now() + '180 days'::interval)")) @map("expire_time") @db.Timestamptz(6)
  deviceType String? @map("device_type")
  deviceName String? @map("device_name")
  os String?
  browser String?
  userLocation String? @map("user_location")
  ipAddress String? @map("ip_address") @db.Inet

  user User @relation(fields: [userId], references: [userId], onDelete: Cascade)

  @@index([userId], map: "idx_sessions_user_id")
  @@index([expireTime(sort: Asc)], map: "idx_sessions_expire_time")
  @@map("sessions")
}
```


## Prisma Studio

![Скріншот з Prisma Studio](https://ucarecdn.com/6b415495-991f-4dd7-ac16-527f34c296b9/20261104105038_hyprshot.png)
