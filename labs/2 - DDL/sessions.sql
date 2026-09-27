CREATE TABLE sessions (
    session_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    refresh_token TEXT NOT NULL UNIQUE,
    device_type TEXT,
    device_name TEXT,
    os TEXT,
    browser TEXT,
    user_agent TEXT,
    user_location TEXT,
    ip_address INET
);

-- TODO: think about index for this FK
CREATE INDEX idx_sessions_user_id ON sessions(user_id);