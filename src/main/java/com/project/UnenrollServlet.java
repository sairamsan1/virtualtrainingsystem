package com.project;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/UnenrollServlet")
public class UnenrollServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("email") == null) {
            response.sendRedirect("login.jsp?msg=session_expired");
            return;
        }

        String email = (String) session.getAttribute("email");
        String trainingIdParam = request.getParameter("trainingId");

        if (trainingIdParam == null || trainingIdParam.isEmpty()) {
            response.sendRedirect("enrollment_overview.jsp?msg=invalid_id");
            return;
        }

        int trainingId = Integer.parseInt(trainingIdParam);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "DELETE FROM enrollments WHERE training_id = ? AND student_email = ?")) {

            ps.setInt(1, trainingId);
            ps.setString(2, email);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                response.sendRedirect("enrollment_overview.jsp?msg=unenrolled");
            } else {
                response.sendRedirect("enrollment_overview.jsp?msg=notfound");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("enrollment_overview.jsp?msg=error");
        }
    }
}