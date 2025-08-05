<%@ page import="java.sql.*, com.project.DBConnection" %>
<%@ page session="true" %>
<%
    String role = (String) session.getAttribute("role");
    String email = (String) session.getAttribute("email");

    if (role == null || !role.equals("student")) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Available Trainings</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f4f4f4;
            margin: 0;
            padding: 0;
        }
        .header {
            background: #007bff;
            color: white;
            padding: 15px 20px;
            display: flex;
            justify-content: space-between;
        }
        .header span {
            font-size: 16px;
        }
        .container {
            width: 90%;
            margin: auto;
            padding-top: 30px;
        }
        h2 {
            text-align: center;
            color: #333;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 25px;
            background: #fff;
            box-shadow: 0px 4px 8px rgba(0,0,0,0.05);
        }
        th, td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #007bff;
            color: white;
        }
        tr:hover {
            background-color: #f1f1f1;
        }
        input[type="submit"] {
            background-color: #28a745;
            border: none;
            color: white;
            padding: 8px 12px;
            cursor: pointer;
            border-radius: 4px;
        }
        input[type="submit"]:hover {
            background-color: #218838;
        }
        .message {
            text-align: center;
            margin-top: 20px;
            color: green;
            font-weight: bold;
        }
        .error {
            color: red;
        }
    </style>
    <script>
        function confirmEnroll() {
            return confirm("Are you sure you want to enroll in this training?");
        }
    </script>
</head>
<body>
    <div class="header">
        <span>Welcome, <%= email %> (Student)</span>
        <a href="logout.jsp" style="color: white; text-decoration: none;">Logout</a>
    </div>

    <div class="container">
        <h2>Available Trainings</h2>

        <% 
            String msg = request.getParameter("msg");
            if (msg != null) {
                if (msg.equals("enrolled")) {
        %>          <div class="message">Enrolled successfully!</div>
        <%      } else if (msg.equals("already")) { %>
                <div class="message error">You have already enrolled in this training.</div>
        <%      } else if (msg.equals("error")) { %>
                <div class="message error">Something went wrong. Please try again.</div>
        <%      }
            }
        %>

        <table>
            <tr>
                <th>Title</th>
                <th>Description</th>
                <th>Trainer</th>
                <th>Duration</th>
                <th>Action</th>
            </tr>
            <%
                Connection conn = null;
                PreparedStatement ps = null;
                ResultSet rs = null;

                try {
                    conn = DBConnection.getConnection();
                    String sql = "SELECT t.*, u.full_name AS trainer_name FROM trainings t " +
                                 "JOIN users u ON t.trainer_email = u.email " +
                                 "WHERE u.role = 'trainer'";
                    ps = conn.prepareStatement(sql);
                    rs = ps.executeQuery();

                    while (rs.next()) {
            %>
            <tr>
                <td><%= rs.getString("title") %></td>
                <td><%= rs.getString("description") %></td>
                <td><%= rs.getString("trainer_name") %></td>
                <td><%= rs.getString("duration") %></td>
                <td>
                    <form action="enroll" method="post" onsubmit="return confirmEnroll();">
                        <input type="hidden" name="training_id" value="<%= rs.getInt("id") %>">
                        <input type="submit" value="Enroll">
                    </form>
                </td>
            </tr>
            <%
                    }
                } catch (Exception e) {
                    out.println("<tr><td colspan='5' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
                    e.printStackTrace();
                } finally {
                    try { if (rs != null) rs.close(); } catch (Exception e) {}
                    try { if (ps != null) ps.close(); } catch (Exception e) {}
                    try { if (conn != null) conn.close(); } catch (Exception e) {}
                }
            %>
        </table>
    </div>
</body>
</html>