CREATE TABLE comments(
    comment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    author_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    anime_id UUID NOT NULL REFERENCES animes(anime_id) ON DELETE CASCADE,
    grade SMALLINT CHECK (grade BETWEEN -5 AND 5),
    content TEXT NOT NULL CHECK(length(trim(content)) > 0),
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    is_edited BOOL DEFAULT FALSE
);

CREATE INDEX idx_comments_anime_created ON comments(anime_id, created_at DESC);

--- INSERT EXAMPLES ---

INSERT INTO comments(author_id, anime_id, grade, content) VALUES
    (
        '00000000-0000-7000-8000-000000000001', 
        '11111111-1111-1111-1111-111111111111', 
        -3, 
        'Example Comment 1'
    ),
    (
        '00000000-0000-7000-8000-000000000002', 
        '11111111-6666-1111-2222-111119999999', 
        0, 
        'Example Comment 2'
    ),
    (
        '00000000-0000-7000-8000-000000000003', 
        '33333333-3333-3333-3333-333333333333', 
        NULL, 
        'Example Comment 3'
    );
