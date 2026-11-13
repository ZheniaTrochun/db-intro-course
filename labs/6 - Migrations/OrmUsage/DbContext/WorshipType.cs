using System;
using System.Collections.Generic;

namespace OrmUsage.DbContext;

public partial class WorshipType
{
    public Guid Id { get; set; }

    public string Type { get; set; } = null!;

    public virtual ICollection<Worship> Worships { get; set; } = new List<Worship>();
}
