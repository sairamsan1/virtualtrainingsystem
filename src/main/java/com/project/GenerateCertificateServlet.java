package com.project;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.*;
import java.sql.*;
import java.time.LocalDate;
import java.util.Base64;
import java.util.UUID;

@WebServlet("/GenerateCertificateServlet")
public class GenerateCertificateServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("email") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String email = (String) session.getAttribute("email");
        String trainingId = request.getParameter("training_id");

        if (trainingId == null || trainingId.trim().isEmpty()) {
            response.getWriter().println("Training ID is required.");
            return;
        }

        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/virtualtrainingsystem", "root", "");
             PreparedStatement stmt = conn.prepareStatement(
                     "SELECT u.name, u.email, t.title, t.instructor, t.duration, e.certificate_id " +
                     "FROM users u " +
                     "JOIN enrollments e ON u.id = e.student_id " +
                     "JOIN trainings t ON e.training_id = t.id " +
                     "WHERE u.email = ? AND t.id = ?")) {

            stmt.setString(1, email);
            stmt.setString(2, trainingId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                String studentName = rs.getString("name");
                String studentEmail = rs.getString("email");
                String title = rs.getString("title");
                String instructor = rs.getString("instructor");
                String duration = rs.getString("duration");
                String certificateId = rs.getString("certificate_id");

                if (certificateId == null || certificateId.isEmpty()) {
                    certificateId = UUID.randomUUID().toString();
                    PreparedStatement updateStmt = conn.prepareStatement(
                            "UPDATE enrollments SET certificate_id = ?, status = 'completed' " +
                            "WHERE student_id = (SELECT id FROM users WHERE email = ?) AND training_id = ?");
                    updateStmt.setString(1, certificateId);
                    updateStmt.setString(2, email);
                    updateStmt.setString(3, trainingId);
                    updateStmt.executeUpdate();
                }

                String certDir = getServletContext().getRealPath("/certificates/");
                File directory = new File(certDir);
                if (!directory.exists()) directory.mkdirs();

                File pdfFile = new File(certDir, certificateId + ".pdf");

                // Encrypted verification URL
                String token = Base64.getEncoder().encodeToString(certificateId.getBytes());
                String verifyURL = "http://localhost:8080/virtualtrainingsystem/VerifyCertificate.jsp?token=" + token;

                Document doc = new Document();
                PdfWriter writer = PdfWriter.getInstance(doc, new FileOutputStream(pdfFile));
                doc.open();

                // Background image
                String bgPath = getServletContext().getRealPath("/uploads/watermark.jpg");
                if (new File(bgPath).exists()) {
                    Image bg = Image.getInstance(bgPath);
                    bg.setAbsolutePosition(0, 0);
                    bg.scaleAbsolute(PageSize.A4.getWidth(), PageSize.A4.getHeight());
                    doc.add(bg);
                }

                // Watermark
                Font watermarkFont = new Font(Font.FontFamily.HELVETICA, 50, Font.BOLD, new GrayColor(0.90f));
                Phrase watermark = new Phrase("Virtual Training System", watermarkFont);
                ColumnText.showTextAligned(writer.getDirectContentUnder(), Element.ALIGN_CENTER, watermark, 297.5f, 421, 45);

                // Logo
                String logoPath = getServletContext().getRealPath("/uploads/logo.png");
                if (new File(logoPath).exists()) {
                    Image logo = Image.getInstance(logoPath);
                    logo.scaleAbsolute(100, 100);
                    logo.setAlignment(Image.ALIGN_CENTER);
                    doc.add(logo);
                }

                doc.add(Chunk.NEWLINE);

                // Certificate Title
                Font titleFont = new Font(Font.FontFamily.TIMES_ROMAN, 28, Font.BOLD, BaseColor.BLACK);
                Paragraph p1 = new Paragraph("Certificate of Completion", titleFont);
                p1.setAlignment(Element.ALIGN_CENTER);
                doc.add(p1);
                doc.add(Chunk.NEWLINE);

                // Certificate Body
                Font bodyFont = new Font(Font.FontFamily.HELVETICA, 16);
                Paragraph p2 = new Paragraph("This is to certify that", bodyFont);
                p2.setAlignment(Element.ALIGN_CENTER);
                doc.add(p2);

                Font nameFont = new Font(Font.FontFamily.TIMES_ROMAN, 20, Font.BOLDITALIC);
                Paragraph p3 = new Paragraph(studentName, nameFont);
                p3.setAlignment(Element.ALIGN_CENTER);
                doc.add(p3);

                Paragraph p4 = new Paragraph("has successfully completed the training titled", bodyFont);
                p4.setAlignment(Element.ALIGN_CENTER);
                doc.add(p4);

                Font courseFont = new Font(Font.FontFamily.COURIER, 18, Font.BOLD, BaseColor.BLUE);
                Paragraph p5 = new Paragraph("\"" + title + "\"", courseFont);
                p5.setAlignment(Element.ALIGN_CENTER);
                doc.add(p5);

                Paragraph p6 = new Paragraph("under the instruction of " + instructor +
                        " with a duration of " + duration + ".", bodyFont);
                p6.setAlignment(Element.ALIGN_CENTER);
                doc.add(p6);
                doc.add(Chunk.NEWLINE);

                Paragraph p7 = new Paragraph("Certificate ID: " + certificateId,
                        new Font(Font.FontFamily.HELVETICA, 12, Font.ITALIC, BaseColor.GRAY));
                p7.setAlignment(Element.ALIGN_CENTER);
                doc.add(p7);
                doc.add(Chunk.NEWLINE);

                // QR Code
                BarcodeQRCode qrCode = new BarcodeQRCode(verifyURL, 150, 150, null);
                Image qrImage = qrCode.getImage();
                qrImage.setAlignment(Image.ALIGN_CENTER);
                doc.add(qrImage);
                doc.add(Chunk.NEWLINE);

                // Footer
                Paragraph datePara = new Paragraph("Date: " + LocalDate.now(), bodyFont);
                datePara.setAlignment(Element.ALIGN_LEFT);
                doc.add(datePara);

                Paragraph signPara = new Paragraph("Authorized Signature", bodyFont);
                signPara.setAlignment(Element.ALIGN_RIGHT);
                doc.add(signPara);

                doc.close();

                // ✅ Send Certificate Email
                String downloadLink = "http://localhost:8080/virtualtrainingsystem/DownloadCertificateServlet?certificate_id=" + certificateId;
                String subject = "🎓 Certificate for " + title;
                String body = "Hi " + studentName + ",\n\n" +
                        "Congratulations on completing the training: " + title + "!\n\n" +
                        "You can download your certificate here:\n" + downloadLink + "\n\n" +
                        "Regards,\nVirtual Training System";

                try {
                    EmailUtility.sendEmail(studentEmail, subject, body);
                } catch (Exception e) {
                    e.printStackTrace();
                }

                // Send PDF directly to browser
                response.setContentType("application/pdf");
                response.setHeader("Content-Disposition", "inline; filename=\"Certificate_" +
                        studentName.replaceAll(" ", "_") + ".pdf\"");

                try (FileInputStream fis = new FileInputStream(pdfFile);
                     OutputStream os = response.getOutputStream()) {
                    fis.transferTo(os);
                    os.flush();
                }

            } else {
                response.getWriter().println("No matching enrollment found.");
            }
         

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error generating certificate: " + e.getMessage());
        }
    }
}
