CREATE TABLE IF NOT EXISTS public.user_links(
    user_link_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    user_link_url TEXT NOT NULL,

    UNIQUE(user_id, user_link_url)
);
