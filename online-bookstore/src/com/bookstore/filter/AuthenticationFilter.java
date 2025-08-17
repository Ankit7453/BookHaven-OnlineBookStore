package com.bookstore.filter;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Filter to protect user-only pages
 */
@WebFilter(urlPatterns = {"/cart/*", "/orders/*", "/user/profile", "/checkout/*"})
public class AuthenticationFilter implements Filter {
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization code if needed
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) 
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);
        
        boolean isLoggedIn = (session != null && session.getAttribute("user") != null);
        
        if (isLoggedIn) {
            chain.doFilter(request, response);
        } else {
            // Store the requested URL for redirect after login
            String requestedUrl = httpRequest.getRequestURL().toString();
            String queryString = httpRequest.getQueryString();
            if (queryString != null) {
                requestedUrl += "?" + queryString;
            }
            
            HttpSession newSession = httpRequest.getSession();
            newSession.setAttribute("redirectUrl", requestedUrl);
            
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/user/login");
        }
    }
    
    @Override
    public void destroy() {
        // Cleanup code if needed
    }
}
