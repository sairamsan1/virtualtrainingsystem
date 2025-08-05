package com.project;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;

@WebServlet("/ToggleUserStatusServlet")
public class ToggleUserStatusServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String userId = request.getParameter("userId");

        try (Connection conn = DBConnection.getConnection()) {
            // Step 1: Get current status safely
            String sql = "SELECT status FROM users WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, userId);
            ResultSet rs = ps.executeQuery();

            String status = "active"; // Default fallback

            if (rs.next()) {
                status = rs.getString("status");
                if (status == null) {
                    status = "active"; // fallback if DB has null
                }
            }

            // Step 2: Toggle status
            String newStatus = "active".equals(status) ? "inactive" : "active";

            sql = "UPDATE users SET status = ? WHERE id = ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, newStatus);
            ps.setString(2, userId);
            ps.executeUpdate();

            response.sendRedirect("manage_users.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("manage_users.jsp?msg=error");
        }
    }
}
