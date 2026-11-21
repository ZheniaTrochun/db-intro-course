-- 1

SELECT * FROM location;

-- 2

SELECT location_id, name, address 
FROM location 
WHERE type = 'store' AND status = 'working';

--  3

INSERT INTO location (name, type, address, status) 
VALUES ('Магазин у ТРЦ "Ocean Plaza"', 'store', 'м. Київ, вул. Антоновича, 176', 'working');

SELECT * FROM location WHERE name LIKE '%Ocean Plaza%';

-- 4

UPDATE location 
SET status = 'closed' 
WHERE name LIKE '%Ocean Plaza%';

SELECT location_id, status FROM location WHERE name LIKE '%Ocean Plaza%';

-- 5

SELECT * FROM location 
WHERE name LIKE '%Ocean Plaza%' AND status = 'closed';

DELETE FROM location 
WHERE name LIKE '%Ocean Plaza%' AND status = 'closed';

SELECT * FROM location WHERE name LIKE '%Ocean Plaza%';