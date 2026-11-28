INSERT INTO USERS (
        user_id,
        email,
        pass_hash,
        display_name,
        avatar_url,
        role,
        status,
        created_at,
        deleted_at
    )
VALUES (
        1,
        'olena@example.com',
        'totallyrealhash1234',
        'Олена',
        NULL,
        'user',
        'active',
        '2026-01-10 09:00:00+02',
        NULL
    ),
    (
        2,
        'taras@example.com',
        'totallyrealhash1234',
        'Тарас',
        NULL,
        'user',
        'active',
        '2026-01-12 11:30:00+02',
        NULL
    ),
    (
        3,
        'marta.moderator@example.com',
        'totallyrealhash1234',
        'Марта',
        NULL,
        'moderator',
        'active',
        '2025-12-01 10:00:00+02',
        NULL
    ),
    (
        4,
        'admin@example.com',
        'totallyrealhash1234',
        'Адміністратор',
        NULL,
        'admin',
        'active',
        '2025-11-15 08:00:00+02',
        NULL
    ),
    (
        5,
        'andrii@example.com',
        'totallyrealhash1234',
        'Андрій',
        NULL,
        'user',
        'active',
        '2026-02-02 14:15:00+02',
        NULL
    ),
    (
        6,
        'owner@example.com',
        'totallyrealhash1234',
        'Ірина',
        NULL,
        'user',
        'active',
        '2026-01-20 16:45:00+02',
        NULL
    ),
    (
        7,
        'deleted@example.com',
        'totallyrealhash1234',
        'Видалений користувач',
        NULL,
        'user',
        'deleted',
        '2025-10-01 12:00:00+03',
        '2026-01-05 12:00:00+02'
    ),
    (
        8,
        'sofia@example.com',
        'totallyrealhash1234',
        'Софія',
        NULL,
        'user',
        'active',
        '2026-03-05 13:20:00+02',
        NULL
    );
INSERT INTO CITY (city_id, name, region)
VALUES (1, 'Київ', 'Київська область'),
    (2, 'Львів', 'Львівська область'),
    (3, 'Одеса', 'Одеська область');
INSERT INTO VENUE_TYPE (venue_type_id, name)
VALUES (1, 'Шаурмічна'),
    (2, 'Фастфуд'),
    (3, 'Кафе'),
    (4, 'Вулична їжа');
INSERT INTO FEATURE (feature_id, name)
VALUES (1, 'Доставка'),
    (2, 'Літній майданчик'),
    (3, 'Вегетаріанські страви'),
    (4, 'Працює допізна'),
    (5, 'Безготівкова оплата');
INSERT INTO VENUE (
        venue_id,
        city_id,
        created_by,
        status,
        name,
        description,
        address,
        latitude,
        longitude,
        phone_number,
        website,
        created_at
    )
VALUES (
        1,
        1,
        6,
        'approved',
        'Шаурма на Подолі',
        'Шаурма з куркою та свіжими овочами.',
        'вул. Спаська, 5, Київ',
        50.4652,
        30.5153,
        '+380441112233',
        'https://podil-shawarma.example.com',
        '2026-01-21 10:00:00+02'
    ),
    (
        2,
        2,
        8,
        'approved',
        'Львівський лаваш',
        'Лаваш із локальними соусами та м’ясом на грилі.',
        'просп. Свободи, 12, Львів',
        49.8419,
        24.0315,
        '+380322223344',
        'https://lviv-lavash.example.com',
        '2026-02-10 12:00:00+02'
    ),
    (
        3,
        3,
        5,
        'approved',
        'Причал',
        'Швидкі страви та шаурма неподалік від моря.',
        'вул. Дерибасівська, 18, Одеса',
        46.4846,
        30.7356,
        '+380482223344',
        'https://prychal.example.com',
        '2026-02-15 09:30:00+02'
    ),
    (
        4,
        1,
        1,
        'pending',
        'Зелений лаваш',
        'Меню з овочевими та м’ясними начинками.',
        'вул. Велика Васильківська, 20, Київ',
        50.4354,
        30.5162,
        '+380443334455',
        'https://green-lavash.example.com',
        '2026-03-10 15:00:00+02'
    ),
    (
        5,
        2,
        2,
        'rejected',
        'Нічний гриль',
        'Невеликий заклад із вечірнім меню.',
        'вул. Городоцька, 44, Львів',
        49.8397,
        24.0101,
        '+380322223355',
        'https://night-grill.example.com',
        '2026-03-12 17:00:00+02'
    );
