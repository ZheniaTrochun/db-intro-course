using System;
using System.Collections.Generic;

namespace OrmUsage.DbContext;

public partial class Singing
{
    public Guid Id { get; set; }

    public Guid WorshipId { get; set; }

    public Guid SongId { get; set; }

    public string? Performer { get; set; }

    public string? Note { get; set; }

    public virtual Song Song { get; set; } = null!;

    public virtual Worship Worship { get; set; } = null!;
}
