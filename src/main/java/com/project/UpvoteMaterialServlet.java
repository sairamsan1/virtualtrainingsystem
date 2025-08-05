package com.project;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/UpvoteMaterialServlet")
public class UpvoteMaterialServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));

        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement("UPDATE trainer_materials SET upvotes = upvotes + 1 WHERE id = ?");
            ps.setInt(1, id);
            int result = ps.executeUpdate();
            ps.close();
            response.sendRedirect("view_materials.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Upvote failed: " + e.getMessage());
        }
    }
}