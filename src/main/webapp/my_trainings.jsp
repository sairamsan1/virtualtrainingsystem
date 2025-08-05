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
    <title>My Trainings</title>
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background: #f4f6f9;
            margin: 0;
            padding: 0;
        }
        .container {
            width: 90%;
            margin: 50px auto;
            background: #fff;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h2 {
            text-align: center;
            margin-bottom: 25px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        table th, td {
            padding: 12px;
            border-bottom: 1px solid #ccc;
            text-align: left;
        }
        th {
            background: #007bff;
            color: white;
        }
        tr:hover {
            background: #f1f1f1;
        }
        .action-btn {
            padding: 6px 12px;
            margin: 0 4px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .edit-btn {
            background-color: #28a745;
            color: white;
        }
        .delete-btn {
            background-color: #dc3545;
            color: white;
        }
        .no-data {
            text-align: center;
            color: #777;
            padding: 20px;
        }
    </style>
</head>
<body>
<div class="container">
    <h2>My Trainings</h2>
    <%
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement("SELECT * FROM trainings WHERE trainer_email = ?");
            ps.setString(1, email);
            rs = ps.executeQuery();

            if (!rs.isBeforeFirst()) {
    %>
        <div class="no-data">You have not created or been assigned to any training programs yet.</div>
    <%
            } else {
    %>
        <table>
            <tr>
                <th>ID</th>
                <th>Title</th>
                <th>Description</th>
                <th>Start Date</th>
                <th>End Date</th>
                <th>Actions</th>
            </tr>
            <%
                while (rs.next()) {
                    int trainingId = rs.getInt("id");
            %>
            <tr>
                <td><%= trainingId %></td>
                <td><%= rs.getString("title") %></td>
                <td><%= rs.getString("description") %></td>
                <td><%= rs.getString("start_date") %></td>
                <td><%= rs.getString("end_date") %></td>
                <td>
                    <form action="EditTraining.jsp" method="get" style="display:inline;">
                        <input type="hidden" name="id" value="<%= trainingId %>" />
                        <button type="submit" class="action-btn edit-btn">Edit</button>
                    </form>
                    <form action="DeleteTrainingServlet" method="post" style="display:inline;" 
                          onsubmit="return confirm('Are you sure you want to delete this training?');">
                        <input type="hidden" name="id" value="<%= trainingId %>" />
                        <button type="submit" class="action-btn delete-btn">Delete</button>
                    </form>
                </td>
            </tr>
            <%
                }
            %>
        </table>
    <%
            }
        } catch (Exception e) {
            out.println("<p style='color:red'>Error: " + e.getMessage() + "</p>");
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        }
    %>
</div>
</body>
</html>