CREATE TABLE IF NOT EXISTS public.sessions(
    session_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    refresh_token BYTEA NOT NULL UNIQUE CHECK(length(refresh_token) = 96),
    expire_time TIMESTAMPTZ NOT NULL DEFAULT now() + INTERVAL '180 days',
    device_type TEXT,
    device_name TEXT,
    os TEXT,
    browser TEXT,
    user_location TEXT,
    ip_address INET
);

CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON public.sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_expire_time ON public.sessions(expire_time ASC);
