DROP TABLE IF EXISTS FAVORITE;
DROP TABLE IF EXISTS VENUE_FEATURE;
DROP TABLE IF EXISTS VENUE_VENUE_TYPE;
DROP TABLE IF EXISTS PROMOTION_STAT;
DROP TABLE IF EXISTS REPORT;
DROP TABLE IF EXISTS PHOTO;
DROP TABLE IF EXISTS REVIEW_COMMENT;
DROP TABLE IF EXISTS PROMOTION;
DROP TABLE IF EXISTS VENUE_STAFF;
DROP TABLE IF EXISTS VENUE_CLAIM;
DROP TABLE IF EXISTS REVIEW;
DROP TABLE IF EXISTS MODERATION_ACTION;
DROP TABLE IF EXISTS MENU_ITEM;
DROP TABLE IF EXISTS WORKING_HOURS;
DROP TABLE IF EXISTS VENUE;
DROP TABLE IF EXISTS FEATURE;
DROP TABLE IF EXISTS VENUE_TYPE;
DROP TABLE IF EXISTS CITY;
DROP TABLE IF EXISTS USERS;
DROP TYPE IF EXISTS user_role;
DROP TYPE IF EXISTS user_status;
DROP TYPE IF EXISTS venue_status;
DROP TYPE IF EXISTS moderation_action_action;
DROP TYPE IF EXISTS review_status;
DROP TYPE IF EXISTS venue_claim_status;
DROP TYPE IF EXISTS venue_staff_role;
DROP TYPE IF EXISTS promotion_type;
DROP TYPE IF EXISTS promotion_status;
DROP TYPE IF EXISTS report_status;
CREATE TYPE user_role AS ENUM ('user', 'moderator', 'admin');
CREATE TYPE user_status AS ENUM ('active', 'deleted');
CREATE TYPE venue_status AS ENUM ('pending', 'approved', 'rejected');
CREATE TYPE moderation_action_action AS ENUM ('approve', 'reject', 'request_changes');
CREATE TYPE review_status AS ENUM ('visible', 'hidden');
CREATE TYPE venue_claim_status AS ENUM ('pending', 'approved', 'rejected');
CREATE TYPE venue_staff_role AS ENUM ('owner', 'manager');
CREATE TYPE promotion_type AS ENUM ('featured', 'offer');
CREATE TYPE promotion_status AS ENUM (
    'draft',
    'pending',
    'active',
    'ended',
    'rejected'
);
CREATE TYPE report_status AS ENUM ('open', 'resolved', 'dismissed');
CREATE TABLE USERS (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(254) UNIQUE NOT NULL,
    pass_hash TEXT NOT NULL,
    display_name VARCHAR(50) NOT NULL,
    avatar_url TEXT NULL,
    role user_role NOT NULL DEFAULT 'user',
    status user_status NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ NULL,
    CONSTRAINT chk_users_deleted_consistency CHECK ((status = 'deleted') = (deleted_at IS NOT NULL))
);
CREATE TABLE CITY (
    city_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    region VARCHAR(255) NOT NULL
);
CREATE TABLE VENUE_TYPE (
    venue_type_id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL
);
CREATE TABLE FEATURE (
    feature_id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL
);
CREATE TABLE VENUE (
    venue_id SERIAL PRIMARY KEY,
    city_id INT NOT NULL,
    created_by INT NULL,
    status venue_status NOT NULL DEFAULT 'pending',
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    address TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL CHECK (
        latitude BETWEEN -90 AND 90
    ),
    longitude DOUBLE PRECISION NOT NULL CHECK (
        longitude BETWEEN -180 AND 180
    ),
    phone_number VARCHAR(20) NOT NULL,
    website TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_venue_city FOREIGN KEY (city_id) REFERENCES CITY(city_id),
    CONSTRAINT fk_venue_created_by FOREIGN KEY (created_by) REFERENCES USERS(user_id) ON DELETE
    SET NULL
);
CREATE TABLE VENUE_VENUE_TYPE (
    venue_id INT NOT NULL,
    venue_type_id INT NOT NULL,
    CONSTRAINT pk_venue_venue_type PRIMARY KEY (venue_id, venue_type_id),
    CONSTRAINT fk_venue_venue_type_venue FOREIGN KEY (venue_id) REFERENCES VENUE(venue_id) ON DELETE CASCADE,
    CONSTRAINT fk_venue_venue_type_type FOREIGN KEY (venue_type_id) REFERENCES VENUE_TYPE(venue_type_id) ON DELETE CASCADE
);
CREATE TABLE VENUE_FEATURE (
    venue_id INT NOT NULL,
    feature_id INT NOT NULL,
    CONSTRAINT pk_venue_feature PRIMARY KEY (venue_id, feature_id),
    CONSTRAINT fk_venue_feature_venue FOREIGN KEY (venue_id) REFERENCES VENUE(venue_id) ON DELETE CASCADE,
    CONSTRAINT fk_venue_feature_feature FOREIGN KEY (feature_id) REFERENCES FEATURE(feature_id) ON DELETE CASCADE
);
CREATE TABLE FAVORITE (
    user_id INT NOT NULL,
    venue_id INT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_favorite PRIMARY KEY (user_id, venue_id),
    CONSTRAINT fk_favorite_user FOREIGN KEY (user_id) REFERENCES USERS(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_favorite_venue FOREIGN KEY (venue_id) REFERENCES VENUE(venue_id) ON DELETE CASCADE
);
CREATE TABLE WORKING_HOURS (
    working_hours_id SERIAL PRIMARY KEY,
    venue_id INT NOT NULL,
    weekday SMALLINT NOT NULL CHECK (
        weekday BETWEEN 1 AND 7
    ),
    opens_at TIME NOT NULL,
    closes_at TIME NOT NULL,
    CONSTRAINT fk_working_hours_venue FOREIGN KEY (venue_id) REFERENCES VENUE(venue_id) ON DELETE CASCADE
);
CREATE TABLE MENU_ITEM (
    menu_item_id SERIAL PRIMARY KEY,
    venue_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_menu_item_venue FOREIGN KEY (venue_id) REFERENCES VENUE(venue_id) ON DELETE CASCADE
);
CREATE TABLE MODERATION_ACTION (
    moderation_action_id SERIAL PRIMARY KEY,
    venue_id INT NOT NULL,
    moderator_id INT NOT NULL,
    action moderation_action_action NOT NULL,
    note TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_moderation_action_venue FOREIGN KEY (venue_id) REFERENCES VENUE(venue_id) ON DELETE CASCADE,
    CONSTRAINT fk_moderation_action_moderator FOREIGN KEY (moderator_id) REFERENCES USERS(user_id) ON DELETE RESTRICT
);
CREATE TABLE REVIEW (
    review_id SERIAL PRIMARY KEY,
    venue_id INT NOT NULL,
    user_id INT NULL,
    rating SMALLINT NOT NULL CHECK (
        rating BETWEEN 1 AND 10
    ),
    text TEXT NOT NULL,
    visited_on DATE NOT NULL,
    status review_status NOT NULL DEFAULT 'visible',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_review_venue FOREIGN KEY (venue_id) REFERENCES VENUE(venue_id) ON DELETE CASCADE,
    CONSTRAINT fk_review_user FOREIGN KEY (user_id) REFERENCES USERS(user_id) ON DELETE
    SET NULL
);
CREATE TABLE VENUE_CLAIM (
    venue_claim_id SERIAL PRIMARY KEY,
    venue_id INT NOT NULL,
    claimant_id INT NOT NULL,
    contact_info TEXT NOT NULL,
    evidence TEXT NOT NULL,
    status venue_claim_status NOT NULL DEFAULT 'pending',
    reviewed_by INT NULL,
    reviewed_at TIMESTAMPTZ NULL,
    review_note TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_venue_claim_venue FOREIGN KEY (venue_id) REFERENCES VENUE(venue_id) ON DELETE CASCADE,
    CONSTRAINT fk_venue_claim_claimant FOREIGN KEY (claimant_id) REFERENCES USERS(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_venue_claim_reviewed_by FOREIGN KEY (reviewed_by) REFERENCES USERS(user_id) ON DELETE
    SET NULL
);
CREATE TABLE VENUE_STAFF (
    venue_id INT NOT NULL,
    user_id INT NOT NULL,
    role venue_staff_role NOT NULL,
    added_by INT NULL,
    added_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_venue_staff PRIMARY KEY (venue_id, user_id),
    CONSTRAINT fk_venue_staff_venue FOREIGN KEY (venue_id) REFERENCES VENUE(venue_id) ON DELETE CASCADE,
    CONSTRAINT fk_venue_staff_user FOREIGN KEY (user_id) REFERENCES USERS(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_venue_staff_added_by FOREIGN KEY (added_by) REFERENCES USERS(user_id) ON DELETE
    SET NULL
);
CREATE TABLE PROMOTION (
    promotion_id SERIAL PRIMARY KEY,
    venue_id INT NOT NULL,
    created_by INT NULL,
    type promotion_type NOT NULL DEFAULT 'featured',
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    image_url TEXT NOT NULL,
    starts_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ends_at TIMESTAMPTZ NOT NULL,
    status promotion_status NOT NULL DEFAULT 'draft',
    reviewed_by INT NULL,
    reviewed_at TIMESTAMPTZ NULL,
    review_note TEXT NULL,
    CONSTRAINT chk_promotion_dates CHECK (ends_at >= starts_at),
    CONSTRAINT fk_promotion_venue FOREIGN KEY (venue_id) REFERENCES VENUE(venue_id) ON DELETE CASCADE,
    CONSTRAINT fk_promotion_created_by FOREIGN KEY (created_by) REFERENCES USERS(user_id) ON DELETE
    SET NULL,
        CONSTRAINT fk_promotion_reviewed_by FOREIGN KEY (reviewed_by) REFERENCES USERS(user_id) ON DELETE
    SET NULL
);
CREATE TABLE REVIEW_COMMENT (
    review_comment_id SERIAL PRIMARY KEY,
    review_id INT NOT NULL,
    user_id INT NULL,
    parent_comment_id INT NULL,
    text TEXT NOT NULL,
    is_official BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_review_comment_review FOREIGN KEY (review_id) REFERENCES REVIEW(review_id) ON DELETE CASCADE,
    CONSTRAINT fk_review_comment_user FOREIGN KEY (user_id) REFERENCES USERS(user_id) ON DELETE
    SET NULL,
        CONSTRAINT fk_review_comment_parent FOREIGN KEY (parent_comment_id) REFERENCES REVIEW_COMMENT(review_comment_id) ON DELETE CASCADE
);
CREATE TABLE PHOTO (
    photo_id SERIAL PRIMARY KEY,
    venue_id INT NULL,
    review_id INT NULL,
    uploaded_by INT NULL,
    url TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_photo_target_xor CHECK (
        (
            venue_id IS NOT NULL
            AND review_id IS NULL
        )
        OR (
            venue_id IS NULL
            AND review_id IS NOT NULL
        )
    ),
    CONSTRAINT fk_photo_venue FOREIGN KEY (venue_id) REFERENCES VENUE(venue_id) ON DELETE CASCADE,
    CONSTRAINT fk_photo_review FOREIGN KEY (review_id) REFERENCES REVIEW(review_id) ON DELETE CASCADE,
    CONSTRAINT fk_photo_uploaded_by FOREIGN KEY (uploaded_by) REFERENCES USERS(user_id) ON DELETE
    SET NULL
);
CREATE TABLE REPORT (
    report_id SERIAL PRIMARY KEY,
    reporter_id INT NULL,
    review_id INT NULL,
    comment_id INT NULL,
    venue_id INT NULL,
    reason TEXT NOT NULL,
    status report_status NOT NULL DEFAULT 'open',
    handled_by INT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_report_target_exactly_one_of_three CHECK (
        (review_id IS NOT NULL)::INT + (comment_id IS NOT NULL)::INT + (venue_id IS NOT NULL)::INT = 1
    ),
    CONSTRAINT fk_report_reporter_id FOREIGN KEY (reporter_id) REFERENCES USERS(user_id) ON DELETE
    SET NULL,
        CONSTRAINT fk_report_review FOREIGN KEY (review_id) REFERENCES REVIEW(review_id) ON DELETE CASCADE,
        CONSTRAINT fk_report_comment FOREIGN KEY (comment_id) REFERENCES REVIEW_COMMENT(review_comment_id) ON DELETE CASCADE,
        CONSTRAINT fk_report_venue FOREIGN KEY (venue_id) REFERENCES VENUE(venue_id) ON DELETE CASCADE,
        CONSTRAINT fk_report_handled_by FOREIGN KEY (handled_by) REFERENCES USERS(user_id) ON DELETE
    SET NULL
);
CREATE TABLE PROMOTION_STAT (
    promotion_stat_id SERIAL PRIMARY KEY,
    promotion_id INT NOT NULL,
    stat_date DATE NOT NULL,
    impressions INT NOT NULL DEFAULT 0 CHECK (impressions >= 0),
    clicks INT NOT NULL DEFAULT 0 CHECK (clicks >= 0),
    CONSTRAINT fk_promotion_stat_promotion FOREIGN KEY (promotion_id) REFERENCES PROMOTION(promotion_id) ON DELETE CASCADE
);