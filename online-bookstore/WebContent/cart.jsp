<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="com.bookstore.model.CartItem" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shopping Cart - Online Bookstore</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="<%= request.getContextPath() %>/css/style.css" rel="stylesheet">
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container">
            <a class="navbar-brand" href="<%= request.getContextPath() %>/">
                <i class="fas fa-book"></i> Online Bookstore
            </a>
            
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/books/catalog">Catalog</a>
                    </li>
                    <!-- Removed Featured navigation link -->
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/books/bestsellers">Bestsellers</a>
                    </li>
                </ul>
                
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link active" href="<%= request.getContextPath() %>/cart">
                            <i class="fas fa-shopping-cart"></i> Cart <span id="cart-count" class="badge bg-light text-dark">0</span>
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
                </ul>
            </div>
        </div>
    </nav>
    
    <div class="container mt-4">
        <div class="row">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h4 class="mb-0"><i class="fas fa-shopping-cart"></i> Shopping Cart</h4>
                        <button type="button" class="btn btn-outline-danger btn-sm" onclick="clearCart()">
                            <i class="fas fa-trash"></i> Clear Cart
                        </button>
                    </div>
                    <div class="card-body">
                        <div id="cart-items">
                            <% 
                            List<CartItem> cartItems = (List<CartItem>) request.getAttribute("cartItems");
                            if (cartItems != null && !cartItems.isEmpty()) {
                                for (CartItem item : cartItems) {
                            %>
                                <div class="cart-item mb-3 p-3 border rounded" data-book-id="<%= item.getBookId() %>">
                                    <div class="row align-items-center">
                                        <div class="col-md-2">
                                            <% 
                                            String coverImage = item.getCoverImage();
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
                                                imageUrl = "/placeholder.svg?height=100&width=80";
                                            }
                                            %>
                                            <img src="<%= imageUrl %>" 
                                                 class="img-fluid rounded" alt="<%= item.getBookTitle() %>" style="max-height: 100px;"
                                                 onerror="this.src='/placeholder.svg?height=100&width=80'">
                                        </div>
                                        <div class="col-md-4">
                                            <h6 class="mb-1"><%= item.getBookTitle() %></h6>
                                            <p class="text-muted small mb-1">by <%= item.getBookAuthor() %></p>
                                            <p class="text-primary mb-0">₹<%= item.getBookPrice() %></p>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="input-group input-group-sm">
                                                <button class="btn btn-outline-secondary" type="button" 
                                                        onclick="updateQuantity(<%= item.getBookId() %>, <%= item.getQuantity() - 1 %>)">
                                                    <i class="fas fa-minus"></i>
                                                </button>
                                                <input type="number" class="form-control text-center quantity-input" 
                                                       value="<%= item.getQuantity() %>" min="1" max="99"
                                                       onchange="updateQuantity(<%= item.getBookId() %>, this.value)">
                                                <button class="btn btn-outline-secondary" type="button" 
                                                        onclick="updateQuantity(<%= item.getBookId() %>, <%= item.getQuantity() + 1 %>)">
                                                    <i class="fas fa-plus"></i>
                                                </button>
                                            </div>
                                        </div>
                                        <div class="col-md-2">
                                            <strong class="item-total">₹<%= item.getTotalPrice() %></strong>
                                        </div>
                                        <div class="col-md-1">
                                            <button type="button" class="btn btn-outline-danger btn-sm" 
                                                    onclick="removeFromCart(<%= item.getBookId() %>)">
                                                <i class="fas fa-times"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            <% 
                                }
                            } else {
                            %>
                                <div class="text-center py-5" id="empty-cart">
                                    <i class="fas fa-shopping-cart fa-3x text-muted mb-3"></i>
                                    <h4>Your cart is empty</h4>
                                    <p class="text-muted">Add some books to get started!</p>
                                    <a href="<%= request.getContextPath() %>/books/catalog" class="btn btn-primary">
                                        <i class="fas fa-book"></i> Browse Books
                                    </a>
                                </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0"><i class="fas fa-calculator"></i> Order Summary</h5>
                    </div>
                    <div class="card-body">
                        <div class="d-flex justify-content-between mb-2">
                            <span>Subtotal:</span>
                            <span id="cart-subtotal">₹<%= request.getAttribute("cartTotal") != null ? request.getAttribute("cartTotal") : "0.00" %></span>
                        </div>
                        <div class="d-flex justify-content-between mb-2">
                            <span>Shipping:</span>
                            <span class="text-success">FREE</span>
                        </div>
                        <div class="d-flex justify-content-between mb-2">
                            <span>Tax:</span>
                            <span id="cart-tax">₹0.00</span>
                        </div>
                        <hr>
                        <div class="d-flex justify-content-between mb-3">
                            <strong>Total:</strong>
                            <strong id="cart-total">₹<%= request.getAttribute("cartTotal") != null ? request.getAttribute("cartTotal") : "0.00" %></strong>
                        </div>
                        
                        <% if (cartItems != null && !cartItems.isEmpty()) { %>
                            <div class="d-grid gap-2">
                                <button type="button" class="btn btn-primary btn-lg" onclick="proceedToCheckout()">
                                    <i class="fas fa-credit-card"></i> Place Order
                                </button>
                                <a href="<%= request.getContextPath() %>/books/catalog" class="btn btn-outline-secondary">
                                    <i class="fas fa-arrow-left"></i> Continue Shopping
                                </a>
                            </div>
                        <% } %>
                    </div>
                </div>
                
                <!-- Promo Code Section -->
                <div class="card mt-3">
                    <div class="card-header">
                        <h6 class="mb-0"><i class="fas fa-tag"></i> Promo Code</h6>
                    </div>
                    <div class="card-body">
                        <div class="input-group">
                            <input type="text" class="form-control" placeholder="Enter promo code" id="promo-code">
                            <button class="btn btn-outline-primary" type="button" onclick="applyPromoCode()">
                                Apply
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
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
        // Update cart count on page load
        updateCartCount();
        
        function updateQuantity(bookId, newQuantity) {
            if (newQuantity < 0) return;
            
            const itemElement = document.querySelector(`[data-book-id="${bookId}"]`);
            const quantityInput = itemElement ? itemElement.querySelector('.quantity-input') : null;
            
            if (quantityInput) {
                quantityInput.disabled = true;
            }
            
            fetch('<%= request.getContextPath() %>/cart/update', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'bookId=' + bookId + '&quantity=' + newQuantity
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.json();
            })
            .then(data => {
                if (data.success) {
                    if (newQuantity === 0) {
                        itemElement.remove();
                        checkEmptyCart();
                        showSuccessMessage('Item removed from cart');
                    } else {
                        quantityInput.value = newQuantity;
                        
                        const priceElement = itemElement.querySelector('.text-primary');
                        const price = parseFloat(priceElement.textContent.replace('₹', ''));
                        const totalElement = itemElement.querySelector('.item-total');
                        totalElement.textContent = '₹' + (price * newQuantity).toFixed(2);
                        
                        showSuccessMessage('Quantity updated successfully');
                    }
                    
                    if (data.cartTotal) {
                        updateCartTotals(data.cartTotal);
                    }
                    updateCartCount();
                } else {
                    showErrorMessage(data.message || 'Failed to update cart');
                }
            })
            .catch(error => {
                showErrorMessage('Error updating cart. Please try again.');
            })
            .finally(() => {
                if (quantityInput) {
                    quantityInput.disabled = false;
                }
            });
        }
        
        function removeFromCart(bookId) {
            if (!confirm('Are you sure you want to remove this item from your cart?')) {
                return;
            }
            
            const itemElement = document.querySelector(`[data-book-id="${bookId}"]`);
            const removeButton = itemElement ? itemElement.querySelector('.btn-outline-danger') : null;
            
            if (removeButton) {
                removeButton.disabled = true;
                removeButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
            }
            
            fetch('<%= request.getContextPath() %>/cart/remove', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'bookId=' + encodeURIComponent(bookId)
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.json();
            })
            .then(data => {
                if (data.success) {
                    if (itemElement) {
                        itemElement.style.transition = 'all 0.3s ease';
                        itemElement.style.transform = 'translateX(-100%)';
                        itemElement.style.opacity = '0';
                        
                        setTimeout(() => {
                            itemElement.remove();
                            checkEmptyCart();
                        }, 300);
                    }
                    
                    updateCartTotals(data.cartTotal || '0.00');
                    updateCartCount();
                    showSuccessMessage('Item removed from cart successfully');
                } else {
                    throw new Error(data.message || 'Failed to remove item');
                }
            })
            .catch(error => {
                if (removeButton) {
                    removeButton.disabled = false;
                    removeButton.innerHTML = '<i class="fas fa-times"></i>';
                }
                showErrorMessage('Error removing item. Please try again.');
            });
        }
        
        function clearCart() {
            if (!confirm('Are you sure you want to clear your entire cart?')) {
                return;
            }
            
            fetch('<%= request.getContextPath() %>/cart/clear', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                }
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    document.getElementById('cart-items').innerHTML = `
                        <div class="text-center py-5" id="empty-cart">
                            <i class="fas fa-shopping-cart fa-3x text-muted mb-3"></i>
                            <h4>Your cart is empty</h4>
                            <p class="text-muted">Add some books to get started!</p>
                            <a href="<%= request.getContextPath() %>/books/catalog" class="btn btn-primary">
                                <i class="fas fa-book"></i> Browse Books
                            </a>
                        </div>
                    `;
                    updateCartTotals('0.00');
                    updateCartCount();
                    showSuccessMessage('Cart cleared successfully');
                } else {
                    alert('Error: ' + data.message);
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('An error occurred while clearing the cart.');
            });
        }
        
        function updateCartTotals(subtotal) {
            document.getElementById('cart-subtotal').textContent = '₹' + subtotal;
            document.getElementById('cart-total').textContent = '₹' + subtotal;
        }
        
        function updateCartCount() {
            fetch('<%= request.getContextPath() %>/cart/count')
            .then(response => response.json())
            .then(data => {
                document.getElementById('cart-count').textContent = data.cartCount;
            })
            .catch(error => {
                console.error('Error updating cart count:', error);
            });
        }
        
        function checkEmptyCart() {
            const cartItems = document.querySelectorAll('.cart-item');
            if (cartItems.length === 0) {
                document.getElementById('cart-items').innerHTML = `
                    <div class="text-center py-5" id="empty-cart">
                        <i class="fas fa-shopping-cart fa-3x text-muted mb-3"></i>
                        <h4>Your cart is empty</h4>
                        <p class="text-muted">Add some books to get started!</p>
                        <a href="<%= request.getContextPath() %>/books/catalog" class="btn btn-primary">
                            <i class="fas fa-book"></i> Browse Books
                        </a>
                    </div>
                `;
            }
        }
        
        function showSuccessMessage(message) {
            const alertDiv = document.createElement('div');
            alertDiv.className = 'alert alert-success alert-dismissible fade show position-fixed';
            alertDiv.style.cssText = 'top: 20px; right: 20px; z-index: 9999; min-width: 300px;';
            alertDiv.innerHTML = `
                <i class="fas fa-check-circle me-2"></i>${message}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            `;
            
            document.body.appendChild(alertDiv);
            setTimeout(() => {
                if (alertDiv.parentElement) {
                    alertDiv.remove();
                }
            }, 3000);
        }
        
        function showErrorMessage(message) {
            const alertDiv = document.createElement('div');
            alertDiv.className = 'alert alert-danger alert-dismissible fade show position-fixed';
            alertDiv.style.cssText = 'top: 20px; right: 20px; z-index: 9999; min-width: 300px;';
            alertDiv.innerHTML = `
                <i class="fas fa-exclamation-circle me-2"></i>${message}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            `;
            
            document.body.appendChild(alertDiv);
            setTimeout(() => {
                if (alertDiv.parentElement) {
                    alertDiv.remove();
                }
            }, 3000);
        }
        
        function applyPromoCode() {
            const promoCode = document.getElementById('promo-code').value.trim();
            if (!promoCode) {
                alert('Please enter a promo code');
                return;
            }
            
            alert('Promo code functionality will be implemented in a future update');
        }
        
        function proceedToCheckout() {
            if (!confirm('Are you sure you want to place this order?')) {
                return;
            }
            
            fetch('<%= request.getContextPath() %>/orders/place', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                }
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('Order placed successfully! Order ID: #' + data.orderId);
                    window.location.href = '<%= request.getContextPath() %>/user/profile?tab=order-history';
                } else {
                    alert('Error placing order: ' + data.message);
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('An error occurred while placing the order.');
            });
        }
    </script>
</body>
</html>
