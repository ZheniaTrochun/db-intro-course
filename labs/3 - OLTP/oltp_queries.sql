SELECT user_id, name, username, email, created_at
FROM users
WHERE username = 'staljerst';

SELECT conversation_id, title, type
FROM conversations
WHERE type = 'group'
ORDER BY title;

SELECT
    c.conversation_id,
    COALESCE(c.title, '(Особистий чат)') AS chat_title,
    c.type,
    cp.role,
    cp.joined_at
FROM conversation_participants cp
JOIN users u ON u.user_id = cp.user_id
JOIN conversations c ON c.conversation_id = cp.conversation_id
WHERE u.username = 'olena_kov'
ORDER BY cp.joined_at;

SELECT
    m.message_id,
    u.name AS sender_name,
    u.username AS sender_username,
    m.content,
    a.file_name AS attachment_name,
    m.sent_at
FROM messages m
JOIN users u ON u.user_id = m.sender_id
LEFT JOIN attachments a ON a.message_id = m.message_id
WHERE m.conversation_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2'
ORDER BY m.sent_at, a.file_name;

SELECT attachment_id, file_name, mime_type, size_bytes
FROM attachments
WHERE size_bytes > 102400
ORDER BY size_bytes DESC;



INSERT INTO users (user_id, name, username, email)
VALUES (
    '66666666-6666-6666-6666-666666666666',
    'Софія Ткаченко',
    'sofia_tk',
    'sofia@example.com'
);

SELECT user_id, name, username, email, created_at
FROM users
WHERE user_id = '66666666-6666-6666-6666-666666666666';

INSERT INTO conversation_participants (conversation_id, user_id, role)
VALUES (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2',
    '66666666-6666-6666-6666-666666666666',
    'member'
);

SELECT conversation_id, user_id, role, joined_at
FROM conversation_participants
WHERE conversation_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2'
  AND user_id = '66666666-6666-6666-6666-666666666666';

BEGIN;

INSERT INTO conversations (conversation_id, title, type)
VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa6', 'Обговорення Lab 3', 'group');

INSERT INTO conversation_participants (conversation_id, user_id, role)
VALUES
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa6', '22222222-2222-2222-2222-222222222222', 'owner'),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa6', '66666666-6666-6666-6666-666666666666', 'member');

INSERT INTO messages (message_id, conversation_id, sender_id, content)
VALUES (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb7',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa6',
    '66666666-6666-6666-6666-666666666666',
    'Привіт! Ось запити для перевірки Lab 3.'
);

INSERT INTO attachments (attachment_id, message_id, file_name, mime_type, size_bytes, storage_key)
VALUES (
    'cccccccc-cccc-cccc-cccc-ccccccccccc6',
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb7',
    'oltp_queries.sql',
    'application/sql',
    5120,
    'uploads/2026/09/oltp_queries_06.sql'
);

COMMIT;


SELECT
    c.title,
    u.username AS sender,
    m.content,
    a.file_name,
    a.size_bytes
FROM messages m
JOIN conversations c ON c.conversation_id = m.conversation_id
JOIN users u ON u.user_id = m.sender_id
LEFT JOIN attachments a ON a.message_id = m.message_id
WHERE c.conversation_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa6';


SELECT user_id, name, email
FROM users
WHERE user_id = '66666666-6666-6666-6666-666666666666';

UPDATE users
SET name  = 'Софія Ткаченко-Мельник',
    email = 'sofia.tkachenko@example.com'
WHERE user_id = '66666666-6666-6666-6666-666666666666';

SELECT user_id, name, email
FROM users
WHERE user_id = '66666666-6666-6666-6666-666666666666';

SELECT conversation_id, user_id, role
FROM conversation_participants
WHERE conversation_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2'
  AND user_id = '66666666-6666-6666-6666-666666666666';

UPDATE conversation_participants
SET role = 'admin'
WHERE conversation_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2'
  AND user_id = '66666666-6666-6666-6666-666666666666';

SELECT conversation_id, user_id, role
FROM conversation_participants
WHERE conversation_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2'
  AND user_id = '66666666-6666-6666-6666-666666666666';

UPDATE conversations
SET title = 'Обговорення Lab 3 (OLTP)'
WHERE conversation_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa6';

UPDATE messages
SET content = 'Привіт! Ось фінальна версія запитів для Lab 3.'
WHERE message_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb7';

SELECT c.conversation_id, c.title, m.message_id, m.content
FROM conversations c
JOIN messages m ON m.conversation_id = c.conversation_id
WHERE c.conversation_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa6';



BEGIN;

DELETE FROM attachments
WHERE attachment_id = 'cccccccc-cccc-cccc-cccc-ccccccccccc6';

SELECT COUNT(*) AS attachments_during_tx
FROM attachments
WHERE attachment_id = 'cccccccc-cccc-cccc-cccc-ccccccccccc6';

ROLLBACK;

SELECT attachment_id, file_name
FROM attachments
WHERE attachment_id = 'cccccccc-cccc-cccc-cccc-ccccccccccc6';

SELECT attachment_id, file_name
FROM attachments
WHERE attachment_id = 'cccccccc-cccc-cccc-cccc-ccccccccccc6';

DELETE FROM attachments
WHERE attachment_id = 'cccccccc-cccc-cccc-cccc-ccccccccccc6';

SELECT attachment_id, file_name
FROM attachments
WHERE attachment_id = 'cccccccc-cccc-cccc-cccc-ccccccccccc6';

DELETE FROM messages
WHERE message_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb7';

SELECT message_id
FROM messages
WHERE message_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb7';

DELETE FROM conversation_participants
WHERE conversation_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2'
  AND user_id = '66666666-6666-6666-6666-666666666666';


DELETE FROM conversations
WHERE conversation_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa6';


DELETE FROM users
WHERE user_id = '66666666-6666-6666-6666-666666666666';


SELECT 'users' AS table_name, COUNT(*) AS row_count FROM users
UNION ALL
SELECT 'conversations', COUNT(*) FROM conversations
UNION ALL
SELECT 'conversation_participants', COUNT(*) FROM conversation_participants
UNION ALL
SELECT 'messages', COUNT(*) FROM messages
UNION ALL
SELECT 'attachments', COUNT(*) FROM attachments
ORDER BY table_name;
