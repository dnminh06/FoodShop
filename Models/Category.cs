using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FoodOrderWPF.Models
{
    [Table("Categories")]
    public class Category
    {
        [Key]
        [Column("categoryID")]
        public int CategoryId { get; set; }

        [Required]
        [Column("name")]
        public string Name { get; set; } = string.Empty;

        public virtual ICollection<Product> Products { get; set; } = new List<Product>();
    }
}
