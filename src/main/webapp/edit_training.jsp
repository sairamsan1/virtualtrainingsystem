<%@ page import="java.sql.*, com.project.DBConnection" %>
<%@ page session="true" %>
<%
    String email = (String) session.getAttribute("email");
    String role = (String) session.getAttribute("role");
    if (email == null || !"admin".equals(role)) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }

    int trainingId = Integer.parseInt(request.getParameter("id"));
    String title = "", duration = "", description = "";
    int trainerId = -1;

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();
        ps = conn.prepareStatement("SELECT * FROM trainings WHERE id = ?");
        ps.setInt(1, trainingId);
        rs = ps.executeQuery();
        if (rs.next()) {
            title = rs.getString("title");
            duration = rs.getString("duration");
            description = rs.getString("description");
            trainerId = rs.getInt("trainer_id");
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Training</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #eef2f3;
            padding: 40px;
        }
        .form-box {
            background: white;
            max-width: 500px;
            margin: auto;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 5px 12px rgba(0,0,0,0.1);
        }
        h2 {
            text-align: center;
            color: #333;
        }
        label {
            display: block;
            margin-top: 20px;
            font-weight: bold;
        }
        input[type="text"], select, textarea {
            width: 100%;
            padding: 10px;
            margin-top: 6px;
            border: 1px solid #ccc;
            border-radius: 5px;
        }
        button {
            margin-top: 25px;
            padding: 12px;
            background-color: #007bff;
            color: white;
            border: none;
            width: 100%;
            border-radius: 6px;
            cursor: pointer;
        }
        button:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>
<div class="form-box">
    <h2>Edit Training</h2>
    <form action="UpdateTrainingServlet" method="post">
        <input type="hidden" name="id" value="<%= trainingId %>"/>

        <label for="title">Title:</label>
        <input type="text" name="title" value="<%= title %>" required />

        <label for="duration">Duration:</label>
        <input type="text" name="duration" value="<%= duration %>" required />

        <label for="description">Description:</label>
        <textarea name="description" rows="4" required><%= description %></textarea>

        <label for="trainer">Assigned Trainer:</label>
        <select name="trainer_id" required>
            <option value="">-- Select Trainer --</option>
            <%
                try {
                    PreparedStatement trainerPS = conn.prepareStatement("SELECT id, full_name FROM users WHERE role = 'trainer'");
                    ResultSet trainerRS = trainerPS.executeQuery();
                    while (trainerRS.next()) {
                        int tId = trainerRS.getInt("id");
                        String tName = trainerRS.getString("full_name");
                        String selected = (tId == trainerId) ? "selected" : "";
            %>
                <option value="<%= tId %>" <%= selected %>><%= tName %></option>
            <%
                    }
                    trainerRS.close();
                    trainerPS.close();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            %>
        </select>

        <button type="submit">Update Training</button>
    </form>
</div>
</body>
</html>