CREATE TABLE IF NOT EXISTS users (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100),
    nickname VARCHAR(50) NOT NULL UNIQUE,
    phone_number VARCHAR(20) UNIQUE, 
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    timezone VARCHAR(32) NOT NULL DEFAULT 'Etc/UTC',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS workspaces (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    owner_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'ARCHIVED', 'SUSPENDED')),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (owner_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS task_categories (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    workspace_id BIGINT REFERENCES workspaces(id) ON DELETE CASCADE, 
    name VARCHAR(100) NOT NULL, 
    color VARCHAR(8) NOT NULL DEFAULT '#f8f8f8',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMPTZ, 
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tasks (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT, 
    status VARCHAR(30) NOT NULL DEFAULT 'open'
        CHECK (status IN ('open', 'in_progress', 'done', 'closed', 'cancelled')),
    priority INTEGER CHECK (priority > 0), 
    creator_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    assignee_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    workspace_id BIGINT REFERENCES workspaces(id) ON DELETE CASCADE,
    category_id BIGINT REFERENCES task_categories(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deadline TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_task_deadline CHECK (deadline IS NULL OR deadline >= created_at)
);

CREATE TABLE IF NOT EXISTS workspace_members (
    user_id BIGINT NOT NULL,
    workspace_id BIGINT NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'MEMBER' CHECK (role IN ('ADMIN', 'OWNER', 'MEMBER', 'GUEST')),
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INVITED', 'DEACTIVATED', 'ARCHIVED')),
    joined_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (user_id, workspace_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (workspace_id) REFERENCES workspaces(id)
);

CREATE TABLE IF NOT EXISTS habits_categories (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    -- cascade deletion since habits categories are not related to collaborative work in workspaces --
    user_id BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    name VARCHAR(256) NOT NULL,
    color VARCHAR(8) NOT NULL DEFAULT '#fff9e2', -- hexadecimal notation --
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS habits (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(256) NOT NULL,
    description TEXT NULL,
    creator_id BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    category_id BIGINT NULL REFERENCES habits_categories (id) ON DELETE SET NULL,
    timezone VARCHAR(32) NOT NULL DEFAULT 'Etc/UTC', -- IANA tz format --
    -- array_length(frequency_days, 1), where 1 stands for array dimension which length the function computes --
    frequency_days SMALLINT[] NOT NULL DEFAULT ARRAY[1, 2, 3, 4, 5, 6, 7] CHECK (
        array_ndims(frequency_days) = 1 AND
        cardinality(frequency_days) BETWEEN  1 AND 7
    ),
    status VARCHAR(16) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'PAUSED', 'ARCHIVED', 'DRAFT', 'DROPPED', 'FAILED')),
    start_day DATE NULL,
    end_day DATE NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now() 
);

CREATE TABLE IF NOT EXISTS habit_completions (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    habit_id BIGINT NOT NULL REFERENCES habits (id) ON DELETE CASCADE,
    local_timestamp TIMESTAMPTZ NOT NULL, -- the timezone can be accessed via habits table --
    completed_at TIMESTAMPTZ DEFAULT now(),
    actual_value SMALLINT NULL,
    note TEXT NULL,
    status VARCHAR(256) NOT NULL DEFAULT 'COMPLETED' CHECK (status IN ('COMPLETED ', 'SKIPPED', 'MISSED', 'PARTIALLY_COMPLETED'))
);