# Complete SQL Hands-On Practice: Database Normalization

## 🎯 Exercise 1: Social Media App

### Scenario
Build a social media app where users post content with tags, and users have different subscription plans.

### Step-by-Step SQL Script

```sql
-- ============================================================
-- SOCIAL MEDIA APP NORMALIZATION
-- ============================================================

CREATE DATABASE IF NOT EXISTS social_media_demo;
USE social_media_demo;

-- ============================================================
-- UNNORMALIZED VERSION (The Problem)
-- ============================================================

CREATE TABLE posts_unnormalized (
    PostID INT,
    Username VARCHAR(50),
    UserEmail VARCHAR(100),
    UserPlan VARCHAR(20),
    PlanPrice DECIMAL(10,2),
    PostContent TEXT,
    Tags VARCHAR(200),  -- Multiple values in one cell!
    LikeCount INT
);

INSERT INTO posts_unnormalized VALUES
(1, 'alice_wonder', 'alice@email.com', 'Premium', 9.99, 
 'Beautiful sunset!', 'nature,sunset,photography', 150),
(2, 'bob_builder', 'bob@email.com', 'Free', 0.00, 
 'New project completed', 'work,project', 45),
(3, 'alice_wonder', 'alice@email.com', 'Premium', 9.99, 
 'Morning coffee', 'coffee,morning,lifestyle', 89);

-- See the messy data
SELECT * FROM posts_unnormalized;

-- ============================================================
-- NORMALIZED VERSION (3NF Solution)
-- ============================================================

-- Create Plans table
CREATE TABLE plans (
    PlanName VARCHAR(20) PRIMARY KEY,
    PlanPrice DECIMAL(10,2) NOT NULL,
    MaxPosts INT,
    Features TEXT
);

INSERT INTO plans VALUES
('Free', 0.00, 10, 'Basic features'),
('Premium', 9.99, 100, 'Advanced features + No ads'),
('Pro', 19.99, -1, 'Unlimited + Analytics + API access');

-- Create Users table
CREATE TABLE users_3nf (
    Username VARCHAR(50) PRIMARY KEY,
    UserEmail VARCHAR(100) NOT NULL UNIQUE,
    UserPlan VARCHAR(20) NOT NULL,
    JoinDate DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (UserPlan) REFERENCES plans(PlanName)
);

INSERT INTO users_3nf (Username, UserEmail, UserPlan) VALUES
('alice_wonder', 'alice@email.com', 'Premium'),
('bob_builder', 'bob@email.com', 'Free'),
('charlie_coder', 'charlie@email.com', 'Pro');

-- Create Posts table
CREATE TABLE posts (
    PostID INT PRIMARY KEY,
    Username VARCHAR(50) NOT NULL,
    PostContent TEXT NOT NULL,
    LikeCount INT DEFAULT 0,
    PostDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (Username) REFERENCES users_3nf(Username)
);

INSERT INTO posts (PostID, Username, PostContent, LikeCount) VALUES
(1, 'alice_wonder', 'Beautiful sunset!', 150),
(2, 'bob_builder', 'New project completed', 45),
(3, 'alice_wonder', 'Morning coffee', 89),
(4, 'charlie_coder', 'Code snippet', 200);

-- Create Tags table
CREATE TABLE tags (
    TagName VARCHAR(50) PRIMARY KEY,
    TagCategory VARCHAR(50)
);

INSERT INTO tags VALUES
('nature', 'lifestyle'),
('sunset', 'lifestyle'),
('photography', 'creative'),
('work', 'professional'),
('project', 'professional'),
('coffee', 'lifestyle'),
('morning', 'lifestyle'),
('programming', 'tech'),
('code', 'tech');

-- Create PostTags junction table
CREATE TABLE post_tags (
    PostID INT,
    TagName VARCHAR(50),
    PRIMARY KEY (PostID, TagName),
    FOREIGN KEY (PostID) REFERENCES posts(PostID),
    FOREIGN KEY (TagName) REFERENCES tags(TagName)
);

INSERT INTO post_tags VALUES
(1, 'nature'), (1, 'sunset'), (1, 'photography'),
(2, 'work'), (2, 'project'),
(3, 'coffee'), (3, 'morning'),
(4, 'programming'), (4, 'code');

-- ============================================================
-- POWERFUL QUERIES
-- ============================================================

-- Get all user posts with plan details
SELECT 
    u.Username,
    u.UserEmail,
    p.PlanName,
    p.PlanPrice,
    COUNT(po.PostID) as TotalPosts,
    SUM(po.LikeCount) as TotalLikes
FROM users_3nf u
JOIN plans p ON u.UserPlan = p.PlanName
LEFT JOIN posts po ON u.Username = po.Username
GROUP BY u.Username, u.UserEmail, p.PlanName, p.PlanPrice;

-- Find posts with specific tag category
SELECT DISTINCT
    po.PostID,
    po.PostContent,
    u.Username,
    GROUP_CONCAT(pt.TagName) as AllTags
FROM posts po
JOIN post_tags pt ON po.PostID = pt.PostID
JOIN tags t ON pt.TagName = t.TagName
JOIN users_3nf u ON po.Username = u.Username
WHERE t.TagCategory = 'tech'
GROUP BY po.PostID, po.PostContent, u.Username;

-- Update plan price (affects all users automatically!)
UPDATE plans 
SET PlanPrice = 11.99 
WHERE PlanName = 'Premium';

-- Most popular tags
SELECT 
    t.TagName,
    t.TagCategory,
    COUNT(pt.PostID) as TimesUsed,
    SUM(p.LikeCount) as TotalLikes
FROM tags t
JOIN post_tags pt ON t.TagName = pt.TagName
JOIN posts p ON pt.PostID = p.PostID
GROUP BY t.TagName, t.TagCategory
ORDER BY TotalLikes DESC;
```

