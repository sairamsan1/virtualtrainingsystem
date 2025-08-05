<%@ page session="true" %>
<%
    String email = (String) session.getAttribute("email");
    String role = (String) session.getAttribute("role");

    if (email == null || !"student".equals(role)) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }

    String trainingId = request.getParameter("trainingId");
    String title = request.getParameter("title");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Confirm Unenroll</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #fefefe;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .box {
            background: white;
            padding: 40px;
            box-shadow: 0 0 10px #ccc;
            text-align: center;
            border-radius: 10px;
        }
        h2 {
            color: #cc0000;
        }
        .btn {
            padding: 10px 20px;
            margin: 10px;
            font-size: 16px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        .yes {
            background-color: #cc0000;
            color: white;
        }
        .no {
            background-color: #ccc;
        }
        a {
            text-decoration: none;
        }
    </style>
</head>
<body>
<div class="box">
    <h2>Are you sure you want to unenroll from:</h2>
    <p><strong><%= title %></strong></p>

    <form action="UnenrollServlet" method="post">
        <input type="hidden" name="trainingId" value="<%= trainingId %>">
        <button type="submit" class="btn yes">Yes, Unenroll</button>
    </form>

    <a href="enrollment_overview.jsp"><button class="btn no">Cancel</button></a>
</div>
</body>
</html>