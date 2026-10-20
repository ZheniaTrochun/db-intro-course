-- test: перевіряю cascade на копії юзера перед delete в основних даних
INSERT INTO "User" (id, email, username, password)
VALUES ('f7a8b9c0-0001-0000-0000-000000000001', 'test@test.com', 'test_user', 'pass');

INSERT INTO "Video" (title, url, author_id)
VALUES ('test video', 'https://cdn.videohub.com/videos/test.mp4',
        (SELECT id FROM "User" WHERE username = 'test_user'));

-- має видалити і відео разом з юзером
DELETE FROM "User" WHERE username = 'test_user';

SELECT * FROM "Video" WHERE title = 'test video';
