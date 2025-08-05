<%@ page import="java.sql.*, com.project.DBConnection" %>
<%@ page session="true" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String email = (String) session.getAttribute("email");
    if (email == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    String fullName = "", mobile = "", gender = "", password = "", photo = "default.png";

    try {
        conn = DBConnection.getConnection();
        ps = conn.prepareStatement("SELECT * FROM users WHERE email = ?");
        ps.setString(1, email);
        rs = ps.executeQuery();
        if (rs.next()) {
            fullName = rs.getString("full_name");
            mobile = rs.getString("mobile");
            gender = rs.getString("gender");
            password = rs.getString("password");
            photo = rs.getString("photo") != null ? rs.getString("photo") : "default.png";
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (conn != null) conn.close();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Student Profile</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .profile-container {
            max-width: 700px;
            margin: 30px auto;
            background: #fff;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        .preview-img {
            max-height: 150px;
            margin-top: 10px;
            border-radius: 10px;
        }
    </style>
</head>
<body class="bg-light">
<div class="container">
    <div class="profile-container">
        <h3 class="mb-4">My Profile</h3>
        <form action="UpdateProfileAndPhotoServlet" method="post" enctype="multipart/form-data" onsubmit="return validateForm()">
            <input type="hidden" name="email" value="<%=email%>">

            <div class="mb-3">
                <label class="form-label">Full Name</label>
                <input type="text" name="full_name" class="form-control" value="<%=fullName%>" required>
            </div>

            <div class="mb-3">
                <label class="form-label">Mobile</label>
                <input type="text" name="mobile" class="form-control" value="<%=mobile%>" pattern="[6-9][0-9]{9}" required>
                <div class="form-text">Enter a 10-digit valid Indian phone number.</div>
            </div>

            <div class="mb-3">
                <label class="form-label">Gender</label>
                <select name="gender" class="form-select" required>
                    <option value="">Select Gender</option>
                    <option value="Male" <%= "Male".equals(gender) ? "selected" : "" %>>Male</option>
                    <option value="Female" <%= "Female".equals(gender) ? "selected" : "" %>>Female</option>
                    <option value="Other" <%= "Other".equals(gender) ? "selected" : "" %>>Other</option>
                </select>
            </div>

            <div class="mb-3">
                         <label for="password">New Password (optional)</label>
<div class="input-group mb-2">
    <input type="password" name="password" id="password" class="form-control" placeholder="Enter new password" minlength="6">
    <button type="button" class="btn btn-outline-secondary" onclick="togglePassword()">👁️</button>
</div>

<label for="confirmPassword">Confirm Password</label>
<div class="input-group mb-2">
    <input type="password" id="confirmPassword" class="form-control" placeholder="Confirm new password">
    <button type="button" class="btn btn-outline-secondary" onclick="toggleConfirmPassword()">👁️</button>
</div>

<small id="passwordHelp" class="form-text text-muted">
    Leave blank to keep current password. Must be at least 6 characters.
</small>
<div id="strengthMessage" style="font-size: 14px;"></div>
<div id="matchMessage" style="font-size: 14px;"></div>
            </div>
          <div class="mb-3">
    <label class="form-label">Current Photo</label><br>
    <img src="uploads/profile_photos/<%=photo != null && !photo.isEmpty() ? photo : "default.png"%>" 
         class="preview-img mb-2" 
         alt="Profile Photo" 
         style="max-height: 150px; border-radius: 10px;">
</div>

<div class="mb-3">
    <label class="form-label">Upload New Photo</label>
    <input type="file" name="photo" class="form-control" accept="image/*" onchange="previewImage(event)">
    <img id="newPhotoPreview" class="preview-img mt-2" style="display: none; max-height: 150px; border-radius: 10px;">
</div>
          
          

            <button type="submit" class="btn btn-primary">Update Profile</button>
        </form>
    </div>
</div>

<script>
function previewImage(event) {
    const input = event.target;
    const preview = document.getElementById("newPhotoPreview");

    if (input.files && input.files[0]) {
        const reader = new FileReader();
        reader.onload = function (e) {
            preview.src = e.target.result;
            preview.style.display = "block";
        };
        reader.readAsDataURL(input.files[0]);
    } else {
        preview.src = "";
        preview.style.display = "none";
    }
}

      function validateForm() {
        const mobile = document.querySelector('input[name="mobile"]').value;
        const mobilePattern = /^[6-9]\d{9}$/;
        if (!mobilePattern.test(mobile)) {
            alert("Please enter a valid 10-digit Indian mobile number.");
            return false;
        }
        return true;
    }
   function togglePassword() {
        const pwd = document.getElementById("password");
        pwd.type = pwd.type === "password" ? "text" : "password";
    }

    function toggleConfirmPassword() {
        const cpwd = document.getElementById("confirmPassword");
        cpwd.type = cpwd.type === "password" ? "text" : "password";
    }

    // Check password strength
    document.getElementById("password").addEventListener("input", function () {
        const pwd = this.value;
        const message = document.getElementById("strengthMessage");
        if (pwd.length === 0) {
            message.innerHTML = "";
            return;
        }
        if (pwd.length < 6) {
            message.style.color = "red";
            message.innerHTML = "❌ Too short";
        } else if (!/[A-Z]/.test(pwd) || !/[0-9]/.test(pwd)) {
            message.style.color = "orange";
            message.innerHTML = "⚠️ Weak (Add uppercase & numbers)";
        } else {
            message.style.color = "green";
            message.innerHTML = "✅ Strong password";
        }
        checkPasswordMatch();
    });

    // Check if passwords match
    document.getElementById("confirmPassword").addEventListener("input", checkPasswordMatch);

    function checkPasswordMatch() {
        const pwd = document.getElementById("password").value;
        const cpwd = document.getElementById("confirmPassword").value;
        const message = document.getElementById("matchMessage");

        if (pwd === "" && cpwd === "") {
            message.innerHTML = "";
            return;
        }

        if (pwd !== cpwd) {
            message.style.color = "red";
            message.innerHTML = "❌ Passwords do not match";
        } else {
            message.style.color = "green";
            message.innerHTML = "✅ Passwords match";
        }
    }
    </script>
</body>
</html>
