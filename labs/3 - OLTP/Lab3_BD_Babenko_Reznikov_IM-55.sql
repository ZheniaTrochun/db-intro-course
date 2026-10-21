INSERT INTO person (username, email, password_hash) 
VALUES ('babenko_yaroslav', 'yaroslav@kyiv.ua', 'hash_yaroslav_123');

INSERT INTO person (username, email, password_hash) 
VALUES ('test_reader', 'reader@kyiv.ua', 'hash_reader_000');

INSERT INTO poem (owner_id, title, content_poem, poem_status) 
VALUES (6, 'Зимовий вечір', 'Опис зимового вечора...', 'notes');

INSERT INTO poem (owner_id, title, content_poem, poem_status) 
VALUES 
    (6, 'Київські каштани', 'Текст про осінній Київ...', 'notes'),
    (6, 'Дніпровські хвилі', 'Текст про річку...', 'notes')
RETURNING poem_id, title, poem_status;

INSERT INTO review (user_id, poem_id, rating, "comment") 
VALUES 
    (6, 1, 5, 'Неймовірно сильний твір! ' || chr(10) || 'Особливо вражає ритміка.');

SELECT username, email 
FROM person;

SELECT title, poem_status 
FROM poem 
WHERE poem_status = 'published';

SELECT person_id, username, email 
FROM person 
WHERE email LIKE '%@example.com' 
ORDER BY username ASC;

SELECT user_id, poem_id, rating, "comment" 
FROM review 
WHERE rating IN (4, 5) 
  AND "comment" IS NOT NULL;

SELECT poem_id, title, published_at 
FROM poem 
WHERE poem_status = 'published'
ORDER BY published_at DESC
LIMIT 2 
OFFSET 1;

UPDATE person 
SET email = 'new.yaroslav@kpi.ua' 
WHERE username = 'babenko_yaroslav';

UPDATE poem 
SET title = 'Зимовий вечір (оновлено)' 
WHERE title = 'Зимовий вечір';

UPDATE review 
SET rating = 4 
WHERE user_id = 6 AND poem_id = 1;

UPDATE review 
SET "comment" = "comment" || ' (Оновлено автором: виправив одруківки)' 
WHERE user_id = 6 AND poem_id = 1;

UPDATE poem 
SET poem_status = CASE 
    WHEN title = 'Київські каштани' THEN 'published'::poem_status
    WHEN title = 'Дніпровські хвилі' THEN 'reviewed'::poem_status
    ELSE poem_status 
END,
published_at = CASE 
    WHEN title = 'Київські каштани' THEN now() 
    ELSE published_at 
END
WHERE owner_id = 6;

DELETE FROM review 
WHERE user_id = 6 AND poem_id = 1;

DELETE FROM poem 
WHERE title = 'Зимовий вечір (оновлено)';

DELETE FROM person 
WHERE username = 'test_reader';

DELETE FROM review 
WHERE (rating BETWEEN 1 AND 2) 
   OR ("comment" IS NULL) 
   OR (length(trim("comment")) = 0);

DELETE FROM poem 
WHERE owner_id = 6 
  AND content_poem ILIKE '%річку%';




INSERT INTO person (username, email, password_hash) 
VALUES ('reznikov_nikita', 'nikita@kyiv.ua', 'hash_nikita_456');

INSERT INTO collection (person_id, title, visibility_status) 
VALUES (7, 'Сучасна українська лірика', 'public');

INSERT INTO poem_author (user_id, poem_id, contribution_type) 
VALUES (7, 3, 'редактор тексту');

INSERT INTO collection_poem (collection_id, poem_id, added_at) 
VALUES 
    (1, 2, DEFAULT),
    (1, 4, DEFAULT)
RETURNING *;

INSERT INTO review (user_id, poem_id, rating, "comment") 
VALUES 
    (7, 3, 4, 'Текст Франка ''Каменярі'' — це справжній шедевр.')
RETURNING user_id, poem_id, updated_at;

SELECT title, created_at 
FROM collection 
WHERE visibility_status = 'private';

SELECT poem_id, title, content_poem 
FROM poem 
WHERE owner_id = 4 AND poem_status = 'notes';

SELECT user_id, poem_id 
FROM poem_author 
WHERE contribution_type = 'головний автор';

SELECT user_id, poem_id, rating, COALESCE("comment", 'Користувач не залишив тексту') AS comment_text 
FROM review 
WHERE rating BETWEEN 1 AND 3;

SELECT title, visibility_status, created_at 
FROM collection 
WHERE person_id IN (1, 3, 7) 
ORDER BY visibility_status ASC, created_at DESC 
LIMIT 5;

UPDATE collection 
SET visibility_status = 'private' 
WHERE title = 'Сучасна українська лірика';

UPDATE poem 
SET title = 'Каменярі (Виправлене видання)' 
WHERE poem_id = 3;

UPDATE poem_author 
SET contribution_type = 'повноцінний співавтор' 
WHERE user_id = 7 AND poem_id = 3;

UPDATE review 
SET rating = GREATEST(rating - 1, 1), 
    updated_at = now() 
WHERE user_id = 7 AND poem_id = 3;

UPDATE collection 
SET visibility_status = 'deleted' 
WHERE visibility_status IN ('private', 'public') 
  AND title LIKE '%лірика%';

DELETE FROM poem_author 
WHERE user_id = 2 AND poem_id = 2;

DELETE FROM collection 
WHERE title = 'Сучасна українська лірика';

DELETE FROM person 
WHERE username = 'reznikov_nikita';

DELETE FROM collection_poem 
WHERE collection_id = 1 
  AND added_at BETWEEN '2026-10-01 00:00:00' AND '2026-10-01 23:59:59';

DELETE FROM review 
WHERE (rating = 1 OR rating = 2) 
  AND ("comment" IS NULL OR length("comment") < 5);
