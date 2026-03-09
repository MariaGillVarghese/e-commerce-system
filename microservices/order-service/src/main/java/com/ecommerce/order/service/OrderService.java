package com.ecommerce.order.service;

import com.ecommerce.order.entity.Order;
import com.ecommerce.order.repository.OrderRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Optional;

@Service
@Slf4j
@Transactional
public class OrderService {
    
    @Autowired
    private OrderRepository orderRepository;
    
    @Autowired
    private RestTemplate restTemplate;
    
    @Value("${product.service.url}")
    private String productServiceUrl;
    
    public Order createOrder(Order order) {
        log.info("Creating order for product id: {} with quantity: {}", order.getProductId(), order.getQuantity());
        
        // Validate product exists
        if (!validateProductExists(order.getProductId())) {
            throw new RuntimeException("Product not found with id: " + order.getProductId());
        }
        
        return orderRepository.save(order);
    }
    
    public List<Order> getAllOrders() {
        log.info("Fetching all orders");
        return orderRepository.findAll();
    }
    
    public Optional<Order> getOrderById(Long id) {
        log.info("Fetching order by id: {}", id);
        return orderRepository.findById(id);
    }
    
    public List<Order> getOrdersByCustomer(String customerName) {
        log.info("Fetching orders for customer: {}", customerName);
        return orderRepository.findByCustomerName(customerName);
    }
    
    public List<Order> getOrdersByProduct(Long productId) {
        log.info("Fetching orders for product id: {}", productId);
        return orderRepository.findByProductId(productId);
    }
    
    public List<Order> getOrdersByStatus(String status) {
        log.info("Fetching orders with status: {}", status);
        return orderRepository.findByStatus(status);
    }
    
    public Order updateOrder(Long id, Order orderDetails) {
        log.info("Updating order with id: {}", id);
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Order not found with id: " + id));
        
        if (orderDetails.getProductId() != null) {
            if (!validateProductExists(orderDetails.getProductId())) {
                throw new RuntimeException("Product not found with id: " + orderDetails.getProductId());
            }
            order.setProductId(orderDetails.getProductId());
        }
        if (orderDetails.getQuantity() != null) {
            order.setQuantity(orderDetails.getQuantity());
        }
        if (orderDetails.getTotalPrice() != null) {
            order.setTotalPrice(orderDetails.getTotalPrice());
        }
        if (orderDetails.getStatus() != null) {
            order.setStatus(orderDetails.getStatus());
        }
        if (orderDetails.getCustomerName() != null) {
            order.setCustomerName(orderDetails.getCustomerName());
        }
        if (orderDetails.getCustomerEmail() != null) {
            order.setCustomerEmail(orderDetails.getCustomerEmail());
        }
        if (orderDetails.getShippingAddress() != null) {
            order.setShippingAddress(orderDetails.getShippingAddress());
        }
        
        return orderRepository.save(order);
    }
    
    public void deleteOrder(Long id) {
        log.info("Deleting order with id: {}", id);
        orderRepository.deleteById(id);
    }
    
    public boolean validateProductExists(Long productId) {
        log.info("Validating product existence for id: {}", productId);
        try {
            String url = productServiceUrl + "/products/validate/" + productId;
            ResponseEntity<Boolean> response = restTemplate.getForEntity(url, Boolean.class);
            return response.getBody() != null && response.getBody();
        } catch (Exception e) {
            log.error("Error calling Product Service: {}", e.getMessage());
            throw new RuntimeException("Unable to validate product. Product Service is unavailable.");
        }
    }
}
