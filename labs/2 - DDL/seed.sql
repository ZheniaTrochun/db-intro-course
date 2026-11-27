INSERT INTO users (user_id, name, username, email, created_at) VALUES
    ('11111111-1111-1111-1111-111111111111', 'Олена Коваленко',    'olena_kov', 'olena@example.com',    '2026-09-01 10:00:00+03'),
    ('22222222-2222-2222-2222-222222222222', 'Євгеній Ковальчук',  'staljerst', 'yevhenii@example.com', '2026-09-01 10:15:00+03'),
    ('33333333-3333-3333-3333-333333333333', 'Максим Шевченко',    'max_sheva', 'maksym@example.com',   '2026-09-02 09:30:00+03'),
    ('44444444-4444-4444-4444-444444444444', 'Ірина Мельник',      'iryna_m',   'iryna@example.com',    '2026-09-03 14:20:00+03'),
    ('55555555-5555-5555-5555-555555555555', 'Дмитро Бондар',      'dmytro_b',  'dmytro@example.com',   '2026-09-04 18:05:00+03');

INSERT INTO conversations (conversation_id, title, type) VALUES
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', NULL,                        'direct'),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'Група ІМ-51: Бази даних',   'group'),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'Команда проєкту',           'group'),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', NULL,                        'direct'),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 'Підготовка до контрольної', 'group');

INSERT INTO conversation_participants (conversation_id, user_id, role, joined_at) VALUES
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', '11111111-1111-1111-1111-111111111111', 'member', '2026-09-05 11:00:00+03'),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', '22222222-2222-2222-2222-222222222222', 'member', '2026-09-05 11:00:00+03'),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', '22222222-2222-2222-2222-222222222222', 'owner',  '2026-09-05 12:00:00+03'),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', '11111111-1111-1111-1111-111111111111', 'admin',  '2026-09-05 12:05:00+03'),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', '33333333-3333-3333-3333-333333333333', 'member', '2026-09-05 12:10:00+03'),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', '33333333-3333-3333-3333-333333333333', 'owner',  '2026-09-06 09:00:00+03'),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', '44444444-4444-4444-4444-444444444444', 'member', '2026-09-06 09:15:00+03'),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', '44444444-4444-4444-4444-444444444444', 'member', '2026-09-07 16:00:00+03'),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', '55555555-5555-5555-5555-555555555555', 'member', '2026-09-07 16:00:00+03'),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', '11111111-1111-1111-1111-111111111111', 'owner',  '2026-09-08 10:30:00+03'),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', '55555555-5555-5555-5555-555555555555', 'member', '2026-09-08 10:45:00+03');

INSERT INTO messages (message_id, conversation_id, sender_id, content, sent_at) VALUES
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', '11111111-1111-1111-1111-111111111111', 'Привіт! Ти вже підготував ER-діаграму?',                     '2026-09-05 11:02:00+03'),
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', '22222222-2222-2222-2222-222222222222', 'Так, щойно залив схему, ось прев’ю.',                       '2026-09-05 11:05:00+03'),
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb3', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', '22222222-2222-2222-2222-222222222222', 'Скидаю SQL-скрипти для другої лабораторної.',               '2026-09-05 12:30:00+03'),
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb4', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', '33333333-3333-3333-3333-333333333333', 'Дякую, перевірив у pgAdmin — усе працює!',                  '2026-09-05 12:40:00+03'),
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb5', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', '44444444-4444-4444-4444-444444444444', NULL,                                                        '2026-09-06 09:20:00+03'),
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb6', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', '55555555-5555-5555-5555-555555555555', 'Зібрав конспект по нормалізації та індексах.',              '2026-09-08 11:00:00+03');

INSERT INTO attachments (attachment_id, message_id, file_name, mime_type, size_bytes, storage_key) VALUES
    ('cccccccc-cccc-cccc-cccc-ccccccccccc1', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2', 'er_diagram.png',    'image/png',                                                               245760,  'uploads/2026/09/er_diagram_01.png'),
    ('cccccccc-cccc-cccc-cccc-ccccccccccc2', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb3', 'schema.sql',        'application/sql',                                                         4096,    'uploads/2026/09/schema_02.sql'),
    ('cccccccc-cccc-cccc-cccc-ccccccccccc3', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb3', 'seed.sql',          'application/sql',                                                         6144,    'uploads/2026/09/seed_03.sql'),
    ('cccccccc-cccc-cccc-cccc-ccccccccccc4', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb5', 'project_specs.pdf', 'application/pdf',                                                         1048576, 'uploads/2026/09/project_specs_04.pdf'),
    ('cccccccc-cccc-cccc-cccc-ccccccccccc5', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb6', 'db_notes.docx',     'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 524288,  'uploads/2026/09/db_notes_05.docx');


SELECT * FROM users;
SELECT * FROM conversations;
SELECT * FROM conversation_participants;
SELECT * FROM messages;
SELECT * FROM attachments;

SELECT
    c.type AS conversation_type,
    COALESCE(c.title, '(Особистий чат)') AS conversation_title,
    u.username AS sender,
    m.content,
    a.file_name,
    a.size_bytes,
    m.sent_at
FROM messages m
JOIN conversations c ON c.conversation_id = m.conversation_id
JOIN users u ON u.user_id = m.sender_id
LEFT JOIN attachments a ON a.message_id = m.message_id
ORDER BY m.sent_at;
