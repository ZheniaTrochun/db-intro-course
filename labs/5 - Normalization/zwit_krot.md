Проблемна таблиця (порушення 1NF через JSONs):

```sql
create table item (
    id int generated always as identity primary key,
    item_tmpl_id int not null references item_template(id),
    inv_id int not null references inventory(id),
    inventory_slot smallint not null,
    quantity smallint not null default 1,
    attributes jsonb,
    enchantments jsonb
);
```
## 1NF

Для компенсації attributes вирішено створити додаткові поля, які можуть бути null, але у контексті логіки продукту є найпродуктивнішим варіантом (найшвидший доступ до даних без додаткових джоінів). Для компенсації enchantments вирішено створити окрему таблицю enchantment, яка буде містити всі enchantments для item.

```sql
alter table item
    add column damage int check (damage >= 0),
    add column attack_speed numeric check (attack_speed > 0),
    add column protect int check (protect >= 0),
    add column up_health int check (up_health >= 0);

create table enchantment (
    item_id int primary key references item(id) on delete cascade,
    ench_level int not null check (ench_level > 0),
    effect varchar(255) not null
);

alter table item
    drop column attributes,
    drop column enchantments;
```

## 2NF
```text
item(id [pk], item_tmpl_id [fk], inv_id [fk], inventory_slot,
     quantity, damage, attack_speed, protect, up_health)

enchantment(item_id [pk, fk → item.id], ench_level, effect)
```

## 3NF

`item`:

id → item_tmpl_id
id → inv_id
id → inventory_slot
id → quantity
id → damage
id → attack_speed
id → protect
id → up_health

`enchantment`:

item_id → ench_level
item_id → effect

