-- Середня тривалість треку серед усіх треків певного виконавця

DELETE FROM artists WHERE artist_name = 'Artist Without Tracks';
INSERT INTO artists (artist_user_id, artist_name) VALUES (3, 'Artist Without Tracks');

SELECT
	a.artist_name,
	COALESCE(AVG(t.track_duration_milliseconds), 0) as average_duration_ms
FROM artists AS a
LEFT JOIN tracks AS t
	ON t.track_artist_id = a.artist_id
GROUP BY a.artist_id, a.artist_name;

-- Кількість треків у кожному існуючому плейлісті

SELECT
    p.playlist_name,
    u.user_email AS owner_email,
    COUNT(pt.track_id) AS tracks_count
FROM playlists AS p
JOIN users AS u
    ON u.user_id = p.playlist_user_id
LEFT JOIN playlist_tracks AS pt
    ON pt.playlist_id = p.playlist_id
GROUP BY
    p.playlist_id,
    p.playlist_name,
    u.user_email
ORDER BY tracks_count DESC;

-- Загальна тривалість кожного існуючого плейліста

DELETE FROM playlists WHERE playlist_name = 'Empty playlist';
INSERT INTO playlists (playlist_user_id, playlist_name) VALUES (1, 'Empty playlist');

SELECT
	p.playlist_name,
	u.user_email AS owner_email,
	COALESCE(SUM(t.track_duration_milliseconds), 0) AS total_duration_ms
FROM playlists AS p
JOIN users AS u
	ON p.playlist_user_id = u.user_id
LEFT JOIN playlist_tracks AS pt
	ON p.playlist_id = pt.playlist_id
LEFT JOIN tracks AS t
	ON t.track_id = pt.track_id
GROUP BY
	p.playlist_id,
	p.playlist_name,
	u.user_email
ORDER BY total_duration_ms DESC;

-- Максимальна тривалість треку серед усіх треків

SELECT
    a.artist_name,
    t.track_name,
    t.track_duration_milliseconds
FROM tracks AS t
JOIN artists AS a
    ON t.track_artist_id = a.artist_id
WHERE t.track_duration_milliseconds = (
    SELECT MAX(t2.track_duration_milliseconds)
    FROM tracks AS t2
);

-- Кількість треків кожного виконавця (підзапит)

SELECT
	a.artist_name,
	(
		SELECT COUNT(t.track_id) FROM tracks AS t WHERE t.track_artist_id = a.artist_id
	) AS existing_track_count
FROM artists AS a
ORDER BY existing_track_count DESC;

-- Виконавці, кількість треків яких більша за середню кількість треків серед усіх виконавців

SELECT
	a.artist_name,
	COUNT(t.track_id) AS existing_track_count
FROM artists AS a
LEFT JOIN tracks AS t
	ON t.track_artist_id = a.artist_id
GROUP BY
	a.artist_id,
	a.artist_name
HAVING COUNT(t.track_id) > (
	SELECT AVG(track_count) FROM (
		SELECT COUNT(t2.track_id) AS track_count
		FROM tracks AS t2
		GROUP BY t2.track_artist_id
	)
);