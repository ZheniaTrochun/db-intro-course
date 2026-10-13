DROP TABLE IF EXISTS collection_poem CASCADE; 
DROP TABLE IF EXISTS poem_author CASCADE; 
DROP TABLE IF EXISTS review CASCADE; 
DROP TABLE IF EXISTS collection CASCADE; 
DROP TABLE IF EXISTS poem CASCADE; 
DROP TABLE IF EXISTS person CASCADE; 
 
DROP TYPE IF EXISTS poem_status CASCADE; 
DROP TYPE IF EXISTS visibility_status CASCADE; 
 
CREATE TYPE poem_status AS ENUM ('published', 'notes', 'reviewed'); 
CREATE TYPE visibility_status AS ENUM ('public', 'private', 'deleted'); 
 
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
    person_id int NOT NULL REFERENCES person(person_id) ON DELETE CASCADE, 
    title varchar(50) NOT NULL, 
    visibility_status visibility_status NOT NULL DEFAULT 'public', 
    created_at timestamp NOT NULL DEFAULT now() 
); 
 
CREATE TABLE review ( 
    user_id int NOT NULL REFERENCES person(person_id) ON DELETE CASCADE, 
    poem_id int NOT NULL REFERENCES poem(poem_id) ON DELETE CASCADE, 
    rating int NOT NULL CHECK (rating BETWEEN 1 AND 5), 
    comment text, 
    updated_at timestamp NOT NULL DEFAULT now(), 
    PRIMARY KEY (user_id, poem_id) 
); 
 
CREATE TABLE poem_author ( 
    user_id int NOT NULL REFERENCES person(person_id) ON DELETE CASCADE, 
    poem_id int NOT NULL REFERENCES poem(poem_id) ON DELETE CASCADE, 
    contribution_type varchar(50) NOT NULL, 
    PRIMARY KEY (user_id, poem_id) 
); 
 
CREATE TABLE collection_poem ( 
    collection_id int NOT NULL REFERENCES collection(collection_id) ON DELETE CASCADE, 
    poem_id int NOT NULL REFERENCES poem(poem_id) ON DELETE CASCADE, 
    added_at timestamp NOT NULL DEFAULT now(), 
    PRIMARY KEY (collection_id, poem_id) 
); 
 
CREATE OR REPLACE FUNCTION prevent_self_review() 
RETURNS TRIGGER AS $$ 
BEGIN 
    IF EXISTS ( 
        SELECT 1 FROM poem_author 
        WHERE user_id = NEW.user_id AND poem_id = NEW.poem_id 
    ) THEN 
        RAISE EXCEPTION 'User % cannot review their own poem %', NEW.user_id, NEW.poem_id; 
    END IF; 
    RETURN NEW; 
END; 
$$ LANGUAGE plpgsql; 
 
CREATE TRIGGER trg_prevent_self_review 
BEFORE INSERT OR UPDATE ON review 
FOR EACH ROW EXECUTE FUNCTION prevent_self_review(); 
 
INSERT INTO person (username, email, password_hash) VALUES 
    ('taras_shevchenko', 'taras@example.com', 'bcrypt_hash_1111111'), 
    ('lesya_ukrainka', 'lesya@example.com', 'bcrypt_hash_2222222'), 
    ('ivan_franko', 'ivan@example.com', 'bcrypt_hash_3333333'), 
    ('lina_kostenko', 'lina@example.com', 'bcrypt_hash_4444444'), 
    ('vasyl_stus', 'stus@example.com', 'bcrypt_hash_5555555'); 
 
INSERT INTO poem (owner_id, title, content_poem, poem_status, published_at) 

VALUES 

    (1,'Заповіт','Як умру, то поховайте мене на могилі...','published','2026-10-01 10:00:00'), 

    (2,'Contra spem spero!','Гетьте, думи, ви хмари осінні...','published','2026-10-02 11:30:00'), 

    (3,'Каменярі','Я бачив дивний сон. Немов передо мною...','published','2026-10-03 14:15:00'), 

    (4,'Маруся Чурай (Чернетка)','Зрада — це коли...','notes',NULL), 

    (5,'Терпи, терпи — терпець тебе шліфує','Терпи, терпи — терпець тебе шліфує...','published','2026-10-05 09:00:00'); 

 

INSERT INTO collection (person_id, title, visibility_status) VALUES 
    (1, 'Вибране. Кобзар', 'public'), 
    (2, 'На крилах пісень', 'public'), 
    (3, 'З вершин і низин', 'public'), 
    (4, 'Особисті записи', 'private'), 
    (5, 'Палімпсести', 'public'); 
 
INSERT INTO poem_author (user_id, poem_id, contribution_type) VALUES 
    (1, 1, 'головний автор'), 
    (2, 2, 'головний автор'), 
    (3, 3, 'головний автор'), 
    (4, 4, 'головний автор'), 
    (5, 5, 'головний автор'); 
 
INSERT INTO collection_poem (collection_id, poem_id, added_at) VALUES 
    (1, 1, '2026-10-01 12:00:00'), 
    (1, 3, '2026-10-03 15:00:00'), 
    (2, 2, '2026-10-02 12:00:00'), 
    (3, 3, '2026-10-03 16:00:00'), 
    (4, 4, '2026-10-04 10:00:00'), 
    (5, 5, '2026-10-05 10:00:00'); 
 
INSERT INTO review (user_id, poem_id, rating, comment) VALUES 
    (2, 1, 5, 'Чудовий твір.'), 
    (3, 1, 4, 'Дуже сильний текст.'), 
    (1, 2, 5, 'Один із найкращих творів.'), 
    (4, 3, 5, 'Вражаючий вірш.'); 
