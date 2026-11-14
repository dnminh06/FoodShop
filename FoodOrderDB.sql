USE [master];
GO
IF DB_ID(N'FoodOrderDB') IS NULL
    CREATE DATABASE [FoodOrderDB];
GO
USE [FoodOrderDB];
GO

IF OBJECT_ID('dbo.Reviews', 'U') IS NOT NULL DROP TABLE dbo.Reviews;
IF OBJECT_ID('dbo.Payments', 'U') IS NOT NULL DROP TABLE dbo.Payments;
IF OBJECT_ID('dbo.OrderDetails', 'U') IS NOT NULL DROP TABLE dbo.OrderDetails;
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.FoodOptionItems', 'U') IS NOT NULL DROP TABLE dbo.FoodOptionItems;
IF OBJECT_ID('dbo.FoodOptionGroups', 'U') IS NOT NULL DROP TABLE dbo.FoodOptionGroups;
IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID('dbo.Restaurants', 'U') IS NOT NULL DROP TABLE dbo.Restaurants;
IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID('dbo.Vouchers', 'U') IS NOT NULL DROP TABLE dbo.Vouchers;
IF OBJECT_ID('dbo.UserAddresses', 'U') IS NOT NULL DROP TABLE dbo.UserAddresses;
IF OBJECT_ID('dbo.ShipperDetails', 'U') IS NOT NULL DROP TABLE dbo.ShipperDetails;
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
GO

CREATE TABLE dbo.Users (
    userID INT IDENTITY(1,1) PRIMARY KEY,
    fullName NVARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    passwordHash VARCHAR(255) NOT NULL,
    phoneNumber VARCHAR(20) NULL,
    roleID INT NOT NULL
);

CREATE TABLE dbo.ShipperDetails (
    userID INT PRIMARY KEY FOREIGN KEY REFERENCES dbo.Users(userID),
    vehicleType NVARCHAR(100) NULL,
    licensePlate VARCHAR(50) NULL
);

CREATE TABLE dbo.UserAddresses (
    addressID INT IDENTITY(1,1) PRIMARY KEY,
    userID INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(userID),
    addressDetails NVARCHAR(255) NOT NULL,
    isDefault BIT NULL
);

CREATE TABLE dbo.Vouchers (
    voucherID INT IDENTITY(1,1) PRIMARY KEY,
    voucherCode VARCHAR(50) NOT NULL UNIQUE,
    discountPercent DECIMAL(18,2) NOT NULL,
    maxDiscountAmount DECIMAL(18,2) NULL,
    startDate DATETIME2 NOT NULL,
    endDate DATETIME2 NOT NULL
);

CREATE TABLE dbo.Categories (
    categoryID INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL
);

CREATE TABLE dbo.Restaurants (
    restaurantID INT IDENTITY(1,1) PRIMARY KEY,
    managerID INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(userID),
    name NVARCHAR(150) NOT NULL,
    address NVARCHAR(255) NOT NULL,
    openingHours VARCHAR(100) NULL,
    status NVARCHAR(50) NULL
);

CREATE TABLE dbo.Products (
    productID INT IDENTITY(1,1) PRIMARY KEY,
    restaurantID INT NOT NULL FOREIGN KEY REFERENCES dbo.Restaurants(restaurantID),
    categoryID INT NOT NULL FOREIGN KEY REFERENCES dbo.Categories(categoryID),
    name NVARCHAR(150) NOT NULL,
    price DECIMAL(18,2) NOT NULL,
    description NVARCHAR(500) NULL,
    imageURL VARCHAR(255) NULL
);

CREATE TABLE dbo.FoodOptionGroups (
    groupID INT IDENTITY(1,1) PRIMARY KEY,
    productID INT NOT NULL FOREIGN KEY REFERENCES dbo.Products(productID),
    groupName NVARCHAR(100) NOT NULL
);

CREATE TABLE dbo.FoodOptionItems (
    itemID INT IDENTITY(1,1) PRIMARY KEY,
    groupID INT NOT NULL FOREIGN KEY REFERENCES dbo.FoodOptionGroups(groupID),
    itemName NVARCHAR(100) NOT NULL,
    additionalPrice DECIMAL(18,2) NULL
);

CREATE TABLE dbo.Orders (
    orderID INT IDENTITY(1,1) PRIMARY KEY,
    userID INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(userID),
    addressID INT NULL FOREIGN KEY REFERENCES dbo.UserAddresses(addressID),
    voucherID INT NULL FOREIGN KEY REFERENCES dbo.Vouchers(voucherID),
    orderDate DATETIME2 NULL,
    shippingAddress NVARCHAR(255) NOT NULL,
    status NVARCHAR(50) NULL,
    totalAmount DECIMAL(18,2) NOT NULL
);

CREATE TABLE dbo.OrderDetails (
    orderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    orderID INT NOT NULL FOREIGN KEY REFERENCES dbo.Orders(orderID),
    productID INT NOT NULL FOREIGN KEY REFERENCES dbo.Products(productID),
    quantity INT NOT NULL,
    unitPrice DECIMAL(18,2) NOT NULL,
    priceAtOrder DECIMAL(18,2) NOT NULL
);

CREATE TABLE dbo.Payments (
    paymentID INT IDENTITY(1,1) PRIMARY KEY,
    orderID INT NOT NULL UNIQUE FOREIGN KEY REFERENCES dbo.Orders(orderID),
    amount DECIMAL(18,2) NOT NULL,
    method VARCHAR(50) NOT NULL,
    transactionDate DATETIME2 NULL,
    status NVARCHAR(50) NULL
);

