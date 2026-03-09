-- Order Service Database Schema
-- Database: order_db (PostgreSQL Production)

CREATE TABLE IF NOT EXISTS orders (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    quantity INTEGER NOT NULL,
    total_price NUMERIC(10, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'PENDING',
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255),
    shipping_address VARCHAR(500),
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_orders_customer_name ON orders(customer_name);
CREATE INDEX IF NOT EXISTS idx_orders_product_id ON orders(product_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);

-- Insert sample data (optional - create sample orders)
INSERT INTO orders (product_id, quantity, total_price, status, customer_name, customer_email, shipping_address, created_at, updated_at)
VALUES
    (1, 1, 75000.00, 'PENDING', 'John Doe', 'john@example.com', '123 Main Street, New York, NY 10001', EXTRACT(EPOCH FROM NOW())::BIGINT * 1000, EXTRACT(EPOCH FROM NOW())::BIGINT * 1000),
    (2, 2, 3000.00, 'CONFIRMED', 'Jane Smith', 'jane@example.com', '456 Oak Avenue, Los Angeles, CA 90001', EXTRACT(EPOCH FROM NOW())::BIGINT * 1000, EXTRACT(EPOCH FROM NOW())::BIGINT * 1000),
    (3, 1, 5000.00, 'SHIPPED', 'Bob Johnson', 'bob@example.com', '789 Pine Road, Chicago, IL 60601', EXTRACT(EPOCH FROM NOW())::BIGINT * 1000, EXTRACT(EPOCH FROM NOW())::BIGINT * 1000)
ON CONFLICT DO NOTHING;
