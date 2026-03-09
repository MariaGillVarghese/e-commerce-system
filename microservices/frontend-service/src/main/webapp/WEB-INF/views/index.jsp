<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>E-Commerce System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            padding: 20px;
        }
        .navbar {
            margin-bottom: 30px;
        }
        .feature-box {
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 8px;
            text-align: center;
            transition: transform 0.3s;
        }
        .feature-box:hover {
            transform: translateY(-5px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        .feature-box h5 {
            margin-top: 15px;
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
                    <li class="nav-item"><a class="nav-link" href="/ecommerce/products">Products</a></li>
                    <li class="nav-item"><a class="nav-link" href="/ecommerce/orders">Orders</a></li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container">
        <div class="row text-center mb-5">
            <div class="col-lg-12">
                <h1 class="mb-4">Welcome to E-Commerce System</h1>
                <p class="lead mb-4">Manage your products and orders efficiently</p>
            </div>
        </div>

        <div class="row">
            <div class="col-md-4">
                <div class="feature-box">
                    <h3>📦</h3>
                    <h5>Product Management</h5>
                    <p>Create, view, and manage products in your catalog</p>
                    <a href="/ecommerce/products" class="btn btn-primary">View Products</a>
                </div>
            </div>
            <div class="col-md-4">
                <div class="feature-box">
                    <h3>🛒</h3>
                    <h5>Order Management</h5>
                    <p>Create and track customer orders</p>
                    <a href="/ecommerce/orders" class="btn btn-primary">View Orders</a>
                </div>
            </div>
            <div class="col-md-4">
                <div class="feature-box">
                    <h3>✅</h3>
                    <h5>Quick Actions</h5>
                    <p>Quickly create new products and orders</p>
                    <div>
                        <a href="/ecommerce/products/create" class="btn btn-success btn-sm">+ Product</a>
                        <a href="/ecommerce/orders/create" class="btn btn-success btn-sm">+ Order</a>
                    </div>
                </div>
            </div>
        </div>

        <div class="row mt-5">
            <div class="col-lg-12">
                <h4>How to use this system:</h4>
                <ul class="lead">
                    <li><strong>Products:</strong> Browse all products, view details, or create new products</li>
                    <li><strong>Orders:</strong> Create orders by selecting products from catalog, track order status</li>
                    <li><strong>Validation:</strong> Order service automatically validates product availability before creating orders</li>
                </ul>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
