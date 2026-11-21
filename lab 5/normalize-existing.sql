BEGIN;

-- 1НФ
ALTER TABLE booking ADD COLUMN equipment_ids INTEGER[];

UPDATE booking
SET equipment_ids = ARRAY[1, 3]
WHERE booking_id = 1;

SELECT booking_id, equipment_ids
FROM booking
WHERE booking_id = 1;

ALTER TABLE booking DROP COLUMN equipment_ids;

SELECT booking_id, equipment_id, quantity
FROM booking_equipment
WHERE booking_id = 1;

-- 2НФ
ALTER TABLE booking_equipment ADD COLUMN item_name VARCHAR(50);

UPDATE booking_equipment
SET item_name = equipment.item_name
FROM equipment
WHERE booking_equipment.equipment_id = equipment.equipment_id;

SELECT booking_id, equipment_id, item_name, quantity
FROM booking_equipment;

ALTER TABLE booking_equipment DROP COLUMN item_name;

-- 3НФ
ALTER TABLE booking ADD COLUMN court_name VARCHAR(15);

UPDATE booking
SET court_name = court.court_name
FROM court
WHERE booking.court_id = court.court_id;

SELECT booking_id, court_id, court_name
FROM booking;

ALTER TABLE booking DROP COLUMN court_name;

ROLLBACK;