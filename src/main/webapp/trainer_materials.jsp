<%@ page import="java.sql.*, com.project.DBConnection" %>
<%@ page session="true" %>
<%
    String email = (String) session.getAttribute("email");
    String role = (String) session.getAttribute("role");

    if (email == null || !"trainer".equals(role)) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>

<!DOCTYPE html>
<html>
<head>
    <title>My Uploaded Materials</title>
    <style>
        body { font-family: Arial; background-color: #f0f0f0; padding: 20px; }
        table { width: 100%; border-collapse: collapse; background: #fff; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ccc; }
        th { background-color: #343a40; color: white; }
        a.btn {
            text-decoration: none;
            padding: 6px 12px;
            border-radius: 4px;
            color: white;
            margin-right: 5px;
        }
        .btn-download { background-color: #17a2b8; }
        .btn-delete { background-color: #dc3545; }
    </style>
</head>
<body>
    <h2>My Uploaded Materials</h2>
    <table>
        <tr>
            <th>File Name</th>
            <th>Type</th>
            <th>Downloads</th>
            <th>Upvotes</th>
            <th>Actions</th>
        </tr>
        <%
            try {
                conn = DBConnection.getConnection();

                // Get trainer ID
                ps = conn.prepareStatement("SELECT id FROM users WHERE email = ?");
                ps.setString(1, email);
                rs = ps.executeQuery();
                int trainerId = 0;
                if (rs.next()) {
                    trainerId = rs.getInt("id");
                }
                rs.close();
                ps.close();

                ps = conn.prepareStatement("SELECT * FROM materials WHERE trainer_id = ?");
                ps.setInt(1, trainerId);
                rs = ps.executeQuery();

                while (rs.next()) {
                    int id = rs.getInt("id");
                    String fileName = rs.getString("file_name");
                    String fileType = rs.getString("file_type");
                    int downloads = rs.getInt("downloads");
                    int upvotes = rs.getInt("upvotes");
        %>
        <tr>
            <td><%= fileName %></td>
            <td><%= fileType %></td>
            <td><%= downloads %></td>
            <td><%= upvotes %></td>
            <td>
                <a class="btn btn-download" href="DownloadMaterialServlet?id=<%=id%>">Download</a>
                <a class="btn btn-delete" href="DeleteMaterialServlet?id=<%=id%>" onclick="return confirm('Are you sure you want to delete this file?');">Delete</a>
            </td>
        </tr>
        <%
                }

            } catch (Exception e) {
                out.println("<tr><td colspan='5'>Error: " + e.getMessage() + "</td></tr>");
            } finally {
                try { if (rs != null) rs.close(); if (ps != null) ps.close(); if (conn != null) conn.close(); } catch (Exception e) {}
            }
        %>
    </table>
</body>
</html>