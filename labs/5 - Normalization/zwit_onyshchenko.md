# Laba 5

## Moved user ban into a saparate table

```sql
create table users(
  id int generated always as identity primary key,

  username varchar(100) not null,
  email varchar(255) not null unique CHECK (email LIKE '_%@_%._%'),
  password_hash varchar(128) not null CHECK (trim(password_hash) <> ''),

  ban_until timestamp with time zone null default null,
  ban_reason varchar(420) null default null
);
```

### Функціональні залежності (ФЗ)

```id -> username, email, password_hash, ban_until, ban_reason```

```email -> id, username, password_hash, ban_until, ban_reason```

```sql
PK: {id}
CK: {id}, {email}
```

### became

```sql
create table users(
  id int generated always as identity primary key,

  username varchar(100) not null,
  email varchar(255) not null unique CHECK (email LIKE '_%@_%._%'),
  password_hash varchar(128) not null CHECK (trim(password_hash) <> ''),
);

create table user_ban(
  id int generated always as identity primary key,
  user_id int not null references users(id) on delete cascade,
  
  ban_until timestamp with time zone not null,
  ban_reason varchar(420) not null check (trim(ban_reason) <> '')
)
```

### Функціональні залежності

#### users

```id -> username, email, password_hash```

```email -> id, username, password_hash```

```sql
PK: {id}
CK: {id}, {email}
```

#### user_ban

```id -> user_id, ban_until, ban_reason```

```sql
PK: {id}
FK: user_id -> users(id)
```
