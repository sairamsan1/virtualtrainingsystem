package com.project;

import java.io.IOException;
import java.sql.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/editTraining")
public class EditTrainingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String trainingId = request.getParameter("id");
        if (trainingId == null || trainingId.trim().isEmpty()) {
            response.sendRedirect("admin_dashboard.jsp?msg=invalid_id");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT * FROM trainings WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, Integer.parseInt(trainingId));
                ResultSet rs = stmt.executeQuery();

                if (rs.next()) {
                    request.setAttribute("id", rs.getInt("id"));
                    request.setAttribute("title", rs.getString("title"));
                    request.setAttribute("instructor", rs.getString("instructor"));
                    request.setAttribute("duration", rs.getString("duration"));

                    request.getRequestDispatcher("edit_training.jsp").forward(request, response);
                } else {
                    response.sendRedirect("admin_dashboard.jsp?msg=not_found");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("admin_dashboard.jsp?msg=error");
        }
    }
}