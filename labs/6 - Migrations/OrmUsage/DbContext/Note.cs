using System;
using System.Collections.Generic;

namespace OrmUsage.DbContext;

public partial class Note
{
    public Guid Id { get; set; }

    public Guid SongId { get; set; }

    public string Note1 { get; set; } = null!;

    public virtual Song Song { get; set; } = null!;
}
