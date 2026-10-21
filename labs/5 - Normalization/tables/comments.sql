CREATE TABLE IF NOT EXISTS public.comments(
    comment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    author_id UUID NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    anime_id UUID NOT NULL REFERENCES public.animes(anime_id) ON DELETE CASCADE,
    content TEXT NOT NULL CHECK(length(trim(content)) > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    is_edited BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_comments_anime_created ON public.comments(anime_id, comment_id DESC);
