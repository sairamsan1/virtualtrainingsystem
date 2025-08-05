package com.project;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/UpdateTrainingServlet")
public class UpdateTrainingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String idParam = request.getParameter("id");
        String title = request.getParameter("title") != null ? request.getParameter("title").trim() : "";
        String description = request.getParameter("description") != null ? request.getParameter("description").trim() : "";
        String instructor = request.getParameter("instructor") != null ? request.getParameter("instructor").trim() : "";
        String duration = request.getParameter("duration") != null ? request.getParameter("duration").trim() : "";
        String trainerIdStr = request.getParameter("trainer_id");

        // Validate required fields
        if (idParam == null || idParam.trim().isEmpty() ||
            title.isEmpty() || instructor.isEmpty() || duration.isEmpty() ||
            trainerIdStr == null || trainerIdStr.trim().isEmpty()) {
            response.sendRedirect("edit_training.jsp?id=" + idParam + "&msg=missing_fields");
            return;
        }

        try {
            int id = Integer.parseInt(idParam.trim());
            int trainerId = Integer.parseInt(trainerIdStr.trim());

            try (Connection conn = DBConnection.getConnection()) {
                String sql = "UPDATE trainings SET title=?, description=?, instructor=?, duration=?, trainer_id=? WHERE id=?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, title);
                    ps.setString(2, description);
                    ps.setString(3, instructor);
                    ps.setString(4, duration);
                    ps.setInt(5, trainerId);
                    ps.setInt(6, id);

                    int rows = ps.executeUpdate();
                    if (rows > 0) {
                        response.sendRedirect("admin_dashboard.jsp?msg=updated");
                    } else {
                        response.sendRedirect("edit_training.jsp?id=" + id + "&msg=not_found");
                    }
                }
            }
        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect("edit_training.jsp?id=" + idParam + "&msg=invalid_id_or_trainer");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("edit_training.jsp?id=" + idParam + "&msg=error");
        }
    }
}