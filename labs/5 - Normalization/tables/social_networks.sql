CREATE TABLE IF NOT EXISTS public.social_networks(
    social_network_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    social_network_link TEXT NOT NULL,

    UNIQUE(user_id, social_network_link)
);