---

## 🛍️ Exercise 2: E-Commerce Store

### Scenario
Online store with customers, products, orders, and shipping methods.

### SQL Script

```sql
-- ============================================================
-- E-COMMERCE STORE NORMALIZATION
-- ============================================================

CREATE DATABASE IF NOT EXISTS ecommerce_demo;
USE ecommerce_demo;

-- ============================================================
-- UNNORMALIZED VERSION
-- ============================================================

CREATE TABLE orders_messy (
    OrderID INT,
    OrderDate DATE,
    CustomerName VARCHAR(100),
    CustomerEmail VARCHAR(100),
    CustomerCity VARCHAR(50),
    ProductNames VARCHAR(200),      -- Multiple products!
    ProductPrices VARCHAR(100),      -- Multiple prices!
    ProductCategories VARCHAR(200),  -- Multiple categories!
    TotalAmount DECIMAL(10,2),
    ShippingMethod VARCHAR(50),
    ShippingCost DECIMAL(10,2)
);

INSERT INTO orders_messy VALUES
(1, '2024-10-01', 'Alice Johnson', 'alice@email.com', 'Mumbai',
 'Laptop,Mouse', '50000,500', 'Electronics,Accessories', 50500, 'Express', 200),
(2, '2024-10-02', 'Bob Smith', 'bob@email.com', 'Delhi',
 'Book', '300', 'Books', 300, 'Standard', 50);

-- ============================================================
-- NORMALIZED VERSION (3NF)
-- ============================================================

-- Categories table
CREATE TABLE categories (
    CategoryID INT PRIMARY KEY AUTO_INCREMENT,
    CategoryName VARCHAR(50) UNIQUE NOT NULL,
    Description TEXT
);

INSERT INTO categories (CategoryName, Description) VALUES
('Electronics', 'Electronic devices and gadgets'),
('Accessories', 'Computer and phone accessories'),
('Books', 'Physical and digital books');

-- Products table
CREATE TABLE products (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    CategoryID INT,
    Stock INT DEFAULT 0,
    FOREIGN KEY (CategoryID) REFERENCES categories(CategoryID)
);

INSERT INTO products (ProductName, Price, CategoryID, Stock) VALUES
('Laptop', 50000, 1, 10),
('Mouse', 500, 2, 50),
('Book', 300, 3, 100);

-- Shipping methods table
CREATE TABLE shipping_methods (
    MethodID INT PRIMARY KEY AUTO_INCREMENT,
    MethodName VARCHAR(50) UNIQUE NOT NULL,
    Cost DECIMAL(10,2) NOT NULL,
    DeliveryDays INT
);

INSERT INTO shipping_methods (MethodName, Cost, DeliveryDays) VALUES
('Standard', 50, 7),
('Express', 200, 2),
('Same Day', 500, 1);

-- Customers table
CREATE TABLE customers (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerName VARCHAR(100) NOT NULL,
    CustomerEmail VARCHAR(100) UNIQUE NOT NULL,
    CustomerCity VARCHAR(50)
);

INSERT INTO customers (CustomerName, CustomerEmail, CustomerCity) VALUES
('Alice Johnson', 'alice@email.com', 'Mumbai'),
('Bob Smith', 'bob@email.com', 'Delhi');

-- Orders table
CREATE TABLE orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATE NOT NULL,
    ShippingMethodID INT NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL,
    Status VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID),
    FOREIGN KEY (ShippingMethodID) REFERENCES shipping_methods(MethodID)
);

INSERT INTO orders VALUES
(1, 1, '2024-10-01', 2, 50500, 'Delivered'),
(2, 2, '2024-10-02', 1, 300, 'Delivered');

-- Order items table
CREATE TABLE order_items (
    OrderItemID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    PriceAtPurchase DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES products(ProductID)
);

INSERT INTO order_items (OrderID, ProductID, Quantity, PriceAtPurchase) VALUES
(1, 1, 1, 50000),  -- Laptop
(1, 2, 1, 500),    -- Mouse
(2, 3, 1, 300);    -- Book

-- ============================================================
-- POWERFUL QUERIES
-- ============================================================

-- Complete order details
SELECT 
    o.OrderID,
    c.CustomerName,
    c.CustomerEmail,
    o.OrderDate,
    sm.MethodName as ShippingMethod,
    sm.Cost as ShippingCost,
    o.TotalAmount,
    o.Status
FROM orders o
JOIN customers c ON o.CustomerID = c.CustomerID
JOIN shipping_methods sm ON o.ShippingMethodID = sm.MethodID;

-- Order items with product details
SELECT 
    o.OrderID,
    c.CustomerName,
    p.ProductName,
    cat.CategoryName,
    oi.Quantity,
    oi.PriceAtPurchase,
    (oi.Quantity * oi.PriceAtPurchase) as ItemTotal
FROM orders o
JOIN customers c ON o.CustomerID = c.CustomerID
JOIN order_items oi ON o.OrderID = oi.OrderID
JOIN products p ON oi.ProductID = p.ProductID
JOIN categories cat ON p.CategoryID = cat.CategoryID;

-- Customer purchase history
SELECT 
    c.CustomerName,
    COUNT(DISTINCT o.OrderID) as TotalOrders,
    SUM(o.TotalAmount) as TotalSpent
FROM customers c
LEFT JOIN orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.CustomerName;

-- Most popular products
SELECT 
    p.ProductName,
    COUNT(oi.OrderItemID) as TimesSold,
    SUM(oi.Quantity * oi.PriceAtPurchase) as TotalRevenue
FROM products p
LEFT JOIN order_items oi ON p.ProductID = oi.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY TotalRevenue DESC;
```

