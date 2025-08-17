<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.bookstore.model.Book" %>
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
            <a class="navbar-brand fw-bold" href="<%= request.getContextPath() %>">
                <i class="fas fa-book-open"></i> BookHaven
            </a>
            
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/books/catalog">Browse Books</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/books/bestsellers">Bestsellers</a>
                    </li>
                </ul>
                
                <ul class="navbar-nav">
                    <% if (session.getAttribute("user") != null) { %>
                        <li class="nav-item">
                            <a class="nav-link" href="<%= request.getContextPath() %>/cart">
                                <i class="fas fa-shopping-cart"></i> Cart
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
        <% 
        Book book = (Book) request.getAttribute("book");
        if (book != null) {
        %>
            <!-- Breadcrumb -->
            <nav aria-label="breadcrumb" class="mb-4">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/">Home</a></li>
                    <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/books/catalog">Books</a></li>
                    <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/books/category?id=<%= book.getCategoryId() %>"><%= book.getCategoryName() %></a></li>
                    <li class="breadcrumb-item active" aria-current="page"><%= book.getTitle() %></li>
                </ol>
            </nav>
            
            <div class="row">
                <!-- Book Image -->
                <div class="col-md-4 mb-4">
                    <div class="text-center">
                        <% 
                        String coverImage = book.getCoverImage();
                        String imageUrl;
                        
                        if (coverImage != null && !coverImage.trim().isEmpty() && !"null".equals(coverImage)) {
                            // If it's just a filename, assume it's in the images directory
                            if (!coverImage.startsWith("/") && !coverImage.startsWith("http")) {
                                imageUrl = request.getContextPath() + "/images/" + coverImage;
                            } else if (coverImage.startsWith("/images/")) {
                                imageUrl = request.getContextPath() + coverImage;
                            } else {
                                imageUrl = coverImage;
                            }
                        } else {
                            // Use placeholder for missing images
                            imageUrl = "/placeholder.svg?height=500&width=350";
                        }
                        %>
                        <img src="<%= imageUrl %>" 
                             class="img-fluid rounded shadow-lg book-detail-image" alt="<%= book.getTitle() %>"
                             onerror="this.src='/placeholder.svg?height=500&width=350'">
                        
                        <% if (book.isBestseller()) { %>
                            <span class="badge bg-success position-absolute top-0 end-0 m-3">Bestseller</span>
                        <% } %>
                    </div>
                </div>
                
                <!-- Book Details -->
                <div class="col-md-8">
                    <div class="mb-3">
                        <h1 class="display-6 fw-bold"><%= book.getTitle() %></h1>
                        <p class="lead text-muted">by <strong><%= book.getAuthor() %></strong></p>
                        
                        <!-- Rating -->
                        <% if (book.getRating() != null && book.getRating().doubleValue() > 0) { %>
                            <div class="mb-3">
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
                                <span class="ms-2 text-muted">(<%= book.getTotalReviews() %> reviews)</span>
                            </div>
                        <% } %>
                        
                        <!-- Price and Stock -->
                        <div class="row mb-4">
                            <div class="col-md-6">
                                <h3 class="text-primary fw-bold">₹<%= book.getPrice() %></h3>
                            </div>
                            <div class="col-md-6">
                                <% if (book.getStockQuantity() > 0) { %>
                                    <span class="badge bg-success fs-6">
                                        <i class="fas fa-check-circle"></i> In Stock (<%= book.getStockQuantity() %> available)
                                    </span>
                                <% } else { %>
                                    <span class="badge bg-danger fs-6">
                                        <i class="fas fa-times-circle"></i> Out of Stock
                                    </span>
                                <% } %>
                            </div>
                        </div>
                        
                        <!-- Book Info -->
                        <div class="row mb-4">
                            <div class="col-md-6">
                                <ul class="list-unstyled">
                                    <li><strong>Category:</strong> <%= book.getCategoryName() %></li>
                                    <li><strong>Publisher:</strong> <%= book.getPublisher() != null ? book.getPublisher() : "N/A" %></li>
                                    <li><strong>Language:</strong> <%= book.getLanguage() %></li>
                                </ul>
                            </div>
                            <div class="col-md-6">
                                <ul class="list-unstyled">
                                    <li><strong>Pages:</strong> <%= book.getPages() > 0 ? book.getPages() : "N/A" %></li>
                                    <li><strong>ISBN:</strong> <%= book.getIsbn() != null ? book.getIsbn() : "N/A" %></li>
                                    <li><strong>Publication Date:</strong> <%= book.getPublicationDate() != null ? book.getPublicationDate() : "N/A" %></li>
                                </ul>
                            </div>
                        </div>
                        
                        <!-- Action Buttons -->
                        <div class="row mb-4">
                            <div class="col-md-8">
                                <div class="input-group">
                                    <button class="btn btn-outline-secondary" type="button" onclick="decreaseQuantity()">
                                        <i class="fas fa-minus"></i>
                                    </button>
                                    <input type="number" class="form-control text-center" id="quantity" value="1" min="1" max="<%= book.getStockQuantity() %>">
                                    <button class="btn btn-outline-secondary" type="button" onclick="increaseQuantity()">
                                        <i class="fas fa-plus"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <% if (book.getStockQuantity() > 0) { %>
                                    <button type="button" class="btn btn-primary w-100" onclick="addToCart(<%= book.getBookId() %>)">
                                        <i class="fas fa-cart-plus"></i> Add to Cart
                                    </button>
                                <% } else { %>
                                    <button type="button" class="btn btn-secondary w-100" disabled>
                                        <i class="fas fa-ban"></i> Out of Stock
                                    </button>
                                <% } %>
                            </div>
                        </div>
                        
                        <div class="d-flex gap-2 mb-4">
                            <button type="button" class="btn btn-outline-danger" onclick="addToWishlist(<%= book.getBookId() %>)">
                                <i class="fas fa-heart"></i> Add to Wishlist
                            </button>
                            <button type="button" class="btn btn-outline-info" onclick="shareBook()">
                                <i class="fas fa-share-alt"></i> Share
                            </button>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Book Description -->
            <div class="row mt-5">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header">
                            <h4><i class="fas fa-info-circle"></i> About This Book</h4>
                        </div>
                        <div class="card-body">
                            <% if (book.getDescription() != null && !book.getDescription().trim().isEmpty()) { %>
                                <p class="lead"><%= book.getDescription() %></p>
                            <% } else { %>
                                <p class="text-muted">No description available for this book.</p>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Related Books -->
            <% 
            List<Book> relatedBooks = (List<Book>) request.getAttribute("relatedBooks");
            if (relatedBooks != null && !relatedBooks.isEmpty()) {
            %>
                <div class="row mt-5">
                    <div class="col-12">
                        <h4 class="mb-4"><i class="fas fa-book"></i> More Books in <%= book.getCategoryName() %></h4>
                        <div class="row">
                            <% for (Book relatedBook : relatedBooks) { %>
                                <div class="col-lg-3 col-md-6 mb-4">
                                    <div class="card book-card h-100">
                                        <% 
                                        String relatedCoverImage = relatedBook.getCoverImage();
                                        String relatedImageUrl;
                                        
                                        if (relatedCoverImage != null && !relatedCoverImage.trim().isEmpty() && !"null".equals(relatedCoverImage)) {
                                            if (!relatedCoverImage.startsWith("/") && !relatedCoverImage.startsWith("http")) {
                                                relatedImageUrl = request.getContextPath() + "/images/" + relatedCoverImage;
                                            } else if (relatedCoverImage.startsWith("/images/")) {
                                                relatedImageUrl = request.getContextPath() + relatedCoverImage;
                                            } else {
                                                relatedImageUrl = relatedCoverImage;
                                            }
                                        } else {
                                            relatedImageUrl = "/placeholder.svg?height=250&width=180";
                                        }
                                        %>
                                        <img src="<%= relatedImageUrl %>" 
                                             class="card-img-top" alt="<%= relatedBook.getTitle() %>"
                                             onerror="this.src='/placeholder.svg?height=250&width=180'">
                                        <div class="card-body d-flex flex-column">
                                            <h6 class="card-title book-title"><%= relatedBook.getTitle() %></h6>
                                            <p class="card-text text-muted small">by <%= relatedBook.getAuthor() %></p>
                                            <div class="mt-auto">
                                                <div class="d-flex justify-content-between align-items-center mb-2">
                                                    <h5 class="text-primary mb-0">₹<%= relatedBook.getPrice() %></h5>
                                                </div>
                                                <a href="<%= request.getContextPath() %>/books/details?id=<%= relatedBook.getBookId() %>" 
                                                   class="btn btn-outline-primary btn-sm w-100">
                                                    <i class="fas fa-eye"></i> View Details
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            <% } %>
            
        <% } else { %>
            <div class="text-center py-5">
                <i class="fas fa-book fa-3x text-muted mb-3"></i>
                <h4>Book Not Found</h4>
                <p class="text-muted">The book you're looking for doesn't exist or has been removed.</p>
                <a href="<%= request.getContextPath() %>/books/catalog" class="btn btn-primary">
                    <i class="fas fa-arrow-left"></i> Back to Catalog
                </a>
            </div>
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
        function increaseQuantity() {
            const quantityInput = document.getElementById('quantity');
            const currentValue = parseInt(quantityInput.value);
            const maxValue = parseInt(quantityInput.max);
            
            if (currentValue < maxValue) {
                quantityInput.value = currentValue + 1;
            }
        }
        
        function decreaseQuantity() {
            const quantityInput = document.getElementById('quantity');
            const currentValue = parseInt(quantityInput.value);
            
            if (currentValue > 1) {
                quantityInput.value = currentValue - 1;
            }
        }
        
        function addToCart(bookId) {
            <% if (session.getAttribute("user") != null) { %>
                const quantity = document.getElementById('quantity').value;
                
                fetch('<%= request.getContextPath() %>/cart/add', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'bookId=' + bookId + '&quantity=' + quantity
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        alert('Book added to cart successfully!');
                    } else {
                        alert('Failed to add book to cart: ' + data.message);
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('An error occurred while adding the book to cart.');
                });
            <% } else { %>
                window.location.href = '<%= request.getContextPath() %>/user/login';
            <% } %>
        }
        
        function addToWishlist(bookId) {
            <% if (session.getAttribute("user") != null) { %>
                // TODO: Implement wishlist functionality
                alert('Wishlist functionality will be implemented in a future update');
            <% } else { %>
                window.location.href = '<%= request.getContextPath() %>/user/login';
            <% } %>
        }
        
        function shareBook() {
            if (navigator.share) {
                navigator.share({
                    title: '<%= book != null ? book.getTitle() : "" %>',
                    text: 'Check out this book: <%= book != null ? book.getTitle() : "" %> by <%= book != null ? book.getAuthor() : "" %>',
                    url: window.location.href
                });
            } else {
                // Fallback for browsers that don't support Web Share API
                navigator.clipboard.writeText(window.location.href).then(() => {
                    alert('Book link copied to clipboard!');
                });
            }
        }
    </script>
</body>
</html>
