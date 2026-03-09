package com.ecommerce.frontend.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class OrderDTO {
    private Long id;
    private Long productId;
    private Integer quantity;
    private Double totalPrice;
    private String status;
    private String customerName;
    private String customerEmail;
    private String shippingAddress;
}
