using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FoodOrderWPF.Models
{
    [Table("Orders")]
    public class Order
    {
        [Key]
        [Column("orderID")]
        public int OrderId { get; set; }

        [Column("userID")]
        public int UserId { get; set; }

        [Column("addressID")]
        public int? AddressId { get; set; }

        [Column("voucherID")]
        public int? VoucherId { get; set; }

        [Column("orderDate")]
        public DateTime? OrderDate { get; set; }

        [Required]
        [Column("shippingAddress")]
        public string ShippingAddress { get; set; } = string.Empty;

        [Column("status")]
        public string? Status { get; set; }

        [Column("totalAmount", TypeName = "decimal(18,2)")]
        public decimal TotalAmount { get; set; }

        [ForeignKey(nameof(UserId))]
        public virtual User? User { get; set; }

        [ForeignKey(nameof(VoucherId))]
        public virtual Voucher? Voucher { get; set; }

        public virtual ICollection<OrderDetail> OrderDetails { get; set; } = new List<OrderDetail>();

        [NotMapped]
        public string CustomerName => User != null
            ? $"{User.FullName} ({User.Email})"
            : $"User #{UserId}";

        [NotMapped]
        public string VoucherCode => Voucher?.VoucherCode ?? "-";
    }
}
