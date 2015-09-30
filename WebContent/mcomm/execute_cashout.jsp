<%@page import="com.telkomsel.itvas.webstarter.User"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<jsp:useBean id="u" scope="request" class="tsel_tunai.UssdTx" />
<%@ include file="/web-starter/taglibs.jsp"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Deposit List">
	<stripes:layout-component name="contents">
<%

boolean b1 = false;
boolean b2 = false;
boolean b3 = false;
boolean b4 = false;

String browse = request.getParameter("browse");
if (browse == null) {
	browse = "";
}

if (request.getMethod().equals("POST") && !browse.equals("1")) {
	User user = (User)session.getValue("user");
	String cashout_id = request.getParameter("cashout_id");
	String doc_number = request.getParameter("doc_number");
	if(user != null)
	{
   	//	session.putValue("user", user);
		Connection conn = null;
		conn = DbCon.getConnection();
		try
		{
			
			String q = "SELECT AMOUNT, MERCHANT_ID FROM MERCHANT_CASHOUT WHERE CASHOUT_ID=?";
			PreparedStatement ps = conn.prepareStatement(q);
			ps.setString(1, cashout_id);
			ResultSet rs = ps.executeQuery();
			String[] retval = new String[] {"04", "internal_problem"};
			if (rs.next()) {
				String amount = rs.getString("AMOUNT");
				String merchant_id = rs.getString("MERCHANT_ID");
				u.setAmount(amount);
				u.setMerchant_id(merchant_id);
				retval = u.doMerchantCashout(cashout_id);
				
				if (retval[0].equals("00")) {
					PreparedStatement stmt = null;
					String sql = null;
					sql = "INSERT INTO ACTIVITY_LOG (USERLOGIN, ACCESS_TIME, ACTIVITY, NOTE, IP) values (?,sysdate, ?,?,?)";
					stmt = conn.prepareStatement(sql);
					stmt.setString(1, user.getUsername());
					stmt.setString(2, "Execute Cashout|" + cashout_id);
					stmt.setString(3, "Success");
					stmt.setString(4, request.getRemoteAddr());
					stmt.executeUpdate();
					stmt.close();
					
					
					sql = "UPDATE merchant_cashout SET DOC_NUMBER=?, EXEC_TIME=SYSDATE, EXECUTOR='"+user.getUsername()+"' WHERE CASHOUT_ID=?";
					stmt = conn.prepareStatement(sql);
					stmt.setString(1, doc_number);
					stmt.setString(2, cashout_id);
					stmt.executeUpdate();
					stmt.close();
					b1 = true;
					
					
					//response.sendRedirect("execute_cashout.jsp?msg=Cashout+Executed");
				} else {
					b2 = true;
					//response.sendRedirect("execute_cashout.jsp?msg=" + java.net.URLEncoder.encode("Execution failed, reason : " + retval[0] + ":" + retval[1]));			
				}
			} else {
						b3 = true;
						//response.sendRedirect("execute_cashout.jsp?msg=" + java.net.URLEncoder.encode("Execution failed, reason : cashout not found" ));			
			}
			rs.close();
		
		
		
		
		}
		catch(Exception  e){
			//response.sendRedirect("execute_cashout.jsp?msg=" + java.net.URLEncoder.encode("Execution failed, because of database error"));
			b4 = true;
			e.printStackTrace(System.out);
		} finally{
		try { if(conn != null) conn.close(); } catch(Exception ee){}
		}
		
		if(b1) response.sendRedirect("execute_cashout.jsp?msg=Cashout+Executed");
		if(b2) response.sendRedirect("execute_cashout.jsp?msg=Cashout+Gagal+Pastikan+Saldo+Lebih+Besar+Dari+Amount+Cashout");
		if(b3) response.sendRedirect("execute_cashout.jsp?msg=Cashout+Gagal");
		if(b4) response.sendRedirect("execute_cashout.jsp?msg=Cashout+Gagal");
		
		
	} else {
		response.sendRedirect("admin.html");	
	}
}
%>

<%@ page import="java.sql.*"%>
<script language="JavaScript">
<!--
function checkExecute()
{
	with(document)
	{
		var checkStatus = confirm('Do you really want to execute this cashout?');
		if (checkStatus)
		{
			checkStatus = true;
		}
		return checkStatus;
	}
}


function nameempty(objek){
        if(objek.value == '' ){
                alert('Doc number masih kosong!')
                return false;
        }else{
			return true;
		}
}

//-->
</script>

