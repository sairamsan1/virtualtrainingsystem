package com.project;
import java.io.*;
import java.nio.file.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/UploadMaterialServlet")
@MultipartConfig
public class UploadMaterialServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String UPLOAD_DIR = "uploads";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("email");
        if (email == null || !"trainer".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        int trainingId = Integer.parseInt(request.getParameter("training_id"));
        Part filePart = request.getPart("file");
        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

        // Physical path to /uploads
        String appPath = request.getServletContext().getRealPath("");
        String uploadPath = appPath + File.separator + UPLOAD_DIR;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdir();

        String filePath = uploadPath + File.separator + fileName;
        filePart.write(filePath);

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();

            // Get trainer_id from email
            int trainerId = 0;
            ps = conn.prepareStatement("SELECT id FROM users WHERE email = ?");
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                trainerId = rs.getInt("id");
            }
            rs.close();
            ps.close();

            // Insert material record
            ps = conn.prepareStatement(
                "INSERT INTO materials (training_id, trainer_id, file_name, file_path, file_type, downloads, upvotes) VALUES (?, ?, ?, ?, ?, 0, 0)"
            );
            ps.setInt(1, trainingId);
            ps.setInt(2, trainerId);
            ps.setString(3, fileName);
            ps.setString(4, filePath);
            ps.setString(5, filePart.getContentType());

            ps.executeUpdate();
            ps.close();

            response.sendRedirect("trainer_materials.jsp?msg=upload_success");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("trainer_materials.jsp?msg=upload_error");
        } finally {
            try { if (ps != null) ps.close(); if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }
}