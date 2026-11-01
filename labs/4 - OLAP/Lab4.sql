SELECT 
    COUNT(*) AS total_reviews,
    SUM(rating) AS sum_ratings,
    AVG(rating) AS avg_rating,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating
FROM review;

SELECT 
    poem_status,
    COUNT(*) AS poems_count
FROM poem
GROUP BY poem_status;

SELECT 
    poem_id,
    COUNT(*) AS reviews_count,
    SUM(rating) AS total_points
FROM review
GROUP BY poem_id
ORDER BY total_points DESC;

SELECT 
    poem_id,
    COUNT(*) AS reviews_count
FROM review
GROUP BY poem_id
HAVING COUNT(*) > 1;

SELECT 
    p.title,
    p.poem_status,
    per.username
FROM poem p
INNER JOIN person per ON p.owner_id = per.person_id;

SELECT 
    p.title,
    r.rating,
    r.comment
FROM poem p
LEFT JOIN review r ON p.poem_id = r.poem_id;

SELECT 
    p.title,
    COUNT(r.poem_id) AS reviews_count
FROM poem p
LEFT JOIN review r ON p.poem_id = r.poem_id
GROUP BY p.poem_id, p.title
ORDER BY reviews_count DESC;

SELECT 
    per.username,
    (SELECT COUNT(*) FROM poem p WHERE p.owner_id = per.person_id) AS poems_count
FROM person per;

SELECT 
    poem_id,
    title
FROM poem
WHERE poem_id IN (
    SELECT poem_id 
    FROM review 
    WHERE rating = 5
);

SELECT 
    poem_id,
    AVG(rating) AS poem_avg
FROM review
GROUP BY poem_id
HAVING AVG(rating) > (
    SELECT AVG(rating) 
    FROM review
);



SELECT 
    COUNT(*) AS total_poems,
    SUM(poem_id) AS sum_ids,
    AVG(poem_id) AS avg_id,
    MIN(published_at) AS first_published,
    MAX(published_at) AS last_published
FROM poem;

SELECT 
    visibility_status,
    COUNT(*) AS collections_count
FROM collection
GROUP BY visibility_status;

SELECT 
    collection_id,
    COUNT(*) AS poems_count,
    MAX(added_at) AS last_added
FROM collection_poem
GROUP BY collection_id
ORDER BY poems_count DESC;

SELECT 
    collection_id,
    COUNT(*) AS poems_count
FROM collection_poem
GROUP BY collection_id
HAVING COUNT(*) > 1;

SELECT 
    c.title,
    c.visibility_status,
    per.username
FROM collection c
INNER JOIN person per ON c.person_id = per.person_id;

SELECT 
    per.username,
    pa.poem_id,
    pa.contribution_type
FROM poem_author pa
RIGHT JOIN person per ON pa.user_id = per.person_id;

SELECT 
    c.title,
    COUNT(cp.poem_id) AS poems_count
FROM collection c
FULL JOIN collection_poem cp ON c.collection_id = cp.collection_id
GROUP BY c.collection_id, c.title
ORDER BY poems_count DESC;

SELECT 
    c.title,
    (SELECT COUNT(*) FROM collection_poem cp WHERE cp.collection_id = c.collection_id) AS poems_count
FROM collection c;

SELECT 
    poem_id,
    title
FROM poem
WHERE poem_id IN (
    SELECT poem_id 
    FROM collection_poem 
    WHERE collection_id = 1
);

SELECT 
    collection_id,
    COUNT(*) AS poems_count
FROM collection_poem
GROUP BY collection_id
HAVING COUNT(*) > (
    SELECT COUNT(*) 
    FROM collection_poem 
    WHERE collection_id = 2
);