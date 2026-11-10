using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FoodOrderWPF.Models
{
    [Table("Payments")]
    public class Payment
    {
        [Key]
        [Column("paymentID")]
        public int PaymentId { get; set; }

        [Column("orderID")]
        public int OrderId { get; set; }

        [Column("amount", TypeName = "decimal(18,2)")]
        public decimal Amount { get; set; }

        [Required]
        [Column("method")]
        public string Method { get; set; } = "COD";

        [Column("transactionDate")]
        public DateTime? TransactionDate { get; set; }

        [Column("status")]
        public string? Status { get; set; }
    }
}
