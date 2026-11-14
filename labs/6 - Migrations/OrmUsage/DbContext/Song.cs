using System;
using System.Collections.Generic;

namespace OrmUsage.DbContext;

public partial class Song
{
    public Guid Id { get; set; }

    public string Name { get; set; } = null!;

    public string? Author { get; set; }

    public bool HasAuthor { get; set; }

    public string? Translator { get; set; }

    public bool IsTranslated { get; set; }

    public string Lyrics { get; set; } = null!;

    public bool IsAi { get; set; }

    public Guid LanguageId { get; set; }

    public virtual SongLanguage Language { get; set; } = null!;

    public virtual ICollection<Note> Notes { get; set; } = new List<Note>();

    public virtual ICollection<Singing> Singings { get; set; } = new List<Singing>();
}
