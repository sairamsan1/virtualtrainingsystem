package com.project;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/AssignTaskServlet")
public class AssignTaskServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get parameters from form
        int trainingId = Integer.parseInt(request.getParameter("training_id"));
        int studentId = Integer.parseInt(request.getParameter("student_id"));
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String dueDate = request.getParameter("due_date");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "INSERT INTO tasks (title, description, due_date, student_id, training_id, is_completed, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, NOW())")) {

            ps.setString(1, title);
            ps.setString(2, description);
            ps.setDate(3, Date.valueOf(dueDate));
            ps.setInt(4, studentId);
            ps.setInt(5, trainingId);
            ps.setBoolean(6, false);  // is_completed = false initially

            ps.executeUpdate();

            // Redirect with success message
            response.sendRedirect("trainer_dashboard.jsp?msg=TaskAssignedSuccessfully");

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html");
            response.getWriter().println("<h3 style='color:red'>Error assigning task: " + e.getMessage() + "</h3>");
        }
    }
}