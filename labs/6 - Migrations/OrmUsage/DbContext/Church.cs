using System;
using System.Collections.Generic;

namespace OrmUsage.DbContext;

public partial class Church
{
    public Guid Id { get; set; }

    public string Name { get; set; } = null!;

    public string Location { get; set; } = null!;

    public virtual ICollection<Worship> Worships { get; set; } = new List<Worship>();
}
