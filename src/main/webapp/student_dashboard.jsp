<%@ page import="java.sql.*, com.project.DBConnection" %> <%@ page session="true" %> <% response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); response.setHeader("Pragma", "no-cache"); response.setDateHeader("Expires", 0);

String role = (String) session.getAttribute("role"); String email = (String) session.getAttribute("email");

if (email == null || !"student".equals(role)) { response.sendRedirect("login.jsp?msg=unauthorized"); return; }

String photo = "uploads/profile_photos/default_avatar.png";

try (Connection conn = DBConnection.getConnection()) { PreparedStatement ps = conn.prepareStatement("SELECT photo FROM users WHERE email = ?"); ps.setString(1, email); ResultSet rs = ps.executeQuery(); if (rs.next()) { String dbPhoto = rs.getString("photo"); if (dbPhoto != null && !dbPhoto.trim().isEmpty()) { photo = "uploads/profile_photos/" + dbPhoto; } } } catch (Exception e) { e.printStackTrace(); } %>

<!DOCTYPE html><html lang="en"><head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background-color: #f8f9fa;
            color: #333;
        }
        .sidebar {
            height: 100vh;
            background: #fff;
            border-right: 1px solid #ddd;
            padding: 20px;
        }
        .sidebar img {
            width: 100px;
            height: 100px;
            object-fit: cover;
            border-radius: 50%;
            margin-bottom: 15px;
            border: 2px solid #0d6efd;
        }
        .sidebar h4 {
            font-size: 16px;
            text-align: center;
            margin-bottom: 20px;
        }
        .sidebar a {
            display: block;
            margin: 10px 0;
            padding: 10px 15px;
            color: #333;
            border-radius: 6px;
            text-decoration: none;
            transition: 0.2s;
        }
        .sidebar a:hover, .sidebar a.active {
            background-color: #0d6efd;
            color: #fff;
        }
        .main {
            margin-left: 250px;
            padding: 30px;
        }
        .card {
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            padding: 20px;
            margin-bottom: 30px;
        }
        .card h5 {
            margin-bottom: 20px;
            color: #0d6efd;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        table th, table td {
            padding: 12px;
            border: 1px solid #dee2e6;
        }
        table th {
            background-color: #0d6efd;
            color: white;
        }
        .task-box {
            border-left: 5px solid #0d6efd;
            padding: 10px;
            margin-bottom: 10px;
            background-color: #f1f9ff;
            border-radius: 4px;
        }
        .toggle-mode-btn {
            margin-top: 20px;
            width: 100%;
        }
        .dark-mode {
            background-color: #18191a !important;
            color: #f1f1f1 !important;
        }
        .dark-mode .sidebar, .dark-mode .card {
            background-color: #242526;
        }
        .dark-mode .task-box {
            background-color: #333;
            color: #f1f1f1;
        }
    </style>
