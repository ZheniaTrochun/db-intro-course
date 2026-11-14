using Microsoft.EntityFrameworkCore;

namespace OrmUsage.DbContext;

public partial class PostgresContext
{

    public virtual DbSet<GeneralNote> GeneralNotes { get; set; }
    
    partial void OnModelCreatingPartial(ModelBuilder modelBuilder)
    {
        // for future model changes
    }
}
