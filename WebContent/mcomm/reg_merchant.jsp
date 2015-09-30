<%@ page import="java.sql.*"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<%@page import="com.telkomsel.itvas.webstarter.WebStarterProperties"%>
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
	User user = (User)session.getValue("user");
	
	String stat = request.getParameter("stat");
	String msg = request.getParameter("msg");
	String suc = request.getParameter("suc");
	
	if(stat == null)
		stat = "0";
	if(msg == null)
		msg = "";
	if(suc == null)
		suc = "";
	
	if(!stat.equals("0"))
	{
		if(suc.equals("Merchant registration success"))
			out.println( "<SCRIPT LANGUAGE=javascript> alert('Registrasi merchant berhasil');</SCRIPT>" );
		else
			out.println( "<SCRIPT LANGUAGE=javascript> alert('Registrasi merchant gagal, reason : " + suc + "');</SCRIPT>" );
	}	
	
	Connection conn = null;
	conn = DbCon.getConnection();
	try
	{
		String sql = "select distinct city  from prefix_hlr order by city asc"; 
		PreparedStatement pstmt = conn.prepareStatement(sql);
		ResultSet rs = pstmt.executeQuery();
		
%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Create Merchant">
	<stripes:layout-component name="contents">
		<table width="55%" border="0" cellspacing="0" cellpadding="0">
		<form name="form" method="post" onsubmit="return validasiForm(this)" action="addMerchant2.jsp">
			<tr bgcolor="#CC6633">
				<td colspan="2"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Registration</strong></font></div></td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Name</strong></font></td>
				<td><input type="text" name="name" width="200"></td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Address</strong></font></td>
				<td><textarea name="address" cols="15"></textarea></td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>City</strong></font></td>
				<td> 
						<select name="city">			  	
                			<option value="Other" selected>Other</option>
                			<%
								while(rs.next()){
									out.println("<option value='"+rs.getString("city")+"'>"+rs.getString("city")+"</option>");
								}
							%>
						</select>
				</td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Zip Code</strong></font></td>
				<td><input type="text" name="zipcode" width="200"></td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Phone Number</strong></font></td>
				<td><input type="text" name="phonenum" width="200"></td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>MSISDN</strong></font></td>
				<td><input type="text" name="msisdn" width="200" value="628"></td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Login</strong></font></td>
				<td><input type="text" name="login" width="200"></td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>KTP Number</strong></font></td>
				<td><input type="text" name="ktpno" width="200"></td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>NPWP Number</strong></font></td>
				<td><input type="text" name="npwp" width="200"></td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Bank Name</strong></font></td>
				<td> 
						<select name="bank_name" onchange="changeText(this.value)">			  	
                			<option value="Mandiri" selected>Mandiri</option>
                			<option value="BNI">BNI</option>
							<option value="00">Other</option>
						</select>
				</td>
				<input type="hidden" name="tsel_bank_acc" width="200" value="1240004904539">
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Bank Account Number</strong></font></td>
				<td><input type="text" name="bank_acc_no" width="200"></td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Bank Account Holder</strong></font></td>
				<td><input type="text" name="bank_acc_holder" width="200"></td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Merchant's Type</strong></font></td>
		        	<td> <select name="merchant_type">			  	
                			<option value="deposit">deposit</option>
                			<option value="daily">daily</option>
                			</select>
					</td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td><input type="submit" name="Submit" value="  Add  "></td>
			</tr>
		</form>
		</table>
		<br>
		<br>
		<table width="40%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td>
					<div align="center">
						<font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif">Sebelum anda keluar dari layanan ini pastikan anda telah logout agar login anda tidak dapat dipakai oleh orang lain.</font>
					</div>
				</td>
			</tr>
		</table>
	</stripes:layout-component>
</stripes:layout-render>
<%
	}
	catch(Exception e){
		e.printStackTrace(System.out);
	}
	finally{
		try
		{
			conn.close();
		}
		catch(Exception ee){}
	}
%>
