<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.bookstore.model.Book" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Books - BookHaven Admin</title>
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
                <h1 class="h2">Manage Books</h1>
                
                <!-- Replaced JSTL with standard JSP scriptlets for success/error messages -->
                <% String success = (String) request.getAttribute("success"); %>
                <% if (success != null) { %>
                    <div class="alert alert-success"><%=success%></div>
                <% } %>
                
                <% String error = (String) request.getAttribute("error"); %>
                <% if (error != null) { %>
                    <div class="alert alert-danger"><%=error%></div>
                <% } %>

                <div class="mb-3">
                    <a href="<%=request.getContextPath()%>/admin/add-book" class="btn btn-primary">Add New Book</a>
                </div>

                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Title</th>
                                <th>Author</th>
                                <th>Price</th>
                                <th>Stock</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- Replaced JSTL forEach with standard JSP scriptlet for book iteration -->
                            <% 
                            List<Book> books = (List<Book>) request.getAttribute("books");
                            if (books != null) {
                                for (Book book : books) {
                            %>
                                <tr>
                                    <td><%=book.getBookId()%></td>
                                    <td><%=book.getTitle()%></td>
                                    <td><%=book.getAuthor()%></td>
                                    <td>₹<%=String.format("%.2f", book.getPrice())%></td>
                                    
                                    <td>
                                        <a href="<%=request.getContextPath()%>/admin/edit-book?id=<%=book.getBookId()%>" class="btn btn-sm btn-outline-primary">Edit</a>
                                        <form method="post" action="<%=request.getContextPath()%>/admin/delete-book" style="display:inline;">
                                            <input type="hidden" name="bookId" value="<%=book.getBookId()%>">
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