---

## 🎯 Practice Exercises

### Exercise 1: Add New Data
```sql
-- Add a new customer
INSERT INTO customers (CustomerName, CustomerEmail, CustomerCity) 
VALUES ('Diana Prince', 'diana@email.com', 'Pune');

-- Create an order for Diana
INSERT INTO orders (OrderID, CustomerID, OrderDate, ShippingMethodID, TotalAmount) 
VALUES (3, 3, '2024-10-05', 1, 500);

-- Add items to the order
INSERT INTO order_items (OrderID, ProductID, Quantity, PriceAtPurchase) 
VALUES (3, 2, 1, 500);
```

### Exercise 2: Update Operations
```sql
-- Update shipping cost (affects all orders using this method)
UPDATE shipping_methods 
SET Cost = 250 
WHERE MethodName = 'Express';

-- Check which orders are affected
SELECT o.OrderID, c.CustomerName, sm.MethodName, sm.Cost
FROM orders o
JOIN customers c ON o.CustomerID = c.CustomerID
JOIN shipping_methods sm ON o.ShippingMethodID = sm.MethodID
WHERE sm.MethodName = 'Express';
```

### Exercise 3: Complex Queries
```sql
-- Find customers who ordered from multiple categories
SELECT 
    c.CustomerName,
    COUNT(DISTINCT cat.CategoryID) as DifferentCategories
FROM customers c
JOIN orders o ON c.CustomerID = o.CustomerID
JOIN order_items oi ON o.OrderID = oi.OrderID
JOIN products p ON oi.ProductID = p.ProductID
JOIN categories cat ON p.CategoryID = cat.CategoryID
GROUP BY c.CustomerID, c.CustomerName
HAVING COUNT(DISTINCT cat.CategoryID) > 1;
```

