<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*" %>
<%
    // 1. Session Check: Verify the user is still logged in
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
    <title>LMS | My Issued Books</title>
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
            width: 1000px; 
            height: 650px;
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
            margin-bottom: 20px;
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

        .table-wrapper {
            flex: 1;
            overflow-y: auto;
            margin-bottom: 20px;
            border: 1px solid rgba(61, 43, 31, 0.2);
            background: rgba(250, 245, 238, 0.6);
            border-radius: 5px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.85rem;
        }

        th {
            background-color: var(--mocha);
            color: var(--paper);
            padding: 15px;
            text-align: left;
            position: sticky;
            top: 0;
            text-transform: uppercase;
            letter-spacing: 1px;
            z-index: 2;
        }

        td {
            padding: 12px 15px;
            border-bottom: 1px solid rgba(61, 43, 31, 0.1);
            color: var(--dark-espresso);
        }

        tr:hover {
            background-color: rgba(194, 156, 97, 0.15);
        }

        .no-data {
            text-align: center;
            padding: 50px;
            font-style: italic;
            color: #777;
        }

        /* Scrollbar */
        .table-wrapper::-webkit-scrollbar { width: 8px; }
        .table-wrapper::-webkit-scrollbar-track { background: var(--aged-paper); }
        .table-wrapper::-webkit-scrollbar-thumb { background: var(--mocha); border-radius: 4px; }

        .footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
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
            <h1>My Issued Books</h1>
        </div>

        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Book Name</th>
                        <th>Author</th>
                        <th>Publisher</th>
                        <th>Issue Date</th>
                        <th>Return Date</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/LMS", "root", "Root@1234");
                            
                            // UPDATED TO MATCH YOUR TABLE 'ISSUE' AND COLUMN 'NAME'
                            String sql = "SELECT * FROM ISSUE WHERE NAME = ?";
                            ps = con.prepareStatement(sql);
                            ps.setString(1, user);
                            rs = ps.executeQuery();
                            
                            boolean hasBooks = false;
                            while(rs.next()) {
                                hasBooks = true;
                    %>
                                <tr>
                                    <td><%= rs.getString("BOOKNAME") %></td>
                                    <td><%= rs.getString("AUTHOR") %></td>
                                    <td><%= rs.getString("PUBLISHER") %></td>
                                    <td><%= rs.getString("DOI") %></td>
                                    <td><%= rs.getString("DOR") %></td>
                                </tr>
                    <%
                            }
                            if(!hasBooks) {
                    %>
                                <tr>
                                    <td colspan="5" class="no-data">No books found issued to your account.</td>
                                </tr>
                    <%
                            }
                        } catch (Exception e) {
                    %>
                            <tr>
                                <td colspan="5" style="text-align:center; color:#8b0000; padding: 20px;">
                                    <strong>Error:</strong> <%= e.getMessage() %>
                                </td>
                            </tr>
                    <%
                        } finally {
                            if (rs != null) rs.close();
                            if (ps != null) ps.close();
                            if (con != null) con.close();
                        }
                    %>
                </tbody>
            </table>
        </div>

        <div class="footer">
            <a href="ten.jsp" class="btn-back">RETURN TO DASHBOARD</a>
            <div class="user-tag">Reader: <%= user %></div>
        </div>
    </div>
        
</body>
</html>