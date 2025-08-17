<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.bookstore.model.Book" %>
<%@ page import="com.bookstore.model.Category" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= request.getAttribute("pageTitle") %> - Online Bookstore</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="<%= request.getContextPath() %>/css/style.css" rel="stylesheet">
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container">
            <a class="navbar-brand" href="<%= request.getContextPath() %>">
                <i class="fas fa-book"></i> Online Bookstore
            </a>
            
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link active" href="<%= request.getContextPath() %>/books/catalog">Catalog</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/books/bestsellers">Bestsellers</a>
                    </li>
                </ul>
                
                <ul class="navbar-nav">
                    <% if (session.getAttribute("user") != null) { %>
                        <li class="nav-item">
                            <a class="nav-link" href="<%= request.getContextPath() %>/cart">
                                <i class="fas fa-shopping-cart"></i> Cart <span id="cart-count" class="badge bg-light text-dark ms-1"><%= session.getAttribute("cartCount") %></span>
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="<%= request.getContextPath() %>/user/profile">
                                <i class="fas fa-user"></i> <%= session.getAttribute("userName") %>
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="<%= request.getContextPath() %>/user/logout">Logout</a>
                        </li>
                    <% } else { %>
                        <li class="nav-item">
                            <a class="nav-link" href="<%= request.getContextPath() %>/user/login">Login</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="<%= request.getContextPath() %>/user/register">Register</a>
                        </li>
                    <% } %>
                </ul>
            </div>
        </div>
    </nav>
    
    <div class="container mt-4">
        <!-- Search and Filter Section -->
        <div class="row mb-4">
            <div class="col-md-8">
                <!-- Fixed search form action and method -->
                <form action="<%= request.getContextPath() %>/books/search" method="GET" class="d-flex">
                    <input type="text" class="form-control me-2" name="q" placeholder="Search books by title, author, or description..." 
                           value="<%= request.getParameter("q") != null ? request.getParameter("q") : "" %>">
                    <button type="submit" class="btn btn-outline-primary">
                        <i class="fas fa-search"></i> Search
                    </button>
                </form>
            </div>
            <div class="col-md-4">
                <!-- Simplified category filter with direct links -->
                <div class="dropdown">
                    <button class="btn btn-outline-secondary dropdown-toggle w-100" type="button" data-bs-toggle="dropdown">
                        <i class="fas fa-filter"></i> Filter by Category
                    </button>
                    <ul class="dropdown-menu w-100">
                        <li><a class="dropdown-item" href="<%= request.getContextPath() %>/books/catalog">All Categories</a></li>
                        <% 
                        List<Category> categories = (List<Category>) request.getAttribute("categories");
                        if (categories != null) {
                            for (Category category : categories) {
                        %>
                            <li><a class="dropdown-item" href="<%= request.getContextPath() %>/books/search?category=<%= category.getCategoryId() %>">
                                <%= category.getCategoryName() %>
                            </a></li>
                        <% 
                            }
                        }
                        %>
                    </ul>
                </div>
            </div>
        </div>
        
        <!-- Page Header -->
        <div class="row mb-4">
            <div class="col">
                <h2><%= request.getAttribute("pageTitle") %></h2>
                <p class="text-muted">
                    Showing <%= request.getAttribute("totalBooks") %> books
                    <% if (request.getAttribute("totalPages") != null && (Integer) request.getAttribute("totalPages") > 1) { %>
                        (Page <%= request.getAttribute("currentPage") %> of <%= request.getAttribute("totalPages") %>)
                    <% } %>
                </p>
            </div>
        </div>
        
        <!-- Books Grid -->
        <div class="row">
            <% 
            List<Book> books = (List<Book>) request.getAttribute("books");
            if (books != null && !books.isEmpty()) {
                for (Book book : books) {
            %>
                <div class="col-lg-3 col-md-4 col-sm-6 mb-4">
                    <div class="card h-100 book-card">
                        <div class="book-image-container">
                            <% 
                            String coverImage = book.getCoverImage();
                            String imageUrl;
                            
                            if (coverImage != null && !coverImage.trim().isEmpty() && !"null".equals(coverImage)) {
                                // Simple approach: assume all images are in WebContent/images/ directory
                                if (coverImage.startsWith("images/")) {
                                    imageUrl = request.getContextPath() + "/" + coverImage;
                                } else {
                                    imageUrl = request.getContextPath() + "/images/" + coverImage;
                                }
                            } else {
                                // Use placeholder for missing images
                                imageUrl = "https://via.placeholder.com/200x300/f8f9fa/6c757d?text=No+Image";
                            }
                            %>
                            <img src="<%= imageUrl %>" 
                                 class="card-img-top book-image" alt="<%= book.getTitle() %>"
                                 onerror="this.src='https://via.placeholder.com/200x300/f8f9fa/6c757d?text=No+Image'">
                            <% if (book.isBestseller()) { %>
                                <span class="badge bg-success position-absolute top-0 end-0 m-2">Bestseller</span>
                            <% } %>
                        </div>
                        <div class="card-body d-flex flex-column">
                            <h6 class="card-title book-title"><%= book.getTitle() %></h6>
                            <p class="card-text text-muted small">by <%= book.getAuthor() %></p>
                            <p class="card-text small text-muted mb-2">
                                <i class="fas fa-tag"></i> <%= book.getCategoryName() %>
                            </p>
                            
                            <% if (book.getRating() != null && book.getRating().doubleValue() > 0) { %>
                                <div class="mb-2">
                                    <% 
                                    double rating = book.getRating().doubleValue();
                                    for (int i = 1; i <= 5; i++) {
                                        if (i <= rating) {
                                    %>
                                        <i class="fas fa-star text-warning"></i>
                                    <% 
                                        } else if (i - 0.5 <= rating) {
                                    %>
                                        <i class="fas fa-star-half-alt text-warning"></i>
                                    <% 
                                        } else {
                                    %>
                                        <i class="far fa-star text-warning"></i>
                                    <% 
                                        }
                                    }
                                    %>
                                    <small class="text-muted">(<%= book.getTotalReviews() %> reviews)</small>
                                </div>
                            <% } %>
                            
                            <div class="mt-auto">
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <!-- Changed currency from $ to ₹ for Indian Rupees -->
                                    <h5 class="text-primary mb-0">₹<%= book.getPrice() %></h5>
                                    <small class="text-muted">
                                        <% if (book.getStockQuantity() > 0) { %>
                                            <i class="fas fa-check-circle text-success"></i> In Stock
                                        <% } else { %>
                                            <i class="fas fa-times-circle text-danger"></i> Out of Stock
                                        <% } %>
                                    </small>
                                </div>
                                
                                <div class="btn-group w-100" role="group">
                                    <a href="<%= request.getContextPath() %>/books/details?id=<%= book.getBookId() %>" 
                                       class="btn btn-outline-primary btn-sm">
                                        <i class="fas fa-eye"></i> View
                                    </a>
                                    <% if (book.getStockQuantity() > 0) { %>
                                        <button type="button" class="btn btn-primary btn-sm" 
                                                onclick="addToCart(<%= book.getBookId() %>)">
                                            <i class="fas fa-cart-plus"></i> Add to Cart
                                        </button>
                                    <% } else { %>
                                        <button type="button" class="btn btn-secondary btn-sm" disabled>
                                            <i class="fas fa-ban"></i> Out of Stock
                                        </button>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            <% 
                }
            } else {
            %>
                <div class="col-12">
                    <div class="text-center py-5">
                        <i class="fas fa-book fa-3x text-muted mb-3"></i>
                        <h4>No books found</h4>
                        <p class="text-muted">Try adjusting your search criteria or browse all categories.</p>
                        <a href="<%= request.getContextPath() %>/books/catalog" class="btn btn-primary">
                            <i class="fas fa-arrow-left"></i> Back to Catalog
                        </a>
                    </div>
                </div>
            <% } %>
        </div>
        
        <!-- Pagination -->
        <% 
        Integer totalPages = (Integer) request.getAttribute("totalPages");
        Integer currentPage = (Integer) request.getAttribute("currentPage");
        if (totalPages != null && totalPages > 1) {
        %>
            <nav aria-label="Book catalog pagination" class="mt-4">
                <ul class="pagination justify-content-center">
                    <% if (currentPage > 1) { %>
                        <li class="page-item">
                            <a class="page-link" href="?page=<%= currentPage - 1 %>">
                                <i class="fas fa-chevron-left"></i> Previous
                            </a>
                        </li>
                    <% } %>
                    
                    <% 
                    int startPage = Math.max(1, currentPage - 2);
                    int endPage = Math.min(totalPages, currentPage + 2);
                    
                    for (int i = startPage; i <= endPage; i++) {
                    %>
                        <li class="page-item <%= i == currentPage ? "active" : "" %>">
                            <a class="page-link" href="?page=<%= i %>"><%= i %></a>
                        </li>
                    <% } %>
                    
                    <% if (currentPage < totalPages) { %>
                        <li class="page-item">
                            <a class="page-link" href="?page=<%= currentPage + 1 %>">
                                Next <i class="fas fa-chevron-right"></i>
                            </a>
                        </li>
                    <% } %>
                </ul>
            </nav>
        <% } %>
    </div>
    
    <!-- Footer with credit -->
    <footer class="bg-dark text-light py-4 mt-5">
        <div class="container">
            <div class="row">
                <div class="col-md-6">
                    <p class="mb-0">&copy; 2024 Online Bookstore. All rights reserved.</p>
                </div>
                <div class="col-md-6 text-md-end">
                    <p class="mb-0">Made by <strong>ANKIT RAWAT</strong></p>
                </div>
            </div>
        </div>
    </footer>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function addToCart(bookId) {
            <% if (session.getAttribute("user") != null) { %>
                fetch('<%= request.getContextPath() %>/cart/add', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'bookId=' + bookId + '&quantity=1'
                })
                .then(response => response.text())
                .then(text => {
                    try {
                        const data = JSON.parse(text);
                        if (data.success) {
                            alert('Book added to cart successfully!');
                            // Update cart count if element exists
                            const cartCountElement = document.getElementById('cart-count');
                            if (cartCountElement && data.cartCount) {
                                cartCountElement.textContent = data.cartCount;
                            }
                        } else {
                            alert('Failed to add book to cart: ' + data.message);
                        }
                    } catch (e) {
                        console.error('JSON parse error:', e);
                        alert('An error occurred while adding the book to cart.');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('An error occurred while adding the book to cart.');
                });
            <% } else { %>
                // User not logged in, redirect to login
                window.location.href = '<%= request.getContextPath() %>/user/login';
            <% } %>
        }
    </script>
</body>
</html>
