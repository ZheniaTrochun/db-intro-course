-- 1.

SELECT
  COUNT(*) AS items_count,
  SUM(price) AS total_price,
  ROUND(AVG(price), 2) AS avg_price,
  MIN(price) AS min_price,
  MAX(price) AS max_price
FROM wishlist_items

-- 2.

SELECT
  w.name AS wishlist_name,
  COUNT(wi.wishlist_id) AS items_count,
  SUM(wi.price) AS sum_price,
  AVG(wi.price) AS avg_price
FROM wishlists AS w
JOIN wishlist_items AS wi
  ON w.wishlist_id = wi.wishlist_id
GROUP BY w.wishlist_id
ORDER BY sum_price DESC

-- 3.

SELECT 
	w.wishlist_id,
	w.name AS wishlist_name,
	SUM(wi.price) AS sum_price
FROM wishlists AS w
JOIN wishlist_items AS wi
	ON w.wishlist_id = wi.wishlist_id
GROUP BY w.wishlist_id
HAVING SUM(wi.price) > 150

-- 4.

SELECT 
	u.name AS user_name,
	COUNT(w.wishlist_id) AS wishlists_quantity,
	COUNT(wi.item_id) AS wishlist_items_quantity,
	SUM(wi.price) AS total_price
FROM users AS u
LEFT JOIN wishlists AS w
	ON u.user_id = w.user_id
LEFT JOIN wishlist_items AS wi
	ON w.wishlist_id = wi.wishlist_id
GROUP BY u.user_id
ORDER BY total_price DESC

-- 5. 

SELECT
	wi.name AS wishlist_item_name,
	wi.price AS wishlist_item_price,
	w.name AS wishlist_name,
	u.name AS user_name
FROM wishlist_items AS wi
JOIN wishlists AS w
	ON wi.wishlist_id = wi.wishlist_id
JOIN users AS u
	ON w.user_id = u.user_id

-- 6.

SELECT 
	u.name AS user_name,
	COUNT(DISTINCT w.wishlist_id) AS wishlists_quantity,
	ROUND(AVG(wi.price), 2) AS avarage_items_price
FROM users AS u
LEFT JOIN wishlists AS w
	ON u.user_id = w.user_id
LEFT JOIN wishlist_items AS wi
	ON w.wishlist_id = wi.wishlist_id
GROUP BY u.name

-- 7.

SELECT 
	u.name AS user_name,
	wi.name AS item_name
FROM reservations AS r
RIGHT JOIN wishlist_items AS wi
	ON r.item_id = wi.item_id
RIGHT JOIN users AS u
	ON r.user_id = u.user_id

-- 8.

SELECT 
	name,
	price
FROM wishlist_items
WHERE price > (
	SELECT AVG(price)
	FROM wishlist_items
)

-- 9.

SELECT 
	w.name AS wishlist_name,
	u.name AS user_name,
	(
		SELECT COUNT(*)
		FROM wishlist_items AS wi
		WHERE w.wishlist_id = wi.wishlist_id
	) AS items_count
FROM wishlists AS w
JOIN users AS u
	ON w.user_id = u.user_id

-- 10.

SELECT 
	w.name,
	ROUND(AVG(wi.price), 2) AS avarage_price
FROM wishlists AS w
JOIN wishlist_items AS wi
	ON w.wishlist_id = wi.wishlist_id
GROUP BY w.wishlist_id
HAVING ROUND(AVG(wi.price), 2) > (
	SELECT AVG(price)
	FROM wishlist_items
)

-- 11.

SELECT 
	w.name AS wishlist_name,
	MIN(wi.price) AS min_price,
	MAX(wi.price) AS max_price,
	(MAX(wi.price) - MIN(wi.price)) AS price_difference
FROM wishlists AS w
JOIN wishlist_items AS wi
	ON w.wishlist_id = wi.wishlist_id
GROUP BY w.wishlist_id

-- 12.

SELECT
	u.name AS user_name,
	w.name AS wishlist_name
FROM users AS u
CROSS JOIN wishlists AS w
WHERE u.user_id != w.user_id
	AND w.is_public = TRUE
ORDER BY u.name ASC

-- 13.

SELECT name
FROM users
WHERE user_id IN (
	SELECT user_id
	FROM reservations
)

SELECT name
FROM users AS u
WHERE EXISTS (
    SELECT 1
    FROM reservations AS r
    WHERE r.user_id = u.user_id
);
