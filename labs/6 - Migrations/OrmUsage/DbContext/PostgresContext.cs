using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace OrmUsage.DbContext;

public partial class PostgresContext : Microsoft.EntityFrameworkCore.DbContext
{
    public PostgresContext()
    {
    }

    public PostgresContext(DbContextOptions<PostgresContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Church> Churches { get; set; }

    public virtual DbSet<Note> Notes { get; set; }

    public virtual DbSet<Singing> Singings { get; set; }

    public virtual DbSet<Song> Songs { get; set; }

    public virtual DbSet<SongLanguage> SongLanguages { get; set; }

    public virtual DbSet<Worship> Worships { get; set; }

    public virtual DbSet<WorshipType> WorshipTypes { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseNpgsql("Host=localhost;Port=5432;Database=postgres;Username=postgres;Password=password");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Church>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("church_pkey");

            entity.ToTable("church");

            entity.HasIndex(e => new { e.Name, e.Location }, "church_name_location_key").IsUnique();

            entity.Property(e => e.Id)
                .HasDefaultValueSql("gen_random_uuid()")
                .HasColumnName("id");
            entity.Property(e => e.Location)
                .HasMaxLength(128)
                .HasColumnName("location");
            entity.Property(e => e.Name)
                .HasMaxLength(128)
                .HasColumnName("name");
        });

        modelBuilder.Entity<Note>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("note_pkey");

            entity.ToTable("note");

            entity.Property(e => e.Id)
                .HasDefaultValueSql("gen_random_uuid()")
                .HasColumnName("id");
            entity.Property(e => e.Note1)
                .HasMaxLength(2048)
                .HasColumnName("note");
            entity.Property(e => e.SongId).HasColumnName("song_id");

            entity.HasOne(d => d.Song).WithMany(p => p.Notes)
                .HasForeignKey(d => d.SongId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("note_song_id_fkey");
        });

        modelBuilder.Entity<Singing>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("singing_pkey");

            entity.ToTable("singing");

            entity.Property(e => e.Id)
                .HasDefaultValueSql("gen_random_uuid()")
                .HasColumnName("id");
            entity.Property(e => e.Note)
                .HasMaxLength(512)
                .HasColumnName("note");
            entity.Property(e => e.Performer)
                .HasMaxLength(256)
                .HasColumnName("performer");
            entity.Property(e => e.SongId).HasColumnName("song_id");
            entity.Property(e => e.WorshipId).HasColumnName("worship_id");

            entity.HasOne(d => d.Song).WithMany(p => p.Singings)
                .HasForeignKey(d => d.SongId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("singing_song_id_fkey");

            entity.HasOne(d => d.Worship).WithMany(p => p.Singings)
                .HasForeignKey(d => d.WorshipId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("singing_worship_id_fkey");
        });

        modelBuilder.Entity<Song>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("song_pkey");

            entity.ToTable("song");

            entity.Property(e => e.Id)
                .HasDefaultValueSql("gen_random_uuid()")
                .HasColumnName("id");
            entity.Property(e => e.Author)
                .HasMaxLength(256)
                .HasColumnName("author");
            entity.Property(e => e.HasAuthor).HasColumnName("has_author");
            entity.Property(e => e.IsAi).HasColumnName("is_ai");
            entity.Property(e => e.IsTranslated).HasColumnName("is_translated");
            entity.Property(e => e.LanguageId).HasColumnName("language_id");
            entity.Property(e => e.Lyrics)
                .HasMaxLength(1024)
                .HasColumnName("lyrics");
            entity.Property(e => e.Name)
                .HasMaxLength(128)
                .HasColumnName("name");
            entity.Property(e => e.Translator)
                .HasMaxLength(256)
                .HasColumnName("translator");

            entity.HasOne(d => d.Language).WithMany(p => p.Songs)
                .HasForeignKey(d => d.LanguageId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("song_language_id_fkey");
        });

        modelBuilder.Entity<SongLanguage>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("song_language_pkey");

            entity.ToTable("song_language");

            entity.HasIndex(e => e.Language, "song_language_language_key").IsUnique();

            entity.Property(e => e.Id)
                .HasDefaultValueSql("gen_random_uuid()")
                .HasColumnName("id");
            entity.Property(e => e.Language)
                .HasMaxLength(128)
                .HasColumnName("language");
        });

        modelBuilder.Entity<Worship>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("worship_pkey");

            entity.ToTable("worship");

            entity.Property(e => e.Id)
                .HasDefaultValueSql("gen_random_uuid()")
                .HasColumnName("id");
            entity.Property(e => e.ChurchId).HasColumnName("church_id");
            entity.Property(e => e.Date)
                .HasColumnType("timestamp without time zone")
                .HasColumnName("date");
            entity.Property(e => e.Link)
                .HasMaxLength(256)
                .HasColumnName("link");
            entity.Property(e => e.Subscribers).HasColumnName("subscribers");
            entity.Property(e => e.TypeId).HasColumnName("type_id");
            entity.Property(e => e.Views).HasColumnName("views");

            entity.HasOne(d => d.Church).WithMany(p => p.Worships)
                .HasForeignKey(d => d.ChurchId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("worship_church_id_fkey");

            entity.HasOne(d => d.Type).WithMany(p => p.Worships)
                .HasForeignKey(d => d.TypeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("worship_type_id_fkey");
        });

        modelBuilder.Entity<WorshipType>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("worship_types_pkey");

            entity.ToTable("worship_types");

            entity.HasIndex(e => e.Type, "worship_types_type_key").IsUnique();

            entity.Property(e => e.Id)
                .HasDefaultValueSql("gen_random_uuid()")
                .HasColumnName("id");
            entity.Property(e => e.Type)
                .HasMaxLength(128)
                .HasColumnName("type");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
