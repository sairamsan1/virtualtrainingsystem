<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login - Virtual Training System</title>
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background: linear-gradient(to right, #8e2de2, #4a00e0);
            margin: 0;
            padding: 0;
        }

        .login-container {
            width: 400px;
            margin: 100px auto;
            background-color: #fff;
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
        }

        h2 {
            text-align: center;
            color: #4a00e0;
            margin-bottom: 20px;
        }

        input[type="email"],
        input[type="password"],
        select {
            width: 100%;
            padding: 12px 15px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 8px;
            font-size: 14px;
            box-sizing: border-box;
        }

        select:invalid {
            color: gray;
        }

        button {
            width: 100%;
            padding: 12px;
            background-color: #4a00e0;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            cursor: pointer;
        }

        button:hover {
            background-color: #5f17d3;
        }

        .message {
            color: red;
            text-align: center;
            margin-bottom: 10px;
        }

        .footer-link {
            text-align: center;
            margin-top: 15px;
        }

        .footer-link a {
            color: #4a00e0;
            text-decoration: none;
        }

        .footer-link a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <h2>Login</h2>

        <% 
            String msg = request.getParameter("msg");
            if (msg != null) {
                if ("invalid".equals(msg)) {
        %>
            <p class="message">Invalid email or password.</p>
        <% 
                } else if ("error".equals(msg)) { 
        %>
            <p class="message">Something went wrong. Please try again.</p>
        <% 
                } else if ("unauthorized".equals(msg)) {
        %>
            <p class="message">Unauthorized access. Please log in again.</p>
        <% 
                }
            } 
        %>

        <form action="loginservlet" method="post" autocomplete="off">
            <input type="email" name="email" placeholder="Email Address" required autocomplete="off" />
            <input type="password" name="password" id="password" placeholder="Password" required autocomplete="new-password" />
            <select name="role" required>
                <option value="" disabled selected>Select Role</option>
                <option value="student">Student</option>
                <option value="trainer">Trainer</option>
                <option value="admin">Admin</option>
            </select>
            <button type="submit">Login</button>
        </form>

        <div class="footer-link">
            <p>Don't have an account? <a href="register.jsp">Register Here</a></p>
        </div>
    </div>
</body>
</html>