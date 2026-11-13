using System;
using System.Collections.Generic;

namespace OrmUsage.DbContext;

public partial class SongLanguage
{
    public Guid Id { get; set; }

    public string Language { get; set; } = null!;

    public virtual ICollection<Song> Songs { get; set; } = new List<Song>();
}
