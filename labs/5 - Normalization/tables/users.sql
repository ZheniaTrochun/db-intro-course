CREATE TYPE public.user_status_enum AS ENUM('active', 'banned', 'deactivated');
CREATE TYPE public.user_role_enum AS ENUM('user', 'admin');

CREATE TABLE IF NOT EXISTS public.users(
    user_id UUID PRIMARY KEY DEFAULT uuidv7(),
    nickname VARCHAR(30) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email TEXT NOT NULL,
    google_id TEXT UNIQUE,
    bio TEXT NOT NULL DEFAULT '',
    password_hash TEXT,
    avatar_url TEXT NOT NULL DEFAULT '',
    max_streak INT NOT NULL DEFAULT 0 CHECK(max_streak >= 0),
    timezone TEXT NOT NULL DEFAULT 'Europe/Kyiv',
    streak_start_date DATE,
    last_watch_date DATE,
    profile_frame_url TEXT,
    profile_background_url TEXT,
    user_role user_role_enum NOT NULL DEFAULT 'user',
    user_status user_status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT check_user_auth_method CHECK(password_hash IS NOT NULL OR google_id IS NOT NULL)
);

CREATE INDEX IF NOT EXISTS idx_users_status ON public.users(user_status);
CREATE UNIQUE INDEX idx_users_unique_lower_nickname ON public.users(lower(nickname));
CREATE UNIQUE INDEX idx_users_unique_lower_email ON public.users(lower(email));
