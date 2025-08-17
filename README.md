# BookHaven - Online Book Store Application

## Project Overview

BookHaven is a comprehensive online bookstore application built using Java Enterprise technologies. It provides a complete e-commerce solution for book sales with separate interfaces for customers and administrators. The application features user authentication, book catalog management, shopping cart functionality, order processing, and administrative controls.

### Key Features

**Customer Features:**
- User registration and authentication
- Browse books by categories
- Advanced search with filters (title, author, category, price range)
- Shopping cart management
- Secure checkout process
- Order history and tracking(in furure improvements)
- User profile management
- Book reviews and ratings(future improvements)

**Admin Features:**
- Admin authentication and dashboard
- Complete book management (CRUD operations)
- Category management
- Order management and status updates
- User account management
- Sales statistics and reporting

## Technology Stack

- **Frontend:** HTML5, CSS3, JavaScript, Bootstrap 5, JSP
- **Backend:** Java Servlets, JDBC
- **Database:** MySQL 8.0+
- **Server:** Apache Tomcat 9.0+
- **IDE:** Eclipse IDE for Enterprise Java Developers

## System Requirements

### Software Requirements
- **Java Development Kit (JDK):** 11 or higher
- **Apache Tomcat:** 9.0 or higher
- **MySQL Server:** 8.0 or higher
- **Eclipse IDE:** 2021-06 or higher (Enterprise Java Developers edition)
- **Web Browser:** Chrome, Firefox, Safari, or Edge (latest versions)

### Hardware Requirements
- **RAM:** Minimum 4GB (8GB recommended)
- **Storage:** 2GB free space
- **Processor:** Intel i3 or equivalent

## Project Structure

\`\`\`
online-bookstore/
├── src/
│   └── com/
│       └── bookstore/
│           ├── controller/          # Servlet controllers
│           │   ├── AdminController.java
│           │   ├── BookController.java
│           │   ├── CartController.java
│           │   ├── OrderController.java
│           │   └── UserController.java
│           ├── dao/                 # Data Access Objects
│           │   ├── AdminDAO.java
│           │   ├── BookDAO.java
│           │   ├── CartDAO.java
│           │   ├── CategoryDAO.java
│           │   ├── OrderDAO.java
│           │   └── UserDAO.java
│           ├── filter/              # Authentication filters
│           │   ├── AdminAuthenticationFilter.java
│           │   └── AuthenticationFilter.java
│           ├── model/               # Entity classes (POJOs)
│           │   ├── Admin.java
│           │   ├── Book.java
│           │   ├── CartItem.java
│           │   ├── Category.java
│           │   ├── Order.java
│           │   ├── OrderItem.java
│           │   └── User.java
│           └── util/                # Utility classes
│               ├── DatabaseConnection.java
│               ├── PasswordUtil.java
│               └── ServletContextListener.java
├── WebContent/
│   ├── WEB-INF/
│   │   └── web.xml                  # Deployment descriptor
│   ├── admin/                       # Admin JSP pages
│   │   ├── dashboard.jsp
│   │   └── login.jsp
│   ├── css/                         # Stylesheets
│   │   ├── admin.css
│   │   └── style.css
│   ├── js/                          # JavaScript files
│   │   └── main.js
│   ├── images/                      # Book cover images (JPEG format)
│   ├── book-details.jsp
│   ├── cart.jsp
│   ├── catalog.jsp
│   ├── index.html
│   ├── login.jsp
│   ├── profile.jsp
│   └── register.jsp
└── scripts/                         # Database scripts
    ├── 01_create_database.sql
    ├── 02_create_tables.sql
    ├── 03_insert_sample_data.sql
    └── 04_create_indexes_and_triggers.sql
\`\`\`

## Setup Instructions

### 3. Project Setup

1. **Create Dynamic Web Project**
   \`\`\`
   File → New → Dynamic Web Project
   Project Name: online-bookstore
   Target Runtime: Apache Tomcat v9.0
   Dynamic Web Module Version: 4.0
   \`\`\`

2. **Import Project Files**
   - Copy all source files to respective directories
   - Ensure proper package structure in src folder
   - Place JSP files in WebContent directory
   - Add CSS/JS files to respective folders

3. **Database Setup**
   - Open MySQL Workbench or command line
   - Execute SQL scripts in order:
     \`\`\`sql
     source scripts/01_create_database.sql
     source scripts/02_create_tables.sql
     source scripts/03_insert_sample_data.sql
     source scripts/04_create_indexes_and_triggers.sql
     \`\`\`

4. **Configure Database Connection**
     Go to Deployment descriptor(web.xml) file and make following changes
      <context-param>
        <param-name>db.password</param-name>
        <param-value>your_password </param-value>   <-------Your Password------>
    </context-param>

### 4. Running the Application

1. **Deploy to Tomcat**
   - Right-click project → Run As → Run on Server
   - Select Tomcat server and click "Finish"

3. **Default Admin Credentials**
   - Username: admin@bookstore.com
   - Password: admin123

### Tables Created
- users (customer accounts)
- admins (administrator accounts)
- categories (book categories)
- books (book catalog)
- cart (shopping cart items)
- orders (customer orders)
- order_items (order details)
- reviews (book reviews)
- wishlist (saved books)

## Testing the Application

### Customer Workflow
1. Register new account or login
2. Browse books by category
3. Search for specific books
4. Add books to cart
5. Proceed to checkout
6. View order history

### Admin Workflow
1. Login with admin credentials
2. Manage book inventory
3. Process customer orders
4. View sales statistics
5. Manage user accounts

## License
This project is developed for educational purposes.

---
**Made by ANKIT RAWAT**
