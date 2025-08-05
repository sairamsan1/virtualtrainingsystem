<!DOCTYPE html><%@ page import="java.sql.*, com.project.DBConnection" %> <%@ page session="true" %> <% String role = (String) session.getAttribute("role"); String email = (String) session.getAttribute("email"); if (email == null || !"trainer".equals(role)) { response.sendRedirect("login.jsp?msg=unauthorized"); return; }

int trainerId = -1;
int trainingId = -1;
Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

%>

<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Trainer Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600&display=swap" rel="stylesheet">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Inter', sans-serif; }
        body { background-color: var(--bg); color: var(--text); display: flex; min-height: 100vh; transition: background-color 0.3s ease; }
        :root {
            --bg: #f1f5f9;
            --text: #0f172a;
            --card: #ffffff;
            --primary: #3b82f6;
        }
        .dark-mode {
            --bg: #0f172a;
            --text: #f1f5f9;
            --card: #1e293b;
            --primary: #2563eb;
        }
        .sidebar {
            width: 250px;
            background: var(--card);
            padding: 30px 20px;
            color: var(--text);
            border-right: 1px solid #ccc;
        }
        .sidebar h2 { text-align: center; margin-bottom: 30px; font-size: 22px; }
        .sidebar ul { list-style: none; }
        .sidebar ul li { margin: 20px 0; }
        .sidebar ul li a {
            text-decoration: none;
            color: var(--text);
            display: flex;
            align-items: center;
            gap: 10px;
            font-weight: 500;
        }
        .sidebar ul li a:hover { color: var(--primary); }
        .main { flex-grow: 1; padding: 40px; overflow-y: auto; }
        .section {
            background: var(--card);
            padding: 30px;
            margin-bottom: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.05);
        }
        h3 { margin-bottom: 20px; font-size: 20px; color: var(--text); }
        select, input[type="text"], textarea, input[type="file"], input[type="date"] {
            width: 100%;
            padding: 12px;
            margin-bottom: 20px;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            font-size: 14px;
        }
        input[type="submit"], button {
            background-color: var(--primary);
            color: white;
            padding: 12px 20px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
        }
        .chat-box {
            height: 250px;
            overflow-y: auto;
            padding: 15px;
            border: 1px solid #e2e8f0;
            background: #f8fafc;
            border-radius: 10px;
            margin-bottom: 15px;
        }
        .chat-message {
            padding: 10px 15px;
            margin-bottom: 10px;
            border-radius: 12px;
            max-width: 70%;
            line-height: 1.4;
        }
        .chat-message.trainer {
            background-color: var(--primary);
            color: white;
            margin-left: auto;
        }
        .chat-message.student {
            background-color: #e2e8f0;
            color: #0f172a;
        }
    </style>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body>
<div class="sidebar">
    <h2>Trainer Panel</h2>
    <ul>
        <li><a href="#" onclick="toggleTheme()"><i class="fas fa-adjust"></i> Toggle Theme</a></li>
        <li><a href="trainer_dashboard.jsp"><i class="fas fa-home"></i> Dashboard</a></li>
        <li><a href="upload_material.jsp"><i class="fas fa-upload"></i> Upload Material</a></li>
        <li><a href="trainer_materials.jsp"><i class="fas fa-book"></i> My Materials</a></li>
        <li><a href="trainer_trainings.jsp"><i class="fas fa-chalkboard-teacher"></i> My Trainings</a></li>
        <li><a href="view_assignments.jsp"><i class="fas fa-tasks"></i> View Assignments</a></li>
          <li> <a href="AIChat.jsp">AI CHAT</a></li>
        <li><a href="LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
     
    </ul>
