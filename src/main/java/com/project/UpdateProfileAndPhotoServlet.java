package com.project;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.*;
import java.nio.file.Paths;
import java.sql.*;

@WebServlet("/UpdateProfileAndPhotoServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2,    // 2MB
        maxFileSize = 1024 * 1024 * 10,                  // 10MB
        maxRequestSize = 1024 * 1024 * 50)               // 50MB
public class UpdateProfileAndPhotoServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String UPLOAD_FOLDER = "uploads/profile_photos"; // subfolder inside webapp

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String fullName = request.getParameter("full_name");
        String mobile = request.getParameter("mobile");
        String gender = request.getParameter("gender");
        String password = request.getParameter("password");

        String fileName = null;

        // Get the photo file part from form
        Part filePart = request.getPart("photo");
        if (filePart != null && filePart.getSize() > 0) {
            fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

            // Upload directory path relative to server context
            String uploadPath = getServletContext().getRealPath("/") + UPLOAD_FOLDER;
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs(); // create parent folders

            // Write file to the folder
            filePart.write(uploadPath + File.separator + fileName);
        }

        try (Connection conn = DBConnection.getConnection()) {

            // Build dynamic query based on provided fields
            StringBuilder query = new StringBuilder("UPDATE users SET full_name=?, mobile=?, gender=?");

            if (password != null && !password.trim().isEmpty()) {
                query.append(", password=?");
            }
            if (fileName != null) {
                query.append(", photo=?");
            }

            query.append(" WHERE email=?");

            PreparedStatement ps = conn.prepareStatement(query.toString());

            ps.setString(1, fullName);
            ps.setString(2, mobile);
            ps.setString(3, gender);

            int index = 4;

            if (password != null && !password.trim().isEmpty()) {
                ps.setString(index++, password); // Optional: hash before storing
            }
            if (fileName != null) {
                ps.setString(index++, fileName); // store only filename, not full path
            }

            ps.setString(index, email); // last param is email (WHERE condition)

            int updated = ps.executeUpdate();
            if (updated > 0) {
                response.sendRedirect("student_profile.jsp?msg=updated");
            } else {
                response.sendRedirect("student_profile.jsp?msg=error");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("student_profile.jsp?msg=exception");
        }
    }
}
