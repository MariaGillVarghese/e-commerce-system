<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Order - E-Commerce System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            padding: 20px;
        }
        .navbar {
            margin-bottom: 30px;
        }
        .form-container {
            max-width: 700px;
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
        <div class="row">
            <div class="col-lg-8">
                <h2>Create New Order</h2>
            </div>
        </div>

        <c:if test="${param.error != null}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ${param.error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <div class="form-container mt-4">
            <form method="POST" action="/ecommerce/orders/create" class="needs-validation">
                <h5 class="mb-3">Customer Information</h5>

                <div class="mb-3">
                    <label for="customerName" class="form-label">Customer Name *</label>
                    <input type="text" class="form-control" id="customerName" name="customerName" required 
                           placeholder="Enter customer name">
                </div>

                <div class="mb-3">
                    <label for="customerEmail" class="form-label">Customer Email *</label>
                    <input type="email" class="form-control" id="customerEmail" name="customerEmail" required 
                           placeholder="Enter customer email">
                </div>

                <div class="mb-3">
                    <label for="shippingAddress" class="form-label">Shipping Address *</label>
                    <textarea class="form-control" id="shippingAddress" name="shippingAddress" rows="3" required 
                              placeholder="Enter complete shipping address"></textarea>
                </div>

                <hr>
                <h5 class="mb-3">Product & Order Details</h5>

                <div class="mb-3">
                    <label for="productId" class="form-label">Select Product *</label>
                    <select class="form-select" id="productId" name="productId" required onchange="updateProductDetails()">
                        <option value="">-- Select a product --</option>
                        <c:forEach items="${products}" var="product">
                            <option value="${product.id}" data-price="${product.price}">
                                ${product.name} (₹ ${product.price})
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="mb-3">
                    <label for="quantity" class="form-label">Quantity *</label>
                    <input type="number" class="form-control" id="quantity" name="quantity" required 
                           placeholder="Enter quantity" min="1" onchange="updateTotalPrice()">
                </div>

                <div class="mb-3">
                    <label for="totalPrice" class="form-label">Total Price (₹)</label>
                    <input type="number" class="form-control" id="totalPrice" name="totalPrice" readonly 
                           placeholder="Calculated automatically" step="0.01">
                </div>

                <div class="d-flex gap-2">
                    <button type="submit" class="btn btn-success">Create Order</button>
                    <a href="/ecommerce/orders" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>

    <script>
        function updateProductDetails() {
            updateTotalPrice();
        }

        function updateTotalPrice() {
            const productSelect = document.getElementById('productId');
            const quantityInput = document.getElementById('quantity');
            const totalPriceInput = document.getElementById('totalPrice');
            
            const selectedOption = productSelect.options[productSelect.selectedIndex];
            const price = selectedOption.getAttribute('data-price');
            const quantity = quantityInput.value;
            
            if (price && quantity) {
                const total = parseFloat(price) * parseInt(quantity);
                totalPriceInput.value = total.toFixed(2);
            } else {
                totalPriceInput.value = '';
            }
        }
    </script>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
