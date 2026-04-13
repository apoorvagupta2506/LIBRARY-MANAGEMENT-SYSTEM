<%@ page import="java.sql.*, java.util.*" %>

<%! 
    Connection con = null;
    Statement st = null;
    ResultSet rs = null;

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
    int recordCount = 0;
    List<String[]> issueData = new ArrayList<>();
    
    String searchRoll = request.getParameter("rollNo");
    String action = request.getParameter("action"); 

    if (con != null && action != null) {
        try {
            String sql = "";
            if (action.equals("all")) {
                sql = "SELECT * FROM ISSUE";
            } else if (action.equals("specific") && searchRoll != null && !searchRoll.isEmpty()) {
                sql = "SELECT * FROM ISSUE WHERE ROLL_NO='" + searchRoll + "'";
            }

            if (!sql.equals("")) {
                st = con.createStatement();
                rs = st.executeQuery(sql);
                while(rs.next()) {
                    recordCount++;
                    String[] row = new String[8];
                    for(int j=0; j<8; j++) {
                        row[j] = rs.getString(j+1);
                    }
                    issueData.add(row);
                }
            }
        } catch(Exception e) {
            out.println("<script>alert('Error: " + e.getMessage() + "');</script>");
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>LMS | Issued Books Ledger</title>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@600;700&family=Instrument+Sans:wght@400;600&display=swap" rel="stylesheet">
    <style>
        :root { --dark-espresso: #1a120b; --mocha: #3d2b1f; --beige-paper: #f2ede4; --gold: #c29c61; --text-dark: #2c1e14; }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { background-color: var(--dark-espresso); min-height: 100vh; display: flex; justify-content: center; align-items: center; font-family: 'Instrument Sans', sans-serif; padding: 20px; }
        
        .container-card { 
            width: 100%; max-width: 1150px; background: var(--beige-paper); 
            border-radius: 12px; box-shadow: 0 25px 50px rgba(0,0,0,0.5); 
            border: 1px solid var(--gold); overflow: hidden;
        }

        .header-section { background: var(--mocha); padding: 25px; text-align: center; border-bottom: 3px solid var(--gold); }
        .header-section h1 { font-family: 'Cormorant Garamond', serif; color: var(--beige-paper); font-size: 2.2rem; text-transform: uppercase; letter-spacing: 2px; }
        
        .control-bar {
            display: flex; justify-content: center; align-items: center; gap: 30px;
            padding: 25px 40px; background: rgba(61, 43, 31, 0.05); border-bottom: 1px solid rgba(0,0,0,0.1);
        }

        .search-group { display: flex; gap: 10px; align-items: center; }
        input[type="text"] { padding: 10px 15px; border: 1px solid var(--gold); border-radius: 4px; width: 180px; outline: none; background: white; }
        
        .btn { padding: 10px 20px; border: none; border-radius: 4px; font-weight: 700; cursor: pointer; text-transform: uppercase; font-size: 0.75rem; transition: 0.3s; }
        .btn-gold { background: var(--gold); color: var(--dark-espresso); }
        .btn-mocha { background: var(--mocha); color: white; border: 1px solid var(--gold); }
        .btn-outline { background: transparent; border: 2px solid var(--mocha); color: var(--mocha); text-decoration: none; padding: 12px 40px; display: inline-block; }
        .btn:hover { opacity: 0.9; transform: translateY(-1px); }

        .status-info { padding: 10px 40px; background: #eeeae3; font-size: 0.85rem; font-weight: 600; color: var(--mocha); text-align: center; }

        .table-wrapper { padding: 30px 40px; max-height: 400px; overflow-y: auto; border-bottom: 1px solid rgba(0,0,0,0.05); }
        table { width: 100%; border-collapse: collapse; text-align: left; }
        thead th { background: var(--mocha); color: var(--gold); font-family: 'Cormorant Garamond', serif; padding: 15px; position: sticky; top: 0; z-index: 10; border-bottom: 2px solid var(--gold); }
        tbody td { padding: 12px 15px; border-bottom: 1px solid rgba(61, 43, 31, 0.1); color: var(--text-dark); font-size: 0.85rem; }
        
        .footer-actions { padding: 30px; display: flex; justify-content: center; background: var(--beige-paper); }
        .empty-msg { text-align: center; padding: 60px; color: #888; font-style: italic; }
    </style>
</head>
<body>

    <div class="container-card">
        <form action="eight.jsp" method="POST">
            <div class="header-section">
                <h1>Issued Book Ledger</h1>
            </div>

            <div class="control-bar">
                <div class="search-group">
                    <label style="font-size: 0.75rem; font-weight: bold;">ROLL NO:</label>
                    <input type="text" name="rollNo" value="<%= (searchRoll != null) ? searchRoll : "" %>">
                    <button type="submit" name="action" value="specific" class="btn btn-gold">Display For Student</button>
                </div>
                <button type="submit" name="action" value="all" class="btn btn-mocha">Display All Issued Books</button>
            </div>
        </form>

        <div class="status-info">
            <% if(action == null) { %> SELECT AN OPTION TO LOAD DATA <% } else { %> RECORDS FOUND: <%= recordCount %> <% } %>
        </div>

        <div class="table-wrapper">
            <% if(action == null) { %>
                <div class="empty-msg">No data selected. Use the controls above to view records.</div>
            <% } else { %>
                <table>
                    <thead>
                        <tr>
                            <th>Roll No.</th><th>Name</th><th>Class</th><th>Book Name</th><th>Author</th><th>Publisher</th><th>Issue Date</th><th>Return Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if(issueData.isEmpty()) { %>
                            <tr><td colspan="8" style="text-align:center; padding: 40px;">No matching records in database.</td></tr>
                        <% } else {
                            for(String[] row : issueData) { %>
                            <tr>
                                <td><%= row[0] %></td><td><strong><%= row[1] %></strong></td><td><%= row[2] %></td><td><%= row[3] %></td><td><%= row[4] %></td><td><%= row[5] %></td><td><%= row[6] %></td><td><%= row[7] %></td>
                            </tr>
                        <% } } %>
                    </tbody>
                </table>
            <% } %>
        </div>

        <div class="footer-actions">
            <a href="third.html" class="btn btn-outline">Back to Dashboard</a>
        </div>
    </div>

</body>
</html>