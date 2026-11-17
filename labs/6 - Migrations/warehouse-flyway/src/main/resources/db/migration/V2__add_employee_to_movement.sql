-- хто з працівників оформив документ руху (ТТН)
ALTER TABLE movement
ADD COLUMN employee_id INTEGER REFERENCES employee(employee_id) ON DELETE RESTRICT;

UPDATE movement SET employee_id = 2 WHERE warehouse_id = 1;
UPDATE movement SET employee_id = 3 WHERE warehouse_id = 2;