package com.bookstore.filter;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Filter to protect admin-only pages
 */
@WebFilter(
    urlPatterns = {"/admin/*"},
    dispatcherTypes = {DispatcherType.REQUEST, DispatcherType.ERROR} // Avoid FORWARD filtering
)
public class AdminAuthenticationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization if needed
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest  = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String requestURI  = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();

        // Paths that don't require authentication
        boolean isLoginPage   = requestURI.endsWith("/admin/login");
        boolean isLoginJsp    = requestURI.endsWith("/admin/login.jsp");
        boolean isLoginAction = "POST".equalsIgnoreCase(httpRequest.getMethod())
                && "login".equalsIgnoreCase(httpRequest.getParameter("action"));

        if (isLoginPage || isLoginJsp || isLoginAction) {
            chain.doFilter(request, response); // Allow
            return;
        }

        // Check session for admin
        HttpSession session = httpRequest.getSession(false);
        boolean isAdminLoggedIn = (session != null && session.getAttribute("admin") != null);

        if (isAdminLoggedIn) {
            chain.doFilter(request, response); // Allow
        } else {
            httpResponse.sendRedirect(contextPath + "/admin/login");
        }
    }

    @Override
    public void destroy() {
        // Cleanup if needed
    }
}