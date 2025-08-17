<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%-- Removed JSTL taglib and replaced with standard JSP --%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Book - BookHaven Admin</title>
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
                            <a class="nav-link active" href="<%=request.getContextPath()%>/admin/books">Books</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="<%=request.getContextPath()%>/admin/categories">Categories</a>
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
                <h1 class="h2">Add New Book</h1>
                
                <%-- Replaced JSTL conditionals with JSP scriptlets --%>
                <% if (request.getAttribute("success") != null) { %>
                    <div class="alert alert-success"><%=request.getAttribute("success")%></div>
                <% } %>
                <% if (request.getAttribute("error") != null) { %>
                    <div class="alert alert-danger"><%=request.getAttribute("error")%></div>
                <% } %>

                <form method="post" action="<%=request.getContextPath()%>/admin/add-book">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="title" class="form-label">Title *</label>
                                <input type="text" class="form-control" id="title" name="title" required>
                            </div>
                            <div class="mb-3">
                                <label for="author" class="form-label">Author *</label>
                                <input type="text" class="form-control" id="author" name="author" required>
                            </div>
                            <div class="mb-3">
                                <label for="isbn" class="form-label">ISBN</label>
                                <input type="text" class="form-control" id="isbn" name="isbn">
                            </div>
                            <div class="mb-3">
                                <label for="price" class="form-label">Price (₹) *</label>
                                <input type="number" step="0.01" class="form-control" id="price" name="price" required>
                            </div>
                            <div class="mb-3">
                                <label for="stock" class="form-label">Stock</label>
                                <input type="number" class="form-control" id="stock" name="stock" value="0">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="categoryId" class="form-label">Category</label>
                                <select class="form-control" id="categoryId" name="categoryId">
                                    <%-- Replaced JSTL forEach with JSP scriptlet --%>
                                    <%
                                        java.util.List categories = (java.util.List) request.getAttribute("categories");
                                        if (categories != null) {
                                            for (Object obj : categories) {
                                                com.bookstore.model.Category category = (com.bookstore.model.Category) obj;
                                    %>
                                        <option value="<%=category.getCategoryId()%>"><%=category.getCategoryName()%></option>
                                    <%
                                            }
                                        }
                                    %>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label for="publisher" class="form-label">Publisher</label>
                                <input type="text" class="form-control" id="publisher" name="publisher">
                            </div>
                            <div class="mb-3">
                                <label for="coverImage" class="form-label">Cover Image (filename)</label>
                                <input type="text" class="form-control" id="coverImage" name="coverImage" placeholder="e.g., book_title.jpeg">
                            </div>
                            <div class="mb-3">
                                <label for="pages" class="form-label">Pages</label>
                                <input type="number" class="form-control" id="pages" name="pages">
                            </div>
                            <div class="mb-3">
                                <label for="language" class="form-label">Language</label>
                                <input type="text" class="form-control" id="language" name="language" value="English">
                            </div>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label for="description" class="form-label">Description</label>
                        <textarea class="form-control" id="description" name="description" rows="4"></textarea>
                    </div>
                    <div class="mb-3">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="bestseller" name="bestseller">
                            <label class="form-check-label" for="bestseller">Bestseller</label>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary">Add Book</button>
                    <a href="<%=request.getContextPath()%>/admin/books" class="btn btn-secondary">Cancel</a>
                </form>
            </main>
        </div>
    </div>
</body>
</html>
