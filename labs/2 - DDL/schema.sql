DROP TABLE IF EXISTS attachments CASCADE;
DROP TABLE IF EXISTS messages CASCADE;
DROP TABLE IF EXISTS conversation_participants CASCADE;
DROP TABLE IF EXISTS conversations CASCADE;
DROP TABLE IF EXISTS users CASCADE;


CREATE TABLE users (
    user_id    UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    name       VARCHAR(100) NOT NULL CHECK (char_length(btrim(name)) > 0),
    username   VARCHAR(50)  NOT NULL UNIQUE CHECK (username ~ '^[a-zA-Z0-9_]{3,50}$'),
    email      VARCHAR(255) NOT NULL UNIQUE CHECK (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
    created_at TIMESTAMPTZ  NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE conversations (
    conversation_id UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    title           VARCHAR(150),
    type            VARCHAR(20)  NOT NULL CHECK (type IN ('direct', 'group')),

    CONSTRAINT chk_conversations_group_title
        CHECK (type <> 'group' OR (title IS NOT NULL AND char_length(btrim(title)) > 0))
);


CREATE TABLE conversation_participants (
    conversation_id UUID        NOT NULL,
    user_id         UUID        NOT NULL,
    role            VARCHAR(20) NOT NULL DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'member')),
    joined_at       TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_conversation_participants
        PRIMARY KEY (conversation_id, user_id),
    CONSTRAINT fk_participants_conversation
        FOREIGN KEY (conversation_id) REFERENCES conversations(conversation_id) ON DELETE CASCADE,
    CONSTRAINT fk_participants_user
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);


CREATE TABLE messages (
    message_id      UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID        NOT NULL,
    sender_id       UUID        NOT NULL,
    content         TEXT,
    sent_at         TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_messages_conversation
        FOREIGN KEY (conversation_id) REFERENCES conversations(conversation_id) ON DELETE CASCADE,
    CONSTRAINT fk_messages_sender
        FOREIGN KEY (sender_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE attachments (
    attachment_id UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id    UUID         NOT NULL,
    file_name     VARCHAR(255) NOT NULL CHECK (char_length(btrim(file_name)) > 0),
    mime_type     VARCHAR(100) NOT NULL CHECK (mime_type ~ '^[^/\s]+/[^/\s]+$'),
    size_bytes    BIGINT       NOT NULL CHECK (size_bytes > 0),
    storage_key   VARCHAR(512) NOT NULL UNIQUE CHECK (char_length(btrim(storage_key)) > 0),

    CONSTRAINT fk_attachments_message
        FOREIGN KEY (message_id) REFERENCES messages(message_id) ON DELETE CASCADE
);
