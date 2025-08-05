<%@ page import="java.sql.*, com.project.DBConnection" %>
<%@ page session="true" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String email = (String) session.getAttribute("email");
    if (email == null || !"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }

    int totalUsers = 0, totalTrainers = 0, totalTrainings = 0, totalEnrollments = 0;
    Connection conn = null;
    try {
        conn = DBConnection.getConnection();

        PreparedStatement ps1 = conn.prepareStatement("SELECT COUNT(*) FROM users WHERE role='student'");
        ResultSet rs1 = ps1.executeQuery();
        if (rs1.next()) totalUsers = rs1.getInt(1);
        rs1.close(); ps1.close();

        PreparedStatement ps2 = conn.prepareStatement("SELECT COUNT(*) FROM users WHERE role='trainer'");
        ResultSet rs2 = ps2.executeQuery();
        if (rs2.next()) totalTrainers = rs2.getInt(1);
        rs2.close(); ps2.close();

        PreparedStatement ps3 = conn.prepareStatement("SELECT COUNT(*) FROM trainings");
        ResultSet rs3 = ps3.executeQuery();
        if (rs3.next()) totalTrainings = rs3.getInt(1);
        rs3.close(); ps3.close();

        PreparedStatement ps4 = conn.prepareStatement("SELECT COUNT(*) FROM enrollments");
        ResultSet rs4 = ps4.executeQuery();
        if (rs4.next()) totalEnrollments = rs4.getInt(1);
        rs4.close(); ps4.close();

    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Admin Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; font-family: 'Segoe UI', sans-serif; }
        .sidebar { height: 100vh; position: fixed; width: 240px; background-color: #343a40; padding-top: 30px; }
        .sidebar a { color: #adb5bd; display: block; padding: 12px 20px; text-decoration: none; }
        .sidebar a.active, .sidebar a:hover { background-color: #495057; color: #fff; }
        .main { margin-left: 240px; padding: 30px; }
        .card { border-radius: 12px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); transition: 0.3s ease; }
        .card:hover { transform: translateY(-4px); }
        table { background: white; }
        .modal { display: none; position: fixed; z-index: 1050; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(0, 0, 0, 0.5); }
        .modal-content { margin: 10% auto; padding: 20px; background-color: #fff; border-radius: 10px; width: 400px; }
        .close { float: right; font-size: 24px; cursor: pointer; }
    </style>
    <script>
        function showProfileModal() {
            document.getElementById("profileModal").style.display = "block";
        }
        function closeModal() {
            document.getElementById("profileModal").style.display = "none";
        }
        function filterTrainings() {
            let input = document.getElementById("trainingSearch").value.toLowerCase();
            let rows = document.querySelectorAll("#trainingsTable tbody tr");
            rows.forEach(row => {
                let title = row.cells[1].innerText.toLowerCase();
                row.style.display = title.includes(input) ? "" : "none";
            });
        }
    </script>
</head>
<body>
<div class="sidebar">
    <div class="text-center text-white mb-4">
        <h4>Admin Panel</h4>
        <p class="small">Welcome, <%= email %></p>
    </div>
    <a href="admin_dashboard.jsp" class="active"><i class="bi bi-speedometer2"></i> Dashboard</a>
    <a href="manage_users.jsp"><i class="bi bi-people"></i> Manage Users</a>
    <a href="manage_trainers.jsp"><i class="bi bi-person-badge"></i> Manage Trainers</a>
    <a href="admin_enrollments.jsp"><i class="bi bi-journal-text"></i> View Enrollments</a>
    <a href="add_training.jsp"><i class="bi bi-plus-circle"></i> Add Training</a>
    <a href="#" onclick="showProfileModal()"><i class="bi bi-person-circle"></i> Admin Profile</a>
    <a href="admin_ai_logs.jsp">AI Logs</a>
    <a href="LogoutServlet"><i class="bi bi-box-arrow-right"></i> Logout</a>
</div>

<div class="main">
    <div class="mb-4">
        <h2 class="fw-bold">📊 Dashboard Overview</h2>
        <p class="text-muted">Quick stats of platform activities</p>
    </div>
    <div class="row g-4 mb-4">
        <div class="col-md-3">
            <div class="card p-3 text-center bg-light">
                <h5>Total Students</h5>
                <h3 class="text-primary"><%= totalUsers %></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card p-3 text-center bg-light">
                <h5>Total Trainers</h5>
                <h3 class="text-success"><%= totalTrainers %></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card p-3 text-center bg-light">
                <h5>Total Trainings</h5>
                <h3 class="text-warning"><%= totalTrainings %></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card p-3 text-center bg-light">
                <h5>Total Enrollments</h5>
                <h3 class="text-danger"><%= totalEnrollments %></h3>
            </div>
        </div>
    </div>

    <div class="mb-4">
        <a href="admin_enrollments.jsp" class="btn btn-outline-dark">📄 View All Enrollments</a>
        <a href="add_training.jsp" class="btn btn-success float-end">➕ Add New Training</a>
    </div>

    <div class="mb-3">
        <h4>📚 All Trainings</h4>
        <input type="text" id="trainingSearch" onkeyup="filterTrainings()" class="form-control mb-3" placeholder="Search trainings by title...">
        <table class="table table-hover" id="trainingsTable">
            <thead class="table-light">
                <tr>
                    <th>ID</th>
                    <th>Title</th>
                    <th>Description</th>
                    <th>Trainer</th>
                    <th>Start</th>
                    <th>End</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <%
                    try {
                        PreparedStatement ps = conn.prepareStatement(
                            "SELECT t.*, u.full_name AS trainer FROM trainings t LEFT JOIN users u ON t.trainer_id = u.id"
                        );
                        ResultSet rs = ps.executeQuery();
                        while (rs.next()) {
                %>
                <tr>
                    <td><%= rs.getInt("id") %></td>
                    <td><%= rs.getString("title") %></td>
                    <td><%= rs.getString("description") %></td>
                    <td><%= rs.getString("trainer") != null ? rs.getString("trainer") : "Not Assigned" %></td>
                    <td><%= rs.getString("start_date") %></td>
                    <td><%= rs.getString("end_date") %></td>
                    <td>
                        <a class="btn btn-sm btn-outline-primary" href="edit_training.jsp?id=<%= rs.getInt("id") %>">Edit</a>
                        <a class="btn btn-sm btn-outline-danger" href="DeleteTrainingServlet?id=<%= rs.getInt("id") %>" onclick="return confirm('Delete this training?')">Delete</a>
                    </td>
                </tr>
                <%
                        }
                        rs.close(); ps.close(); conn.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                %>
            </tbody>
        </table>
    </div>

    <form action="SendTrainingReminders" method="get" class="text-center mt-4">
        <button type="submit" class="btn btn-warning">📧 Send Training Reminders</button>
    </form>
</div>

<!-- Profile Modal -->
<div id="profileModal" class="modal">
    <div class="modal-content">
        <span class="close" onclick="closeModal()">&times;</span>
        <h4>Admin Profile</h4>
        <p><strong>Name:</strong> Administrator</p>
        <p><strong>Email:</strong> <%= email %></p>
        <p><strong>Role:</strong> Admin</p>
    </div>
</div>
</body>
</html>