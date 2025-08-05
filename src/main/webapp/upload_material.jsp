<%@ page import="java.sql.*, com.project.DBConnection" %>
<%@ page session="true" %>
<%
    String email = (String) session.getAttribute("email");
    String role = (String) session.getAttribute("role");

    if (email == null || !"trainer".equals(role)) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Upload Training Material</title>
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background: #f4f6f9;
            margin: 0;
            padding: 40px;
        }

        .container {
            width: 500px;
            margin: auto;
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        h2 {
            text-align: center;
            margin-bottom: 25px;
        }

        label {
            font-weight: bold;
        }

        select, input[type="file"], button {
            width: 100%;
            padding: 10px;
            margin: 10px 0 20px;
            border-radius: 6px;
            border: 1px solid #ccc;
        }

        button {
            background-color: #007bff;
            color: white;
            border: none;
            font-weight: bold;
            cursor: pointer;
        }

        button:hover {
            background-color: #0056b3;
        }

        .back-link {
            display: block;
            text-align: center;
            margin-top: 20px;
            text-decoration: none;
            color: #007bff;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Upload Training Material</h2>
        <form action="UploadMaterialServlet" method="post" enctype="multipart/form-data">
            <label for="trainingId">Select Training:</label>
            <select name="trainingId" id="trainingId" required>
                <option value="">-- Choose a Training --</option>
                <%
                    Connection conn = null;
                    PreparedStatement ps = null;
                    ResultSet rs = null;

                    try {
                        conn = DBConnection.getConnection();
                        ps = conn.prepareStatement("SELECT id, title FROM trainings WHERE trainer_email = ?");
                        ps.setString(1, email);
                        rs = ps.executeQuery();

                        while (rs.next()) {
                            int trainingId = rs.getInt("id");
                            String title = rs.getString("title");
                %>
                            <option value="<%= trainingId %>"><%= title %></option>
                <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        try { if (rs != null) rs.close(); } catch (Exception ignored) {}
                        try { if (ps != null) ps.close(); } catch (Exception ignored) {}
                        try { if (conn != null) conn.close(); } catch (Exception ignored) {}
                    }
                %>
            </select>

            <label for="file">Select File:</label>
            <input type="file" name="file" id="file" accept=".pdf,.mp4,.docx,.pptx,.txt" required>

            <button type="submit">Upload Material</button>
        </form>
        <a href="trainer_dashboard.jsp" class="back-link">← Back to Dashboard</a>
    </div>
</body>
</html>