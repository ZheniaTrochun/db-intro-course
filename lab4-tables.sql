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
    user_password_hash VARCHAR(100) NOT NULL,
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
    track_audio_url VARCHAR(100) NOT NULL UNIQUE,
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
    stats_artist_id BIGINT NOT NULL REFERENCES artists(artist_id) ON DELETE CASCADE,
    stats_month DATE NOT NULL
		CHECK (EXTRACT(DAY FROM stats_month) = 1),
    stats_play_count INTEGER NOT NULL
		CHECK (stats_play_count >= 0),

	PRIMARY KEY (stats_artist_id, stats_month)
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
	PRIMARY KEY (playlist_id, track_id),

	CONSTRAINT unique_track_position UNIQUE(playlist_id, track_position) DEFERRABLE INITIALLY DEFERRED
);