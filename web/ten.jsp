<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*" %>
<%
    // 1. Get user from parameter or session
    String user = request.getParameter("firstname");
    if (user == null) {
        user = (String) session.getAttribute("userName");
    }

    // 2. LOGOUT LOGIC: If user clicks logout (redirects back to this page with action=logout)
    String action = request.getParameter("action");
    if ("logout".equals(action)) {
        Connection con = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/LMS", "root", "Root@1234");
            
            // Delete from active LOGIN table
            PreparedStatement ps = con.prepareStatement("DELETE FROM LOGIN WHERE FIRSTNAME=?");
            ps.setString(1, (String) session.getAttribute("userName"));
            ps.executeUpdate();
            
            // Kill session and send to home
            session.invalidate();
            response.sendRedirect("first.jsp");
            return;
        } catch (Exception e) {
            out.println(e.getMessage());
        } finally {
            if (con != null) con.close();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>LMS | Student Admin</title>
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

        /* Dashboard Container - Stylized as an open journal */
        .dashboard-container {
            background-color: var(--aged-paper);
            width: 900px;
            height: 580px;
            border-radius: 4px;
            display: flex;
            flex-direction: column;
            border-left: 15px solid var(--mocha); /* Mimics book spine */
            box-shadow: 20px 20px 60px rgba(0,0,0,0.7);
            position: relative;
        }

        /* Top Header */
        .header {
            padding: 40px 20px 20px 20px;
            text-align: center;
        }

        .header h1 {
            font-family: 'Cormorant Garamond', serif;
            font-size: 3rem;
            letter-spacing: 6px;
            color: var(--dark-espresso);
            text-transform: uppercase;
            border-bottom: 2px solid var(--accent-gold);
            display: inline-block;
            padding-bottom: 5px;
        }

        /* User Greeting Section */
        .greeting {
            margin: 20px 0;
            text-align: center;
        }

        .welcome-msg {
            font-family: 'Satisfy', cursive;
            font-size: 1.8rem;
            color: var(--mocha);
        }

        .user-name {
            /* FONT UPDATED TO SATISFY AS REQUESTED */
            font-family: 'Satisfy', cursive;
            font-weight: 400;
            font-size: 2.2rem;
            color: var(--dark-espresso);
            margin-top: 5px;
        }

        /* Menu Section */
        .menu-area {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            gap: 20px;
            padding-bottom: 40px;
        }

        .menu-btn {
            width: 420px;
            padding: 16px;
            background: var(--paper);
            border: 1px solid var(--accent-gold);
            color: var(--mocha);
            font-weight: 700;
            text-transform: uppercase;
            text-decoration: none;
            text-align: center;
            font-size: 0.9rem;
            letter-spacing: 1px;
            transition: all 0.3s ease;
            box-shadow: 4px 4px 0px var(--accent-gold);
        }

        .menu-btn:hover {
            background: var(--mocha);
            color: var(--paper);
            transform: translate(2px, 2px);
            box-shadow: 0px 0px 0px var(--accent-gold);
        }

        /* Bottom Navigation */
        .footer {
            padding: 30px;
            display: flex;
            justify-content: center;
        }

        .btn-back {
            font-family: 'Instrument Sans', sans-serif;
            font-weight: 700;
            font-size: 0.75rem;
            letter-spacing: 2px;
            color: var(--accent-gold);
            text-decoration: none;
            border: 1px solid var(--accent-gold);
            padding: 8px 30px;
            transition: 0.3s;
        }

        .btn-back:hover {
            background: var(--accent-gold);
            color: var(--dark-espresso);
        }

        /* Subtle Texture Overlay */
        .dashboard-container::before {
            content: "";
            position: absolute;
            top: 0; left: 0; width: 100%; height: 100%;
            background: url('https://www.transparenttextures.com/patterns/paper.png');
            opacity: 0.4;
            pointer-events: none;
        }
    </style>
</head>
<body>

    <div class="dashboard-container">
        <div class="header">
            <h1>Student Admin</h1>
        </div>

        <div class="greeting">
            <p class="welcome-msg">Welcome back,</p>
            <div class="user-name"><%= user %></div>
        </div>

        <div class="menu-area">
            <a href="eleven.jsp" class="menu-btn">Explore The Library Archive</a>
            <a href="twelve.jsp" class="menu-btn">View My Issued Books</a>
            <a href="thirteen.jsp" class="menu-btn">Check My Fines</a>
        </div>

        <div class="footer">
            <a href="ten.jsp?action=logout" class="btn-back">LOGOUT</a>
        </div>
    </div>

</body>
</html>