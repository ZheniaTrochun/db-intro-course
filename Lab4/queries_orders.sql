SELECT  --Загальна кількість замовлень
    COUNT(*) as TotalOrders
FROM Orders;

SELECT --Найбільше за прайсом замовлення
    MAX(TotalAmount) AS MaxTotalAmount
FROM Orders;