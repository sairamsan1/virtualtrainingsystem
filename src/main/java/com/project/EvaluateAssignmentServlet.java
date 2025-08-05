package com.project;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/EvaluateAssignmentServlet")
public class EvaluateAssignmentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String email = (String) session.getAttribute("email");
        String role = (String) session.getAttribute("role");

        if (email == null || !"trainer".equals(role)) {
            response.sendRedirect("login.jsp?msg=unauthorized");
            return;
        }

        int assignmentId = Integer.parseInt(request.getParameter("assignment_id"));
        int marks = Integer.parseInt(request.getParameter("marks"));
        String comments = request.getParameter("comments");

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            String query = "UPDATE assignments SET marks = ?, comments = ? WHERE id = ?";
            ps = conn.prepareStatement(query);
            ps.setInt(1, marks);
            ps.setString(2, comments);
            ps.setInt(3, assignmentId);

            int rowsUpdated = ps.executeUpdate();
            if (rowsUpdated > 0) {
                response.sendRedirect("trainer_dashboard.jsp?msg=evaluation_success");
            } else {
                response.sendRedirect("trainer_dashboard.jsp?msg=evaluation_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("trainer_dashboard.jsp?msg=error");
        } finally {
            try {
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
    }
}