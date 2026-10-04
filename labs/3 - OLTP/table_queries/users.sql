CREATE TYPE user_status_enum AS ENUM('active', 'banned', 'deactivated');
CREATE TYPE user_role_enum AS ENUM('user', 'admin');

CREATE TABLE users(
    user_id UUID PRIMARY KEY DEFAULT uuidv7(),
    nickname VARCHAR(30) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    email TEXT NOT NULL UNIQUE,
    google_id TEXT UNIQUE,
    bio TEXT NOT NULL DEFAULT '',
    password_hash TEXT,
    avatar_url TEXT,
    social_networks TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
    max_streak INT NOT NULL DEFAULT 0 CHECK(max_streak >= 0),
    timezone TEXT NOT NULL DEFAULT 'UTC',
    last_watch_date DATE,
    profile_frame_url TEXT,
    profile_background_url TEXT,
    user_role user_role_enum NOT NULL DEFAULT 'user',
    user_status user_status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT check_user_auth_method CHECK(password_hash IS NOT NULL OR google_id IS NOT NULL)
);

CREATE INDEX idx_user_status ON users(user_status);

--- INSERT EXAMPLES ---

INSERT INTO users(user_id, nickname, full_name, email, password_hash) VALUES
    ('00000000-0000-7000-8000-000000000001', 'BadBoy67', 'He Is Bad', 'badboy67@ukr.net', 'very secretative password hash'),
    ('00000000-0000-7000-8000-000000000002', 'GoodBoy34', 'He Is Good', 'goodboy34@gmail.com', 'example password hash'),
    ('00000000-0000-7000-8000-000000000003', 'TheBestBoy911', 'He Is The Best', 'thebestboy911@something.example', 'really good password hash');