---

## 🏆 Advanced Challenges

### Challenge 1: Add Discounts
```sql
-- Create discounts table
CREATE TABLE discounts (
    DiscountID INT PRIMARY KEY AUTO_INCREMENT,
    DiscountCode VARCHAR(20) UNIQUE NOT NULL,
    DiscountPercent DECIMAL(5,2) NOT NULL,
    ValidUntil DATE
);

-- Add discount to orders table
ALTER TABLE orders ADD COLUMN DiscountID INT;
ALTER TABLE orders ADD FOREIGN KEY (DiscountID) REFERENCES discounts(DiscountID);
```

### Challenge 2: Product Reviews
```sql
-- Create reviews table
CREATE TABLE product_reviews (
    ReviewID INT PRIMARY KEY AUTO_INCREMENT,
    ProductID INT NOT NULL,
    CustomerID INT NOT NULL,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    ReviewText TEXT,
    ReviewDate DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (ProductID) REFERENCES products(ProductID),
    FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID)
);
```

### Challenge 3: Create a View
```sql
-- Customer order summary view
CREATE VIEW customer_order_summary AS
SELECT 
    c.CustomerID,
    c.CustomerName,
    c.CustomerEmail,
    COUNT(DISTINCT o.OrderID) as TotalOrders,
    SUM(o.TotalAmount) as TotalSpent,
    AVG(o.TotalAmount) as AvgOrderValue,
    MAX(o.OrderDate) as LastOrderDate
FROM customers c
LEFT JOIN orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.CustomerName, c.CustomerEmail;

-- Use the view
SELECT * FROM customer_order_summary WHERE TotalOrders > 1;
```

---

## 📚 More Practice Scenarios

Try normalizing these on your own:

### 1. Hospital Management System
- Tables: Patients, Doctors, Appointments, Prescriptions, Medicines
- Challenge: Handle many-to-many relationships between doctors and specializations

### 2. School Management System
- Tables: Students, Teachers, Courses, Enrollments, Grades
- Challenge: Track course prerequisites and grade dependencies

### 3. Movie Streaming Service
- Tables: Users, Movies, Actors, Genres, Watch_History
- Challenge: Handle movie-actor relationships and viewing statistics

### 4. Food Delivery App
- Tables: Restaurants, Menu_Items, Customers, Orders, Delivery_Partners
- Challenge: Track order status changes and delivery zones

---

## 💡 Tips for Practice

1. **Start Simple**: Begin with unnormalized data
2. **Identify Problems**: Look for redundancy and anomalies
3. **Apply Rules**: Follow 1NF → 2NF → 3NF systematically
4. **Test Queries**: Write queries to verify your design
5. **Think Real-World**: Consider actual business scenarios
6. **Use Constraints**: Always add PRIMARY KEY and FOREIGN KEY constraints
7. **Practice Regularly**: Try new scenarios to build intuition

---

## 🎓 Key Takeaways

- **Normalization eliminates redundancy** and improves data integrity
- **1NF**: Atomic values only
- **2NF**: Remove partial dependencies
- **3NF**: Remove transitive dependencies
- **Foreign keys** maintain relationships between tables
- **JOIN operations** reconstruct the full picture when needed
- **Updates become simple** - change once, affect all related records

Happy practicing! 🚀