-- =====================================================
-- Тестові дані (запускати після 01_schema.sql)
-- =====================================================

INSERT INTO categories (name) VALUES
('Web Development'),
('Mobile Development'),
('Design'),
('Copywriting');

INSERT INTO clients (company_name, contact_name, email, phone, country) VALUES
('TechNova LLC',   'Олексій Гриценко', 'o.hrytsenko@technova.com', '+380501110001', 'Ukraine'),
('BrightPath Inc', 'Emily Carter',     'emily@brightpath.io',      '+14155550102',  'USA'),
('GreenLeaf GmbH', 'Hans Müller',      'hans@greenleaf.de',        '+4915112345678', 'Germany'),
('Skyline Studio', 'Наталія Литвин',   'n.lytvyn@skyline.ua',      '+380671110004', 'Ukraine');

INSERT INTO freelancers (full_name, email, skills, hourly_rate, registered_at) VALUES
('Іван Петренко',    'ivan.petrenko@mail.com', 'Python, Django, PostgreSQL',  35.00, CURRENT_DATE - 400),
('Олена Коваль',     'olena.koval@mail.com',   'React, Node.js, Flutter',     40.00, CURRENT_DATE - 380),
('Марія Шевченко',   'maria.shev@mail.com',    'Figma, UI/UX, Branding',      30.00, CURRENT_DATE - 300),
('Андрій Мельник',   'andrii.melnyk@mail.com', 'Copywriting, SEO',            20.00, CURRENT_DATE - 250),
('Софія Бондар',     'sofia.bondar@mail.com',  'Illustration, Figma',         25.00, CURRENT_DATE - 200);

INSERT INTO projects (client_id, category_id, title, description, budget, deadline, status, created_at) VALUES
(1, 1, 'Інтернет-магазин на Django',      'Каталог, кошик, оплата',          3000.00, CURRENT_DATE - 50,  'completed',   CURRENT_DATE - 120),
(1, 2, 'Мобільний застосунок доставки',   'iOS/Android, трекінг кур''єрів',  5000.00, CURRENT_DATE - 60,  'completed',   CURRENT_DATE - 150),
(2, 3, 'Логотип і брендбук',              'Айдентика для стартапу',           800.00, CURRENT_DATE - 70,  'completed',   CURRENT_DATE - 100),
(2, 1, 'Лендінг для стартапу',            'Адаптивний односторінковий сайт', 1200.00, CURRENT_DATE + 20,  'open',        CURRENT_DATE - 10),
(3, 4, 'Тексти для сайту',                'Копірайтинг 10 сторінок',          500.00, CURRENT_DATE - 70,  'completed',   CURRENT_DATE - 90),
(3, 1, 'REST API для CRM',                'FastAPI + PostgreSQL',            2500.00, CURRENT_DATE + 25,  'in_progress', CURRENT_DATE - 40),
(4, 3, 'UI-дизайн дашборда',              'Макети в Figma',                  1500.00, CURRENT_DATE + 30,  'open',        CURRENT_DATE - 5),
(4, 2, 'Flutter застосунок для фітнесу',  'Трекер тренувань',                4000.00, CURRENT_DATE + 40,  'open',        CURRENT_DATE - 45),
(1, 1, 'Міграція БД на PostgreSQL',       'Перенесення з MySQL',             2000.00, CURRENT_DATE + 35,  'open',        CURRENT_DATE - 3),
(2, 4, 'SEO-статті для блогу',            '12 статей по 1500 слів',           600.00, CURRENT_DATE + 15,  'open',        CURRENT_DATE - 60),
(4, 1, 'Адмін-панель',                    'React адмінка для складу',        2200.00, CURRENT_DATE - 30,  'completed',   CURRENT_DATE - 80);

INSERT INTO proposals (project_id, freelancer_id, price, cover_letter, submitted_at, status) VALUES
(1,  1, 2800.00, 'Маю досвід з Django',        CURRENT_DATE - 118, 'accepted'),
(1,  2, 3200.00, 'Можу зробити на React+Node', CURRENT_DATE - 117, 'rejected'),
(2,  2, 5200.00, 'Flutter - мій основний стек',CURRENT_DATE - 148, 'accepted'),
(3,  3,  750.00, 'Портфоліо у профілі',        CURRENT_DATE - 98,  'accepted'),
(5,  4,  480.00, 'Пишу для e-commerce',        CURRENT_DATE - 88,  'accepted'),
(6,  1, 2400.00, 'Готовий почати негайно',     CURRENT_DATE - 38,  'accepted'),
(4,  1, 1100.00, 'Зроблю за 2 тижні',          CURRENT_DATE - 8,   'pending'),
(4,  2, 1250.00, 'React + Tailwind',           CURRENT_DATE - 7,   'pending'),
(7,  3, 1400.00, 'Спеціалізуюсь на дашбордах', CURRENT_DATE - 4,   'pending'),
(11, 2, 2100.00, 'Робив подібні адмінки',      CURRENT_DATE - 78,  'accepted'),
(11, 1, 2300.00, 'Django Admin + React',       CURRENT_DATE - 77,  'rejected'),
(3,  5,  900.00, 'Ілюстрації та логотипи',     CURRENT_DATE - 97,  'rejected');

INSERT INTO contracts (proposal_id, start_date, end_date, status, rating) VALUES
(1,  CURRENT_DATE - 115, CURRENT_DATE - 60, 'completed', 5),
(3,  CURRENT_DATE - 145, CURRENT_DATE - 70, 'completed', 4),
(4,  CURRENT_DATE - 95,  CURRENT_DATE - 80, 'completed', 5),
(5,  CURRENT_DATE - 85,  CURRENT_DATE - 75, 'completed', 4),
(6,  CURRENT_DATE - 35,  NULL,              'active',    NULL),
(10, CURRENT_DATE - 75,  CURRENT_DATE - 50, 'completed', 3);
