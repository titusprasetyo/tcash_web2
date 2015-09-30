<%@page import="java.io.*, java.sql.*, java.util.*,java.text.*,java.net.*" contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="Util" scope="page" class="tsel_tunai.Util" />

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>GKIOS Reader Terminal List</title>
    </head>
    <body>
        Creating file.. <br />

<%
String output = request.getParameter("output");

if(output!=null){
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
		File f = new File(pathFile2);
		if(f.exists()) f.delete();
		if(!f.exists()) f.createNewFile();
	
		Class.forName("oracle.jdbc.OracleDriver");
		con = DriverManager.getConnection("jdbc:oracle:thin:@10.2.114.121:1521:OPTUNAI", "tunai", "tunai123");
		con.setAutoCommit(false);
		
		fileOut = new BufferedWriter(new FileWriter(pathFile2));
		
		//sqlQuery = "select mi.NAME, rt.terminal_id, rt.msisdn, rt.description, rt.keyterminal, rt.address, rt.url, rt.charge_info from reader_terminal rt, merchant m, merchant_info mi where (terminal_type=6 or terminal_type =69) and m.merchant_id=rt.merchant_id and m.merchant_info_id=mi.merchant_info_id order by mi.NAME";
		sqlQuery = "select mi.name, mi.address, mi.city, mi.npwp, mi.bank_name, mi.bank_acc_no, mi.bank_acc_holder, m.login, m.password, m.limit_monthly, tma.balance, rt.msisdn, rt.description, rt.keyterminal, rt.url, rt.charge_info from tsel_merchant_account tma, reader_terminal rt, merchant m, merchant_info mi where rt.terminal_type='6' and m.merchant_type='6' and rt.merchant_id=m.merchant_id and m.merchant_info_id=mi.merchant_info_id and m.acc_no=tma.acc_no";
		pstmt = con.prepareStatement(sqlQuery);
		rs = pstmt.executeQuery();
		while(rs.next()){
			String keyterminal = rs.getString("keyterminal");
			String password = rs.getString("password");
			//System.out.println(keyterminal + "|" +Util.decMy(keyterminal));
			// yang ada dicek satu persatu ke util
			if((keyterminal==null || keyterminal.equals("")) && (password==null || password.equals(""))) {
				//fileOut.write(rs.getString("NAME")+"|"+rs.getString("terminal_id")+"|"+rs.getString("msisdn")+"|"+rs.getString("description")+"|"+keyterminal+"|000000,"+rs.getString("address")+"|"+rs.getString("url")+"|"+rs.getString("charge_info")+"\n");
				//fileOut.write(rs.getString("NAME")+"|"+rs.getString("address")+"|"+rs.getString("city")+"|"+rs.getString("npwp")+"|"+rs.getString("bank_name")+"|"+rs.getString("bank_acc_no")+"|"+rs.getString("bank_acc_holder")+"|"+rs.getString("login")+"|"+(Util.decMy(rs.getString("password")))+"|"+rs.getString("limit_monthly")+"|"+rs.getString("balance")+"|"+rs.getString("msisdn")+"|"+rs.getString("description")+"|"+rs.getString("keyterminal")+"|000000|"+rs.getString("url")+"|"+rs.getString("charge_info")+"\n");
				fileOut.write(rs.getString("NAME")+"|"+(rs.getString("address")).replaceAll("\\r|\\n"," ")+"|"+rs.getString("city")+"|"+rs.getString("npwp")+"|"+rs.getString("bank_name")+"|"+rs.getString("bank_acc_no")+"|"+rs.getString("bank_acc_holder")+"|"+rs.getString("login")+"|"+(Util.decMy(rs.getString("password")))+"|"+rs.getString("limit_monthly")+"|"+rs.getString("balance")+"|"+rs.getString("msisdn")+"|"+(rs.getString("description")).replaceAll("\\r|\\n"," ")+"|"+rs.getString("keyterminal")+"|000000|"+rs.getString("url")+"|"+rs.getString("charge_info")+"\n");
			
			}else{
				try{
					//fileOut.write(rs.getString("NAME")+"|"+rs.getString("terminal_id")+"|"+rs.getString("msisdn")+"|"+rs.getString("description")+"|"+keyterminal+"|"+(Util.decMy(keyterminal))+"|"+rs.getString("address")+"|"+rs.getString("url")+"|"+rs.getString("charge_info")+"\n");
					//fileOut.write(rs.getString("NAME")+"|"+rs.getString("address")+"|"+rs.getString("city")+"|"+rs.getString("npwp")+"|"+rs.getString("bank_name")+"|"+rs.getString("bank_acc_no")+"|"+rs.getString("bank_acc_holder")+"|"+rs.getString("login")+"|"+(Util.decMy(rs.getString("password")))+"|"+rs.getString("limit_monthly")+"|"+rs.getString("balance")+"|"+rs.getString("msisdn")+"|"+rs.getString("description")+"|"+rs.getString("keyterminal")+"|"+(Util.decMy(rs.getString("keyterminal")))+"|"+rs.getString("url")+"|"+rs.getString("charge_info")+"\n");
					fileOut.write(rs.getString("NAME")+"|"+(rs.getString("address")).replaceAll("\\r|\\n"," ")+"|"+rs.getString("city")+"|"+rs.getString("npwp")+"|"+rs.getString("bank_name")+"|"+rs.getString("bank_acc_no")+"|"+rs.getString("bank_acc_holder")+"|"+rs.getString("login")+"|"+(Util.decMy(rs.getString("password")))+"|"+rs.getString("limit_monthly")+"|"+rs.getString("balance")+"|"+rs.getString("msisdn")+"|"+(rs.getString("description")).replaceAll("\\r|\\n"," ")+"|"+rs.getString("keyterminal")+"|"+(Util.decMy(rs.getString("keyterminal")))+"|"+rs.getString("url")+"|"+rs.getString("charge_info")+"\n");
				
				}catch(Exception e1){
					System.out.println("Exception raised. Error:"+e1.getMessage());
					//fileOut.write(rs.getString("NAME")+"|"+rs.getString("terminal_id")+"|"+rs.getString("msisdn")+"|"+rs.getString("description")+"|"+keyterminal+"|999999,"+rs.getString("address")+"|"+rs.getString("url")+"|"+rs.getString("charge_info")+"\n");
					//fileOut.write(rs.getString("NAME")+"|"+rs.getString("address")+"|"+rs.getString("city")+"|"+rs.getString("npwp")+"|"+rs.getString("bank_name")+"|"+rs.getString("bank_acc_no")+"|"+rs.getString("bank_acc_holder")+"|"+rs.getString("login")+"|"+(Util.decMy(rs.getString("password")))+"|"+rs.getString("limit_monthly")+"|"+rs.getString("balance")+"|"+rs.getString("msisdn")+"|"+rs.getString("description")+"|"+rs.getString("keyterminal")+"|999999|"+rs.getString("url")+"|"+rs.getString("charge_info")+"\n");
					fileOut.write(rs.getString("NAME")+"|"+(rs.getString("address")).replaceAll("\\r|\\n"," ")+"|"+rs.getString("city")+"|"+rs.getString("npwp")+"|"+rs.getString("bank_name")+"|"+rs.getString("bank_acc_no")+"|"+rs.getString("bank_acc_holder")+"|"+rs.getString("login")+"|"+(Util.decMy(rs.getString("password")))+"|"+rs.getString("limit_monthly")+"|"+rs.getString("balance")+"|"+rs.getString("msisdn")+"|"+(rs.getString("description")).replaceAll("\\r|\\n"," ")+"|"+rs.getString("keyterminal")+"|999999|"+rs.getString("url")+"|"+rs.getString("charge_info")+"\n");
				
				}
			}				
		}
		pstmt.close();rs.close();
		out.println("<b>GKIOS listing success.</b>");
		fileOut.close();
	}
	catch(Exception e){
		e.printStackTrace();
		try{con.rollback();}catch(Exception ee){}
		out.println("<b>Listing error.</b>");
		System.out.println(e.getMessage());
	}
	finally{
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
    out.println("<b>Incorrect parameter.<b>");
}

%>
    </body>
</html>
