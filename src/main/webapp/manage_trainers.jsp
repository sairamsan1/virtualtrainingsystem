<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, com.project.DBConnection" %>
<%@ page session="true" %>
<%
    String email = (String) session.getAttribute("email");
    String role = (String) session.getAttribute("role");
    if (email == null || !"admin".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    int currentPage = 1;  
    try {
        currentPage = Integer.parseInt(request.getParameter("page"));
    } catch (Exception e) {
        currentPage = 1;
    }

    String search = request.getParameter("search") != null ? request.getParameter("search").trim() : "";  
    int limit = 10;  
    int offset = (currentPage - 1) * limit;  
    int totalRecords = 0;  
    List<Map<String, String>> trainerList = new ArrayList<>();  

    try (Connection conn = DBConnection.getConnection()) {  
        String baseQuery = "FROM users WHERE role='trainer' ";
        String countQuery = "SELECT COUNT(*) " + baseQuery;
        String selectQuery = "SELECT * " + baseQuery;

        if (!search.isEmpty()) {
            countQuery += "AND full_name LIKE ? ";
            selectQuery += "AND full_name LIKE ? ";
        }

        selectQuery += "ORDER BY full_name ASC LIMIT ? OFFSET ?";

        try (PreparedStatement countStmt = conn.prepareStatement(countQuery)) {
            if (!search.isEmpty()) {
                countStmt.setString(1, "%" + search + "%");
            }
            ResultSet countRs = countStmt.executeQuery();
            if (countRs.next()) {
                totalRecords = countRs.getInt(1);
            }
        }

        try (PreparedStatement selectStmt = conn.prepareStatement(selectQuery)) {
            int paramIndex = 1;
            if (!search.isEmpty()) {
                selectStmt.setString(paramIndex++, "%" + search + "%");
            }
            selectStmt.setInt(paramIndex++, limit);
            selectStmt.setInt(paramIndex, offset);

            ResultSet rs = selectStmt.executeQuery();
            while (rs.next()) {
                Map<String, String> trainer = new HashMap<>();
                trainer.put("id", rs.getString("id"));
                trainer.put("name", rs.getString("full_name"));
                trainer.put("email", rs.getString("email"));
                trainer.put("mobile", rs.getString("mobile"));
                trainer.put("gender", rs.getString("gender"));
                trainer.put("specialization", rs.getString("specialization"));
                trainer.put("status", rs.getString("status")); // "active" or "inactive"
                trainerList.add(trainer);
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    int totalPages = (int) Math.ceil((double) totalRecords / limit);
%>

<!DOCTYPE html>
<html>
<head>
    <title>Manage Trainers</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container mt-4">
    <h2 class="mb-4">Manage Trainers</h2>

    <form method="get" class="mb-3 d-flex">
        <input type="text" name="search" class="form-control me-2" placeholder="Search by name" value="<%= search %>">
        <button type="submit" class="btn btn-primary">Search</button>
    </form>

    <table class="table table-bordered">
        <thead class="table-light">
            <tr>
                <th>ID</th><th>Name</th><th>Email</th><th>Status</th><th>Actions</th>
            </tr>
        </thead>
        <tbody>
        <%
            for (Map<String, String> trainer : trainerList) {
        %>
            <tr>
                <td><%= trainer.get("id") %></td>
                <td><%= trainer.get("name") %></td>
                <td><%= trainer.get("email") %></td>
                <td><%= "active".equalsIgnoreCase(trainer.get("status")) ? "Active" : "Inactive" %></td>
                <td>
                    <form method="post" action="ToggleUserStatusServlet" style="display:inline-block;">
                        <input type="hidden" name="id" value="<%= trainer.get("id") %>">
                        <button class="btn btn-sm btn-warning">Toggle Status</button>
                    </form>

                    <form method="post" action="ResetPasswordServlet" style="display:inline-block;">
                        <input type="hidden" name="userId" value="<%= trainer.get("id") %>">
                        <button class="btn btn-sm btn-secondary">Reset Password</button>
                    </form>

                    <button type="button" class="btn btn-sm btn-info" onclick="openEditModal(
                        '<%= trainer.get("id") %>',
                        '<%= trainer.get("name").replace("'", "\\'") %>',
                        '<%= trainer.get("email") %>',
                        '<%= trainer.get("mobile") %>',
                        '<%= trainer.get("gender") %>',
                        '<%= trainer.get("specialization") %>'
                    )">Edit</button>

                    <form method="post" action="DeleteTrainerServlet" onsubmit="return confirm('Are you sure you want to delete this trainer?');" style="display:inline-block;">
                        <input type="hidden" name="id" value="<%= trainer.get("id") %>">
                        <button class="btn btn-sm btn-danger">Delete</button>
                    </form>
                </td>
            </tr>
        <%
            }
            if (trainerList.isEmpty()) {
        %>
            <tr>
                <td colspan="5" class="text-center">No trainers found.</td>
            </tr>
        <%
            }
        %>
        </tbody>
    </table>

    <% if (totalPages > 1) { %>
    <nav>
        <ul class="pagination">
            <% for (int i = 1; i <= totalPages; i++) { %>
                <li class="page-item <%= (i == currentPage) ? "active" : "" %>">
                    <form method="get" class="d-inline">
                        <input type="hidden" name="search" value="<%= search %>">
                        <input type="hidden" name="page" value="<%= i %>">
                        <button class="page-link" type="submit"><%= i %></button>
                    </form>
                </li>
            <% } %>
        </ul>
    </nav>
    <% } %>

    <!-- EDIT MODAL -->
    <div class="modal" tabindex="-1" id="editModal">
        <div class="modal-dialog">
            <form method="post" action="UpdateTrainerServlet" class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Edit Trainer</h5>
                    <button type="button" class="btn-close" onclick="closeEditModal()"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="id" id="editId">
                    <div class="mb-2">
                        <label>Name:</label>
                        <input type="text" name="full_name" id="editName" class="form-control" required>
                    </div>
                    <div class="mb-2">
                        <label>Email:</label>
                        <input type="email" name="email" id="editEmail" class="form-control" required>
                    </div>
                    <div class="mb-2">
                        <label>Mobile:</label>
                        <input type="text" name="mobile" id="editMobile" class="form-control">
                    </div>
                    <div class="mb-2">
                        <label>Gender:</label>
                        <select name="gender" id="editGender" class="form-control">
                            <option value="">-- Select --</option>
                            <option value="Male">Male</option>
                            <option value="Female">Female</option>
                        </select>
                    </div>
                    <div class="mb-2">
                        <label>Specialization:</label>
                        <input type="text" name="specialization" id="editSpecialization" class="form-control">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="submit" class="btn btn-success">Update</button>
                    <button type="button" class="btn btn-secondary" onclick="closeEditModal()">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openEditModal(id, name, email, mobile, gender, specialization) {
            document.getElementById('editId').value = id;
            document.getElementById('editName').value = name;
            document.getElementById('editEmail').value = email;
            document.getElementById('editMobile').value = mobile;
            document.getElementById('editGender').value = gender;
            document.getElementById('editSpecialization').value = specialization;

            document.getElementById('editModal').style.display = 'block';
            document.getElementById('editModal').classList.add('show');
        }

        function closeEditModal() {
            document.getElementById('editModal').style.display = 'none';
            document.getElementById('editModal').classList.remove('show');
        }
    </script>
</body>
</html>