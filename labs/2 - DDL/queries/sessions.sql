CREATE TABLE sessions(
    session_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    refresh_token CHAR(128) NOT NULL UNIQUE,
    expire_time TIMESTAMP NOT NULL DEFAULT (now() + INTERVAL '1 year'),
    device_type TEXT,
    device_name TEXT,
    os TEXT,
    browser TEXT,
    user_agent TEXT,
    user_location TEXT,
    ip_address INET
);


-- TO THINK: I have added index for user_id, because if we might want to find all user sessions to show it to user or smth like that
CREATE INDEX idx_sessions_user_id ON sessions(user_id);

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
