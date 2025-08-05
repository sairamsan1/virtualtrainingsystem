package com.project;

import jakarta.servlet.*;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URI;
import java.sql.*;

import org.json.*;

@WebServlet("/AIChatServlet")
@MultipartConfig
public class AIChatServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String ENDPOINT = "https://api.openai.com/v1/chat/completions";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/plain");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().println("AIChatServlet is alive. Only POST requests are supported for chat.");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("email") == null || session.getAttribute("role") == null) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.write("{\"error\": \"Unauthorized: Session missing.\"}");
            return;
        }

        String email = (String) session.getAttribute("email");
        String role = (String) session.getAttribute("role");

        if (!"student".equals(role) && !"trainer".equals(role)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.write("{\"error\": \"Only students or trainers can access this feature.\"}");
            return;
        }

        String OPENAI_API_KEY = System.getenv("OPENAI_API_KEY");
        if (OPENAI_API_KEY == null || OPENAI_API_KEY.trim().isEmpty()) {
            System.out.println("OPENAI_API_KEY is missing or not set");
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.write("{\"error\": \"Server misconfigured: OpenAI key missing.\"}");
            return;
        }

        String userMessage = request.getParameter("message");
        if (userMessage == null || userMessage.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.write("{\"error\": \"Message cannot be empty.\"}");
            return;
        }

        String fileName = null;
        try {
            Part filePart = request.getPart("file");
            if (filePart != null && filePart.getSize() > 0) {
                fileName = filePart.getSubmittedFileName();
                String uploadPath = getServletContext().getRealPath("/") + "uploads";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdirs();

                File uploadedFile = new File(uploadDir, fileName);
                try (InputStream is = filePart.getInputStream();
                     FileOutputStream fos = new FileOutputStream(uploadedFile)) {
                    byte[] buffer = new byte[1024];
                    int bytesRead;
                    while ((bytesRead = is.read(buffer)) != -1) {
                        fos.write(buffer, 0, bytesRead);
                    }
                }
            }
        } catch (Exception e) {
            System.out.println("File upload skipped or failed: " + e.getMessage());
        }

        String reply = "";
        try {
            JSONObject payload = new JSONObject();
            payload.put("model", "gpt-3.5-turbo");

            JSONArray messages = new JSONArray();
            messages.put(new JSONObject().put("role", "system")
                    .put("content", "You are an assistant helping users in a virtual training system."));
            messages.put(new JSONObject().put("role", "user").put("content", userMessage));
            payload.put("messages", messages);

            URI endpointUri = URI.create(ENDPOINT);
            HttpURLConnection conn = (HttpURLConnection) endpointUri.toURL().openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Authorization", "Bearer " + OPENAI_API_KEY);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);

            try (OutputStream os = conn.getOutputStream()) {
                os.write(payload.toString().getBytes("UTF-8"));
            }

            int status = conn.getResponseCode();
            System.out.println("OpenAI status code: " + status);

            if (status != 200) {
                StringBuilder errResponse = new StringBuilder();
                try (BufferedReader er = new BufferedReader(new InputStreamReader(conn.getErrorStream()))) {
                    String line;
                    while ((line = er.readLine()) != null) errResponse.append(line);
                }
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.write("{\"error\": \"OpenAI Error\", \"details\": " + JSONObject.quote(errResponse.toString()) + "}");
                return;
            }

            StringBuilder responseBuffer = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()))) {
                String line;
                while ((line = reader.readLine()) != null) responseBuffer.append(line);
            }

            JSONObject jsonResponse = new JSONObject(responseBuffer.toString());
            reply = jsonResponse.getJSONArray("choices").getJSONObject(0)
                    .getJSONObject("message").getString("content");
            System.out.println("AI Response: " + reply);

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JSONObject errorJson = new JSONObject();
            errorJson.put("error", "AI communication failed");
            errorJson.put("exception", e.toString());
            out.write(errorJson.toString());
            return;
        }

        // Save chat log to DB
        try (Connection conn = DBConnection.getConnection()) {
            int userId = getUserIdByEmail(conn, email);
            PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO ai_chat_logs (user_id, role, user_message, ai_reply, file_name) VALUES (?, ?, ?, ?, ?)");
            ps.setInt(1, userId);
            ps.setString(2, role);
            ps.setString(3, userMessage);
            ps.setString(4, reply);
            ps.setString(5, fileName);
            ps.executeUpdate();
        } catch (Exception e) {
            System.out.println("DB logging failed: " + e.getMessage());
        }

        out.write(new JSONObject().put("reply", reply).toString());
    }

    private int getUserIdByEmail(Connection conn, String email) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement("SELECT id FROM users WHERE email = ?")) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("id");
        }
        return -1;
    }
}
