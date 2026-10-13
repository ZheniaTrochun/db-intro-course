DROP TABLE IF EXISTS
    playlist_tracks,
    track_features,
    artist_monthly_stats,
    playlists,
    tracks,
    albums,
    artists,
    users;

DROP TYPE IF EXISTS PLAYLIST_VIEW_ENUM;

CREATE TABLE users (
    user_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_email VARCHAR(100) NOT NULL UNIQUE
		CHECK (user_email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'),
    user_password_hash VARCHAR(100) NOT NULL
		CHECK (btrim(user_password_hash) <> ''),
    registered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE artists (
    artist_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    artist_user_id BIGINT NOT NULL UNIQUE REFERENCES users(user_id) ON DELETE CASCADE,
    artist_name VARCHAR(100) NOT NULL
		CHECK (btrim(artist_name) <> ''),
    artist_bio VARCHAR(500)
);

CREATE TABLE albums (
    album_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    album_artist_id BIGINT NOT NULL REFERENCES artists(artist_id) ON DELETE CASCADE,
    album_name VARCHAR(100) NOT NULL
        CHECK (btrim(album_name) <> ''),
    released_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tracks (
    track_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    track_artist_id BIGINT NOT NULL REFERENCES artists(artist_id) ON DELETE CASCADE,
    track_album_id BIGINT REFERENCES albums(album_id) ON DELETE SET NULL,
    track_name VARCHAR(100) NOT NULL
        CHECK (btrim(track_name) <> ''),
    track_duration_milliseconds INTEGER NOT NULL
        CHECK (track_duration_milliseconds >= 1 AND track_duration_milliseconds <= 900000),
    track_audio_url VARCHAR(100) NOT NULL UNIQUE
		CHECK (btrim(track_audio_url) <> ''),
    released_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TYPE PLAYLIST_VIEW_ENUM AS ENUM (
    'private',
    'public'
);

CREATE TABLE playlists (
    playlist_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    playlist_user_id BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    playlist_name VARCHAR(100) NOT NULL
        CHECK (btrim(playlist_name) <> '') DEFAULT 'New Playlist',
    playlist_view PLAYLIST_VIEW_ENUM NOT NULL DEFAULT 'private',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE artist_monthly_stats (
    stats_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    stats_artist_id BIGINT NOT NULL REFERENCES artists(artist_id) ON DELETE CASCADE,
    stats_month DATE NOT NULL
		CHECK (EXTRACT(DAY FROM stats_month) = 1),
    stats_play_count INTEGER NOT NULL
		CHECK (stats_play_count >= 0)
);

CREATE TABLE track_features (
	artist_id BIGINT NOT NULL REFERENCES artists(artist_id) ON DELETE CASCADE,
	track_id BIGINT NOT NULL REFERENCES tracks(track_id) ON DELETE CASCADE,
	PRIMARY KEY (artist_id, track_id)
);

CREATE TABLE playlist_tracks (
	playlist_id BIGINT NOT NULL REFERENCES playlists(playlist_id) ON DELETE CASCADE,
	track_id BIGINT NOT NULL REFERENCES tracks(track_id) ON DELETE CASCADE,
	track_position INTEGER NOT NULL
		CHECK (track_position >= 1),
	added_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (playlist_id, track_id)
);

INSERT INTO users (user_email, user_password_hash) VALUES
	('abc123@gmail.com',        'Ag^h%$j8kh8G7G%23hg*3tn'),
	('random_email2@gmail.com', 'j^7H^gL*KbGgO-&56vRGjlk'),
	('any_email3@gmail.com',    'AJG79uihF&%^^TF&E%ivm37');

INSERT INTO artists (artist_user_id, artist_name) VALUES
	(1, 'Eminem'),
	(2, 'Rihanna');

INSERT INTO tracks (track_artist_id, track_album_id, track_name, track_duration_milliseconds, track_audio_url) VALUES
	(1, NULL, 'Not Afraid', 	      248000, 'audio/1.mp3'),
	(1, NULL, 'Superman', 		      350000, 'audio/2.mp3'),
	(1, NULL, 'Sing For The Moment',  339000, 'audio/3.mp3'),
	(1, NULL, 'Without Me', 		  290000, 'audio/4.mp3'),
	(1, NULL, 'Lose Yourself', 	      326000, 'audio/5.mp3'),
	(1, NULL, 'Rap God', 	          364000, 'audio/6.mp3'),
	(1, NULL, 'The Monster', 	      250000, 'audio/7.mp3'),
	(1, NULL, 'Love The Way You Lie', 263000, 'audio/8.mp3'),
	(2, NULL, 'Diamonds', 			  225000, 'audio/9.mp3'),
	(2, NULL, 'Umbrella', 			  255000, 'audio/10.mp3'),
	(2, NULL, 'Numb', 				  205000, 'audio/11.mp3');

WITH new_album AS (
	INSERT INTO albums (album_artist_id, album_name) VALUES (1, 'Recovery')
	RETURNING album_id
)
UPDATE tracks
SET track_album_id = new_album.album_id
FROM new_album
WHERE track_id IN (1, 8);

WITH new_album AS (
	INSERT INTO albums (album_artist_id, album_name) VALUES (1, 'The Eminem Show')
	RETURNING album_id
)
UPDATE tracks
SET track_album_id = new_album.album_id
FROM new_album
WHERE track_id IN (2, 3, 4);

WITH new_album AS (
	INSERT INTO albums (album_artist_id, album_name) VALUES (1, 'Unapologetic')
	RETURNING album_id
)
UPDATE tracks
SET track_album_id = new_album.album_id
FROM new_album
WHERE track_id IN (9, 10, 11);

INSERT INTO track_features (artist_id, track_id) VALUES
	(2, 7),
	(2, 8),
	(1, 11);

INSERT INTO artist_monthly_stats (stats_artist_id, stats_month, stats_play_count) VALUES
	(1, '2026-01-01', 73674520),
	(1, '2026-02-01', 75865947),
	(1, '2026-03-01', 71953102),
	(2, '2026-01-01', 116654654),
	(2, '2026-02-01', 110987653),
	(2, '2026-03-01', 117125687);

INSERT INTO playlists (playlist_user_id, playlist_name, playlist_view) VALUES
	(3, 'Eminem singles', 'private');

INSERT INTO playlist_tracks (playlist_id, track_id, track_position) VALUES
	(1, 5, 1),
	(1, 6, 2),
	(1, 7, 3);


SELECT * FROM users;
SELECT * FROM artists;
SELECT * FROM tracks;
SELECT * FROM albums;
SELECT * FROM playlists;
SELECT * FROM track_features;
SELECT * FROM playlist_tracks;
SELECT * FROM artist_monthly_stats;

SELECT *
FROM albums AS a
JOIN tracks AS t
	ON a.album_id = t.track_album_id
WHERE a.album_id = 2;

SELECT *
FROM playlist_tracks AS pt
JOIN tracks AS t
	ON pt.track_id = t.track_id
WHERE pt.playlist_id = 1;