</head>
<body>
<div class="d-flex">
    <div class="sidebar d-flex flex-column align-items-center">
        <img src="<%= request.getContextPath() + "/" + photo %>" alt="Profile">
        <h4><%= email %></h4>
        <a href="available_courses.jsp">📘 Courses</a>
        <a href="student_profile.jsp">🙋 My Profile</a>
        <a href="student_enrollments.jsp">📝 Enrollments</a>
        <a href="chat.jsp">💬 Chat</a>
        <a href="view_materials.jsp">📄 Materials</a>
         <a href="AIChat.jsp">AI CHAT</a>
        <button class="btn btn-outline-primary toggle-mode-btn" onclick="toggleDarkMode()">🌗 Toggle Mode</button>
        <a href="LogoutServlet">🚪 Logout</a>
       
    </div>
    <div class="main">
        <div class="card">
            <h5>Welcome, Student!</h5>
            <div class="alert alert-info">Logged in as <strong><%= email %></strong></div>
            <p>Use the sidebar to navigate between your courses, materials, tasks, and more.</p>
        </div>
        <div class="card">
            <h5>📚 Your Enrolled Trainings</h5>
            <table>
                <tr>
                    <th>Title</th>
                    <th>Trainer</th>
                    <th>Start</th>
                    <th>End</th>
                    <th>Status</th>
                </tr>
                <%
                    try (Connection conn = DBConnection.getConnection()) {
                        PreparedStatement ps = conn.prepareStatement(
                            "SELECT t.title, t.trainer, t.start_date, t.end_date, e.status " +
                            "FROM enrollments e " +
                            "JOIN trainings t ON e.training_id = t.id " +
                            "JOIN users u ON e.student_id = u.id " +
                            "WHERE u.email = ?");
                        ps.setString(1, email);
                        ResultSet rs = ps.executeQuery();
                        while (rs.next()) {
                %>
                <tr>
                    <td><%= rs.getString("title") %></td>
                    <td><%= rs.getString("trainer") %></td>
                    <td><%= rs.getString("start_date") %></td>
                    <td><%= rs.getString("end_date") %></td>
                    <td><%= rs.getString("status") %></td>
                </tr>
                <%
                        }
                        rs.close();
                        ps.close();
                    } catch (Exception e) {
                        out.println("<tr><td colspan='5'>Error loading trainings</td></tr>");
                    }
                %>
            </table>
        </div>
        <div class="card">
            <h5>📄 Submitted Assignments</h5>
            <table>
                <tr>
                    <th>Training</th>
                    <th>Description</th>
                    <th>File</th>
                    <th>Uploaded</th>
                    <th>Marks</th>
                    <th>Comments</th>
                </tr>
                <%
                    try (Connection conn = DBConnection.getConnection()) {
                        PreparedStatement ps = conn.prepareStatement(
                            "SELECT a.*, t.title FROM assignments a " +
                            "JOIN trainings t ON a.training_id = t.id " +
                            "WHERE a.student_id = (SELECT id FROM users WHERE email = ?) " +
                            "ORDER BY a.upload_time DESC"
                        );
                        ps.setString(1, email);
                        ResultSet rs = ps.executeQuery();
                        while (rs.next()) {
                %>
                <tr>
                    <td><%= rs.getString("title") %></td>
                    <td><%= rs.getString("description") %></td>
                    <td><a href="assignments/<%= rs.getString("filename") %>" target="_blank">Download</a></td>
                    <td><%= rs.getTimestamp("upload_time") %></td>
                    <td><%= (rs.getObject("marks") != null) ? rs.getString("marks") : "Pending" %></td>
                    <td><%= (rs.getString("comments") != null) ? rs.getString("comments") : "Awaiting Feedback" %></td>
                </tr>
                <%
                        }
                        rs.close();
                        ps.close();
                    }
                %>
            </table>
        </div>
        <div class="card">
            <h5>📝 Your Assigned Tasks</h5>
            <%
                try (Connection conn = DBConnection.getConnection()) {
                    int studentId = -1;
                    PreparedStatement psUser = conn.prepareStatement("SELECT id FROM users WHERE email = ?");
                    psUser.setString(1, email);
                    ResultSet rsUser = psUser.executeQuery();
                    if (rsUser.next()) {
                        studentId = rsUser.getInt("id");
                    }
                    rsUser.close();
                    psUser.close();if (studentId != -1) {
                    PreparedStatement psTasks = conn.prepareStatement(
                        "SELECT title, description, due_date, created_at, is_completed FROM tasks WHERE student_id = ?"
                    );
                    psTasks.setInt(1, studentId);
                    ResultSet rsTasks = psTasks.executeQuery();

                    boolean hasTasks = false;
                    while (rsTasks.next()) {
                        hasTasks = true;
        %>
        <div class="task-box">
            <strong><%= rsTasks.getString("title") %></strong><br>
            <%= rsTasks.getString("description") %><br>
            <em>Due: <%= rsTasks.getDate("due_date") %> | Assigned: <%= rsTasks.getTimestamp("created_at") %></em><br>
            <em>Status: <%= rsTasks.getBoolean("is_completed") ? "✅ Completed" : "❌ Pending" %></em>
        </div>
        <%
                    }
                    if (!hasTasks) {
                        out.println("<p>No tasks assigned.</p>");
                    }
                    rsTasks.close();
                    psTasks.close();
                } else {
                    out.println("<p>User not found.</p>");
                }
            } catch (Exception e) {
                out.println("<p>Error loading tasks: " + e.getMessage() + "</p>");
                e.printStackTrace();
            }
        %>
    </div>
</div>

</div>
<script>
    function toggleDarkMode() {
        document.body.classList.toggle('dark-mode');
        localStorage.setItem('darkMode', document.body.classList.contains('dark-mode'));
    }
    window.onload = () => {
        if (localStorage.getItem('darkMode') === 'true') {
            document.body.classList.add('dark-mode');
        }
    }
</script>
</body>
</html>