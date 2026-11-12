## 1. Кількість записів у `item`
```sql
select count(*) as item_count
from item;
```

## 2. Розподіл шаблонів предметів по інвентарях
```sql
select
    t.id as template_id,
    t.name as item_name,
    count(distinct i.inv_id) as inventory_count,
    coalesce(sum(i.quantity), 0) as total_quantity
from item_template as t
left join item as i ON i.item_tmpl_id = t.id
group by t.id, t.name
order by t.id;
```

## 3. `inner join`

```sql
select
    i.inv_id as inventory_id,
    i.inventory_slot,
    t.name as item_name,
    t.rarity,
    i.quantity
from item as i
INNER join item_template as t ON t.id = i.item_tmpl_id
order by i.inv_id, i.inventory_slot, i.id;
```

## 4. `left join`, шаблони, відсутні в інвентарях

```sql
select
    t.id as template_id,
    t.name as item_name,
    t.type
from item_template as t
left join item as i ON i.item_tmpl_id = t.id
where i.id is null
order by t.id;
```

## 5. Кількість предметів у світі

```sql
SELECT
    it.id,
    it.name,
    it.type,
    COALESCE(
        (SELECT SUM(i.quantity)
         FROM item i
         WHERE i.item_tmpl_id = it.id),
        0
    ) AS total_in_world
FROM item_template it
ORDER BY total_in_world DESC;
```

## 6. Предмет із найбільшою кількістю

```sql
SELECT
    c.name AS character_name,
    it.name AS item_name,
    it.type,
    i.quantity
FROM item i
JOIN item_template it ON it.id = i.item_tmpl_id
JOIN inventory inv ON inv.id = i.inv_id
JOIN character c ON c.id = inv.character_id
WHERE i.quantity = (SELECT MAX(quantity) FROM item);
```

## 7. Шаблони, що ніхто не продає

```sql
SELECT it.id, it.name, it.type
FROM item_template it
WHERE NOT EXISTS (
    SELECT 1
    FROM item i
    JOIN npc_item_relation r ON r.item_id = i.id
    WHERE i.item_tmpl_id = it.id
      AND r.trades = true
);
```
