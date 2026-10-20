-- ============================================
-- Seed data for VideoHub (Lab 6 — Prisma)
-- ============================================

-- 1. Користувачі (5 рядків)
INSERT INTO "User" (id, email, username, password, google_id, avatar, banner, description) VALUES
    ('a1b2c3d4-0001-0000-0000-000000000001', 'denys@example.com', 'denys_dev', 'hashed_pass_1', NULL, 'https://cdn.videohub.com/avatars/denys.png', 'https://cdn.videohub.com/banners/denys.png', 'Full-stack developer. Uploading coding tutorials.'),
    ('a1b2c3d4-0002-0000-0000-000000000002', 'maria@example.com', 'maria_gaming', 'hashed_pass_2', NULL, 'https://cdn.videohub.com/avatars/maria.png', NULL, 'Gaming streamer. Love RPGs and indie games.'),
    ('a1b2c3d4-0003-0000-0000-000000000003', 'oleg@example.com', 'oleg_cook', NULL, 'google_oauth_id_3', 'https://cdn.videohub.com/avatars/oleg.png', 'https://cdn.videohub.com/banners/oleg.png', 'Chef sharing recipes and cooking tips.'),
    ('a1b2c3d4-0004-0000-0000-000000000004', 'anna@example.com', 'anna_travel', 'hashed_pass_4', NULL, NULL, NULL, 'Traveling the world, one video at a time.'),
    ('a1b2c3d4-0005-0000-0000-000000000005', 'max@example.com', 'max_music', NULL, 'google_oauth_id_5', 'https://cdn.videohub.com/avatars/max.png', 'https://cdn.videohub.com/banners/max.png', 'Musician. Covers, original songs, and tutorials.')
ON CONFLICT DO NOTHING;

-- 2. Відео (5 рядків)
INSERT INTO "Video" (id, title, description, url, thumbnail, views, author_id) VALUES
    ('b2c3d4e5-0001-0000-0000-000000000001', 'PostgreSQL Tutorial for Beginners', 'Learn the basics of PostgreSQL in 30 minutes.', 'https://cdn.videohub.com/videos/vid1.mp4', 'https://cdn.videohub.com/thumbs/vid1.jpg', 15420, 'a1b2c3d4-0001-0000-0000-000000000001'),
    ('b2c3d4e5-0002-0000-0000-000000000002', 'Elden Ring — Final Boss Fight', 'Epic battle against the final boss.', 'https://cdn.videohub.com/videos/vid2.mp4', 'https://cdn.videohub.com/thumbs/vid2.jpg', 89300, 'a1b2c3d4-0002-0000-0000-000000000002'),
    ('b2c3d4e5-0003-0000-0000-000000000003', 'How to Make Perfect Pasta Carbonara', 'Simple and delicious Italian recipe.', 'https://cdn.videohub.com/videos/vid3.mp4', 'https://cdn.videohub.com/thumbs/vid3.jpg', 5230, 'a1b2c3d4-0003-0000-0000-000000000003'),
    ('b2c3d4e5-0004-0000-0000-000000000004', 'Exploring Tokyo — Shibuya at Night', 'Walking through the neon streets of Shibuya.', 'https://cdn.videohub.com/videos/vid4.mp4', 'https://cdn.videohub.com/thumbs/vid4.jpg', 32100, 'a1b2c3d4-0004-0000-0000-000000000004'),
    ('b2c3d4e5-0005-0000-0000-000000000005', 'Acoustic Guitar Cover — Wonderwall', 'My acoustic cover of Oasis Wonderwall.', 'https://cdn.videohub.com/videos/vid5.mp4', 'https://cdn.videohub.com/thumbs/vid5.jpg', 12750, 'a1b2c3d4-0005-0000-0000-000000000005')
ON CONFLICT DO NOTHING;

-- 3. Коментарі (5 рядків)
INSERT INTO "Comment" (id, text, user_id, video_id) VALUES
    ('c3d4e5f6-0001-0000-0000-000000000001', 'Great tutorial, finally understood JOINs!', 'a1b2c3d4-0002-0000-0000-000000000002', 'b2c3d4e5-0001-0000-0000-000000000001'),
    ('c3d4e5f6-0002-0000-0000-000000000002', 'That boss fight was insane!', 'a1b2c3d4-0001-0000-0000-000000000001', 'b2c3d4e5-0002-0000-0000-000000000002'),
    ('c3d4e5f6-0003-0000-0000-000000000003', 'Tried this recipe, turned out amazing!', 'a1b2c3d4-0004-0000-0000-000000000004', 'b2c3d4e5-0003-0000-0000-000000000003'),
    ('c3d4e5f6-0004-0000-0000-000000000004', 'Tokyo is on my bucket list now.', 'a1b2c3d4-0005-0000-0000-000000000005', 'b2c3d4e5-0004-0000-0000-000000000004'),
    ('c3d4e5f6-0005-0000-0000-000000000005', 'Best cover of this song I have heard.', 'a1b2c3d4-0003-0000-0000-000000000003', 'b2c3d4e5-0005-0000-0000-000000000005')
ON CONFLICT DO NOTHING;

-- 4. Лайки (5 рядків)
INSERT INTO "Like" (id, user_id, video_id) VALUES
    ('d4e5f6a7-0001-0000-0000-000000000001', 'a1b2c3d4-0002-0000-0000-000000000002', 'b2c3d4e5-0001-0000-0000-000000000001'),
    ('d4e5f6a7-0002-0000-0000-000000000002', 'a1b2c3d4-0001-0000-0000-000000000001', 'b2c3d4e5-0002-0000-0000-000000000002'),
    ('d4e5f6a7-0003-0000-0000-000000000003', 'a1b2c3d4-0004-0000-0000-000000000004', 'b2c3d4e5-0003-0000-0000-000000000003'),
    ('d4e5f6a7-0004-0000-0000-000000000004', 'a1b2c3d4-0005-0000-0000-000000000005', 'b2c3d4e5-0004-0000-0000-000000000004'),
    ('d4e5f6a7-0005-0000-0000-000000000005', 'a1b2c3d4-0003-0000-0000-000000000003', 'b2c3d4e5-0005-0000-0000-000000000005')
ON CONFLICT DO NOTHING;

-- 5. Підписки (5 рядків) — УВАГА: subscribed_to_id замість channel_id
INSERT INTO "Subscription" (id, subscriber_id, subscribed_to_id) VALUES
    ('e5f6a7b8-0001-0000-0000-000000000001', 'a1b2c3d4-0002-0000-0000-000000000002', 'a1b2c3d4-0001-0000-0000-000000000001'),
    ('e5f6a7b8-0002-0000-0000-000000000002', 'a1b2c3d4-0001-0000-0000-000000000001', 'a1b2c3d4-0002-0000-0000-000000000002'),
    ('e5f6a7b8-0003-0000-0000-000000000003', 'a1b2c3d4-0004-0000-0000-000000000004', 'a1b2c3d4-0003-0000-0000-000000000003'),
    ('e5f6a7b8-0004-0000-0000-000000000004', 'a1b2c3d4-0005-0000-0000-000000000005', 'a1b2c3d4-0004-0000-0000-000000000004'),
    ('e5f6a7b8-0005-0000-0000-000000000005', 'a1b2c3d4-0003-0000-0000-000000000003', 'a1b2c3d4-0005-0000-0000-000000000005')
ON CONFLICT DO NOTHING;
