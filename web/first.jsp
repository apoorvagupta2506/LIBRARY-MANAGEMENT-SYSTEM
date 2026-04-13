<%@page import="java.sql.*" %>
<%
    String errorMsg = "";
    boolean loginFailed = false; 
    
    if (request.getMethod().equals("POST")) {
        String role = request.getParameter("r"); 
        String userId = request.getParameter("userId");
        String password = request.getParameter("password");

        Connection con = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/LMS", "root", "Root@1234");
            
            if ("ADMIN".equals(role)) {
                if ("ABC".equals(userId) && "123".equals(password)) {
                    response.sendRedirect("second.html");
                    return;
                } else {
                    errorMsg = "WRONG ADMIN OR PASSWORD";
                    loginFailed = true;
                }
            } 
            else if ("USER".equals(role)) {
                // 1. Check the permanent USER table
                String str = "SELECT * FROM USER WHERE FIRSTNAME = ?";
                PreparedStatement ps = con.prepareStatement(str);
                ps.setString(1, userId); 
                ResultSet rs = ps.executeQuery();
                
                if (rs.next()) {
                    String dbPassword = rs.getString(5);
                    if (dbPassword != null && dbPassword.equals(password)) {
                        
                        // 2. Clean up any existing session for this user
                        PreparedStatement psDel = con.prepareStatement("DELETE FROM LOGIN WHERE FIRSTNAME=?");
                        psDel.setString(1, userId);
                        psDel.executeUpdate();

                        // 3. Insert into LOGIN table (FIRSTNAME and PASSWORD only)
                        PreparedStatement psLogin = con.prepareStatement("INSERT INTO LOGIN(FIRSTNAME, PASSWORD) VALUES(?,?)");
                        psLogin.setString(1, userId);
                        psLogin.setString(2, password);
                        psLogin.executeUpdate();

                        // 4. Set Session and Redirect
                        session.setAttribute("userName", userId);
                        response.sendRedirect("ten.jsp?firstname=" + userId);
                        return;
                    } else {
                        errorMsg = "WRONG USER OR PASSWORD";
                        loginFailed = true;
                    }
                } else {
                    errorMsg = "WRONG USER OR PASSWORD";
                    loginFailed = true;
                }
            }
        } catch (Exception e) {
            errorMsg = "Error: " + e.getMessage();
            loginFailed = true;
        } finally {
            if (con != null) try { con.close(); } catch (SQLException ignore) {}
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>LMS | Library Portal</title>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@600;700&family=Instrument+Sans:wght@400;600&family=Satisfy&display=swap" rel="stylesheet">
    <style>
        :root { --dark-espresso: #1a120b; --mocha: #3d2b1f; --paper: #faf5ee; --aged-paper: #e6dac1; --accent-gold: #c29c61; }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { background-color: var(--dark-espresso); height: 100vh; display: flex; justify-content: center; align-items: center; overflow: hidden; font-family: 'Instrument Sans', sans-serif; }
        .bg-layer { position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: 1; pointer-events: none; }
        .floating-page { position: absolute; background: rgba(229, 224, 216, 0.15); border: 1px solid rgba(255,255,255,0.05); animation: drift linear infinite; }
        @keyframes drift { from { transform: translateY(110vh) rotate(0deg); opacity: 0; } 50% { opacity: 0.4; } to { transform: translateY(-20vh) rotate(360deg); opacity: 0; } }
        .book-wrapper { position: relative; z-index: 10; width: 900px; height: 580px; perspective: 2000px; }
        .book-obj { position: relative; width: 100%; height: 100%; transform-style: preserve-3d; transition: transform 1.2s cubic-bezier(0.4, 0, 0.2, 1); cursor: pointer; }
        .cover-front { position: absolute; right: 0; width: 50%; height: 100%; background: var(--mocha); color: var(--paper); z-index: 100; display: flex; flex-direction: column; justify-content: center; align-items: center; border-radius: 0 15px 15px 0; border: 3px solid var(--accent-gold); transform-origin: left; transition: transform 1.5s ease-in-out, opacity 0.8s ease-in-out; box-shadow: 10px 10px 30px rgba(0,0,0,0.5); backface-visibility: hidden; }
        .cover-front h1 { font-family: 'Cormorant Garamond', serif; font-size: 3rem; text-align: center; transition: opacity 0.5s; }
        .cover-front span { letter-spacing: 4px; font-size: 0.8rem; margin-top: 15px; opacity: 0.8; transition: opacity 0.5s; }
        .page-base { position: absolute; width: 50%; height: 100%; top: 0; background: var(--paper); padding: 50px 45px; box-shadow: inset 0 0 50px rgba(0,0,0,0.05); }
        .left-page { left: 0; border-radius: 15px 0 0 15px; z-index: 10; border-right: 1px solid rgba(0,0,0,0.1); }
        .right-page { right: 0; border-radius: 0 15px 15px 0; background: var(--aged-paper); z-index: 5; }
        .book-obj.is-open .cover-front { transform: rotateY(-170deg); opacity: 0; pointer-events: none; }
        .book-obj.is-open .cover-front h1, .book-obj.is-open .cover-front span { opacity: 0; }
        .role-toggle { display: flex; background: rgba(61, 43, 31, 0.08); padding: 4px; border-radius: 10px; margin-bottom: 35px; }
        .role-toggle label { flex: 1; text-align: center; font-size: 0.75rem; font-weight: 700; color: var(--mocha); padding: 8px; cursor: pointer; }
        .role-toggle input { display: none; }
        .role-toggle input:checked + span { background: white; display: block; border-radius: 8px; padding: 6px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .field { margin-bottom: 20px; }
        .field label { display: block; font-size: 0.7rem; font-weight: 700; color: #a58f7f; margin-bottom: 5px; }
        .field input { width: 100%; padding: 14px; border-radius: 10px; border: 1px solid #ddd; background: rgba(0,0,0,0.02); outline: none; }
        .btn-box { display: flex; gap: 15px; margin-top: 25px; }
        button { flex: 1; padding: 14px; border-radius: 10px; border: none; font-weight: 600; cursor: pointer; transition: 0.3s; }
        .btn-sign { background: #eee; color: #777; }
        .btn-sign:disabled { opacity: 0.5; cursor: not-allowed; }
        .btn-log { background: var(--mocha); color: white; }
        .error-label { color: #8b0000; font-size: 0.8rem; text-align: center; margin-top: 10px; font-weight: bold; }
 .quote-style { font-family: 'Cormorant Garamond', serif; font-size: 1.1rem; line-height: 1.8; color: #5d4037; font-style: italic; }
    </style>
</head>
<body onload="checkLoginStatus()">

    <div class="bg-layer" id="particles"></div>

    <div class="book-wrapper">
        <form action="first.jsp" method="POST" class="book-obj <%= loginFailed ? "is-open" : "" %>" id="mainBook">
            
            <div class="cover-front" onclick="document.getElementById('mainBook').classList.add('is-open')">
                <h1>LIBRARY MANAGEMENT</h1>
                <span>CLICK TO ENTER</span>
            </div>

            <div class="page-base left-page">
                <h3 style="font-family: 'Satisfy'; font-size: 1.8rem; color: var(--mocha); margin-bottom: 20px;">A Tale of Two Cities</h3>
                <p class="quote-style">  &nbsp; &nbsp;"It was the best of times, it was the worst of times..."</p>
                <br>
                <p class="quote-style">
                    &nbsp; &nbsp; &nbsp; &nbsp;"...we had everything before us, we had nothing before us, we were all going direct to Heaven, we were all going direct the other way ? in short, the period was so far like the present period, that some of its noisiest authorities insisted on its being received, for good or for evil, in the superlative degree of comparison only."
                </p>
            </div>
            
            <div class="page-base right-page">
                <div class="role-toggle">
                    <label><input type="radio" name="r" value="ADMIN" checked onclick="toggleSignIn(false)"><span>ADMIN</span></label>
                    <label><input type="radio" name="r" value="USER" onclick="toggleSignIn(true)"><span>USER</span></label>
                </div>

                <div class="field">
                    <label>USER ID</label>
                    <input type="text" name="userId" placeholder="Enter Username" required value="<%= request.getParameter("userId") != null ? request.getParameter("userId") : "" %>">
                </div>

                <div class="field">
                    <label>PASSWORD</label>
                    <input type="password" name="password" placeholder="????????" required>
                </div>

                <div class="btn-box">
                    <button type="button" id="btnSignIn" class="btn-sign" disabled onclick="location.href='nine.jsp'">SIGN IN</button>
                    <button type="submit" class="btn-log">LOG IN</button>
                </div>

                <% if(loginFailed) { %>
                    <div class="error-label"><%= errorMsg %></div>
                <% } %>

            </div>
        </form>
    </div>

    <script>
        function toggleSignIn(enable) {
            document.getElementById('btnSignIn').disabled = !enable;
        }

        function checkLoginStatus() {
            <% if(loginFailed) { %>
                document.getElementById('mainBook').classList.add('is-open');
            <% } %>
        }

        const container = document.getElementById('particles');
         for (let i = 0; i < 15; i++) {
            const p = document.createElement('div'); p.className = 'floating-page';
            const size = Math.random() * 30 + 20; p.style.width = size + 'px';
            p.style.height = (size * 1.4) + 'px'; p.style.left = Math.random() * 100 + 'vw';
            p.style.animationDuration = (Math.random() * 8 + 7) + 's';
            p.style.animationDelay = (Math.random() * 5) + 's';
            container.appendChild(p);
        }
    </script>
</body>
</html>