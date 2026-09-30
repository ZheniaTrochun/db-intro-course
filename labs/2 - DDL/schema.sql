-- ============================================
-- Lab 2: Wishlist Service
-- Database schema
-- ============================================

-- Remove existing tables so the script can be
-- executed again during development.
DROP TABLE IF EXISTS reservations;
DROP TABLE IF EXISTS wishlist_items;
DROP TABLE IF EXISTS wishlists;
DROP TABLE IF EXISTS users;


-- ============================================
-- Users
-- ============================================

CREATE TABLE users (
    user_id UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL
);


-- ============================================
-- Wishlists
-- ============================================

CREATE TABLE wishlists (
    wishlist_id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_public BOOLEAN NOT NULL DEFAULT TRUE,

    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
);


-- ============================================
-- Wishlist Items
-- ============================================

CREATE TABLE wishlist_items (
    item_id UUID PRIMARY KEY,
    wishlist_id UUID NOT NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    product_url TEXT,
    image_url TEXT,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,

    FOREIGN KEY (wishlist_id)
        REFERENCES wishlists(wishlist_id)
);


-- ============================================
-- Reservations
-- ============================================

CREATE TABLE reservations (
    reservation_id UUID PRIMARY KEY,
    item_id UUID NOT NULL UNIQUE,
    user_id UUID NOT NULL,
    reserved_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (item_id)
        REFERENCES wishlist_items(item_id),

    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
);