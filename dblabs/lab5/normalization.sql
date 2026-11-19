begin;

create table genre(
    genre_id integer generated always as identity primary key,
    genre_name varchar(64) not null unique,
    short_description varchar(2056),
    additional_description jsonb
);

create table issue_genre(
    issue_id integer not null references issue(issue_id) on delete cascade,
    genre_id integer not null references genre(genre_id) on delete cascade,
    primary key(issue_id, genre_id)
);

insert into genre(genre_name)
select distinct
    string_to_table(genre, ' ')
from issue
where genre is not null;

with issue_genres_names as(
    select
        issue_id,
        string_to_table(genre, ' ') as genre_name
    from issue
    where genre is not null
)
insert into issue_genre (issue_id, genre_id)
select distinct
    ign.issue_id,
    g.genre_id
from issue_genres_names ign
join genre g on ign.genre_name = g.genre_name;

alter table issue drop column genre;

commit;

begin;

create table language(
    language_id integer generated always as identity primary key,
    language_name varchar(64) not null unique
);

create table issue_language(
    issue_id integer not null references issue(issue_id) on delete cascade,
    language_id integer not null references language(language_id) on delete cascade,
    primary key(issue_id, language_id)
);

insert into language(language_name)
select distinct
    trim(regexp_split_to_table(language, '[, ]+')) as language_name
from issue
where language is not null;

with issue_languages_names as(
    select
        issue_id,
        trim(regexp_split_to_table(language, '[, ]+')) as language_name
    from issue
    where language is not null
)
insert into issue_language (issue_id, language_id)
select distinct
    ign.issue_id,
    l.language_id
from issue_languages_names ign
join language l on ign.language_name = l.language_name;

alter table issue drop column language;

commit;

begin;

create table adm_fine(
    adm_fine_id integer generated always as identity primary key,
    reader_id integer not null references reader(reader_id),
    amount numeric(10, 2) not null check(amount > 0),
    start_date date not null default current_date,
    closed_date date check(closed_date is null or closed_date >= start_date),
    fine_type fine_type not null,
    fine_status fine_status not null default 'unpaid',
    description varchar(256) not null check(length(trim(both ' ' from description)) > 0),
    check((closed_date is null) = (fine_status = 'unpaid'))
);

create table loan_fine(
    loan_fine_id integer generated always as identity primary key,
    loan_id integer not null references loan(loan_id),
    amount numeric(10, 2) not null check(amount > 0),
    start_date date not null default current_date,
    closed_date date check(closed_date is null or closed_date >= start_date),
    fine_type fine_type not null,
    fine_status fine_status not null default 'unpaid',
    description varchar(256) not null check(length(trim(both ' ' from description)) > 0),
    check((closed_date is null) = (fine_status = 'unpaid'))
);

insert into adm_fine(reader_id, amount, start_date, closed_date, fine_type, fine_status, description)
select reader_id, amount, start_date, closed_date, fine_type, fine_status, description
from fine
where loan_id is null;

insert into loan_fine(loan_id, amount, start_date, closed_date, fine_type, fine_status, description)
select loan_id, amount, start_date, closed_date, fine_type, fine_status, description
from fine
where loan_id is not null;

drop table fine;

alter table loan drop constraint loan_loan_id_reader_id_key;

commit;