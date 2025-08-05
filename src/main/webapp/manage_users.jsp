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
    int recordsPerPage = 10;
    if (request.getParameter("page") != null) {
        try {
            currentPage = Integer.parseInt(request.getParameter("page"));
        } catch (NumberFormatException e) {
            currentPage = 1;
        }
    }

    String searchTerm = request.getParameter("search") != null ? request.getParameter("search").trim() : "";
    int offset = (currentPage - 1) * recordsPerPage;
    int totalRecords = 0;
    List<Map<String, String>> users = new ArrayList<>();

    try (Connection conn = DBConnection.getConnection()) {
        String whereClause = "WHERE role = 'student'";
        if (!searchTerm.isEmpty()) {
            whereClause += " AND full_name LIKE ?";
        }

        // Count query
        String countSql = "SELECT COUNT(*) FROM users " + whereClause;
        try (PreparedStatement countStmt = conn.prepareStatement(countSql)) {
            if (!searchTerm.isEmpty()) {
                countStmt.setString(1, "%" + searchTerm + "%");
            }
            try (ResultSet rs = countStmt.executeQuery()) {
                if (rs.next()) {
                    totalRecords = rs.getInt(1);
                }
            }
        }

        // Select users
        String userSql = "SELECT full_name, email, status FROM users " + whereClause + " ORDER BY full_name ASC LIMIT ? OFFSET ?";
        try (PreparedStatement userStmt = conn.prepareStatement(userSql)) {
            int idx = 1;
            if (!searchTerm.isEmpty()) {
                userStmt.setString(idx++, "%" + searchTerm + "%");
            }
            userStmt.setInt(idx++, recordsPerPage);
            userStmt.setInt(idx, offset);

            try (ResultSet rs = userStmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> user = new HashMap<>();
                    user.put("full_name", rs.getString("full_name"));
                    user.put("email", rs.getString("email"));
                    user.put("status", rs.getString("status"));  // Fixed line
                    users.add(user);
                }
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    int totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Students - Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5">
    <h3 class="mb-4">Manage Users <small class="text-muted">(Students)</small></h3>

    <form method="get" class="row mb-3">
        <div class="col-md-6">
            <input type="text" name="search" value="<%= searchTerm %>" class="form-control" placeholder="Search by name...">
        </div>
        <div class="col-md-2">
            <button type="submit" class="btn btn-primary">Search</button>
        </div>
    </form>

    <table class="table table-bordered table-striped">
        <thead class="table-light">
            <tr>
                <th>Full Name</th>
                <th>Email</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
        <%
            if (users.isEmpty()) {
        %>
            <tr>
                <td colspan="4" class="text-center text-danger">No users found.</td>
            </tr>
        <%
            } else {
                for (Map<String, String> user : users) {
        %>
            <tr>
                <td><%= user.get("full_name") %></td>
                <td><%= user.get("email") %></td>
                <td><%= user.get("status") %></td>
                <td>
                    <!-- Edit Button -->
                    <button class="btn btn-sm btn-warning" onclick="openEditModal('<%= user.get("email") %>', '<%= user.get("full_name") %>')">Edit</button>

                    <!-- Delete Button -->
                    <a href="DeleteUserServlet?email=<%= user.get("email") %>" class="btn btn-sm btn-danger" onclick="return confirm('Are you sure you want to delete this user?')">Delete</a>

                    <!-- Toggle Status -->
                    <form action="ToggleUserStatusServlet" method="post" style="display:inline;">
                        <input type="hidden" name="email" value="<%= user.get("email") %>">
                        <button type="submit" class="btn btn-sm btn-secondary">Toggle Status</button>
                    </form>
                </td>
            </tr>
        <%
                }
            }
        %>
        </tbody>
    </table>

    <!-- Pagination -->
    <nav>
        <ul class="pagination justify-content-center">
            <% for (int i = 1; i <= totalPages; i++) { %>
                <li class="page-item <%= (i == currentPage) ? "active" : "" %>">
                    <a class="page-link" href="manage_users.jsp?page=<%= i %>&search=<%= searchTerm %>"><%= i %></a>
                </li>
            <% } %>
        </ul>
    </nav>
</div>

<!-- Edit Modal -->
<div class="modal fade" id="editModal" tabindex="-1" aria-labelledby="editModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <form action="UpdateUserServlet" method="post" class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Edit User</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" name="email" id="editEmail">
        <div class="mb-3">
            <label for="editName" class="form-label">Full Name</label>
            <input type="text" name="full_name" class="form-control" id="editName" required>
        </div>
      </div>
      <div class="modal-footer">
        <button type="submit" class="btn btn-success">Update</button>
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
      </div>
    </form>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function openEditModal(email, name) {
        document.getElementById("editEmail").value = email;
        document.getElementById("editName").value = name;
        var editModal = new bootstrap.Modal(document.getElementById("editModal"));
        editModal.show();
    }
</script>
</body>
