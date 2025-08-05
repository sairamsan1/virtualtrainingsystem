<%@ page import="java.sql.*, com.project.DBConnection" %>
<%@ page session="true" %>
<%
    String email = (String) session.getAttribute("email");
    String role = (String) session.getAttribute("role");

    if (email == null || (!"trainer".equals(role) && !"student".equals(role))) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }

    Connection conn = DBConnection.getConnection();
    PreparedStatement ps = null;
    ResultSet rs = null;
%>
<html>
<head>
    <title><%= "trainer".equals(role) ? "Student Assignments" : "My Submitted Assignments" %></title>
    <style>
        body { font-family: Arial; background-color: #f9f9f9; }
        table { border-collapse: collapse; width: 95%; margin: auto; }
        th, td { border: 1px solid #ccc; padding: 10px; text-align: left; }
        th { background-color: #eee; }
        h2 { text-align: center; margin-top: 30px; }
        form { margin: 0; }
    </style>
</head>
<body>
    <h2><%= "trainer".equals(role) ? "Student Assignments" : "My Submitted Assignments" %></h2>
    <table>
        <tr>
            <% if ("trainer".equals(role)) { %>
                <th>Student Name</th>
            <% } else { %>
                <th>Trainer Email</th>
            <% } %>
            <th>Training Title</th>
            <th>Description</th>
            <th>File</th>
            <th>Uploaded On</th>
            <th>Marks</th>
            <th>Comments</th>
            <% if ("trainer".equals(role)) { %>
                <th>Actions</th>
            <% } %>
        </tr>
        <%
            if ("trainer".equals(role)) {
                ps = conn.prepareStatement(
                    "SELECT a.id, u.full_name, t.title AS training_title, a.filename, a.description, " +
                    "a.upload_time, a.marks, a.comments " +
                    "FROM assignments a " +
                    "JOIN users u ON a.student_id = u.id " +
                    "JOIN trainings t ON a.training_id = t.id " +
                    "WHERE t.trainer_email = ? ORDER BY a.upload_time DESC");
                ps.setString(1, email);
            } else {
                ps = conn.prepareStatement(
                    "SELECT a.id, t.title AS training_title, t.trainer_email, a.filename, a.description, " +
                    "a.upload_time, a.marks, a.comments " +
                    "FROM assignments a " +
                    "JOIN trainings t ON a.training_id = t.id " +
                    "JOIN users u ON a.student_id = u.id " +
                    "WHERE u.email = ? ORDER BY a.upload_time DESC");
                ps.setString(1, email);
            }

            rs = ps.executeQuery();
            while (rs.next()) {
        %>
        <tr>
            <% if ("trainer".equals(role)) { %>
                <td><%= rs.getString("full_name") %></td>
            <% } else { %>
                <td><%= rs.getString("trainer_email") %></td>
            <% } %>
            <td><%= rs.getString("training_title") %></td>
            <td><%= rs.getString("description") %></td>
            <td><a href="assignments/<%= rs.getString("filename") %>" target="_blank">Download</a></td>
            <td><%= rs.getTimestamp("upload_time") %></td>
            <td><%= (rs.getObject("marks") != null) ? rs.getInt("marks") : "Not Evaluated" %></td>
            <td><%= (rs.getString("comments") != null) ? rs.getString("comments") : "Awaiting Feedback" %></td>
            <% if ("trainer".equals(role)) { %>
            <td>
                <form action="EvaluateAssignment.jsp" method="get">
                    <input type="hidden" name="assignment_id" value="<%= rs.getInt("id") %>">
                    <input type="submit" value="Evaluate">
                </form>
            </td>
            <% } %>
        </tr>
        <%
            }
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            conn.close();
        %>
    </table>
</body>
</html>