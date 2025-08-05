package com.project;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/GetMessagesServlet")
public class GetMessagesServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		HttpSession session = request.getSession();
		String email = (String) session.getAttribute("email");
		int trainingId = Integer.parseInt(request.getParameter("training_id"));
		int otherUserId = Integer.parseInt(request.getParameter("other_user_id")); // sender/receiver

		if (email == null) {
			response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
			return;
		}

		try (Connection conn = DBConnection.getConnection()) {
			int currentUserId = -1;
			PreparedStatement ps1 = conn.prepareStatement("SELECT id FROM users WHERE email = ?");
			ps1.setString(1, email);
			ResultSet rs1 = ps1.executeQuery();
			if (rs1.next()) {
				currentUserId = rs1.getInt("id");
			}

			PreparedStatement ps = conn.prepareStatement(
				"SELECT m.*, u.full_name AS sender_name FROM messages m JOIN users u ON m.sender_id = u.id " +
				"WHERE training_id = ? AND ((sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)) ORDER BY m.timestamp ASC");
			ps.setInt(1, trainingId);
			ps.setInt(2, currentUserId);
			ps.setInt(3, otherUserId);
			ps.setInt(4, otherUserId);
			ps.setInt(5, currentUserId);

			ResultSet rs = ps.executeQuery();
			response.setContentType("application/json");
			PrintWriter out = response.getWriter();
			out.println("[");
			boolean first = true;
			while (rs.next()) {
				if (!first) out.println(",");
				out.print("{");
				out.printf("\"sender_id\":%d,", rs.getInt("sender_id"));
				out.printf("\"receiver_id\":%d,", rs.getInt("receiver_id"));
				out.printf("\"message\":\"%s\",", rs.getString("message").replace("\"", "\\\""));
				out.printf("\"file_url\":\"%s\",", rs.getString("file_url"));
				out.printf("\"timestamp\":\"%s\",", rs.getTimestamp("timestamp"));
				out.printf("\"sender_name\":\"%s\"", rs.getString("sender_name").replace("\"", "\\\""));
				out.print("}");
				first = false;
			}
			out.println("]");
		} catch (Exception e) {
			e.printStackTrace();
			response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
		}
	}
}