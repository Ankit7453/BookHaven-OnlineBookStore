package com.bookstore.controller;

import com.bookstore.dao.AdminDAO;
import com.bookstore.dao.BookDAO;
import com.bookstore.dao.CategoryDAO;
import com.bookstore.dao.OrderDAO;
import com.bookstore.dao.UserDAO;
import com.bookstore.model.Admin;
import com.bookstore.model.Book;
import com.bookstore.model.Category;
import com.bookstore.model.Order;
import com.bookstore.model.User;
import com.bookstore.util.PasswordUtil;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;

/**
 * Servlet controller for admin operations
 */
public class AdminController extends HttpServlet {
    private AdminDAO adminDAO;
    private BookDAO bookDAO;
    private CategoryDAO categoryDAO;
    private OrderDAO orderDAO;
    private UserDAO userDAO;
    
    @Override
    public void init() throws ServletException {
        adminDAO = new AdminDAO();
        bookDAO = new BookDAO();
        categoryDAO = new CategoryDAO();
        orderDAO = new OrderDAO();
        userDAO = new UserDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = getAction(request);
        
        if ("login".equals(action)) {
            showLoginPage(request, response);
            return;
        }
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("admin") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }
        
        switch (action) {
            case "":
            case "dashboard":
                showDashboard(request, response);
                break;
            case "logout":
                logout(request, response);
                break;
            case "books":
                manageBooks(request, response);
                break;
            case "add-book":
                showAddBookForm(request, response);
                break;
            case "edit-book":
                showEditBookForm(request, response);
                break;
            case "categories":
                manageCategories(request, response);
                break;
            case "orders":
                manageOrders(request, response);
                break;
            case "order-details":
                showOrderDetails(request, response);
                break;
            case "users":
                manageUsers(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/login");
                break;
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = getAction(request);
        
        if ("login".equals(action)) {
            processLogin(request, response);
            return;
        }
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("admin") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }
        
        switch (action) {
            case "add-book":
                processAddBook(request, response);
                break;
            case "edit-book":
                processEditBook(request, response);
                break;
            case "delete-book":
                processDeleteBook(request, response);
                break;
            case "add-category":
                processAddCategory(request, response);
                break;
            case "edit-category":
                processEditCategory(request, response);
                break;
            case "delete-category":
                processDeleteCategory(request, response);
                break;
            case "update-order-status":
                processUpdateOrderStatus(request, response);
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
    
    private void showLoginPage(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("/admin/login.jsp").forward(request, response);
    }
    
    private void processLogin(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        if (username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("error", "Username and password are required");
            request.getRequestDispatcher("/admin/login.jsp").forward(request, response);
            return;
        }
        
        String trimmedUsername = username.trim().toLowerCase();
        String trimmedPassword = password.trim();
        
        boolean validCredentials = "admin123".equals(trimmedPassword) && 
                                  ("admin".equals(trimmedUsername) || "admin@bookstore.com".equals(trimmedUsername));
        
        if (validCredentials) {
            // Create admin session
            Admin admin = new Admin();
            admin.setAdminId(1);
            admin.setUsername("admin");
            admin.setFullName("System Administrator");
            admin.setEmail("admin@bookstore.com");
            
            HttpSession session = request.getSession(true);
            session.setAttribute("admin", admin);
            session.setAttribute("adminId", admin.getAdminId());
            session.setAttribute("adminName", admin.getFullName());
            session.setMaxInactiveInterval(3600); // 1 hour
            
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        } else {
            request.setAttribute("error", "Invalid credentials. Use 'admin' or 'admin@bookstore.com' with password 'admin123'");
            request.setAttribute("username", username);
            request.getRequestDispatcher("/admin/login.jsp").forward(request, response);
        }
    }
    
    private void showDashboard(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get dashboard statistics with error handling
        int totalBooks = 0;
        int totalUsers = 0;
        int totalOrders = 0;
        BigDecimal totalRevenue = BigDecimal.ZERO;
        List<Order> dashboardOrders = null;
        
        try {
            totalBooks = bookDAO.getTotalBooksCount();
        } catch (Exception e) {
            System.out.println("Error getting book count: " + e.getMessage());
        }
        
        try {
            List<User> users = userDAO.getAllUsers();
            totalUsers = users != null ? users.size() : 0;
        } catch (Exception e) {
            System.out.println("Error getting user count: " + e.getMessage());
        }
        
        try {
            List<Order> recentOrders = orderDAO.getAllOrders();
            if (recentOrders != null) {
                totalOrders = recentOrders.size();
                
                // Calculate total revenue
                for (Order order : recentOrders) {
                    if ("paid".equals(order.getPaymentStatus())) {
                        totalRevenue = totalRevenue.add(order.getTotalAmount());
                    }
                }
                
                // Get recent orders (last 10)
                dashboardOrders = recentOrders.size() > 10 ? 
                    recentOrders.subList(0, 10) : recentOrders;
            }
        } catch (Exception e) {
            System.out.println("Error getting orders: " + e.getMessage());
        }
        
        request.setAttribute("totalBooks", totalBooks);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("totalRevenue", totalRevenue);
        request.setAttribute("recentOrders", dashboardOrders);
        request.setAttribute("pageTitle", "Admin Dashboard");
        
        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
        
    }
    
    private void manageBooks(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        List<Book> books = bookDAO.getAllBooks();
        List<Category> categories = categoryDAO.getAllCategories();
        
        request.setAttribute("books", books);
        request.setAttribute("categories", categories);
        request.setAttribute("pageTitle", "Manage Books");
        
        request.getRequestDispatcher("/admin/books.jsp").forward(request, response);
    }
    
    private void showAddBookForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        List<Category> categories = categoryDAO.getAllCategories();
        request.setAttribute("categories", categories);
        request.setAttribute("pageTitle", "Add New Book");
        
        request.getRequestDispatcher("/admin/add-book.jsp").forward(request, response);
    }
    
    private void showEditBookForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String bookIdParam = request.getParameter("id");
        
        if (bookIdParam == null || bookIdParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/books");
            return;
        }
        
        try {
            int bookId = Integer.parseInt(bookIdParam);
            Book book = bookDAO.getBookById(bookId);
            
            if (book == null) {
                response.sendRedirect(request.getContextPath() + "/admin/books");
                return;
            }
            
            List<Category> categories = categoryDAO.getAllCategories();
            request.setAttribute("book", book);
            request.setAttribute("categories", categories);
            request.setAttribute("pageTitle", "Edit Book");
            
            request.getRequestDispatcher("/admin/edit-book.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/books");
        }
    }
    
