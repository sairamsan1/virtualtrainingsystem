<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Register - Virtual Training System</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f2f2f2;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .register-box {
            background: #fff;
            padding: 30px 40px;
            border-radius: 10px;
            box-shadow: 0px 4px 10px rgba(0,0,0,0.1);
            width: 400px;
        }
        .register-box h2 {
            text-align: center;
            margin-bottom: 25px;
        }
        .register-box input, .register-box select {
            width: 100%;
            padding: 12px 10px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 8px;
            font-size: 14px;
        }
        .register-box button {
            width: 100%;
            background-color: #007bff;
            color: white;
            border: none;
            padding: 12px;
            border-radius: 8px;
            font-size: 16px;
            cursor: pointer;
        }
        .register-box button:hover {
            background-color: #0056b3;
        }
        .message {
            text-align: center;
            margin-top: 10px;
            font-weight: bold;
        }
        .message.error {
            color: red;
        }
        .message.success {
            color: green;
        }
    </style>
    <script>
        function validateForm() {
            const password = document.getElementById("password").value;
            const confirm = document.getElementById("confirmPassword").value;
            if (password !== confirm) {
                alert("Passwords do not match.");
                return false;
            }
            return true;
        }

        function toggleSpecializationField() {
            const role = document.getElementById("role").value;
            const specializationDiv = document.getElementById("specializationDiv");
            const specializationInput = document.getElementById("specialization");

            if (role === "trainer") {
                specializationDiv.style.display = "block";
                specializationInput.required = true;
            } else {
                specializationDiv.style.display = "none";
                specializationInput.required = false;
            }
        }

        document.addEventListener("DOMContentLoaded", () => {
            document.getElementById("role").addEventListener("change", toggleSpecializationField);
        });
    </script>
</head>
<body>
<div class="register-box">
    <h2>Create Account</h2>

    <% String error = (String) request.getAttribute("error"); %>
    <% if (error != null) { %>
        <div class="message error"><%= error %></div>
    <% } %>

    <% if ("registered".equals(request.getParameter("msg"))) { %>
        <div class="message success">Registration successful! Please <a href="login.jsp">login</a>.</div>
    <% } %>

    <form action="register" method="post" onsubmit="return validateForm();" autocomplete="off">
        <input type="text" name="name" placeholder="Full Name" required autocomplete="off" />
        <input type="email" name="email" placeholder="Email Address" required autocomplete="off" />
        <input type="password" name="password" id="password" placeholder="Password" required autocomplete="new-password" />
        <input type="password" id="confirmPassword" placeholder="Confirm Password" required autocomplete="new-password" />
        
        <select name="role" id="role" required>
            <option value="" disabled selected>Select Role</option>
            <option value="student">Student</option>
            <option value="trainer">Trainer</option>
            <option value="admin">Admin</option>
        </select>

        <div id="specializationDiv" style="display: none;">
            <input type="text" name="specialization" id="specialization" placeholder="Specialization (for trainers only)" />
        </div>

        <button type="submit">Register</button>
    </form>
</div>
</body>
</html>