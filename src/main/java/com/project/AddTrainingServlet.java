// File: src/main/java/com/project/AddTrainingServlet.java
package com.project;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/addTraining")
public class AddTrainingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String title = request.getParameter("title") != null ? request.getParameter("title").trim() : "";
        String duration = request.getParameter("duration") != null ? request.getParameter("duration").trim() : "";
        String trainerIdParam = request.getParameter("trainer_id");

        // Input validation
        if (title.isEmpty() ||  duration.isEmpty() || trainerIdParam == null || trainerIdParam.isEmpty()) {
            response.sendRedirect("add_training.jsp?msg=invalid_input");
            return;
        }

        try {
            int trainerId = Integer.parseInt(trainerIdParam);

            try (Connection conn = DBConnection.getConnection()) {
                String sql = "INSERT INTO trainings (title, instructor, duration, trainer_id) VALUES (?,  ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, title);
                    ps.setString(3, duration);
                    ps.setInt(4, trainerId);

                    int rowsInserted = ps.executeUpdate();
                    if (rowsInserted > 0) {
                        response.sendRedirect("add_training.jsp?msg=added");
                    } else {
                        response.sendRedirect("add_training.jsp?msg=error");
                    }
                }
            }
        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect("add_training.jsp?msg=invalid_input");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("add_training.jsp?msg=error");
        }
    }
}