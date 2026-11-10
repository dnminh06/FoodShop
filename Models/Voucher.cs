using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FoodOrderWPF.Models
{
    [Table("Vouchers")]
    public class Voucher
    {
        [Key]
        [Column("voucherID")]
        public int VoucherId { get; set; }

        [Required]
        [Column("voucherCode")]
        public string VoucherCode { get; set; } = string.Empty;

        [Column("discountPercent", TypeName = "decimal(18,2)")]
        public decimal DiscountPercent { get; set; }

        [Column("maxDiscountAmount", TypeName = "decimal(18,2)")]
        public decimal? MaxDiscountAmount { get; set; }

        [Column("startDate")]
        public DateTime StartDate { get; set; }

        [Column("endDate")]
        public DateTime EndDate { get; set; }

        [NotMapped]
        public string DisplayName => VoucherId == 0
            ? "-- Không dùng Voucher --"
            : $"{VoucherCode} (-{DiscountPercent:0}% tối đa {MaxDiscountAmount ?? 0:N0}đ)";
    }
}
