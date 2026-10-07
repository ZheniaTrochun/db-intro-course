# Модуль Player

Описує сутності, пов'язані з користувачами, персонажами, їхніми характеристиками, закляттями та інвентарем.

## User

Зберігає облікові дані гравців платформи. Головним ключем цієї сутності є id - int generated always as identity. Окрім того, має атрибути username - varchar[100] NOT NULL для унікального імені користувача, email - varchar[255] NOT NULL, та password - varbinary[128] NOT NULL для хешу пароля. Також визначає стан блокування через ban_until - timestamp NULL default NULL та ban_reason - varchar[420] NULL. Має зв'язок один до нуля або багатьох із сутністю Character.

## Character

Центральна сутність ігрового персонажа, що об'єднує ігрові підсистеми, білд, характеристики та фізичну присутність у світі. Зберігає ігрове ім'я персонажа - name - varchar[100] NOT NULL, а також головний ключ id - int generated always as identity.

user_id є foreign key до таблиці User, кардинальність - багато до одного (нуль або багато персонажів належать одному User). Також має worldentity_id - int NOT NULL, foreign key на сутність WorldEntity (визначає координати у світі), та stats_id - int NOT NULL, foreign key на сутність Stats. Кожен з цих двох зв'язків має тип один до одного. Окрім того, персонаж має суворі зв'язки один до одного з сутностями CharacterBuild (білд), Attributes (динамічні ресурси) та Inventory (інвентар і золото). Відповідно, має зв'язок один до багатьох із CharacterSpell — персонаж може вивчити нуль або декілька заклять.

## CharacterBuild

Зберігає візуальні та рольові характеристики персонажа, задані під час створення або кастомізації. Головним ключем є id - int generated always as identity, а також має foreign key character_id - int NOT NULL UNIQUE до сутності Character (зв'язок строго один до одного). Визначає атрибути race - Race NOT NULL з доступними значеннями enum: Human, Orc, Elf, Dwarf, Khajiit, та skin_color_hex - char[7] NOT NULL для шістнадцяткового коду кольору шкіри. Також має sex - SEX NOT NULL (enum: Male, Female, Croissant, Non-binary) та class - CLASS NOT NULL для визначення ігрового класу (enum: Cleric, Fighter, Rogue, Wizard).

## Stats

Таблиця атрибутів базової бойової сили та фізичних або ментальних параметрів персонажа чи сутностей світу. Має головний ключ id - int generated always as identity. Зберігає показники у форматі int NOT NULL: strength (сила), dexterity (спритність/влучність), intelligence (інтелект), defense (захист/броня), agility (рухливість/швидкість реакції).

## Attributes

Зберігає динамічні ресурсні параметри персонажа, які змінюються в процесі гри. id є int generated always as identity, а character_id - int NOT NULL UNIQUE, що є foreign key до Character з кардинальністю один до одного. Також має атрибути experience - int NOT NULL default 0, max_hp - int NOT NULL, current_hp - int NOT NULL, max_mana - int NOT NULL та current_mana - int NOT NULL.

## Inventory

Описує персональне сховище предметів та фінанси конкретного персонажа. Відповідно є foreign key character_id int NOT NULL UNIQUE на сутність Character (один до одного) та головний ключ id - int generated always as identity. Окрім того, визначає gold - int NOT NULL default 0 для кількості золота та capacity - int NOT NULL DEFAULT 20 для місткості інвентарю.

## Spell

Каталог усіх доступних у грі заклять та магічних здібностей. Головним ключем цієї сутності є varchar[128] - таким чином кожне закляття ідентифікується унікальним рядком, наприклад fireball або heal. Окрім того є окремий атрибут name - varchar[128] NOT NULL для повноцінної назви закляття, що висвітлюється в інтерфейсі клієнта. Також є атрибут description - varchar[512] NOT NULL для повного опису дії, та mana_cost - int NOT NULL DEFAULT 0, що визначає вартість застосування.

## CharacterSpell

Асоціативна сутність для реалізації зв'язку багато до багатьох між Character та Spell. Відображає книгу вивчених заклять персонажа та їх прив'язку до панелі швидкого доступу. Має два атрибути, які є foreign key: character_id int NOT NULL та spell_id varchar[128] NOT NULL, а також slot_index - int NULL для номеру слота на панелі дії. Кардинальність з боку CharacterSpell до кожної з пов'язаних сутностей - строго один. При цьому одне й те саме закляття може бути вивчене багатьма персонажами (нуль або багато), а персонаж може мати нуль або багато вивчених заклять.
