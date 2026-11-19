-- Запит 2.1: список клієнтів та їхніх замовлень

SELECT 
    c.CustomerName,
    o.OrderID,
    o.OrderPrice
FROM Customer c
INNER JOIN public.order o ON c.CustomerID = o.CustomerID; 

-- Запит 2.2: усі клієнти та залишені ними відгуки

SELECT 
    c.CustomerName,
    r.ReviewText,
    r.ReviewGrade
FROM Customer c
LEFT JOIN Review r ON c.CustomerID = r.CustomerID;

-- Запит 2.3: усі товари та статистика їхньої наявності в замовленнях

SELECT 
    g.GoodName,
    oi.OrderID,
    oi.Quantity
FROM OrderItem oi
RIGHT JOIN Good g ON oi.GoodID = g.GoodID;