CREATE TABLE "user" (
    user_id UUID PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    registration_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE movie (
    movie_id UUID PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    release_year SMALLINT NOT NULL CHECK (release_year >= 1888),
    duration_minutes SMALLINT CHECK (duration_minutes > 0),
    synopsis TEXT,
    poster_url VARCHAR(512)
);

CREATE TABLE genre (
    genre_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE person (
    person_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL
);

CREATE TABLE rating (
    rating_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES "user"(user_id) ON DELETE CASCADE,
    movie_id UUID NOT NULL REFERENCES movie(movie_id) ON DELETE CASCADE,
    score SMALLINT NOT NULL CHECK (score BETWEEN 1 AND 10),
    rated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_user_movie_rating UNIQUE (user_id, movie_id)
);

CREATE TABLE user_movie_status (
    status_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES "user"(user_id) ON DELETE CASCADE,
    movie_id UUID NOT NULL REFERENCES movie(movie_id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL CHECK (status IN ('WATCH_LATER', 'WATCHED')),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_user_movie_status UNIQUE (user_id, movie_id)
);

CREATE TABLE movie_genre (
    movie_id UUID REFERENCES movie(movie_id) ON DELETE CASCADE,
    genre_id INT REFERENCES genre(genre_id) ON DELETE CASCADE,
    PRIMARY KEY (movie_id, genre_id)
);

CREATE TABLE movie_director (
    movie_id UUID REFERENCES movie(movie_id) ON DELETE CASCADE,
    person_id INT REFERENCES person(person_id) ON DELETE CASCADE,
    PRIMARY KEY (movie_id, person_id)
);

CREATE TABLE movie_actor (
    movie_id UUID REFERENCES movie(movie_id) ON DELETE CASCADE,
    person_id INT REFERENCES person(person_id) ON DELETE CASCADE,
    PRIMARY KEY (movie_id, person_id)
);


INSERT INTO "user" (user_id, username, email, password_hash) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'ivan_dev', 'ivan@example.com', '$2y$10$hashample1'),
('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'olena_k', 'olena@example.com', '$2y$10$hashample2'),
('c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a33', 'maksym_ua', 'maksym@example.com', '$2y$10$hashample3'),
('d3eebc99-9c0b-4ef8-bb6d-6bb9bd380a44', 'anna_movie', 'anna@example.com', '$2y$10$hashample4');

INSERT INTO movie (movie_id, title, release_year, duration_minutes, synopsis, poster_url) VALUES
('f47ac10b-58cc-4372-a567-0e02b2c3d479', 'Inception', 2010, 148, 'A thief who steals corporate secrets through the use of dream-sharing technology.', 'https://example.com/inception.jpg'),
('e23bc10b-58cc-4372-a567-0e02b2c3d480', 'Interstellar', 2014, 169, 'A team of explorers travel through a wormhole in space to ensure humanity survival.', 'https://example.com/interstellar.jpg'),
('c34dc10b-58cc-4372-a567-0e02b2c3d481', 'The Matrix', 1999, 136, 'A computer hacker learns from mysterious rebels about the true nature of his reality.', 'https://example.com/matrix.jpg'),
('d45ec10b-58cc-4372-a567-0e02b2c3d482', 'Parasite', 2019, 132, 'Greed and class discrimination threaten the newly formed symbiotic relationship between two families.', 'https://example.com/parasite.jpg');

INSERT INTO genre (name) VALUES
('Sci-Fi'),
('Action'),
('Drama'),
('Thriller');

INSERT INTO person (full_name) VALUES
('Christopher Nolan'),   -- 1
('Lana Wachowski'),     -- 2
('Bong Joon Ho'),       -- 3
('Leonardo DiCaprio'),  -- 4
('Keanu Reeves'),       -- 5
('Matthew McConaughey'),-- 6
('Song Kang-ho');       -- 7

INSERT INTO rating (user_id, movie_id, score) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'f47ac10b-58cc-4372-a567-0e02b2c3d479', 10),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'e23bc10b-58cc-4372-a567-0e02b2c3d480', 9),
('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'c34dc10b-58cc-4372-a567-0e02b2c3d481', 10),
('c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a33', 'd45ec10b-58cc-4372-a567-0e02b2c3d482', 8);

INSERT INTO user_movie_status (user_id, movie_id, status) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'd45ec10b-58cc-4372-a567-0e02b2c3d482', 'WATCH_LATER'),
('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'f47ac10b-58cc-4372-a567-0e02b2c3d479', 'WATCHED'),
('c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a33', 'e23bc10b-58cc-4372-a567-0e02b2c3d480', 'WATCH_LATER'),
('d3eebc99-9c0b-4ef8-bb6d-6bb9bd380a44', 'c34dc10b-58cc-4372-a567-0e02b2c3d481', 'WATCHED');

INSERT INTO movie_genre (movie_id, genre_id) VALUES
('f47ac10b-58cc-4372-a567-0e02b2c3d479', 1), -- Inception: Sci-Fi
('f47ac10b-58cc-4372-a567-0e02b2c3d479', 2), -- Inception: Action
('e23bc10b-58cc-4372-a567-0e02b2c3d480', 1), -- Interstellar: Sci-Fi
('c34dc10b-58cc-4372-a567-0e02b2c3d481', 1); -- The Matrix: Sci-Fi

INSERT INTO movie_director (movie_id, person_id) VALUES
('f47ac10b-58cc-4372-a567-0e02b2c3d479', 1), -- Christopher Nolan -> Inception
('e23bc10b-58cc-4372-a567-0e02b2c3d480', 1), -- Christopher Nolan -> Interstellar
('c34dc10b-58cc-4372-a567-0e02b2c3d481', 2), -- Lana Wachowski -> The Matrix
('d45ec10b-58cc-4372-a567-0e02b2c3d482', 3); -- Bong Joon Ho -> Parasite

INSERT INTO movie_actor (movie_id, person_id) VALUES
('f47ac10b-58cc-4372-a567-0e02b2c3d479', 4), -- Leonardo DiCaprio -> Inception
('c34dc10b-58cc-4372-a567-0e02b2c3d481', 5), -- Keanu Reeves -> The Matrix
('e23bc10b-58cc-4372-a567-0e02b2c3d480', 6), -- Matthew McConaughey -> Interstellar
('d45ec10b-58cc-4372-a567-0e02b2c3d482', 7); -- Song Kang-ho -> Parasite