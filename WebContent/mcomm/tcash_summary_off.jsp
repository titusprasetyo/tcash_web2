<%@ page import="java.sql.*, java.text.*, java.util.*"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon" />
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<%
	if(session.getValue("user") == null) {
		response.sendRedirect("index.html");	
	}
	NumberFormat nf = NumberFormat.getInstance(Locale.ITALY);
	SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
	
	Connection con_tcash = null;
	Connection con_ecash = null;
	String sql = "";
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	
	User user = (User)session.getValue("user");
	
	// parameter report
	String 	status_tapizy = "Balance",
		
		total_bal_tapizy = "0",
		fee_total = "0",
		fee_ecash = "0",
		fee_tcash = "0",
		
		total_bal_customer = "0",
		total_trx_customer = "0",
		total_customer_inactive = "0",
		total_customer = "0",
		
		total_merchant = "0",
		total_merchant_inactive = "0",
		total_edc = "0",
		total_edc_inactive = "0",
		total_trx_merchant = "0",
		total_bal_pur_merchant = "0",
		total_bal_dep_merchant = "0",
		
		ecash_merchant_id = "123456789",
		ecash_acc_no = "123456789",
		ecash_balance = "0"
		;
	
	
	if(user!=null){
%>

</SCRIPT>
<%@ include file="/web-starter/taglibs.jsp"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Summary TCash TAPizy">
	<stripes:layout-component name="contents">
        <div align="right"><font color="#FFFFFF" face="Verdana, Arial, Helvetica, sans-serif"></font> 
        </div>
        <div align="right"> </div>
        <div align="right"> </div>
		
		
		<table width="60%" border="0" cellpadding="0" cellspacing="0">
			<tr bgcolor="#FFF6EF"> 
				<td colspan="11"><div align="right"><font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>.:: 
					Summary TCash TAPizy (<%= sdf.format(new java.util.Date())%>)</strong></font></div></td>
			</tr>			
<%
	try {
		Class.forName("oracle.jdbc.OracleDriver");
		con_tcash = DbCon.getConnection();
		//con_ecash = DriverManager.getConnection("jdbc:oracle:thin:@//10.2.248.246:1521/orcl", "ecash", "orclecash");
		con_ecash = DriverManager.getConnection("jdbc:oracle:thin:@//10.2.125.46:1521/xe", "ecash", "orclecash");

%>
			<tr>
				<td colspan="3" bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>ECash Merchant Information</strong></font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> ECash Merchant ID </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%= ecash_merchant_id %> </font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> ECash Merchant Acc No </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%= ecash_acc_no%> </font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> ECash Online Balance </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Rp. <%= nf.format(Long.parseLong(ecash_balance))%> </strong></font></div></td>
			</tr>
			
			
			
			<tr>
				<td colspan="3" bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>TAPizy Merchants Information</strong></font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total TAPizy Merchants </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%= nf.format(Long.parseLong(total_merchant)) %> Merchants </font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total TAPizy inactive Merchants </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%= nf.format(Long.parseLong(total_merchant_inactive)) %> Merchants </font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total TAPizy EDCs </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%= nf.format(Long.parseLong(total_edc)) %> EDCs </font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total TAPizy inactive EDCs </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%= nf.format(Long.parseLong(total_edc_inactive)) %> EDCs </font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total Transactions in TAPizy Merchants </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%= nf.format(Long.parseLong(total_trx_merchant))%> trx </font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total Deposit Balance of TAPizy Merchants </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Rp. <%= nf.format(Long.parseLong(total_bal_dep_merchant))%> </strong></font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total Purchase Balance of TAPizy Merchants </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Rp. <%= nf.format(Long.parseLong(total_bal_pur_merchant))%> </strong></font></div></td>
			</tr>
			
			
			<tr>
				<td colspan="3" bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>TAPizy Customers Information</strong></font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total TAPizy Customers </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%= nf.format(Long.parseLong(total_customer)) %> Customers </font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total TAPizy inactive Customers </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%= nf.format(Long.parseLong(total_customer_inactive)) %> Customers </font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total Transactions in TAPizy Customers </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%= nf.format(Long.parseLong(total_trx_customer))%> trx </font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total Balance of TAPizy Customers </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Rp. <%= nf.format(Long.parseLong(total_bal_customer))%> </strong></font></div></td>
			</tr>
			
			
			<tr>
				<td colspan="3" bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Others Information</strong></font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Fee TAPizy ECash </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Rp. <%= nf.format(Long.parseLong(fee_ecash)) %> </strong></font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Fee TAPizy TCash </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Rp. <%= nf.format(Long.parseLong(fee_tcash))%> </strong></font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Fee Total TAPizy Merchants </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Rp. <%= nf.format(Long.parseLong(fee_total))%> </font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total TAPizy Balance </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Rp. <%= nf.format(Long.parseLong(total_bal_tapizy))%> </strong></font></div></td>
			</tr>
			
			
			<tr>
				<td colspan="3" bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>TAPizy Status</strong></font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Status </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> <%= status_tapizy %> </strong></font></div></td>
			</tr>
		</table>
		 
        <br />
        <br />
        <br />
        <br />
<%
	}catch(Exception  e){
		e.printStackTrace(System.out);
	}finally{
		try { if(con_ecash!=null)con_ecash.close(); if(con_tcash!=null)con_tcash.close(); if(pstmt!=null)pstmt.close(); if(rs!=null)rs.close();} catch(Exception ee){}
	}
%>
		</stripes:layout-component>
</stripes:layout-render>
<%
}else{
	response.sendRedirect("index.html");
}
%>