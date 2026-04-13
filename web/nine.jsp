<%@ page import="java.sql.*" %>
<%
    String statusMsg = "";
    String statusClass = "";

    // Backend logic: Check if form was submitted via POST
    if (request.getMethod().equals("POST")) {
        String fName = request.getParameter("firstName");
        String lName = request.getParameter("lastName");
        String addr = request.getParameter("address");
        String phone = request.getParameter("phone");
        String pass = request.getParameter("password");

        Connection con = null;
        PreparedStatement ps = null;

        try {
            // Database Connection logic
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/LMS", "root", "Root@1234");
            
            // Prepared Statement to match your save() method
            String sql = "INSERT INTO USER VALUES(?,?,?,?,?)";
            ps = con.prepareStatement(sql);
            ps.setString(1, fName);
            ps.setString(2, lName);
            ps.setString(3, addr);
            ps.setString(4, phone);
            ps.setString(5, pass);

            int result = ps.executeUpdate();
            if (result > 0) {
                statusMsg = "REGISTRATION SUCCESSFUL!";
                statusClass = "success-msg";
            }
        } catch (Exception e) {
            statusMsg = "ERROR: " + e.getMessage();
            statusClass = "error-msg";
        } finally {
            if (ps != null) ps.close();
            if (con != null) con.close();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LMS | Sign In</title>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@600;700&family=Instrument+Sans:wght@400;600&display=swap" rel="stylesheet">
    <style>
        :root { --dark-espresso: #1a120b; --mocha: #3d2b1f; --beige-paper: #f2ede4; --gold: #c29c61; --text-dark: #2c1e14; }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { background-color: var(--dark-espresso); min-height: 100vh; display: flex; justify-content: center; align-items: center; font-family: 'Instrument Sans', sans-serif; }
        
        .auth-card { width: 100%; max-width: 500px; background: var(--beige-paper); border-radius: 12px; box-shadow: 0 25px 50px rgba(0,0,0,0.5); border: 1px solid var(--gold); overflow: hidden; animation: fadeIn 0.6s ease-out; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }

        .header { background: var(--mocha); padding: 40px 20px; text-align: center; border-bottom: 3px solid var(--gold); }
        .header h1 { font-family: 'Cormorant Garamond', serif; color: var(--beige-paper); font-size: 2.5rem; text-transform: uppercase; letter-spacing: 4px; }
        
        form { padding: 40px; }
        .input-group { margin-bottom: 20px; }
        .input-group label { display: block; margin-bottom: 8px; color: var(--mocha); font-weight: 700; text-transform: uppercase; font-size: 0.75rem; letter-spacing: 1px; }
        .input-group input { width: 100%; padding: 12px 15px; border: 1px solid rgba(61, 43, 31, 0.2); background: white; border-radius: 4px; color: var(--text-dark); }
        .input-group input:focus { outline: none; border-color: var(--gold); box-shadow: 0 0 0 3px rgba(194, 156, 97, 0.1); }

        .btn-container { display: flex; gap: 15px; margin-top: 30px; }
        .btn { flex: 1; padding: 14px; border: none; border-radius: 4px; font-weight: 700; text-transform: uppercase; cursor: pointer; transition: 0.3s; font-size: 0.85rem; text-decoration: none; text-align: center; }
        .btn-save { background: var(--gold); color: var(--dark-espresso); }
        .btn-back { background: transparent; color: var(--mocha); border: 1px solid var(--mocha); }
        
        /* Status message styling */
        .status-box { text-align: center; padding: 10px; margin-bottom: 20px; font-weight: bold; border-radius: 4px; font-size: 0.8rem; }
        .success-msg { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .error-msg { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
    </style>
</head>
<body>

    <div class="auth-card">
        <div class="header">
            <h1>Sign In</h1>
        </div>

        <form action="nine.jsp" method="POST">
            <% if(!statusMsg.equals("")) { %>
                <div class="status-box <%= statusClass %>"><%= statusMsg %></div>
            <% } %>

            <div class="input-group">
                <label>First Name</label>
                <input type="text" name="firstName" required>
            </div>
            <div class="input-group">
                <label>Last Name</label>
                <input type="text" name="lastName" required>
            </div>
            <div class="input-group">
                <label>Address</label>
                <input type="text" name="address" required>
            </div>
            <div class="input-group">
                <label>Phone No.</label>
                <input type="tel" name="phone" required>
            </div>
            <div class="input-group">
                <label>Password</label>
                <input type="password" name="password" required>
            </div>

            <div class="btn-container">
                <button type="submit" class="btn btn-save">Save</button>
                <a href="first.jsp" class="btn btn-back">Back</a>
            </div>
        </form>
    </div>

</body>
</html>