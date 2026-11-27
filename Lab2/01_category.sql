DROP TABLE IF EXISTS RecipeTaste;
DROP TABLE IF EXISTS RecipeItemQuantity;
DROP TABLE IF EXISTS Taste;
DROP TABLE IF EXISTS Recipe;
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
	UNIQUE (RecipeID, CategoryID)
);

CREATE TABLE RecipeTaste (
	RecipeTasteID SERIAL PRIMARY KEY,
	RecipeID INTEGER NOT NULL,
	TasteID INTEGER NOT NULL,
	FOREIGN KEY (RecipeID) REFERENCES Recipe(RecipeID),
	FOREIGN KEY (TasteID) REFERENCES Taste(TasteID),
	Intensity VARCHAR(10) NOT NULL CHECK (Intensity IN ('слабо', 'помірно', 'сильно')),
    UNIQUE (RecipeID, TasteID) 
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
	(1, 1, 'сильно'),
	(2, 2, 'помірно'),
	(3, 3, 'слабо');

	SELECT * FROM Category;
	SELECT * FROM Recipe;
	SELECT * FROM Taste;
	SELECT * FROM RecipeItemQuantity;
	SELECT * FROM RecipeTaste;