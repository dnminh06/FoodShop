using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FoodOrderWPF.Models
{
    [Table("OrderDetails")]
    public class OrderDetail
    {
        [Key]
        [Column("orderDetailID")]
        public int OrderDetailId { get; set; }

        [Column("orderID")]
        public int OrderId { get; set; }

        [Column("productID")]
        public int ProductId { get; set; }

        [Column("quantity")]
        public int Quantity { get; set; }

        [Column("unitPrice", TypeName = "decimal(18,2)")]
        public decimal UnitPrice { get; set; }

        [Column("priceAtOrder", TypeName = "decimal(18,2)")]
        public decimal PriceAtOrder { get; set; }

        [ForeignKey(nameof(OrderId))]
        public virtual Order? Order { get; set; }

        [ForeignKey(nameof(ProductId))]
        public virtual Product? Product { get; set; }

        [NotMapped]
        public string ProductName => Product?.Name ?? $"Product #{ProductId}";

        [NotMapped]
        public decimal SubTotal => Quantity * PriceAtOrder;
    }
}
