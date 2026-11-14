using System;
using System.Linq;
using System.Text.RegularExpressions;
using System.Windows;
using FoodOrderWPF.Models;

namespace FoodOrderWPF
{
    public partial class LoginWindow : Window
    {
        public LoginWindow()
        {
            InitializeComponent();
            txtEmail.Focus();
        }

        private void btnLogin_Click(object sender, RoutedEventArgs e)
        {
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Password.Trim();

            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                MessageBox.Show("Vui lòng nhập đầy đủ Email và Password!", "Thông báo",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (!Regex.IsMatch(email, @"^[^@\s]+@[^@\s]+\.[^@\s]+$", RegexOptions.IgnoreCase))
            {
                MessageBox.Show("Định dạng Email không hợp lệ! (VD: example@gmail.com)", "Dữ liệu không hợp lệ",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                txtEmail.Focus();
                return;
            }

            try
            {
                using var db = new FoodOrderDbContext();
                var user = db.Users
                    .FirstOrDefault(u => u.Email == email && u.PasswordHash == password);

                if (user == null)
                {
                    MessageBox.Show("Sai Email hoặc mật khẩu!", "Đăng nhập thất bại",
                        MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }

                var mainWindow = new MainWindow(user);
                mainWindow.Show();
                this.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi kết nối Cơ sở dữ liệu:\n" + ex.Message, "Lỗi hệ thống",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void btnOpenSignup_Click(object sender, RoutedEventArgs e)
        {
            var signupWindow = new SignupWindow();
            signupWindow.Owner = this;
            if (signupWindow.ShowDialog() == true)
            {
                txtEmail.Text = signupWindow.CreatedEmail;
                txtPassword.Focus();
            }
        }

        private void btnGuest_Click(object sender, RoutedEventArgs e)
        {
            var mainWindow = new MainWindow(null);
            mainWindow.Show();
            this.Close();
        }
    }
}
