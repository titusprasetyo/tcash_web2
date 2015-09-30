<%@ page import = "java.util.Locale, java.text.SimpleDateFormat, java.text.NumberFormat, java.sql.*" %>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<%@page import="com.telkomsel.itvas.webstarter.WebStarterProperties"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%
User user = (User)session.getValue("user");
String mid = request.getParameter("mid");
String date = request.getParameter("date");
String type = request.getParameter("type");
String xid = request.getParameter("xid");

String name = null;
String address = null;
String npwp = null;
String bank_name = null;
String bank_acc = null;
String acc_holder = null;
String amount = null;
String doc = null;
String note = null;
String rid = null;

String [] _date = null;
String [] _approver_title = WebStarterProperties.getInstance().getProperty("settlement.approver.title").split("\\|");
String [] _approver_name = WebStarterProperties.getInstance().getProperty("settlement.approver.name").split("\\|");
String [] _month = {"I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII"};

String doc_type = type.equals("deposit") ? "IN" : "OUT";
String s1 = type.equals("deposit") ? "terima dari" : "dibayarkan ke";
String s2 = type.equals("deposit") ? "Pembayaran" : "Terima";
String docTitle = type.equals("deposit") ? "KUITANSI" : "PERINTAH BAYAR";

SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy");
NumberFormat nf =  NumberFormat.getInstance(Locale.ITALY);

String query = null;
Connection conn = null;
Statement stmt = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try
{
	conn = DbCon.getConnection();
	
	if(date == null)
	{
		query = "UPDATE merchant_" + type + " SET print_date = SYSDATE, receipt_id = settlement_doc_sequence.NEXTVAL WHERE " + type + "_id = ?";
		pstmt = conn.prepareStatement(query);
		pstmt.clearParameters();
		pstmt.setString(1, xid);
		pstmt.executeUpdate();
		pstmt.close();
	}
	
	query = "SELECT * from merchant_" + type + " a, merchant b, merchant_info c WHERE a." + type + "_id = ? AND a.merchant_id = b.merchant_id AND b.merchant_info_id = c.merchant_info_id";
	pstmt = conn.prepareStatement(query);
	pstmt.clearParameters();
	pstmt.setString(1, xid);
	rs = pstmt.executeQuery();
	if(rs.next())
	{
		name = rs.getString("name");
		address = rs.getString("address");
		npwp = rs.getString("npwp");
		bank_name = rs.getString("bank_name");
		bank_acc = rs.getString("bank_acc_no");
		acc_holder = rs.getString("bank_acc_holder");
		amount = rs.getString("amount");
		doc = rs.getString("doc_number");
		note = rs.getString("note");
		date = sdf.format(rs.getTimestamp("print_date"));
		rid = rs.getString("receipt_id");
	}
	
	rs.close();
	pstmt.close();
	
	_date = date.split("-");
	
	String [] _amount = amount.split(",");
	if(_amount.length > 1)
		amount = nf.format(Long.parseLong(_amount[0])) + "," + _amount[1];
	else
		amount = nf.format(Long.parseLong(_amount[0]));
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
	catch(Exception e)
	{
	}
}
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<title>T-Cash</title>
	<style type="text/css">
	<!--
	body,td,th
	 {
		font-family: Courier New, Courier, monospace;
		font-size: 12px;
	}
	-->
	</style>
</head>
<body>
	<table width="900" border="0" align="center" cellpadding="2" cellspacing="2">
	<tr>
		<td width="50%"><div align="center"><%=docTitle%><br>NO: <%= rid%>/TSEL/TCASH-<%= doc_type%>/<%= _month[Integer.parseInt(_date[1]) - 1]%>/<%= _date[2]%></div></td>
		<td><div align="right">PT. TELEKOMUNIKASI SELULAR<br>Wisma Mulia<br>Jl. Gatot Subroto KAV 42 Jakarta Selatan 12710<br>NPWP/PKP: 01.718.327.8.091.00</div></td>
	</tr>
	<tr>
		<td>
			<br><br>
			<table width="100%" border="0" cellspacing="2" cellpadding="2">
			<tr>
				<td width="35%">Sudah <%= s1%></td>
				<td width="65%">: <%= name%></td>
			</tr>
			<tr>
				<td>Alamat</td>
				<td>: <%= address%></td>
			</tr>
			<tr>
				<td>NPWP</td>
				<td>: <%= npwp%></td>
			</tr>
			<tr>
				<td>Bank</td>
				<td>: <%= bank_name%></td>
			</tr>
			<tr>
				<td>No Rekening</td>
				<td>: <%= bank_acc%></td>
			</tr>
			<tr>
				<td>Pemegang Rekening</td>
				<td>: <%= acc_holder%></td>
			</tr>
			</table>
			<br><br>Untuk Pembayaran dengan rincian:
		</td>
		<td>&nbsp;</td>
	</tr>
	</table>
	<table width="900" border="1" align="center" cellpadding="1" cellspacing="1">
	<tr>
		<td><div align="center"><strong>No</strong></div></td>
		<td width="75%"><div align="center"><strong>Keterangan</strong></div></td>
		<td width="20%"><div align="center"><strong>Jumlah (Rp)</strong></div></td>
	</tr>
	<tr>
		<td><div align="right">1.</div></td>
		<td>T-Cash <%= type%><br>Doc Number: <%= doc%><br>Note: <%= note%></td>
		<td><div align="right"><%= amount%></div></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td><div align="right">Total Pembayaran</div></td>
		<td><div align="right"><%= amount%></div></td>
	</tr>
	</table>
	<br><br>
	<table width="900" border="0" align="center" cellpadding="2" cellspacing="2">
	<tr>
		<td width="33%">&nbsp;</td>
		<td width="33%">&nbsp;</td>
		<td><div align="center">Jakarta HQ, <%= date%></div></td>
	</tr>
	<tr>
		<td><div align="center">Printed by:</div></td>
		<td>&nbsp;</td>
		<td><div align="center">Approved by:</div></td>
	</tr>
	<tr>
		<td colspan="3"><br><br><br><br></td>
	</tr>
	<tr>
		<td><div align="center"><%= user.getFullName()%></div></td>
		<td><div align="center"><u><%= type.equals("deposit") ? "" : _approver_name[0]%></u></div></td>
		<td><div align="center"><u><%= _approver_name[1]%></u></div></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td><div align="center"><%= type.equals("deposit") ? "" : _approver_title[0]%></div></td>
		<td><div align="center"><%= _approver_title[1]%></div></td>
	</tr>
	</table>
</body>
</html>
