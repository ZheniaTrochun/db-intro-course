/*
INSERT INTO CHURCH (id, name, location)
VALUES ('c83748a9-682c-4037-9005-56810bd7ac73', 'Алмаз', 'Вінниця')
RETURNING id;
*/

/*
INSERT INTO WORSHIP_TYPES(id, type)
VALUES ('83d37825-bc62-4698-9d23-ea30590c969e', 'Недільне')
RETURNING id;
*/

/*
INSERT INTO WORSHIP(id,church_id,date,type_id,views,subscribers,link)
VALUES ('6c75637f-1f5c-4085-8992-809a3baafb99','c83748a9-682c-4037-9005-56810bd7ac73', '2023-01-01 00:00:00', '83d37825-bc62-4698-9d23-ea30590c969e', 1270, 256, '')
RETURNING church_id,date,type_id,views,subscribers,link;

INSERT INTO WORSHIP(id,church_id,date,type_id,views,subscribers,link)
VALUES ('0fb3a63d-5db6-41c1-8e21-494c4d8df519','c83748a9-682c-4037-9005-56810bd7ac73', '2023-01-08 00:00:00', '83d37825-bc62-4698-9d23-ea30590c969e', 1270, 387, '')
RETURNING church_id,date,type_id,views,subscribers,link;

INSERT INTO WORSHIP(id,church_id,date,type_id,views,subscribers,link)
VALUES ('2b7a8a69-6976-466a-999f-2660e6203dd0','c83748a9-682c-4037-9005-56810bd7ac73', '2023-01-15 00:00:00', '83d37825-bc62-4698-9d23-ea30590c969e', 1270, 256, '')
RETURNING church_id,date,type_id,views,subscribers,link;

INSERT INTO WORSHIP(id,church_id,date,type_id,views,subscribers,link)
VALUES ('a53a4083-885e-4221-994e-09ec70b42277','c83748a9-682c-4037-9005-56810bd7ac73', '2023-01-22 00:00:00', '83d37825-bc62-4698-9d23-ea30590c969e', 1270, 256, '')
RETURNING church_id,date,type_id,views,subscribers,link;
*/


--SELECT * FROM worship;

/*
UPDATE worship
SET views=327, subscribers=1270
WHERE id = 'a53a4083-885e-4221-994e-09ec70b42277';
*/

-- MAKING SONGS

/*
INSERT INTO SONG_LANGUAGE(id,language)
VALUES ('856c9ffc-6057-4440-a02a-c2e3b75e290c','українська')
RETURNING id,language;
*/

/* бекап для створення
INSERT INTO SONG(name,author,has_author,translator,is_translated,lyrics,is_ai,language_id)
VALUES('','','TRUE','','FALSE','','FALSE','856c9ffc-6057-4440-a02a-c2e3b75e290c')
RETURNING id,name,author,has_author,translator,is_translated,lyrics,is_ai,language_id;
*/

/*
INSERT INTO SONG(id,name,author,has_author,translator,is_translated,lyrics,is_ai,language_id)
VALUES ('5908f8a3-753f-4650-89fd-7ecbd19aaca1','Буду славить я Бога Израиля','','TRUE','Тітка Наня','TRUE','Буду Славити Бога Ізраїля','FALSE','856c9ffc-6057-4440-a02a-c2e3b75e290c')
RETURNING id,name,author,has_author,translator,is_translated,lyrics,is_ai,language_id;

INSERT INTO SONG(id,name,author,has_author,translator,is_translated,lyrics,is_ai,language_id)
VALUES('288a07f0-f7d9-4c89-8b41-d9a3df9c2cae','Разом (Ти і я)','LimeMusic (українська команда)','TRUE','','FALSE','Разом (Ти і я)','FALSE','856c9ffc-6057-4440-a02a-c2e3b75e290c')
RETURNING id,name,author,has_author,translator,is_translated,lyrics,is_ai,language_id;

INSERT INTO SONG(id,name,author,has_author,translator,is_translated,lyrics,is_ai,language_id)
VALUES('ab0e69d2-0a6c-48a0-a279-aa7283347885','Разом славимо Тебе','Оксана Бунтовська','TRUE','','FALSE','Разом славимо Тебе','FALSE','856c9ffc-6057-4440-a02a-c2e3b75e290c')
RETURNING id,name,author,has_author,translator,is_translated,lyrics,is_ai,language_id;

INSERT INTO SONG(id,name,author,has_author,translator,is_translated,lyrics,is_ai,language_id)
VALUES('af52f4fb-6438-43d1-9434-be5ac1a423a4','Ісус є неземна любов','Евеліна Скороходько','TRUE','','FALSE','Ісус є неземна любов','FALSE','856c9ffc-6057-4440-a02a-c2e3b75e290c')
RETURNING id,name,author,has_author,translator,is_translated,lyrics,is_ai,language_id;
*/

