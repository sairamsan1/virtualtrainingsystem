package com.project;
import java.io.File;
import java.io.IOException;
import java.sql.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/DeleteMaterialServlet")
public class DeleteMaterialServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect("trainer_materials.jsp?msg=Invalid material ID");
            return;
        }

        int materialId = Integer.parseInt(idParam);

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();

            // Get file path before deleting record
            ps = conn.prepareStatement("SELECT file_path FROM materials WHERE id = ?");
            ps.setInt(1, materialId);
            rs = ps.executeQuery();

            String filePath = null;
            if (rs.next()) {
                filePath = rs.getString("file_path");
            }
            rs.close();
            ps.close();

            // Delete material record from database
            ps = conn.prepareStatement("DELETE FROM materials WHERE id = ?");
            ps.setInt(1, materialId);
            int deleted = ps.executeUpdate();
            ps.close();

            // Delete file from disk if database record deleted
            if (deleted > 0 && filePath != null) {
                File file = new File(filePath);
                if (file.exists()) {
                    file.delete();
                }
            }

            response.sendRedirect("trainer_materials.jsp?msg=deleted");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("trainer_materials.jsp?msg=error");
        } finally {
            try { if (rs != null) rs.close(); if (ps != null) ps.close(); if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }
}