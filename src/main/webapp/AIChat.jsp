<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>AI Assistant - Virtual Training System</title>
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background: #eaf0f6;
            margin: 0;
            padding: 0;
            transition: background 0.3s, color 0.3s;
        }
        .chat-container {
            max-width: 850px;
            margin: 50px auto;
            background: #fff;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
        }
        .chat-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .chat-box {
            height: 450px;
            overflow-y: auto;
            border: 1px solid #dcdcdc;
            padding: 15px;
            margin: 15px 0;
            border-radius: 8px;
            background-color: #fdfdfd;
        }
        .message {
            margin: 10px 0;
            max-width: 80%;
            padding: 10px 15px;
            border-radius: 20px;
            display: inline-block;
            position: relative;
            word-wrap: break-word;
        }
        .user {
            background-color: #d1f0ff;
            float: right;
            text-align: right;
            clear: both;
        }
        .assistant {
            background-color: #e2e2e2;
            float: left;
            text-align: left;
            clear: both;
        }
        .timestamp {
            font-size: 10px;
            color: #666;
            display: block;
            margin-top: 4px;
        }
        .input-box {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        #messageInput {
            flex: 1;
            padding: 12px;
            font-size: 16px;
            border: 1px solid #ccc;
            border-radius: 8px;
        }
        #fileInput {
            flex: 1;
        }
        button {
            padding: 12px 20px;
            background: #2e86de;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
        }
        button:hover {
            background: #2169c0;
        }
        .loader {
            width: 25px;
            display: inline-block;
        }
        .loader span {
            display: inline-block;
            width: 6px;
            height: 6px;
            margin: 0 2px;
            background: #555;
            border-radius: 50%;
            animation: bounce 1.4s infinite ease-in-out both;
        }
        .loader span:nth-child(2) { animation-delay: 0.2s; }
        .loader span:nth-child(3) { animation-delay: 0.4s; }
        @keyframes bounce {
            0%, 80%, 100% { transform: scale(0); }
            40% { transform: scale(1); }
        }
        .dark-mode {
            background: #121212;
            color: #f5f5f5;
        }
        .dark-mode .chat-container {
            background: #1f1f1f;
        }
        .dark-mode .chat-box {
            background-color: #2b2b2b;
        }
        .dark-mode .user {
            background-color: #3498db;
            color: white;
        }
        .dark-mode .assistant {
            background-color: #444;
            color: #fff;
        }
        .toggle-dark {
            cursor: pointer;
            font-size: 14px;
            color: #007bff;
            background: none;
            border: none;
        }
    </style>
</head>
<body>
<div class="chat-container">
    <div class="chat-header">
        <h2>💬 AI Assistant</h2>
        <button class="toggle-dark" onclick="toggleDarkMode()">🌙 Toggle Dark Mode</button>
    </div>
    <div class="chat-box" id="chatBox"></div>
    <div class="input-box">
        <input type="text" id="messageInput" placeholder="Type your message..." onkeydown="if(event.key === 'Enter') sendMessage();">
        <input type="file" id="fileInput" name="file">
        <button onclick="sendMessage()">Send</button>
    </div>
</div>

<script>
    const chatBox = document.getElementById("chatBox");

    function toggleDarkMode() {
        document.body.classList.toggle("dark-mode");
    }

    function addMessage(content, sender) {
        const msg = document.createElement("div");
        msg.classList.add("message", sender);
        const timestamp = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
        const html = content + '<span class="timestamp">' + timestamp + '</span>';
        msg.innerHTML = html;
        chatBox.appendChild(msg);
        chatBox.scrollTop = chatBox.scrollHeight;
    }

    function addTypingIndicator() {
        const typing = document.createElement("div");
        typing.classList.add("message", "assistant");
        typing.id = "typing-indicator";
        typing.innerHTML = '<div class="loader"><span></span><span></span><span></span></div>';
        chatBox.appendChild(typing);
        chatBox.scrollTop = chatBox.scrollHeight;
    }

    function removeTypingIndicator() {
        const typing = document.getElementById("typing-indicator");
        if (typing) typing.remove();
    }

    function speak(text) {
        if ('speechSynthesis' in window) {
            const utterance = new SpeechSynthesisUtterance(text);
            utterance.lang = 'en-US';
            speechSynthesis.speak(utterance);
        }
    }

    function sendMessage() {
        const input = document.getElementById("messageInput");
        const message = input.value.trim();
        const fileInput = document.getElementById("fileInput");

        if (!message) return;

        addMessage("You: " + message, "user");
        input.value = "";

        addTypingIndicator();

        const formData = new FormData();
        formData.append("message", message);
        if (fileInput.files.length > 0) {
            formData.append("file", fileInput.files[0]);
        }

        fetch("AIChatServlet", {
            method: "POST",
            body: formData
        })
        .then(response => {
            if (!response.ok) {
                throw new Error("Network response was not ok");
            }
            return response.json();
        })
        .then(data => {
            removeTypingIndicator();
            if (data.reply) {
                addMessage("AI: " + data.reply, "assistant");
                speak(data.reply);
            } else if (data.error) {
                addMessage("⚠ " + data.error, "assistant");
            }
        })
        .catch(error => {
            removeTypingIndicator();
            addMessage("⚠ Error communicating with AI assistant.", "assistant");
            console.error("Error:", error);
        });
    }
</script>
</body>
</html>