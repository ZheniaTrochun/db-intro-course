CREATE TABLE comments (
    comment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    author_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    anime_id UUID NOT NULL REFERENCES animes(anime_id) ON DELETE CASCADE,
    grade SMALLINT CHECK (grade BETWEEN -5 AND 5),
    content TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

-- TODO: think about index for these FKs
CREATE INDEX idx_comments_anime_id ON comments(anime_id);
CREATE INDEX idx_comments_author_id ON comments(author_id);


-- TEST: Example of insertion (using ids that are hardcoded in corresponding .sql files)
-- It is extremely bad practice for real project and is just for example
INSERT INTO comments (author_id, anime_id, grade, content) VALUES
    (
        '00000000-0000-7000-8000-000000000001', 
        '00000000-aaaa-7000-8000-000000000001', 
        -3, 
        'Example Comment 1'
    ),
    (
        '00000000-0000-7000-8000-000000000002', 
        '00000000-aaaa-7000-8000-000000000001', 
        0, 
        'Example Comment 2'
    ),
    (
        '00000000-0000-7000-8000-000000000003', 
        '00000000-aaaa-7000-8000-000000000001', 
        5, 
        'Example Comment 3'
    );