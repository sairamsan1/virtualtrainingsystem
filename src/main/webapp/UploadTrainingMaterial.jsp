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
</head>
<body>
    <h2>Upload Training Material</h2>
    <form action="UploadMaterialServlet" method="post" enctype="multipart/form-data">
        <label>Select Training:</label>
        <select name="trainingId" required>
            <%
                try {
                    Connection conn = DBConnection.getConnection();
                    String sql = "SELECT id, title FROM trainings WHERE trainer_id = (SELECT id FROM users WHERE email = ?)";
                    PreparedStatement ps = conn.prepareStatement(sql);
                    ps.setString(1, email);
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        int id = rs.getInt("id");
                        String title = rs.getString("title");
            %>
                <option value="<%= id %>"><%= title %></option>
            <%
                    }
                    rs.close();
                    ps.close();
                    conn.close();
                } catch (Exception e) {
                    out.println("<p style='color:red;'>Error loading trainings.</p>");
                }
            %>
        </select><br><br>

        <label>Select File:</label>
        <input type="file" name="file" accept=".pdf,.mp4,.docx,.pptx" required><br><br>

        <button type="submit">Upload</button>
    </form>
</body>
</html>