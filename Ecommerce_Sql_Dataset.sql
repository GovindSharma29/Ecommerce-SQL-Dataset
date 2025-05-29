DROP TABLE IF EXISTS E_order_items, E_payments, E_orders, E_customers, E_products;

CREATE TABLE E_customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);
INSERT INTO E_customers VALUES(1, 'Ram', 'ram@example.com'),(2, 'shyam', 'shyam@example.com'),(3, 'Charlie', 'charlie@example.com');

CREATE TABLE E_products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    price INT
);
INSERT INTO E_products VALUES(1, 'Laptop', 1000),(2, 'Mouse', 25),(3, 'Keyboard', 50);

CREATE TABLE E_orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount INT,
    FOREIGN KEY (customer_id) REFERENCES E_customers(customer_id)
);
INSERT INTO E_orders VALUES(101, 1, '2025-05-26', 1075),(102, 1, '2025-05-27', 1000),(103, 2, '2025-05-28', 75);

CREATE TABLE E_order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price INT,
    FOREIGN KEY (order_id) REFERENCES E_orders(order_id),
    FOREIGN KEY (product_id) REFERENCES E_products(product_id)
);
INSERT INTO E_order_items VALUES(1, 101, 1, 1, 1000.00),(2, 101, 2, 3, 25.00),(3, 102, 1, 1, 1000.00),(4, 103, 3, 1, 50.00),(5, 103, 2, 1, 25.00);

CREATE TABLE E_payments (
    payment_id INT PRIMARY KEY,
    order_id INT,
    payment_method VARCHAR(50),
    FOREIGN KEY (order_id) REFERENCES E_orders(order_id)
);
INSERT INTO E_payments VALUES(1, 101, 'Credit Card'),(2, 102, 'Upi'),(3, 103, 'Cash');

SELECT c.customer_id, c.name, c.email
FROM E_customers c
WHERE c.customer_id IN (
    SELECT customer_id
    FROM E_orders
    GROUP BY customer_id
    HAVING SUM(total_amount) > 1000
);

SELECT 
    p.product_id, 
    p.name AS product_name, 
    SUM(oi.quantity * oi.price) AS total_revenue
FROM E_products p
JOIN E_order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.name
ORDER BY total_revenue DESC;

SELECT 
    o.order_id, 
    c.name AS customer_name, 
    o.order_date, 
    o.total_amount, 
    pm.payment_method
FROM E_orders o
JOIN E_customers c ON o.customer_id = c.customer_id
JOIN E_payments pm ON o.order_id = pm.order_id;

SELECT c.customer_id, c.name
FROM E_customers c
LEFT JOIN E_orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

SELECT TOP 2 customer_id, SUM(total_amount) AS total_spent
FROM E_orders
GROUP BY customer_id
ORDER BY total_spent DESC;

CREATE OR ALTER VIEW monthly_revenue AS
SELECT 
    FORMAT(order_date, 'yyyy-MM') AS month,
    SUM(total_amount) AS revenue
FROM E_orders
GROUP BY FORMAT(order_date, 'yyyy-MM');

SELECT * FROM monthly_revenue WHERE revenue > 1000;

CREATE INDEX idx_orders_customer ON E_orders(customer_id);
CREATE INDEX idx_items_product ON E_order_items(product_id);