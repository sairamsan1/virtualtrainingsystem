<%@ page session="false" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Welcome to Virtual Training System</title>
    <link rel="icon" type="image/png" href="favicon.png"> <!-- Optional favicon -->
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f4f4f4;
            padding: 40px;
            text-align: center;
        }
        .container {
            background: #fff;
            padding: 30px;
            margin: 0 auto;
            width: 400px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
        }
        a.button {
            display: inline-block;
            margin: 10px;
            padding: 12px 24px;
            background-color: #007BFF;
            color: #fff;
            text-decoration: none;
            font-weight: bold;
            border-radius: 5px;
            transition: background-color 0.3s ease;
        }
        a.button:hover {
            background-color: #0056b3;
        }
        .footer {
            margin-top: 40px;
            color: #777;
            font-size: 13px;
        }

        @media (max-width: 500px) {
            .container {
                width: 90%;
                padding: 20px;
            }
            a.button {
                padding: 10px 20px;
            }
        }
    </style>
</head>
<body>

    <main class="container" role="main">
        <h1>Welcome to Virtual Training System</h1>
        <p>Please choose your login type:</p>
        <a href="login.jsp" class="button" aria-label="Login as existing user">Login</a>
        <a href="register.jsp" class="button" aria-label="Register as new user">Register</a>
    </main>

    <footer class="footer">
        &copy; 2025 Virtual Training System. All rights reserved.
    </footer>

</body>
</html>
