package com.ecommerce.frontend.service;

import com.ecommerce.frontend.model.OrderDTO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.List;

@Service
@Slf4j
public class OrderService {
    
    @Autowired
    private RestTemplate restTemplate;
    
    @Value("${order.service.url}")
    private String orderServiceUrl;
    
    public List<OrderDTO> getAllOrders() {
        log.info("Fetching all orders from Order Service");
        try {
            String url = orderServiceUrl + "/orders";
            ResponseEntity<List<OrderDTO>> response = restTemplate.exchange(
                    url,
                    HttpMethod.GET,
                    null,
                    new ParameterizedTypeReference<List<OrderDTO>>() {}
            );
            return response.getBody() != null ? response.getBody() : new ArrayList<>();
        } catch (Exception e) {
            log.error("Error fetching orders: {}", e.getMessage());
            return new ArrayList<>();
        }
    }
    
    public OrderDTO getOrderById(Long orderId) {
        log.info("Fetching order by id: {}", orderId);
        try {
            String url = orderServiceUrl + "/orders/" + orderId;
            ResponseEntity<OrderDTO> response = restTemplate.getForEntity(url, OrderDTO.class);
            return response.getBody();
        } catch (Exception e) {
            log.error("Error fetching order by id: {}", e.getMessage());
            return null;
        }
    }
    
    public List<OrderDTO> getOrdersByCustomer(String customerName) {
        log.info("Fetching orders for customer: {}", customerName);
        try {
            String url = orderServiceUrl + "/orders/customer/" + customerName;
            ResponseEntity<List<OrderDTO>> response = restTemplate.exchange(
                    url,
                    HttpMethod.GET,
                    null,
                    new ParameterizedTypeReference<List<OrderDTO>>() {}
            );
            return response.getBody() != null ? response.getBody() : new ArrayList<>();
        } catch (Exception e) {
            log.error("Error fetching orders by customer: {}", e.getMessage());
            return new ArrayList<>();
        }
    }
    
    public OrderDTO createOrder(OrderDTO orderDTO) {
        log.info("Creating order for product id: {}", orderDTO.getProductId());
        try {
            String url = orderServiceUrl + "/orders";
            ResponseEntity<OrderDTO> response = restTemplate.postForEntity(url, orderDTO, OrderDTO.class);
            return response.getBody();
        } catch (Exception e) {
            log.error("Error creating order: {}", e.getMessage());
            return null;
        }
    }
}
