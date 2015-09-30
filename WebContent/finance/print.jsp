<%@ page language = "java" import = "java.io.*, java.util.*, java.text.*, java.sql.*" %>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%
String cashoutid = "", name = "", address = "", description = "", amount = "", docnumber = "", exectime = "", seq = "", npwp = "";
SimpleDateFormat sdf1 = new SimpleDateFormat("yyyy");
SimpleDateFormat sdf2 = new SimpleDateFormat("dd/MM/yyyy");
NumberFormat nf = NumberFormat.getInstance();
User user = (User)request.getSession().getAttribute("user");

String id = request.getParameter("id");
String q = "SELECT * FROM merchant a, merchant_cashout b, merchant_info c WHERE a.merchant_id=b.merchant_id AND a.merchant_info_id=c.merchant_info_id AND b.cashout_id=?";	
Connection conn = null;
try {
	conn = DbCon.getConnection();
	PreparedStatement ps = conn.prepareStatement(q);
	ps.setString(1, id);
	
	ResultSet rs = ps.executeQuery();
	if (rs.next()) {
		name = rs.getString("name");
		cashoutid = rs.getString("cashout_id");
		address = rs.getString("address");
		description = rs.getString("note");
		seq = rs.getString("seq");
		npwp = rs.getString("npwp");
		if (seq == null || seq.equals("")) {
			seq = "UNDEF";			
		}
		docnumber = rs.getString("doc_number");
		amount = nf.format(rs.getLong("amount"));
		exectime = sdf2.format(rs.getTimestamp("exec_time"));
	}
	rs.close();
	ps.close();
} catch (Exception e) {
	e.printStackTrace();
} finally {
	DbUtils.closeQuietly(conn);
}

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@page import="java.util.Date"%>
<%@page import="org.apache.commons.dbutils.DbUtils"%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>T-Cash</title>
<style type="text/css">
<!--
body,td,th {
	font-family: Courier New, Courier, monospace;
	font-size: 12px;
}
-->
</style></head>

<body>
<table width="900" border="0" align="center" cellpadding="2" cellspacing="2">
  <tr>
    <td width="50%"><div align="center">PERINTAH BAYAR<br />
      NO: <%=cashoutid %>/TSEL/TCASH-OUT/<%= seq %>/<%=sdf1.format(new Date())  %>
    </div></td>
    <td><div align="right">PT. TELEKOMUNIKASI SELULAR<br />
      Wisma Mulia<br />
      Jl. Gatot Subroto KAV 42 Jakarta Selatan 12710<br />
      NPWP/PKP: 01.718.327.8.091.00
</div></td>
  </tr>
  <tr>
    <td><br />
    <br />
    <table width="100%%" border="0" cellspacing="2" cellpadding="2">
      <tr>
        <td width="32%">Sudah Dibayarkan ke</td>
        <td width="68%">: <%=name %> </td>
      </tr>
      <tr>
        <td>Alamat</td>
        <td>: <%=address %> </td>
      </tr>
       <tr>
        <td>NPWP</td>
        <td>: <%=npwp %></td>
      </tr>
    </table>
    <br />
    <br />
	Untuk Pembayaran Pembelian dengan rincian:
	</td>
    <td>&nbsp;</td>
  </tr>
</table>
<table width="900" border="1" align="center" cellpadding="1" cellspacing="1">
  <tr>
    <td><div align="center"><strong>No</strong></div></td>
    <td width="75%"><div align="center"><strong>Keterangan</strong></div></td>
    <td width="20%"><div align="center"><strong>Jumlah (Rp) </strong></div></td>
  </tr>
  <tr>
    <td><div align="right">1.</div></td>
    <td>Cash out Tcash  (<%=docnumber %>) </td>
    <td><div align="right"><%=amount %></div></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td><div align="right">Total Pembayaran </div></td>
    <td><div align="right"><%=amount %></div></td>
  </tr>
</table>
<p>&nbsp;</p>
<p>&nbsp;</p>
<table width="900" border="0" align="center" cellpadding="2" cellspacing="2">
  <tr>
    <td width="50%"><p>Printed by:<br />
      <br />
      <br />
      <br />
    </p>    </td>
    <td valign="top"><div align="right">Jakarta HQ, <%=exectime  %><br />
      Approved by:<br />
      <br />
      <br />
      <br />
    </div></td>
  </tr>
  <tr>
    <td><%=user.getFullName() %></td>
    <td valign="top"><div align="right">....................</div></td>
  </tr>
</table>
<p>&nbsp;</p>
</body>
</html>
