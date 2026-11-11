-- =====================================================
-- Завдання 1. Схема бази даних: Платформа фрілансу
-- СУБД: PostgreSQL
-- =====================================================

DROP TABLE IF EXISTS contracts,
proposals,
projects,
freelancers,
clients,
categories CASCADE;


CREATE TABLE categories (
    category_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE
);


CREATE TABLE clients (
    client_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_name VARCHAR(150) NOT NULL,
    contact_name VARCHAR(100) NOT NULL,
    email        VARCHAR(100) NOT NULL UNIQUE,
    phone        VARCHAR(20)  UNIQUE,
    country      VARCHAR(50)  NOT NULL
);


CREATE TABLE freelancers (
    freelancer_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    skills        TEXT NOT NULL,
    hourly_rate   NUMERIC(8, 2) NOT NULL CHECK (hourly_rate > 0),
    registered_at DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE projects (
    project_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    client_id   INT NOT NULL REFERENCES clients (client_id) ON DELETE CASCADE,
    category_id INT NOT NULL REFERENCES categories (category_id),
    title       VARCHAR(200) NOT NULL,
    description TEXT,
    budget      NUMERIC(12, 2) NOT NULL CHECK (budget > 0),
    deadline    DATE NOT NULL,
    status      VARCHAR(20) NOT NULL DEFAULT 'open'
                CHECK (status IN ('open', 'in_progress', 'completed', 'cancelled')),
    created_at  DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE proposals (
    proposal_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id    INT NOT NULL REFERENCES projects (project_id) ON DELETE CASCADE,
    freelancer_id INT NOT NULL REFERENCES freelancers (freelancer_id) ON DELETE CASCADE,
    price         NUMERIC(12, 2) NOT NULL CHECK (price > 0),
    cover_letter  TEXT,
    submitted_at  DATE NOT NULL DEFAULT CURRENT_DATE,
    status        VARCHAR(20) NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending', 'accepted', 'rejected')),
    UNIQUE (project_id, freelancer_id)
);

CREATE TABLE contracts (
    contract_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    proposal_id INT NOT NULL UNIQUE REFERENCES proposals (proposal_id) ON DELETE CASCADE,
    start_date  DATE NOT NULL,
    end_date    DATE,
    status      VARCHAR(20) NOT NULL DEFAULT 'active'
                CHECK (status IN ('active', 'completed', 'terminated')),
    rating      SMALLINT CHECK (rating BETWEEN 1 AND 5),
    CHECK (end_date IS NULL OR end_date >= start_date)
);