INSERT INTO VENUE_VENUE_TYPE (venue_id, venue_type_id)
VALUES (1, 1),
    (1, 4),
    (2, 1),
    (3, 2),
    (4, 3),
    (5, 4);
INSERT INTO VENUE_FEATURE (venue_id, feature_id)
VALUES (1, 1),
    (1, 4),
    (2, 2),
    (3, 1),
    (4, 3),
    (5, 5);
INSERT INTO FAVORITE (user_id, venue_id, created_at)
VALUES (1, 1, '2026-03-01 12:00:00+02'),
    (1, 2, '2026-03-02 12:00:00+02'),
    (2, 1, '2026-03-03 14:30:00+02'),
    (5, 3, '2026-03-04 18:15:00+02'),
    (8, 4, '2026-03-05 19:00:00+02');
INSERT INTO WORKING_HOURS (
        working_hours_id,
        venue_id,
        weekday,
        opens_at,
        closes_at
    )
VALUES (1, 1, 1, '10:00', '22:00'),
    (2, 1, 2, '10:00', '22:00'),
    (3, 2, 5, '11:00', '23:00'),
    (4, 3, 6, '10:00', '00:00'),
    (5, 4, 7, '09:00', '20:00');
INSERT INTO MENU_ITEM (
        menu_item_id,
        venue_id,
        name,
        description,
        price,
        is_available
    )
VALUES (
        1,
        1,
        'Шаурма класична',
        'Курка, овочі, часниковий соус.',
        155.00,
        TRUE
    ),
    (
        2,
        1,
        'Шаурма гостра',
        'Курка, овочі та гострий соус.',
        165.00,
        TRUE
    ),
    (
        3,
        2,
        'Лаваш із телятиною',
        'Телятина, салат і фірмовий соус.',
        190.00,
        TRUE
    ),
    (
        4,
        3,
        'Овочева шаурма',
        'Овочі гриль, зелень і тахіні.',
        145.00,
        TRUE
    ),
    (
        5,
        4,
        'Комбо дня',
        'Шаурма та напій.',
        210.00,
        FALSE
    );
INSERT INTO MODERATION_ACTION (
        moderation_action_id,
        venue_id,
        moderator_id,
        action,
        note,
        created_at
    )
VALUES (
        1,
        1,
        3,
        'approve',
        'Інформацію про заклад перевірено.',
        '2026-01-22 10:00:00+02'
    ),
    (
        2,
        2,
        3,
        'approve',
        'Адресу та контактні дані підтверджено.',
        '2026-02-11 11:00:00+02'
    ),
    (
        3,
        5,
        3,
        'reject',
        'Потрібно підтвердити адресу закладу.',
        '2026-03-13 09:00:00+02'
    );
INSERT INTO REVIEW (
        review_id,
        venue_id,
        user_id,
        rating,
        text,
        visited_on,
        status,
        created_at,
        updated_at
    )
VALUES (
        1,
        1,
        1,
        9,
        'Смачна шаурма, швидке обслуговування.',
        '2026-02-20',
        'visible',
        '2026-02-21 12:00:00+02',
        '2026-02-21 12:00:00+02'
    ),
    (
        2,
        1,
        2,
        7,
        'Гарний соус, але хотілося б більше овочів.',
        '2026-02-25',
        'visible',
        '2026-02-26 13:00:00+02',
        '2026-02-26 13:00:00+02'
    ),
    (
        3,
        2,
        5,
        10,
        'Чудовий лаваш і привітний персонал.',
        '2026-03-01',
        'visible',
        '2026-03-02 17:30:00+02',
        '2026-03-02 17:30:00+02'
    ),
    (
        4,
        3,
        8,
        6,
        'Непогано, але довелося довго чекати.',
        '2026-03-03',
        'visible',
        '2026-03-04 15:45:00+02',
        '2026-03-04 15:45:00+02'
    ),
    (
        5,
        3,
        NULL,
        8,
        'Свіжі інгредієнти та зручне розташування.',
        '2026-03-05',
        'hidden',
        '2026-03-06 10:15:00+02',
        '2026-03-07 09:00:00+02'
    );
