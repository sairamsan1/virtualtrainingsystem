<%@ page import="java.sql.*, java.util.*, com.project.DBConnection" %>
<%@ page session="true" %>
<%
    String trainerEmail = (String) session.getAttribute("email");
    if (trainerEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Assign Tasks to Students</title>
    <style>
        body { font-family: Arial; background: #f9f9f9; padding: 20px; }
        h2 { color: #333; }
        form { background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); width: 500px; margin-bottom: 30px; }
        label { font-weight: bold; }
        input, textarea, select { width: 100%; padding: 8px; margin-bottom: 15px; }
        table { border-collapse: collapse; width: 100%; background: #fff; margin-top: 20px; }
        th, td { padding: 10px; border: 1px solid #ccc; text-align: left; }
    </style>
</head>
<body>

<h2>Assign Task to Student</h2>

<form method="post" action="AssignTaskServlet">
    <label>Select Training:</label>
    <select name="training_id" required>
        <%
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement("SELECT id, title FROM trainings WHERE trainer_email = ?");
            ps.setString(1, trainerEmail);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
        %>
        <option value="<%= rs.getInt("id") %>"><%= rs.getString("title") %></option>
        <%
            }
            rs.close();
            ps.close();
        %>
    </select>

    <label>Select Student:</label>
    <select name="student_id" required>
        <%
            ps = conn.prepareStatement(
                "SELECT DISTINCT u.id, u.name FROM users u " +
                "JOIN enrollments e ON u.id = e.student_id " +
                "JOIN trainings t ON e.training_id = t.id " +
                "WHERE t.trainer_email = ?"
            );
            ps.setString(1, trainerEmail);
            rs = ps.executeQuery();
            while (rs.next()) {
        %>
        <option value="<%= rs.getInt("id") %>"><%= rs.getString("name") %></option>
        <%
            }
            rs.close();
            ps.close();
        %>
    </select>

    <label>Task Title:</label>
    <input type="text" name="title" required>

    <label>Description:</label>
    <textarea name="description" required></textarea>

    <label>Due Date:</label>
    <input type="date" name="due_date" required>

    <input type="submit" value="Assign Task">
</form>

<%
    // Display Assigned Tasks
    ps = conn.prepareStatement(
        "SELECT t.title AS training_title, u.name AS student_name, tk.title AS task_title, tk.description, tk.due_date, tk.is_completed " +
        "FROM tasks tk " +
        "JOIN trainings t ON tk.training_id = t.id " +
        "JOIN users u ON tk.student_id = u.id " +
        "WHERE t.trainer_email = ? ORDER BY tk.due_date DESC"
    );
    ps.setString(1, trainerEmail);
    rs = ps.executeQuery();
%>

<h2>Assigned Tasks</h2>
<table>
    <tr>
        <th>Training</th>
        <th>Student</th>
        <th>Title</th>
        <th>Description</th>
        <th>Due Date</th>
        <th>Status</th>
    </tr>
    <%
        while (rs.next()) {
    %>
    <tr>
        <td><%= rs.getString("training_title") %></td>
        <td><%= rs.getString("student_name") %></td>
        <td><%= rs.getString("task_title") %></td>
        <td><%= rs.getString("description") %></td>
        <td><%= rs.getDate("due_date") %></td>
        <td><em>Status: <%= rs.getBoolean("is_completed") ? "✅ Completed" : "❌ Pending" %></em></td>
    </tr>
    <%
        }
        rs.close();
        ps.close();
        conn.close();
    %>
</table>

</body>
</html>