CREATE TABLE dbo.Reviews (
    reviewID INT IDENTITY(1,1) PRIMARY KEY,
    userID INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(userID),
    orderID INT NOT NULL FOREIGN KEY REFERENCES dbo.Orders(orderID),
    productID INT NOT NULL FOREIGN KEY REFERENCES dbo.Products(productID),
    rating INT NOT NULL,
    comment NVARCHAR(500) NULL,
    reviewDate DATETIME2 NULL
);
GO
SET IDENTITY_INSERT dbo.Users ON;
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (1, N'Nguyễn Văn An', N'an.nguyen@gmail.com', N'hash_pwd_001', N'0901111222', 1);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (2, N'Trần Thị Bích', N'bich.tran@gmail.com', N'hash_pwd_002', N'0902222333', 1);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (3, N'Đỗ Minh Giang', N'giang.do@gmail.com', N'hash_pwd_003', N'0903333444', 1);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (4, N'Bùi Thị Hoa', N'hoa.bui@gmail.com', N'hash_pwd_004', N'0904444555', 1);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (5, N'Dương Thị Khánh', N'khanh.duong@gmail.com', N'hash_pwd_005', N'0905555666', 1);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (6, N'Lý Hải Nam', N'nam.ly@gmail.com', N'hash_pwd_006', N'0906666777', 1);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (7, N'Phan Thị Mai', N'mai.phan@gmail.com', N'hash_pwd_007', N'0907777888', 1);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (8, N'Vương Đình Phước', N'phuoc.vuong@gmail.com', N'hash_pwd_008', N'0908888999', 1);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (9, N'Hồ Ngọc Quỳnh', N'quynh.ho@gmail.com', N'hash_pwd_009', N'0909999000', 1);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (10, N'Lương Thế Vinh', N'vinh.luong@gmail.com', N'hash_pwd_010', N'0901234568', 1);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (11, N'Lê Hoàng Cường', N'cuong.le@gmail.com', N'hash_pwd_011', N'0911111222', 2);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (12, N'Phạm Thị Dung', N'dung.pham@gmail.com', N'hash_pwd_012', N'0912222333', 2);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (13, N'Đinh Quốc Huy', N'huy.dinh@gmail.com', N'hash_pwd_013', N'0913333444', 2);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (14, N'Nguyễn Thị Kim', N'kim.nguyen@gmail.com', N'hash_pwd_014', N'0914444555', 2);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (15, N'Trương Vĩnh Kỳ', N'ky.truong@gmail.com', N'hash_pwd_015', N'0915555666', 2);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (16, N'Hoàng Văn Em', N'em.hoang@gmail.com', N'hash_pwd_016', N'0921111222', 3);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (17, N'Vũ Thị Phương', N'phuong.vu@gmail.com', N'hash_pwd_017', N'0922222333', 3);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (18, N'Cao Bá Quát', N'quat.cao@gmail.com', N'hash_pwd_018', N'0923333444', 3);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (19, N'Lê Văn Sỹ', N'sy.le@gmail.com', N'hash_pwd_019', N'0924444555', 3);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (20, N'Trần Đức Tài', N'tai.tran@gmail.com', N'hash_pwd_020', N'0925555666', 3);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (21, N'Mai Văn Uy', N'uy.mai@gmail.com', N'hash_pwd_021', N'0926666777', 3);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (22, N'Nguyễn Thanh Tùng', N'tung.nguyen@gmail.com', N'hash_pwd_022', N'0927777888', 3);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (23, N'Phạm Hồng Sơn', N'son.pham@gmail.com', N'hash_pwd_023', N'0928888999', 3);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (24, N'Đặng Văn Minh', N'minh.dang@gmail.com', N'hash_pwd_024', N'0929999000', 3);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (25, N'Bùi Thanh Trúc', N'truc.bui@gmail.com', N'hash_pwd_025', N'0921234567', 3);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (26, N'Ngô Quang Hùng', N'hung.ngo@gmail.com', N'hash_pwd_026', N'0931111222', 4);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (27, N'Lê Thị Ngọc', N'ngoc.le@gmail.com', N'hash_pwd_027', N'0932222333', 4);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (28, N'Trần Minh Quân', N'quan.tran@gmail.com', N'hash_pwd_028', N'0933333444', 4);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (29, N'Phạm Gia Huy', N'huy.pham@gmail.com', N'hash_pwd_029', N'0934444555', 4);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (30, N'Hoàng Minh Tuấn', N'tuan.hoang@gmail.com', N'hash_pwd_030', N'0935555666', 4);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (31, N'Đỗ Nhật Minh', N'admin@gmail.com', N'123', N'0999999999', 4);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (32, N'Đỗ Nhật Nam', N'customer@gmail.com', N'123', N'0988888888', 1);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (33, N'Đỗ Nhật Quang', N'manager@gmail.com', N'123', N'0977777777', 2);
INSERT INTO dbo.Users ([userID], [fullName], [email], [passwordHash], [phoneNumber], [roleID]) VALUES (34, N'Đỗ Nhật Si', N'ship@gmail.com', N'123', N'0966666666', 3);
SET IDENTITY_INSERT dbo.Users OFF;
GO

INSERT INTO dbo.ShipperDetails ([userID], [vehicleType], [licensePlate]) VALUES (16, N'Xe máy Honda Wave', N'29-C1 12345');
INSERT INTO dbo.ShipperDetails ([userID], [vehicleType], [licensePlate]) VALUES (17, N'Xe máy Yamaha Sirius', N'30-F2 67890');
INSERT INTO dbo.ShipperDetails ([userID], [vehicleType], [licensePlate]) VALUES (18, N'Xe máy Vision', N'29-AB 11122');
INSERT INTO dbo.ShipperDetails ([userID], [vehicleType], [licensePlate]) VALUES (19, N'Xe máy Air Blade', N'29-XY 33344');
INSERT INTO dbo.ShipperDetails ([userID], [vehicleType], [licensePlate]) VALUES (20, N'Xe điện VinFast Klara', N'29-MD 55566');
INSERT INTO dbo.ShipperDetails ([userID], [vehicleType], [licensePlate]) VALUES (21, N'Xe máy Future', N'30-G1 77788');
INSERT INTO dbo.ShipperDetails ([userID], [vehicleType], [licensePlate]) VALUES (22, N'Xe máy Winner X', N'29-EX 99900');
INSERT INTO dbo.ShipperDetails ([userID], [vehicleType], [licensePlate]) VALUES (23, N'Xe máy Exciter', N'30-V1 24680');
INSERT INTO dbo.ShipperDetails ([userID], [vehicleType], [licensePlate]) VALUES (24, N'Xe máy Lead', N'29-L1 13579');
INSERT INTO dbo.ShipperDetails ([userID], [vehicleType], [licensePlate]) VALUES (25, N'Xe máy Vespa', N'30-P8 86420');
GO

