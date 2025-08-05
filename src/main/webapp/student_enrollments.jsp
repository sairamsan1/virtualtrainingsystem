<%@ page import="java.sql.*, com.project.DBConnection" %>
<%@ page session="true" %>
<%
    String email = (String) session.getAttribute("email");
    String role = (String) session.getAttribute("role");

    if (email == null || role == null || !role.equals("student")) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }

    int studentId = -1;
    try (Connection conn = DBConnection.getConnection()) {
        PreparedStatement ps = conn.prepareStatement("SELECT id FROM users WHERE email = ?");
        ps.setString(1, email);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            studentId = rs.getInt("id");
        }
        rs.close();
        ps.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>📚 My Enrolled Trainings</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            padding: 40px;
            background: #f4f9ff;
        }
        h2 {
            text-align: center;
            margin-bottom: 30px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background: #fff;
            box-shadow: 0 0 8px rgba(0,0,0,0.1);
            border-radius: 8px;
            overflow: hidden;
        }
        th, td {
            padding: 14px 16px;
            border-bottom: 1px solid #eee;
            text-align: left;
        }
        th {
            background-color: #007bff;
            color: white;
        }
        .btn {
            padding: 6px 12px;
            background-color: #28a745;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 13px;
        }
        .btn:hover {
            background-color: #218838;
        }
        .disabled {
            color: #aaa;
        }
        .back-link {
            display: inline-block;
            margin-top: 20px;
            color: #007bff;
            text-decoration: none;
        }
        .back-link:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>

<h2>📚 My Enrolled Trainings</h2>

<table>
    <tr>
        <th>Training Title</th>
        <th>Trainer</th>
        <th>Duration</th>
        <th>Enrollment Date</th>
        <th>Status</th>
        <th>Certificate</th>
    </tr>
<%
    try (Connection conn = DBConnection.getConnection()) {
        String sql = "SELECT e.id AS enrollment_id, t.id AS training_id, t.title, t.duration, t.trainer_email, " +
                     "e.enrollment_date, e.status, e.certificate_id " +
                     "FROM enrollments e " +
                     "JOIN trainings t ON e.training_id = t.id " +
                     "WHERE e.student_id = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, studentId);
        ResultSet rs = ps.executeQuery();

        boolean found = false;

        while (rs.next()) {
            found = true;
            int trainingId = rs.getInt("training_id");
            String title = rs.getString("title");
            String trainerEmail = rs.getString("trainer_email");
            String trainerName = "N/A";

            // Get trainer full name
            try (PreparedStatement trainerPs = conn.prepareStatement("SELECT full_name FROM users WHERE email = ?")) {
                trainerPs.setString(1, trainerEmail);
                try (ResultSet trainerRs = trainerPs.executeQuery()) {
                    if (trainerRs.next()) {
                        trainerName = trainerRs.getString("full_name");
                    }
                }
            }

            String duration = rs.getString("duration");
            Timestamp enrollmentDate = rs.getTimestamp("enrollment_date");
            String status = rs.getString("status");
            String certId = rs.getString("certificate_id");

            // Format duration
            String durationFormatted = duration;
            try {
                if (duration != null && duration.matches(".\\d+.*hour.")) {
                    int hours = Integer.parseInt(duration.replaceAll("[^0-9]", ""));
                    int weeks = (int) Math.ceil(hours / 40.0);
                    durationFormatted = weeks + (weeks == 1 ? " week" : " weeks");
                }
            } catch (Exception ex) {
                durationFormatted = duration;
            }
%>
    <tr>
        <td><%= title %></td>
        <td><%= trainerName %></td>
        <td><%= durationFormatted %></td>
        <td><%= enrollmentDate.toString().split(" ")[0] %></td>
        <td>
            <% if ("completed".equalsIgnoreCase(status)) { %>
                ✅ Completed
            <% } else { %>
                ⏳ In Progress
            <% } %>
        </td>
        <td>
            <% if ("completed".equalsIgnoreCase(status)) { %>
                <form method="post" action="GenerateCertificateServlet" style="display:inline;">
                    <input type="hidden" name="trainingId" value="<%= trainingId %>" />
                    <button type="submit" class="btn">
                        <%= certId != null ? "Download Again" : "Download Certificate" %>
                    </button>
                </form>
            <% } else { %>
                <span class="disabled">Not Available</span>
            <% } %>
        </td>
    </tr>
<%
        }

        rs.close();
        ps.close();

        if (!found) {
%>
    <tr>
        <td colspan="6" style="text-align:center;">No enrollments found.</td>
    </tr>
<%
        }
    } catch (Exception e) {
%>
    <tr>
        <td colspan="6" style="color:red;">Error: <%= e.getMessage() %></td>
    </tr>
<%
    }
%>
</table>

<a href="student_dashboard.jsp" class="back-link">← Back to Dashboard</a>

</body>
</html>