<%@ page import="java.sql.*, com.project.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Verify Certificate</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f0f8ff; padding: 40px; }
        .container {
            max-width: 600px; margin: auto; background: #fff;
            padding: 30px; border-radius: 10px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        h2 { color: #2c3e50; }
        input[type="text"] {
            width: 100%; padding: 12px;
            border: 1px solid #ccc; border-radius: 6px;
            margin-top: 10px; margin-bottom: 20px;
        }
        button {
            background: #3498db; color: white;
            padding: 12px 20px; border: none;
            border-radius: 6px; cursor: pointer;
        }
        button:hover { background: #2980b9; }
        .result { margin-top: 25px; font-size: 16px; }
        .valid { color: green; font-weight: bold; }
        .invalid { color: red; font-weight: bold; }
    </style>
</head>
<body>
<div class="container">
    <h2>🎓 Verify Certificate</h2>
    <form method="post">
        <label for="certificate_code">Enter Certificate ID:</label>
        <input type="text" name="certificate_code" id="certificate_code" required />
        <button type="submit">Verify</button>
    </form>

    <%
        String certCode = request.getParameter("certificate_code");
        if (certCode != null && !certCode.trim().isEmpty()) {
            try {
                Connection conn = DBConnection.getConnection();
                PreparedStatement pst = conn.prepareStatement(
                    "SELECT c.certificate_code, u.name, t.title, c.issue_date " +
                    "FROM certificates c " +
                    "JOIN enrollments e ON c.student_id = e.student_id AND c.training_id = e.training_id " +
                    "JOIN users u ON c.student_id = u.id " +
                    "JOIN trainings t ON c.training_id = t.id " +
                    "WHERE c.certificate_code = ?"
                );
                pst.setString(1, certCode);
                ResultSet rs = pst.executeQuery();
                if (rs.next()) {
    %>
        <div class="result valid">
            ✅ <strong>Certificate is Valid</strong><br><br>
            Student: <strong><%= rs.getString("name") %></strong><br>
            Training: <strong><%= rs.getString("title") %></strong><br>
            Certificate ID: <strong><%= rs.getString("certificate_code") %></strong><br>
            Issued On: <strong><%= rs.getTimestamp("issue_date") %></strong>
        </div>
    <%
                } else {
    %>
        <div class="result invalid">❌ Invalid Certificate ID</div>
    <%
                }
                rs.close(); pst.close(); conn.close();
            } catch (Exception e) {
    %>
        <div class="result invalid">⚠️ Error occurred: <%= e.getMessage() %></div>
    <%
            }
        }
    %>
</div>
</body>
</html>
