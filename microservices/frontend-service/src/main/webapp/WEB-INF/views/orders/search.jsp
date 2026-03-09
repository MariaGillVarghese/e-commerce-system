<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search Orders - E-Commerce System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            padding: 20px;
        }
        .navbar {
            margin-bottom: 30px;
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
        <h2 class="mb-4">Search Orders by Customer</h2>

        <div class="row mb-4">
            <div class="col-lg-6">
                <form method="GET" action="/ecommerce/orders/customer">
                    <div class="input-group">
                        <input type="text" name="name" class="form-control" placeholder="Enter customer name" 
                               value="${customerName}">
                        <button type="submit" class="btn btn-primary">Search</button>
                        <a href="/ecommerce/orders" class="btn btn-secondary">View All</a>
                    </div>
                </form>
            </div>
        </div>

        <c:if test="${not empty customerName}">
            <h5>Results for: ${customerName}</h5>
        </c:if>

        <c:if test="${empty orders && not empty customerName}">
            <div class="alert alert-info">No orders found for customer name: ${customerName}</div>
        </c:if>

        <c:if test="${not empty orders}">
            <div class="table-responsive">
                <table class="table table-striped table-hover">
                    <thead class="table-dark">
                        <tr>
                            <th>Order ID</th>
                            <th>Customer Name</th>
                            <th>Product ID</th>
                            <th>Quantity</th>
                            <th>Total Price</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${orders}" var="order">
                            <tr>
                                <td>${order.id}</td>
                                <td>${order.customerName}</td>
                                <td>${order.productId}</td>
                                <td>${order.quantity}</td>
                                <td>₹ ${order.totalPrice}</td>
                                <td>
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
                                </td>
                                <td>
                                    <a href="/ecommerce/orders/view/${order.id}" class="btn btn-sm btn-info">View</a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:if>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
