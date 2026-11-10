using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using FoodOrderWPF.Models;
using Microsoft.EntityFrameworkCore;

namespace FoodOrderWPF
{
    public partial class MainWindow : Window
    {
        private User? _currentUser;
        private readonly List<CartItem> _cart = new List<CartItem>();
        private bool _isInitializing = true;

        public MainWindow() : this(null)
        {
        }

        public MainWindow(User? loggedInUser)
        {
            InitializeComponent();
            _currentUser = loggedInUser;

            ApplyPermissionsAndHeader();
            LoadCategoriesAndRestaurants();
            LoadVouchers();
            LoadMenuProducts();
            RefreshCartUI();

            if (_currentUser != null)
            {
                LoadProfileForm();
                LoadMyOrders();

                if (_currentUser.RoleId == 4 || _currentUser.RoleId == 2)
                {
                    LoadManageProducts();
                }

                if (_currentUser.RoleId == 4 || _currentUser.RoleId == 2 || _currentUser.RoleId == 3)
                {
                    LoadManageOrders();
                }

                if (_currentUser.RoleId == 4)
                {
                    LoadManageUsers();
                }
            }

            _isInitializing = false;
        }

        private void ApplyPermissionsAndHeader()
        {
            if (_currentUser == null)
            {
                txtCurrentUserInfo.Text = "Xin chào: Khách (Chưa đăng nhập)";
                btnLogout.Content = "Đăng nhập";

                tabMyOrders.Visibility = Visibility.Collapsed;
                tabManageProduct.Visibility = Visibility.Collapsed;
                tabManageOrder.Visibility = Visibility.Collapsed;
                tabManageUser.Visibility = Visibility.Collapsed;
                tabProfile.Visibility = Visibility.Collapsed;
            }
            else
            {
                txtCurrentUserInfo.Text = $"Xin chào: {_currentUser.FullName} ({_currentUser.RoleName})";
                btnLogout.Content = "Đăng xuất";

                tabMyOrders.Visibility = Visibility.Visible;
                tabProfile.Visibility = Visibility.Visible;

                tabManageProduct.Visibility = (_currentUser.RoleId == 4 || _currentUser.RoleId == 2)
                    ? Visibility.Visible
                    : Visibility.Collapsed;

                tabManageOrder.Visibility = (_currentUser.RoleId == 4 || _currentUser.RoleId == 2 || _currentUser.RoleId == 3)
                    ? Visibility.Visible
                    : Visibility.Collapsed;

                tabManageUser.Visibility = _currentUser.RoleId == 4
                    ? Visibility.Visible
                    : Visibility.Collapsed;
            }
        }

        private void btnHeaderCart_Click(object sender, RoutedEventArgs e)
        {
            mainTabControl.SelectedItem = tabCart;
        }

        private void btnLogout_Click(object sender, RoutedEventArgs e)
        {
            var loginWindow = new LoginWindow();
            loginWindow.Show();
            this.Close();
        }

        private void mainTabControl_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (_isInitializing || e.Source != mainTabControl) return;

            if (mainTabControl.SelectedItem == tabMyOrders && _currentUser != null)
            {
                LoadMyOrders();
            }
            else if (mainTabControl.SelectedItem == tabManageOrder)
            {
                LoadManageOrders();
            }
        }

