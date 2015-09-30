<%@page import="java.io.*, java.sql.*, java.util.*,java.text.*,java.net.*" contentType="text/html" pageEncoding="UTF-8"%>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>GKIOS Filter</title>
    </head>
    <body>
        Opening file.. <br />

<%
String input = request.getParameter("input");
String output = request.getParameter("output");

if(input!=null && output!=null){
    if(!input.equalsIgnoreCase(output)){
        //lolos
        //untuk file input
        String pathFile = application.getRealPath("/")+input;
        //untuk file output
        String pathFile2 = application.getRealPath("/")+output;

        String thisLine;
        BufferedReader fileIn = null;
        BufferedWriter fileOut = null;
		
		//database parameter
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sqlQuery = "";
		
        try{
            fileIn = new BufferedReader(new FileReader(pathFile));
            if(fileIn!=null){
                //thisLine = fileIn.readLine();
                ArrayList<String> al = new ArrayList<String>();
                while((thisLine=fileIn.readLine())!=null){
                    //System.out.println(thisLine);
					if(!thisLine.equals(""))al.add(thisLine);
                }

                File f = new File(pathFile2);
                if(f.exists()) f.delete();
                if(!f.exists()) f.createNewFile();

				
				Class.forName("oracle.jdbc.OracleDriver");
				con = DriverManager.getConnection("jdbc:oracle:thin:@10.2.114.121:1521:OPTUNAI", "tunai", "tunai123");
				con.setAutoCommit(false);

				
                fileOut = new BufferedWriter(new FileWriter(pathFile2));
                for (int i=0;i<al.size();i++){
					sqlQuery = "SELECT * FROM reader_terminal WHERE msisdn like '%"+al.get(i)+"'";
					pstmt = con.prepareStatement(sqlQuery);
					rs = pstmt.executeQuery();
					if(rs.next()){
						fileOut.write(al.get(i) + ",1\n");
					}else{
						fileOut.write(al.get(i) + ",0\n");
					}
					pstmt.close();rs.close();
				}
                out.println("<b>GKIOS filtering success.</b>");
                fileIn.close();
                fileOut.close();
            }
            else{
                out.println("<b>File input not found.</b>");
            }
        }
        catch(Exception e){
            e.printStackTrace();
			try{con.rollback();}catch(Exception ee){}
            out.println("<b>Conversion error.</b>");
            System.out.println(e.getMessage());
        }
        finally{
            if(fileIn!=null)fileIn.close();
            if(fileOut!=null)fileOut.close();
			try{
				if(con!=null) con.close();
				if(rs!=null) rs.close();
				if(pstmt!=null) pstmt.close();
			}
			catch(Exception e){}
        }

    }
    else{
        out.println("<b>File names cannot be the same.<b>");
    }
}
else{
    out.println("<b>Incorrect parameter.<b>");
}

%>
    </body>
</html>
