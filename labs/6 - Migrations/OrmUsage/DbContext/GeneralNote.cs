namespace OrmUsage.DbContext;

public partial class GeneralNote
{
    public Guid Id { get; set; }

    public string Note { get; set; } = null!;

    public DateTime CreatedAt { get; set; }
}