<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat" %>

<%! 
    Connection con = null;
    PreparedStatement ps;
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
    
    String selectedBook = request.getParameter("bookName");
    String rollNo = (request.getParameter("rollNo") != null) ? request.getParameter("rollNo") : "";
    String studentName = (request.getParameter("studentName") != null) ? request.getParameter("studentName") : "";
    String className = (request.getParameter("class") != null) ? request.getParameter("class") : "";
    
    String doi = request.getParameter("issueDate");
    if(doi == null || doi.isEmpty()) {
        doi = new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
    }

    String auth = "";
    String pub = "";
    
    // Auto-fetch Author and Publisher when a book is selected
    if(selectedBook != null && !selectedBook.isEmpty()) {
        try {
            ps = con.prepareStatement("SELECT authorname, publisher FROM BOOK WHERE BOOKNAME=?");
            ps.setString(1, selectedBook);
            ResultSet rsD = ps.executeQuery();
            if(rsD.next()) { 
                auth = rsD.getString("authorname");
                pub = rsD.getString("publisher");
            }
        } catch(Exception e) { e.printStackTrace(); }
    }

    // Logic for Issuing the Book
    if (request.getMethod().equalsIgnoreCase("POST") && request.getParameter("issueBtn") != null) {
        try {
            // 1. Backend Validation: Check for existing issues and limits
            String checkQuery = "SELECT * FROM ISSUE WHERE ROLL_NO='" + rollNo + "'";
            st = con.createStatement();
            ResultSet rs = st.executeQuery(checkQuery);
            
            int count = 0;
            boolean alreadyHasBook = false;

            while(rs.next()) {
                count++;
                // Check if this student already has this specific book
                if(selectedBook != null && selectedBook.equals(rs.getString("BOOKNAME"))) {
                    alreadyHasBook = true;
                }
            }

            if(alreadyHasBook) {
                message = "BOOK ALREADY EXIST FOR THIS ROLL NO";
            } 
            else if(count >= 3) {
                message = "MORE THAN THREE BOOKS CANNOT BE ISSUED";
            } 
            else {
                // 2. Proceed with Issuance
                ps = con.prepareStatement("INSERT INTO ISSUE (ROLL_NO, NAME, CLASS, BOOKNAME, AUTHOR, PUBLISHER, DOI) VALUES (?,?,?,?,?,?,?)");
                ps.setString(1, rollNo);
                ps.setString(2, studentName);
                ps.setString(3, className);
                ps.setString(4, selectedBook);
                ps.setString(5, auth);
                ps.setString(6, pub);
                ps.setString(7, doi);
                ps.executeUpdate();

                // Update Return Date (DOR) and available copies
                st.executeUpdate("UPDATE ISSUE SET DOR = DATE_ADD(DOI, INTERVAL 15 DAY) WHERE ROLL_NO='"+rollNo+"' AND BOOKNAME='"+selectedBook+"'");
                st.executeUpdate("UPDATE BOOK SET NO_AVAILABLECOPIES = NO_AVAILABLECOPIES - 1 WHERE BOOKNAME='"+selectedBook+"'");

                message = "BOOK ISSUED SUCCESSFULLY!";
                
                // Clear fields on success
                rollNo = ""; studentName = ""; className = ""; selectedBook = ""; auth = ""; pub = "";
            }
            
        } catch (Exception e) { 
            message = "Database Error: " + e.getMessage(); 
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>LMS | Issue Book Ledger</title>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@600;700&family=Instrument+Sans:wght@400;600&display=swap" rel="stylesheet">
    <style>
        :root { --dark-espresso: #1a120b; --mocha: #3d2b1f; --beige-paper: #f2ede4; --gold: #c29c61; --text-dark: #2c1e14; }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { background-color: var(--dark-espresso); min-height: 100vh; display: flex; justify-content: center; align-items: center; font-family: 'Instrument Sans', sans-serif; }
        .form-card { width: 850px; background: var(--beige-paper); border-radius: 12px; box-shadow: 0 25px 50px rgba(0,0,0,0.5); border: 1px solid var(--gold); }
        .title-box { background: var(--mocha); padding: 25px; text-align: center; border-bottom: 3px solid var(--gold); }
        .title-box h1 { font-family: 'Cormorant Garamond', serif; color: var(--beige-paper); font-size: 2.2rem; text-transform: uppercase; }
        form { padding: 40px 60px; display: grid; grid-template-columns: 1fr 1fr; gap: 20px 40px; }
        .input-group { display: flex; flex-direction: column; gap: 8px; }
        label { font-size: 0.75rem; font-weight: 700; color: var(--text-dark); text-transform: uppercase; }
        input, select { width: 100%; padding: 12px 15px; border: 1px solid rgba(0,0,0,0.1); border-radius: 4px; background: rgba(255,255,255,0.6); outline: none; }
        input[readonly] { background: #e9e4db; color: #555; }
        .btn-group { grid-column: span 2; margin-top: 20px; display: flex; justify-content: center; gap: 20px; }
        .btn { padding: 14px 40px; border: none; border-radius: 4px; font-weight: 700; cursor: pointer; text-transform: uppercase; transition: 0.3s; text-decoration: none; display: inline-block; font-size: 0.85rem;}
        .btn-save { background: var(--mocha); color: white; border: 1px solid var(--gold); }
        .btn-back { background: transparent; color: var(--mocha); border: 1px solid var(--mocha); text-align: center; }
        #status-msg { color: var(--gold); margin-top: 5px; font-weight: bold; min-height: 24px;}
    </style>
    
    <script>
        function autoFetch() {
            var form = document.getElementById("issueForm");
            form.method = "GET"; 
            form.submit();
        }
    </script>
</head>
<body>

    <div class="form-card">
        <div class="title-box">
            <h1>Issued Book Ledger</h1>
            <div id="status-msg"><%= message %></div>
        </div>

        <form id="issueForm" action="five.jsp" method="POST">
            <div class="input-group">
                <label>Roll No.</label>
                <input type="text" name="rollNo" value="<%= rollNo %>" required>
            </div>
            <div class="input-group">
                <label>Student Name</label>
                <input type="text" name="studentName" value="<%= studentName %>" required>
            </div>
            <div class="input-group">
                <label>Class / Department</label>
                <input type="text" name="class" value="<%= className %>" required>
            </div>
            
            <div class="input-group">
                <label>Book Name</label>
                <select name="bookName" onchange="autoFetch()" required>
                    <option value="" disabled <%= (selectedBook == null || selectedBook.isEmpty()) ? "selected" : "" %>>Select Book</option>
                    <%
                        try {
                            st = con.createStatement();
                            ResultSet rsB = st.executeQuery("SELECT BOOKNAME FROM BOOK WHERE NO_AVAILABLECOPIES > 0");
                            while(rsB.next()) {
                                String b = rsB.getString(1);
                                String isSel = (b.equals(selectedBook)) ? "selected" : "";
                                out.println("<option value='"+b+"' "+isSel+">"+b+"</option>");
                            }
                        } catch(Exception e) {}
                    %>
                </select>
            </div>

            <div class="input-group">
                <label>Author</label>
                <input type="text" name="author" value="<%= auth %>" readonly>
            </div>
            <div class="input-group">
                <label>Publisher</label>
                <input type="text" name="publisher" value="<%= pub %>" readonly>
            </div>

            <div class="input-group" style="grid-column: span 2;">
                <label>Date of Issue</label>
                <input type="date" name="issueDate" value="<%= doi %>" required>
            </div>

            <div class="btn-group">
                <button type="submit" name="issueBtn" class="btn btn-save">ISSUE BOOK</button>
                <a href="third.html" class="btn btn-back">BACK</a>
            </div>
        </form>
    </div>

</body>
</html>
