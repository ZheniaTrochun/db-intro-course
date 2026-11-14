using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace OrmUsage.Migrations
{
    /// <inheritdoc />
    public partial class GeneralNotesName : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Name",
                table: "GeneralNotes",
                type: "text",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Name",
                table: "GeneralNotes");
        }
    }
}
