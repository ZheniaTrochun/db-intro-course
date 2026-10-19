INSERT INTO person (username, email, password_hash) 
VALUES ('babenko_yaroslav', 'yaroslav@kyiv.ua', 'hash_yaroslav_123');

INSERT INTO poem (owner_id, title, content_poem, poem_status) 
VALUES (6, 'Київські каштани', 'Текст про осінній Київ...', 'notes');

INSERT INTO review (user_id, poem_id, rating, "comment") 
VALUES (6, 1, 5, 'Неймовірно сильний твір, актуальний і сьогодні.');



INSERT INTO person (username, email, password_hash) 
VALUES ('reznikov_nikita', 'nikita@kyiv.ua', 'hash_nikita_456');

INSERT INTO collection (person_id, title, visibility_status) 
VALUES (7, 'Сучасна українська лірика', 'public');

INSERT INTO poem_author (user_id, poem_id, contribution_type) 
VALUES (7, 6, 'редактор тексту');



SELECT username, email 
FROM person;

SELECT title, poem_status, published_at 
FROM poem 
WHERE poem_status = 'published';

SELECT user_id, rating, "comment" 
FROM review 
WHERE rating = 5;



SELECT title, created_at 
FROM collection 
WHERE visibility_status = 'private';

SELECT poem_id, title, content_poem 
FROM poem 
WHERE owner_id = 4 AND poem_status = 'notes';

SELECT user_id, poem_id 
FROM poem_author 
WHERE contribution_type = 'головний автор';



UPDATE person 
SET email = 'new.yaroslav@kpi.ua' 
WHERE username = 'babenko_yaroslav';

UPDATE poem 
SET poem_status = 'published', published_at = now() 
WHERE title = 'Київські каштани';

UPDATE review 
SET rating = 4, "comment" = 'Твір хороший, але є одруківки в 3 строфі.' 
WHERE user_id = 6 AND poem_id = 1;



UPDATE collection 
SET visibility_status = 'private' 
WHERE title = 'Сучасна українська лірика';

UPDATE poem 
SET title = 'Каменярі (Виправлене видання)' 
WHERE poem_id = 3;

UPDATE poem_author 
SET contribution_type = 'повноцінний співавтор' 
WHERE user_id = 7 AND poem_id = 6;



DELETE FROM review 
WHERE user_id = 6 AND poem_id = 1;

DELETE FROM collection_poem 
WHERE collection_id = 1 AND poem_id = 1;

DELETE FROM poem 
WHERE title = 'Київські каштани';



DELETE FROM poem_author 
WHERE user_id = 2 AND poem_id = 2;

DELETE FROM collection 
WHERE title = 'Сучасна українська лірика';

DELETE FROM person 
WHERE username = 'reznikov_nikita';
