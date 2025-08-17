package com.bookstore.controller;

import com.bookstore.dao.BookDAO;
import com.bookstore.dao.CategoryDAO;
import com.bookstore.model.Book;
import com.bookstore.model.Category;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

/**
 * Servlet controller for book catalog and search operations
 */
public class BookController extends HttpServlet {
    private BookDAO bookDAO;
    private CategoryDAO categoryDAO;
    private static final int BOOKS_PER_PAGE = 12;
    
    @Override
    public void init() throws ServletException {
        bookDAO = new BookDAO();
        categoryDAO = new CategoryDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = getAction(request);
        
        switch (action) {
            case "":
            case "catalog":
                showCatalog(request, response);
                break;
            case "search":
                searchBooks(request, response);
                break;
            case "details":
                showBookDetails(request, response);
                break;
            case "category":
                showBooksByCategory(request, response);
                break;
            case "featured":
                showFeaturedBooks(request, response);
                break;
            case "bestsellers":
                showBestsellerBooks(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/books/catalog");
                break;
        }
    }
    
    private String getAction(HttpServletRequest request) {
        String pathInfo = request.getPathInfo();
        return (pathInfo != null && pathInfo.length() > 1) ? pathInfo.substring(1) : "";
    }
    
    private void showCatalog(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int page = getPageNumber(request);
        int offset = (page - 1) * BOOKS_PER_PAGE;
        
        List<Book> books = bookDAO.getAllBooks(offset, BOOKS_PER_PAGE);
        int totalBooks = bookDAO.getTotalBooksCount();
        int totalPages = (int) Math.ceil((double) totalBooks / BOOKS_PER_PAGE);
        
        List<Category> categories = categoryDAO.getAllCategories();
        
        request.setAttribute("books", books);
        request.setAttribute("categories", categories);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalBooks", totalBooks);
        request.setAttribute("pageTitle", "Book Catalog");
        
        request.getRequestDispatcher("/catalog.jsp").forward(request, response);
    }
    
    private void searchBooks(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String query = request.getParameter("q");
        String categoryParam = request.getParameter("category");
        String minPriceParam = request.getParameter("minPrice");
        String maxPriceParam = request.getParameter("maxPrice");
        
        Integer categoryId = null;
        BigDecimal minPrice = null;
        BigDecimal maxPrice = null;
        
        try {
            if (categoryParam != null && !categoryParam.trim().isEmpty() && !categoryParam.equals("0")) {
                categoryId = Integer.parseInt(categoryParam);
            }
            if (minPriceParam != null && !minPriceParam.trim().isEmpty()) {
                minPrice = new BigDecimal(minPriceParam);
            }
            if (maxPriceParam != null && !maxPriceParam.trim().isEmpty()) {
                maxPrice = new BigDecimal(maxPriceParam);
            }
        } catch (NumberFormatException e) {
            // Invalid number format, ignore and continue with null values
            System.out.println("Invalid number format in search parameters: " + e.getMessage());
        }
        
        int page = getPageNumber(request);
        int offset = (page - 1) * BOOKS_PER_PAGE;
        
        List<Book> books = bookDAO.searchBooks(query, categoryId, minPrice, maxPrice, offset, BOOKS_PER_PAGE);
        int totalBooks = bookDAO.getSearchResultCount(query, categoryId, minPrice, maxPrice);
        int totalPages = (int) Math.ceil((double) totalBooks / BOOKS_PER_PAGE);
        
        List<Category> categories = categoryDAO.getAllCategories();
        
        request.setAttribute("books", books);
        request.setAttribute("categories", categories);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalBooks", totalBooks);
        request.setAttribute("searchQuery", query);
        request.setAttribute("selectedCategory", categoryId);
        request.setAttribute("minPrice", minPriceParam);
        request.setAttribute("maxPrice", maxPriceParam);
        request.setAttribute("pageTitle", "Search Results");
        
        request.getRequestDispatcher("/catalog.jsp").forward(request, response);
    }
    
    private void showBookDetails(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String bookIdParam = request.getParameter("id");
        
        if (bookIdParam == null || bookIdParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/books/catalog");
            return;
        }
        
        try {
            int bookId = Integer.parseInt(bookIdParam);
            Book book = bookDAO.getBookById(bookId);
            
            if (book == null) {
                response.sendRedirect(request.getContextPath() + "/books/catalog");
                return;
            }
            
            // Get related books from the same category
            List<Book> relatedBooks = bookDAO.getBooksByCategory(book.getCategoryId(), 4);
            relatedBooks.removeIf(b -> b.getBookId() == bookId); // Remove current book
            
            request.setAttribute("book", book);
            request.setAttribute("relatedBooks", relatedBooks);
            request.setAttribute("pageTitle", book.getTitle());
            
            request.getRequestDispatcher("/book-details.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/books/catalog");
        }
    }
    
    private void showBooksByCategory(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String categoryIdParam = request.getParameter("id");
        
        if (categoryIdParam == null || categoryIdParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/books/catalog");
            return;
        }
        
        try {
            int categoryId = Integer.parseInt(categoryIdParam);
            Category category = categoryDAO.getCategoryById(categoryId);
            
            if (category == null) {
                response.sendRedirect(request.getContextPath() + "/books/catalog");
                return;
            }
            
            int page = getPageNumber(request);
            int offset = (page - 1) * BOOKS_PER_PAGE;
            
            List<Book> books = bookDAO.searchBooks(null, categoryId, null, null, offset, BOOKS_PER_PAGE);
            int totalBooks = bookDAO.getSearchResultCount(null, categoryId, null, null);
            int totalPages = (int) Math.ceil((double) totalBooks / BOOKS_PER_PAGE);
            
            List<Category> categories = categoryDAO.getAllCategories();
            
            request.setAttribute("books", books);
            request.setAttribute("categories", categories);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalBooks", totalBooks);
            request.setAttribute("selectedCategory", categoryId);
            request.setAttribute("categoryName", category.getCategoryName());
            request.setAttribute("pageTitle", category.getCategoryName() + " Books");
            
            request.getRequestDispatcher("/category-books.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/books/catalog");
        }
    }
    
    private void showFeaturedBooks(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        List<Book> books = bookDAO.getFeaturedBooks(20);
        List<Category> categories = categoryDAO.getAllCategories();
        
        request.setAttribute("books", books);
        request.setAttribute("categories", categories);
        request.setAttribute("pageTitle", "Featured Books");
        
        request.getRequestDispatcher("/featured-books.jsp").forward(request, response);
    }
    
    private void showBestsellerBooks(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        List<Book> books = bookDAO.getBestsellerBooks(20);
        List<Category> categories = categoryDAO.getAllCategories();
        
        request.setAttribute("books", books);
        request.setAttribute("categories", categories);
        request.setAttribute("pageTitle", "Bestseller Books");
        
        request.getRequestDispatcher("/bestseller-books.jsp").forward(request, response);
    }
    
    private int getPageNumber(HttpServletRequest request) {
        String pageParam = request.getParameter("page");
        int page = 1;
        
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        
        return page;
    }
}
