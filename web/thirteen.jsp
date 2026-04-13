<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*" %>
<%
    // 1. Session Check: Keep user logged in
    String user = (String) session.getAttribute("userName");
    if (user == null) {
        response.sendRedirect("first.jsp");
        return;
    }

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>LMS | My Fines</title>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@600;700&family=Instrument+Sans:wght@400;600&family=Satisfy&display=swap" rel="stylesheet">
    <style>
        :root { 
            --dark-espresso: #1a120b; 
            --mocha: #3d2b1f; 
            --paper: #faf5ee; 
            --aged-paper: #e6dac1; 
            --accent-gold: #c29c61; 
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body { 
            background-color: var(--dark-espresso); 
            height: 100vh; 
            display: flex; 
            justify-content: center; 
            align-items: center; 
            font-family: 'Instrument Sans', sans-serif; 
            overflow: hidden;
        }

        .dashboard-container {
            background-color: var(--aged-paper);
            width: 900px; 
            height: 550px;
            border-radius: 4px;
            display: flex;
            flex-direction: column;
            border-left: 15px solid var(--mocha);
            box-shadow: 20px 20px 60px rgba(0,0,0,0.7);
            position: relative;
            padding: 40px;
        }

        .header {
            text-align: center;
            margin-bottom: 30px;
        }

        .header h1 {
            font-family: 'Cormorant Garamond', serif;
            font-size: 2.5rem;
            letter-spacing: 4px;
            color: var(--dark-espresso);
            text-transform: uppercase;
            border-bottom: 2px solid var(--accent-gold);
            display: inline-block;
            padding-bottom: 5px;
        }

        .fine-card {
            background: rgba(250, 245, 238, 0.8);
            border: 1px solid var(--accent-gold);
            padding: 30px;
            text-align: center;
            border-radius: 8px;
            flex: 1;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
        }

        .amount-display {
            font-family: 'Cormorant Garamond', serif;
            font-size: 4rem;
            color: #8b0000;
            margin: 10px 0;
        }

        .currency {
            font-size: 1.5rem;
            vertical-align: middle;
            margin-right: 5px;
        }

        .fine-details {
            font-size: 0.9rem;
            color: var(--mocha);
            margin-top: 10px;
            line-height: 1.6;
        }

        .footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 30px;
            border-top: 1px solid rgba(61, 43, 31, 0.2);
            padding-top: 20px;
        }

        .btn-back {
            font-family: 'Instrument Sans', sans-serif;
            font-weight: 700;
            font-size: 0.75rem;
            letter-spacing: 2px;
            color: var(--mocha);
            text-decoration: none;
            border: 1px solid var(--mocha);
            padding: 8px 25px;
            transition: 0.3s;
        }

        .btn-back:hover {
            background: var(--mocha);
            color: var(--paper);
        }

        .user-tag {
            font-family: 'Satisfy', cursive;
            color: var(--mocha);
            font-size: 1.4rem;
        }

        .dashboard-container::before {
            content: "";
            position: absolute;
            top: 0; left: 0; width: 100%; height: 100%;
            background: url('https://www.transparenttextures.com/patterns/paper.png');
            opacity: 0.3;
            pointer-events: none;
        }
    </style>
</head>
<body>

    <div class="dashboard-container">
        <div class="header">
            <h1>Library Fines</h1>
        </div>

        <div class="fine-card">
            <%
                double totalFine = 0.0;
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    con = DriverManager.getConnection("jdbc:mysql://localhost:3306/LMS", "root", "Root@1234");
                    
                    // UPDATED TO TABLE 'RETURNBOOK' AND COLUMN 'FINE'
                    String sql = "SELECT SUM(FINE) FROM RETURNBOOK WHERE NAME = ?";
                    ps = con.prepareStatement(sql);
                    ps.setString(1, user);
                    rs = ps.executeQuery();
                    
                    if(rs.next()) {
                        totalFine = rs.getDouble(1);
                    }
            %>
                <p style="font-family: 'Satisfy'; font-size: 1.5rem; color: var(--mocha);">Outstanding Balance</p>
                <div class="amount-display">
                    <span class="currency">₹</span><%= String.format("%.2f", totalFine) %>
                </div>
                
                <div class="fine-details">
                    <% if(totalFine > 0) { %>
                        Your total accumulated fine for late returns is ₹<%= String.format("%.2f", totalFine) %>.<br>
                        Please settle these dues with the Library Administrator.
                    <% } else { %>
                        Wonderful! Your account currently has no pending fines.
                    <% } %>
                </div>
            <%
                } catch (Exception e) {
            %>
                <div style="color: #8b0000;">
                    <strong>Notice:</strong> Database retrieval error. <br>
                    <small><%= e.getMessage() %></small>
                </div>
            <%
                } finally {
                    if (rs != null) rs.close();
                    if (ps != null) ps.close();
                    if (con != null) con.close();
                }
            %>
        </div>

        <div class="footer">
            <a href="ten.jsp" class="btn-back">RETURN TO DASHBOARD</a>
            <div class="user-tag">Reader: <%= user %></div>
        </div>
    </div>

</body>
</html>