    private void processAddBook(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            Book book = createBookFromRequest(request);
            
            if (bookDAO.addBook(book)) {
                request.setAttribute("success", "Book added successfully!");
            } else {
                request.setAttribute("error", "Failed to add book. Please try again.");
            }
            
        } catch (Exception e) {
            request.setAttribute("error", "Error adding book: " + e.getMessage());
        }
        
        List<Category> categories = categoryDAO.getAllCategories();
        request.setAttribute("categories", categories);
        request.setAttribute("pageTitle", "Add New Book");
        
        request.getRequestDispatcher("/admin/add-book.jsp").forward(request, response);
    }
    
    private void processEditBook(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            int bookId = Integer.parseInt(request.getParameter("bookId"));
            Book book = createBookFromRequest(request);
            book.setBookId(bookId);
            
            if (bookDAO.updateBook(book)) {
                request.setAttribute("success", "Book updated successfully!");
            } else {
                request.setAttribute("error", "Failed to update book. Please try again.");
            }
            
            request.setAttribute("book", book);
            
        } catch (Exception e) {
            request.setAttribute("error", "Error updating book: " + e.getMessage());
        }
        
        List<Category> categories = categoryDAO.getAllCategories();
        request.setAttribute("categories", categories);
        request.setAttribute("pageTitle", "Edit Book");
        
        request.getRequestDispatcher("/admin/edit-book.jsp").forward(request, response);
    }
    
    private void processDeleteBook(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            int bookId = Integer.parseInt(request.getParameter("bookId"));
            
            if (bookDAO.deleteBook(bookId)) {
                request.setAttribute("success", "Book deleted successfully!");
            } else {
                request.setAttribute("error", "Failed to delete book.");
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid book ID.");
        }
        
        manageBooks(request, response);
    }
    
    private void manageCategories(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        List<Category> categories = categoryDAO.getAllCategories();
        request.setAttribute("categories", categories);
        request.setAttribute("pageTitle", "Manage Categories");
        
        request.getRequestDispatcher("/admin/categories.jsp").forward(request, response);
    }
    
    private void processAddCategory(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String categoryName = request.getParameter("categoryName");
        String description = request.getParameter("description");
        
        if (categoryName == null || categoryName.trim().isEmpty()) {
            request.setAttribute("error", "Category name is required");
        } else {
            Category category = new Category(categoryName.trim(), description);
            
            if (categoryDAO.addCategory(category)) {
                request.setAttribute("success", "Category added successfully!");
            } else {
                request.setAttribute("error", "Failed to add category. It may already exist.");
            }
        }
        
        manageCategories(request, response);
    }
    
    private void processEditCategory(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));
            String categoryName = request.getParameter("categoryName");
            String description = request.getParameter("description");
            
            if (categoryName == null || categoryName.trim().isEmpty()) {
                request.setAttribute("error", "Category name is required");
            } else {
                Category category = new Category(categoryId, categoryName.trim(), description);
                
                if (categoryDAO.updateCategory(category)) {
                    request.setAttribute("success", "Category updated successfully!");
                } else {
                    request.setAttribute("error", "Failed to update category.");
                }
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid category ID.");
        }
        
        manageCategories(request, response);
    }
    
    private void processDeleteCategory(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));
            
            if (categoryDAO.deleteCategory(categoryId)) {
                request.setAttribute("success", "Category deleted successfully!");
            } else {
                request.setAttribute("error", "Failed to delete category. It may be in use by books.");
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid category ID.");
        }
        
        manageCategories(request, response);
    }
    
    private void manageOrders(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        List<Order> orders = orderDAO.getAllOrders();
        request.setAttribute("orders", orders);
        request.setAttribute("pageTitle", "Manage Orders");
        
        request.getRequestDispatcher("/admin/orders.jsp").forward(request, response);
    }
    
    private void showOrderDetails(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String orderIdParam = request.getParameter("id");
        
        if (orderIdParam == null || orderIdParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }
        
        try {
            int orderId = Integer.parseInt(orderIdParam);
            Order order = orderDAO.getOrderById(orderId);
            
            if (order == null) {
                response.sendRedirect(request.getContextPath() + "/admin/orders");
                return;
            }
            
            request.setAttribute("order", order);
            request.setAttribute("pageTitle", "Order Details #" + orderId);
            
            request.getRequestDispatcher("/admin/order-details.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/orders");
        }
    }
    
    private void processUpdateOrderStatus(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            String orderStatus = request.getParameter("orderStatus");
            String paymentStatus = request.getParameter("paymentStatus");
            String trackingNumber = request.getParameter("trackingNumber");
            
            boolean success = true;
            
            if (orderStatus != null && !orderStatus.trim().isEmpty()) {
                success &= orderDAO.updateOrderStatus(orderId, orderStatus);
            }
            
            if (paymentStatus != null && !paymentStatus.trim().isEmpty()) {
                success &= orderDAO.updatePaymentStatus(orderId, paymentStatus);
            }
            
            if (trackingNumber != null && !trackingNumber.trim().isEmpty()) {
                success &= orderDAO.updateTrackingNumber(orderId, trackingNumber);
            }
            
            if (success) {
                request.setAttribute("success", "Order updated successfully!");
            } else {
                request.setAttribute("error", "Failed to update order.");
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid order ID.");
        }
        
        manageOrders(request, response);
    }
    
    private void manageUsers(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        List<User> users = userDAO.getAllUsers();
        request.setAttribute("users", users);
        request.setAttribute("pageTitle", "Manage Users");
        
        request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
    }
    
    private void logout(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/login");
    }
    
    private Book createBookFromRequest(HttpServletRequest request) throws Exception {
        String title = request.getParameter("title");
        String author = request.getParameter("author");
        String isbn = request.getParameter("isbn");
        String description = request.getParameter("description");
        String priceStr = request.getParameter("price");
        String stockStr = request.getParameter("stock");
        String categoryIdStr = request.getParameter("categoryId");
        String coverImage = request.getParameter("coverImage");
        String publisher = request.getParameter("publisher");
        String publicationDateStr = request.getParameter("publicationDate");
        String pagesStr = request.getParameter("pages");
        String language = request.getParameter("language");
        boolean isFeatured = "on".equals(request.getParameter("featured"));
        boolean isBestseller = "on".equals(request.getParameter("bestseller"));
        
        // Validation
        if (title == null || title.trim().isEmpty()) {
            throw new Exception("Title is required");
        }
        if (author == null || author.trim().isEmpty()) {
            throw new Exception("Author is required");
        }
        if (priceStr == null || priceStr.trim().isEmpty()) {
            throw new Exception("Price is required");
        }
        
        BigDecimal price = new BigDecimal(priceStr);
        int stock = Integer.parseInt(stockStr != null ? stockStr : "0");
        int categoryId = Integer.parseInt(categoryIdStr != null ? categoryIdStr : "1");
        
        Book book = new Book(title.trim(), author.trim(), isbn, description, price, stock, categoryId);
        book.setCoverImage(coverImage);
        book.setPublisher(publisher);
        
        if (publicationDateStr != null && !publicationDateStr.trim().isEmpty()) {
            book.setPublicationDate(Date.valueOf(publicationDateStr));
        }
        
        if (pagesStr != null && !pagesStr.trim().isEmpty()) {
            book.setPages(Integer.parseInt(pagesStr));
        }
        
        book.setLanguage(language != null ? language : "English");
        book.setFeatured(isFeatured);
        book.setBestseller(isBestseller);
        
        return book;
    }
}