SET IDENTITY_INSERT dbo.UserAddresses ON;
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (1, 1, N'Số 10, Đường Tôn Thất Thuyết, Cầu Giấy, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (2, 1, N'Số 25, Ngõ 100 Hoàng Quốc Việt, Cầu Giấy, Hà Nội', 0);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (3, 2, N'Số 120, Phố Huế, Hai Bà Trưng, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (4, 3, N'Số 54, Triều Khúc, Thanh Trì, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (5, 4, N'Số 88, Phố Nhổn, Bắc Từ Liêm, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (6, 5, N'Số 15, Đường Phạm Văn Đồng, Cầu Giấy, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (7, 11, N'Số 42, Láng Hạ, Đống Đa, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (8, 12, N'Số 99, Nguyễn Trãi, Thanh Xuân, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (9, 16, N'Số 77, Đội Cấn, Ba Đình, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (10, 17, N'Số 33, Bạch Mai, Hai Bà Trưng, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (11, 10, N'Số 55, Quang Trung, Hà Đông, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (12, 11, N'Số 14, Phố Hàng Bài, Hoàn Kiếm, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (13, 12, N'Số 22, Tây Sơn, Đống Đa, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (14, 13, N'Số 68, Cầu Giấy, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (15, 14, N'Số 90, Minh Khai, Hai Bà Trưng, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (16, 15, N'Số 31, Nguyễn Văn Cừ, Long Biên, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (17, 16, N'Số 77, Đội Cấn, Ba Đình, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (18, 17, N'Số 33, Bạch Mai, Hai Bà Trưng, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (19, 18, N'Số 44, Đại Cồ Việt, Hai Bà Trưng, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (20, 19, N'Số 99, Láng Hạ, Đống Đa, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (21, 20, N'Số 12, Hoàng Cầu, Đống Đa, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (22, 21, N'Số 86, Trần Duy Hưng, Cầu Giấy, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (23, 22, N'Số 50, Nguyễn Trãi, Thanh Xuân, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (24, 23, N'Số 15, Láng Hạ, Đống Đa, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (25, 24, N'Số 108, Phố Huế, Hai Bà Trưng, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (26, 25, N'Số 9, Đinh Tiên Hoàng, Hoàn Kiếm, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (27, 26, N'Số 330, Nguyễn Xiển, Thanh Xuân, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (28, 27, N'Số 45, Phạm Hùng, Nam Từ Liêm, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (29, 28, N'Số 12, Lê Duẩn, Ba Đình, Hà Nội', 1);
INSERT INTO dbo.UserAddresses ([addressID], [userID], [addressDetails], [isDefault]) VALUES (30, 29, N'Số 66, Tràng Thi, Hoàn Kiếm, Hà Nội', 1);
SET IDENTITY_INSERT dbo.UserAddresses OFF;
GO

SET IDENTITY_INSERT dbo.Vouchers ON;
INSERT INTO dbo.Vouchers ([voucherID], [voucherCode], [discountPercent], [maxDiscountAmount], [startDate], [endDate]) VALUES (1, N'WELCOME50', 50.00, 50000.00, '2026-01-01 00:00:00', '2026-12-31 23:59:59');
INSERT INTO dbo.Vouchers ([voucherID], [voucherCode], [discountPercent], [maxDiscountAmount], [startDate], [endDate]) VALUES (2, N'FREESHIP', 15.00, 20000.00, '2026-05-01 00:00:00', '2026-06-01 23:59:59');
INSERT INTO dbo.Vouchers ([voucherID], [voucherCode], [discountPercent], [maxDiscountAmount], [startDate], [endDate]) VALUES (3, N'SUMMER20', 20.00, 40000.00, '2026-06-01 00:00:00', '2026-08-31 23:59:59');
INSERT INTO dbo.Vouchers ([voucherID], [voucherCode], [discountPercent], [maxDiscountAmount], [startDate], [endDate]) VALUES (4, N'FOODSALE30', 30.00, 60000.00, '2026-10-01 00:00:00', '2026-10-31 23:59:59');
INSERT INTO dbo.Vouchers ([voucherID], [voucherCode], [discountPercent], [maxDiscountAmount], [startDate], [endDate]) VALUES (5, N'TETGIAM10', 10.00, 30000.00, '2026-01-10 00:00:00', '2026-02-10 23:59:59');
INSERT INTO dbo.Vouchers ([voucherID], [voucherCode], [discountPercent], [maxDiscountAmount], [startDate], [endDate]) VALUES (6, N'WEEKEND15', 15.00, 25000.00, '2026-11-01 00:00:00', '2026-12-31 23:59:59');
INSERT INTO dbo.Vouchers ([voucherID], [voucherCode], [discountPercent], [maxDiscountAmount], [startDate], [endDate]) VALUES (7, N'VIPMEMBER', 25.00, 100000.00, '2026-01-01 00:00:00', '2026-12-31 23:59:59');
INSERT INTO dbo.Vouchers ([voucherID], [voucherCode], [discountPercent], [maxDiscountAmount], [startDate], [endDate]) VALUES (8, N'FLASH50', 50.00, 80000.00, '2026-11-11 00:00:00', '2026-11-12 23:59:59');
INSERT INTO dbo.Vouchers ([voucherID], [voucherCode], [discountPercent], [maxDiscountAmount], [startDate], [endDate]) VALUES (9, N'LUNCHTIME', 10.00, 15000.00, '2026-03-01 00:00:00', '2026-12-31 23:59:59');
INSERT INTO dbo.Vouchers ([voucherID], [voucherCode], [discountPercent], [maxDiscountAmount], [startDate], [endDate]) VALUES (10, N'DINNER20', 20.00, 50000.00, '2026-03-01 00:00:00', '2026-12-31 23:59:59');
SET IDENTITY_INSERT dbo.Vouchers OFF;
GO

SET IDENTITY_INSERT dbo.Categories ON;
INSERT INTO dbo.Categories ([categoryID], [name]) VALUES (1, N'Phở & Bún');
INSERT INTO dbo.Categories ([categoryID], [name]) VALUES (2, N'Cơm & Đồ ăn nhanh');
INSERT INTO dbo.Categories ([categoryID], [name]) VALUES (3, N'Pizza & Burger');
INSERT INTO dbo.Categories ([categoryID], [name]) VALUES (4, N'Gà rán & Đồ chiên');
INSERT INTO dbo.Categories ([categoryID], [name]) VALUES (5, N'Trà sữa & Đồ uống');
INSERT INTO dbo.Categories ([categoryID], [name]) VALUES (6, N'Bánh mì & Đồ ăn vặt');
INSERT INTO dbo.Categories ([categoryID], [name]) VALUES (7, N'Lẩu & Nướng');
INSERT INTO dbo.Categories ([categoryID], [name]) VALUES (8, N'Mì cay & Mì trộn');
INSERT INTO dbo.Categories ([categoryID], [name]) VALUES (9, N'Đồ chay thanh tịnh');
INSERT INTO dbo.Categories ([categoryID], [name]) VALUES (10, N'Tráng miệng & Hoa quả');
SET IDENTITY_INSERT dbo.Categories OFF;
GO

SET IDENTITY_INSERT dbo.Restaurants ON;
INSERT INTO dbo.Restaurants ([restaurantID], [managerID], [name], [address], [openingHours], [status]) VALUES (1, 11, N'Phở Thìn Láng Hạ', N'13 Láng Hạ, Đống Đa, Hà Nội', N'06:00 - 22:00', N'Active');
INSERT INTO dbo.Restaurants ([restaurantID], [managerID], [name], [address], [openingHours], [status]) VALUES (2, 11, N'Bún Chả Hàng Buồm', N'50 Hàng Buồm, Hoàn Kiếm, Hà Nội', N'09:00 - 21:00', N'Active');
INSERT INTO dbo.Restaurants ([restaurantID], [managerID], [name], [address], [openingHours], [status]) VALUES (3, 12, N'Cơm Tấm Sài Gòn S vị', N'105 Trần Đại Nghĩa, Hai Bà Trưng, Hà Nội', N'08:00 - 21:30', N'Active');
INSERT INTO dbo.Restaurants ([restaurantID], [managerID], [name], [address], [openingHours], [status]) VALUES (4, 12, N'Pizza Express Cầu Giấy', N'45 Xuân Thủy, Cầu Giấy, Hà Nội', N'10:00 - 23:00', N'Active');
INSERT INTO dbo.Restaurants ([restaurantID], [managerID], [name], [address], [openingHours], [status]) VALUES (5, 13, N'Gà Rán KFC Xuân Thủy', N'234 Xuân Thủy, Cầu Giấy, Hà Nội', N'09:00 - 22:00', N'Active');
INSERT INTO dbo.Restaurants ([restaurantID], [managerID], [name], [address], [openingHours], [status]) VALUES (6, 13, N'Trà Sữa Tocotoco', N'12 Chùa Bộc, Đống Đa, Hà Nội', N'08:30 - 23:00', N'Active');
INSERT INTO dbo.Restaurants ([restaurantID], [managerID], [name], [address], [openingHours], [status]) VALUES (7, 14, N'Bánh Mì Phượng Hội An', N'78 Hàng Bông, Hoàn Kiếm, Hà Nội', N'06:30 - 21:00', N'Active');
INSERT INTO dbo.Restaurants ([restaurantID], [managerID], [name], [address], [openingHours], [status]) VALUES (8, 14, N'Lẩu Thái Tomyum - King BBQ', N'Vincom Phạm Ngọc Thạch, Hà Nội', N'10:00 - 22:00', N'Active');
INSERT INTO dbo.Restaurants ([restaurantID], [managerID], [name], [address], [openingHours], [status]) VALUES (9, 15, N'Mì Cay Seoul', N'19 Hồ Tùng Mậu, Cầu Giấy, Hà Nội', N'09:00 - 22:00', N'Active');
INSERT INTO dbo.Restaurants ([restaurantID], [managerID], [name], [address], [openingHours], [status]) VALUES (10, 15, N'Bún Đậu Mắm Tôm A Chảnh', N'10 Định Công, Hoàng Mai, Hà Nội', N'10:00 - 21:00', N'Active');
SET IDENTITY_INSERT dbo.Restaurants OFF;
GO

SET IDENTITY_INSERT dbo.Products ON;
INSERT INTO dbo.Products ([productID], [restaurantID], [categoryID], [name], [price], [description], [imageURL]) VALUES (1, 1, 1, N'Phở bò tái lăn', 55000.00, N'Thịt bò tươi xào tỏi thơm lừng', N'pho_tai_lan.jpg');
INSERT INTO dbo.Products ([productID], [restaurantID], [categoryID], [name], [price], [description], [imageURL]) VALUES (2, 2, 1, N'Bún chả đặc biệt', 50000.00, N'Chả nướng than hoa truyền thống', N'bun_cha.jpg');
INSERT INTO dbo.Products ([productID], [restaurantID], [categoryID], [name], [price], [description], [imageURL]) VALUES (3, 3, 2, N'Cơm tấm sườn bì chả', 60000.00, N'Sườn nướng mật ong đậm đà', N'com_tam.jpg');
INSERT INTO dbo.Products ([productID], [restaurantID], [categoryID], [name], [price], [description], [imageURL]) VALUES (4, 4, 3, N'Pizza hải sản sốt phô mai', 129000.00, N'Đế mỏng giòn, topping tôm mực ngập phô mai', N'pizza_seafood.jpg');
INSERT INTO dbo.Products ([productID], [restaurantID], [categoryID], [name], [price], [description], [imageURL]) VALUES (5, 5, 4, N'Gà rán cay giòn (2 miếng)', 45000.00, N'Phủ sốt cay Hàn Quốc đậm vị', N'ga_ran.jpg');
INSERT INTO dbo.Products ([productID], [restaurantID], [categoryID], [name], [price], [description], [imageURL]) VALUES (6, 6, 5, N'Trà sữa trân châu hoàng kim', 42000.00, N'Trà sữa thơm béo, trân châu dai giòn', N'tra_sua.jpg');
INSERT INTO dbo.Products ([productID], [restaurantID], [categoryID], [name], [price], [description], [imageURL]) VALUES (7, 7, 6, N'Bánh mì hội an đầy đủ', 35000.00, N'Nhân thịt nguội, chả lụa, pate gan nhà làm', N'banh_mi.jpg');
INSERT INTO dbo.Products ([productID], [restaurantID], [categoryID], [name], [price], [description], [imageURL]) VALUES (8, 8, 7, N'Set lẩu thái hải sản size M', 250000.00, N'Nước lẩu thái chua cay chuẩn vị kèm bò mỹ và hải sản', N'lau_thai.jpg');
INSERT INTO dbo.Products ([productID], [restaurantID], [categoryID], [name], [price], [description], [imageURL]) VALUES (9, 9, 8, N'Mì cay cấp độ 1 hải sản', 55000.00, N'Mì Hàn Quốc kết hợp tôm mực nấm kim châm', N'mi_cay.jpg');
INSERT INTO dbo.Products ([productID], [restaurantID], [categoryID], [name], [price], [description], [imageURL]) VALUES (10, 10, 1, N'Bún đậu tá lả đầy đủ', 65000.00, N'Đậu mơ rán giòn, chả cốm, thịt chân giò luộc', N'bun_dau.jpg');
INSERT INTO dbo.Products ([productID], [restaurantID], [categoryID], [name], [price], [description], [imageURL]) VALUES (11, 1, 1, N'Phở bò tái nạm', 60000.00, N'Thịt bò tái kết hợp nạm giòn ngon', N'pho_tai_nam.jpg');
INSERT INTO dbo.Products ([productID], [restaurantID], [categoryID], [name], [price], [description], [imageURL]) VALUES (12, 1, 1, N'Phở sốt vang đặc biệt', 65000.00, N'Thịt bò sốt vang mềm nhừ đậm vị', N'pho_sot_vang.jpg');
INSERT INTO dbo.Products ([productID], [restaurantID], [categoryID], [name], [price], [description], [imageURL]) VALUES (13, 2, 1, N'Bún chả quẹt', 45000.00, N'Chả viên nướng đậm đà nước mắm tỏi ớt', N'bun_cha_quet.jpg');
INSERT INTO dbo.Products ([productID], [restaurantID], [categoryID], [name], [price], [description], [imageURL]) VALUES (14, 2, 1, N'Nem cua bể (2 cái)', 30000.00, N'Nem hải sản giòn rụm nhân cua bể', N'nem_cua_be.jpg');
INSERT INTO dbo.Products ([productID], [restaurantID], [categoryID], [name], [price], [description], [imageURL]) VALUES (15, 3, 2, N'Cơm tấm sườn trứng ốp la', 55000.00, N'Sườn nướng kèm trứng ốp la lòng đào', N'com_tam_suon_trung.jpg');
INSERT INTO dbo.Products ([productID], [restaurantID], [categoryID], [name], [price], [description], [imageURL]) VALUES (16, 3, 2, N'Cơm tấm đùi gà quay', 65000.00, N'Đùi gà quay da giòn nước sốt đậm vị', N'com_tam_dui_ga.jpg');
INSERT INTO dbo.Products ([productID], [restaurantID], [categoryID], [name], [price], [description], [imageURL]) VALUES (17, 4, 3, N'Pizza bò bằm Ý', 119000.00, N'Thịt bò bằm sốt cà chua và phô mai Mozzarella', N'pizza_beef.jpg');
INSERT INTO dbo.Products ([productID], [restaurantID], [categoryID], [name], [price], [description], [imageURL]) VALUES (18, 4, 3, N'Pizza xúc xích xông khói', 109000.00, N'Xúc xích Đức xông khói phủ phô mai béo ngậy', N'pizza_sausage.jpg');
INSERT INTO dbo.Products ([productID], [restaurantID], [categoryID], [name], [price], [description], [imageURL]) VALUES (19, 5, 4, N'Gà rán truyền thống (1 miếng)', 35000.00, N'Lớp vỏ giòn rụm, thịt gà mọng nước', N'ga_ran_truyen_thong.jpg');
INSERT INTO dbo.Products ([productID], [restaurantID], [categoryID], [name], [price], [description], [imageURL]) VALUES (20, 5, 4, N'Khoai tây chiên lắc phô mai', 30000.00, N'Khoai tây giòn rụm phủ bột phô mai thơm lừng', N'khoai_tay.jpg');
INSERT INTO dbo.Products ([productID], [restaurantID], [categoryID], [name], [price], [description], [imageURL]) VALUES (21, 6, 5, N'Hồng trà ô long kem trứng', 45000.00, N'Trà ô long thanh mát phủ lớp kem trứng béo ngậy', N'hong_tra.jpg');
INSERT INTO dbo.Products ([productID], [restaurantID], [categoryID], [name], [price], [description], [imageURL]) VALUES (22, 6, 5, N'Trà đào cam sả', 38000.00, N'Trà thanh mát kết hợp miếng đào tươi và sả thơm', N'tra_dao.jpg');
INSERT INTO dbo.Products ([productID], [restaurantID], [categoryID], [name], [price], [description], [imageURL]) VALUES (23, 7, 6, N'Bánh mì nướng muối ớt', 25000.00, N'Đậm vị cay ngọt, xúc xích, mỡ hành', N'banh_mi_nuong.jpg');
INSERT INTO dbo.Products ([productID], [restaurantID], [categoryID], [name], [price], [description], [imageURL]) VALUES (24, 7, 6, N'Bánh mì gà xé phay', 30000.00, N'Thịt gà xé trộn rau răm nước sốt đặc biệt', N'banh_mi_ga.jpg');
INSERT INTO dbo.Products ([productID], [restaurantID], [categoryID], [name], [price], [description], [imageURL]) VALUES (25, 8, 7, N'Ba chỉ bò Mỹ nhúng lẩu', 99000.00, N'Phần thịt ba chỉ tươi ngon cắt lát vừa ăn', N'ba_chi_bo.jpg');
SET IDENTITY_INSERT dbo.Products OFF;
GO

SET IDENTITY_INSERT dbo.FoodOptionGroups ON;
INSERT INTO dbo.FoodOptionGroups ([groupID], [productID], [groupName]) VALUES (1, 1, N'Chọn kích cỡ tô phở');
INSERT INTO dbo.FoodOptionGroups ([groupID], [productID], [groupName]) VALUES (2, 1, N'Thêm topping thịt bò');
INSERT INTO dbo.FoodOptionGroups ([groupID], [productID], [groupName]) VALUES (3, 4, N'Chọn kích cỡ bánh Pizza');
INSERT INTO dbo.FoodOptionGroups ([groupID], [productID], [groupName]) VALUES (4, 4, N'Chọn viền bánh');
INSERT INTO dbo.FoodOptionGroups ([groupID], [productID], [groupName]) VALUES (5, 6, N'Chọn mức đường');
INSERT INTO dbo.FoodOptionGroups ([groupID], [productID], [groupName]) VALUES (6, 6, N'Chọn mức đá');
INSERT INTO dbo.FoodOptionGroups ([groupID], [productID], [groupName]) VALUES (7, 8, N'Chọn loại nước lẩu');
INSERT INTO dbo.FoodOptionGroups ([groupID], [productID], [groupName]) VALUES (8, 9, N'Chọn cấp độ cay');
INSERT INTO dbo.FoodOptionGroups ([groupID], [productID], [groupName]) VALUES (9, 2, N'Chọn loại thịt bún chả');
INSERT INTO dbo.FoodOptionGroups ([groupID], [productID], [groupName]) VALUES (10, 5, N'Chọn vị gà rán');
SET IDENTITY_INSERT dbo.FoodOptionGroups OFF;
GO

SET IDENTITY_INSERT dbo.FoodOptionItems ON;
INSERT INTO dbo.FoodOptionItems ([itemID], [groupID], [itemName], [additionalPrice]) VALUES (1, 1, N'Tô thường', 0.00);
INSERT INTO dbo.FoodOptionItems ([itemID], [groupID], [itemName], [additionalPrice]) VALUES (2, 1, N'Tô đặc biệt', 15000.00);
INSERT INTO dbo.FoodOptionItems ([itemID], [groupID], [itemName], [additionalPrice]) VALUES (3, 2, N'Thêm trứng chần', 10000.00);
INSERT INTO dbo.FoodOptionItems ([itemID], [groupID], [itemName], [additionalPrice]) VALUES (4, 3, N'Size M (20cm)', 0.00);
INSERT INTO dbo.FoodOptionItems ([itemID], [groupID], [itemName], [additionalPrice]) VALUES (5, 3, N'Size L (30cm)', 50000.00);
INSERT INTO dbo.FoodOptionItems ([itemID], [groupID], [itemName], [additionalPrice]) VALUES (6, 4, N'Viền phô mai', 30000.00);
INSERT INTO dbo.FoodOptionItems ([itemID], [groupID], [itemName], [additionalPrice]) VALUES (7, 5, N'70% Đường', 0.00);
INSERT INTO dbo.FoodOptionItems ([itemID], [groupID], [itemName], [additionalPrice]) VALUES (8, 6, N'Ít đá', 0.00);
INSERT INTO dbo.FoodOptionItems ([itemID], [groupID], [itemName], [additionalPrice]) VALUES (9, 8, N'Cấp độ 1', 0.00);
INSERT INTO dbo.FoodOptionItems ([itemID], [groupID], [itemName], [additionalPrice]) VALUES (10, 10, N'Gà sốt cay', 0.00);
SET IDENTITY_INSERT dbo.FoodOptionItems OFF;
GO

SET IDENTITY_INSERT dbo.Orders ON;
INSERT INTO dbo.Orders ([orderID], [userID], [addressID], [voucherID], [orderDate], [shippingAddress], [status], [totalAmount]) VALUES (1, 1, 1, 1, '2026-11-10 20:04:44', N'Số 10, Đường Tôn Thất Thuyết, Cầu Giấy, Hà Nội', N'Completed', 70000.00);
INSERT INTO dbo.Orders ([orderID], [userID], [addressID], [voucherID], [orderDate], [shippingAddress], [status], [totalAmount]) VALUES (2, 2, 3, 2, '2026-11-10 20:04:44', N'Số 120, Phố Huế, Hai Bà Trưng, Hà Nội', N'Delivering', 50000.00);
INSERT INTO dbo.Orders ([orderID], [userID], [addressID], [voucherID], [orderDate], [shippingAddress], [status], [totalAmount]) VALUES (3, 3, 4, NULL, '2026-11-10 20:04:44', N'Số 54, Triều Khúc, Thanh Trì, Hà Nội', N'Processing', 129000.00);
INSERT INTO dbo.Orders ([orderID], [userID], [addressID], [voucherID], [orderDate], [shippingAddress], [status], [totalAmount]) VALUES (4, 4, 5, 3, '2026-11-10 20:04:44', N'Số 88, Phố Nhổn, Bắc Từ Liêm, Hà Nội', N'Pending', 90000.00);
INSERT INTO dbo.Orders ([orderID], [userID], [addressID], [voucherID], [orderDate], [shippingAddress], [status], [totalAmount]) VALUES (5, 5, 6, NULL, '2026-11-10 20:04:44', N'Số 15, Đường Phạm Văn Đồng, Cầu Giấy, Hà Nội', N'Completed', 42000.00);
INSERT INTO dbo.Orders ([orderID], [userID], [addressID], [voucherID], [orderDate], [shippingAddress], [status], [totalAmount]) VALUES (6, 1, 2, 4, '2026-11-10 20:04:44', N'Số 25, Ngõ 100 Hoàng Quốc Việt, Cầu Giấy, Hà Nội', N'Completed', 150000.00);
INSERT INTO dbo.Orders ([orderID], [userID], [addressID], [voucherID], [orderDate], [shippingAddress], [status], [totalAmount]) VALUES (7, 2, 3, NULL, '2026-11-10 20:04:44', N'Số 120, Phố Huế, Hai Bà Trưng, Hà Nội', N'Cancelled', 35000.00);
INSERT INTO dbo.Orders ([orderID], [userID], [addressID], [voucherID], [orderDate], [shippingAddress], [status], [totalAmount]) VALUES (8, 3, 4, 6, '2026-11-10 20:04:44', N'Số 54, Triều Khúc, Thanh Trì, Hà Nội', N'Processing', 250000.00);
INSERT INTO dbo.Orders ([orderID], [userID], [addressID], [voucherID], [orderDate], [shippingAddress], [status], [totalAmount]) VALUES (9, 4, 5, NULL, '2026-11-10 20:04:44', N'Số 88, Phố Nhổn, Bắc Từ Liêm, Hà Nội', N'Pending', 55000.00);
INSERT INTO dbo.Orders ([orderID], [userID], [addressID], [voucherID], [orderDate], [shippingAddress], [status], [totalAmount]) VALUES (10, 5, 6, 7, '2026-11-10 20:04:44', N'Số 15, Đường Phạm Văn Đồng, Cầu Giấy, Hà Nội', N'Completed', 65000.00);
INSERT INTO dbo.Orders ([orderID], [userID], [addressID], [voucherID], [orderDate], [shippingAddress], [status], [totalAmount]) VALUES (11, 1, NULL, 9, '2026-11-10 20:46:47', N'Số 10, Đường Tôn Thất Thuyết, Cầu Giấy, Hà Nội', N'Cancelled', 67500.00);
INSERT INTO dbo.Orders ([orderID], [userID], [addressID], [voucherID], [orderDate], [shippingAddress], [status], [totalAmount]) VALUES (12, 1, NULL, 7, '2026-11-10 20:47:08', N'Số 10, Đường Tôn Thất Thuyết, Cầu Giấy, Hà Nội', N'Pending', 22500.00);
SET IDENTITY_INSERT dbo.Orders OFF;
GO

SET IDENTITY_INSERT dbo.OrderDetails ON;
INSERT INTO dbo.OrderDetails ([orderDetailID], [orderID], [productID], [quantity], [unitPrice], [priceAtOrder]) VALUES (1, 1, 1, 1, 55000.00, 55000.00);
INSERT INTO dbo.OrderDetails ([orderDetailID], [orderID], [productID], [quantity], [unitPrice], [priceAtOrder]) VALUES (2, 2, 2, 1, 50000.00, 50000.00);
INSERT INTO dbo.OrderDetails ([orderDetailID], [orderID], [productID], [quantity], [unitPrice], [priceAtOrder]) VALUES (3, 3, 4, 1, 129000.00, 129000.00);
INSERT INTO dbo.OrderDetails ([orderDetailID], [orderID], [productID], [quantity], [unitPrice], [priceAtOrder]) VALUES (4, 4, 3, 1, 60000.00, 60000.00);
INSERT INTO dbo.OrderDetails ([orderDetailID], [orderID], [productID], [quantity], [unitPrice], [priceAtOrder]) VALUES (5, 5, 6, 1, 42000.00, 42000.00);
INSERT INTO dbo.OrderDetails ([orderDetailID], [orderID], [productID], [quantity], [unitPrice], [priceAtOrder]) VALUES (6, 6, 8, 1, 250000.00, 250000.00);
INSERT INTO dbo.OrderDetails ([orderDetailID], [orderID], [productID], [quantity], [unitPrice], [priceAtOrder]) VALUES (7, 7, 7, 1, 35000.00, 35000.00);
INSERT INTO dbo.OrderDetails ([orderDetailID], [orderID], [productID], [quantity], [unitPrice], [priceAtOrder]) VALUES (8, 8, 8, 1, 250000.00, 250000.00);
INSERT INTO dbo.OrderDetails ([orderDetailID], [orderID], [productID], [quantity], [unitPrice], [priceAtOrder]) VALUES (9, 9, 9, 1, 55000.00, 55000.00);
INSERT INTO dbo.OrderDetails ([orderDetailID], [orderID], [productID], [quantity], [unitPrice], [priceAtOrder]) VALUES (10, 10, 10, 1, 65000.00, 65000.00);
INSERT INTO dbo.OrderDetails ([orderDetailID], [orderID], [productID], [quantity], [unitPrice], [priceAtOrder]) VALUES (11, 11, 23, 3, 25000.00, 25000.00);
INSERT INTO dbo.OrderDetails ([orderDetailID], [orderID], [productID], [quantity], [unitPrice], [priceAtOrder]) VALUES (12, 12, 14, 1, 30000.00, 30000.00);
SET IDENTITY_INSERT dbo.OrderDetails OFF;
GO

SET IDENTITY_INSERT dbo.Payments ON;
INSERT INTO dbo.Payments ([paymentID], [orderID], [amount], [method], [transactionDate], [status]) VALUES (1, 1, 70000.00, N'Momo', '2026-11-10 20:04:44', N'Paid');
INSERT INTO dbo.Payments ([paymentID], [orderID], [amount], [method], [transactionDate], [status]) VALUES (2, 2, 50000.00, N'COD', '2026-11-10 20:04:44', N'Unpaid');
INSERT INTO dbo.Payments ([paymentID], [orderID], [amount], [method], [transactionDate], [status]) VALUES (3, 3, 129000.00, N'VNPay', '2026-11-10 20:04:44', N'Paid');
INSERT INTO dbo.Payments ([paymentID], [orderID], [amount], [method], [transactionDate], [status]) VALUES (4, 4, 90000.00, N'CreditCard', '2026-11-10 20:04:44', N'Paid');
INSERT INTO dbo.Payments ([paymentID], [orderID], [amount], [method], [transactionDate], [status]) VALUES (5, 5, 42000.00, N'Momo', '2026-11-10 20:04:44', N'Paid');
INSERT INTO dbo.Payments ([paymentID], [orderID], [amount], [method], [transactionDate], [status]) VALUES (6, 6, 150000.00, N'COD', '2026-11-10 20:04:44', N'Unpaid');
INSERT INTO dbo.Payments ([paymentID], [orderID], [amount], [method], [transactionDate], [status]) VALUES (7, 7, 35000.00, N'COD', '2026-11-10 20:04:44', N'Refunded');
INSERT INTO dbo.Payments ([paymentID], [orderID], [amount], [method], [transactionDate], [status]) VALUES (8, 8, 250000.00, N'VNPay', '2026-11-10 20:04:44', N'Paid');
INSERT INTO dbo.Payments ([paymentID], [orderID], [amount], [method], [transactionDate], [status]) VALUES (9, 9, 55000.00, N'Momo', '2026-11-10 20:04:44', N'Paid');
INSERT INTO dbo.Payments ([paymentID], [orderID], [amount], [method], [transactionDate], [status]) VALUES (10, 10, 65000.00, N'COD', '2026-11-10 20:04:44', N'Paid');
INSERT INTO dbo.Payments ([paymentID], [orderID], [amount], [method], [transactionDate], [status]) VALUES (11, 11, 67500.00, N'COD', '2026-11-10 20:46:47', N'Unpaid');
INSERT INTO dbo.Payments ([paymentID], [orderID], [amount], [method], [transactionDate], [status]) VALUES (12, 12, 22500.00, N'VNPay', '2026-11-10 20:47:08', N'Paid');
SET IDENTITY_INSERT dbo.Payments OFF;
GO

SET IDENTITY_INSERT dbo.Reviews ON;
INSERT INTO dbo.Reviews ([reviewID], [userID], [orderID], [productID], [rating], [comment], [reviewDate]) VALUES (1, 1, 1, 1, 5, N'Phở ngon, nước dùng đậm đà, ship nhanh!', '2026-11-10 20:04:44');
INSERT INTO dbo.Reviews ([reviewID], [userID], [orderID], [productID], [rating], [comment], [reviewDate]) VALUES (2, 2, 2, 2, 4, N'Bún chả thơm nhưng hơi ít thịt chút xíu.', '2026-11-10 20:04:44');
INSERT INTO dbo.Reviews ([reviewID], [userID], [orderID], [productID], [rating], [comment], [reviewDate]) VALUES (3, 3, 3, 4, 5, N'Pizza ngon tuyệt, nhiều phô mai kéo sợi thích lắm.', '2026-11-10 20:04:44');
INSERT INTO dbo.Reviews ([reviewID], [userID], [orderID], [productID], [rating], [comment], [reviewDate]) VALUES (4, 4, 4, 3, 4, N'Cơm tấm sườn mềm, nước mắm vừa miệng.', '2026-11-10 20:04:44');
INSERT INTO dbo.Reviews ([reviewID], [userID], [orderID], [productID], [rating], [comment], [reviewDate]) VALUES (5, 5, 5, 6, 5, N'Trà sữa béo ngậy, trân châu mềm ngon.', '2026-11-10 20:04:44');
INSERT INTO dbo.Reviews ([reviewID], [userID], [orderID], [productID], [rating], [comment], [reviewDate]) VALUES (6, 1, 6, 8, 5, N'Lẩu thái chua cay đúng vị, ăn đáng tiền.', '2026-11-10 20:04:44');
INSERT INTO dbo.Reviews ([reviewID], [userID], [orderID], [productID], [rating], [comment], [reviewDate]) VALUES (7, 2, 7, 7, 3, N'Bánh mì bình thường, hơi nguội khi nhận.', '2026-11-10 20:04:44');
INSERT INTO dbo.Reviews ([reviewID], [userID], [orderID], [productID], [rating], [comment], [reviewDate]) VALUES (8, 3, 8, 8, 5, N'Đóng gói cẩn thận, nước lẩu không bị đổ ra ngoài.', '2026-11-10 20:04:44');
INSERT INTO dbo.Reviews ([reviewID], [userID], [orderID], [productID], [rating], [comment], [reviewDate]) VALUES (9, 4, 9, 9, 4, N'Mì cay cấp 1 mà khá cay đối với mình, tổng thể ổn.', '2026-11-10 20:04:44');
INSERT INTO dbo.Reviews ([reviewID], [userID], [orderID], [productID], [rating], [comment], [reviewDate]) VALUES (10, 5, 10, 10, 5, N'Bún đậu mắm tôm chuẩn vị Bắc, ăn rất cuốn.', '2026-11-10 20:04:44');
SET IDENTITY_INSERT dbo.Reviews OFF;
GO

