<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%-- Removed JSTL taglibs and replaced with standard JSP --%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Orders - BookHaven Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/admin.css" rel="stylesheet">
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <nav class="col-md-2 d-none d-md-block bg-light sidebar">
                <div class="sidebar-sticky">
                    <ul class="nav flex-column">
                        <li class="nav-item">
                            <a class="nav-link" href="<%=request.getContextPath()%>/admin/dashboard">Dashboard</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="<%=request.getContextPath()%>/admin/books">Books</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="<%=request.getContextPath()%>/admin/categories">Categories</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link active" href="<%=request.getContextPath()%>/admin/orders">Orders</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="<%=request.getContextPath()%>/admin/users">Users</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="<%=request.getContextPath()%>/admin/logout">Logout</a>
                        </li>
                    </ul>
                </div>
            </nav>

            <main role="main" class="col-md-9 ml-sm-auto col-lg-10 px-4">
                <h1 class="h2">Manage Orders</h1>
                
                <%-- Replaced JSTL conditionals with JSP scriptlets --%>
                <% if (request.getAttribute("success") != null) { %>
                    <div class="alert alert-success"><%=request.getAttribute("success")%></div>
                <% } %>
                <% if (request.getAttribute("error") != null) { %>
                    <div class="alert alert-danger"><%=request.getAttribute("error")%></div>
                <% } %>

                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>Order ID</th>
                                <th>User ID</th>
                                <th>Date</th>
                                <th>Total</th>
                                <th>Status</th>
                                <th>Payment</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%-- Replaced JSTL forEach with JSP scriptlet --%>
                            <%
                                java.util.List orders = (java.util.List) request.getAttribute("orders");
                                if (orders != null) {
                                    for (Object obj : orders) {
                                        com.bookstore.model.Order order = (com.bookstore.model.Order) obj;
                                        String statusClass = "confirmed".equals(order.getOrderStatus()) ? "success" : 
                                                           "pending".equals(order.getOrderStatus()) ? "warning" : "secondary";
                                        String paymentClass = "paid".equals(order.getPaymentStatus()) ? "success" : "warning";
                            %>
                                <tr>
                                    <td>#<%=order.getOrderId()%></td>
                                    <td><%=order.getUserId()%></td>
                                    <td><%=order.getOrderDate()%></td>
                                    <td>₹<%=String.format("%.2f", order.getTotalAmount())%></td>
                                    <td>
                                        <span class="badge bg-<%=statusClass%>">
                                            <%=order.getOrderStatus()%>
                                        </span>
                                    </td>
                                    <td>
                                        <span class="badge bg-<%=paymentClass%>">
                                            <%=order.getPaymentStatus()%>
                                        </span>
                                    </td>
                                    <td>
                                        <a href="<%=request.getContextPath()%>/admin/order-details?id=<%=order.getOrderId()%>" class="btn btn-sm btn-outline-primary">View</a>
                                    </td>
                                </tr>
                            <%
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </main>
        </div>
    </div>
</body>
</html>
