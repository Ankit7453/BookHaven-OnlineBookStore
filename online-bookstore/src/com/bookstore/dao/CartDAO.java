package com.bookstore.dao;

import com.bookstore.model.CartItem;
import com.bookstore.util.DatabaseConnection;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Cart operations
 */
public class CartDAO {
    
    public List<CartItem> getCartItems(int userId) {
        List<CartItem> cartItems = new ArrayList<>();
        String sql = "SELECT c.*, b.title, b.author, b.price, b.cover_image, b.stock_quantity " +
                    "FROM cart c " +
                    "JOIN books b ON c.book_id = b.book_id " +
                    "WHERE c.user_id = ? AND b.is_active = TRUE " +
                    "ORDER BY c.added_at DESC";
        
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                CartItem item = mapResultSetToCartItem(rs);
                cartItems.add(item);
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting cart items: " + e.getMessage());
        }
        
        return cartItems;
    }
    
    public boolean addToCart(int userId, int bookId, int quantity) {
        // First check if item already exists in cart
        CartItem existingItem = getCartItem(userId, bookId);
        
        if (existingItem != null) {
            // Update quantity
            return updateCartItemQuantity(userId, bookId, existingItem.getQuantity() + quantity);
        } else {
            // Add new item
            String sql = "INSERT INTO cart (user_id, book_id, quantity) VALUES (?, ?, ?)";
            
            try (Connection conn = DatabaseConnection.getInstance().getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql)) {
                
                stmt.setInt(1, userId);
                stmt.setInt(2, bookId);
                stmt.setInt(3, quantity);
                
                int result = stmt.executeUpdate();
                return result > 0;
                
            } catch (SQLException e) {
                System.err.println("Error adding to cart: " + e.getMessage());
                return false;
            }
        }
    }
    
    public boolean updateCartItemQuantity(int userId, int bookId, int newQuantity) {
        if (newQuantity <= 0) {
            return removeFromCart(userId, bookId);
        }
        
        String sql = "UPDATE cart SET quantity = ? WHERE user_id = ? AND book_id = ?";
        
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, newQuantity);
            stmt.setInt(2, userId);
            stmt.setInt(3, bookId);
            
            int result = stmt.executeUpdate();
            return result > 0;
            
        } catch (SQLException e) {
            System.err.println("Error updating cart item quantity: " + e.getMessage());
            return false;
        }
    }
    
    public boolean removeFromCart(int userId, int bookId) {
        String sql = "DELETE FROM cart WHERE user_id = ? AND book_id = ?";
        
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            stmt.setInt(2, bookId);
            
            int result = stmt.executeUpdate();
            return result > 0;
            
        } catch (SQLException e) {
            System.err.println("Error removing from cart: " + e.getMessage());
            return false;
        }
    }
    
    public boolean clearCart(int userId) {
        String sql = "DELETE FROM cart WHERE user_id = ?";
        
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            
            int result = stmt.executeUpdate();
            return result >= 0; // Return true even if no items to delete
            
        } catch (SQLException e) {
            System.err.println("Error clearing cart: " + e.getMessage());
            return false;
        }
    }
    
    public CartItem getCartItem(int userId, int bookId) {
        String sql = "SELECT c.*, b.title, b.author, b.price, b.cover_image, b.stock_quantity " +
                    "FROM cart c " +
                    "JOIN books b ON c.book_id = b.book_id " +
                    "WHERE c.user_id = ? AND c.book_id = ? AND b.is_active = TRUE";
        
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            stmt.setInt(2, bookId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToCartItem(rs);
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting cart item: " + e.getMessage());
        }
        
        return null;
    }
    
    public int getCartItemCount(int userId) {
        String sql = "SELECT COALESCE(SUM(quantity), 0) FROM cart WHERE user_id = ?";
        
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting cart item count: " + e.getMessage());
        }
        
        return 0;
    }
    
    public BigDecimal getCartTotal(int userId) {
        String sql = "SELECT COALESCE(SUM(c.quantity * b.price), 0) " +
                    "FROM cart c " +
                    "JOIN books b ON c.book_id = b.book_id " +
                    "WHERE c.user_id = ? AND b.is_active = TRUE";
        
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getBigDecimal(1);
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting cart total: " + e.getMessage());
        }
        
        return BigDecimal.ZERO;
    }
    
    public boolean validateCartStock(int userId) {
        String sql = "SELECT c.quantity, b.stock_quantity, b.title " +
                    "FROM cart c " +
                    "JOIN books b ON c.book_id = b.book_id " +
                    "WHERE c.user_id = ? AND b.is_active = TRUE";
        
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                int cartQuantity = rs.getInt("quantity");
                int stockQuantity = rs.getInt("stock_quantity");
                
                if (cartQuantity > stockQuantity) {
                    return false; // Insufficient stock
                }
            }
            
            return true;
            
        } catch (SQLException e) {
            System.err.println("Error validating cart stock: " + e.getMessage());
            return false;
        }
    }
    
    private CartItem mapResultSetToCartItem(ResultSet rs) throws SQLException {
        CartItem item = new CartItem();
        item.setCartId(rs.getInt("cart_id"));
        item.setUserId(rs.getInt("user_id"));
        item.setBookId(rs.getInt("book_id"));
        item.setBookTitle(rs.getString("title"));
        item.setBookAuthor(rs.getString("author"));
        item.setBookPrice(rs.getBigDecimal("price"));
        item.setCoverImage(rs.getString("cover_image"));
        item.setQuantity(rs.getInt("quantity"));
        item.setAddedAt(rs.getTimestamp("added_at"));
        return item;
    }
}
