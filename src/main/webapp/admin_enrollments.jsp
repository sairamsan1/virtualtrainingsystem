<%@ page import="java.sql.*, com.project.DBConnection" %>
<%@ page session="true" %>
<%
    String email = (String) session.getAttribute("email");
    String role = (String) session.getAttribute("role");

    if (email == null || !"admin".equals(role)) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>View Enrollments - Admin</title>
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background: #f9f9f9;
            padding: 40px;
        }

        .container {
            max-width: 1000px;
            margin: auto;
            background: white;
            padding: 25px 30px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
            border-radius: 10px;
        }

        h2 {
            text-align: center;
            margin-bottom: 25px;
            color: #333;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }

        th, td {
            padding: 14px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }

        th {
            background-color: #0077cc;
            color: white;
        }

        tr:nth-child(even) {
            background-color: #f4f8fb;
        }

        tr:hover {
            background-color: #eef3f8;
        }

        .back-link {
            display: inline-block;
            margin-top: 20px;
            text-decoration: none;
            background-color: #0077cc;
            color: white;
            padding: 8px 14px;
            border-radius: 5px;
        }

        .back-link:hover {
            background-color: #005fa3;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>All Student Enrollments</h2>
        <table>
            <tr>
                <th>Student Name</th>
                <th>Email</th>
                <th>Training Title</th>
                <th>Trainer Name</th>
                <th>Enrollment Date</th>
            </tr>
          <%
    try (Connection conn = DBConnection.getConnection()) {
        String sql = "SELECT u.full_name AS student_name, u.email, t.title, tu.full_name AS trainer_name, e.enrollment_date " +
                     "FROM enrollments e " +
                     "JOIN users u ON e.student_id = u.id " +
                     "JOIN trainings t ON e.training_id = t.id " +
                     "JOIN users tu ON t.trainer_email = tu.email";
        PreparedStatement ps = conn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
%>
<tr>
    <td><%= rs.getString("student_name") %></td>
    <td><%= rs.getString("email") %></td>
    <td><%= rs.getString("title") %></td>
    <td><%= rs.getString("trainer_name") %></td>
    <td><%= rs.getTimestamp("enrollment_date") %></td>
</tr>
<%
        }
    } catch (Exception e) {
        out.println("<tr><td colspan='5'>Error loading enrollments: " + e.getMessage() + "</td></tr>");
    }
%>
        </table>
        <a class="back-link" href="admin_dashboard.jsp">← Back to Dashboard</a>
    </div>
</body>
</html>
