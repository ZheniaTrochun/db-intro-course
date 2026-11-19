-- Запит 3.1: пошук товарів дорожчого сегменту

SELECT GoodName, GoodPrice
FROM Good
WHERE GoodPrice > (SELECT AVG(GoodPrice) FROM Good);

-- Запит 3.2: підрахунок загальних витрат кожного клієнта

SELECT 
    c.CustomerName,
    (SELECT SUM(OrderPrice) FROM public.order o WHERE o.CustomerID = c.CustomerID) AS Total_Spent
FROM Customer c;

-- Запит 3.3: виявлення клієнтів із витратами вище середнього чека

SELECT 
    CustomerID, 
    SUM(OrderPrice) AS Total_Client_Spent
FROM public.order
GROUP BY CustomerID
HAVING SUM(OrderPrice) > (SELECT AVG(OrderPrice) FROM public.order);