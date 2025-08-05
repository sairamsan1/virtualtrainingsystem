<%@ page import="java.sql.*, com.project.DBConnection" %>
<%@ page session="true" %>
<%
    String email = (String) session.getAttribute("email");
    String role = (String) session.getAttribute("role");

    if (email == null || !"student".equals(role)) {
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
    <title>Available Materials</title>
    <style>
        body { font-family: Arial; background-color: #f4f4f4; padding: 20px; }
        table { width: 100%; border-collapse: collapse; background: #fff; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ccc; }
        th { background-color: #007BFF; color: white; }
        a.btn {
            text-decoration: none;
            padding: 6px 12px;
            color: #fff;
            background-color: #28a745;
            border-radius: 4px;
            margin-right: 5px;
        }
        a.btn-download { background-color: #17a2b8; }
        a.btn-upvote { background-color: #ffc107; color: black; }
    </style>
</head>
<body>
    <h2>Training Materials</h2>
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
                ps = conn.prepareStatement("SELECT * FROM trainer_materials");
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
                <a class="btn btn-upvote" href="UpvoteMaterialServlet?id=<%=id%>">Upvote</a>
            </td>
        </tr>
        <%
                }
            } catch (Exception e) {
                out.println("<tr><td colspan='5'>Error loading materials: " + e.getMessage() + "</td></tr>");
            } finally {
                try { if (rs != null) rs.close(); if (ps != null) ps.close(); if (conn != null) conn.close(); } catch (Exception e) {}
            }
        %>
    </table>
</body>
</html>