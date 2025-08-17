<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.bookstore.model.User" %>
<%@ page import="com.bookstore.model.Order" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - Online Bookstore</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="<%= request.getContextPath() %>/css/style.css" rel="stylesheet">
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container">
            <a class="navbar-brand fw-bold" href="<%= request.getContextPath() %>/">
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
                    <!-- Removed Featured navigation link -->
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/books/bestsellers">Bestsellers</a>
                    </li>
                </ul>
                
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/cart">
                            <i class="fas fa-shopping-cart"></i> Cart
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="<%= request.getContextPath() %>/user/profile">
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
            <!-- Sidebar -->
            <div class="col-md-3">
                <div class="card">
                    <div class="card-header bg-primary text-white">
                        <h5 class="mb-0"><i class="fas fa-user-circle"></i> My Account</h5>
                    </div>
                    <div class="list-group list-group-flush">
                        <a href="#profile-info" class="list-group-item list-group-item-action active" data-bs-toggle="pill">
                            <i class="fas fa-user"></i> Profile Information
                        </a>
                        <a href="#order-history" class="list-group-item list-group-item-action" data-bs-toggle="pill">
                            <i class="fas fa-shopping-bag"></i> Order History
                        </a>
                        <a href="#change-password" class="list-group-item list-group-item-action" data-bs-toggle="pill">
                            <i class="fas fa-lock"></i> Change Password
                        </a>
                        <a href="#wishlist" class="list-group-item list-group-item-action" data-bs-toggle="pill">
                            <i class="fas fa-heart"></i> Wishlist
                        </a>
                    </div>
                </div>
            </div>
            
            <!-- Main Content -->
            <div class="col-md-9">
                <div class="tab-content">
                    <!-- Profile Information -->
                    <div class="tab-pane fade show active" id="profile-info">
                        <div class="card">
                            <div class="card-header">
                                <h4><i class="fas fa-user"></i> Profile Information</h4>
                            </div>
                            <div class="card-body">
                                <% if (request.getAttribute("success") != null) { %>
                                    <div class="alert alert-success" role="alert">
                                        <i class="fas fa-check-circle"></i> <%= request.getAttribute("success") %>
                                    </div>
                                <% } %>
                                
                                <% if (request.getAttribute("error") != null) { %>
                                    <div class="alert alert-danger" role="alert">
                                        <i class="fas fa-exclamation-triangle"></i> <%= request.getAttribute("error") %>
                                    </div>
                                <% } %>
                                
                                <% 
                                User user = (User) session.getAttribute("user");
                                if (user != null) {
                                %>
                                    <form action="<%= request.getContextPath() %>/user/update-profile" method="post">
                                        <div class="row">
                                            <div class="col-md-6">
                                                <div class="mb-3">
                                                    <label for="name" class="form-label">Full Name</label>
                                                    <input type="text" class="form-control" id="name" name="name" 
                                                           value="<%= user.getName() %>" required>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="mb-3">
                                                    <label for="email" class="form-label">Email Address</label>
                                                    <input type="email" class="form-control" id="email" 
                                                           value="<%= user.getEmail() %>" readonly>
                                                    <div class="form-text">Email cannot be changed</div>
                                                </div>
                                            </div>
                                        </div>
                                        
                                        <div class="mb-3">
                                            <label for="phone" class="form-label">Phone Number</label>
                                            <input type="tel" class="form-control" id="phone" name="phone" 
                                                   value="<%= user.getPhone() != null ? user.getPhone() : "" %>">
                                        </div>
                                        
                                        <div class="mb-3">
                                            <label for="address" class="form-label">Address</label>
                                            <textarea class="form-control" id="address" name="address" rows="3"><%= user.getAddress() != null ? user.getAddress() : "" %></textarea>
                                        </div>
                                        
                                        <div class="row">
                                            <div class="col-md-4">
                                                <div class="mb-3">
                                                    <label for="city" class="form-label">City</label>
                                                    <input type="text" class="form-control" id="city" name="city" 
                                                           value="<%= user.getCity() != null ? user.getCity() : "" %>">
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="mb-3">
                                                    <label for="state" class="form-label">State</label>
                                                    <input type="text" class="form-control" id="state" name="state" 
                                                           value="<%= user.getState() != null ? user.getState() : "" %>">
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="mb-3">
                                                    <label for="zipCode" class="form-label">ZIP Code</label>
                                                    <input type="text" class="form-control" id="zipCode" name="zipCode" 
                                                           value="<%= user.getZipCode() != null ? user.getZipCode() : "" %>">
                                                </div>
                                            </div>
                                        </div>
                                        
                                        <button type="submit" class="btn btn-primary">
                                            <i class="fas fa-save"></i> Update Profile
                                        </button>
                                    </form>
                                <% } %>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Order History -->
                    <div class="tab-pane fade" id="order-history">
                        <div class="card">
                            <div class="card-header">
                                <h4><i class="fas fa-shopping-bag"></i> Order History</h4>
                            </div>
                            <div class="card-body">
                                <!-- Added dynamic order history display -->
                                <% 
                                List<Order> userOrders = (List<Order>) request.getAttribute("userOrders");
                                if (userOrders != null && !userOrders.isEmpty()) {
                                %>
                                    <div class="table-responsive">
                                        <table class="table table-striped">
                                            <thead>
                                                <tr>
                                                    <th>Order ID</th>
                                                    <th>Date</th>
                                                    <th>Total</th>
                                                    <th>Status</th>
                                                    <th>Payment</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <% for (Order order : userOrders) { %>
                                                    <tr>
                                                        <td>#<%= order.getOrderId() %></td>
                                                        <td><%= order.getOrderDate() %></td>
                                                        <td>₹<%= order.getTotalAmount() %></td>
                                                        <td>
                                                            <span class="badge bg-success">
                                                                <%= order.getOrderStatus().toUpperCase() %>
                                                            </span>
                                                        </td>
                                                        <td>
                                                            <span class="badge bg-primary">
                                                                <%= order.getPaymentStatus().toUpperCase() %>
                                                            </span>
                                                        </td>
                                                    </tr>
                                                <% } %>
                                            </tbody>
                                        </table>
                                    </div>
                                <% } else { %>
                                    <div class="text-center py-5">
                                        <i class="fas fa-shopping-bag fa-3x text-muted mb-3"></i>
                                        <h5>No orders yet</h5>
                                        <p class="text-muted">Start shopping to see your order history here.</p>
                                        <a href="<%= request.getContextPath() %>/books/catalog" class="btn btn-primary">
                                            <i class="fas fa-book"></i> Browse Books
                                        </a>
                                    </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Change Password -->
                    <div class="tab-pane fade" id="change-password">
                        <div class="card">
                            <div class="card-header">
                                <h4><i class="fas fa-lock"></i> Change Password</h4>
                            </div>
                            <div class="card-body">
                                <form action="<%= request.getContextPath() %>/user/change-password" method="post">
                                    <div class="mb-3">
                                        <label for="currentPassword" class="form-label">Current Password</label>
                                        <input type="password" class="form-control" id="currentPassword" name="currentPassword" required>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label for="newPassword" class="form-label">New Password</label>
                                        <input type="password" class="form-control" id="newPassword" name="newPassword" 
                                               minlength="6" required>
                                        <div class="form-text">Minimum 6 characters</div>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label for="confirmPassword" class="form-label">Confirm New Password</label>
                                        <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" 
                                               minlength="6" required>
                                    </div>
                                    
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-key"></i> Change Password
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Wishlist -->
                    <div class="tab-pane fade" id="wishlist">
                        <div class="card">
                            <div class="card-header">
                                <h4><i class="fas fa-heart"></i> My Wishlist</h4>
                            </div>
                            <div class="card-body">
                                <div class="text-center py-5">
                                    <i class="fas fa-heart fa-3x text-muted mb-3"></i>
                                    <h5>Your wishlist is empty</h5>
                                    <p class="text-muted">Save books you're interested in to your wishlist.</p>
                                    <a href="<%= request.getContextPath() %>/books/catalog" class="btn btn-primary">
                                        <i class="fas fa-book"></i> Browse Books
                                    </a>
                                </div>
                            </div>
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
        // Password confirmation validation
        document.getElementById('confirmPassword').addEventListener('input', function() {
            const newPassword = document.getElementById('newPassword').value;
            const confirmPassword = this.value;
            
            if (newPassword !== confirmPassword) {
                this.setCustomValidity('Passwords do not match');
            } else {
                this.setCustomValidity('');
            }
        });
        
        document.addEventListener('DOMContentLoaded', function() {
            // Check if we should show order history tab
            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.get('tab') === 'order-history') {
                // Switch to order history tab
                const orderHistoryTab = document.querySelector('a[href="#order-history"]');
                const orderHistoryPane = document.querySelector('#order-history');
                
                // Remove active from current tab
                document.querySelector('.list-group-item-action.active').classList.remove('active');
                document.querySelector('.tab-pane.show.active').classList.remove('show', 'active');
                
                // Activate order history tab
                orderHistoryTab.classList.add('active');
                orderHistoryPane.classList.add('show', 'active');
            }
        });
    </script>
</body>
</html>
