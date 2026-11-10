using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FoodOrderWPF.Models
{
    [Table("Restaurants")]
    public class Restaurant
    {
        [Key]
        [Column("restaurantID")]
        public int RestaurantId { get; set; }

        [Column("managerID")]
        public int ManagerId { get; set; }

        [Required]
        [Column("name")]
        public string Name { get; set; } = string.Empty;

        [Required]
        [Column("address")]
        public string Address { get; set; } = string.Empty;

        [Column("openingHours")]
        public string? OpeningHours { get; set; }

        [Column("status")]
        public string? Status { get; set; }

        public virtual ICollection<Product> Products { get; set; } = new List<Product>();
    }
}
