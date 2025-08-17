package com.bookstore.util;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

/**
 * Application lifecycle listener for initialization
 */
@WebListener
public class BookstoreContextListener implements ServletContextListener {
    
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // Initialize database connection
        DatabaseConnection.getInstance().initialize(sce.getServletContext());
        System.out.println("Bookstore application initialized successfully");
    }
    
    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("Bookstore application destroyed");
    }
}
