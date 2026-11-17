-- працівники складу
CREATE TABLE employee (
    employee_id  SERIAL       PRIMARY KEY,
    warehouse_id INTEGER      NOT NULL REFERENCES warehouse(warehouse_id) ON DELETE RESTRICT,
    full_name    VARCHAR(150) NOT NULL CHECK (btrim(full_name) <> ''),
    position     VARCHAR(50)  NOT NULL CHECK (btrim(position) <> ''),
    phone        VARCHAR(20),
    hired_at     DATE         NOT NULL DEFAULT CURRENT_DATE
);

INSERT INTO employee (warehouse_id, full_name, position, phone, hired_at) VALUES
    (1, 'Коваленко Андрій', 'Начальник складу', '+380671112233', '2025-03-01'),
    (1, 'Шевчук Ірина',     'Комірник',         '+380502223344', '2025-06-15'),
    (2, 'Бондар Максим',    'Комірник',         NULL,            '2025-09-01'),
    (3, 'Ткаченко Олена',   'Комірник',         '+380633334455', '2026-01-10');