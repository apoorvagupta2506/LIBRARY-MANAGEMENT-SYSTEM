<%@ page import="java.sql.*, java.util.*" %>

<%! 
    // Reusable connection logic similar to your 'connect' class
    Connection con = null;
    Statement st = null;
    ResultSet rs = null;

    Connection getConnect() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            // Using your established database credentials
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/LMS","root","Root@1234");
        } catch(Exception e) { e.printStackTrace(); }
        return con;
    }
%>

<%
    con = getConnect();
    int count = 0;
    List<String[]> bookData = new ArrayList<>();

    try {
        if (con != null) {
            st = con.createStatement();
            // Combined query to handle both countRecords() and showTable() logic
            rs = st.executeQuery("SELECT * FROM BOOK");
            
            while(rs.next()) {
                count++; // Increment count for every record found
                // Storing row data: BookName, Author, Publisher, Total, Available
                String[] row = new String[5];
                for(int j=0; j<5; j++) {
                    row[j] = rs.getString(j+1);
                }
                bookData.add(row);
            }
        }
    } catch(Exception e) {
        out.println("Database Error: " + e.getMessage());
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>LMS | Inventory Ledger</title>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@600;700&family=Instrument+Sans:wght@400;600&display=swap" rel="stylesheet">
    <style>
        :root { 
            --dark-espresso: #1a120b; --mocha: #3d2b1f; --beige-paper: #f2ede4; 
            --gold: #c29c61; --text-dark: #2c1e14; 
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body { 
            background-color: var(--dark-espresso); 
            min-height: 100vh; 
            display: flex; 
            justify-content: center; 
            align-items: center; 
            font-family: 'Instrument Sans', sans-serif; 
            padding: 20px;
        }

        .container-card { 
            width: 100%; max-width: 1050px; 
            background: var(--beige-paper); 
            border-radius: 12px; 
            box-shadow: 0 25px 50px rgba(0,0,0,0.5); 
            border: 1px solid var(--gold); 
            overflow: hidden;
            display: flex; flex-direction: column;
        }

        .header-section { 
            background: var(--mocha); padding: 30px; 
            text-align: center; border-bottom: 3px solid var(--gold);
        }

        .header-section h1 { 
            font-family: 'Cormorant Garamond', serif; 
            color: var(--beige-paper); font-size: 2.4rem; 
            text-transform: uppercase; letter-spacing: 3px;
        }

        .count-badge {
            color: var(--gold); font-size: 0.9rem; margin-top: 5px; font-weight: 600;
        }

        .table-wrapper {
            padding: 40px; background: var(--beige-paper);
            max-height: 550px; overflow-y: auto;
        }

        table { width: 100%; border-collapse: collapse; text-align: left; }

        thead th {
            background: var(--mocha); color: var(--gold);
            font-family: 'Cormorant Garamond', serif;
            text-transform: uppercase; padding: 18px 15px;
            position: sticky; top: 0; z-index: 10;
            border-bottom: 2px solid var(--gold);
        }

        tbody td {
            padding: 16px 15px; border-bottom: 1px solid rgba(61, 43, 31, 0.1);
            color: var(--text-dark); font-size: 0.95rem;
        }

        tbody tr:hover td { background: rgba(194, 156, 97, 0.08); }

        .stock-badge {
            display: inline-block; padding: 4px 12px;
            border-radius: 20px; font-weight: 600; font-size: 0.85rem;
            background: var(--mocha); color: var(--gold);
            border: 1px solid var(--gold);
        }

        .footer-actions { 
            padding: 20px 40px 40px; display: flex; 
            justify-content: center; background: var(--beige-paper);
        }

        .btn-back { 
            padding: 12px 45px; background: transparent; 
            color: var(--mocha); border: 2px solid var(--mocha); 
            border-radius: 4px; font-weight: 700;
            text-transform: uppercase; text-decoration: none; font-size: 0.85rem;
        }

        .btn-back:hover { background: var(--mocha); color: var(--beige-paper); }

        .table-wrapper::-webkit-scrollbar { width: 8px; }
        .table-wrapper::-webkit-scrollbar-thumb { background: var(--gold); border-radius: 4px; }
    </style>
</head>
<body>

    <div class="container-card">
        <div class="header-section">
            <h1>Display All Books</h1>
            <div class="count-badge">TOTAL RECORDS FOUND: <%= count %></div>
        </div>

        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Book Title</th>
                        <th>Author Name</th>
                        <th>Publisher</th>
                        <th>No of Copies</th>
                        <th>Available</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        // Scriptlet to loop through the bookData List
                        for(String[] row : bookData) { 
                    %>
                    <tr>
                        <td><strong><%= row[0] %></strong></td>
                        <td><%= row[1] %></td>
                        <td><%= row[2] %></td>
                        <td><%= row[3] %></td>
                        <td><span class="stock-badge"><%= row[4] %></span></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>

        <div class="footer-actions">
            <a href="third.html" class="btn-back">Back to Dashboard</a>
        </div>
    </div>

</body>
</html>