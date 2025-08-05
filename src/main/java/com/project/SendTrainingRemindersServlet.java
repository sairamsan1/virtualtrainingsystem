package com.project;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;

/**
 * Sends training reminder emails to students whose trainings start the next day.
 */
@WebServlet("/SendTrainingReminders")
public class SendTrainingRemindersServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int count = 0;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT u.email, u.full_name, t.title, t.start_date " +
                 "FROM enrollments e " +
                 "JOIN users u ON e.student_id = u.id " +
                 "JOIN trainings t ON e.training_id = t.id " +
                 "WHERE DATE(t.start_date) = CURDATE() + INTERVAL 1 DAY")) {

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                String email = rs.getString("email");
                String name = rs.getString("full_name");
                String title = rs.getString("title");
                String date = rs.getString("start_date");

                String subject = "📢 Training Reminder: " + title;
                String message = "Hi " + name + ",\n\n" +
                        "This is a reminder that your training \"" + title + "\" is scheduled for " + date + ".\n" +
                        "Please be prepared and make sure you attend on time.\n\n" +
                        "Best Regards,\nVirtual Training System";

                try {
                    EmailUtility.sendEmail(email, subject, message);
                    count++;
                } catch (Exception ex) {
                    System.err.println("Failed to send reminder to: " + email);
                    ex.printStackTrace();
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        response.setContentType("text/html");
        response.getWriter().write("<h3>Training reminders sent to " + count + " students!</h3>");
    }
}
