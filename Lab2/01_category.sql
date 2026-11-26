DROP TABLE IF EXISTS Category CASCADE;
DROP TABLE IF EXISTS Recipe CASCADE;
DROP TABLE IF EXISTS Taste CASCADE;
DROP TABLE IF EXISTS RecipeItemQuantity CASCADE;
DROP TABLE IF EXISTS RecipeTaste CASCADE;

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
	RecipeItemAmount NUMERIC(8,2) NOT NULL CHECK(RecipeItemAmount > 0)
);

CREATE TABLE RecipeTaste (
	RecipeTasteID SERIAL PRIMARY KEY,
	RecipeID INTEGER NOT NULL,
	TasteID INTEGER NOT NULL,
	FOREIGN KEY (RecipeID) REFERENCES Recipe(RecipeID),
	FOREIGN KEY (TasteID) REFERENCES Taste(TasteID),
	Intensity NUMERIC(4,2) NOT NULL CHECK(Intensity > 0) 
);


INSERT INTO Category (Name, Unit)
VALUES
	('Борошно', 'кг'),
	('Цукор', 'кг'),
	('Масло', 'г');

INSERT INTO RECIPE (Name, EQUIPMENTNOTE)
VALUES 
	('Пиріг з яблуками', 'Використовувати духовку'),
	('Торт "Наполеон"', 'Використовувати міксер'),
	('Печиво "Орео"', 'Використовувати духовку');

	INSERT INTO TASTE (Name) 
	VALUES 
	('Солодкий'),
	('Гіркий'),
	('Солоний');

	INSERT INTO RecipeItemQuantity (RecipeID, CategoryID, RecipeItemAmount)
	VALUES 
	(1, 1, 0.50),
    (2, 2, 0.30),
    (3, 3, 200.00);

	INSERT INTO RecipeTaste (RecipeID, TasteID, Intensity)
	VALUES 
	(1, 1, 0.80),
	(2, 2, 0.60),
	(3, 3, 0.90);

	SELECT * FROM Category;
	SELECT * FROM Recipe;
	SELECT * FROM Taste;
	SELECT * FROM RecipeItemQuantity;
	SELECT * FROM RecipeTaste;