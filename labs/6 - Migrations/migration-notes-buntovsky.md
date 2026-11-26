## міграція add-world-event-table

Додає таблицю world_event початково з полями id, title, starts_at, ends_at, zone_id references zone

## міграція add_world_event_is_active

Додає до world_event булеве поле is_active

## міграція add_world_event_remove_ends_at

Видаляє поле ends_at з world_event

[Пруф](buntovsky/proof.png)