</div>
<div class="main">
    <div class="section">
        <h3>Welcome, <%= email %></h3>
        <% try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement("SELECT id FROM users WHERE email = ?");
            ps.setString(1, email);
            rs = ps.executeQuery();
            if (rs.next()) trainerId = rs.getInt("id");
            rs.close(); ps.close();
            ps = conn.prepareStatement("SELECT id FROM trainings WHERE trainer_email = ? ORDER BY id DESC LIMIT 1");
            ps.setString(1, email);
            rs = ps.executeQuery();
            if (rs.next()) trainingId = rs.getInt("id");
            rs.close(); ps.close();
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
        } %>
    </div><div class="section">
    <h3>💬 Chat with Students</h3>
    <label>Select Student:</label>
    <select id="studentSelect">
        <option value="">-- Select Student --</option>
        <% try {
            ps = conn.prepareStatement("SELECT DISTINCT u.id, u.full_name FROM users u JOIN enrollments e ON u.id = e.student_id JOIN trainings t ON t.id = e.training_id WHERE t.trainer_email = ?");
            ps.setString(1, email);
            rs = ps.executeQuery();
            while (rs.next()) {
        %>
        <option value="<%= rs.getInt("id") %>"><%= rs.getString("full_name") %></option>
        <% } rs.close(); ps.close(); } catch (Exception e) { out.println("<option>Error loading students</option>"); } %>
    </select>
    <div class="chat-box" id="chatBox"></div>
    <form id="chatForm">
        <input type="hidden" id="senderId" value="<%= trainerId %>">
        <input type="hidden" id="trainingId" value="<%= trainingId %>">
        <input type="text" id="message" placeholder="Type your message..." required>
        <button type="submit">Send</button>
    </form>
</div>

<div class="section">
    <h3>📄 Upload Assignment to Student</h3>
    <form method="post" action="UploadAssignmentServlet" enctype="multipart/form-data">
        <label>Select Training:</label>
        <select name="training_id" required>
            <% ps = conn.prepareStatement("SELECT id, title FROM trainings WHERE trainer_email = ?");
               ps.setString(1, email);
               rs = ps.executeQuery();
               while (rs.next()) { %>
            <option value="<%= rs.getInt("id") %>"><%= rs.getString("title") %></option>
            <% } rs.close(); ps.close(); %>
        </select>
        <label>Select Student:</label>
        <select name="student_id" required>
            <% ps = conn.prepareStatement("SELECT DISTINCT u.id, u.full_name FROM users u JOIN enrollments e ON u.id = e.student_id JOIN trainings t ON t.id = e.training_id WHERE t.trainer_email = ?");
               ps.setString(1, email);
               rs = ps.executeQuery();
               while (rs.next()) { %>
            <option value="<%= rs.getInt("id") %>"><%= rs.getString("full_name") %></option>
            <% } rs.close(); ps.close(); conn.close(); %>
        </select>
        <label>Description:</label>
        <textarea name="description" required></textarea>
        <label>Upload File:</label>
        <input type="file" name="assignment_file" required>
        <label>Deadline:</label>
        <input type="date" name="deadline" required>
        <input type="submit" value="Upload Assignment">
    </form>
</div>

</div>
<script>
function toggleTheme() {
    document.body.classList.toggle('dark-mode');
}$(document).ready(function () { let receiverId = null; function escapeHtml(text) { return text.replace(/["&'<>]/g, function (a) { return { '"': '"', '&': '&', "'": ''', '<': '<', '>': '>' }[a]; }); } $('#studentSelect').change(function () { receiverId = $(this).val(); if (receiverId) loadMessages(); else $('#chatBox').empty(); });

$('#chatForm').submit(function (e) {
    e.preventDefault();
    const message = $('#message').val().trim();
    const senderId = $('#senderId').val();
    const trainingId = $('#trainingId').val();
    if (!receiverId || !message) return;
    $.post("SendMessageServlet", {
        sender_id: senderId,
        receiver_id: receiverId,
        training_id: trainingId,
        message: message
    }, function () {
        $('#message').val('');
        loadMessages();
    });
});

function loadMessages() {
    const senderId = $('#senderId').val();
    const trainingId = $('#trainingId').val();
    $.getJSON("GetMessagesServlet", {
        sender_id: senderId,
        receiver_id: receiverId,
        training_id: trainingId
    }, function (data) {
        $('#chatBox').empty();
        data.forEach(function (msg) {
            const cls = msg.senderId == senderId ? 'trainer' : 'student';
            $('#chatBox').append('<div class="chat-message ' + cls + '">' + escapeHtml(msg.message) + '</div>');
        });
    });
}

// Auto-refresh chat every 5 seconds
setInterval(() => {
    if (receiverId) loadMessages();
}, 5000);

}); </script>

</body>
</html>