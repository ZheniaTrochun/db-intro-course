-- фінальна схема в 3НФ 

DROP TABLE IF EXISTS incident_participant, incident, visit, student,
    student_group, faculty, participant_role, incident_status,
    incident_type, security_employee CASCADE;

CREATE TABLE faculty (
    faculty_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name       VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE student_group (
    group_id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    faculty_id INTEGER     NOT NULL,
    name       VARCHAR(50) NOT NULL UNIQUE,
    CONSTRAINT fk_student_group_faculty
        FOREIGN KEY (faculty_id) REFERENCES faculty (faculty_id)
);

CREATE TABLE student (
    student_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    group_id   INTEGER      NOT NULL,
    full_name  VARCHAR(150) NOT NULL,
    CONSTRAINT fk_student_group
        FOREIGN KEY (group_id) REFERENCES student_group (group_id)
);

CREATE TABLE security_employee (
    employee_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name   VARCHAR(150) NOT NULL,
    position    VARCHAR(100) NOT NULL,
    phone       VARCHAR(20)  NOT NULL UNIQUE
);

CREATE TABLE incident_type (
    type_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name    VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE incident_status (
    status_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name      VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE participant_role (
    role_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name    VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE visit (
    visit_id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id INTEGER     NOT NULL,
    category   VARCHAR(50) NOT NULL DEFAULT 'Відпочинок',
    started_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ended_at   TIMESTAMP,
    CONSTRAINT fk_visit_student
        FOREIGN KEY (student_id) REFERENCES student (student_id),
    CONSTRAINT chk_visit_dates
        CHECK (ended_at IS NULL OR ended_at >= started_at)
);

CREATE TABLE incident (
    incident_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    visit_id    INTEGER     NOT NULL,
    type_id     INTEGER     NOT NULL,
    employee_id INTEGER     NOT NULL,
    status_id   INTEGER     NOT NULL DEFAULT 1,
    description TEXT,
    occurred_at TIMESTAMP   NOT NULL,
    severity    VARCHAR(20) NOT NULL,
    CONSTRAINT fk_incident_visit
        FOREIGN KEY (visit_id) REFERENCES visit (visit_id),
    CONSTRAINT fk_incident_type
        FOREIGN KEY (type_id) REFERENCES incident_type (type_id),
    CONSTRAINT fk_incident_employee
        FOREIGN KEY (employee_id) REFERENCES security_employee (employee_id),
    CONSTRAINT fk_incident_status
        FOREIGN KEY (status_id) REFERENCES incident_status (status_id),
    CONSTRAINT chk_incident_severity
        CHECK (severity IN ('Низький', 'Середній', 'Високий'))
);

CREATE TABLE incident_participant (
    incident_id INTEGER NOT NULL,
    visit_id    INTEGER NOT NULL,
    role_id     INTEGER NOT NULL,
    CONSTRAINT pk_incident_participant
        PRIMARY KEY (incident_id, visit_id),
    CONSTRAINT fk_participant_incident
        FOREIGN KEY (incident_id) REFERENCES incident (incident_id),
    CONSTRAINT fk_participant_visit
        FOREIGN KEY (visit_id) REFERENCES visit (visit_id),
    CONSTRAINT fk_participant_role
        FOREIGN KEY (role_id) REFERENCES participant_role (role_id)
);

-- Початковий статус, на який посилається DEFAULT 1 в incident.status_id
INSERT INTO incident_status (name) VALUES ('Відкрито'), ('В обробці'), ('Закрито');