# Laba 4

## 1. Aгрегаційні функції

### How many characters classes are present

```sql
select class, count(id) as character_count 
from character
group by class;
```

### How many spells each character has

```sql
select character_id, SUM(quantity) as total_spells_quantity
from character_spell
group by character_id;
```

### Display least and most expencive spells with average spell mana cost 

```sql
select 
  (select name from spell order by mana_cost ASC limit 1) as cheapest_spell,
    MIN(mana_cost) as min_mana_cost,
  (select name from spell order by mana_cost DESC limit 1) as most_expensive_spell,
  MAX(mana_cost) as max_mana_cost,
  AVG(mana_cost) as avg_mana_cost
from spell;
```

### Max mana of cleric, but must be above 70

``` sql
select class, MAX(max_mana) as highest_mana
from character
where class = 'cleric'
group by class
having MAX(max_mana) > 70;
```

## Йоінькс

### Display username, character name and class

``` sql
select u.username, c.name as character_name, c.class
from users u
inner join character c ON u.id = c.user_id;
```

### All spells and how many characters know that spell

```sql
select 
  s.name as spell_name, 
  COUNT(cs.character_id) as num_of_characters_with_spell
from spell s
left join character_spell cs ON s.id = cs.spell_id
group by s.id, s.name
order by COUNT(cs.character_id) DESC;
```

### Display Character id, name and level

```sql
select 
  c.id as character_id,
  c.name as character_name,
  we.level as character_level
from character c
right join world_entity we ON we.id = c.worldentity_id
where c.id IS NOT NULL;
```

## Subqueries

### All characters that knows the spell 'Fireball'

```sql
select id, name
from character
where id IN (
  select character_id
  from character_spell
  where spell_id = (
    select id from spell
    where name = 'Fireball'
  )
);
```

### Amount of unique spell

```sql
SELECT 
    name, 
    race,
    ( SELECT COUNT(*) 
      FROM character_spell 
      WHERE character_id = character.id ) AS unique_spells_known
FROM character;
```

### Race with greater avrg max_mana than overall avrg max_mana

```sql
select race, AVG(max_mana) as race_avg_mana
from character
group by race
having AVG(max_mana) > (select AVG(max_mana) from character);
```
