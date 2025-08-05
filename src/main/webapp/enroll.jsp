<%@ page import="java.sql.*, com.project.DBConnection" %>
<%@ page session="true" %>
<%
    String email = (String) session.getAttribute("email");
    String role = (String) session.getAttribute("role");

    if (email == null || !"student".equals(role)) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Enrollments</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            padding: 20px;
        }

        h2 {
            color: #333;
        }

        table {
            border-collapse: collapse;
            width: 100%;
            margin-top: 20px;
        }

        th, td {
            border: 1px solid #000;
            padding: 10px;
            text-align: left;
        }

        th {
            background-color: #f2f2f2;
        }

        a {
            display: inline-block;
            margin-top: 20px;
            text-decoration: none;
            color: #007BFF;
        }

        a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <h2>My Enrolled Trainings</h2>
    <table>
        <tr>
            <th>Title</th>
            <th>Trainer</th>
            <th>Duration</th>
        </tr>
        <%
            Connection conn = null;
            PreparedStatement ps = null;
            ResultSet rs = null;

            try {
                conn = DBConnection.getConnection();
                String sql = "SELECT t.title, u.full_name AS trainer_name, t.duration " +
                        "FROM trainings t " +
                        "INNER JOIN enrollments e ON t.id = e.training_id " +
                        "INNER JOIN users u ON t.trainer_email = u.email " +
                        "WHERE e.student_email = ?";
                ps = conn.prepareStatement(sql);
                ps.setString(1, email);
                rs = ps.executeQuery();

                boolean hasRecords = false;

                while (rs.next()) {
                    hasRecords = true;
        %>
        <tr>
            <td><%= rs.getString("title") %></td>
            <td><%= rs.getString("trainer_name") %></td>
            <td><%= rs.getString("duration") %></td>
        </tr>
        <%
                }

                if (!hasRecords) {
        %>
        <tr>
            <td colspan="3">You have not enrolled in any trainings yet.</td>
        </tr>
        <%
                }
            } catch (Exception e) {
        %>
        <tr>
            <td colspan="3">Error: <%= e.getMessage() %></td>
        </tr>
        <%
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                if (conn != null) try { conn.close(); } catch (SQLException e) {}
            }
        %>
    </table>
    <a href="student_dashboard.jsp">← Back to Dashboard</a>
</body>
</html>
