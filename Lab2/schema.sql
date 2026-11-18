DROP TABLE IF EXISTS ItemQuantity;
DROP TABLE IF EXISTS RecipeTaste;
DROP TABLE IF EXISTS RecipeItemQuantity;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Ingredient;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS Recipe;
DROP TABLE IF EXISTS Taste;
DROP TABLE IF EXISTS Category;

CREATE TABLE Category (
CategoryID SERIAL PRIMARY KEY,
Name VARCHAR (100) NOT NULL,
Unit VARCHAR (20) NOT NULL 
);

CREATE TABLE Recipe (
	RecipeID SERIAL PRIMARY KEY,
	Name VARCHAR(100) NOT NULL,
	EQUIPMENTNOTE VARCHAR(100)
);

CREATE TABLE Taste (
	TasteID SERIAL PRIMARY KEY,
	Name VARCHAR(100) NOT NULL
);

CREATE TABLE RecipeItemQuantity (
	RecipeItemQuantityID SERIAL PRIMARY KEY,
	RecipeID INTEGER NOT NULL,
	CategoryID INTEGER NOT NULL,
	FOREIGN KEY (RecipeID) REFERENCES Recipe(RecipeID),
	FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID),
	RecipeItemAmount NUMERIC(8,3) NOT NULL CHECK(RecipeItemAmount > 0),
    UNIQUE(RecipeID, CategoryID)
);

CREATE TABLE RecipeTaste (
	RecipeTasteID SERIAL PRIMARY KEY,
	RecipeID INTEGER NOT NULL,
	TasteID INTEGER NOT NULL,
	FOREIGN KEY (RecipeID) REFERENCES Recipe(RecipeID),
	FOREIGN KEY (TasteID) REFERENCES Taste(TasteID),
	Intensity VARCHAR(10) NOT NULL CHECK(Intensity IN ('слабо','помірно','сильно')),
    UNIQUE (RecipeID, TasteID)
);

