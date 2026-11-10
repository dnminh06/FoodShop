using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FoodOrderWPF.Models
{
    [Table("Users")]
    public class User
    {
        [Key]
        [Column("userID")]
        public int UserId { get; set; }

        [Required]
        [Column("fullName")]
        public string FullName { get; set; } = string.Empty;

        [Required]
        [Column("email")]
        public string Email { get; set; } = string.Empty;

        [Required]
        [Column("passwordHash")]
        public string PasswordHash { get; set; } = string.Empty;

        [Column("phoneNumber")]
        public string? PhoneNumber { get; set; }

        [Column("roleID")]
        public int RoleId { get; set; }

        public virtual ICollection<Order> Orders { get; set; } = new List<Order>();

        [NotMapped]
        public string RoleName
        {
            get
            {
                return RoleId switch
                {
                    1 => "Customer",
                    2 => "Restaurant Manager",
                    3 => "Shipper",
                    4 => "Admin",
                    _ => "Customer"
                };
            }
        }
    }
}
