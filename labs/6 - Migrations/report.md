# Звіт: Лабораторна 6 - Міграції схеми

## Міграції

| Міграція | Що змінилось |
|---|---|
| `20261114074539_InitialCreate` | базова, порожня |
| `20261114075101_GeneralNotes` | створено таблицю `GeneralNotes` (`Id` uuid PK, `Note` text, `CreatedAt` timestamptz) |
| `20261114075257_GeneralNotesName` | додано стовпець `Name` (text not null, default `''`) |
| `20261114075336_GeneralNotesNameRemoved` | видалено стовпець `Name` |

## Перевірка

`Program.cs` підключається до бази й читає дані:

```csharp
using var db = new PostgresContext();
Console.WriteLine(db.Churches.Count());
```

Запит виконується без помилок - з'єднання та читання працюють.


