<%@ page import="java.sql.*"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<%@page import="com.telkomsel.itvas.webstarter.WebStarterProperties"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<script language="JavaScript">
<!--
function validasiForm(theForm) { // passing the form object
  var valbank_acc_no = theForm.bank_acc_no.value;
  var valbank_acc_holder = theForm.bank_acc_holder.value;
  var status = true;
  if (valbank_acc_no==null || valbank_acc_no.trim()=="") { 
    alert('Tolong lengkapi data No.Rekening Merchant');
    theForm.bank_acc_no.focus();
    status = false; // cancel submission
  }
  else if(valbank_acc_holder==null || valbank_acc_holder.trim()==""){
	alert('Tolong lengkapi data Nama No.Rekening Merchant');
    theForm.bank_acc_holder.focus();
    status = false; // cancel submission
  }
  return status; // allow submit
}

function changeText(value){
  if (value=="Mandiri"){ 
    document.getElementsByName("tsel_bank_acc")[0].value = "1240004904539";
  }
  else if(value=="BNI"){
	document.getElementsByName("tsel_bank_acc")[0].value = "0120883432";
  }
  else{
	document.getElementsByName("tsel_bank_acc")[0].value = "00";
  }
}
//-->
</script>

<%
String minfoid = request.getParameter("minfoid");
User user = (User)session.getValue("user");

if(user != null)
{
	session.putValue("user", user);
	String stat = request.getParameter("stat");
	if(stat.equals("1"))
		out.println( "<SCRIPT LANGUAGE=javascript>alert('Any field cannot be empty');</SCRIPT>" );
	else if(stat.equals("2"))
		out.println( "<SCRIPT LANGUAGE=javascript>alert('Merchant Data Succesfully Edited');</SCRIPT>" );
	else if(stat.equals("3"))
		out.println( "<SCRIPT LANGUAGE=javascript>alert('Login already used');</SCRIPT>" );

	Connection conn = null;
	conn = DbCon.getConnection();
	try
	{
		String sql = "select name, address, city, zipcode, phone_num, m.msisdn, login, ktp_no, npwp, bank_name, bank_acc_no, bank_acc_holder, tsel_bank_acc, m.merchant_info_id from merchant m, merchant_info mi where m.merchant_info_id = mi.merchant_info_id and m.merchant_info_id = ?"; 
		PreparedStatement pstmt = conn.prepareStatement(sql);
		pstmt.setString(1, minfoid);
		ResultSet rs = pstmt.executeQuery();
		if(rs.next())
		{			
%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Merchant List">
	<stripes:layout-component name="contents">
		<table width="55%" border="0" cellspacing="0" cellpadding="0">
		<form name="form" method="post" onsubmit="return validasiForm(this)" action="edit_merchant_eksekusi.jsp">
			<input type="hidden" name="minfoid" value="<%= minfoid%>">
			<tr bgcolor="#CC6633">
				<td colspan="2"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Edit Account</strong></font></div></td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Name</strong></font></td>
				<td><input type="text" name="name" width="200" value="<%= rs.getString("name")%>">
			</td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Address</strong></font></td>
				<td><textarea name="address" cols="15" ><%= rs.getString("address")%></textarea></td>
			</tr>
			<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>City</strong></font></td>
				<td> 
						<select name="city">			  	
                			<option value="Other" selected>Other</option>
                			<%
								String sql2 = "select distinct city  from prefix_hlr order by city asc"; 
								PreparedStatement pstmt2 = conn.prepareStatement(sql2);
								ResultSet rs2 = pstmt2.executeQuery();
								while(rs2.next()){
									if((rs.getString("city").toUpperCase()).equals(rs2.getString("city").toUpperCase())){
										//System.out.println("<option value='"+rs2.getString("city")+"' selected >"+rs2.getString("city")+"</option>");
										out.println("<option value='"+rs2.getString("city")+"' selected >"+rs2.getString("city")+"</option>");
									}
									else{
										//System.out.println("<option value='"+rs2.getString("city")+"'>"+rs2.getString("city")+"</option>");
										out.println("<option value='"+rs2.getString("city")+"'>"+rs2.getString("city")+"</option>");
									}
								}
								pstmt2.close();rs2.close();
							%>
						</select>
				</td>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Zip Code</strong></font></td>
				<td><input type="text" name="zipcode" width="200" value="<%= rs.getString("zipcode")%>"></td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Phone Number</strong></font></td>
				<td><input type="text" name="phonenum" width="200" value="<%= rs.getString("phone_num")%>"></td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>MSISDN</strong></font></td>
				<td><input type="text" name="msisdn" width="200" value="<%= rs.getString("msisdn")%>"></td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Login</strong></font></td>
				<td><input type="text" name="login" width="200" value="<%= rs.getString("login")%>"> </td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>KTP Number</strong></font></td>
				<td><input name="ktpno" type="text" width="200" value="<%= rs.getString("ktp_no")%>"></td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>NPWP</strong></font></td>
				<td><input name="npwp" type="text" width="200" value="<%= rs.getString("npwp")%>"></td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Bank Name</strong></font></td>
				<td> 
						<select name="bank_name" onchange="changeText(this.value)">			  	
                			<option value="Mandiri" <%if((rs.getString("bank_name").toUpperCase()).equals("MANDIRI")) out.print("selected");%>>Mandiri</option>
                			<option value="BNI" <%if((rs.getString("bank_name").toUpperCase()).equals("BNI")) out.print("selected");%>>BNI</option>
							<option value="00" <%if((rs.getString("bank_name").toUpperCase()).equals("00")) out.print("selected");%>>Other</option>
						</select>
				</td>
				<input type="hidden" name="tsel_bank_acc" width="200" value="<%= rs.getString("tsel_bank_acc")%>">
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Bank Account Number</strong></font></td>
				<td><input name="bank_acc_no" type="text" width="200" value="<%= rs.getString("bank_acc_no")%>"></td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Bank Account Holder</strong></font></td>
				<td><input name="bank_acc_holder" type="text" width="200" value="<%= rs.getString("bank_acc_holder")%>"></td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td><input type="submit" name="Submit" value="Edit"></td>
			</tr>
		</form>
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
}
else
{
	response.sendRedirect("admin.html");
}
%>
