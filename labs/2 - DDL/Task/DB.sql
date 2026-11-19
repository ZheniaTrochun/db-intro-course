DROP TABLE IF EXISTS
"categories", "languages", "users", "sources",
"articles", "revisions", "article_category", "article_sources";

CREATE TABLE categories (
    name VARCHAR(100) PRIMARY KEY
);
CREATE TABLE languages (
    name VARCHAR(100) PRIMARY KEY
);
CREATE TABLE users (
    name VARCHAR(100) PRIMARY KEY
);
CREATE TABLE sources (
    name VARCHAR(100) NOT NULL,
    url VARCHAR(1000) PRIMARY KEY
);
CREATE TABLE articles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    language VARCHAR(100) REFERENCES languages(name)
);
# Відображає історію ревізій
CREATE TABLE revisions (
    article_id INT REFERENCES articles(id),
    relative_id INT NOT NULL CHECK (relative_id >= 1),
    "user" VARCHAR(100) REFERENCES users(name),
    date DATE,
    content TEXT,
    PRIMARY KEY(article_id, relative_id)
);
# junction tables(таблиці сполучення)
# категорії
CREATE TABLE article_category (
    article_id INT,
    category VARCHAR(100) REFERENCES categories(name),

    PRIMARY KEY(article_id, category)
);
# джерела
CREATE TABLE article_source (
    article_id INT REFERENCES articles(id),
    source_url VARCHAR(1000) REFERENCES sources(url),

    PRIMARY KEY(article_id, source_url)
);
# INSERTS
INSERT INTO categories(name) 
VALUES
('Science'),
('History'),
('Technology');

INSERT INTO languages(name)
VALUES
('Ukrainian'),
('Polish'),
('German');

INSERT INTO users(name)
VALUES
('user_a'),
('user_b'),
('user_c');

INSERT INTO sources(name, url)
VALUES
('trustworthy source', 'ddd://trustworthy.com'),
('source', 'ddd://source.com'),
('third source', 'ddd://third_source.com');

INSERT INTO articles(id, name, language)
VALUES
(DEFAULT, 'scientific technology 34', 'Ukrainian'),
(DEFAULT, 'history of science', 'Polish'),
(DEFAULT, 'oven', 'German');

INSERT INTO 
revisions(article_id, relative_id, "user", date, content)
VALUES
(1, 1, 'user_a', '23.11.2022', 'some content'),
(1, 2, 'user_b', '24.11.2022', 'some updated content'),
(2, 1, 'user_c', '12.12.2011', 'some content');

INSERT INTO article_category(article_id, category)
VALUES
(1, 'Science'),
(1, 'Technology'),
(2, 'History'),
(2, 'Science');
INSERT INTO article_source(article_id, source_url)
VALUES
(1, 'ddd://trustworthy.com'),
(1, 'ddd://source.com'),
(2, 'ddd://third_source.com');