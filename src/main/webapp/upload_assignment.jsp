<%@ page import="java.sql.*, com.project.DBConnection" %>
<%@ page session="true" %>
<%
    String email = (String) session.getAttribute("email");
    String role = (String) session.getAttribute("role");
    if (email == null || !"student".equals(role)) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Upload Assignment</title>
</head>
<body>
    <h2>Upload Assignment</h2>
    <form action="uploadAssignment" method="post" enctype="multipart/form-data">
        <label>Select Training:</label>
        <select name="training_id" required>
            <%
                Connection conn = null;
                PreparedStatement ps = null;
                ResultSet rs = null;
                try {
                    conn = DBConnection.getConnection();
                    ps = conn.prepareStatement("SELECT id, title FROM trainings");
                    rs = ps.executeQuery();
                    while(rs.next()) {
            %>
                <option value="<%= rs.getInt("id") %>"><%= rs.getString("title") %></option>
            <%
                    }
                } catch(Exception e) {
                    out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
                } finally {
                    if(rs != null) try { rs.close(); } catch(Exception e) {}
                    if(ps != null) try { ps.close(); } catch(Exception e) {}
                    if(conn != null) try { conn.close(); } catch(Exception e) {}
                }
            %>
        </select><br><br>

        <label>Description:</label><br>
        <textarea name="description" rows="4" cols="50"></textarea><br><br>

        <label>Select File:</label>
        <input type="file" name="file" required><br><br>

        <input type="submit" value="Upload Assignment">
    </form>
</body>
</html>