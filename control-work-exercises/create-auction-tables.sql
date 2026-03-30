-- Категорії
CREATE TABLE category (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- Користувачі
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL  UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE
);

-- Лоти
CREATE TABLE lots (
    lot_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    start_price INT CHECK (start_price >= 0),
	created_at TIMESTAMP DEFAULT NOW(),
    end_time TIMESTAMP NOT NULL,
	status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'closed')),
    seller_id INTEGER NOT NULL REFERENCES users(user_id),
    category_id INTEGER REFERENCES category(category_id)
);

-- Ставки
CREATE TABLE bids (
    bid_id SERIAL PRIMARY KEY,
    amount INT NOT  NULL CHECK (amount > 0),
    bid_time TIMESTAMP DEFAULT NOW(),
    lot_id INTEGER NOT NULL REFERENCES lots(lot_id),
    buyer_id INTEGER NOT NULL REFERENCES users(user_id)
);

-- Транзакції (фінальні продажі)
CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    final_price INTEGER NOT NULL CHECK (final_price > 0),
    lot_id INTEGER NOT NULL UNIQUE REFERENCES lots(lot_id),
    buyer_id INTEGER NOT NULL REFERENCES users(user_id)
);