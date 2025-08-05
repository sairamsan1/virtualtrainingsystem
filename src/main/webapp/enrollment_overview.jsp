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
    <title>Enrollment Overview</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            padding: 20px;
            background: #f2f2f2;
        }
        h2 {
            color: #333;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background: #fff;
        }
        th, td {
            border: 1px solid #aaa;
            padding: 10px;
            text-align: left;
        }
        th {
            background-color: #e2e2e2;
        }
        form {
            display: inline;
        }
        button {
            background-color: #ff4d4d;
            color: white;
            border: none;
            padding: 5px 10px;
            cursor: pointer;
            border-radius: 4px;
        }
        button:hover {
            background-color: #cc0000;
        }
        a {
            display: inline-block;
            margin-top: 20px;
            text-decoration: none;
            color: #007BFF;
        }
    </style>
</head>
<body>
    <h2>My Enrollments</h2>
    <table>
        <tr>
            <th>Training Title</th>
            <th>Trainer Email</th>
            <th>Enrollment Date</th>
            <th>Action</th>
        </tr>
        <%
            Connection conn = null;
            PreparedStatement ps = null;
            ResultSet rs = null;

            try {
                conn = DBConnection.getConnection();
                String sql = "SELECT e.enrollment_id, t.title, t.trainer_email, e.enrollment_date " +
                             "FROM enrollments e " +
                             "JOIN trainings t ON e.training_id = t.training_id " +
                             "WHERE e.user_email = ?";
                ps = conn.prepareStatement(sql);
                ps.setString(1, email);
                rs = ps.executeQuery();

                boolean hasData = false;
                while (rs.next()) {
                    hasData = true;
        %>
        <tr>
            <td><%= rs.getString("title") %></td>
            <td><%= rs.getString("trainer_email") %></td>
            <td><%= rs.getDate("enrollment_date") %></td>
            <td>
                <form action="UnenrollServlet" method="post" onsubmit="return confirm('Are you sure you want to unenroll?');">
                    <input type="hidden" name="enrollmentId" value="<%= rs.getInt("enrollment_id") %>">
                    <button type="submit">Unenroll</button>
                </form>
            </td>
        </tr>
        <%
                }

                if (!hasData) {
        %>
        <tr>
            <td colspan="4">You are not enrolled in any trainings.</td>
        </tr>
        <%
                }
            } catch (Exception e) {
        %>
        <tr>
            <td colspan="4">Error: <%= e.getMessage() %></td>
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