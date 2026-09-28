CREATE TYPE user_status_enum AS ENUM ('admin', 'banned', 'deactivated');

CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuidv7(),
    nickname VARCHAR(30) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    email TEXT NOT NULL UNIQUE,
    google_id TEXT UNIQUE,
    bio TEXT NOT NULL DEFAULT '',
    password_hash TEXT,
    avatar_url TEXT,
    social_networks TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
    max_streak INTEGER NOT NULL DEFAULT 0,
    timezone TEXT NOT NULL DEFAULT 'UTC',
    last_watch_date DATE,
    profile_frame_url TEXT,
    profile_background_url TEXT,
    user_status user_status_enum,
    crated_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX idx_user_status ON user(user_status);
CREATE INDEX idx_nickname ON user(nickname);

-- TEST: Example of insertion with hardcoded user_id
-- It is extremely bad practice for real project and is just for example
INSERT INTO users (user_id, nickname, full_name, email) VALUES
    ('00000000-0000-7000-8000-000000000001','BadBoy67','He Is Bad','badboy67@ukr.net'),
    ('00000000-0000-7000-8000-000000000002','GoodBoy34','He Is Good','goodboy34@gmail.com'),
    ('00000000-0000-7000-8000-000000000003','TheBestBoy911','He Is The Best','thebestboy911@something.example');
