create table CHURCH (
    id uuid default uuid_generate_v7() primary key,
    name varchar(128) not null,
    location varchar(128) not null
);

create table SONG_LANGUAGE (
    id uuid default uuid_generate_v7() primary key,
    language varchar(128) not null
);

create table SONG (
    id uuid default uuid_generate_v7() primary key,
    name varchar(128) not null,
    author varchar(256),
    has_author bool not null,
    translator varchar(256),
    is_translated bool not null,
    lyrics varchar(1024) not null,
    is_ai bool not null,
    language_id uuid not null references SONG_LANGUAGE(id)
);

create table NOTE (
    id uuid default uuid_generate_v7() primary key,
    song_id uuid not null references SONG(id),
    note varchar(2048) not null
);

create table WORSHIP_TYPES (
    id uuid default uuid_generate_v7() primary key,
    type varchar(128) not null
);

create table WORSHIP (
    id uuid default uuid_generate_v7() primary key,
    church_id uuid not null references CHURCH(id),
    date timestamp not null,
    type_id uuid not null references WORSHIP_TYPES(id),
    views int,
    subscribers int,
    link varchar(256)
);

create table SINGING (
    id uuid default uuid_generate_v7() primary key,
    worship_id uuid not null references WORSHIP(id),
    song_id uuid not null references SONG(id),
    performer varchar(256),
    note varchar(512)
);