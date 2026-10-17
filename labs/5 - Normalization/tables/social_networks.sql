CREATE TABLE IF NOT EXISTS public.social_networks(
    social_network_id UUID PRIMARY KEY DEFAULT uuidv7(),
    user_id UUID NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    provider TEXT NOT NULL,
    url TEXT NOT NULL,

    CONSTRAINT unique_user_provider UNIQUE (user_id, provider)
);