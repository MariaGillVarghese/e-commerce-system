<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Order - E-Commerce System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            padding: 20px;
        }
        .navbar {
            margin-bottom: 30px;
        }
        .order-details {
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
                    <li class="nav-item"><a class="nav-link" href="/ecommerce/products">Products</a></li>
                    <li class="nav-item"><a class="nav-link active" href="/ecommerce/orders">Orders</a></li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container">
        <div class="row mb-4">
            <div class="col-lg-8">
                <h2>Order Details</h2>
            </div>
            <div class="col-lg-4 text-end">
                <a href="/ecommerce/orders" class="btn btn-secondary">Back to Orders</a>
            </div>
        </div>

        <div class="order-details">
            <div class="row">
                <div class="col-md-6">
                    <h4>Order Information</h4>
                    <p><strong>Order ID:</strong> ${order.id}</p>
                    <p><strong>Status:</strong> 
                        <span class="badge 
                            <c:choose>
                                <c:when test="${order.status == 'PENDING'}">bg-warning</c:when>
                                <c:when test="${order.status == 'CONFIRMED'}">bg-info</c:when>
                                <c:when test="${order.status == 'SHIPPED'}">bg-primary</c:when>
                                <c:when test="${order.status == 'DELIVERED'}">bg-success</c:when>
                                <c:when test="${order.status == 'CANCELLED'}">bg-danger</c:when>
                                <c:otherwise>bg-secondary</c:otherwise>
                            </c:choose>">
                            ${order.status}
                        </span>
                    </p>
                </div>
                <div class="col-md-6">
                    <h4>Customer Information</h4>
                    <p><strong>Name:</strong> ${order.customerName}</p>
                    <p><strong>Email:</strong> ${order.customerEmail}</p>
                    <p><strong>Shipping Address:</strong> ${order.shippingAddress}</p>
                </div>
            </div>

            <hr>

            <div class="row">
                <div class="col-md-6">
                    <h4>Product Information</h4>
                    <c:if test="${not empty product}">
                        <p><strong>Product:</strong> ${product.name}</p>
                        <p><strong>Price:</strong> ₹ ${product.price}</p>
                        <p><strong>Description:</strong> ${product.description}</p>
                    </c:if>
                </div>
                <div class="col-md-6">
                    <h4>Order Details</h4>
                    <p><strong>Product ID:</strong> ${order.productId}</p>
                    <p><strong>Quantity:</strong> ${order.quantity} units</p>
                    <p><strong>Total Price:</strong> <span class="text-success">₹ ${order.totalPrice}</span></p>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