<%
	User user = (User)session.getValue("user");
	String msisdn = request.getParameter("msisdn");
	if(user != null)
	{
%>

        <%
	
   
	
	Connection conn = null;
	try{
		
		conn = DbCon.getConnection();
	%>
        <div align="right"><font color="#FFFFFF" face="Verdana, Arial, Helvetica, sans-serif"></font> 
        </div>
        <div align="right"> </div>
        <div align="right"> </div>
	    
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			  <tr> 
            <td><div align="right"><font color="#CC6633" size="4" face="Verdana, Arial, Helvetica, sans-serif"><strong></strong></font></div></td>
          </tr>	
		
		</table>
<%
if (request.getParameter("msg") != null) {
	out.println("<b>" + request.getParameter("msg") + "</b><br><br>");
}


if (request.getParameter("cashout_id") != null) {
// check for daily settlement
// select note from merchant_cashout where cashout_id='541'
String q = "select note from merchant_cashout where cashout_id=?";
PreparedStatement psD = conn.prepareStatement(q);
psD.setString(1, request.getParameter("cashout_id"));
ResultSet rsD = psD.executeQuery();
String dailyNotes = "";
if(rsD.next()) {
	dailyNotes = rsD.getString("note");
}
psD.close();rsD.close();
if(!dailyNotes.equals("Daily Settlement"))dailyNotes = "";
			
%>
<table width="21%" border="0" cellspacing="0" cellpadding="0">
  <form name="form" method="post" action="execute_cashout.jsp" onSubmit="return nameempty(this.doc_number);">
  	<input type='hidden' name='cashout_id' value=<%=request.getParameter("cashout_id")%>>
    <tr bgcolor="#CC6633"> 
      <td colspan="2"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Enter Cashout Doc Number</strong></font></div></td>
    </tr>
    <tr> 
      <td colspan="2"><input type="text" name="doc_number" value="<%=dailyNotes%>"></td>
		</tr>
    <tr> 
      <td colspan="2"><input type="submit" name="Submit" value="Enter"></td>
		</tr>
<%
} else {
%>
		
        <table width="21%" border="0" cellspacing="0" cellpadding="0">
          <form name="form" method="post" action="execute_cashout.jsp">
          	<input type=hidden name=browse value=1>
            <tr bgcolor="#CC6633"> 
              <td colspan="2"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Search 
                  Merchant's Cashout</strong></font></div></td>
            </tr>
            <tr> 
              <td width="30%"><input type="submit" name="Submit" value="View"></td>
              <td>
<select name="merchant_id">
<%
	String merchantID = request.getParameter("merchant_id");
	String q = "select MERCHANT_ID, NAME from MERCHANT a, MERCHANT_INFO b WHERE a.MERCHANT_INFO_ID=b.MERCHANT_INFO_ID and a.STATUS='A' order by NAME";
	Statement st = conn.createStatement();
	ResultSet merchantRs = null;
	merchantRs = st.executeQuery(q);
	while (merchantRs.next()) {
		if (merchantID != null && merchantID.equals(merchantRs.getString("MERCHANT_ID") )) {
			out.println("<option value='" + merchantRs.getString("MERCHANT_ID") + "' selected>" + merchantRs.getString("NAME") + "</option>");
		} else {
			out.println("<option value='" + merchantRs.getString("MERCHANT_ID") + "'>" + merchantRs.getString("NAME") + "</option>");
		}
	}
	merchantRs.close();
	st.close();
%>
</select>            	
              	
              </td>
            </tr>
          </form>
        </table>
		
		<br>
		
        <table width="80%" border="1" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
          <tr bgcolor="#FFF6EF"> 
            <td colspan="11"><div align="right"><font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>.:: 
                Cashout List</strong></font></div></td>
          </tr>
          <tr> 
            <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Cashout ID</strong></font></div></td>
            <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Merchant Name</strong></font></div></td>
            <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Amount</strong></font></div></td>
            <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Doc. Number</strong></font></div></td>
            <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Note</strong></font></div></td>
            <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Cashout Time</strong></font></div></td>
            <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Executed</strong></font></div></td>
          </tr>
		  <%
// paging stuff
String sql = null;
String merchant_id = request.getParameter("merchant_id");
if (merchant_id == null) {
	merchant_id = "";
}
if (request.getParameter("merchant_id") != null && !(request.getParameter("merchant_id").trim()).equals("")) {
	sql = "select count(*) as jumlah from MERCHANT_CASHOUT a, MERCHANT b, MERCHANT_INFO c WHERE a.MERCHANT_ID=b.MERCHANT_ID AND b.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID and a.MERCHANT_ID='"+request.getParameter("merchant_id")+"' and IS_EXECUTED='0' order by DEPOSIT_TIME DESC";
} else {
	sql = "select count(*) as jumlah from MERCHANT_CASHOUT a, MERCHANT b, MERCHANT_INFO c WHERE a.MERCHANT_ID=b.MERCHANT_ID AND b.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID  and IS_EXECUTED='0' order by DEPOSIT_TIME DESC";		 		
}

PreparedStatement pstmt = conn.prepareStatement(sql);
ResultSet rs = pstmt.executeQuery();
int jumlah = 0;
if (rs.next()) {
	jumlah = rs.getInt("jumlah");
}
rs.close();
pstmt.close();
sql = null;
rs = null;
pstmt = null;


int cur_page = 1;
if (request.getParameter("cur_page") != null) {
	cur_page = Integer.parseInt(request.getParameter("cur_page"));
}
int row_per_page = 50;
int start_row = (cur_page-1) * row_per_page + 1;
int end_row = start_row + row_per_page - 1;
int total_page = (jumlah / row_per_page) +1;
if (jumlah % row_per_page == 0) {
	total_page--;
}
out.println("Page : ");
int minPaging = cur_page - 5;
if (minPaging < 1) {
	minPaging = 1;
}
int maxPaging = cur_page + 5;
if (maxPaging > total_page) {
	maxPaging = total_page;
}
if (minPaging - 1 > 0) {
	out.print("<a class='link' href='?cur_page=" + (minPaging - 1) + "&merchant_id="+merchant_id+"'>&lt;</a> ");
}
for (int i=minPaging; i<=maxPaging;i++) {
	if (i == cur_page) {
		out.print(i + " ");
	} else {
		out.print("<a class='link' href='?cur_page=" + i + "&merchant_id="+merchant_id+"'>" + i + "</a> ");
	}
}
if (maxPaging + 1 <= total_page) {
	out.print("<a class='link' href='?cur_page=" + (maxPaging + 1) + "&merchant_id="+merchant_id+"'>&gt;</a> ");
}

// end of paging stuff
 	
		 	sql = null;
		 	if (request.getParameter("merchant_id") != null && !(request.getParameter("merchant_id").trim()).equals("")) {
		 		sql = "select * FROM (select a.*, ROWNUM rnum from (" + 
		 					"select CASHOUT_ID, IS_EXECUTED, DEPOSIT_TIME, NAME, AMOUNT, DOC_NUMBER, NOTE from MERCHANT_CASHOUT a, MERCHANT b, MERCHANT_INFO c WHERE a.MERCHANT_ID=b.MERCHANT_ID AND b.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID and a.MERCHANT_ID='"+request.getParameter("merchant_id")+"' and IS_EXECUTED='0' order by DEPOSIT_TIME DESC" +
		 					" ) a where ROWNUM <= ?) where rnum >= ?";
		 	} else {
				sql = "select * FROM (select a.*, ROWNUM rnum from (" + 
							"select CASHOUT_ID, IS_EXECUTED, DEPOSIT_TIME, NAME, AMOUNT, DOC_NUMBER, NOTE from MERCHANT_CASHOUT a, MERCHANT b, MERCHANT_INFO c WHERE a.MERCHANT_ID=b.MERCHANT_ID AND b.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID  and IS_EXECUTED='0' order by DEPOSIT_TIME DESC" + 
							" ) a where ROWNUM <= ?) where rnum >= ?";
		 	}
			pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1,end_row);
			pstmt.setInt(2,start_row);
			rs = pstmt.executeQuery();
			
			while (rs.next()) {
				%>
				<tr>
					<td bgcolor="#CCCCCC"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("CASHOUT_ID")%></font></div></td>
            		<td bgcolor="#CCCCCC"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("NAME")%></font></div></td>
            		<td bgcolor="#CCCCCC"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("AMOUNT")%></font></div></td>
            		<td bgcolor="#CCCCCC"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("DOC_NUMBER")%></font></div></td>
            		<td bgcolor="#CCCCCC"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("NOTE")%></font></div></td>
            		<td bgcolor="#CCCCCC"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("DEPOSIT_TIME")%></font></div></td>		
				        <td bgcolor="#CCCCCC"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><a href="execute_cashout.jsp?cashout_id=<%= rs.getString("CASHOUT_ID")%>" onClick="return checkExecute();" class="link">execute</a></font></div></td>
				</tr>
				<%
			}
			pstmt.close();
			rs.close();
		  %>
		 </table>
<% } %> 
        <br>
        <br>
        <br>
		
        <table width="40%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td><div align="center"><font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif">Sebelum 
                anda keluar dari layanan ini pastikan anda telah logout agar login 
                anda tidak dapat dipakai oleh orang lain.</font></div></td>
          </tr>
        </table>
		
		 
        <br>
      </td>
    </tr>
    <tr> 
      <td  valign="top" bgcolor="#CC6633"> <div align="right"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"></font></div></td>
		  <td  valign="top" bgcolor="#CC6633"> <div align="right"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>IT 
          VAS Development 2007</strong></font></div></td>
    </tr>
		
  
  </table>
<%	}
  	 catch(Exception  e){
			e.printStackTrace(System.out);
		} finally{
		try { conn.close(); } catch(Exception ee){}
		}
	
%>
  </div>
<%
if (request.getParameter("msg") != null) {
	out.println( "<SCRIPT LANGUAGE=javascript> alert('"+request.getParameter("msg")+"');</SCRIPT>" );
}

%>

<%
	} else {
		response.sendRedirect("admin.html");
	}
%>

		</stripes:layout-component>
</stripes:layout-render>
