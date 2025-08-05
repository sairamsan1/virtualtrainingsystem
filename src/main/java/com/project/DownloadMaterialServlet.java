package com.project;

import java.io.*;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/DownloadMaterialServlet")
public class DownloadMaterialServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();

            // Get file details
            ps = conn.prepareStatement("SELECT file_name, file_path, downloads FROM trainer_materials WHERE id=?");
            ps.setInt(1, id);
            rs = ps.executeQuery();

            if (rs.next()) {
                String fileName = rs.getString("file_name");
                String filePath = rs.getString("file_path");

                // Increment download count
                PreparedStatement updatePs = conn.prepareStatement("UPDATE trainer_materials SET downloads = downloads + 1 WHERE id=?");
                updatePs.setInt(1, id);
                updatePs.executeUpdate();
                updatePs.close();

                // Set response headers
                File file = new File(filePath);
                response.setContentType("application/octet-stream");
                response.setHeader("Content-Disposition", "attachment;filename=\"" + fileName + "\"");

                // Write file to output
                FileInputStream inStream = new FileInputStream(file);
                OutputStream outStream = response.getOutputStream();

                byte[] buffer = new byte[4096];
                int bytesRead;
                while ((bytesRead = inStream.read(buffer)) != -1) {
                    outStream.write(buffer, 0, bytesRead);
                }

                inStream.close();
                outStream.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Download failed: " + e.getMessage());
        } finally {
            try { if (rs != null) rs.close(); if (ps != null) ps.close(); if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }
}