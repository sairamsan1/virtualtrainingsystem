package com.project;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
@WebServlet("/enroll") 
public class EnrollServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    HttpSession session = request.getSession(false);
    String email = (session != null) ? (String) session.getAttribute("email") : null;
    String role = (session != null) ? (String) session.getAttribute("role") : null;

    if (email == null || !"student".equals(role)) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }

    int trainingId = Integer.parseInt(request.getParameter("trainingId"));

    try (Connection conn = DBConnection.getConnection()) {

        // Check if already enrolled
        String checkQuery = "SELECT COUNT(*) FROM enrollments WHERE email = ? AND training_id = ?";
        try (PreparedStatement checkStmt = conn.prepareStatement(checkQuery)) {
            checkStmt.setString(1, email);
            checkStmt.setInt(2, trainingId);

            ResultSet rs = checkStmt.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                response.sendRedirect("available_coureses.jsp?msg=already_enrolled");
                return;
            }
        }

        // Insert new enrollment
        String enrollQuery = "INSERT INTO enrollments (email, training_id, enrolled_at) VALUES (?, ?, NOW())";
        try (PreparedStatement ps = conn.prepareStatement(enrollQuery)) {
            ps.setString(1, email);
            ps.setInt(2, trainingId);
            ps.executeUpdate();
        }

        response.sendRedirect("student_dashboard.jsp?msg=success");

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("available_courses.jsp?msg=error");
    }
}
}

