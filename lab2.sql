DROP TABLE IF EXISTS MediaCharacters CASCADE;
DROP TABLE IF EXISTS MediaStaff CASCADE;
DROP TABLE IF EXISTS MediaStudio CASCADE;
DROP TABLE IF EXISTS MediaGenre CASCADE;
DROP TABLE IF EXISTS UserMediaStats CASCADE;
DROP TABLE IF EXISTS Characters CASCADE;
DROP TABLE IF EXISTS Person CASCADE;
DROP TABLE IF EXISTS Studio CASCADE;
DROP TABLE IF EXISTS Genre CASCADE;
DROP TABLE IF EXISTS UserData CASCADE;
DROP TABLE IF EXISTS MediaItem CASCADE;

-- Створюємо батьківські таблиці

CREATE TABLE Genre (
    genre_id SERIAL PRIMARY KEY,
    genre_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Studio (
    studio_id SERIAL PRIMARY KEY,
    studio_name VARCHAR(50) NOT NULL UNIQUE,
    establishment_date DATE
);

CREATE TABLE Person (
    person_id SERIAL PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    biography TEXT
);

CREATE TABLE Characters (
    character_id SERIAL PRIMARY KEY,
    character_name VARCHAR(50) NOT NULL,
    character_description TEXT
);

CREATE TABLE UserData (
    user_id SERIAL PRIMARY KEY,
    user_name VARCHAR(50) NOT NULL UNIQUE,
    user_description TEXT DEFAULT 'No bio provided'
);

CREATE TABLE MediaItem (
    title_id SERIAL PRIMARY KEY,
    title_name VARCHAR(200) NOT NULL,
    type VARCHAR(30) NOT NULL CHECK (type IN ('TV', 'Movie', 'OVA', 'ONA', 'Manga', 'Light Novel')),
    release_date DATE,
    status VARCHAR(30) NOT NULL DEFAULT 'Ongoing' CHECK (status IN ('Finished', 'Ongoing', 'Announced')),
    score NUMERIC(4, 2) CHECK (score >= 0 AND score <= 10),
    synopsis TEXT
);

-- Створюємо зв'язуючі таблиці

CREATE TABLE MediaGenre (
    title_id INTEGER NOT NULL REFERENCES MediaItem(title_id) ON DELETE CASCADE,
    genre_id INTEGER NOT NULL REFERENCES Genre(genre_id) ON DELETE CASCADE,
    PRIMARY KEY (title_id, genre_id)
);

CREATE TABLE MediaStudio (
    title_id INTEGER NOT NULL REFERENCES MediaItem(title_id) ON DELETE CASCADE,
    studio_id INTEGER NOT NULL REFERENCES Studio(studio_id) ON DELETE CASCADE,
    PRIMARY KEY (title_id, studio_id)
);

CREATE TABLE MediaStaff (
    title_id INTEGER NOT NULL REFERENCES MediaItem(title_id) ON DELETE CASCADE,
    person_id INTEGER NOT NULL REFERENCES Person(person_id) ON DELETE CASCADE,
    role VARCHAR(100) NOT NULL,
    PRIMARY KEY (title_id, person_id, role)
);

CREATE TABLE MediaCharacters (
    title_id INTEGER NOT NULL REFERENCES MediaItem(title_id) ON DELETE CASCADE,
    character_id INTEGER NOT NULL REFERENCES Characters(character_id) ON DELETE CASCADE,
    person_id INTEGER NOT NULL REFERENCES Person(person_id) ON DELETE CASCADE,
    PRIMARY KEY (title_id, character_id, person_id)
);

CREATE TABLE UserMediaStats (
    user_id INTEGER NOT NULL REFERENCES UserData(user_id) ON DELETE CASCADE,
    title_id INTEGER NOT NULL REFERENCES MediaItem(title_id) ON DELETE CASCADE,
    user_score INTEGER CHECK (user_score >= 1 AND user_score <= 10),
    user_status VARCHAR(30) NOT NULL DEFAULT 'Plan to Watch' 
        CHECK (user_status IN ('Watching', 'Completed', 'On-Hold', 'Dropped', 'Plan to Watch')),
    PRIMARY KEY (user_id, title_id)
);

-- Заповнюємо таблиці тестовими даними

INSERT INTO Genre (genre_id, genre_name) VALUES
    (1, 'Action'),
    (2, 'Psychological'),
    (3, 'Mystery'),
    (4, 'Sci-Fi'),
    (5, 'Supernatural');

INSERT INTO Studio (studio_id, studio_name, establishment_date) VALUES
    (1, 'AIC ASTA', '2003-01-01'),
    (2, 'White Fox', '2007-04-01'),
    (3, 'WIT Studio', '2012-06-01'),
    (4, 'MAPPA', '2011-06-14'),
    (5, 'Bones', '1998-10-01');

INSERT INTO Person (person_id, full_name, birth_date, biography) VALUES
    (1, 'Seiji Kishi', '1969-09-03', 'Japanese anime director known for Persona 4 The Animation and Angel Beats.'),
    (2, 'Shoji Meguro', '1971-06-04', 'Japanese composer and sound director famous for the Persona series soundtrack.'),
    (3, 'Daisuke Namikawa', '1976-04-02', 'Prolific Japanese voice actor who voiced Yu Narukami.'),
    (4, 'Mamoru Miyano', '1983-06-08', 'Japanese voice actor and singer known for voicing Rintaro Okabe and Light Yagami.'),
    (5, 'Tetsuro Araki', '1976-11-05', 'Japanese anime director best known for Attack on Titan and Death Note.');

INSERT INTO Characters (character_id, character_name, character_description) VALUES
    (1, 'Yu Narukami', 'Calm and collected transfer student who moves to Inaba for a year.'),
    (2, 'Rintaro Okabe', 'Self-proclaimed mad scientist Kyoma Hououin and founder of the Future Gadget Lab.'),
    (3, 'Eren Yeager', 'Protagonist who vows to cleanse the earth of giant humanoid Titans.'),
    (4, 'Shigeo Kageyama', 'Middle school boy nicknamed Mob with immense psychic powers.'),
    (5, 'Denji', 'Young man merged with the Chainsaw Devil Pochita.');

INSERT INTO UserData (user_id, user_name, user_description) VALUES
    (1, 'narukami_enjoyer', 'Persona 4 Golden and rhythm games fan.'),
    (2, 'mania_masher', '7K mania player and sci-fi anime enthusiast.'),
    (3, 'kyiv_dev', 'Software engineering student watching seasonal titles.'),
    (4, 'retro_cam', '2000s aesthetic lover and psychological thriller critic.'),
    (5, 'manga_reader', 'Mostly reading manga, rarely watching TV adaptations.');

INSERT INTO MediaItem (title_id, title_name, type, release_date, status, score, synopsis) VALUES
    (1, 'Persona 4 the Animation', 'TV', '2011-10-07', 'Finished', 7.64, 'Yu Narukami moves to the rural town of Inaba, where a mysterious serial murder case begins alongside rumors of the Midnight Channel.'),
    (2, 'Steins;Gate', 'TV', '2011-04-06', 'Finished', 9.07, 'Eccentric scientist Rintaro Okabe and his friends accidentally invent a microwave that can send text messages into the past.'),
    (3, 'Shingeki no Kyojin', 'TV', '2013-04-07', 'Finished', 8.55, 'Centuries ago, mankind was slaughtered to near extinction by monstrous humanoid creatures called Titans.'),
    (4, 'Mob Psycho 100', 'TV', '2016-07-11', 'Finished', 8.49, 'Eighth-grader Shigeo "Mob" Kageyama has tapped into his inner wellspring of psychic prowess at a young age.'),
    (5, 'Chainsaw Man', 'TV', '2022-10-12', 'Finished', 8.47, 'Denji is robbed of a normal teenage life, left with nothing but his deadbeat father''s overwhelming debt.');

INSERT INTO MediaGenre (title_id, genre_id) VALUES
    (1, 3), -- Persona 4 -> Mystery
    (1, 5), -- Persona 4 -> Supernatural
    (2, 4), -- Steins;Gate -> Sci-Fi
    (2, 2), -- Steins;Gate -> Psychological
    (3, 1); -- Attack on Titan -> Action

INSERT INTO MediaStudio (title_id, studio_id) VALUES
    (1, 1), -- Persona 4 -> AIC ASTA
    (2, 2), -- Steins;Gate -> White Fox
    (3, 3), -- AoT -> WIT Studio
    (4, 5), -- Mob Psycho 100 -> Bones
    (5, 4); -- Chainsaw Man -> MAPPA

INSERT INTO MediaStaff (title_id, person_id, role) VALUES
    (1, 1, 'Director'),
    (1, 1, 'Storyboard Artist'),
    (1, 2, 'Theme Song Composition'),
    (1, 2, 'Original Music Composer'),
    (3, 5, 'Director');

INSERT INTO MediaCharacters (title_id, character_id, person_id) VALUES
    (1, 1, 3), -- Persona 4: Yu Narukami voiced by Daisuke Namikawa
    (2, 2, 4), -- Steins;Gate: Rintaro Okabe voiced by Mamoru Miyano
    (3, 3, 3), -- AoT: Guest/Alt voice example
    (4, 4, 3), -- Mob Psycho: Role connection
    (5, 5, 4); -- Chainsaw Man: Role connection

INSERT INTO UserMediaStats (user_id, title_id, user_score, user_status) VALUES
    (1, 1, 10, 'Completed'),
    (1, 2, 9, 'Completed'),
    (2, 2, 10, 'Completed'),
    (3, 5, 8, 'Watching'),
    (4, 3, NULL, 'Plan to Watch');
	