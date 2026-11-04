# 20261104081749_sessions_expire_time_new_index

Змінено таблицю sessions
шляхом додавання індексу на рядок expire_time.

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
  userAgent String? @map("user_agent")

  user User @relation(fields: [userId], references: [userId], onDelete: Cascade)

  @@index([userId], map: "idx_sessions_user_id")
  @@index([expireTime(sort: Asc)], map: "idx_sessions_expire_time")
  @@map("sessions")
}
```


## Prisma Studio

![Скріншот з Prisma Studio](https://ucarecdn.com/b5e0d7d5-697a-4a87-a900-466d12437905/20261104105250_hyprshot.png)
