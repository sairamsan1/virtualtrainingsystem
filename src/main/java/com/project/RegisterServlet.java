package com.project;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role");

        // Read specialization only if trainer
        String specialization = null;
        if ("trainer".equalsIgnoreCase(role)) {
            specialization = request.getParameter("specialization");
        }

        try (Connection conn = DBConnection.getConnection()) {

            // Check if email already exists
            PreparedStatement checkStmt = conn.prepareStatement("SELECT id FROM users WHERE email = ?");
            checkStmt.setString(1, email);
            ResultSet rs = checkStmt.executeQuery();

            if (rs.next()) {
                // Email already exists
                request.setAttribute("error", "Email is already registered.");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            // Insert new user depending on role
            PreparedStatement stmt;
            if ("trainer".equalsIgnoreCase(role)) {
                stmt = conn.prepareStatement(
                    "INSERT INTO users (name, email, password, role, active, specialization) VALUES (?, ?, ?, ?, 1, ?)");
                stmt.setString(1, name);
                stmt.setString(2, email);
                stmt.setString(3, password);
                stmt.setString(4, role);
                stmt.setString(5, specialization);
            } else {
                stmt = conn.prepareStatement(
                    "INSERT INTO users (name, email, password, role, active) VALUES (?, ?, ?, ?, 1)");
                stmt.setString(1, name);
                stmt.setString(2, email);
                stmt.setString(3, password);
                stmt.setString(4, role);
            }

            int rows = stmt.executeUpdate();
            if (rows > 0) {
                response.sendRedirect("login.jsp?msg=registered");
            } else {
                request.setAttribute("error", "Registration failed. Try again.");
                request.getRequestDispatcher("register.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Server error occurred.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
}