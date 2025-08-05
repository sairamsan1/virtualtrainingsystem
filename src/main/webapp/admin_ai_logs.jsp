<%@ page import="java.sql.*" %>
<%@ page import="com.project.DBConnection" %>
<%@ page session="true" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null || !"admin".equals(role)) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>AI Chat Logs - Admin</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f4f4f4;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 1000px;
            margin: 40px auto;
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            padding: 10px;
            border: 1px solid #ccc;
            text-align: left;
            vertical-align: top;
        }
        th {
            background-color: #3498db;
            color: white;
        }
        h2 {
            color: #2c3e50;
        }
        input[type="text"] {
            padding: 8px;
            width: 250px;
            margin-right: 10px;
        }
        button {
            padding: 8px 16px;
            background: #3498db;
            color: white;
            border: none;
            cursor: pointer;
        }
        button:hover {
            background: #2980b9;
        }
        td pre {
            white-space: pre-wrap;
            word-wrap: break-word;
        }
    </style>
</head>
<body>
<div class="container">
    <h2>🧠 AI Chat Logs</h2>
    <form method="get" action="">
        <input type="text" name="email" placeholder="Filter by Email"
               value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>">
        <button type="submit">Search</button>
    </form>
    <br>
    <table>
        <tr>
            <th>Email</th>
            <th>User Message</th>
            <th>AI Reply</th>
            <th>Timestamp</th>
        </tr>
        <%
            String filterEmail = request.getParameter("email");
            try (Connection conn = DBConnection.getConnection()) {
                String query = "SELECT l.*, u.email FROM ai_chat_logs l JOIN users u ON l.user_id = u.id";
                if (filterEmail != null && !filterEmail.trim().isEmpty()) {
                    query += " WHERE u.email LIKE ? ORDER BY l.timestamp DESC";
                } else {
                    query += " ORDER BY l.timestamp DESC";
                }

                PreparedStatement ps = conn.prepareStatement(query);
                if (filterEmail != null && !filterEmail.trim().isEmpty()) {
                    ps.setString(1, "%" + filterEmail + "%");
                }

                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
        %>
        <tr>
            <td><%= rs.getString("email") %></td>
            <td><pre><%= rs.getString("user_message") %></pre></td>
            <td><pre><%= rs.getString("ai_reply") %></pre></td>
            <td><%= rs.getTimestamp("timestamp") %></td>
        </tr>
        <%
                }
            } catch (Exception e) {
                e.printStackTrace();
        %>
            <tr><td colspan="4">Error loading chat logs.</td></tr>
        <%
            }
        %>
    </table>
</div>
</body>
</html>
