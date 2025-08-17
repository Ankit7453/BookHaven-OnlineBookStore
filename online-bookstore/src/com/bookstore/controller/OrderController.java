package com.bookstore.controller;

import com.bookstore.dao.CartDAO;
import com.bookstore.dao.OrderDAO;
import com.bookstore.model.CartItem;
import com.bookstore.model.Order;
import com.bookstore.model.OrderItem;
import com.bookstore.model.User;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.List;

/**
 * Servlet controller for order operations
 */
public class OrderController extends HttpServlet {
    private OrderDAO orderDAO;
    private CartDAO cartDAO;
    
    @Override
    public void init() throws ServletException {
        orderDAO = new OrderDAO();
        cartDAO = new CartDAO();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = getAction(request);
        
        switch (action) {
            case "place":
                placeOrder(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
                break;
        }
    }
    
    private String getAction(HttpServletRequest request) {
        String pathInfo = request.getPathInfo();
        return (pathInfo != null && pathInfo.length() > 1) ? pathInfo.substring(1) : "";
    }
    
    private void placeOrder(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            out.print("{\"success\":false,\"message\":\"Please login to place order\"}");
            return;
        }
        
        try {
            User user = (User) session.getAttribute("user");
            
            // Get cart items
            List<CartItem> cartItems = cartDAO.getCartItems(user.getUserId());
            if (cartItems == null || cartItems.isEmpty()) {
                out.print("{\"success\":false,\"message\":\"Cart is empty\"}");
                return;
            }
            
            // Calculate total
            BigDecimal totalAmount = cartDAO.getCartTotal(user.getUserId());
            
            // Create order
            Order order = new Order();
            order.setUserId(user.getUserId());
            order.setTotalAmount(totalAmount);
            order.setOrderStatus("confirmed");
            order.setPaymentStatus("paid");
            order.setShippingAddress(user.getAddress() != null ? user.getAddress() : "Default Address");
            order.setShippingCity("Default City");
            order.setShippingState("Default State");
            order.setShippingZip("000000");
            order.setNotes("Order placed through web application");
            
            // Place order and get order ID
            int orderId = orderDAO.createOrder(order);
            
            if (orderId > 0) {
                // Add order items
                boolean allItemsAdded = true;
                for (CartItem cartItem : cartItems) {
                    OrderItem orderItem = new OrderItem();
                    orderItem.setOrderId(orderId);
                    orderItem.setBookId(cartItem.getBookId());
                    orderItem.setQuantity(cartItem.getQuantity());
                    orderItem.setUnitPrice(cartItem.getBookPrice());
                    orderItem.setTotalPrice(cartItem.getBookPrice().multiply(BigDecimal.valueOf(cartItem.getQuantity())));
                    
                    if (!orderDAO.addOrderItem(orderItem)) {
                        allItemsAdded = false;
                        break;
                    }
                }
                
                if (allItemsAdded) {
                    // Clear cart after successful order
                    cartDAO.clearCart(user.getUserId());
                    out.print("{\"success\":true,\"message\":\"Order placed successfully\",\"orderId\":" + orderId + "}");
                } else {
                    out.print("{\"success\":false,\"message\":\"Failed to add some order items\"}");
                }
            } else {
                out.print("{\"success\":false,\"message\":\"Failed to place order\"}");
            }
            
        } catch (Exception e) {
            out.print("{\"success\":false,\"message\":\"An error occurred: " + e.getMessage() + "\"}");
        }
    }
}
