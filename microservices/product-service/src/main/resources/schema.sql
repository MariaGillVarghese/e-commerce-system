-- Product Service Database Schema
-- Database: product_db (PostgreSQL Production)

CREATE TABLE IF NOT EXISTS products (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description VARCHAR(500),
    price NUMERIC(10, 2) NOT NULL,
    quantity INTEGER NOT NULL,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

-- Create index on product name for faster lookups
CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);

-- Insert sample data (optional)
INSERT INTO products (name, description, price, quantity, created_at, updated_at)
VALUES
    ('Laptop', 'High-performance laptop with 16GB RAM', 75000.00, 10, EXTRACT(EPOCH FROM NOW())::BIGINT * 1000, EXTRACT(EPOCH FROM NOW())::BIGINT * 1000),
    ('Mouse', 'Wireless mouse with ergonomic design', 1500.00, 50, EXTRACT(EPOCH FROM NOW())::BIGINT * 1000, EXTRACT(EPOCH FROM NOW())::BIGINT * 1000),
    ('Keyboard', 'Mechanical gaming keyboard with RGB', 5000.00, 25, EXTRACT(EPOCH FROM NOW())::BIGINT * 1000, EXTRACT(EPOCH FROM NOW())::BIGINT * 1000),
    ('Monitor', '27-inch 4K monitor', 25000.00, 15, EXTRACT(EPOCH FROM NOW())::BIGINT * 1000, EXTRACT(EPOCH FROM NOW())::BIGINT * 1000),
    ('Headphones', 'Noise-cancelling wireless headphones', 8000.00, 30, EXTRACT(EPOCH FROM NOW())::BIGINT * 1000, EXTRACT(EPOCH FROM NOW())::BIGINT * 1000)
ON CONFLICT (name) DO NOTHING;
