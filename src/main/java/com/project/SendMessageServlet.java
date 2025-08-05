package com.project;

import jakarta.servlet.*;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.*;
import java.nio.file.*;
import java.sql.*;
import java.util.UUID;

@WebServlet("/SendMessageServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1MB before temp file creation
    maxFileSize = 5 * 1024 * 1024,   // 5MB max per file
    maxRequestSize = 6 * 1024 * 1024 // 6MB total request
)
public class SendMessageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String UPLOAD_DIR = "uploads";
    private static final String[] ALLOWED_TYPES = { "image/", "application/pdf", "video/", "text/plain" };

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        String email = (session != null) ? (String) session.getAttribute("email") : null;

        if (email == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.write("{\"error\":\"Unauthorized. Please login first.\"}");
            return;
        }

        String message = request.getParameter("message");
        Part filePart = request.getPart("file");
        String fileUrl = null;

        int trainingId = Integer.parseInt(request.getParameter("training_id"));
        int receiverId = Integer.parseInt(request.getParameter("receiver_id"));

        if ((message == null || message.trim().isEmpty()) && (filePart == null || filePart.getSize() == 0)) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.write("{\"error\":\"Message or file is required.\"}");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            // Get sender_id using email
            int senderId = -1;
            try (PreparedStatement ps1 = conn.prepareStatement("SELECT id FROM users WHERE email = ?")) {
                ps1.setString(1, email);
                try (ResultSet rs = ps1.executeQuery()) {
                    if (rs.next()) {
                        senderId = rs.getInt("id");
                    } else {
                        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                        out.write("{\"error\":\"User not found.\"}");
                        return;
                    }
                }
            }

            // Handle file upload
            if (filePart != null && filePart.getSize() > 0) {
                String mimeType = filePart.getContentType();
                boolean validType = false;
                for (String type : ALLOWED_TYPES) {
                    if (mimeType.startsWith(type)) {
                        validType = true;
                        break;
                    }
                }

                if (!validType) {
                    response.setStatus(HttpServletResponse.SC_UNSUPPORTED_MEDIA_TYPE);
                    out.write("{\"error\":\"File type not supported. Only images, PDFs, videos, and text allowed.\"}");
                    return;
                }

                // Save file
                String originalFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                String safeFileName = UUID.randomUUID() + "" + originalFileName.replaceAll("[^a-zA-Z0-9.-]", "_");

                String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdirs();

                String filePath = uploadPath + File.separator + safeFileName;
                filePart.write(filePath);

                fileUrl = UPLOAD_DIR + "/" + safeFileName;
            }

            // Insert message into DB
            String insertQuery = "INSERT INTO messages (sender_id, receiver_id, training_id, message, file_url, is_read, timestamp) VALUES (?, ?, ?, ?, ?, false, CURRENT_TIMESTAMP)";
            try (PreparedStatement ps = conn.prepareStatement(insertQuery)) {
                ps.setInt(1, senderId);
                ps.setInt(2, receiverId);
                ps.setInt(3, trainingId);
                ps.setString(4, message != null ? message.trim() : "");
                ps.setString(5, fileUrl);
                ps.executeUpdate();
            }

            response.setStatus(HttpServletResponse.SC_OK);
            out.write("{\"success\":true, \"message\":\"Message sent successfully.\"}");

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.write("{\"error\":\"Internal server error occurred.\"}");
        }
    }
}