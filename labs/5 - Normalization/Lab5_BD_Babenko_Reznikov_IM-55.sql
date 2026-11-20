DROP TABLE IF EXISTS collection_poem CASCADE;
DROP TABLE IF EXISTS poem_author CASCADE;
DROP TABLE IF EXISTS review CASCADE;

DROP TABLE IF EXISTS collection CASCADE;
DROP TABLE IF EXISTS poem CASCADE;
DROP TABLE IF EXISTS person CASCADE;

DROP TYPE IF EXISTS poem_status CASCADE;
DROP TYPE IF EXISTS visibility_status CASCADE;

CREATE TYPE poem_status AS ENUM (
    'published',
    'notes',
    'reviewed'
);

CREATE TYPE visibility_status AS ENUM (
    'public',
    'private',
    'deleted'
);

CREATE TABLE person (
    person_id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    username varchar(35) NOT NULL UNIQUE,

    email varchar(45) NOT NULL UNIQUE,

    password_hash varchar(255) NOT NULL,

    registered_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE poem (
    poem_id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    owner_id int NOT NULL 
        REFERENCES person(person_id) 
        ON DELETE CASCADE,

    title varchar(50) NOT NULL
        CHECK (length(trim(title)) > 0),

    content_poem text NOT NULL
        CHECK (length(trim(content_poem)) >= 1),

    poem_status poem_status NOT NULL DEFAULT 'notes',

    published_at timestamp,

    CONSTRAINT chk_status_date CHECK (
        (poem_status = 'published' AND published_at IS NOT NULL) OR
        (poem_status != 'published' AND published_at IS NULL)
    )
);

CREATE TABLE collection (
    collection_id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    person_id int NOT NULL
        REFERENCES person(person_id)
        ON DELETE CASCADE,

    title varchar(50) NOT NULL,

    visibility_status visibility_status NOT NULL DEFAULT 'public',

    created_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE review (
    user_id int NOT NULL,

    poem_id int NOT NULL,

    rating int NOT NULL
        CHECK (rating BETWEEN 1 AND 5),

    comment text,

    updated_at timestamp NOT NULL DEFAULT now(),

    PRIMARY KEY (user_id, poem_id),

    FOREIGN KEY (user_id)
        REFERENCES person(person_id)
        ON DELETE CASCADE,

    FOREIGN KEY (poem_id)
        REFERENCES poem(poem_id)
        ON DELETE CASCADE
);

CREATE TABLE poem_author (
    user_id int NOT NULL,

    poem_id int NOT NULL,

    contribution_type varchar(50) NOT NULL,

    PRIMARY KEY (user_id, poem_id),

    FOREIGN KEY (user_id)
        REFERENCES person(person_id)
        ON DELETE CASCADE,

    FOREIGN KEY (poem_id)
        REFERENCES poem(poem_id)
        ON DELETE CASCADE
);
 CREATE TABLE collection_poem (
    collection_id int NOT NULL,

    poem_id int NOT NULL,

    added_at timestamp NOT NULL DEFAULT now(),

    PRIMARY KEY (collection_id, poem_id),

    FOREIGN KEY (collection_id)
        REFERENCES collection(collection_id)
        ON DELETE CASCADE,

    FOREIGN KEY (poem_id)
        REFERENCES poem(poem_id)
        ON DELETE CASCADE
);


CREATE OR REPLACE FUNCTION prevent_self_review()
RETURNS TRIGGER AS $$
BEGIN

    IF EXISTS (
        SELECT 1
        FROM poem
        WHERE poem_id = NEW.poem_id
          AND owner_id = NEW.user_id
    )
    OR EXISTS (
        SELECT 1
        FROM poem_author
        WHERE user_id = NEW.user_id
          AND poem_id = NEW.poem_id
    ) THEN

        RAISE EXCEPTION
            'User % cannot review their own poem %',
            NEW.user_id,
            NEW.poem_id;

    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_prevent_self_review
BEFORE INSERT OR UPDATE ON review
FOR EACH ROW
EXECUTE FUNCTION prevent_self_review();