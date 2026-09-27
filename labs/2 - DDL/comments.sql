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