        private void LoadCategoriesAndRestaurants()
        {
            try
            {
                using var db = new FoodOrderDbContext();
                var categories = db.Categories.AsNoTracking().OrderBy(c => c.CategoryId).ToList();
                var restaurants = db.Restaurants.AsNoTracking().OrderBy(r => r.RestaurantId).ToList();

                var filterCategories = new List<Category>
                {
                    new Category { CategoryId = 0, Name = "-- Tất cả danh mục --" }
                };
                filterCategories.AddRange(categories);
                cboMenuCategory.ItemsSource = filterCategories;
                cboMenuCategory.SelectedValue = 0;

                var filterRestaurants = new List<Restaurant>
                {
                    new Restaurant { RestaurantId = 0, Name = "-- Tất cả nhà hàng --" }
                };
                filterRestaurants.AddRange(restaurants);
                cboMenuRestaurant.ItemsSource = filterRestaurants;
                cboMenuRestaurant.SelectedValue = 0;

                cboProductCategory.ItemsSource = categories;
                if (categories.Count > 0) cboProductCategory.SelectedIndex = 0;

                var manageableRestaurants = (_currentUser != null && _currentUser.RoleId == 2)
                    ? restaurants.Where(r => r.ManagerId == _currentUser.UserId).ToList()
                    : restaurants;

                cboProductRestaurant.ItemsSource = manageableRestaurants;
                if (manageableRestaurants.Count > 0) cboProductRestaurant.SelectedIndex = 0;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi tải danh mục/nhà hàng: " + ex.Message, "Lỗi", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void LoadVouchers()
        {
            try
            {
                using var db = new FoodOrderDbContext();
                var vouchers = db.Vouchers.AsNoTracking().OrderBy(v => v.VoucherId).ToList();

                var list = new List<Voucher>
                {
                    new Voucher { VoucherId = 0, VoucherCode = "NONE", DiscountPercent = 0, MaxDiscountAmount = 0 }
                };
                list.AddRange(vouchers);

                cboVoucher.ItemsSource = list;
                cboVoucher.SelectedValue = 0;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi tải danh sách Voucher: " + ex.Message, "Lỗi", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void LoadMenuProducts(int categoryId = 0, int restaurantId = 0, string keyword = "")
        {
            try
            {
                using var db = new FoodOrderDbContext();
                var query = db.Products
                    .Include(p => p.Category)
                    .Include(p => p.Restaurant)
                    .AsNoTracking()
                    .AsQueryable();

                if (categoryId > 0)
                {
                    query = query.Where(p => p.CategoryId == categoryId);
                }

                if (restaurantId > 0)
                {
                    query = query.Where(p => p.RestaurantId == restaurantId);
                }

                if (!string.IsNullOrWhiteSpace(keyword))
                {
                    query = query.Where(p => p.Name.Contains(keyword));
                }

                dgMenuProducts.ItemsSource = query.OrderBy(p => p.ProductId).ToList();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi tải danh sách món ăn: " + ex.Message, "Lỗi", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void cboMenuFilter_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (_isInitializing) return;
            ApplyMenuFilter();
        }

        private void btnSearchProduct_Click(object sender, RoutedEventArgs e)
        {
            ApplyMenuFilter();
        }

        private void ApplyMenuFilter()
        {
            int cid = cboMenuCategory.SelectedValue is int c ? c : 0;
            int rid = cboMenuRestaurant.SelectedValue is int r ? r : 0;
            LoadMenuProducts(cid, rid, txtSearchProduct.Text.Trim());
        }

        private void btnResetMenu_Click(object sender, RoutedEventArgs e)
        {
            txtSearchProduct.Text = string.Empty;
            cboMenuCategory.SelectedValue = 0;
            cboMenuRestaurant.SelectedValue = 0;
            LoadMenuProducts(0, 0, string.Empty);
        }

        private void dgMenuProducts_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (dgMenuProducts.SelectedItem is Product selectedProduct)
            {
                lblDetailName.Text = selectedProduct.Name;
                lblDetailCategory.Text = selectedProduct.CategoryName;
                lblDetailRestaurant.Text = selectedProduct.RestaurantName;
                lblDetailPrice.Text = $"{selectedProduct.Price:N0} đ";
                lblDetailDescription.Text = string.IsNullOrWhiteSpace(selectedProduct.Description)
                    ? "(Không có mô tả)"
                    : selectedProduct.Description;
                txtBuyQuantity.Text = "1";
            }
        }

        private void btnAddToCart_Click(object sender, RoutedEventArgs e)
        {
            if (dgMenuProducts.SelectedItem is not Product selectedProduct)
            {
                MessageBox.Show("Vui lòng chọn 1 món ăn trên bảng trước khi thêm vào giỏ!", "Thông báo",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (!int.TryParse(txtBuyQuantity.Text.Trim(), out int buyQty) || buyQty <= 0)
            {
                MessageBox.Show("Số lượng mua phải là số nguyên lớn hơn 0!", "Thông báo",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            var existingItem = _cart.FirstOrDefault(i => i.ProductId == selectedProduct.ProductId);
            if (existingItem != null)
            {
                existingItem.Quantity += buyQty;
            }
            else
            {
                _cart.Add(new CartItem
                {
                    ProductId = selectedProduct.ProductId,
                    ProductName = selectedProduct.Name,
                    CategoryName = selectedProduct.CategoryName,
                    RestaurantName = selectedProduct.RestaurantName,
                    Price = selectedProduct.Price,
                    Quantity = buyQty
                });
            }

            RefreshCartUI();
            MessageBox.Show($"Đã thêm {buyQty} x '{selectedProduct.Name}' vào giỏ hàng!", "Thành công",
                MessageBoxButton.OK, MessageBoxImage.Information);
        }

        private decimal CalculateFinalTotal()
        {
            decimal rawTotal = _cart.Sum(i => i.SubTotal);
            if (cboVoucher?.SelectedItem is Voucher voucher && voucher.VoucherId > 0)
            {
                decimal discount = rawTotal * (voucher.DiscountPercent / 100m);
                if (voucher.MaxDiscountAmount.HasValue && voucher.MaxDiscountAmount.Value > 0 && discount > voucher.MaxDiscountAmount.Value)
                {
                    discount = voucher.MaxDiscountAmount.Value;
                }
                decimal finalAmount = rawTotal - discount;
                return finalAmount < 0 ? 0 : finalAmount;
            }
            return rawTotal;
        }

        private void RefreshCartUI()
        {
            dgCart.ItemsSource = null;
            dgCart.ItemsSource = _cart;

            decimal finalTotal = CalculateFinalTotal();
            int totalItems = _cart.Sum(i => i.Quantity);

            lblCartTotal.Text = $"{finalTotal:N0} đ";
            btnHeaderCart.Content = $"Giỏ hàng ({totalItems})";
        }

        private void cboVoucher_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (_isInitializing) return;
            RefreshCartUI();
        }

        private void btnCartIncrease_Click(object sender, RoutedEventArgs e)
        {
            if (dgCart.SelectedItem is not CartItem item)
            {
                MessageBox.Show("Hãy chọn 1 món trong giỏ để tăng số lượng!", "Thông báo",
                    MessageBoxButton.OK, MessageBoxImage.Information);
                return;
            }

            item.Quantity++;
            RefreshCartUI();
        }

        private void btnCartDecrease_Click(object sender, RoutedEventArgs e)
        {
            if (dgCart.SelectedItem is not CartItem item)
            {
                MessageBox.Show("Hãy chọn 1 món trong giỏ để giảm số lượng!", "Thông báo",
                    MessageBoxButton.OK, MessageBoxImage.Information);
                return;
            }

            if (item.Quantity > 1)
            {
                item.Quantity--;
            }
            else
            {
                _cart.Remove(item);
            }

            RefreshCartUI();
        }

        private void btnCartRemoveItem_Click(object sender, RoutedEventArgs e)
        {
            if (dgCart.SelectedItem is not CartItem item)
            {
                MessageBox.Show("Hãy chọn 1 món trong giỏ để xóa!", "Thông báo",
                    MessageBoxButton.OK, MessageBoxImage.Information);
                return;
            }

            _cart.Remove(item);
            RefreshCartUI();
        }

        private void btnCartClear_Click(object sender, RoutedEventArgs e)
        {
            _cart.Clear();
            RefreshCartUI();
        }

        private void btnCheckout_Click(object sender, RoutedEventArgs e)
        {
            if (_cart.Count == 0)
            {
                MessageBox.Show("Giỏ hàng đang trống! Vui lòng chọn món ở tab Thực đơn trước.", "Thông báo",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (_currentUser == null)
            {
                MessageBox.Show("Bạn cần đăng nhập tài khoản trước khi Đặt hàng!", "Yêu cầu đăng nhập",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                btnLogout_Click(sender, e);
                return;
            }

            string shippingAddress = txtShippingAddress.Text.Trim();
            if (string.IsNullOrEmpty(shippingAddress))
            {
                MessageBox.Show("Vui lòng nhập Địa chỉ giao hàng!", "Thiếu địa chỉ",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            try
            {
                using var db = new FoodOrderDbContext();
                using var transaction = db.Database.BeginTransaction();

                int? voucherId = (cboVoucher.SelectedValue is int vid && vid > 0) ? vid : null;
                decimal finalTotal = CalculateFinalTotal();

                var newOrder = new Order
                {
                    UserId = _currentUser.UserId,
                    AddressId = null,
                    VoucherId = voucherId,
                    OrderDate = DateTime.Now,
                    ShippingAddress = shippingAddress,
                    Status = "Pending",
                    TotalAmount = finalTotal
                };

                db.Orders.Add(newOrder);
                db.SaveChanges();

                foreach (var cartItem in _cart)
                {
                    var detail = new OrderDetail
                    {
                        OrderId = newOrder.OrderId,
                        ProductId = cartItem.ProductId,
                        Quantity = cartItem.Quantity,
                        UnitPrice = cartItem.Price,
                        PriceAtOrder = cartItem.Price
                    };
                    db.OrderDetails.Add(detail);
                }

                string paymentMethod = cboPaymentMethod.SelectedValue?.ToString() ?? "COD";
                var payment = new Payment
                {
                    OrderId = newOrder.OrderId,
                    Amount = finalTotal,
                    Method = paymentMethod,
                    TransactionDate = DateTime.Now,
                    Status = paymentMethod == "COD" ? "Unpaid" : "Paid"
                };
                db.Payments.Add(payment);

                db.SaveChanges();
                transaction.Commit();

                _cart.Clear();
                RefreshCartUI();

                LoadMyOrders();
                if (_currentUser.RoleId == 4 || _currentUser.RoleId == 2 || _currentUser.RoleId == 3)
                {
                    LoadManageOrders();
                }

                MessageBox.Show(
                    $"Đặt hàng thành công! Mã đơn hàng của bạn là #{newOrder.OrderId}.",
                    "Thành công",
                    MessageBoxButton.OK,
                    MessageBoxImage.Information);

                mainTabControl.SelectedItem = tabMyOrders;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi khi đặt hàng:\n" + ex.Message, "Lỗi",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void LoadMyOrders()
        {
            if (_currentUser == null) return;

            try
            {
                using var db = new FoodOrderDbContext();
                var orders = db.Orders
                    .Include(o => o.Voucher)
                    .AsNoTracking()
                    .Where(o => o.UserId == _currentUser.UserId)
                    .OrderByDescending(o => o.OrderId)
                    .ToList();

                dgMyOrders.ItemsSource = orders;
                dgMyOrderDetails.ItemsSource = null;
                lblMyOrderDetailTitle.Text = "Chi tiết đơn hàng (Chọn 1 đơn bên trái)";
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi tải đơn hàng: " + ex.Message, "Lỗi", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void dgMyOrders_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (dgMyOrders.SelectedItem is not Order selectedOrder)
            {
                dgMyOrderDetails.ItemsSource = null;
                return;
            }

            lblMyOrderDetailTitle.Text = $"Chi tiết Đơn hàng #{selectedOrder.OrderId} ({selectedOrder.Status})";
            dgMyOrderDetails.ItemsSource = GetOrderDetailsWithProductName(selectedOrder.OrderId);
        }

        private List<OrderDetail> GetOrderDetailsWithProductName(int orderId, bool filterByManager = false)
        {
            using var db = new FoodOrderDbContext();
            var query = db.OrderDetails
                .Include(od => od.Product)
                .ThenInclude(p => p!.Restaurant)
                .AsNoTracking()
                .Where(od => od.OrderId == orderId);

            if (filterByManager && _currentUser != null && _currentUser.RoleId == 2)
            {
                query = query.Where(od => od.Product != null && od.Product.Restaurant != null && od.Product.Restaurant.ManagerId == _currentUser.UserId);
            }

            return query.ToList();
        }

        private void btnRefreshMyOrders_Click(object sender, RoutedEventArgs e)
        {
            LoadMyOrders();
        }

        private void btnDeleteMyOrder_Click(object sender, RoutedEventArgs e)
        {
            if (dgMyOrders.SelectedItem is not Order selectedOrder)
            {
                MessageBox.Show("Vui lòng chọn 1 đơn hàng cần xóa!", "Thông báo",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            var confirm = MessageBox.Show(
                $"Bạn có chắc chắn muốn xóa đơn hàng #{selectedOrder.OrderId} không?",
                "Xác nhận xóa đơn hàng",
                MessageBoxButton.YesNo,
                MessageBoxImage.Question);

            if (confirm != MessageBoxResult.Yes) return;

            DeleteOrderById(selectedOrder.OrderId);
            LoadMyOrders();
            if (_currentUser?.RoleId == 4 || _currentUser?.RoleId == 2 || _currentUser?.RoleId == 3)
            {
                LoadManageOrders();
            }
        }

        private void DeleteOrderById(int orderId)
        {
            try
            {
                using var db = new FoodOrderDbContext();
                db.Database.ExecuteSqlInterpolated($"DELETE FROM Reviews WHERE orderID = {orderId}");
                db.Payments.Where(p => p.OrderId == orderId).ExecuteDelete();
                db.OrderDetails.Where(od => od.OrderId == orderId).ExecuteDelete();
                db.Orders.Where(o => o.OrderId == orderId).ExecuteDelete();

                MessageBox.Show($"Đã xóa đơn hàng #{orderId} thành công!", "Thành công",
                    MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi khi xóa đơn hàng:\n" + ex.Message, "Lỗi",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void LoadManageProducts()
        {
            try
            {
                using var db = new FoodOrderDbContext();
                var query = db.Products
                    .Include(p => p.Category)
                    .Include(p => p.Restaurant)
                    .AsNoTracking()
                    .AsQueryable();

                if (_currentUser != null && _currentUser.RoleId == 2)
                {
                    query = query.Where(p => p.Restaurant != null && p.Restaurant.ManagerId == _currentUser.UserId);
                }

                dgManageProducts.ItemsSource = query
                    .OrderBy(p => p.ProductId)
                    .ToList();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi tải danh sách quản lý món ăn: " + ex.Message, "Lỗi",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void dgManageProducts_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (dgManageProducts.SelectedItem is Product product)
            {
                txtProductId.Text = product.ProductId.ToString();
                txtProductName.Text = product.Name;
                cboProductCategory.SelectedValue = product.CategoryId;
                cboProductRestaurant.SelectedValue = product.RestaurantId;
                txtProductPrice.Text = product.Price.ToString("0.##");
                txtProductDescription.Text = product.Description ?? string.Empty;
            }
        }

        private void btnClearProductForm_Click(object sender, RoutedEventArgs e)
        {
            dgManageProducts.SelectedItem = null;
            txtProductId.Text = string.Empty;
            txtProductName.Text = string.Empty;
            if (cboProductCategory.Items.Count > 0) cboProductCategory.SelectedIndex = 0;
            if (cboProductRestaurant.Items.Count > 0) cboProductRestaurant.SelectedIndex = 0;
            txtProductPrice.Text = string.Empty;
            txtProductDescription.Text = string.Empty;
        }

        private void btnAddProduct_Click(object sender, RoutedEventArgs e)
        {
            if (!TryValidateProductInputs(out string name, out int categoryId, out int restaurantId, out decimal price, out string description))
                return;

            try
            {
                using var db = new FoodOrderDbContext();
                var newProduct = new Product
                {
                    Name = name,
                    CategoryId = categoryId,
                    RestaurantId = restaurantId,
                    Price = price,
                    Description = description,
                    ImageUrl = string.Empty
                };

                db.Products.Add(newProduct);
                db.SaveChanges();

                LoadManageProducts();
                ApplyMenuFilter();
                btnClearProductForm_Click(sender, e);

                MessageBox.Show("Thêm món ăn mới thành công!", "Thành công",
                    MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi khi thêm món ăn:\n" + ex.Message, "Lỗi",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void btnUpdateProduct_Click(object sender, RoutedEventArgs e)
        {
            if (!int.TryParse(txtProductId.Text, out int productId))
            {
                MessageBox.Show("Vui lòng chọn 1 món ăn trong bảng để cập nhật!", "Thông báo",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (!TryValidateProductInputs(out string name, out int categoryId, out int restaurantId, out decimal price, out string description))
                return;

            try
            {
                using var db = new FoodOrderDbContext();
                var product = db.Products.FirstOrDefault(p => p.ProductId == productId);
                if (product == null)
                {
                    MessageBox.Show("Không tìm thấy món ăn này trong CSDL!", "Lỗi",
                        MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }

                product.Name = name;
                product.CategoryId = categoryId;
                product.RestaurantId = restaurantId;
                product.Price = price;
                product.Description = description;

                db.SaveChanges();

                LoadManageProducts();
                ApplyMenuFilter();
                MessageBox.Show("Cập nhật thông tin món ăn thành công!", "Thành công",
                    MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi khi cập nhật món ăn:\n" + ex.Message, "Lỗi",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void btnDeleteProduct_Click(object sender, RoutedEventArgs e)
        {
            if (!int.TryParse(txtProductId.Text, out int productId))
            {
                MessageBox.Show("Vui lòng chọn 1 món ăn trong bảng để xóa!", "Thông báo",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            var confirm = MessageBox.Show(
                $"Bạn có chắc muốn xóa món ăn ID #{productId} ({txtProductName.Text}) không?",
                "Xác nhận xóa",
                MessageBoxButton.YesNo,
                MessageBoxImage.Question);

            if (confirm != MessageBoxResult.Yes) return;

            try
            {
                using var db = new FoodOrderDbContext();
                db.Database.ExecuteSqlInterpolated($"DELETE FROM FoodOptionItems WHERE groupID IN (SELECT groupID FROM FoodOptionGroups WHERE productID = {productId})");
                db.Database.ExecuteSqlInterpolated($"DELETE FROM FoodOptionGroups WHERE productID = {productId}");
                db.Database.ExecuteSqlInterpolated($"DELETE FROM Reviews WHERE productID = {productId}");
                db.OrderDetails.Where(od => od.ProductId == productId).ExecuteDelete();
                db.Products.Where(p => p.ProductId == productId).ExecuteDelete();

                LoadManageProducts();
                ApplyMenuFilter();
                btnClearProductForm_Click(sender, e);

                MessageBox.Show("Xóa món ăn thành công!", "Thành công",
                    MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Không thể xóa món ăn này:\n" + ex.Message, "Lỗi",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private bool TryValidateProductInputs(out string name, out int categoryId, out int restaurantId, out decimal price, out string description)
        {
            name = txtProductName.Text.Trim();
            description = txtProductDescription.Text.Trim();
            categoryId = cboProductCategory.SelectedValue is int cid ? cid : 0;
            restaurantId = cboProductRestaurant.SelectedValue is int rid ? rid : 0;
            price = 0;

            if (string.IsNullOrEmpty(name) || categoryId <= 0 || restaurantId <= 0)
            {
                MessageBox.Show("Vui lòng nhập Tên món ăn, chọn Danh mục và Nhà hàng!", "Thiếu thông tin",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return false;
            }

            if (!decimal.TryParse(txtProductPrice.Text.Trim(), out price) || price < 0)
            {
                MessageBox.Show("Giá món ăn phải là số không âm!", "Dữ liệu không hợp lệ",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return false;
            }

            return true;
        }

        private void LoadManageOrders()
        {
            try
            {
                using var db = new FoodOrderDbContext();
                var query = db.Orders
                    .Include(o => o.User)
                    .Include(o => o.Voucher)
                    .AsNoTracking()
                    .AsQueryable();

                if (_currentUser != null && _currentUser.RoleId == 2)
                {
                    query = query.Where(o => o.OrderDetails.Any(
                        od => od.Product != null && od.Product.Restaurant != null && od.Product.Restaurant.ManagerId == _currentUser.UserId));
                }

                dgManageOrders.ItemsSource = query
                    .OrderByDescending(o => o.OrderId)
                    .ToList();

                dgManageOrderDetails.ItemsSource = null;
                txtManageOrderId.Text = string.Empty;
                txtManageOrderTotal.Text = string.Empty;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi tải danh sách quản lý đơn hàng: " + ex.Message, "Lỗi",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void dgManageOrders_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (dgManageOrders.SelectedItem is not Order selectedOrder)
            {
                dgManageOrderDetails.ItemsSource = null;
                return;
            }

            txtManageOrderId.Text = selectedOrder.OrderId.ToString();
            txtManageOrderTotal.Text = $"{selectedOrder.TotalAmount:N0} đ";
            cboOrderStatus.SelectedValue = selectedOrder.Status ?? "Pending";

            dgManageOrderDetails.ItemsSource = GetOrderDetailsWithProductName(selectedOrder.OrderId, filterByManager: true);
        }

        private void btnUpdateOrderStatus_Click(object sender, RoutedEventArgs e)
        {
            if (!int.TryParse(txtManageOrderId.Text, out int orderId))
            {
                MessageBox.Show("Vui lòng chọn 1 đơn hàng cần đổi trạng thái!", "Thông báo",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            string? newStatus = cboOrderStatus.SelectedValue?.ToString();
            if (string.IsNullOrEmpty(newStatus))
            {
                MessageBox.Show("Vui lòng chọn trạng thái hợp lệ!", "Thông báo",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            try
            {
                using var db = new FoodOrderDbContext();
                var order = db.Orders.FirstOrDefault(o => o.OrderId == orderId);
                if (order == null) return;

                order.Status = newStatus;
                db.SaveChanges();

                LoadManageOrders();
                LoadMyOrders();

                MessageBox.Show($"Đã cập nhật trạng thái đơn hàng #{orderId} thành '{newStatus}'!", "Thành công",
                    MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi khi cập nhật trạng thái đơn hàng:\n" + ex.Message, "Lỗi",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void btnDeleteManageOrder_Click(object sender, RoutedEventArgs e)
        {
            if (!int.TryParse(txtManageOrderId.Text, out int orderId))
            {
                MessageBox.Show("Vui lòng chọn 1 đơn hàng cần xóa!", "Thông báo",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            var confirm = MessageBox.Show(
                $"Bạn có chắc chắn muốn xóa đơn hàng #{orderId} không?",
                "Xác nhận xóa đơn hàng",
                MessageBoxButton.YesNo,
                MessageBoxImage.Question);

            if (confirm != MessageBoxResult.Yes) return;

            DeleteOrderById(orderId);
            LoadManageOrders();
            LoadMyOrders();
        }

        private void btnRefreshManageOrders_Click(object sender, RoutedEventArgs e)
        {
            LoadManageOrders();
        }

        private void LoadManageUsers()
        {
            try
            {
                using var db = new FoodOrderDbContext();
                dgManageUsers.ItemsSource = db.Users
                    .AsNoTracking()
                    .OrderBy(u => u.UserId)
                    .ToList();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi tải danh sách người dùng: " + ex.Message, "Lỗi",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void dgManageUsers_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (dgManageUsers.SelectedItem is User u)
            {
                txtUserId.Text = u.UserId.ToString();
                txtUserFullName.Text = u.FullName;
                txtUserEmail.Text = u.Email;
                txtUserPhone.Text = u.PhoneNumber ?? string.Empty;
                txtUserPassword.Text = u.PasswordHash;
                cboUserRole.SelectedValue = u.RoleId.ToString();
            }
        }

        private void btnClearUserForm_Click(object sender, RoutedEventArgs e)
        {
            dgManageUsers.SelectedItem = null;
            txtUserId.Text = string.Empty;
            txtUserFullName.Text = string.Empty;
            txtUserEmail.Text = string.Empty;
            txtUserPhone.Text = string.Empty;
            txtUserPassword.Text = string.Empty;
            cboUserRole.SelectedIndex = 0;
        }

        private void btnAddUser_Click(object sender, RoutedEventArgs e)
        {
            string fullName = txtUserFullName.Text.Trim();
            string email = txtUserEmail.Text.Trim();
            string phone = txtUserPhone.Text.Trim();
            string password = txtUserPassword.Text.Trim();
            int roleId = int.TryParse(cboUserRole.SelectedValue?.ToString(), out int r) ? r : 1;

            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                MessageBox.Show("Vui lòng nhập đầy đủ Họ tên, Email và Mật khẩu!", "Thiếu thông tin",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            try
            {
                using var db = new FoodOrderDbContext();
                if (db.Users.Any(u => u.Email == email))
                {
                    MessageBox.Show("Email này đã tồn tại!", "Trùng Email",
                        MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }

                var newUser = new User
                {
                    FullName = fullName,
                    Email = email,
                    PhoneNumber = string.IsNullOrEmpty(phone) ? null : phone,
                    PasswordHash = password,
                    RoleId = roleId
                };

                db.Users.Add(newUser);
                db.SaveChanges();

                LoadManageUsers();
                btnClearUserForm_Click(sender, e);

                MessageBox.Show("Thêm người dùng mới thành công!", "Thành công",
                    MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi khi thêm người dùng:\n" + ex.Message, "Lỗi",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void btnUpdateUser_Click(object sender, RoutedEventArgs e)
        {
            if (!int.TryParse(txtUserId.Text, out int userId))
            {
                MessageBox.Show("Vui lòng chọn 1 người dùng trong bảng để cập nhật!", "Thông báo",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            string fullName = txtUserFullName.Text.Trim();
            string email = txtUserEmail.Text.Trim();
            string phone = txtUserPhone.Text.Trim();
            string password = txtUserPassword.Text.Trim();
            int roleId = int.TryParse(cboUserRole.SelectedValue?.ToString(), out int r) ? r : 1;

            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                MessageBox.Show("Vui lòng nhập đầy đủ Họ tên, Email và Mật khẩu!", "Thiếu thông tin",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            try
            {
                using var db = new FoodOrderDbContext();
                if (db.Users.Any(u => u.Email == email && u.UserId != userId))
                {
                    MessageBox.Show("Email này đã được người dùng khác sử dụng!", "Trùng Email",
                        MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }

                var user = db.Users.FirstOrDefault(u => u.UserId == userId);
                if (user == null) return;

                user.FullName = fullName;
                user.Email = email;
                user.PhoneNumber = string.IsNullOrEmpty(phone) ? null : phone;
                user.PasswordHash = password;
                user.RoleId = roleId;

                db.SaveChanges();

                LoadManageUsers();
                MessageBox.Show("Cập nhật người dùng thành công!", "Thành công",
                    MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi khi cập nhật người dùng:\n" + ex.Message, "Lỗi",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void btnDeleteUser_Click(object sender, RoutedEventArgs e)
        {
            if (!int.TryParse(txtUserId.Text, out int userId))
            {
                MessageBox.Show("Vui lòng chọn 1 người dùng trong bảng để xóa!", "Thông báo",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (_currentUser != null && userId == _currentUser.UserId)
            {
                MessageBox.Show("Không thể tự xóa tài khoản đang đăng nhập!", "Cảnh báo",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            var confirm = MessageBox.Show(
                $"Bạn có chắc chắn muốn xóa người dùng ID #{userId} ({txtUserEmail.Text}) không?",
                "Xác nhận xóa",
                MessageBoxButton.YesNo,
                MessageBoxImage.Question);

            if (confirm != MessageBoxResult.Yes) return;

            try
            {
                using var db = new FoodOrderDbContext();
                var orderIds = db.Orders.Where(o => o.UserId == userId).Select(o => o.OrderId).ToList();
                foreach (int oid in orderIds)
                {
                    db.Database.ExecuteSqlInterpolated($"DELETE FROM Reviews WHERE orderID = {oid}");
                    db.Payments.Where(p => p.OrderId == oid).ExecuteDelete();
                    db.OrderDetails.Where(od => od.OrderId == oid).ExecuteDelete();
                }
                db.Orders.Where(o => o.UserId == userId).ExecuteDelete();
                db.Database.ExecuteSqlInterpolated($"DELETE FROM Reviews WHERE userID = {userId}");
                db.Database.ExecuteSqlInterpolated($"DELETE FROM UserAddresses WHERE userID = {userId}");
                db.Database.ExecuteSqlInterpolated($"DELETE FROM ShipperDetails WHERE userID = {userId}");
                db.Users.Where(u => u.UserId == userId).ExecuteDelete();

                LoadManageUsers();
                btnClearUserForm_Click(sender, e);

                MessageBox.Show("Xóa người dùng thành công!", "Thành công",
                    MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Không thể xóa người dùng này (có thể đang quản lý Nhà hàng):\n" + ex.Message, "Lỗi",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void LoadProfileForm()
        {
            if (_currentUser == null) return;

            txtProfileFullName.Text = _currentUser.FullName;
            txtProfileEmail.Text = _currentUser.Email;
            txtProfilePhone.Text = _currentUser.PhoneNumber ?? string.Empty;
            txtProfilePassword.Text = _currentUser.PasswordHash;
            lblProfileRole.Text = $"Vai trò hiện tại: {_currentUser.RoleName}";
        }

        private void btnSaveProfile_Click(object sender, RoutedEventArgs e)
        {
            if (_currentUser == null) return;

            string fullName = txtProfileFullName.Text.Trim();
            string email = txtProfileEmail.Text.Trim();
            string phone = txtProfilePhone.Text.Trim();
            string password = txtProfilePassword.Text.Trim();

            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                MessageBox.Show("Họ tên, Email và Mật khẩu không được để trống!", "Thông báo",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            try
            {
                using var db = new FoodOrderDbContext();
                if (db.Users.Any(u => u.Email == email && u.UserId != _currentUser.UserId))
                {
                    MessageBox.Show("Email này đã được người khác sử dụng!", "Trùng Email",
                        MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }

                var userInDb = db.Users.FirstOrDefault(u => u.UserId == _currentUser.UserId);
                if (userInDb == null) return;

                userInDb.FullName = fullName;
                userInDb.Email = email;
                userInDb.PhoneNumber = string.IsNullOrEmpty(phone) ? null : phone;
                userInDb.PasswordHash = password;

                db.SaveChanges();

                _currentUser = userInDb;
                ApplyPermissionsAndHeader();
                if (_currentUser.RoleId == 4) LoadManageUsers();

                MessageBox.Show("Cập nhật hồ sơ cá nhân thành công!", "Thành công",
                    MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi khi lưu hồ sơ:\n" + ex.Message, "Lỗi",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
    }
}
