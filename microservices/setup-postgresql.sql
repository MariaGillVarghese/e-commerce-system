-- PostgreSQL Setup Script for E-Commerce Microservices

-- Create databases
CREATE DATABASE product_db;
CREATE DATABASE order_db;

-- Create application user
CREATE USER ecommerce_user WITH PASSWORD 'SecurePassword123!';

-- Grant DB level access
GRANT ALL PRIVILEGES ON DATABASE product_db TO ecommerce_user;
GRANT ALL PRIVILEGES ON DATABASE order_db TO ecommerce_user;

---

## -- PRODUCT DATABASE SETUP

\c product_db

-- Run schema
\i product-service/src/main/resources/schema.sql

-- Grant table privileges
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ecommerce_user;

-- Grant sequence privileges (needed for SERIAL/BIGSERIAL)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO ecommerce_user;

-- Ensure future tables/sequences also get permissions
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL ON TABLES TO ecommerce_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT USAGE, SELECT ON SEQUENCES TO ecommerce_user;

---

## -- ORDER DATABASE SETUP

\c order_db

-- Run schema
\i order-service/src/main/resources/schema.sql

-- Grant table privileges
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ecommerce_user;

-- Grant sequence privileges
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO ecommerce_user;

-- Ensure future tables/sequences also get permissions
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL ON TABLES TO ecommerce_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT USAGE, SELECT ON SEQUENCES TO ecommerce_user;
