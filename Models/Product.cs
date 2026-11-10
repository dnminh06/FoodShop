using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FoodOrderWPF.Models
{
    [Table("Products")]
    public class Product
    {
        [Key]
        [Column("productID")]
        public int ProductId { get; set; }

        [Column("restaurantID")]
        public int RestaurantId { get; set; }

        [Column("categoryID")]
        public int CategoryId { get; set; }

        [Required]
        [Column("name")]
        public string Name { get; set; } = string.Empty;

        [Column("price", TypeName = "decimal(18,2)")]
        public decimal Price { get; set; }

        [Column("description")]
        public string? Description { get; set; }

        [Column("imageURL")]
        public string? ImageUrl { get; set; }

        [ForeignKey(nameof(RestaurantId))]
        public virtual Restaurant? Restaurant { get; set; }

        [ForeignKey(nameof(CategoryId))]
        public virtual Category? Category { get; set; }

        public virtual ICollection<OrderDetail> OrderDetails { get; set; } = new List<OrderDetail>();

        [NotMapped]
        public string CategoryName => Category?.Name ?? $"Category #{CategoryId}";

        [NotMapped]
        public string RestaurantName => Restaurant?.Name ?? $"Restaurant #{RestaurantId}";
    }
}
