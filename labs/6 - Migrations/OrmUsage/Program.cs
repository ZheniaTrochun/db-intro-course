using OrmUsage.DbContext;

using var db = new PostgresContext();


Console.WriteLine(db.Churches.Count());