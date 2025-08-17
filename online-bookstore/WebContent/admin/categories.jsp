<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%-- Removed JSTL taglib and replaced with standard JSP --%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Categories - BookHaven Admin</title>
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
                            <a class="nav-link active" href="<%=request.getContextPath()%>/admin/categories">Categories</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="<%=request.getContextPath()%>/admin/orders">Orders</a>
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
                <h1 class="h2">Manage Categories</h1>
                
                <%-- Replaced JSTL conditionals with JSP scriptlets --%>
                <% if (request.getAttribute("success") != null) { %>
                    <div class="alert alert-success"><%=request.getAttribute("success")%></div>
                <% } %>
                <% if (request.getAttribute("error") != null) { %>
                    <div class="alert alert-danger"><%=request.getAttribute("error")%></div>
                <% } %>

                <!-- Add Category Form -->
                <div class="card mb-4">
                    <div class="card-header">Add New Category</div>
                    <div class="card-body">
                        <form method="post" action="<%=request.getContextPath()%>/admin/add-category">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="categoryName" class="form-label">Category Name *</label>
                                        <input type="text" class="form-control" id="categoryName" name="categoryName" required>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="description" class="form-label">Description</label>
                                        <input type="text" class="form-control" id="description" name="description">
                                    </div>
                                </div>
                            </div>
                            <button type="submit" class="btn btn-primary">Add Category</button>
                        </form>
                    </div>
                </div>

                <!-- Categories List -->
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Description</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%-- Replaced JSTL forEach with JSP scriptlet --%>
                            <%
                                java.util.List categories = (java.util.List) request.getAttribute("categories");
                                if (categories != null) {
                                    for (Object obj : categories) {
                                        com.bookstore.model.Category category = (com.bookstore.model.Category) obj;
                            %>
                                <tr>
                                    <td><%=category.getCategoryId()%></td>
                                    <td><%=category.getCategoryName()%></td>
                                    <td><%=category.getDescription()%></td>
                                    <td>
                                        <form method="post" action="<%=request.getContextPath()%>/admin/delete-category" style="display:inline;">
                                            <input type="hidden" name="categoryId" value="<%=category.getCategoryId()%>">
                                            <button type="submit" class="btn btn-sm btn-outline-danger" onclick="return confirm('Are you sure?')">Delete</button>
                                        </form>
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
