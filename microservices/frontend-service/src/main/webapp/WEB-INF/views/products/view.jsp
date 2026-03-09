<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Product - E-Commerce System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            padding: 20px;
        }
        .navbar {
            margin-bottom: 30px;
        }
        .product-details {
            background: #f8f9fa;
            padding: 30px;
            border-radius: 8px;
            border: 1px solid #ddd;
        }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="/">E-Commerce System</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item"><a class="nav-link" href="/ecommerce/">Home</a></li>
                    <li class="nav-item"><a class="nav-link active" href="/ecommerce/products">Products</a></li>
                    <li class="nav-item"><a class="nav-link" href="/ecommerce/orders">Orders</a></li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container">
        <div class="row mb-4">
            <div class="col-lg-8">
                <h2>Product Details</h2>
            </div>
            <div class="col-lg-4 text-end">
                <a href="/ecommerce/products" class="btn btn-secondary">Back to Products</a>
            </div>
        </div>

        <div class="product-details">
            <div class="row">
                <div class="col-md-6">
                    <h4>Product Information</h4>
                    <p><strong>Product ID:</strong> ${product.id}</p>
                    <p><strong>Name:</strong> ${product.name}</p>
                    <p><strong>Description:</strong> ${product.description}</p>
                </div>
                <div class="col-md-6">
                    <h4>Pricing & Inventory</h4>
                    <p><strong>Price:</strong> <span class="text-success">₹ ${product.price}</span></p>
                    <p><strong>Available Quantity:</strong> <span class="text-info">${product.quantity} units</span></p>
                    <a href="/ecommerce/orders/create?productId=${product.id}" class="btn btn-primary">Create Order</a>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
