package com.project;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;

@WebServlet("/adminStats")
public class AdminStatsServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int studentCount = 0;
        int trainingCount = 0;
        int enrollmentCount = 0;

        try (Connection conn = DBConnection.getConnection()) {
            Statement stmt = conn.createStatement();

            ResultSet rs1 = stmt.executeQuery("SELECT COUNT(*) FROM users WHERE role = 'student'");
            if (rs1.next()) studentCount = rs1.getInt(1);

            ResultSet rs2 = stmt.executeQuery("SELECT COUNT(*) FROM trainings");
            if (rs2.next()) trainingCount = rs2.getInt(1);

            ResultSet rs3 = stmt.executeQuery("SELECT COUNT(*) FROM enrollments");
            if (rs3.next()) enrollmentCount = rs3.getInt(1);

            request.setAttribute("studentCount", studentCount);
            request.setAttribute("trainingCount", trainingCount);
            request.setAttribute("enrollmentCount", enrollmentCount);

            RequestDispatcher dispatcher = request.getRequestDispatcher("admin_dashboard.jsp");
            dispatcher.forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin_dashboard.jsp?msg=error");
        }
    }
}
