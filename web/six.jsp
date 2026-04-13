<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat" %>

<%! 
    Connection con = null;
    PreparedStatement pst;
    Statement st;

    Connection getConnect() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/LMS","root","Root@1234");   
        } catch(Exception e) { e.printStackTrace(); }
        return con;
    }
%>

<%
    con = getConnect();
    String message = "";
    
    String rollNo = (request.getParameter("rollNo") != null) ? request.getParameter("rollNo") : "";
    String studentName = "";
    String className = "";
    String selectedBook = request.getParameter("bookName");
    String author = "";
    String publisher = "";
    String dor = ""; 
    String currentReturnDate = new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
    String fineStr = "0";

    // 1. Fetch Student & Books (Equivalent to retrieve())
    List<String> userBooks = new ArrayList<>();
    if(!rollNo.isEmpty()) {
        try {
            st = con.createStatement();
            ResultSet rs = st.executeQuery("SELECT * FROM ISSUE WHERE ROLL_NO='" + rollNo + "'");
            while(rs.next()) {
                studentName = rs.getString(2);
                className = rs.getString(3);
                userBooks.add(rs.getString(4)); 
            }
        } catch(Exception e) { message = "Error: " + e.getMessage(); }
    }

    // 2. Fetch Book Details (Equivalent to bookCall())
    if(selectedBook != null && !selectedBook.isEmpty()) {
        try {
            st = con.createStatement();
            ResultSet rs = st.executeQuery("SELECT * FROM ISSUE WHERE BOOKNAME='" + selectedBook + "' AND ROLL_NO='" + rollNo + "'");
            if(rs.next()) {
                author = rs.getString(5);
                publisher = rs.getString(6);
                dor = rs.getString(8); 
            }
        } catch(Exception e) { e.printStackTrace(); }
    }

    // 3. CONDITIONAL SAVE LOGIC
    if (request.getParameter("returnBtn") != null) {
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            java.util.Date expected = sdf.parse(dor);
            java.util.Date actual = sdf.parse(currentReturnDate);
            
            long daysLate = 0;
            if (actual.after(expected)) {
                long diff = actual.getTime() - expected.getTime();
                daysLate = diff / (1000 * 60 * 60 * 24);
            }
            int totalFine = (int)daysLate * 5; 
            fineStr = String.valueOf(totalFine);

            // A. UPDATE RETURNBOOK ONLY IF FINE > 0
            if (totalFine > 0) {
                pst = con.prepareStatement("INSERT INTO RETURNBOOK VALUES(?,?,?,?,?,?,?,?,?)");
                pst.setString(1, rollNo);
                pst.setString(2, studentName);
                pst.setString(3, className);
                pst.setString(4, selectedBook);
                pst.setString(5, author);
                pst.setString(6, publisher);
                pst.setString(7, dor);
                pst.setString(8, currentReturnDate);
                pst.setInt(9, totalFine);
                pst.executeUpdate();
            }

            // B. ALWAYS Update Stock and Delete Issue Record
            st = con.createStatement();
            st.executeUpdate("UPDATE BOOK SET NO_AVAILABLECOPIES = NO_AVAILABLECOPIES + 1 WHERE BOOKNAME='" + selectedBook + "'");
            st.executeUpdate("DELETE FROM ISSUE WHERE BOOKNAME='" + selectedBook + "' AND ROLL_NO='" + rollNo + "'");

            message = (totalFine > 0) ? "RETURNED WITH FINE: ?" + fineStr : "RETURNED SUCCESSFULLY (NO FINE)";
        } catch(Exception e) { message = "Error: " + e.getMessage(); }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>LMS | Return Book Ledger</title>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@600;700&family=Instrument+Sans:wght@400;600&display=swap" rel="stylesheet">
    <style>
        :root { --dark-espresso: #1a120b; --mocha: #3d2b1f; --beige-paper: #f2ede4; --gold: #c29c61; --text-dark: #2c1e14; }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { background-color: var(--dark-espresso); height: 100vh; display: flex; justify-content: center; align-items: center; font-family: 'Instrument Sans', sans-serif; }
        .form-card { width: 780px; background: var(--beige-paper); border-radius: 10px; box-shadow: 0 25px 50px rgba(0,0,0,0.5); border: 1px solid var(--gold); overflow: hidden; }
        .title-box { background: var(--mocha); padding: 22px; text-align: center; border-bottom: 3px solid var(--gold); }
        .title-box h1 { font-family: 'Cormorant Garamond', serif; color: var(--beige-paper); font-size: 2rem; text-transform: uppercase; }
        form { padding: 35px 55px; display: grid; grid-template-columns: 1fr 1fr; gap: 18px 35px; }
        .input-group { display: flex; flex-direction: column; gap: 8px; }
        .full-width { grid-column: span 2; }
        label { font-size: 0.72rem; font-weight: 700; color: var(--text-dark); text-transform: uppercase; }
        input, select { width: 100%; padding: 11px 14px; border: 1px solid rgba(0,0,0,0.1); border-radius: 4px; background: rgba(255,255,255,0.6); outline: none; font-size: 0.95rem; }
        input[readonly] { background: #e9e4db; color: #555; }
        .fine-input { color: #b33939; font-weight: 700; background: #fdf2f2 !important; border: 1px solid #ebccd1; }
        .btn-group { grid-column: span 2; margin-top: 20px; display: flex; justify-content: center; gap: 20px; }
        .btn { padding: 14px 45px; border: none; border-radius: 4px; font-weight: 700; cursor: pointer; text-transform: uppercase; text-decoration: none; font-size: 0.85rem; }
        .btn-save { background: var(--mocha); color: white; border: 1px solid var(--gold); }
        .btn-back { background: transparent; color: var(--mocha); border: 1px solid var(--mocha); text-align: center; line-height: 1.2; }
        #status-msg { color: var(--gold); font-weight: bold; margin-top: 10px; min-height: 20px; transition: 0.3s; }
    </style>
    <script>
        function autoSubmit() { 
            const form = document.getElementById("returnForm");
            form.method = "GET"; 
            form.submit(); 
        }

        document.addEventListener('click', function(event) {
            const msg = document.getElementById('status-msg');
            if (msg && (msg.innerText.includes("SUCCESSFULLY") || msg.innerText.includes("WITH FINE"))) {
                msg.innerText = "";
                window.location.href = "six.jsp"; 
            }
        });
    </script>
</head>
<body>
    <div class="form-card">
        <div class="title-box">
            <h1>Return Book Ledger</h1>
            <div id="status-msg"><%= message %></div>
        </div>
        <form id="returnForm" action="six.jsp" method="POST">
            <div class="input-group">
                <label>Roll No.</label>
                <input type="text" name="rollNo" value="<%= rollNo %>" onchange="autoSubmit()" required>
            </div>
            <div class="input-group">
                <label>Student Name</label>
                <input type="text" value="<%= studentName %>" readonly>
            </div>
            <div class="input-group">
                <label>Class / Department</label>
                <input type="text" value="<%= className %>" readonly>
            </div>
            <div class="input-group">
                <label>Book Title</label>
                <select name="bookName" onchange="autoSubmit()" required>
                    <option value="" disabled <%= (selectedBook == null) ? "selected" : "" %>>Select Issued Book</option>
                    <% for(String b : userBooks) { %>
                        <option value="<%= b %>" <%= (b.equals(selectedBook)) ? "selected" : "" %>><%= b %></option>
                    <% } %>
                </select>
            </div>
            <div class="input-group">
                <label>Author</label>
                <input type="text" value="<%= author %>" readonly>
            </div>
            <div class="input-group">
                <label>Publisher</label>
                <input type="text" value="<%= publisher %>" readonly>
            </div>
            <div class="input-group">
                <label>Expected Return Date</label>
                <input type="text" value="<%= dor %>" readonly>
            </div>
            <div class="input-group">
                <label>Actual Return Date</label>
                <input type="text" value="<%= currentReturnDate %>" readonly>
            </div>
            <div class="input-group full-width">
                <label>Calculated Fine (?)</label>
                <input type="text" class="fine-input" value="<%= fineStr %>" readonly>
            </div>
            <div class="btn-group">
                <button type="submit" name="returnBtn" class="btn btn-save">Confirm Return</button>
                <a href="third.html" class="btn btn-back">Back</a>
            </div>
        </form>
    </div>
</body>
</html>