using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace OrmUsage.Migrations
{
    /// <inheritdoc />
    public partial class InitalCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "church",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    name = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    location = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("church_pkey", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "song_language",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    language = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("song_language_pkey", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "worship_types",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    type = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("worship_types_pkey", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "song",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    name = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    author = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: true),
                    has_author = table.Column<bool>(type: "boolean", nullable: false),
                    translator = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: true),
                    is_translated = table.Column<bool>(type: "boolean", nullable: false),
                    lyrics = table.Column<string>(type: "character varying(1024)", maxLength: 1024, nullable: false),
                    is_ai = table.Column<bool>(type: "boolean", nullable: false),
                    language_id = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("song_pkey", x => x.id);
                    table.ForeignKey(
                        name: "song_language_id_fkey",
                        column: x => x.language_id,
                        principalTable: "song_language",
                        principalColumn: "id");
                });

            migrationBuilder.CreateTable(
                name: "worship",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    church_id = table.Column<Guid>(type: "uuid", nullable: false),
                    date = table.Column<DateTime>(type: "timestamp without time zone", nullable: false),
                    type_id = table.Column<Guid>(type: "uuid", nullable: false),
                    views = table.Column<int>(type: "integer", nullable: true),
                    subscribers = table.Column<int>(type: "integer", nullable: true),
                    link = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("worship_pkey", x => x.id);
                    table.ForeignKey(
                        name: "worship_church_id_fkey",
                        column: x => x.church_id,
                        principalTable: "church",
                        principalColumn: "id");
                    table.ForeignKey(
                        name: "worship_type_id_fkey",
                        column: x => x.type_id,
                        principalTable: "worship_types",
                        principalColumn: "id");
                });

            migrationBuilder.CreateTable(
                name: "note",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    song_id = table.Column<Guid>(type: "uuid", nullable: false),
                    note = table.Column<string>(type: "character varying(2048)", maxLength: 2048, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("note_pkey", x => x.id);
                    table.ForeignKey(
                        name: "note_song_id_fkey",
                        column: x => x.song_id,
                        principalTable: "song",
                        principalColumn: "id");
                });

            migrationBuilder.CreateTable(
                name: "singing",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    worship_id = table.Column<Guid>(type: "uuid", nullable: false),
                    song_id = table.Column<Guid>(type: "uuid", nullable: false),
                    performer = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: true),
                    note = table.Column<string>(type: "character varying(512)", maxLength: 512, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("singing_pkey", x => x.id);
                    table.ForeignKey(
                        name: "singing_song_id_fkey",
                        column: x => x.song_id,
                        principalTable: "song",
                        principalColumn: "id");
                    table.ForeignKey(
                        name: "singing_worship_id_fkey",
                        column: x => x.worship_id,
                        principalTable: "worship",
                        principalColumn: "id");
                });

            migrationBuilder.CreateIndex(
                name: "church_name_location_key",
                table: "church",
                columns: new[] { "name", "location" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_note_song_id",
                table: "note",
                column: "song_id");

            migrationBuilder.CreateIndex(
                name: "IX_singing_song_id",
                table: "singing",
                column: "song_id");

            migrationBuilder.CreateIndex(
                name: "IX_singing_worship_id",
                table: "singing",
                column: "worship_id");

            migrationBuilder.CreateIndex(
                name: "IX_song_language_id",
                table: "song",
                column: "language_id");

            migrationBuilder.CreateIndex(
                name: "song_language_language_key",
                table: "song_language",
                column: "language",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_worship_church_id",
                table: "worship",
                column: "church_id");

            migrationBuilder.CreateIndex(
                name: "IX_worship_type_id",
                table: "worship",
                column: "type_id");

            migrationBuilder.CreateIndex(
                name: "worship_types_type_key",
                table: "worship_types",
                column: "type",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "note");

            migrationBuilder.DropTable(
                name: "singing");

            migrationBuilder.DropTable(
                name: "song");

            migrationBuilder.DropTable(
                name: "worship");

            migrationBuilder.DropTable(
                name: "song_language");

            migrationBuilder.DropTable(
                name: "church");

            migrationBuilder.DropTable(
                name: "worship_types");
        }
    }
}
