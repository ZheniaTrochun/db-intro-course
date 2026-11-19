SELECT articles.name, articles.id, articles.language,
revisions.relative_id as "revision number", revisions.content
FROM articles
JOIN revisions ON articles.id = revisions.article_id
WHERE articles.id = 3;

INSERT INTO 
revisions(article_id, relative_id, "user", date, content)
VALUES
(3, 1, 'user_c', '22.10.2023', 'some content'),
(3, 2, 'user_a', '22.10.2023', 'some updated content'),
(3, 3, 'user_c', '23.10.2023', 'some updated updated content');

UPDATE articles
SET name = 'scientific technolodgy 43'
WHERE name = 'scientific technolodgy 34';

DELETE FROM revisions
WHERE article_id = 3 AND relative_id = 3;