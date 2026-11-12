

### 1. Загальна кількість замовлень
**Опис:** Підраховує загальну кількість записів (замовлень) у таблиці `orders`.  
**Мета:** Щоб швидко дізнатися загальний обсяг усіх оформлених замовлень у магазині.

```sql
SELECT count(orders.order_id) AS total_orders
FROM orders; 
```

---

### 2. Популярність методів доставки
**Опис:** Групує замовлення за методом доставки та підраховує їхню кількість, залишаючи лише ті методи, які було обрано 2 рази чи більше.  
**Мета:** Щоб виявити найбільш популярні способи доставки.

```sql
SELECT o.shipping_method, count(shipping_method) AS count_deliver
FROM orders o
GROUP BY shipping_method
HAVING count(shipping_method) >= 2;
```

---

### 3. Обсяг продажів кожного товару
**Опис:** Підраховує загальну кількість проданих одиниць кожного товару, підсумовуючи кількість в усіх замовленнях (`SUM`) та групуючи за ID продукту (`GROUP BY`).  
**Мета:** Це допомагає визначити найбільш популярні товари за обсягом продажів.

```sql
SELECT product_id, sum(quantity) AS product_in_all_orders
FROM order_product
GROUP BY product_id;
```

---

### 4. Сезонність та динаміка замовлень
**Опис:** Витягує номер місяця з дати кожного замовлення (`EXTRACT`), групує їх за цими місяцями та рахує загальну кількість замовлень у кожному періоді (`COUNT`).  
**Мета:** Це дозволяє аналізувати сезонність та динаміку продажу протягом року.

```sql
SELECT EXTRACT(MONTH FROM o.order_date) AS month, count(order_id) AS order_in_month
FROM orders o
GROUP BY EXTRACT(MONTH FROM o.order_date);
```

---

### 5. Список клієнтів та їхніх міст
**Опис:** Виводить імена всіх клієнтів та їхні міста. Завдяки `RIGHT JOIN` у результат потраплять усі клієнти, навіть якщо для них у базі не вказано жодної адреси.  
**Мета:** Щоб отримати повний список клієнтів разом із даними про їхнє місцезнаходження.

```sql
SELECT c.name, a.city
FROM address a
RIGHT JOIN customer c ON a.customer_id = c.customer_id;
```

---

### 6. Кількість замовлень по кожному клієнту
**Опис:** З'єднує таблиці замовлень і клієнтів та підраховує, скільки всього замовлень зробив кожен клієнт.  
**Мета:** Щоб дивитися статистику замовлень клієнтів.

```sql
SELECT c.name, count(o.order_id) AS order_count
FROM orders o
JOIN customer c ON o.customer_id = c.customer_id
GROUP BY c.name;
```

---

### 7. Наявність контактних та платіжних даних клієнта
**Опис:** Для кожного клієнта рахує унікальну кількість доданих адрес та унікальну кількість платіжних методів. `LEFT JOIN` зберігає всіх клієнтів у списку.  
**Мета:** Щоб побачити чи є у клієнта адреси/платіжні дані.

```sql
SELECT 
    c.name, 
    count(DISTINCT a.address_id) AS address_count, 
    count(DISTINCT pd.payment_data_id) AS payment_count
FROM customer c
LEFT JOIN address a ON c.customer_id = a.customer_id
LEFT JOIN payment_data pd ON c.customer_id = pd.customer_id
GROUP BY c.name;
```

---

### 8. Товар із максимальною ціною
**Опис:** Знаходить максимальну ціну серед усіх товарів за допомогою підзапиту.  
**Мета:** Вивести назву та ціну найдорожчого товару в магазині.

```sql
SELECT name, price
FROM product
WHERE price = (SELECT max(price) FROM product);
```

---

### 9. Клієнти, які робили замовлення
**Опис:** Обирає лише тих кастомерів, які щось замовляли. Обирає імена кастомерів, чиї ID є у списку замовлень.  
**Мета:** Відфільтрувати активних клієнтів від тих, хто ще не зробив жодної покупки.

```sql
SELECT name
FROM customer
WHERE customer_id IN (SELECT customer_id FROM orders);
```

---

### 10. Товари з ціною вище середньої
**Опис:** Рахує середню ціну усіх товарів, а потім виводить ціну лише тих товарів, значення яких більше за середнє.  
**Мета:** Знайти товари, що коштують дорожче за середній показник по магазину.

```sql
SELECT name, price
FROM product
WHERE price > (SELECT avg(price) FROM product);
```