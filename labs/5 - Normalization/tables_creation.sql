create type author_type as enum ('KNOWN', 'UNKNOWN', 'FOLK');
create type translation_type as enum ('ORIGINAL', 'KNOWN_TRANSLATOR', 'UNKNOWN_TRANSLATOR');

create table CHURCH (
    id uuid default gen_random_uuid() primary key,
    name varchar(128) not null,
    location varchar(128) not null,
    unique (name, location)
);

create table SONG_LANGUAGE (
    id uuid default gen_random_uuid() primary key,
    language varchar(128) not null unique
);

create table SONG (
    id uuid default gen_random_uuid() primary key,
    name varchar(128) not null,
    author varchar(256),
    author_type author_type not null default 'KNOWN',
    translator varchar(256),
    translation_type translation_type not null default 'ORIGINAL',
    lyrics varchar(1024) not null,
    is_ai bool not null,
    language_id uuid not null references SONG_LANGUAGE(id),
    CHECK (
        (author_type = 'KNOWN' AND author IS NOT NULL) OR 
        (author_type != 'KNOWN' AND author IS NULL)
    ),
    CHECK (
        (translation_type = 'KNOWN_TRANSLATOR' AND translator IS NOT NULL) OR 
        (translation_type != 'KNOWN_TRANSLATOR' AND translator IS NULL)
    )
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