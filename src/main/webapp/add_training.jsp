<%@ page session="true" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.project.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Add New Training</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        * {
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        body {
            background: linear-gradient(to right, #f2f4f7, #dfe6ed);
            margin: 0;
            padding: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
        }

        .container {
            background-color: #ffffff;
            border-radius: 15px;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1);
            padding: 30px 40px;
            width: 400px;
        }

        h2 {
            text-align: center;
            color: #333;
            margin-bottom: 25px;
        }

        label {
            display: block;
            margin-bottom: 6px;
            color: #555;
            font-weight: 600;
        }

        input[type="text"], select {
            width: 100%;
            padding: 10px 12px;
            margin-bottom: 18px;
            border: 1px solid #ccc;
            border-radius: 8px;
            transition: border-color 0.3s ease;
        }

        input[type="text"]:focus, select:focus {
            border-color: #007bff;
            outline: none;
        }

        .btn {
            width: 100%;
            padding: 12px;
            background-color: #007bff;
            border: none;
            border-radius: 8px;
            color: white;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        .btn:hover {
            background-color: #0056b3;
        }

        .msg {
            margin-top: 15px;
            padding: 10px;
            border-radius: 6px;
            font-size: 14px;
        }

        .success {
            background-color: #d4edda;
            color: #155724;
        }

        .error {
            background-color: #f8d7da;
            color: #721c24;
        }

        .back-link {
            display: block;
            text-align: center;
            margin-top: 20px;
            text-decoration: none;
            color: #007bff;
            font-weight: 600;
        }

        .back-link:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>➕ Add New Training</h2>
        <form action="addTraining" method="post" autocomplete="off">
            <label for="title">Title</label>
            <input type="text" name="title" id="title" placeholder="e.g. Java Basics" required>

            <label for="duration">Duration</label>
            <input type="text" name="duration" id="duration" placeholder="e.g. 4 weeks" required>

            <label for="trainer_id">Assign Trainer</label>
            <select name="trainer_id" id="trainer_id" required>
                <option value="">-- Select Trainer --</option>
                <%
                    try {
                        Connection conn = DBConnection.getConnection();
                        PreparedStatement ps = conn.prepareStatement("SELECT id, full_name FROM users WHERE role='trainer' AND status='active'");
                        ResultSet rs = ps.executeQuery();
                        while (rs.next()) {
                %>
                    <option value="<%= rs.getInt("id") %>"><%= rs.getString("full_name") %></option>
                <%
                        }
                        rs.close();
                        ps.close();
                        conn.close();
                    } catch (Exception e) {
                        out.println("<option disabled>Error loading trainers</option>");
                    }
                %>
            </select>

            <button type="submit" class="btn">Add Training</button>
        </form>

        <%
            String msg = request.getParameter("msg");
            if ("added".equals(msg)) {
        %>
            <div class="msg success">✅ Training added successfully!</div>
        <%
            } else if ("error".equals(msg)) {
        %>
            <div class="msg error">❌ Error adding training. Please try again.</div>
        <%
            } else if ("invalid_input".equals(msg)) {
        %>
            <div class="msg error">⚠ Please fill in all fields correctly.</div>
        <%
            }
        %>

        <a href="admin_dashboard.jsp" class="back-link">← Back to Dashboard</a>
    </div>
</body>
</html>