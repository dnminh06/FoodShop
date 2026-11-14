using System;
using System.Linq;
using System.Text.RegularExpressions;
using System.Windows;
using FoodOrderWPF.Models;

namespace FoodOrderWPF
{
    public partial class SignupWindow : Window
    {
        public string CreatedEmail { get; private set; } = string.Empty;

        public SignupWindow()
        {
            InitializeComponent();
            txtFullName.Focus();
        }

        private void btnSignup_Click(object sender, RoutedEventArgs e)
        {
            string fullName = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string phone = txtPhone.Text.Trim();
            string password = txtPassword.Password.Trim();
            string confirm = txtConfirmPassword.Password.Trim();

            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                MessageBox.Show("Vui lòng nhập đầy đủ Họ tên, Email và Mật khẩu!", "Thông báo",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (!Regex.IsMatch(fullName, @"^[\p{L}\s]{2,100}$"))
            {
                MessageBox.Show("Họ và tên không hợp lệ! Vui lòng chỉ nhập chữ cái (2 - 100 ký tự), không chứa số hoặc ký tự đặc biệt.", "Dữ liệu không hợp lệ",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                txtFullName.Focus();
                return;
            }

            if (!Regex.IsMatch(email, @"^[^@\s]+@[^@\s]+\.[^@\s]+$", RegexOptions.IgnoreCase))
            {
                MessageBox.Show("Định dạng Email không hợp lệ! (VD: example@gmail.com)", "Dữ liệu không hợp lệ",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                txtEmail.Focus();
                return;
            }

            if (!string.IsNullOrEmpty(phone) && !Regex.IsMatch(phone, @"^0\d{9}$"))
            {
                MessageBox.Show("Số điện thoại không hợp lệ! Vui lòng nhập đúng 10 chữ số và bắt đầu bằng số 0 (VD: 0901234567).", "Dữ liệu không hợp lệ",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                txtPhone.Focus();
                return;
            }

            if (password != confirm)
            {
                MessageBox.Show("Mật khẩu nhập lại không khớp!", "Lỗi xác nhận",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            try
            {
                using var db = new FoodOrderDbContext();

                if (db.Users.Any(u => u.Email == email))
                {
                    MessageBox.Show("Email này đã tồn tại! Vui lòng dùng Email khác.", "Trùng Email",
                        MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }

                var newUser = new User
                {
                    FullName = fullName,
                    Email = email,
                    PhoneNumber = string.IsNullOrEmpty(phone) ? null : phone,
                    PasswordHash = password,
                    RoleId = 1
                };

                db.Users.Add(newUser);
                db.SaveChanges();

                CreatedEmail = email;
                MessageBox.Show("Đăng ký tài khoản thành công! Bạn có thể đăng nhập ngay.", "Thành công",
                    MessageBoxButton.OK, MessageBoxImage.Information);
                this.DialogResult = true;
                this.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi khi đăng ký tài khoản:\n" + ex.Message, "Lỗi",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void btnCancel_Click(object sender, RoutedEventArgs e)
        {
            this.DialogResult = false;
            this.Close();
        }
    }
}
