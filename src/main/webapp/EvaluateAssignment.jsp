<%@ page import="java.sql.*, com.project.DBConnection" %>
<%@ page session="true" %>
<%
    String email = (String) session.getAttribute("email");
    String role = (String) session.getAttribute("role");

    if (email == null || !"trainer".equals(role)) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }

    int assignmentId = Integer.parseInt(request.getParameter("assignment_id"));

    Connection conn = DBConnection.getConnection();
    PreparedStatement ps = conn.prepareStatement(
        "SELECT a.id, u.full_name, u.email AS student_email, t.title AS training_title, " +
        "a.filename, a.description, a.upload_time, a.marks, a.comments " +
        "FROM assignments a " +
        "JOIN users u ON a.student_id = u.id " +
        "JOIN trainings t ON a.training_id = t.id " +
        "WHERE a.id = ?");
    ps.setInt(1, assignmentId);
    ResultSet rs = ps.executeQuery();

    if (!rs.next()) {
        out.println("<h3>Assignment not found!</h3>");
        return;
    }
%>
<html>
<head>
    <title>Evaluate Assignment</title>
</head>
<body>
    <h2>Evaluate Assignment</h2>
    <p><strong>Student:</strong> <%= rs.getString("full_name") %> (<%= rs.getString("student_email") %>)</p>
    <p><strong>Training:</strong> <%= rs.getString("training_title") %></p>
    <p><strong>Description:</strong> <%= rs.getString("description") %></p>
    <p><strong>Uploaded:</strong> <%= rs.getTimestamp("upload_time") %></p>
    <p><strong>File:</strong> <a href="assignments/<%= rs.getString("filename") %>" target="_blank">Download</a></p>

    <form action="EvaluateAssignmentServlet" method="post">
        <input type="hidden" name="assignment_id" value="<%= assignmentId %>">

        <label>Marks (out of 100):</label><br>
        <input type="number" name="marks" min="0" max="100" value="<%= rs.getInt("marks") %>" required><br><br>

        <label>Trainer Comments:</label><br>
        <textarea name="comments" rows="4" cols="50"><%= rs.getString("comments") != null ? rs.getString("comments") : "" %></textarea><br><br>

        <input type="submit" value="Submit Evaluation">
    </form>

    <p><a href="trainer_dashboard.jsp">← Back to Dashboard</a></p>
</body>
</html>
<%
    rs.close();
    ps.close();
    conn.close();
%>