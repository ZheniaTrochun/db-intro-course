CREATE TABLE sessions(
    session_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    refresh_token CHAR(128) NOT NULL UNIQUE,
    device_type TEXT,
    device_name TEXT,
    os TEXT,
    browser TEXT,
    user_agent TEXT,
    user_location TEXT,
    ip_address INET
);

CREATE INDEX idx_sessions_refresh_token ON sessions(refresh_token);

--- INSERT EXAMPLES ---

INSERT INTO sessions(
    user_id,
    refresh_token,
    device_type,
    device_name
) VALUES
    (
        '00000000-0000-7000-8000-000000000001',
        '1',
        'desktop',
        'Windows PC'
    ),
    (
        '00000000-0000-7000-8000-000000000002',
        '2',
        'mobile',
        'iPhone 15 Pro'
    ),
    (
        '00000000-0000-7000-8000-000000000003',
        '3',
        'mobile',
        'ZTE Nubia Red Magic 7S Pro Supernova Lords Mobile Limited Edition'
    );
