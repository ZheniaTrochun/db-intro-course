## Таблиці

CHURCH (
    id uuid default gen_random_uuid() primary key,
    name varchar(128) not null,
    location varchar(128) not null,
    unique (name, location)
);

SONG_LANGUAGE (
    id uuid default gen_random_uuid() primary key,
    language varchar(128) not null unique
);

SONG (
    id uuid default gen_random_uuid() primary key,
    name varchar(128) not null,
    author varchar(256),
    has_author bool not null,
    translator varchar(256),
    is_translated bool not null,
    lyrics varchar(1024) not null,
    is_ai bool not null,
    language_id uuid not null references SONG_LANGUAGE(id),
);

create table NOTE (
    id uuid default gen_random_uuid() primary key,
    song_id uuid not null references SONG(id),
    note varchar(2048) not null
);

create table WORSHIP_TYPES (
    id uuid default gen_random_uuid() primary key,
    type varchar(128) not null unique
);

create table WORSHIP (
    id uuid default gen_random_uuid() primary key,
    church_id uuid not null references CHURCH(id),
    date timestamp not null,
    type_id uuid not null references WORSHIP_TYPES(id),
    views int check (views >= 0),
    subscribers int check (subscribers >= 0),
    link varchar(256)
);

create table SINGING (
    id uuid default gen_random_uuid() primary key,
    worship_id uuid not null references WORSHIP(id),
    song_id uuid not null references SONG(id),
    performer varchar(256),
    note varchar(512)
);

## Обмеження
1. У таблиці CHURCH комбінація (name, location) має бути унікальною. В різних містах можуть бути церкви з однаковою назвою, але в одному місті назва має бути унікальною.

2. У таблиці SONG_LANGUAGE language має бути унікальною.

3. У таблиці WORSHIP_TYPES type має бути унікальним.

4. У таблиці WORSHIP views та subscribers повинні бути => 0.
