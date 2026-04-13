<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*" %>

<%!
    Connection con=null;
    PreparedStatement ps;
    
    Connection getConnect() {
        try {
            Class.forName("com.mysql.jdbc.Driver");
            con=DriverManager.getConnection("jdbc:mysql://localhost:3306/LMS","root","Root@1234");   
        } catch(Exception e) {   
            e.printStackTrace();
        }
        return con;
    }
    
    void bookDetails(String bookname, String authorname, String publisher, String copies) {
        String str="INSERT INTO BOOK VALUES(?,?,?,?,?)";
        
        try {
            getConnect();
            ps=con.prepareStatement(str);
            ps.setString(1, bookname);
            ps.setString(2, authorname);
            ps.setString(3, publisher);
            ps.setString(4, copies); 
            ps.setString(5, copies); 
            
            ps.executeUpdate();
            con.close();
        } catch(Exception e) {
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>LMS | Insert New Book</title>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@600;700&family=Instrument+Sans:wght@400;600&display=swap" rel="stylesheet">
    <style>
        :root {
            --dark-espresso: #1a120b;
            --mocha: #3d2b1f;
            --beige-paper: #f2ede4;
            --gold: #c29c61;
            --text-dark: #2c1e14;
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

        .form-card {
            width: 750px;
            background: var(--beige-paper);
            border-radius: 12px;
            box-shadow: 0 25px 50px rgba(0,0,0,0.4);
            overflow: hidden;
            border: 1px solid rgba(255,255,255,0.1);
        }

        .title-box {
            background: var(--mocha);
            padding: 25px;
            text-align: center;
            border-bottom: 3px solid var(--gold);
        }

        .title-box h1 {
            font-family: 'Cormorant Garamond', serif;
            color: var(--beige-paper);
            font-size: 2rem;
            letter-spacing: 4px;
            text-transform: uppercase;
        }

        form { padding: 50px 80px; display: grid; gap: 20px; }

        .input-group { display: flex; align-items: center; justify-content: space-between; }

        label {
            font-size: 0.85rem;
            font-weight: 700;
            color: var(--text-dark);
            text-transform: uppercase;
            letter-spacing: 1px;
            width: 40%;
        }

        input {
            width: 60%;
            padding: 12px 15px;
            border: 1px solid rgba(0,0,0,0.1);
            border-radius: 6px;
            background: rgba(255,255,255,0.6);
            outline: none;
            transition: 0.3s;
        }

        input:focus { background: white; border-color: var(--gold); }

        .btn-group { margin-top: 30px; display: flex; justify-content: center; gap: 20px; }

        .btn {
            padding: 12px 35px;
            border: none;
            border-radius: 5px;
            font-weight: 700;
            font-size: 0.8rem;
            cursor: pointer;
            transition: 0.3s;
        }

        .btn-save { background: var(--mocha); color: white; }
        .btn-save:hover { background: var(--gold); transform: translateY(-2px); }

        .btn-back { background: transparent; color: var(--mocha); border: 1px solid var(--mocha); }

        /* Added transition for smooth disappearance */
        .msg { 
            text-align: center; 
            padding: 10px; 
            color: #2e7d32; 
            font-weight: bold; 
            transition: opacity 0.4s ease;
        }
    </style>
</head>
<body>

    <div class="form-card">
        <div class="title-box">
            <h1>Insert Book Ledger </h1>
        </div>

        <%
            String bname = request.getParameter("bookName");
            if(bname != null) {
                String aname = request.getParameter("authorName");
                String pub = request.getParameter("publisher");
                String cp = request.getParameter("copies");
                bookDetails(bname, aname, pub, cp);
        %>
            <div id="statusMsg" class="msg">Archived: <%= bname %> (Units: <%= cp %>)</div>
        <% } %>

        <form action="fourth.jsp" method="POST">
            <div class="input-group">
                <label>Book Name</label>
                <input type="text" name="bookName" placeholder="Enter Book Title" required>
            </div>
            <div class="input-group">
                <label>Author Name</label>
                <input type="text" name="authorName" placeholder="Enter Author Name" required>
            </div>
            <div class="input-group">
                <label>Publisher</label>
                <input type="text" name="publisher" placeholder="Enter Publisher Name" required>
            </div>
            <div class="input-group">
                <label>No. of Copies</label>
                <input type="number" name="copies" placeholder="0" min="1" required>
            </div>
            <div class="btn-group">
                <button type="submit" class="btn btn-save">SAVE DATA</button>
                <button type="button" class="btn btn-back" onclick="location.href='third.html'">GO BACK</button>
            </div>
        </form>
    </div>

    <script>
        // Function to hide the message
        function clearStatus() {
            const msg = document.getElementById('statusMsg');
            if (msg) {
                msg.style.opacity = '0';
                // Remove from layout after fade
                setTimeout(() => { msg.style.display = 'none'; }, 400);
            }
        }

        // Trigger on any click or key press in the document
        document.addEventListener('mousedown', clearStatus);
        document.addEventListener('keydown', clearStatus);
    </script>
</body>
</html>