--SELECT * FROM SONG

-- combining worship and songs by SINGING

/*
INSERT INTO SINGING(worship_id,song_id,performer,note)
VALUES('a53a4083-885e-4221-994e-09ec70b42277','5908f8a3-753f-4650-89fd-7ecbd19aaca1','Невідомий Співак','');

INSERT INTO SINGING(worship_id,song_id,performer,note)
VALUES('a53a4083-885e-4221-994e-09ec70b42277','288a07f0-f7d9-4c89-8b41-d9a3df9c2cae','Невідомий Співак','');

INSERT INTO SINGING(worship_id,song_id,performer,note)
VALUES('a53a4083-885e-4221-994e-09ec70b42277','af52f4fb-6438-43d1-9434-be5ac1a423a4','Kate','');

INSERT INTO SINGING(worship_id,song_id,performer,note)
VALUES('a53a4083-885e-4221-994e-09ec70b42277','5908f8a3-753f-4650-89fd-7ecbd19aaca1','Kate + Невідомий співак','');

-- ---------

INSERT INTO SINGING(worship_id,song_id,performer,note)
VALUES('6c75637f-1f5c-4085-8992-809a3baafb99','5908f8a3-753f-4650-89fd-7ecbd19aaca1','Markolos','');

INSERT INTO SINGING(worship_id,song_id,performer,note)
VALUES('6c75637f-1f5c-4085-8992-809a3baafb99','288a07f0-f7d9-4c89-8b41-d9a3df9c2cae','Markolos','');

INSERT INTO SINGING(worship_id,song_id,performer,note)
VALUES('6c75637f-1f5c-4085-8992-809a3baafb99','af52f4fb-6438-43d1-9434-be5ac1a423a4','Анастасія Рясна','');

INSERT INTO SINGING(worship_id,song_id,performer,note)
VALUES('6c75637f-1f5c-4085-8992-809a3baafb99','5908f8a3-753f-4650-89fd-7ecbd19aaca1','Анастасія Рясна','');

-- ---------

INSERT INTO SINGING(worship_id,song_id,performer,note)
VALUES('0fb3a63d-5db6-41c1-8e21-494c4d8df519','5908f8a3-753f-4650-89fd-7ecbd19aaca1','Гітарний гурт','');

INSERT INTO SINGING(worship_id,song_id,performer,note)
VALUES('0fb3a63d-5db6-41c1-8e21-494c4d8df519','288a07f0-f7d9-4c89-8b41-d9a3df9c2cae','Гітарний Гурт','');

INSERT INTO SINGING(worship_id,song_id,performer,note)
VALUES('0fb3a63d-5db6-41c1-8e21-494c4d8df519','af52f4fb-6438-43d1-9434-be5ac1a423a4','Kate','');

INSERT INTO SINGING(worship_id,song_id,performer,note)
VALUES('0fb3a63d-5db6-41c1-8e21-494c4d8df519','5908f8a3-753f-4650-89fd-7ecbd19aaca1','Kate + Markolos','');
*/

SELECT * FROM SINGING