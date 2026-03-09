package com.ecommerce.frontend.controller;

import com.ecommerce.frontend.model.OrderDTO;
import com.ecommerce.frontend.model.ProductDTO;
import com.ecommerce.frontend.service.OrderService;
import com.ecommerce.frontend.service.ProductService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequestMapping({"/", "/home"})
@Slf4j
public class FrontendController {
    
    @Autowired
    private ProductService productService;
    
    @Autowired
    private OrderService orderService;
    
    @GetMapping
    public String home(Model model) {
        log.info("Loading home page");
        return "index";
    }
    
    // ===================== PRODUCT PAGES =====================
    
    @GetMapping("/products")
    public String listProducts(Model model) {
        log.info("Loading products page");
        List<ProductDTO> products = productService.getAllProducts();
        model.addAttribute("products", products);
        return "products/list";
    }
    
    @GetMapping("/products/view/{id}")
    public String viewProduct(@PathVariable Long id, Model model) {
        log.info("Loading product details page for id: {}", id);
        ProductDTO product = productService.getProductById(id);
        if (product != null) {
            model.addAttribute("product", product);
            return "products/view";
        }
        return "redirect:/products?error=Product not found";
    }
    
    @GetMapping("/products/create")
    public String createProductForm(Model model) {
        log.info("Loading create product form");
        model.addAttribute("product", new ProductDTO());
        return "products/create";
    }
    
    @PostMapping("/products/create")
    public String createProduct(@ModelAttribute ProductDTO product) {
        log.info("Creating product: {}", product.getName());
        ProductDTO createdProduct = productService.createProduct(product);
        if (createdProduct != null) {
            return "redirect:/products?success=Product created successfully";
        }
        return "redirect:/products/create?error=Failed to create product";
    }
    
    // ===================== ORDER PAGES =====================
    
    @GetMapping("/orders")
    public String listOrders(Model model) {
        log.info("Loading orders page");
        List<OrderDTO> orders = orderService.getAllOrders();
        model.addAttribute("orders", orders);
        return "orders/list";
    }
    
    @GetMapping("/orders/view/{id}")
    public String viewOrder(@PathVariable Long id, Model model) {
        log.info("Loading order details page for id: {}", id);
        OrderDTO order = orderService.getOrderById(id);
        if (order != null) {
            model.addAttribute("order", order);
            ProductDTO product = productService.getProductById(order.getProductId());
            model.addAttribute("product", product);
            return "orders/view";
        }
        return "redirect:/orders?error=Order not found";
    }
    
    @GetMapping("/orders/create")
    public String createOrderForm(Model model) {
        log.info("Loading create order form");
        List<ProductDTO> products = productService.getAllProducts();
        model.addAttribute("products", products);
        model.addAttribute("order", new OrderDTO());
        return "orders/create";
    }
    
    @PostMapping("/orders/create")
    public String createOrder(@ModelAttribute OrderDTO order) {
        log.info("Creating order for product id: {}", order.getProductId());
        OrderDTO createdOrder = orderService.createOrder(order);
        if (createdOrder != null) {
            return "redirect:/orders?success=Order created successfully";
        }
        return "redirect:/orders/create?error=Failed to create order";
    }
    
    @GetMapping("/orders/customer")
    public String searchOrdersByCustomer(@RequestParam(value = "name", required = false) String customerName, Model model) {
        log.info("Searching orders for customer: {}", customerName);
        if (customerName != null && !customerName.isEmpty()) {
            List<OrderDTO> orders = orderService.getOrdersByCustomer(customerName);
            model.addAttribute("orders", orders);
            model.addAttribute("customerName", customerName);
        }
        return "orders/search";
    }
}
