DELETE FROM "user" 
WHERE username = 'misha745';

DELETE FROM category
WHERE name = 'Sport';

DELETE FROM lot_category
WHERE lot_id = 3 AND category_id = (SELECT id FROM category WHERE name = 'Home');