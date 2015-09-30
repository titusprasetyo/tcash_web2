<%@ page import="java.sql.*"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<%@page import="com.telkomsel.itvas.webstarter.WebStarterProperties"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<script language="JavaScript">
<!--
function checkDelete()
{
	with(document)
	{
		var checkStatus = confirm('Do you really want to delete this member?');
		if (checkStatus)
		{
			checkStatus = true;
		}
		return checkStatus;
	}
}
//-->
</script>
<%
User user = (User)session.getValue("user");
String msisdn = request.getParameter("msisdn");
String name = request.getParameter("name");

if(msisdn == null)
	msisdn = "";
if(name == null)
	name = "";

Connection conn = null;

try
{
	conn = DbCon.getConnection();
%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Merchant List">
	<stripes:layout-component name="contents">
		<table width="21%" border="0" cellspacing="0" cellpadding="0">
		<form name="form" method="post" action="list_merchant.jsp">
			<tr bgcolor="#CC6633">
				<td colspan="2"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Search</strong></font></div></td>
			</tr>
			<tr>
				<td><font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif">MSISDN</font></td>
				<td><input type="text" name="msisdn" value="<%= msisdn%>"></td>
			</tr>
			<tr>
				<td><font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif">Name</font></td>
				<td><input type="text" name="name" value="<%= name%>"></td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td><input type="submit" name="Submit" value="Search"></td>
			</td>
		</form>
		</table>
		<br>
		<table width="80%" border="1" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
			<tr bgcolor="#FFF6EF">
				<td colspan="15"><div align="right"><font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>.:: List Account Merchant</strong></font></div></td>
			</tr>
			<tr>
				<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Name</strong></font></div></td>
				<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Merchant ID</strong></font></div></td>
				<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Address</strong></font></div></td>
				<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>City</strong></font></div></td>
				<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>MSISDN</strong></font></div></td>
				<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Login</strong></font></div></td>
				<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Bank Name</strong></font></div></td>
				<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Bank Acc Number</strong></font></div></td>
				<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Bank Acc Number</strong></font></div></td>
				<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>TSEL Bank Acc</strong></font></div></td>
				<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Edit</strong></font></div></td>
				<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Delete</strong></font></div></td>
			</tr>
<%
	String sql = "select name, address, city, zipcode, phone_num, m.msisdn, m.merchant_id, login, ktp_no, npwp, bank_name, bank_acc_no, bank_acc_holder, tsel_bank_acc, m.merchant_info_id, m.merchant_id from merchant m, merchant_info mi where m.merchant_info_id = mi.merchant_info_id and m.msisdn like ? and m.status != 'D' and UPPER(name) like ?";
	PreparedStatement pstmt = conn.prepareStatement(sql);
	pstmt.setString(1, "%" + msisdn + "%");
	pstmt.setString(2, "%" + name.toUpperCase() + "%");
	ResultSet rs = pstmt.executeQuery();
	while(rs.next())
	{
%>
			<tr>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("name")%></font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("merchant_id")%></font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("address")%></font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("city")%></font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("msisdn")%></font></div></td>		
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("login")%></font></div></td>		
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("bank_name")%></font></div></td>		
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("bank_acc_no")%></font></div></td>		
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("bank_acc_holder")%></font></div></td>		
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("tsel_bank_acc")%></font></div></td>		
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><a href="edit_merchant.jsp?stat=0&minfoid=<%= rs.getString("merchant_info_id")%>" class="link">edit</a></font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><a href="delete_merchant.jsp?mid=<%= rs.getString("merchant_id")%>" onClick="return checkDelete();" class="link">delete</a></font></div></td>
			</tr>
<%
	}
	pstmt.close();
	rs.close();
%>
		</table>
		<br>
		<br>
		<table width="40%" border="0" cellspacing="0" cellpadding="0">
			<tr> 
				<td><div align="center"><font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif">Sebelum anda keluar dari layanan ini pastikan anda telah logout agar login anda tidak dapat dipakai oleh orang lain.</font></div></td>
			</tr>
		</table>
	</stripes:layout-component>
</stripes:layout-render>
<%
}
catch(Exception e)
{
	e.printStackTrace(System.out);
}
finally
{
	try
	{
		conn.close();
	}
	catch(Exception ee)
	{
	}
}
%>