INSERT INTO VENUE_CLAIM (
        venue_claim_id,
        venue_id,
        claimant_id,
        contact_info,
        evidence,
        status,
        reviewed_by,
        reviewed_at,
        review_note,
        created_at
    )
VALUES (
        1,
        1,
        6,
        'owner@example.com',
        'Посилання на офіційну сторінку закладу.',
        'approved',
        3,
        '2026-02-01 10:00:00+02',
        'Контакт підтверджено.',
        '2026-01-25 09:00:00+02'
    ),
    (
        2,
        2,
        8,
        'sofia@example.com',
        'Документ із даними про заклад.',
        'pending',
        NULL,
        NULL,
        NULL,
        '2026-03-08 14:00:00+02'
    ),
    (
        3,
        3,
        5,
        'andrii@example.com',
        'Звернення від представника закладу.',
        'rejected',
        3,
        '2026-03-10 16:00:00+02',
        'Наданих підтверджень недостатньо.',
        '2026-03-09 11:00:00+02'
    );
INSERT INTO VENUE_STAFF (venue_id, user_id, role, added_by, added_at)
VALUES (1, 6, 'owner', 4, '2026-02-02 10:00:00+02'),
    (1, 2, 'manager', 6, '2026-02-03 10:00:00+02'),
    (2, 8, 'owner', 4, '2026-02-12 12:00:00+02'),
    (3, 5, 'manager', 4, '2026-02-20 12:00:00+02');
INSERT INTO PROMOTION (
        promotion_id,
        venue_id,
        created_by,
        type,
        title,
        description,
        image_url,
        starts_at,
        ends_at,
        status,
        reviewed_by,
        reviewed_at,
        review_note
    )
VALUES (
        1,
        1,
        6,
        'offer',
        'Комбо зі знижкою',
        'Знижка на шаурму та напій у будні.',
        'https://images.example.com/promo-1.jpg',
        '2026-03-01 00:00:00+02',
        '2026-12-31 23:59:59+02',
        'active',
        3,
        '2026-02-25 10:00:00+02',
        'Акцію погоджено.'
    ),
    (
        2,
        2,
        8,
        'featured',
        'Заклад тижня',
        'Спробуйте фірмовий лаваш.',
        'https://images.example.com/promo-2.jpg',
        '2026-04-01 00:00:00+03',
        '2026-12-31 23:59:59+02',
        'pending',
        NULL,
        NULL,
        NULL
    ),
    (
        3,
        3,
        5,
        'offer',
        'Обідня пропозиція',
        'Спеціальна ціна на обіднє меню.',
        'https://images.example.com/promo-3.jpg',
        '2026-03-15 00:00:00+02',
        '2026-11-30 23:59:59+02',
        'rejected',
        3,
        '2026-03-12 10:00:00+02',
        'Виправте умови та зображення акції.'
    );
INSERT INTO REVIEW_COMMENT (
        review_comment_id,
        review_id,
        user_id,
        parent_comment_id,
        text,
        is_official,
        created_at
    )
VALUES (
        1,
        1,
        6,
        NULL,
        'Дякуємо за відгук! Раді, що вам сподобалося.',
        TRUE,
        '2026-02-21 15:00:00+02'
    ),
    (
        2,
        1,
        2,
        1,
        'Підтверджую, соус справді вдалий.',
        FALSE,
        '2026-02-22 10:00:00+02'
    ),
    (
        3,
        2,
        6,
        NULL,
        'Дякуємо за пораду, врахуємо її.',
        TRUE,
        '2026-02-26 16:00:00+02'
    ),
    (
        4,
        2,
        8,
        3,
        'Дякую, що врахували побажання.',
        FALSE,
        '2026-03-03 11:00:00+02'
    ),
    (
        5,
        4,
        NULL,
        NULL,
        'Відгук перевірено модератором.',
        FALSE,
        '2026-03-05 09:00:00+02'
    );
INSERT INTO PHOTO (
        photo_id,
        venue_id,
        review_id,
        uploaded_by,
        url,
        created_at
    )