CREATE TABLE Customer(
    CustomerID SERIAL PRIMARY KEY,
    UserName VARCHAR(50) NOT NULL,
    Address VARCHAR(200) NOT NULL,
    PhoneNumber VARCHAR(20) NOT NULL
);
CREATE TABLE Orders(
    OrderID SERIAL PRIMARY KEY,
    CustomerID INTEGER NOT NULL,
    OrderDate DATE NOT NULL,
    TotalAmount NUMERIC(8,2) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) 
);
CREATE TABLE Ingredient(
    IngredientID SERIAL PRIMARY KEY,
    CategoryID INTEGER NOT NULL,
    Name VARCHAR(50) NOT NULL,
    Price NUMERIC(8,2) NOT NULL CHECK(Price > 0),
    PackSize NUMERIC(8,3) NOT NULL CHECK(PackSize > 0),
    FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID)
);
CREATE TABLE ItemQuantity(
    ItemQuantityID SERIAL PRIMARY KEY,
    OrderID INTEGER NOT NULL,
    IngredientID INTEGER NOT NULL,
    Quantity INTEGER NOT NULL CHECK(Quantity > 0),
    PriceAtOrder NUMERIC(8,2) NOT NULL CHECK(PriceAtOrder > 0),
    FOREIGN KEY(OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY(IngredientID) REFERENCES Ingredient(IngredientID),
    UNIQUE (OrderID, IngredientID)
);
INSERT INTO Category (Name, Unit)
VALUES
	('Борошно', 'кг'),
	('Цукор', 'кг'),
	('Масло', 'г');
    ('Яйця', 'шт'),
    ('Молоко', 'мл');

INSERT INTO Recipe (Name, EquipmentNote)
VALUES 
	('Пиріг з яблуками', 'Використовувати духовку'),
	('Торт "Наполеон"', 'Використовувати міксер'),
	('Печиво "Орео"', 'Використовувати духовку');
    ('Млинці', 'Використовувати сковорідку'),
    ('Бісквітний рулет', 'Використовувати духовку'),
    ('Заварний крем', NULL);

INSERT INTO Taste (Name) 
VALUES 
	('Солодкий'),
	('Гіркий'),
	('Солоний');
    ('Кислий'),
    ('Пряний');

INSERT INTO RecipeItemQuantity (RecipeID, CategoryID, RecipeItemAmount)
VALUES 
	(1, 1, 0.50),
    (2, 2, 0.30),
    (3, 3, 200.00);
    (1, 2, 0.15),
    (1, 4, 3),
    (2, 1, 0.40),
    (2, 3, 250.00),
    (2, 4, 4),
    (3, 1, 0.30),
    (3, 2, 0.10),
    (4, 1, 0.25),
    (4, 4, 2),
    (4, 5, 500.00),
    (5, 1, 0.20),
    (5, 2, 0.15),
    (5, 4, 5),
    (6, 2, 0.10),
    (6, 4, 3),
    (6, 5, 400.00);

INSERT INTO RecipeTaste (RecipeID, TasteID, Intensity)
VALUES 
	(1, 1, 'слабо'),
	(2, 2, 'сильно'),
	(3, 3, 'помірно');
    (1, 4, 'помірно'),
    (2, 1, 'сильно'),
    (3, 1, 'помірно'),
    (3, 2, 'слабо'),
    (4, 1, 'слабо'),
    (5, 1, 'сильно'),
    (6, 1, 'сильно'),
    (6, 3, 'слабо');

INSERT INTO Customer (UserName, Address, PhoneNumber)
VALUES 
    ('Olena', 'Kyiv, Khreshchatyk 1', '+380501112233'),
    ('Dmitro', 'Kyiv, Bankova 1', '+380063322111'),
    ('Volodymir', 'Dnipro, Dynamo 100', '+380072233111');
    ('Anna', 'Lviv, Rynok 5', '+380931234567'),
    ('Taras', 'Kharkiv, Sumska 10', '+380672345678'),
    ('Iryna', 'Odesa, Derybasivska 3', '+380983456789');

INSERT INTO Orders ( CustomerID, OrderDate, TotalAmount)
VALUES
    (1, '2026-09-18', 241),
    (2, '2025-10-10', 390),
    (3, '2024-12-25', 214.16);
    (1, '2026-10-05', 323.08),
    (1, '2026-11-02', 276.10),
    (2, '2026-09-21', 207.80),
    (4, '2026-10-14', 473.62),
    (4, '2026-11-10', 260.00),
    (5, '2026-11-15', 398.90);

INSERT INTO Ingredient (CategoryID, Name, Price, PackSize)
Values
    (1, 'Борошно Хуторок вищий сорт', 53.54, 1.5),
    (2, 'Цукор Повна Чаша білий кристалічний', 120.50, 0.8),
    (3, 'Масло Яготинське 72%', 130, 870);
    (4, 'Яйця курячі С1', 72.00, 10),
    (5, 'Молоко Яготинське 2.6%', 38.90, 900);

INSERT INTO ItemQuantity (OrderID, IngredientID, Quantity, PriceAtOrder)
Values
    (1, 2, 2, 120.50),
    (2, 3, 3, 130),
    (3, 1, 4, 53.54);
    (4, 1, 2, 53.54),
    (4, 4, 3, 72.00),
    (5, 5, 4, 38.90),
    (5, 2, 1, 120.50),
    (6, 3, 1, 130.00),
    (6, 5, 2, 38.90),
    (7, 1, 3, 53.54),
    (7, 2, 2, 120.50),
    (7, 4, 1, 72.00),
    (8, 3, 2, 130.00),
    (9, 4, 5, 72.00),
    (9, 5, 1, 38.90);
    
SELECT * FROM Category;
SELECT * FROM Recipe;
SELECT * FROM Taste;
SELECT * FROM RecipeItemQuantity;
SELECT * FROM RecipeTaste;
SELECT * FROM Customer;
SELECT * FROM Orders;
SELECT * FROM Ingredient;
SELECT * FROM ItemQuantity;