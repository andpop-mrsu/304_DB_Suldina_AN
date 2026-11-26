PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS works;
DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS master_services;
DROP TABLE IF EXISTS service_prices;
DROP TABLE IF EXISTS services;
DROP TABLE IF EXISTS cars;
DROP TABLE IF EXISTS clients;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS car_categories;
DROP TABLE IF EXISTS bays;

-- 1. Справочник категорий авто
CREATE TABLE car_categories (
    id   INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL
);

-- 2. Клиенты автомойки
CREATE TABLE clients (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name TEXT NOT NULL,
    phone     TEXT NOT NULL,
    email     TEXT UNIQUE
);

-- 3. Автомобили клиентов
CREATE TABLE cars (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    client_id     INTEGER NOT NULL,
    brand         TEXT NOT NULL,
    license_plate TEXT UNIQUE,
    category_id   INTEGER NOT NULL,
    FOREIGN KEY (client_id)   REFERENCES clients(id)        ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES car_categories(id) ON DELETE RESTRICT
);

-- 4. Сотрудники (кадровый учет)
CREATE TABLE employees (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name        TEXT NOT NULL,
    position         TEXT NOT NULL DEFAULT 'Мастер',
    hire_date        TEXT NOT NULL DEFAULT (date('now')),
    termination_date TEXT,                -- NULL = работает
    salary_percent   REAL NOT NULL DEFAULT 30.0 CHECK (salary_percent BETWEEN 0 AND 100),
    phone            TEXT UNIQUE,
    CHECK (termination_date IS NULL OR termination_date >= hire_date)
);

-- 5. Справочник услуг
CREATE TABLE services (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    name             TEXT UNIQUE NOT NULL,
    duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0)
);

-- 6. Цены услуг по категориям авто
CREATE TABLE service_prices (
    service_id  INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    price       REAL NOT NULL CHECK (price >= 0),
    PRIMARY KEY (service_id, category_id),
    FOREIGN KEY (service_id)  REFERENCES services(id)       ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES car_categories(id) ON DELETE CASCADE
);

-- 7. Какие услуги умеет выполнять мастер
CREATE TABLE master_services (
    employee_id INTEGER NOT NULL,
    service_id  INTEGER NOT NULL,
    PRIMARY KEY (employee_id, service_id),
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id)  REFERENCES services(id)  ON DELETE CASCADE
);

-- 8. Боксы
CREATE TABLE bays (
    id     INTEGER PRIMARY KEY AUTOINCREMENT,
    name   TEXT UNIQUE NOT NULL,
    status TEXT NOT NULL DEFAULT 'Работает' CHECK (status IN ('Работает', 'Ремонт'))
);

-- 9. Предварительная запись
CREATE TABLE appointments (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    car_id      INTEGER NOT NULL,
    bay_id      INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    service_id  INTEGER NOT NULL,
    start_time  TEXT NOT NULL,            -- 'YYYY-MM-DD HH:MM:SS'
    end_time    TEXT NOT NULL,
    status      TEXT NOT NULL DEFAULT 'Запланирована'
                CHECK (status IN ('Запланирована', 'Выполнена', 'Отменена')),
    CHECK (end_time > start_time),
    FOREIGN KEY (car_id)      REFERENCES cars(id)      ON DELETE RESTRICT,
    FOREIGN KEY (bay_id)      REFERENCES bays(id)      ON DELETE RESTRICT,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE RESTRICT,
    FOREIGN KEY (service_id)  REFERENCES services(id)  ON DELETE RESTRICT
);

-- 10. Учет выполненных работ 
CREATE TABLE works (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    appointment_id INTEGER,               -- NULL = работа без предварительной записи
    employee_id    INTEGER NOT NULL,
    service_id     INTEGER NOT NULL,
    work_date      TEXT NOT NULL DEFAULT (date('now')),
    actual_price   REAL NOT NULL CHECK (actual_price >= 0),
    is_paid        INTEGER NOT NULL DEFAULT 0 CHECK (is_paid IN (0, 1)),
    FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE SET NULL,
    FOREIGN KEY (employee_id)    REFERENCES employees(id)    ON DELETE RESTRICT,
    FOREIGN KEY (service_id)     REFERENCES services(id)     ON DELETE RESTRICT
);

CREATE INDEX idx_appointments_bay_time  ON appointments(bay_id, start_time);
CREATE INDEX idx_appointments_master    ON appointments(employee_id, start_time);
CREATE INDEX idx_works_date_employee    ON works(work_date, employee_id);

-- тестовые данные

INSERT INTO car_categories (name) VALUES ('Седан'), ('Кроссовер'), ('Внедорожник');

INSERT INTO clients (full_name, phone, email) VALUES
('Смирнов Алексей',  '+79011111111', 'smirnov@mail.ru'),
('Кузнецова Ольга',  '+79022222222', 'kuznetsova@mail.ru');

INSERT INTO cars (client_id, brand, license_plate, category_id) VALUES
(1, 'Toyota Camry', 'А123БВ77', 1),
(2, 'BMW X5',       'А456ГД77', 3);

INSERT INTO employees (full_name, position, hire_date, termination_date, salary_percent, phone) VALUES
('Иванов Иван',      'Старший мастер', '2022-03-15', NULL,         40.0, '+79001112233'),
('Петров Петр',      'Мастер',         '2021-06-01', '2023-12-31', 30.0, '+79002223344'),
('Сидоров Алексей',  'Мастер',         '2023-01-10', NULL,         35.0, '+79003334455');

INSERT INTO services (name, duration_minutes) VALUES
('Мойка кузова', 30), ('Химчистка салона', 120), ('Полировка', 90);

INSERT INTO service_prices (service_id, category_id, price) VALUES
(1, 1, 500.0),  (1, 2, 700.0),  (1, 3, 900.0),
(2, 1, 3000.0), (2, 2, 3500.0), (2, 3, 4000.0),
(3, 1, 2000.0), (3, 2, 2500.0), (3, 3, 3000.0);

INSERT INTO master_services (employee_id, service_id) VALUES
(1, 1), (1, 2), (1, 3),
(2, 1), (2, 2),
(3, 1), (3, 3);

INSERT INTO bays (name, status) VALUES ('Бокс 1', 'Работает'), ('Бокс 2', 'Работает');

INSERT INTO appointments (car_id, bay_id, employee_id, service_id, start_time, end_time, status) VALUES
(1, 1, 1, 1, '2024-11-25 10:00:00', '2024-11-25 10:30:00', 'Выполнена'),
(2, 2, 3, 3, '2024-11-25 11:00:00', '2024-11-25 12:30:00', 'Запланирована'),
(2, 1, 2, 2, '2023-12-20 09:00:00', '2023-12-20 11:00:00', 'Выполнена'),  
(1, 2, 1, 2, '2024-11-26 10:00:00', '2024-11-26 12:00:00', 'Выполнена'),
(1, 1, 3, 1, '2024-11-27 09:00:00', '2024-11-27 09:30:00', 'Выполнена');

INSERT INTO works (appointment_id, employee_id, service_id, work_date, actual_price, is_paid) VALUES
(1, 1, 1, '2024-11-25', 500.0,  1),
(3, 2, 2, '2023-12-20', 4000.0, 1),  
(4, 1, 2, '2024-11-26', 3000.0, 1),
(5, 3, 1, '2024-11-27', 500.0,  0);