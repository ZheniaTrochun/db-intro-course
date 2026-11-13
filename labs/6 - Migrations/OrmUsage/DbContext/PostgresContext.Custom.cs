using Microsoft.EntityFrameworkCore;

namespace OrmUsage.DbContext;

public partial class PostgresContext
{
    partial void OnModelCreatingPartial(ModelBuilder modelBuilder)
    {
        // for future model changes
    }
}