VALUES (
        1,
        1,
        NULL,
        6,
        'https://images.example.com/venue-1-front.jpg',
        '2026-02-01 10:00:00+02'
    ),
    (
        2,
        1,
        NULL,
        2,
        'https://images.example.com/venue-1-menu.jpg',
        '2026-02-02 11:00:00+02'
    ),
    (
        3,
        2,
        NULL,
        8,
        'https://images.example.com/venue-2-interior.jpg',
        '2026-02-15 12:00:00+02'
    ),
    (
        4,
        NULL,
        1,
        1,
        'https://images.example.com/review-1-meal.jpg',
        '2026-02-21 12:30:00+02'
    ),
    (
        5,
        NULL,
        3,
        5,
        'https://images.example.com/review-3-meal.jpg',
        '2026-03-02 18:00:00+02'
    );
INSERT INTO REPORT (
        report_id,
        reporter_id,
        review_id,
        comment_id,
        venue_id,
        reason,
        status,
        handled_by,
        created_at
    )
VALUES (
        1,
        2,
        5,
        NULL,
        NULL,
        'Можливо, відгук не відповідає правилам спільноти.',
        'resolved',
        3,
        '2026-03-07 10:00:00+02'
    ),
    (
        2,
        1,
        NULL,
        5,
        NULL,
        'Потрібно перевірити зміст коментаря.',
        'open',
        NULL,
        '2026-03-08 12:00:00+02'
    ),
    (
        3,
        8,
        NULL,
        NULL,
        5,
        'Адреса закладу може бути некоректною.',
        'dismissed',
        3,
        '2026-03-09 14:00:00+02'
    );
INSERT INTO PROMOTION_STAT (
        promotion_stat_id,
        promotion_id,
        stat_date,
        impressions,
        clicks
    )
VALUES (1, 1, '2026-03-01', 1250, 84),
    (2, 1, '2026-03-02', 1430, 97),
    (3, 2, '2026-04-01', 980, 51);
-- sync serial sequences with the current max values in the tables
SELECT setval(
        pg_get_serial_sequence('users', 'user_id'),
        (
            SELECT MAX(user_id)
            FROM USERS
        )
    );
SELECT setval(
        pg_get_serial_sequence('city', 'city_id'),
        (
            SELECT MAX(city_id)
            FROM CITY
        )
    );
SELECT setval(
        pg_get_serial_sequence('venue_type', 'venue_type_id'),
        (
            SELECT MAX(venue_type_id)
            FROM VENUE_TYPE
        )
    );
SELECT setval(
        pg_get_serial_sequence('feature', 'feature_id'),
        (
            SELECT MAX(feature_id)
            FROM FEATURE
        )
    );
SELECT setval(
        pg_get_serial_sequence('venue', 'venue_id'),
        (
            SELECT MAX(venue_id)
            FROM VENUE
        )
    );
SELECT setval(
        pg_get_serial_sequence('working_hours', 'working_hours_id'),
        (
            SELECT MAX(working_hours_id)
            FROM WORKING_HOURS
        )
    );
SELECT setval(
        pg_get_serial_sequence('menu_item', 'menu_item_id'),
        (
            SELECT MAX(menu_item_id)
            FROM MENU_ITEM
        )
    );
SELECT setval(
        pg_get_serial_sequence('moderation_action', 'moderation_action_id'),
        (
            SELECT MAX(moderation_action_id)
            FROM MODERATION_ACTION
        )
    );
SELECT setval(
        pg_get_serial_sequence('review', 'review_id'),
        (
            SELECT MAX(review_id)
            FROM REVIEW
        )
    );
SELECT setval(
        pg_get_serial_sequence('venue_claim', 'venue_claim_id'),
        (
            SELECT MAX(venue_claim_id)
            FROM VENUE_CLAIM
        )
    );
SELECT setval(
        pg_get_serial_sequence('promotion', 'promotion_id'),
        (
            SELECT MAX(promotion_id)
            FROM PROMOTION
        )
    );
SELECT setval(
        pg_get_serial_sequence('review_comment', 'review_comment_id'),
        (
            SELECT MAX(review_comment_id)
            FROM REVIEW_COMMENT
        )
    );
SELECT setval(
        pg_get_serial_sequence('photo', 'photo_id'),
        (
            SELECT MAX(photo_id)
            FROM PHOTO
        )
    );
SELECT setval(
        pg_get_serial_sequence('report', 'report_id'),
        (
            SELECT MAX(report_id)
            FROM REPORT
        )
    );
SELECT setval(
        pg_get_serial_sequence('promotion_stat', 'promotion_stat_id'),
        (
            SELECT MAX(promotion_stat_id)
            FROM PROMOTION_STAT
        )
    );