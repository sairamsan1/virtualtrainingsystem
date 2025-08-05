<%@ page import="java.sql.*, com.project.DBConnection" %>
<%@ page session="true" %>
<%
    String role = (String) session.getAttribute("role");
    String email = (String) session.getAttribute("email");

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
    <meta charset="UTF-8">
    <title>My Trainings - Trainer</title>
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background-color: #f4f6f9;
            margin: 0;
            padding: 0;
        }

        .container {
            width: 90%;
            margin: 40px auto;
            background-color: #fff;
            border-radius: 12px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            padding: 30px;
        }

        h2 {
            text-align: center;
            color: #333;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 25px;
        }

        th, td {
            border: 1px solid #ccc;
            padding: 14px;
            text-align: center;
        }

        th {
            background-color: #2e86de;
            color: white;
        }

        tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        .back-btn {
            display: inline-block;
            margin-top: 20px;
            padding: 10px 20px;
            background-color: #2e86de;
            color: #fff;
            text-decoration: none;
            border-radius: 6px;
            transition: background 0.3s ease;
        }

        .back-btn:hover {
            background-color: #1b4f72;
        }
    </style>
</head>
<body>
<div class="container">
    <h2>Trainings Assigned to You</h2>
    <table>
        <tr>
            <th>ID</th>
            <th>Title</th>
            <th>Description</th>
            <th>Start Date</th>
            <th>End Date</th>
        </tr>
        <%
            try {
                conn = DBConnection.getConnection();
                String sql = "SELECT * FROM trainings WHERE trainer_email = ?";
                ps = conn.prepareStatement(sql);
                ps.setString(1, email);
                rs = ps.executeQuery();

                boolean hasRows = false;
                while (rs.next()) {
                    hasRows = true;
        %>
        <tr>
            <td><%= rs.getInt("training_id") %></td>
            <td><%= rs.getString("title") %></td>
            <td><%= rs.getString("description") %></td>
            <td><%= rs.getDate("start_date") %></td>
            <td><%= rs.getDate("end_date") %></td>
        </tr>
        <%
                }

                if (!hasRows) {
        %>
        <tr>
            <td colspan="5">No trainings assigned yet.</td>
        </tr>
        <%
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (rs != null) try { rs.close(); } catch (Exception ignored) {}
                if (ps != null) try { ps.close(); } catch (Exception ignored) {}
                if (conn != null) try { conn.close(); } catch (Exception ignored) {}
            }
        %>
    </table>

    <div style="text-align:center;">
        <a class="back-btn" href="trainer_dashboard.jsp">← Back to Dashboard</a>
    </div>
</div>
</body>
</html>