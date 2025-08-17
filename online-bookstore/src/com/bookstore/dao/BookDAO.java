package com.bookstore.dao;

import com.bookstore.model.Book;
import com.bookstore.util.DatabaseConnection;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Book operations
 */
public class BookDAO {
    
    public List<Book> getAllBooks() {
        return getAllBooks(0, 0); // No pagination
    }
    
    public List<Book> getAllBooks(int offset, int limit) {
        List<Book> books = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT b.*, c.category_name FROM books b ");
        sql.append("LEFT JOIN categories c ON b.category_id = c.category_id ");
        sql.append("WHERE b.is_active = TRUE ");
        sql.append("ORDER BY b.created_at DESC");
        
        if (limit > 0) {
            sql.append(" LIMIT ? OFFSET ?");
        }
        
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            if (limit > 0) {
                stmt.setInt(1, limit);
                stmt.setInt(2, offset);
            }
            
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                books.add(mapResultSetToBook(rs));
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting all books: " + e.getMessage());
        }
        
        return books;
    }
    
    public List<Book> searchBooks(String query, Integer categoryId, BigDecimal minPrice, 
                                 BigDecimal maxPrice, int offset, int limit) {
        List<Book> books = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT b.*, c.category_name FROM books b ");
        sql.append("LEFT JOIN categories c ON b.category_id = c.category_id ");
        sql.append("WHERE b.is_active = TRUE ");
        
        List<Object> parameters = new ArrayList<>();
        
        if (query != null && !query.trim().isEmpty()) {
            sql.append("AND (b.title LIKE ? OR b.author LIKE ? OR b.description LIKE ?) ");
            String searchPattern = "%" + query.trim() + "%";
            parameters.add(searchPattern);
            parameters.add(searchPattern);
            parameters.add(searchPattern);
        }
        
        if (categoryId != null && categoryId > 0) {
            sql.append("AND b.category_id = ? ");
            parameters.add(categoryId);
        }
        
        if (minPrice != null && minPrice.compareTo(BigDecimal.ZERO) > 0) {
            sql.append("AND b.price >= ? ");
            parameters.add(minPrice);
        }
        
        if (maxPrice != null && maxPrice.compareTo(BigDecimal.ZERO) > 0) {
            sql.append("AND b.price <= ? ");
            parameters.add(maxPrice);
        }
        
        sql.append("ORDER BY b.rating DESC, b.created_at DESC ");
        
        if (limit > 0) {
            sql.append("LIMIT ? OFFSET ?");
            parameters.add(limit);
            parameters.add(offset);
        }
        
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < parameters.size(); i++) {
                stmt.setObject(i + 1, parameters.get(i));
            }
            
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                books.add(mapResultSetToBook(rs));
            }
            
        } catch (SQLException e) {
            System.err.println("Error searching books: " + e.getMessage());
        }
        
        return books;
    }
    
    public int getSearchResultCount(String query, Integer categoryId, BigDecimal minPrice, BigDecimal maxPrice) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM books b WHERE b.is_active = TRUE ");
        
        List<Object> parameters = new ArrayList<>();
        
        if (query != null && !query.trim().isEmpty()) {
            sql.append("AND (b.title LIKE ? OR b.author LIKE ? OR b.description LIKE ?) ");
            String searchPattern = "%" + query.trim() + "%";
            parameters.add(searchPattern);
            parameters.add(searchPattern);
            parameters.add(searchPattern);
        }
        
        if (categoryId != null && categoryId > 0) {
            sql.append("AND b.category_id = ? ");
            parameters.add(categoryId);
        }
        
        if (minPrice != null && minPrice.compareTo(BigDecimal.ZERO) > 0) {
            sql.append("AND b.price >= ? ");
            parameters.add(minPrice);
        }
        
        if (maxPrice != null && maxPrice.compareTo(BigDecimal.ZERO) > 0) {
            sql.append("AND b.price <= ? ");
            parameters.add(maxPrice);
        }
        
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < parameters.size(); i++) {
                stmt.setObject(i + 1, parameters.get(i));
            }
            
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting search result count: " + e.getMessage());
        }
        
        return 0;
    }
    
    public Book getBookById(int bookId) {
        String sql = "SELECT b.*, c.category_name FROM books b " +
                    "LEFT JOIN categories c ON b.category_id = c.category_id " +
                    "WHERE b.book_id = ? AND b.is_active = TRUE";
        
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, bookId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToBook(rs);
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting book by ID: " + e.getMessage());
        }
        
        return null;
    }
    
    public List<Book> getFeaturedBooks(int limit) {
        String sql = "SELECT b.*, c.category_name FROM books b " +
                    "LEFT JOIN categories c ON b.category_id = c.category_id " +
                    "WHERE b.is_active = TRUE AND b.is_featured = TRUE " +
                    "ORDER BY b.rating DESC, b.created_at DESC LIMIT ?";
        
        List<Book> books = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, limit);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                books.add(mapResultSetToBook(rs));
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting featured books: " + e.getMessage());
        }
        
        return books;
    }
    
    public List<Book> getBestsellerBooks(int limit) {
        String sql = "SELECT b.*, c.category_name FROM books b " +
                    "LEFT JOIN categories c ON b.category_id = c.category_id " +
                    "WHERE b.is_active = TRUE AND b.is_bestseller = TRUE " +
                    "ORDER BY b.rating DESC, b.created_at DESC LIMIT ?";
        
        List<Book> books = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, limit);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                books.add(mapResultSetToBook(rs));
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting bestseller books: " + e.getMessage());
        }
        
        return books;
    }
    
    public List<Book> getBooksByCategory(int categoryId, int limit) {
        String sql = "SELECT b.*, c.category_name FROM books b " +
                    "LEFT JOIN categories c ON b.category_id = c.category_id " +
                    "WHERE b.is_active = TRUE AND b.category_id = ? " +
                    "ORDER BY b.rating DESC, b.created_at DESC";
        
        if (limit > 0) {
            sql += " LIMIT ?";
        }
        
        List<Book> books = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, categoryId);
            if (limit > 0) {
                stmt.setInt(2, limit);
            }
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                books.add(mapResultSetToBook(rs));
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting books by category: " + e.getMessage());
        }
        
        return books;
    }
    
    public boolean addBook(Book book) {
        String sql = "INSERT INTO books (title, author, isbn, description, price, stock_quantity, " +
                    "category_id, cover_image, publisher, publication_date, pages, language, " +
                    "is_featured, is_bestseller) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, book.getTitle());
            stmt.setString(2, book.getAuthor());
            stmt.setString(3, book.getIsbn());
            stmt.setString(4, book.getDescription());
            stmt.setBigDecimal(5, book.getPrice());
            stmt.setInt(6, book.getStockQuantity());
            stmt.setInt(7, book.getCategoryId());
            stmt.setString(8, book.getCoverImage());
            stmt.setString(9, book.getPublisher());
            stmt.setDate(10, book.getPublicationDate());
            stmt.setInt(11, book.getPages());
            stmt.setString(12, book.getLanguage());
            stmt.setBoolean(13, book.isFeatured());
            stmt.setBoolean(14, book.isBestseller());
            
            int result = stmt.executeUpdate();
            
            if (result > 0) {
                ResultSet generatedKeys = stmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    book.setBookId(generatedKeys.getInt(1));
                }
                return true;
            }
            
        } catch (SQLException e) {
            System.err.println("Error adding book: " + e.getMessage());
        }
        
        return false;
    }
    
    public boolean updateBook(Book book) {
        String sql = "UPDATE books SET title = ?, author = ?, isbn = ?, description = ?, " +
                    "price = ?, stock_quantity = ?, category_id = ?, cover_image = ?, " +
                    "publisher = ?, publication_date = ?, pages = ?, language = ?, " +
                    "is_featured = ?, is_bestseller = ?, updated_at = CURRENT_TIMESTAMP " +
                    "WHERE book_id = ?";
        
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, book.getTitle());
            stmt.setString(2, book.getAuthor());
            stmt.setString(3, book.getIsbn());
            stmt.setString(4, book.getDescription());
            stmt.setBigDecimal(5, book.getPrice());
            stmt.setInt(6, book.getStockQuantity());
            stmt.setInt(7, book.getCategoryId());
            stmt.setString(8, book.getCoverImage());
            stmt.setString(9, book.getPublisher());
            stmt.setDate(10, book.getPublicationDate());
            stmt.setInt(11, book.getPages());
            stmt.setString(12, book.getLanguage());
            stmt.setBoolean(13, book.isFeatured());
            stmt.setBoolean(14, book.isBestseller());
            stmt.setInt(15, book.getBookId());
            
            int result = stmt.executeUpdate();
            return result > 0;
            
        } catch (SQLException e) {
            System.err.println("Error updating book: " + e.getMessage());
            return false;
        }
    }
    
    public boolean deleteBook(int bookId) {
        String sql = "UPDATE books SET is_active = FALSE WHERE book_id = ?";
        
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, bookId);
            int result = stmt.executeUpdate();
            return result > 0;
            
        } catch (SQLException e) {
            System.err.println("Error deleting book: " + e.getMessage());
            return false;
        }
    }
    
    public boolean updateStock(int bookId, int newStock) {
        String sql = "UPDATE books SET stock_quantity = ?, updated_at = CURRENT_TIMESTAMP WHERE book_id = ?";
        
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, newStock);
            stmt.setInt(2, bookId);
            
            int result = stmt.executeUpdate();
            return result > 0;
            
        } catch (SQLException e) {
            System.err.println("Error updating stock: " + e.getMessage());
            return false;
        }
    }
    
    public int getTotalBooksCount() {
        String sql = "SELECT COUNT(*) FROM books WHERE is_active = TRUE";
        
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt(1);
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting total books count: " + e.getMessage());
        }
        
        return 0;
    }
    
    private Book mapResultSetToBook(ResultSet rs) throws SQLException {
        Book book = new Book();
        book.setBookId(rs.getInt("book_id"));
        book.setTitle(rs.getString("title"));
        book.setAuthor(rs.getString("author"));
        book.setIsbn(rs.getString("isbn"));
        book.setDescription(rs.getString("description"));
        book.setPrice(rs.getBigDecimal("price"));
        book.setStockQuantity(rs.getInt("stock_quantity"));
        book.setCategoryId(rs.getInt("category_id"));
        book.setCategoryName(rs.getString("category_name"));
        book.setCoverImage(rs.getString("cover_image"));
        book.setPublisher(rs.getString("publisher"));
        book.setPublicationDate(rs.getDate("publication_date"));
        book.setPages(rs.getInt("pages"));
        book.setLanguage(rs.getString("language"));
        book.setRating(rs.getBigDecimal("rating"));
        book.setTotalReviews(rs.getInt("total_reviews"));
        book.setFeatured(rs.getBoolean("is_featured"));
        book.setBestseller(rs.getBoolean("is_bestseller"));
        book.setCreatedAt(rs.getTimestamp("created_at"));
        book.setUpdatedAt(rs.getTimestamp("updated_at"));
        book.setActive(rs.getBoolean("is_active"));
        return book;
    }
}
