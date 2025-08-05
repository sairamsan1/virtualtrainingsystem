<%@ page import="java.sql.*,java.util.*,java.text.SimpleDateFormat,com.project.DBConnection" %> <%@ page session="true" %> <%@ page contentType="text/html;charset=UTF-8" language="java" %>

<% String email = (String) session.getAttribute("email"); String role = (String) session.getAttribute("role"); Integer userId = (Integer) session.getAttribute("userId");

if (email == null || (!"student".equals(role) && !"trainer".equals(role))) {
    response.sendRedirect("login.jsp?msg=unauthorized");
    return;
}

%>

<!DOCTYPE html><html>
<head>
    <title>Chat - Virtual Training System</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4; }
        .container { display: flex; height: 100vh; }
        .sidebar { width: 25%; background: #2c3e50; color: white; overflow-y: auto; padding: 20px; }
        .chat-box { width: 75%; display: flex; flex-direction: column; justify-content: space-between; padding: 20px; }
        .chat-header { font-size: 20px; margin-bottom: 10px; }
        .messages { flex: 1; overflow-y: auto; padding: 10px; background: white; border: 1px solid #ccc; display: flex; flex-direction: column; }
        .message { margin: 5px 0; padding: 8px; border-radius: 10px; max-width: 60%; }
        .sent { background-color: #d1fcd3; align-self: flex-end; }
        .received { background-color: #e6e6e6; align-self: flex-start; }
        .input-area { display: flex; gap: 10px; margin-top: 10px; }
        .input-area input[type="text"] { flex: 1; padding: 10px; border: 1px solid #ccc; border-radius: 5px; }
        .input-area input[type="file"] { border: none; background: none; }
        .input-area button { padding: 10px 20px; }
        .sidebar h3 { color: #ecf0f1; }
        .sidebar select { width: 100%; padding: 10px; margin-top: 10px; font-size: 16px; }
        .typing-indicator { font-style: italic; font-size: 12px; margin-top: 5px; color: #666; }
    </style><script>
    const senderId = <%= userId %>;
    let receiverId = null;
    let currentTrainingId = null;

    function fetchMessages() {
        if (!currentTrainingId || !receiverId) return;
        fetch(GetMessagesServlet?training_id=${currentTrainingId}&other_user_id=${receiverId})
            .then(res => res.json())
            .then(data => {
                const messagesDiv = document.getElementById("messages");
                messagesDiv.innerHTML = "";
                data.forEach(msg => {
                    const div = document.createElement("div");
                    div.classList.add("message");
                    div.classList.add(msg.sender_id === senderId ? "sent" : "received");
                    let content = <strong>${msg.sender_name}</strong><br>;
                    if (msg.message) content += ${msg.message}<br>;
                    if (msg.file_url) content += <a href='${msg.file_url}' target='_blank'>Download Attachment</a><br>;
                    content += <small>${msg.timestamp}</small>;
                    div.innerHTML = content;
                    messagesDiv.appendChild(div);
                });
                messagesDiv.scrollTop = messagesDiv.scrollHeight;
            });
    }

    function sendMessage() {
        const msgInput = document.getElementById("messageInput");
        const fileInput = document.getElementById("fileInput");
        const msg = msgInput.value.trim();
        const file = fileInput.files[0];

        if (!msg && !file) return;

        const formData = new FormData();
        formData.append("training_id", currentTrainingId);
        formData.append("receiver_id", receiverId);
        formData.append("message", msg);
        if (file) formData.append("file", file);

        fetch("SendMessageServlet", {
            method: "POST",
            body: formData
        }).then(() => {
            msgInput.value = "";
            fileInput.value = "";
            fetchMessages();
        }).catch(err => {
            console.error("Failed to send message:", err);
        });
    }

    function selectTraining() {
        const selected = document.getElementById("trainingSelector").value;
        if (!selected.includes(":")) return;
        const parts = selected.split(":");
        currentTrainingId = parseInt(parts[0]);
        receiverId = parseInt(parts[1]);
        fetchMessages();
    }

    function showTyping() {
        document.getElementById("typingStatus").innerText = "Typing...";
        clearTimeout(window.typingTimeout);
        window.typingTimeout = setTimeout(() => {
            document.getElementById("typingStatus").innerText = "";
        }, 1000);
    }

    setInterval(fetchMessages, 3000);
</script>

</head>
<body>
<div class="container">
    <div class="sidebar">
        <h3>Select Training</h3>
        <form>
            <select id="trainingSelector" onchange="selectTraining()">
                <%
                    Connection conn = null;
                    try {
                        conn = DBConnection.getConnection();
                        PreparedStatement ps;
                        if ("student".equals(role)) {
                            ps = conn.prepareStatement(
                                "SELECT t.id, t.title, u.id AS trainerId FROM trainings t JOIN enrollments e ON t.id = e.training_id JOIN users u ON t.trainer_email = u.email WHERE e.student_id = ?");
                        } else {
                            ps = conn.prepareStatement(
                                "SELECT t.id, t.title, u.id AS studentId FROM trainings t JOIN enrollments e ON t.id = e.training_id JOIN users u ON u.id = e.student_id WHERE t.trainer_email = ?");
                        }
                        ps.setInt(1, userId);
                        ResultSet rs = ps.executeQuery();
                        while (rs.next()) {
                            int trainingId = rs.getInt("id");
                            String title = rs.getString("title");
                            int otherId = rs.getInt(3);
                %>
                            <option value="<%=trainingId%>:<%=otherId%>"><%=title%></option>
                <%
                        }
                        rs.close();
                        ps.close();
                    } catch (Exception e) {
                        out.println("<option>Error loading trainings</option>");
                        e.printStackTrace();
                    } finally {
                        if (conn != null) try { conn.close(); } catch (Exception ignored) {}
                    }
                %>
            </select>
        </form>
    </div>
    <div class="chat-box">
        <div class="chat-header">Chat Window</div>
        <div id="messages" class="messages"></div>
        <div class="typing-indicator" id="typingStatus"></div>
        <div class="input-area">
            <input type="text" id="messageInput" oninput="showTyping()" placeholder="Type a message...">
            <input type="file" id="fileInput">
            <button type="button" onclick="sendMessage()">Send</button>
        </div>
    </div>
</div>
</body>
</html>