insert into song_language (language)
values
    ('Lang1'),
    ('Lang2'),
    ('Lang3'),
    ('Lang4'),
    ('Lang5');

insert into church (name, location)
values
    ('Church1', 'Kyiv'),
    ('Church2', 'Lviv'),
    ('Church3', 'Vinnytsia'),
    ('Church4', 'Uzhhorod'),
    ('Church5', 'Dnipro');

insert into worship_types (type)
values
    ('Type1'),
    ('Type2'),
    ('Type3'),
    ('Type4'),
    ('Type5');

insert into song (name, author, has_author, translator, is_translated, lyrics, is_ai, language_id)
values
    ('Song1', 'Author1', true, null, false, 'Lyrics of song 1', false,
        (select id from song_language where language = 'Lang1')),
    ('Song2', 'Author2', true, null, false, 'Lyrics of song 2', false,
        (select id from song_language where language = 'Lang2')),
    ('Song3', 'Author3', true, 'Translator3', true, 'Lyrics of song 3', false,
        (select id from song_language where language = 'Lang3')),
    ('Song4', null, false, null, false, 'Lyrics of song 4', true,
        (select id from song_language where language = 'Lang4')),
    ('Song5', 'Author5', true, 'Translator5', true, 'Lyrics of song 5', false,
        (select id from song_language where language = 'Lang5'));

insert into worship (church_id, date, type_id, views, subscribers, link)
values
    ((select id from church where name = 'Church1'), timestamp '2023-02-05 10:00:00',
        (select id from worship_types where type = 'Type1'), 512, 210, 'https://youtube.com/watch?v=lab3-1'),
    ((select id from church where name = 'Church2'), timestamp '2023-02-12 10:00:00',
        (select id from worship_types where type = 'Type2'), 620, 250, 'https://youtube.com/watch?v=lab3-2'),
    ((select id from church where name = 'Church3'), timestamp '2023-02-19 10:00:00',
        (select id from worship_types where type = 'Type3'), 730, 310, 'https://youtube.com/watch?v=lab3-3'),
    ((select id from church where name = 'Church4'), timestamp '2023-02-26 10:00:00',
        (select id from worship_types where type = 'Type4'), 840, 370, 'https://youtube.com/watch?v=lab3-4'),
    ((select id from church where name = 'Church5'), timestamp '2023-03-05 10:00:00',
        (select id from worship_types where type = 'Type5'), 950, 420, 'https://youtube.com/watch?v=lab3-5');


insert into note (song_id, note)
values
    ((select id from song where name = 'Song1'), 'Note1'),
    ((select id from song where name = 'Song2'), 'Note2'),
    ((select id from song where name = 'Song3'), 'Note3'),
    ((select id from song where name = 'Song4'), 'Note4'),
    ((select id from song where name = 'Song5'), 'Note5');

insert into singing (worship_id, song_id, performer, note)
values
    ((select id from worship where link = 'https://youtube.com/watch?v=lab3-1'),
        (select id from song where name = 'Song1'), 'Performer1', 'Note1'),
    ((select id from worship where link = 'https://youtube.com/watch?v=lab3-2'),
        (select id from song where name = 'Song2'), 'Performer2', 'Note2'),
    ((select id from worship where link = 'https://youtube.com/watch?v=lab3-3'),
        (select id from song where name = 'Song3'), 'Performer3', 'Note3'),
    ((select id from worship where link = 'https://youtube.com/watch?v=lab3-4'),
        (select id from song where name = 'Song4'), 'Performer4', 'Note4'),
    ((select id from worship where link = 'https://youtube.com/watch?v=lab3-5'),
        (select id from song where name = 'Song5'), 'Performer5', 'Note5');



