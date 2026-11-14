using System;
using System.Collections.Generic;

namespace OrmUsage.DbContext;

public partial class Worship
{
    public Guid Id { get; set; }

    public Guid ChurchId { get; set; }

    public DateTime Date { get; set; }

    public Guid TypeId { get; set; }

    public int? Views { get; set; }

    public int? Subscribers { get; set; }

    public string? Link { get; set; }

    public virtual Church Church { get; set; } = null!;

    public virtual ICollection<Singing> Singings { get; set; } = new List<Singing>();

    public virtual WorshipType Type { get; set; } = null!;
}
