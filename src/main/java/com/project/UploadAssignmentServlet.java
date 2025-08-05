package com.project;

import java.io.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;

@WebServlet("/uploadAssignment")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, // 1 MB
                 maxFileSize = 1024 * 1024 * 10,   // 10 MB
                 maxRequestSize = 1024 * 1024 * 50) // 50 MB
public class UploadAssignmentServlet extends HttpServlet {
	 private static final long serialVersionUID = 1L;
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("email");

        if (email == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int trainingId = Integer.parseInt(request.getParameter("training_id"));
        String description = request.getParameter("description");

        Part filePart = request.getPart("file");
        String fileName = filePart.getSubmittedFileName();

        String uploadDir = getServletContext().getRealPath("") + File.separator + "assignments";
        File dir = new File(uploadDir);
        if (!dir.exists()) dir.mkdirs();

        String filePath = uploadDir + File.separator + fileName;
        filePart.write(filePath);

        try (Connection conn = DBConnection.getConnection()) {
            // Get student ID from email
            PreparedStatement ps1 = conn.prepareStatement("SELECT id FROM users WHERE email = ?");
            ps1.setString(1, email);
            ResultSet rs = ps1.executeQuery();
            int studentId = -1;
            if (rs.next()) {
                studentId = rs.getInt("id");
            }
            rs.close();
            ps1.close();

            if (studentId != -1) {
                PreparedStatement ps2 = conn.prepareStatement(
                    "INSERT INTO assignments (student_id, training_id, filename, description) VALUES (?, ?, ?, ?)");
                ps2.setInt(1, studentId);
                ps2.setInt(2, trainingId);
                ps2.setString(3, fileName);
                ps2.setString(4, description);
                ps2.executeUpdate();
                ps2.close();
            }

            response.sendRedirect("student_dashboard.jsp?msg=Assignment Uploaded Successfully");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("student_dashboard.jsp?msg=Upload Failed");
        }
    }
}