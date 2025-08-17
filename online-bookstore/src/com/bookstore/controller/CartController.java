package com.bookstore.controller;

import com.bookstore.dao.CartDAO;
import com.bookstore.dao.BookDAO;
import com.bookstore.model.CartItem;
import com.bookstore.model.Book;
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
 * Servlet controller for shopping cart operations
 */
public class CartController extends HttpServlet {
    private CartDAO cartDAO;
    private BookDAO bookDAO;
    
    @Override
    public void init() throws ServletException {
        cartDAO = new CartDAO();
        bookDAO = new BookDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = getAction(request);
        
        switch (action) {
            case "":
            case "view":
                viewCart(request, response);
                break;
            case "count":
                getCartCount(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/cart/view");
                break;
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = getAction(request);
        
        switch (action) {
            case "add":
                addToCart(request, response);
                break;
            case "update":
                updateCartItem(request, response);
                break;
            case "remove":
                removeFromCart(request, response);
                break;
            case "clear":
                clearCart(request, response);
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
    
    private void viewCart(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        List<CartItem> cartItems = cartDAO.getCartItems(user.getUserId());
        BigDecimal cartTotal = cartDAO.getCartTotal(user.getUserId());
        
        request.setAttribute("cartItems", cartItems);
        request.setAttribute("cartTotal", cartTotal);
        request.setAttribute("pageTitle", "Shopping Cart");
        
        request.getRequestDispatcher("/cart.jsp").forward(request, response);
    }
    
    private void addToCart(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
    
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            out.print("{\"success\":false,\"message\":\"Please login to add items to cart\"}");
            return;
        }
        
        try {
            User user = (User) session.getAttribute("user");
            int bookId = Integer.parseInt(request.getParameter("bookId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            
            if (quantity <= 0) {
                out.print("{\"success\":false,\"message\":\"Invalid quantity\"}");
                return;
            }
            
            Book book = bookDAO.getBookById(bookId);
            if (book == null) {
                out.print("{\"success\":false,\"message\":\"Book not found\"}");
                return;
            }
            
            CartItem existingItem = cartDAO.getCartItem(user.getUserId(), bookId);
            int currentCartQuantity = existingItem != null ? existingItem.getQuantity() : 0;
            int totalQuantity = currentCartQuantity + quantity;
            
            if (totalQuantity > book.getStockQuantity()) {
                out.print("{\"success\":false,\"message\":\"Insufficient stock. Available: " + book.getStockQuantity() + "\"}");
                return;
            }
            
            boolean success = cartDAO.addToCart(user.getUserId(), bookId, quantity);
            
            if (success) {
                int cartCount = cartDAO.getCartItemCount(user.getUserId());
                out.print("{\"success\":true,\"message\":\"Item added to cart successfully\",\"cartCount\":" + cartCount + "}");
            } else {
                out.print("{\"success\":false,\"message\":\"Failed to add item to cart\"}");
            }
            
        } catch (NumberFormatException e) {
            out.print("{\"success\":false,\"message\":\"Invalid parameters\"}");
        } catch (Exception e) {
            out.print("{\"success\":false,\"message\":\"An error occurred: " + e.getMessage() + "\"}");
        }
    }
    
    private void updateCartItem(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
    
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            out.print("{\"success\":false,\"message\":\"Please login\"}");
            return;
        }
        
        try {
            User user = (User) session.getAttribute("user");
            String bookIdParam = request.getParameter("bookId");
            String quantityParam = request.getParameter("quantity");
            
            if (bookIdParam == null || quantityParam == null) {
                out.print("{\"success\":false,\"message\":\"Missing required parameters\"}");
                return;
            }
            
            int bookId = Integer.parseInt(bookIdParam);
            int quantity = Integer.parseInt(quantityParam);
            
            if (quantity < 0) {
                out.print("{\"success\":false,\"message\":\"Invalid quantity\"}");
                return;
            }
            
            if (quantity == 0) {
                boolean success = cartDAO.removeFromCart(user.getUserId(), bookId);
                if (success) {
                    BigDecimal cartTotal = cartDAO.getCartTotal(user.getUserId());
                    int cartCount = cartDAO.getCartItemCount(user.getUserId());
                    out.print("{\"success\":true,\"message\":\"Item removed from cart\",\"cartTotal\":\"" + cartTotal.toString() + "\",\"cartCount\":" + cartCount + "}");
                } else {
                    out.print("{\"success\":false,\"message\":\"Failed to remove item from cart\"}");
                }
                return;
            }
            
            Book book = bookDAO.getBookById(bookId);
            if (book == null) {
                out.print("{\"success\":false,\"message\":\"Book not found\"}");
                return;
            }
            
            if (quantity > book.getStockQuantity()) {
                out.print("{\"success\":false,\"message\":\"Insufficient stock. Available: " + book.getStockQuantity() + "\"}");
                return;
            }
            
            CartItem existingItem = cartDAO.getCartItem(user.getUserId(), bookId);
            boolean success;
            
            if (existingItem == null) {
                success = cartDAO.addToCart(user.getUserId(), bookId, quantity);
            } else {
                success = cartDAO.updateCartItemQuantity(user.getUserId(), bookId, quantity);
            }
            
            if (success) {
                BigDecimal cartTotal = cartDAO.getCartTotal(user.getUserId());
                int cartCount = cartDAO.getCartItemCount(user.getUserId());
                
                out.print("{\"success\":true,\"message\":\"Cart updated successfully\",\"cartTotal\":\"" + cartTotal.toString() + "\",\"cartCount\":" + cartCount + "}");
            } else {
                out.print("{\"success\":false,\"message\":\"Failed to update cart - database operation failed\"}");
            }
            
        } catch (NumberFormatException e) {
            out.print("{\"success\":false,\"message\":\"Invalid parameters - not a number\"}");
        } catch (Exception e) {
            out.print("{\"success\":false,\"message\":\"An error occurred: " + e.getMessage() + "\"}");
        }
    }
    
    private void removeFromCart(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            out.print("{\"success\":false,\"message\":\"Please login\"}");
            return;
        }
        
        try {
            User user = (User) session.getAttribute("user");
            int bookId = Integer.parseInt(request.getParameter("bookId"));
            
            boolean success = cartDAO.removeFromCart(user.getUserId(), bookId);
            
            if (success) {
                BigDecimal cartTotal = cartDAO.getCartTotal(user.getUserId());
                int cartCount = cartDAO.getCartItemCount(user.getUserId());
                
                out.print("{\"success\":true,\"message\":\"Item removed from cart\",\"cartTotal\":\"" + cartTotal.toString() + "\",\"cartCount\":" + cartCount + "}");
            } else {
                out.print("{\"success\":false,\"message\":\"Failed to remove item from cart\"}");
            }
            
        } catch (NumberFormatException e) {
            out.print("{\"success\":false,\"message\":\"Invalid parameters\"}");
        } catch (Exception e) {
            out.print("{\"success\":false,\"message\":\"An error occurred: " + e.getMessage() + "\"}");
        }
    }
    
    private void clearCart(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            out.print("{\"success\":false,\"message\":\"Please login\"}");
            return;
        }
        
        try {
            User user = (User) session.getAttribute("user");
            boolean success = cartDAO.clearCart(user.getUserId());
            
            if (success) {
                out.print("{\"success\":true,\"message\":\"Cart cleared successfully\",\"cartTotal\":\"0.00\",\"cartCount\":0}");
            } else {
                out.print("{\"success\":false,\"message\":\"Failed to clear cart\"}");
            }
            
        } catch (Exception e) {
            out.print("{\"success\":false,\"message\":\"An error occurred: " + e.getMessage() + "\"}");
        }
    }
    
    private void getCartCount(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            out.print("{\"cartCount\":0}");
        } else {
            User user = (User) session.getAttribute("user");
            int cartCount = cartDAO.getCartItemCount(user.getUserId());
            out.print("{\"cartCount\":" + cartCount + "}");
        }
    }
}
