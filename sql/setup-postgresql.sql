-- PostgreSQL Setup Script for E-Commerce Microservices
-- Run this script in PostgreSQL to create the required databases and user

-- Create databases
CREATE DATABASE product_db;
CREATE DATABASE order_db;

-- Create user with secure password
CREATE USER ecommerce_user WITH PASSWORD 'SecurePassword123!';
GRANT ALL PRIVILEGES ON DATABASE product_db TO ecommerce_user;
GRANT ALL PRIVILEGES ON DATABASE order_db TO ecommerce_user;

-- Connect to product_db and run the schema
\c product_db
\i product-service-schema.sql

-- Connect to order_db and run the schema
\c order_db
\i order-service-schema.sql