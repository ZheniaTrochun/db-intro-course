# Лабораторна робота № 4

## Запити з агрегатними функціями

### Знайти середній рівень монстра у світі

```sql
select avg(we.level)
from monster_entity me
join world_entity we on me.entity_id = we.id;
```

### Порахувати кількість зон

```sql
select count(*)
from zone;
```

### Порахувати кількість дропів кожного монстра

```sql
select mt.name, count(*)
from monster_drop md
join monster_type mt on md.monster_id = mt.id
group by mt.id;
```

### Знайти зону з найменшим необхідним рівнем

```sql
select *
from zone
where level_requirement = (select min(level_requirement) from zone);
```

## Джойни

### Вивести назву та опис усіх монстрів, які зараз реально існують у світі

```sql
select mt.name as monster_name, mt.description, we.level, we.max_hp
from monster_entity me
inner join world_entity we on me.entity_id = we.id
inner join monster_type mt on me.type_id = mt.id;
```

### Вивести усі зони та кількість монстрів у кожній із них

```sql
select z.zone_name, z.level_requirement, count(we.id) as monster_count
from zone z
left join world_entity we on z.id = we.zone_id
left join monster_entity me on we.id = me.entity_id
group by z.id, z.zone_name, z.level_requirement
order by z.level_requirement;
```

### Перевірка наявності зв'язків між усіма типами монстрів та їх можливим дропом

```sql
select mt.name as monster_type, md.item_id
from monster_type mt
full join monster_drop md on mt.id = md.monster_id;
```

## Запити з підзапитами

### Знайти всіх монстрів, рівень яких вище за середній по існуючим монстрам

```sql
select we.id, mt.name, we.level
from monster_entity me
join world_entity we on me.entity_id = we.id
join monster_type mt on me.type_id = mt.id
where we.level > (
    select avg(level) 
    from world_entity
);
```

### Для кожного NPC вивести різницю його рівня з середнім рівнем по всім зонам

```sql
select 
    n.name as npc_name, 
    z.zone_name, 
    z.level_requirement,
    (z.level_requirement - (select avg(level_requirement) from zone)) as diff_from_avg
from npc n
join world_entity we on n.entity_id = we.id
join zone z on we.zone_id = z.id;
```

### Зони, де максимальний запас здоров'я сутностей вищий за середній показник по світу

```sql
select z.zone_name, sum(we.max_hp) as total_hp
from zone z
join world_entity we on z.id = we.zone_id
group by z.id, z.zone_name
having sum(we.max_hp) > (
    select avg(zone_hp) from (
        select sum(max_hp) as zone_hp 
        from world_entity 
        group by zone_id
    ) as sub
);
```
