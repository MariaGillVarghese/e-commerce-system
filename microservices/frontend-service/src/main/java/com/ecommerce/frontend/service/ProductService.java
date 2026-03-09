package com.ecommerce.frontend.service;

import com.ecommerce.frontend.model.ProductDTO;
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
public class ProductService {
    
    @Autowired
    private RestTemplate restTemplate;
    
    @Value("${product.service.url}")
    private String productServiceUrl;
    
    public List<ProductDTO> getAllProducts() {
        log.info("Fetching all products from Product Service");
        try {
            String url = productServiceUrl + "/products";
            ResponseEntity<List<ProductDTO>> response = restTemplate.exchange(
                    url,
                    HttpMethod.GET,
                    null,
                    new ParameterizedTypeReference<List<ProductDTO>>() {}
            );
            return response.getBody() != null ? response.getBody() : new ArrayList<>();
        } catch (Exception e) {
            log.error("Error fetching products: {}", e.getMessage());
            return new ArrayList<>();
        }
    }
    
    public ProductDTO getProductById(Long productId) {
        log.info("Fetching product by id: {}", productId);
        try {
            String url = productServiceUrl + "/products/" + productId;
            ResponseEntity<ProductDTO> response = restTemplate.getForEntity(url, ProductDTO.class);
            return response.getBody();
        } catch (Exception e) {
            log.error("Error fetching product by id: {}", e.getMessage());
            return null;
        }
    }
    
    public ProductDTO createProduct(ProductDTO productDTO) {
        log.info("Creating product: {}", productDTO.getName());
        try {
            String url = productServiceUrl + "/products";
            ResponseEntity<ProductDTO> response = restTemplate.postForEntity(url, productDTO, ProductDTO.class);
            return response.getBody();
        } catch (Exception e) {
            log.error("Error creating product: {}", e.getMessage());
            return null;
        }
    }
}
