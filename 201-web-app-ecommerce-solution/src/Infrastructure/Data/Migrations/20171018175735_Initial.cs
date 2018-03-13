using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;
using System;
using System.Collections.Generic;

namespace Infrastructure.Data.Migrations
{
    public partial class Initial : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateSequence(
                name: "catalog_brand_hilo",
                incrementBy: 10);

            migrationBuilder.CreateSequence(
                name: "catalog_hilo",
                incrementBy: 10);

            migrationBuilder.CreateSequence(
                name: "catalog_type_hilo",
                incrementBy: 10);

            migrationBuilder.CreateTable(
                name: "Baskets",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    BuyerId = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Baskets", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "CatalogBrand",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false),
                    Brand = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CatalogBrand", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "CatalogType",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false),
                    Type = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CatalogType", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Orders",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    BuyerId = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    OrderDate = table.Column<DateTimeOffset>(type: "datetimeoffset", nullable: false),
                    ShipToAddress_City = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ShipToAddress_Country = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ShipToAddress_State = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ShipToAddress_Street = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ShipToAddress_ZipCode = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Status = table.Column<string>(type: "nvarchar(max)", nullable: true),
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Orders", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "BasketItem",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    BasketId = table.Column<int>(type: "int", nullable: true),
                    CatalogItemId = table.Column<int>(type: "int", nullable: false),
                    Quantity = table.Column<int>(type: "int", nullable: false),
                    UnitPrice = table.Column<decimal>(type: "decimal(18, 2)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BasketItem", x => x.Id);
                    table.ForeignKey(
                        name: "FK_BasketItem_Baskets_BasketId",
                        column: x => x.BasketId,
                        principalTable: "Baskets",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Catalog",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false),
                    CatalogBrandId = table.Column<int>(type: "int", nullable: false),
                    CatalogTypeId = table.Column<int>(type: "int", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Name = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    PictureUri = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Price = table.Column<decimal>(type: "decimal(18, 2)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Catalog", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Catalog_CatalogBrand_CatalogBrandId",
                        column: x => x.CatalogBrandId,
                        principalTable: "CatalogBrand",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Catalog_CatalogType_CatalogTypeId",
                        column: x => x.CatalogTypeId,
                        principalTable: "CatalogType",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "OrderItems",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    OrderId = table.Column<int>(type: "int", nullable: true),
                    UnitPrice = table.Column<decimal>(type: "decimal(18, 2)", nullable: false),
                    Units = table.Column<int>(type: "int", nullable: false),
                    ItemOrdered_CatalogItemId = table.Column<int>(type: "int", nullable: false),
                    ItemOrdered_PictureUri = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ItemOrdered_ProductName = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_OrderItems", x => x.Id);
                    table.ForeignKey(
                        name: "FK_OrderItems_Orders_OrderId",
                        column: x => x.OrderId,
                        principalTable: "Orders",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_BasketItem_BasketId",
                table: "BasketItem",
                column: "BasketId");

            migrationBuilder.CreateIndex(
                name: "IX_Catalog_CatalogBrandId",
                table: "Catalog",
                column: "CatalogBrandId");

            migrationBuilder.CreateIndex(
                name: "IX_Catalog_CatalogTypeId",
                table: "Catalog",
                column: "CatalogTypeId");

            migrationBuilder.CreateIndex(
                name: "IX_OrderItems_OrderId",
                table: "OrderItems",
                column: "OrderId");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "BasketItem");

            migrationBuilder.DropTable(
                name: "Catalog");

            migrationBuilder.DropTable(
                name: "OrderItems");

            migrationBuilder.DropTable(
                name: "Baskets");

            migrationBuilder.DropTable(
                name: "CatalogBrand");

            migrationBuilder.DropTable(
                name: "CatalogType");

            migrationBuilder.DropTable(
                name: "Orders");

            migrationBuilder.DropSequence(
                name: "catalog_brand_hilo");

            migrationBuilder.DropSequence(
                name: "catalog_hilo");

            migrationBuilder.DropSequence(
                name: "catalog_type_hilo");
        }
    }
}
