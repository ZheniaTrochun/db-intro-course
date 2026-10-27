```mermaid

erDiagram

&#x20;   Order{

&#x20;       int OrderID PK

&#x20;       int CustomerID FK

&#x20;       date OrderDate

&#x20;       decimal TotalAmount

&#x09;}

&#x09;ItemQuantity{

&#x09;	int ItemQuantityID PK

&#x09;	int OrderID FK

&#x20;       int IngredientID FK

&#x09;	int Quantity

&#x09;	decimal PriceAtOrder

&#x09;}

&#x09;Ingredient{

&#x09;	int IngredientID PK

&#x09;	int CategoryID FK

&#x09;	string Name

&#x09;	decimal Price

&#x09;	decimal PackSize

&#x09;}

&#x09;Customer{

&#x09;	int CustomerID PK

&#x09;	string UserName

&#x09;	string Address

&#x09;	string PhoneNumber

&#x09;}

&#x09;Category{

&#x09;	int CategoryID PK

&#x09;	string Name

&#x09;	string Unit

&#x09;}

&#x09;Recipe{

&#x09;	int RecipeID PK

&#x09;	string Name

&#x09;	string EquipmentNote

&#x09;}

&#x09;RecipeItemQuantity{

&#x09;	int RecipeItemQuantityID PK

&#x09;	int RecipeID FK

&#x09;	int CategoryID FK

&#x09;	decimal RecipeItemAmount	

&#x09;}

&#x09;Taste{

&#x09;	int TasteID PK

&#x09;	string Name

&#x09;}

&#x09;RecipeTaste{

&#x09;	int RecipeTasteID PK

&#x09;	int RecipeID FK

&#x09;	int TasteID FK

&#x09;	string Intensity

&#x09;}	

&#x09;Order ||--|{ ItemQuantity : "contains"

&#x09;Ingredient ||--o{ ItemQuantity : "contains"

&#x09;Customer ||--o{ Order : "places"

&#x09;Category ||--o{ Ingredient : "groups"

&#x09;Recipe ||--|{ RecipeItemQuantity : "contains"

&#x09;Category ||--o{ RecipeItemQuantity : "contains"

&#x09;Recipe ||--|{ RecipeTaste : "contains"

&#x09;Taste ||--o{ RecipeTaste : "taste"

```

