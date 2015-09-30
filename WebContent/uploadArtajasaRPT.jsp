<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.sql.*, java.util.*,java.text.*, oracle.jdbc.driver.*" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="org.apache.commons.fileupload.FileUploadException" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon" />

<% 
//yusuf
List fileItemsList = null;
if (ServletFileUpload.isMultipartContent(request)){
	
	//DiskFileItemFactory fileItemFactory = new DiskFileItemFactory ();
	//fileItemFactory.setSizeThreshold(1*1024*1024); //1 MB
	//File tmpDir = new File("D:\\Tests\\upload");
	//fileItemFactory.setRepository(tmpDir);
	
	 ServletFileUpload servletFileUpload = new ServletFileUpload(new DiskFileItemFactory());
	
    //ServletFileUpload servletFileUpload = new ServletFileUpload(new DiskFileItemFactory());
    //ServletFileUpload servletFileUpload = new ServletFileUpload(fileItemFactory);
    
    try {
        fileItemsList = servletFileUpload.parseRequest(request);
    }
    catch (FileUploadException e) {
        out.println("File upload failed. ["+e.getMessage()+"]");
    }
}
%>

<%!

String trimAcctNumber(String input){
	String output = input;
	for(int j=0;j<input.length();j++){
		if(output.startsWith("0")){
			output = input.substring(j+1,input.length());
		}else{
			break;
		}
	}	
	output = "0" + output;
	return output;
}

String getGMTPlus7(String input){
	String output = "";
	String depan = input.substring(0,2);
	String belakang = input.substring(2, input.length());
	
	long depanInt = 0;
	
	try{
		depanInt = Long.parseLong(depan);
	}catch (Exception e){
		depanInt = 92;
	}
	
	depanInt += 7;
	
	if(depanInt<10)
		output = "0" + depanInt + belakang;
	else
		output = depanInt + belakang;
	
	return output;
}

String trimBankCode(String input){
	String output = input;
	for(int j=0;j<input.length();j++){
		if(output.startsWith("0")){
			output = input.substring(j+1,input.length());
		}else{
			break;
		}
	}
	return output;
}

int findRecon(ArrayList <String[]>  report_rpt, String tran_time, String acct_number, String tran_amount, String tran_date, String card_number, String bank_code, String trace_number, String ref_number){
	int result = -1;
	search:
	for(int i=0;i<report_rpt.size();i++){
		// search log in report
			
		//System.out.println("if(tran_time.equalsIgnoreCase(report_rpt.get(i)[0]) && acct_number.equalsIgnoreCase(report_rpt.get(i)[1]) && tran_date.equalsIgnoreCase(report_rpt.get(i)[9]) && card_number.equalsIgnoreCase(report_rpt.get(i)[10]) && bank_code.equalsIgnoreCase(report_rpt.get(i)[11]) && trace_number.equalsIgnoreCase(report_rpt.get(i)[12]) && ref_number.equalsIgnoreCase(report_rpt.get(i)[13]) && Long.parseLong(tran_amount) == Long.parseLong(report_rpt.get(i)[3])){");
		//System.out.println("if"+acct_number+".equalsIgnoreCase("+trimAcctNumber(report_rpt.get(i)[1])+") && "+tran_date+".equalsIgnoreCase("+report_rpt.get(i)[9]+") && "+trimBankCode(bank_code)+".equalsIgnoreCase("+report_rpt.get(i)[11]+") && "+trace_number+".equalsIgnoreCase("+report_rpt.get(i)[12]+") && "+ref_number+".equalsIgnoreCase("+report_rpt.get(i)[13]+") && Long.parseLong("+tran_amount+") == Long.parseLong("+report_rpt.get(i)[3]+")){");

		if(/*tran_time.equalsIgnoreCase(report_rpt.get(i)[0]) &&*/ acct_number.equalsIgnoreCase(trimAcctNumber(report_rpt.get(i)[1])) && tran_date.equalsIgnoreCase(report_rpt.get(i)[9]) && /*card_number.equalsIgnoreCase(report_rpt.get(i)[10]) &&*/ trimBankCode(bank_code).equalsIgnoreCase(report_rpt.get(i)[11]) && trace_number.equalsIgnoreCase(report_rpt.get(i)[12]) && ref_number.equalsIgnoreCase(report_rpt.get(i)[13]) && Long.parseLong(tran_amount) == Long.parseLong(report_rpt.get(i)[3])){
			result = i;
			break search;
		}
	}
	return result;
}


int findReconCashout(ArrayList <String[]>  report_rpt, String tran_time, String acct_number, String tran_amount, String tran_date, String card_number, String bank_code, String trace_number, String ref_number){
	int result = -1;
	search:
	for(int i=0;i<report_rpt.size();i++){
		// search log in report
		if(/*tran_time.equalsIgnoreCase(report_rpt.get(i)[0]) &&*/ acct_number.equalsIgnoreCase(trimAcctNumber(report_rpt.get(i)[6])) && /*tran_date.equalsIgnoreCase(report_rpt.get(i)[9]) &&*/ /*card_number.equalsIgnoreCase(report_rpt.get(i)[10]) &&*/ trimBankCode(bank_code).equalsIgnoreCase(report_rpt.get(i)[12]) && /*trace_number.equalsIgnoreCase(report_rpt.get(i)[13]) &&*/ ref_number.equalsIgnoreCase(report_rpt.get(i)[14]) && Long.parseLong(tran_amount) == Long.parseLong(report_rpt.get(i)[8])){
			result = i;
			break search;
		}
	}
	return result;
}

String get_cashin_summary(String input){
    return (input.substring(73, 86)).trim();
}

String get_decimal(String input){
	String inputs  = (input.contains(".")?input.substring(0, input.length()-1):input);
	//System.out.println("Debug get_decimal : "+input + "Debug get_decimal 2: "+inputs);
	NumberFormat nf =  NumberFormat.getInstance(Locale.ITALY);
	if(inputs.equals("")){
		return "";
	}else{
		long output = 0;
		try{
			output = Long.parseLong(inputs);
		}catch (Exception e){
			output = -99;
		}finally{
			return ""+nf.format(output);
		}
	}
}

String [] get_claim(String input){
    //System.out.println("get_claim awal : "+input);
	String [] output = new String [8];
    // JENIS
	output[0] = (input.substring(5, 14)).trim();
    // NO KARTU
	output[1] = (input.substring(19, 37)).trim();
    // NO RESI
	output[2] = (input.substring(39, 49)).trim();
    // DASAR SETORAN
	output[3] = (input.substring(70, 100)).trim();
    // TGL TRX
	output[4] = (input.substring(107, 117)).trim();
    // JAM TRX
	output[5] = (input.substring(119, 127)).trim();
    // TERM ID
	output[6] = (input.substring(131, 140)).trim();
    // NOMINAL
	output[7] = ((input.substring(149, input.length()-3)).trim()).replaceAll(",","");
    //System.out.println("get_claim akhir : "+output[7]);
	//System.out.println("get_claim akhir +get_decimal : "+get_decimal(output[7]));
	return output;
}

String [] get_cashin_report(String input){
String [] output = new String [14];
    // tran time
                output[0] = (input.substring(2, 6)).trim();
    //System.out.println("output[0]:"+output[0]);
                // acct number
                //output[1] = (input.substring(7, 26)).trim();
    output[1] = (input.substring(8, 26)).trim();
                //System.out.println("output[1]:"+output[1]);
                // tran code
                //output[2] = (input.substring(27, 41)).trim();
    output[2] = (input.substring(31, 40)).trim();
                //System.out.println("output[2]:"+output[2]);
                // trans amount
                //output[3] = ((input.substring(42, 55)).trim()).replaceAll(",","");
                output[3] = ((input.substring(43, 56)).trim()).replaceAll(",","");
                
                //System.out.println("output[3]:"+output[3]);
    // result code
                //output[4] = (input.substring(60, 72)).trim();
    output[4] = (input.substring(60, 71)).trim();
    
                //System.out.println("output[4]:"+output[4]);
                // trml nbr
                //output[5] = (input.substring(73, 79)).trim();
    output[5] = (input.substring(72, 79)).trim();
    
                //System.out.println("output[5]:"+output[5]);
                // aba trml
                //output[6] = (input.substring(80, 87)).trim();
    output[6] = (input.substring(83, 87)).trim();
    
                //System.out.println("output[6]:"+output[6]);
                // swt nbr
                //output[7] = (input.substring(88, 95)).trim();
    output[7] = (input.substring(89, 95)).trim();
    
                //System.out.println("output[7]:"+output[7]);
                // terminal receipt
                //output[8] = (input.substring(96, 104)).trim();
    output[8] = (input.substring(98, 104)).trim();
    
                //System.out.println("output[8]:"+output[8]);
                // tran date
                //output[9] = (input.substring(104, 113)).trim();
                output[9] = (input.substring(105, 113)).trim();
                
                //System.out.println("output[9]:"+output[9]);
                // card nbr
                //output[10] = (input.substring(113, 133)).trim();
    output[10] = (input.substring(128, 133)).trim();
    
                //System.out.println("output[10]:"+output[10]);
                // aba
                //output[11] = (input.substring(134, 146)).trim();
    output[11] = (input.substring(135, 146)).trim();
    
                //System.out.println("output[11]:"+output[11]);
                // trace nbr
                //output[12] = (input.substring(147, 161)).trim();
    output[12] = (input.substring(147, 159)).trim();
    
                //System.out.println("output[12]:"+output[12]);
                // ret ref nbr
                //output[13] = (input.substring(162, input.length())).trim();
    output[13] = (input.substring(162, input.length())).trim();
    
                //System.out.println("output[13]:"+output[13]);
	
	return output;
}

String get_cashout_summary(String input){
    return (input.substring(73, input.length())).trim();
}

String [] get_cashout_report(String input){
    String [] output = new String [15];
    //tran time
	output[0] = (input.substring(0, 5)).trim();
    // terminal receipt
	output[1] = (input.substring(5, 15)).trim();
	// trans aba nbr
	output[2] = (input.substring(15, 32)).trim();
    // card acct number
	output[3] = (input.substring(32, 53)).trim();
	// card mbr
	output[4] = (input.substring(53, 63)).trim();
    // trans br nbrn
	output[5] = (input.substring(63, 78)).trim();
    // account number
	output[6] = (input.substring(78, 95)).trim();
    // tran code
	output[7] = (input.substring(95, 105)).trim();
    // trans amount
	output[8] = ((input.substring(105, 117)).trim()).replaceAll(",","");;
	// result code
    output[9] = (input.substring(122, 134)).trim();
    // trm nbr
	output[10] = (input.substring(136, 158)).trim();
    // dest acct number
	output[11] = (input.substring(160, 178)).trim();
    // aba dest
	output[12] = (input.substring(178, 185)).trim();
    // trace number
	output[13] = (input.substring(185, 200)).trim();
    // ret ref nbr
	output[14] = (input.substring(200, input.length())).trim();
    return output;
}

%>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Daily Artajasa Report - RPT</title>
<script language="JavaScript">
<!--
function checkExecute2(){
	with(document)
		return confirm("Do you really want to recon these Artajasa records?");
}
//-->
</script>
    </head>
	<style>
	.link {
	color : #CC6633;
	text-decoration : none;
	}
	.link1 {
	color : #CC6633;
	text-decoration : underline;
	}
</style>
    <body>
	
<table width="100%" border="1" cellspacing="0" cellpadding="0" bordercolor="#CC6633">
   <tr>
	  <td width="81%" bgcolor="#CC6633">
	  	<div align="right"> <font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong><font color="#FFFFFF" size="2">TCash Web Interface :: Upload Payment Status</font></strong></font><font color="#FFFFFF" face="Verdana, Arial, Helvetica, sans-serif"><strong>
          </strong></font></div>
	  </td>
	  
    </tr>
    <tr valign='top'> 
      <td height="110" align="center" valign="top" background="${pageContext.request.contextPath}/image/Liquisoft2.jpg" bgcolor="#999999">
        <div align="right"><font color="black" face="Verdana, Arial, Helvetica, sans-serif"></font> 
        </div>
        <div align="right"> </div>
        <div align="right"> </div>
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td width="7%" height="28"> <div align="right"> <font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong><img src="${pageContext.request.contextPath}/image/logo.JPG" width="135" height="37"></strong></font>
              </div></td>
          </tr>
        </table>	
        
		<br />
		
<%
// ================================================================
// parameter to update merchant_deposit, and  inserting to claim
String [] csgag_tran_time = request.getParameterValues("csgag_tran_time"),
		csgag_acct_number = request.getParameterValues("csgag_acct_number"),
		csgag_tran_code = request.getParameterValues("csgag_tran_code"),
		csgag_tran_amount = request.getParameterValues("csgag_tran_amount"),
		csgag_result_code = request.getParameterValues("csgag_result_code"),
		csgag_iso_date = request.getParameterValues("csgag_iso_date"),
		csgag_pan_code = request.getParameterValues("csgag_pan_code"),
		csgag_bank_code = request.getParameterValues("csgag_bank_code"),
		csgag_ref_number = request.getParameterValues("csgag_ref_number"),
		csgag_trace_number = request.getParameterValues("csgag_trace_number");

String [] csber_tran_time = request.getParameterValues("csber_tran_time"),
		csber_acct_number = request.getParameterValues("csber_acct_number"),
		csber_tran_code = request.getParameterValues("csber_tran_code"),
		csber_tran_amount = request.getParameterValues("csber_tran_amount"),
		csber_result_code = request.getParameterValues("csber_result_code"),
		csber_iso_date = request.getParameterValues("csber_iso_date"),
		csber_pan_code = request.getParameterValues("csber_pan_code"),
		csber_bank_code = request.getParameterValues("csber_bank_code"),
		csber_ref_number = request.getParameterValues("csber_ref_number"),
		csber_trace_number = request.getParameterValues("csber_trace_number");
		
String [] cssus_tran_time = request.getParameterValues("cssus_tran_time"),
		cssus_acct_number = request.getParameterValues("cssus_acct_number"),
		cssus_tran_code = request.getParameterValues("cssus_tran_code"),
		cssus_tran_amount = request.getParameterValues("cssus_tran_amount"),
		cssus_result_code = request.getParameterValues("cssus_result_code"),
		cssus_iso_date = request.getParameterValues("cssus_iso_date"),
		cssus_pan_code = request.getParameterValues("cssus_pan_code"),
		cssus_bank_code = request.getParameterValues("cssus_bank_code"),
		cssus_ref_number = request.getParameterValues("cssus_ref_number"),
		cssus_trace_number = request.getParameterValues("cssus_trace_number");

String [] r_tran_time = request.getParameterValues("r_tran_time"),
		r_acct_number = request.getParameterValues("r_acct_number"),
		r_tran_code = request.getParameterValues("r_tran_code"),
		r_tran_amount = request.getParameterValues("r_tran_amount"),
		r_result_code = request.getParameterValues("r_result_code"),
		r_iso_date = request.getParameterValues("r_iso_date"),
		r_pan_code = request.getParameterValues("r_pan_code"),
		r_bank_code = request.getParameterValues("r_bank_code"),
		r_ref_number = request.getParameterValues("r_ref_number"),
		r_trace_number = request.getParameterValues("r_trace_number");
		
String [] r_tran_time2 = request.getParameterValues("r_tran_time2"),
		r_acct_number2 = request.getParameterValues("r_acct_number2"),
		r_tran_code2 = request.getParameterValues("r_tran_code2"),
		r_tran_amount2 = request.getParameterValues("r_tran_amount2"),
		r_result_code2 = request.getParameterValues("r_result_code2"),
		r_iso_date2 = request.getParameterValues("r_iso_date2"),
		r_pan_code2 = request.getParameterValues("r_pan_code2"),
		r_bank_code2 = request.getParameterValues("r_bank_code2"),
		r_ref_number2 = request.getParameterValues("r_ref_number2"),
		r_trace_number2 = request.getParameterValues("r_trace_number2");
		
String [] al_tran_time = request.getParameterValues("al_tran_time"),
		al_acct_number = request.getParameterValues("al_acct_number"),
		al_tran_code = request.getParameterValues("al_tran_code"),
		al_tran_amount = request.getParameterValues("al_tran_amount"),
		al_result_code = request.getParameterValues("al_result_code"),
		al_iso_date = request.getParameterValues("al_iso_date"),
		al_pan_code = request.getParameterValues("al_pan_code"),
		al_bank_code = request.getParameterValues("al_bank_code"),
		al_ref_number = request.getParameterValues("al_ref_number"),
		al_trace_number = request.getParameterValues("al_trace_number");
		
String [] db_tran_time = request.getParameterValues("db_tran_time"),
		db_acct_number = request.getParameterValues("db_acct_number"),
		db_tran_code = request.getParameterValues("db_tran_code"),
		db_tran_amount = request.getParameterValues("db_tran_amount"),
		db_result_code = request.getParameterValues("db_result_code"),
		db_iso_date = request.getParameterValues("db_iso_date"),
		db_pan_code = request.getParameterValues("db_pan_code"),
		db_bank_code = request.getParameterValues("db_bank_code"),
		db_ref_number = request.getParameterValues("db_ref_number"),
		db_trace_number = request.getParameterValues("db_trace_number");
		
String [] al_tran_time2 = request.getParameterValues("al_tran_time2"),
		al_acct_number2 = request.getParameterValues("al_acct_number2"),
		al_tran_code2 = request.getParameterValues("al_tran_code2"),
		al_tran_amount2 = request.getParameterValues("al_tran_amount2"),
		al_result_code2 = request.getParameterValues("al_result_code2"),
		al_iso_date2 = request.getParameterValues("al_iso_date2"),
		al_pan_code2 = request.getParameterValues("al_pan_code2"),
		al_bank_code2 = request.getParameterValues("al_bank_code2"),
		al_ref_number2 = request.getParameterValues("al_ref_number2"),
		al_trace_number2 = request.getParameterValues("al_trace_number2");
		
String [] db_tran_time2 = request.getParameterValues("db_tran_time2"),
		db_acct_number2 = request.getParameterValues("db_acct_number2"),
		db_tran_code2 = request.getParameterValues("db_tran_code2"),
		db_tran_amount2 = request.getParameterValues("db_tran_amount2"),
		db_result_code2 = request.getParameterValues("db_result_code2"),
		db_iso_date2 = request.getParameterValues("db_iso_date2"),
		db_pan_code2 = request.getParameterValues("db_pan_code2"),
		db_bank_code2 = request.getParameterValues("db_bank_code2"),
		db_ref_number2 = request.getParameterValues("db_ref_number2"),
		db_trace_number2 = request.getParameterValues("db_trace_number2");

String [] KB_ada_jenis = request.getParameterValues("KB_ada_jenis"),
		KB_ada_kartu = request.getParameterValues("KB_ada_kartu"),
		KB_ada_resi = request.getParameterValues("KB_ada_resi"),
		KB_ada_setoran = request.getParameterValues("KB_ada_setoran"),
		KB_ada_tanggal = request.getParameterValues("KB_ada_tanggal"),
		KB_ada_jam = request.getParameterValues("KB_ada_jam"),
		KB_ada_nominal = request.getParameterValues("KB_ada_nominal"),
		KB_ada_terminal = request.getParameterValues("KB_ada_terminal");
		
String [] KB_tidak_jenis = request.getParameterValues("KB_tidak_jenis"),
		KB_tidak_kartu = request.getParameterValues("KB_tidak_kartu"),
		KB_tidak_resi = request.getParameterValues("KB_tidak_resi"),
		KB_tidak_setoran = request.getParameterValues("KB_tidak_setoran"),
		KB_tidak_tanggal = request.getParameterValues("KB_tidak_tanggal"),
		KB_tidak_jam = request.getParameterValues("KB_tidak_jam"),
		KB_tidak_nominal = request.getParameterValues("KB_tidak_nominal"),
		KB_tidak_terminal = request.getParameterValues("KB_tidak_terminal");		

String reconed = request.getParameter("reconed");
String [] tanggal_laporan = request.getParameterValues("tanggal_laporan");
		
String user = "admin"; 
//=========================================
Calendar CAL = Calendar.getInstance();
SimpleDateFormat SDF = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
String timeNOW=SDF.format(CAL.getTime());
String outPUT = "";
//=========================================

Calendar cal = Calendar.getInstance();
SimpleDateFormat sdf = new SimpleDateFormat("ddMMyyyyHHmmss");
String timeNow=sdf.format(cal.getTime());

SimpleDateFormat SDF2 = new SimpleDateFormat("dd MMMM yyyy");
SimpleDateFormat sdf2 = new SimpleDateFormat("MM/dd/yy");
SimpleDateFormat df=new SimpleDateFormat("EEEE");

NumberFormat nf =  NumberFormat.getInstance(Locale.ITALY);


//upload  csv file into file server
String pathFile = "";
String encLogP = ""; String encPassP=""; String encPass=""; String encLog="";

BufferedReader fileIn = null;
boolean b0 = false;

// database parameter
String query = "";
Connection con = null;
Statement stmt = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try{
	Class.forName("oracle.jdbc.OracleDriver");
	con = DbCon.getConnection();
	con.setAutoCommit(false);
	
	
	// cek untuk yang buka pertama kali dan bukan form multipart
	if(!ServletFileUpload.isMultipartContent(request)){
		encLogP = request.getParameter("idLog1");
		encPassP = request.getParameter("idLog2");
		if(encLogP==null)encLogP="";if(encPassP==null)encPassP="";
		query = "select * from tsel_webstarter_user where username='"+encLogP+"' and password='"+encPassP+"'";
		stmt = con.createStatement();
		rs = stmt.executeQuery(query);
		if(!rs.next()){
			response.sendRedirect("https://10.2.114.121:9082/tcash-web/web-starter/Login.jsp");
		}
		rs.close();stmt.close();
		
		boolean bb = false;
		
		/*
		Yang dimasukkan dalam recon cashout detail adalah:
		1. Suspect Gagal : cashout_suspect_gagal
		2. Suspect Berhasil : cashout_suspect_berhasil
		3. Suspect Suspect : cashout_suspect_suspect
		*/	
		
		
		String AJ_merchantid = "";
		// checking for AJ_merchantid
		query = "select value from configuration where config like 'ajasa.merchantid'";
		stmt = con.createStatement();
		rs = stmt.executeQuery(query);
		if(rs.next()){
			AJ_merchantid = rs.getString("value");
		}else{
			AJ_merchantid = "1111232020565352";
		}
		rs.close();stmt.close();
		
		
		// insert of recon cashout_suspect_gagal ===================================
		if(csgag_tran_time!=null && csgag_acct_number!=null&& csgag_tran_code!=null&& csgag_tran_amount!=null&& csgag_result_code!=null&& csgag_iso_date!=null&& csgag_pan_code!=null&& csgag_bank_code!=null&& csgag_trace_number!=null ){
			
			String id_recon = ""; String id_recon_detail = "";
			
			// ambil id dari nextval from recon seq
			query = "select SEQ_RECON.NEXTVAL from dual";
			pstmt = con.prepareStatement(query);
			rs = pstmt.executeQuery();
			if(rs.next()){
				id_recon = rs.getString("nextval");
			}
			pstmt.close();rs.close();
			
			// calculate total_amount
			long total_amount = 0;
			for(int i=0;i<csgag_tran_amount.length;i++){
				total_amount += Long.parseLong(csgag_tran_amount[i]);
			}
			System.out.println("total_amount : "+total_amount);
			
			// insert into klaim-recon
			query = "insert into recon values('"+id_recon+"',sysdate, '"+AJ_merchantid+"', 'cashout_suspect_gagal', "+csgag_tran_time.length+", 0, "+total_amount+", 0, 0, sysdate, '','')";
			System.out.println(query);
			pstmt = con.prepareStatement(query);
			pstmt.executeUpdate();
			pstmt.close();	
						
			for(int i=0;i<csgag_tran_time.length;i++){
				// ambil id dari nextval from recon_detail seq
				query = "select SEQ_RECON_DETAIL.NEXTVAL from dual";
				pstmt = con.prepareStatement(query);
				rs = pstmt.executeQuery();
				if(rs.next()){
					id_recon_detail = rs.getString("nextval");
				} 
				pstmt.close();rs.close();
							
				// insert into klaim-recon_detail
				query = "insert into recon_detail values('"+id_recon_detail+"', '"+csgag_tran_time[i]+"', '"+csgag_acct_number[i]+"', '"+csgag_tran_code[i]+"', "+csgag_tran_amount[i]+", '"+csgag_result_code[i]+"', to_date('"+csgag_iso_date[i]+"','mm/dd/yy'), '"+csgag_pan_code[i]+"', '"+csgag_bank_code[i]+"', '"+csgag_trace_number[i]+"', '"+csgag_ref_number[i]+"', '0',sysdate, '', '','"+id_recon+"','')";
				System.out.println(query);
				pstmt = con.prepareStatement(query);
				pstmt.executeUpdate();
				pstmt.close();	
			}
			
			// insert into activity_log
			query = "INSERT INTO ACTIVITY_LOG (USERLOGIN, ACCESS_TIME, ACTIVITY, NOTE, IP, REASON) values ('"+user+"', sysdate, 'Recon cashout_suspect_gagal inserted', '"+AJ_merchantid+"|"+csgag_tran_time.length+"|', '"+request.getRemoteAddr()+"', '-')";
			pstmt = con.prepareStatement(query);
			pstmt.executeUpdate();
			pstmt.close();
			
			outPUT+=("Recon Cashout Suspect Gagal Inserted|"+csgag_tran_time.length+"|");
			bb = true;
		}
		
		// insert of recon cashout_suspect_berhasil ===================================
		if(csber_tran_time!=null && csber_acct_number!=null&& csber_tran_code!=null&& csber_tran_amount!=null&& csber_result_code!=null&& csber_iso_date!=null&& csber_pan_code!=null&& csber_bank_code!=null&& csber_trace_number!=null ){
			
			String id_recon = ""; String id_recon_detail = "";
			
			// ambil id dari nextval from recon seq
			query = "select SEQ_RECON.NEXTVAL from dual";
			pstmt = con.prepareStatement(query);
			rs = pstmt.executeQuery();
			if(rs.next()){
				id_recon = rs.getString("nextval");
			}
			pstmt.close();rs.close();
			
			// calculate total_amount
			long total_amount = 0;
			for(int i=0;i<csber_tran_amount.length;i++){
				total_amount += Long.parseLong(csber_tran_amount[i]);
			}
			System.out.println("total_amount : "+total_amount);
			
			// insert into klaim-recon
			query = "insert into recon values('"+id_recon+"', sysdate, '"+AJ_merchantid+"', 'cashout_suspect_berhasil', "+csber_tran_time.length+", 0, "+total_amount+", 0, 0, sysdate, '','')";
			System.out.println(query);
			pstmt = con.prepareStatement(query);
			pstmt.executeUpdate();
			pstmt.close();	
						
			for(int i=0;i<csber_tran_time.length;i++){
				// ambil id dari nextval from recon_detail seq
				query = "select SEQ_RECON_DETAIL.NEXTVAL from dual";
				pstmt = con.prepareStatement(query);
				rs = pstmt.executeQuery();
				if(rs.next()){
					id_recon_detail = rs.getString("nextval");
				}
				pstmt.close();rs.close();
							
				// insert into klaim-recon_detail
				query = "insert into recon_detail values('"+id_recon_detail+"', '"+csber_tran_time[i]+"', '"+csber_acct_number[i]+"', '"+csber_tran_code[i]+"', "+csber_tran_amount[i]+", '"+csber_result_code[i]+"', to_date('"+csber_iso_date[i]+"','mm/dd/yy'), '"+csber_pan_code[i]+"', '"+csber_bank_code[i]+"', '"+csber_trace_number[i]+"', '"+csber_ref_number[i]+"', '0',sysdate, '', '','"+id_recon+"','')";
				System.out.println(query);
				pstmt = con.prepareStatement(query);
				pstmt.executeUpdate();
				pstmt.close();	
			}
			
			// insert into activity_log
			query = "INSERT INTO ACTIVITY_LOG (USERLOGIN, ACCESS_TIME, ACTIVITY, NOTE, IP, REASON) values ('"+user+"', sysdate, 'Recon cashout_suspect_berhasil inserted', '"+AJ_merchantid+"|"+csber_tran_time.length+"|', '"+request.getRemoteAddr()+"', '-')";
			pstmt = con.prepareStatement(query);
			pstmt.executeUpdate();
			pstmt.close();
			
			outPUT+=("Recon Cashout Suspect Berhasil Inserted|"+csber_tran_time.length+"|");
			bb = true;
		}
		
		// insert of recon cashout_suspect_suspect ===================================
		if(cssus_tran_time!=null && cssus_acct_number!=null&& cssus_tran_code!=null&& cssus_tran_amount!=null&& cssus_result_code!=null&& cssus_iso_date!=null&& cssus_pan_code!=null&& cssus_bank_code!=null&& cssus_trace_number!=null ){
			
			String id_recon = ""; String id_recon_detail = "";
			
			// ambil id dari nextval from recon seq
			query = "select SEQ_RECON.NEXTVAL from dual";
			pstmt = con.prepareStatement(query);
			rs = pstmt.executeQuery();
			if(rs.next()){
				id_recon = rs.getString("nextval");
			}
			pstmt.close();rs.close();
			
			// calculate total_amount
			long total_amount = 0;
			for(int i=0;i<cssus_tran_amount.length;i++){
				total_amount += Long.parseLong(cssus_tran_amount[i]);
			}
			System.out.println("total_amount : "+total_amount);
			
			// insert into klaim-recon
			query = "insert into recon values('"+id_recon+"', sysdate, '"+AJ_merchantid+"', 'cashout_suspect_suspect', "+cssus_tran_time.length+", 0, "+total_amount+", 0, 0, sysdate, '','')";
			System.out.println(query);
			pstmt = con.prepareStatement(query);
			pstmt.executeUpdate();
			pstmt.close();	
						
			for(int i=0;i<cssus_tran_time.length;i++){
				// ambil id dari nextval from recon_detail seq
				query = "select SEQ_RECON_DETAIL.NEXTVAL from dual";
				pstmt = con.prepareStatement(query);
				rs = pstmt.executeQuery();
				if(rs.next()){
					id_recon_detail = rs.getString("nextval");
				}
				pstmt.close();rs.close();
							
				// insert into klaim-recon_detail
				query = "insert into recon_detail values('"+id_recon_detail+"', '"+cssus_tran_time[i]+"', '"+cssus_acct_number[i]+"', '"+cssus_tran_code[i]+"', "+cssus_tran_amount[i]+", '"+cssus_result_code[i]+"', to_date('"+cssus_iso_date[i]+"','mm/dd/yy'), '"+cssus_pan_code[i]+"', '"+cssus_bank_code[i]+"', '"+cssus_trace_number[i]+"', '"+cssus_ref_number[i]+"', '0',sysdate, '', '','"+id_recon+"','')";
				System.out.println(query);
				pstmt = con.prepareStatement(query);
				pstmt.executeUpdate();
				pstmt.close();	
			}
			
			// insert into activity_log
			query = "INSERT INTO ACTIVITY_LOG (USERLOGIN, ACCESS_TIME, ACTIVITY, NOTE, IP, REASON) values ('"+user+"', sysdate, 'Recon cashout_suspect_suspect inserted', '"+AJ_merchantid+"|"+cssus_tran_time.length+"|', '"+request.getRemoteAddr()+"', '-')";
			pstmt = con.prepareStatement(query);
			pstmt.executeUpdate();
			pstmt.close();
			
			outPUT+=("Recon Cashout Suspect Suspect Inserted|"+cssus_tran_time.length+"|");
			bb = true;
		}
		
		
		
		/*
		Yang dimasukkan dalam recon detail adalah:
		1. Klaim Suspect : al_cashin_suspect_recon
		2. Klaim Berhasil_ada : al_claim_berhasil_ada
		
		3. Klaim Berhasil_tidakada : al_claim_berhasil_tidakada
		4. Data Recon Kelebihan di RPT : index_rec_al_array 
		5. Data Recon Kelebihan di TCash DB : index_rec_db_array
		
		6. al_cashin_suspect_recon
		7. index_rec_al_array
		8. index_rec_db_array
		*/
		
		
		
		// insert of recon cashin_suspect ===================================
		if(r_tran_time!=null && r_acct_number!=null&& r_tran_code!=null&& r_tran_amount!=null&& r_result_code!=null&& r_iso_date!=null&& r_pan_code!=null&& r_bank_code!=null&& r_trace_number!=null ){
			
			String id_recon = ""; String id_recon_detail = "";
			
			// ambil id dari nextval from recon seq
			query = "select SEQ_RECON.NEXTVAL from dual";
			pstmt = con.prepareStatement(query);
			rs = pstmt.executeQuery();
			if(rs.next()){
				id_recon = rs.getString("nextval");
			}
			pstmt.close();rs.close();
			
			// calculate total_amount
			long total_amount = 0;
			for(int i=0;i<r_tran_amount.length;i++){
				total_amount += Long.parseLong(r_tran_amount[i]);
			}
			System.out.println("total_amount : "+total_amount);
			
			// insert into klaim-recon
			query = "insert into recon values('"+id_recon+"', sysdate, '"+AJ_merchantid+"', 'cashin_suspect', "+r_tran_time.length+", 0, "+total_amount+", 0, 0, sysdate, '','')";
			System.out.println(query);
			pstmt = con.prepareStatement(query);
			pstmt.executeUpdate();
			pstmt.close();	
						
			for(int i=0;i<r_tran_time.length;i++){
				// ambil id dari nextval from recon_detail seq
				query = "select SEQ_RECON_DETAIL.NEXTVAL from dual";
				pstmt = con.prepareStatement(query);
				rs = pstmt.executeQuery();
				if(rs.next()){
					id_recon_detail = rs.getString("nextval");
				}
				pstmt.close();rs.close();
							
				// insert into klaim-recon_detail
				query = "insert into recon_detail values('"+id_recon_detail+"', '"+r_tran_time[i]+"', '"+r_acct_number[i]+"', '"+r_tran_code[i]+"', "+r_tran_amount[i]+", '"+r_result_code[i]+"', to_date('"+r_iso_date[i]+"','mm/dd/yy'), '"+r_pan_code[i]+"', '"+r_bank_code[i]+"', '"+r_trace_number[i]+"', '"+r_ref_number[i]+"', '0',sysdate, '', '','"+id_recon+"','')";
				System.out.println(query);
				pstmt = con.prepareStatement(query);
				pstmt.executeUpdate();
				pstmt.close();	
			}
			
			// insert into activity_log
			query = "INSERT INTO ACTIVITY_LOG (USERLOGIN, ACCESS_TIME, ACTIVITY, NOTE, IP, REASON) values ('"+user+"', sysdate, 'Recon cashin_suspect inserted', '"+AJ_merchantid+"|"+r_tran_time.length+"|', '"+request.getRemoteAddr()+"', '-')";
			pstmt = con.prepareStatement(query);
			pstmt.executeUpdate();
			pstmt.close();
			
			outPUT+=("Recon Cashin Suspect Inserted|"+r_tran_time.length+"|");
			bb = true;
		}
		
		// insert of recon cashin_rpt ===================================
		if(al_tran_time!=null && al_acct_number!=null&& al_tran_code!=null&& al_tran_amount!=null&& al_result_code!=null&& al_iso_date!=null&& al_pan_code!=null&& al_bank_code!=null&& al_trace_number!=null ){
			
			String id_recon = ""; String id_recon_detail = "";
			
			// ambil id dari nextval from recon seq
			query = "select SEQ_RECON.NEXTVAL from dual";
			pstmt = con.prepareStatement(query);
			rs = pstmt.executeQuery();
			if(rs.next()){
				id_recon = rs.getString("nextval");
			}
			pstmt.close();rs.close();
			
			// calculate total_amount
			long total_amount = 0;
			for(int i=0;i<al_tran_amount.length;i++){
				//total_amount += Long.parseLong(al_tran_amount[i]);
				String tmp = al_tran_amount[i];// yusuf
				System.out.println(tmp);
				total_amount += Long.parseLong(tmp.endsWith(".") ? tmp.substring(0, tmp.length() - 1) : tmp);
			}
			System.out.println("total_amount : "+total_amount);
			
			// insert into klaim-recon
			query = "insert into recon values('"+id_recon+"', sysdate, '"+AJ_merchantid+"', 'cashin_rpt', "+al_tran_time.length+", 0, "+total_amount+", 0, 0, sysdate, '','')";
			System.out.println(query);
			pstmt = con.prepareStatement(query);
			pstmt.executeUpdate();
			pstmt.close();	
						
			for(int i=0;i<al_tran_time.length;i++){
				// ambil id dari nextval from recon_detail seq
				query = "select SEQ_RECON_DETAIL.NEXTVAL from dual";
				pstmt = con.prepareStatement(query);
				rs = pstmt.executeQuery();
				if(rs.next()){
					id_recon_detail = rs.getString("nextval");
				}
				pstmt.close();rs.close();
							
				// insert into klaim-recon_detail
				query = "insert into recon_detail values('"+id_recon_detail+"', '"+al_tran_time[i]+"', '"+al_acct_number[i]+"', '"+al_tran_code[i]+"', "+al_tran_amount[i]+", '"+al_result_code[i]+"', to_date('"+al_iso_date[i]+"','mm/dd/yy'), '"+al_pan_code[i]+"', '"+al_bank_code[i]+"', '"+al_trace_number[i]+"', '"+al_ref_number[i]+"', '0',sysdate, '', '','"+id_recon+"','')";
				System.out.println(query);
				pstmt = con.prepareStatement(query);
				pstmt.executeUpdate();
				pstmt.close();	
			}
			
			// insert into activity_log
			query = "INSERT INTO ACTIVITY_LOG (USERLOGIN, ACCESS_TIME, ACTIVITY, NOTE, IP, REASON) values ('"+user+"', sysdate, 'Recon cashin_rpt inserted', '"+AJ_merchantid+"|"+al_tran_time.length+"|', '"+request.getRemoteAddr()+"', '-')";
			pstmt = con.prepareStatement(query);
			pstmt.executeUpdate();
			pstmt.close();
			
			outPUT+=("Recon Cashin RPT Inserted|"+al_tran_time.length+"|");
			bb = true;
		}
		
		
		// insert of recon cashin_db ===================================
		if(db_tran_time!=null && db_acct_number!=null&& db_tran_code!=null&& db_tran_amount!=null&& db_result_code!=null&& db_iso_date!=null&& db_pan_code!=null&& db_bank_code!=null&& db_trace_number!=null ){
			
			String id_recon = ""; String id_recon_detail = "";
			
			// ambil id dari nextval from recon seq
			query = "select SEQ_RECON.NEXTVAL from dual";
			pstmt = con.prepareStatement(query);
			rs = pstmt.executeQuery();
			if(rs.next()){
				id_recon = rs.getString("nextval");
			}
			pstmt.close();rs.close();
			
			// calculate total_amount
			long total_amount = 0;
			for(int i=0;i<db_tran_amount.length;i++){
				total_amount += Long.parseLong(db_tran_amount[i]);
			}
			System.out.println("total_amount : "+total_amount);
			
			// insert into klaim-recon
			query = "insert into recon values('"+id_recon+"', sysdate, '"+AJ_merchantid+"', 'cashin_db', "+db_tran_time.length+", 0, "+total_amount+", 0, 0, sysdate, '','')";
			System.out.println(query);
			pstmt = con.prepareStatement(query);
			pstmt.executeUpdate();
			pstmt.close();	
						
			for(int i=0;i<db_tran_time.length;i++){
				// ambil id dari nextval from recon_detail seq
				query = "select SEQ_RECON_DETAIL.NEXTVAL from dual";
				pstmt = con.prepareStatement(query);
				rs = pstmt.executeQuery();
				if(rs.next()){
					id_recon_detail = rs.getString("nextval");
				}
				pstmt.close();rs.close();
							
				// insert into klaim-recon_detail
				query = "insert into recon_detail values('"+id_recon_detail+"', '"+db_tran_time[i]+"', '"+db_acct_number[i]+"', '"+db_tran_code[i]+"', "+db_tran_amount[i]+", '"+db_result_code[i]+"', to_date('"+db_iso_date[i]+"','mm/dd/yy'), '"+db_pan_code[i]+"', '"+db_bank_code[i]+"', '"+db_trace_number[i]+"', '"+db_ref_number[i]+"', '0',sysdate, '', '','"+id_recon+"','')";
				System.out.println(query);
				pstmt = con.prepareStatement(query);
				pstmt.executeUpdate();
				pstmt.close();	
			}
			
			// insert into activity_log
			query = "INSERT INTO ACTIVITY_LOG (USERLOGIN, ACCESS_TIME, ACTIVITY, NOTE, IP, REASON) values ('"+user+"', sysdate, 'Recon cashin_db inserted', '"+AJ_merchantid+"|"+db_tran_time.length+"|', '"+request.getRemoteAddr()+"', '-')";
			pstmt = con.prepareStatement(query);
			pstmt.executeUpdate();
			pstmt.close();
			
			outPUT+=("Recon Cashin DB Inserted|"+db_tran_time.length+"|");
			bb = true;
		}		
		
		// ==============================================================================================================
		/*
		// insert of recon cashout_suspect ===================================
		if(r_tran_time2!=null && r_acct_number2!=null&& r_tran_code2!=null&& r_tran_amount2!=null&& r_result_code2!=null&& r_iso_date2!=null&& r_pan_code2!=null&& r_bank_code2!=null&& r_trace_number2!=null ){
			
			String id_recon = ""; String id_recon_detail = "";
			
			// ambil id dari nextval from recon seq
			query = "select SEQ_RECON.NEXTVAL from dual";
			pstmt = con.prepareStatement(query);
			rs = pstmt.executeQuery();
			if(rs.next()){
				id_recon = rs.getString("nextval");
			}
			pstmt.close();rs.close();
			
			// calculate total_amount
			long total_amount = 0;
			for(int i=0;i<r_tran_amount2.length;i++){
				total_amount += Long.parseLong(r_tran_amount2[i]);
			}
			System.out.println("total_amount : "+total_amount);
			
			// insert into klaim-recon
			query = "insert into recon values('"+id_recon+"', sysdate, '"+AJ_merchantid+"', 'cashout_suspect', "+r_tran_time2.length+", 0, "+total_amount+", 0, 0, sysdate, '','')";
			System.out.println(query);
			pstmt = con.prepareStatement(query);
			pstmt.executeUpdate();
			pstmt.close();	
						
			for(int i=0;i<r_tran_time2.length;i++){
				// ambil id dari nextval from recon_detail seq
				query = "select SEQ_RECON_DETAIL.NEXTVAL from dual";
				pstmt = con.prepareStatement(query);
				rs = pstmt.executeQuery();
				if(rs.next()){
					id_recon_detail = rs.getString("nextval");
				}
				pstmt.close();rs.close();
							
				// insert into klaim-recon_detail
				query = "insert into recon_detail values('"+id_recon_detail+"', '"+r_tran_time2[i]+"', '"+r_acct_number2[i]+"', '"+r_tran_code2[i]+"', "+r_tran_amount2[i]+", '"+r_result_code2[i]+"', to_date('"+r_iso_date2[i]+"','mm/dd/yy'), '"+r_pan_code2[i]+"', '"+r_bank_code2[i]+"', '"+r_trace_number2[i]+"', '"+r_ref_number2[i]+"', '0',sysdate, '', '','"+id_recon+"','')";
				System.out.println(query);
				pstmt = con.prepareStatement(query);
				pstmt.executeUpdate();
				pstmt.close();	
			}
			
			// insert into activity_log
			query = "INSERT INTO ACTIVITY_LOG (USERLOGIN, ACCESS_TIME, ACTIVITY, NOTE, IP, REASON) values ('"+user+"', sysdate, 'Recon cashout_suspect inserted', '"+AJ_merchantid+"|"+r_tran_time2.length+"|', '"+request.getRemoteAddr()+"', '-')";
			pstmt = con.prepareStatement(query);
			pstmt.executeUpdate();
			pstmt.close();
			
			outPUT+=("Recon Cashout Suspect Inserted|"+r_tran_time2.length+"|");
			bb = true;
		}
		*/
		
		// insert of recon cashout_rpt ===================================
		if(al_tran_time2!=null && al_acct_number2!=null&& al_tran_code2!=null&& al_tran_amount2!=null&& al_result_code2!=null&& al_iso_date2!=null&& al_pan_code2!=null&& al_bank_code2!=null&& al_trace_number2!=null ){
			
			String id_recon = ""; String id_recon_detail = "";
			
			// ambil id dari nextval from recon seq
			query = "select SEQ_RECON.NEXTVAL from dual";
			pstmt = con.prepareStatement(query);
			rs = pstmt.executeQuery();
			if(rs.next()){
				id_recon = rs.getString("nextval");
			}
			pstmt.close();rs.close();
			
			// calculate total_amount
			long total_amount = 0;
			for(int i=0;i<al_tran_amount2.length;i++){
				total_amount += Long.parseLong(al_tran_amount2[i]);
			}
			System.out.println("total_amount : "+total_amount);
			
			// insert into klaim-recon
			query = "insert into recon values('"+id_recon+"', sysdate, '"+AJ_merchantid+"', 'cashout_rpt', "+al_tran_time2.length+", 0, "+total_amount+", 0, 0, sysdate, '','')";
			System.out.println(query);
			pstmt = con.prepareStatement(query);
			pstmt.executeUpdate();
			pstmt.close();	
						
			for(int i=0;i<al_tran_time2.length;i++){
				// ambil id dari nextval from recon_detail seq
				query = "select SEQ_RECON_DETAIL.NEXTVAL from dual";
				pstmt = con.prepareStatement(query);
				rs = pstmt.executeQuery();
				if(rs.next()){
					id_recon_detail = rs.getString("nextval");
				}
				pstmt.close();rs.close();
							
				// insert into klaim-recon_detail
				query = "insert into recon_detail values('"+id_recon_detail+"', '"+al_tran_time2[i]+"', '"+al_acct_number2[i]+"', '"+al_tran_code2[i]+"', "+al_tran_amount2[i]+", '"+al_result_code2[i]+"', to_date('"+al_iso_date2[i]+"','mm/dd/yy'), '"+al_pan_code2[i]+"', '"+al_bank_code2[i]+"', '"+al_trace_number2[i]+"', '"+al_ref_number2[i]+"', '0',sysdate, '', '','"+id_recon+"','')";
				System.out.println(query);
				pstmt = con.prepareStatement(query);
				pstmt.executeUpdate();
				pstmt.close();	
			}
			
			// insert into activity_log
			query = "INSERT INTO ACTIVITY_LOG (USERLOGIN, ACCESS_TIME, ACTIVITY, NOTE, IP, REASON) values ('"+user+"', sysdate, 'Recon cashout_rpt inserted', '"+AJ_merchantid+"|"+al_tran_time2.length+"|', '"+request.getRemoteAddr()+"', '-')";
			pstmt = con.prepareStatement(query);
			pstmt.executeUpdate();
			pstmt.close();
			
			outPUT+=("Recon Cashout RPT Inserted|"+al_tran_time2.length+"|");
			bb = true;
		}
		
		
		// insert of recon cashout_db ===================================
		if(db_tran_time2!=null && db_acct_number2!=null&& db_tran_code2!=null&& db_tran_amount2!=null&& db_result_code2!=null&& db_iso_date2!=null&& db_pan_code2!=null&& db_bank_code2!=null&& db_trace_number2!=null ){
			
			String id_recon = ""; String id_recon_detail = "";
			
			// ambil id dari nextval from recon seq
			query = "select SEQ_RECON.NEXTVAL from dual";
			pstmt = con.prepareStatement(query);
			rs = pstmt.executeQuery();
			if(rs.next()){
				id_recon = rs.getString("nextval");
			}
			pstmt.close();rs.close();
			
			// calculate total_amount
			long total_amount = 0;
			for(int i=0;i<db_tran_amount2.length;i++){
				total_amount += Long.parseLong(db_tran_amount2[i]);
			}
			System.out.println("total_amount : "+total_amount);
			
			// insert into klaim-recon
			query = "insert into recon values('"+id_recon+"', sysdate, '"+AJ_merchantid+"', 'cashout_db', "+db_tran_time2.length+", 0, "+total_amount+", 0, 0, sysdate, '','')";
			System.out.println(query);
			pstmt = con.prepareStatement(query);
			pstmt.executeUpdate();
			pstmt.close();	
						
			for(int i=0;i<db_tran_time2.length;i++){
				// ambil id dari nextval from recon_detail seq
				query = "select SEQ_RECON_DETAIL.NEXTVAL from dual";
				pstmt = con.prepareStatement(query);
				rs = pstmt.executeQuery();
				if(rs.next()){
					id_recon_detail = rs.getString("nextval");
				}
				pstmt.close();rs.close();
							
				// insert into klaim-recon_detail
				query = "insert into recon_detail values('"+id_recon_detail+"', '"+db_tran_time2[i]+"', '"+db_acct_number2[i]+"', '"+db_tran_code2[i]+"', "+db_tran_amount2[i]+", '"+db_result_code2[i]+"', to_date('"+db_iso_date2[i]+"','mm/dd/yy'), '"+db_pan_code2[i]+"', '"+db_bank_code2[i]+"', '"+db_trace_number2[i]+"', '"+db_ref_number2[i]+"', '0',sysdate, '', '','"+id_recon+"','')";
				System.out.println(query);
				pstmt = con.prepareStatement(query);
				pstmt.executeUpdate();
				pstmt.close();	
			}
			
			// insert into activity_log
			query = "INSERT INTO ACTIVITY_LOG (USERLOGIN, ACCESS_TIME, ACTIVITY, NOTE, IP, REASON) values ('"+user+"', sysdate, 'Recon cashout_db inserted', '"+AJ_merchantid+"|"+db_tran_time2.length+"|', '"+request.getRemoteAddr()+"', '-')";
			pstmt = con.prepareStatement(query);
			pstmt.executeUpdate();
			pstmt.close();
			
			outPUT+=("Recon Cashout DB Inserted|"+db_tran_time2.length+"|");
			bb = true;
		}
		
		
		// ==============================================================================================================
				
		// insert of recon cashin_claim_ada ===================================
		if(KB_ada_nominal!=null && KB_ada_jenis!=null && KB_ada_kartu!=null&& KB_ada_resi!=null&& KB_ada_setoran!=null&& KB_ada_tanggal!=null&& KB_ada_jam!=null&& KB_ada_terminal!=null){
			System.out.println("Masuk claim ada");
			String id_recon = ""; String id_recon_detail = "";
			
			// ambil id dari nextval from recon seq
			query = "select SEQ_RECON.NEXTVAL from dual";
			pstmt = con.prepareStatement(query);
			rs = pstmt.executeQuery();
			if(rs.next()){
				id_recon = rs.getString("nextval");
			}
			pstmt.close();rs.close();
			
			// calculate total_amount
			long total_amount = 0;
			for(int i=0;i<KB_ada_nominal.length;i++){
				total_amount += Long.parseLong(KB_ada_nominal[i]);
			}
			System.out.println("total_amount : "+total_amount);
			
			// insert into klaim-recon
			query = "insert into recon values('"+id_recon+"', sysdate, '"+AJ_merchantid+"', 'cashin_claim_ada', "+KB_ada_nominal.length+", 0, "+total_amount+", 0, 0, sysdate, '','')";
			System.out.println(query);
			pstmt = con.prepareStatement(query);
			pstmt.executeUpdate();
			pstmt.close();	
						
			for(int i=0;i<KB_ada_nominal.length;i++){
				// ambil id dari nextval from recon_detail seq
				query = "select SEQ_RECON_DETAIL.NEXTVAL from dual";
				pstmt = con.prepareStatement(query);
				rs = pstmt.executeQuery();
				if(rs.next()){
					id_recon_detail = rs.getString("nextval");
				}
				pstmt.close();rs.close();
							
				// insert into klaim-recon_detail
				query = "insert into recon_detail values('"+id_recon_detail+"', '"+KB_ada_jam[i]+"', '"+KB_ada_kartu[i]+"', '"+KB_ada_jenis[i]+"', "+KB_ada_nominal[i]+", '"+KB_ada_setoran[i]+"', to_date('"+KB_ada_tanggal[i]+"','DD/MM/YYYY'), '', '', '"+KB_ada_resi[i]+"', '"+KB_ada_terminal[i]+"', '0',sysdate, '', '','"+id_recon+"','"+KB_ada_resi[i]+"')";
				System.out.println(query);
				pstmt = con.prepareStatement(query);
				pstmt.executeUpdate();
				pstmt.close();	
			}
			
			// insert into activity_log
			query = "INSERT INTO ACTIVITY_LOG (USERLOGIN, ACCESS_TIME, ACTIVITY, NOTE, IP, REASON) values ('"+user+"', sysdate, 'Recon cashin_claim_ada inserted', '"+AJ_merchantid+"|"+KB_ada_nominal.length+"|', '"+request.getRemoteAddr()+"', '-')";
			pstmt = con.prepareStatement(query);
			pstmt.executeUpdate();
			pstmt.close();
			
			outPUT+=("Recon Cashin Claim Ada Inserted|"+KB_ada_nominal.length+"|");
			bb = true;
		}
		
		// insert of recon cashin_claim_tidak ===================================
		if(KB_tidak_nominal!=null && KB_tidak_jenis!=null && KB_tidak_kartu!=null&& KB_tidak_resi!=null&& KB_tidak_setoran!=null&& KB_tidak_tanggal!=null&& KB_tidak_jam!=null&& KB_tidak_terminal!=null){
			System.out.println("Masuk claim tidak");
			String id_recon = ""; String id_recon_detail = "";
			
			// ambil id dari nextval from recon seq
			query = "select SEQ_RECON.NEXTVAL from dual";
			pstmt = con.prepareStatement(query);
			rs = pstmt.executeQuery();
			if(rs.next()){
				id_recon = rs.getString("nextval");
			}
			pstmt.close();rs.close();
			
			// calculate total_amount
			long total_amount = 0;
			for(int i=0;i<KB_tidak_nominal.length;i++){
				total_amount += Long.parseLong(KB_tidak_nominal[i]);
			}
			System.out.println("total_amount : "+total_amount);
			
			// insert into klaim-recon
			query = "insert into recon values('"+id_recon+"', sysdate, '"+AJ_merchantid+"', 'cashin_claim_tidak', "+KB_tidak_nominal.length+", 0, "+total_amount+", 0, 0, sysdate, '','')";
			System.out.println(query);
			pstmt = con.prepareStatement(query);
			pstmt.executeUpdate();
			pstmt.close();	
						
			for(int i=0;i<KB_tidak_nominal.length;i++){
				// ambil id dari nextval from recon_detail seq
				query = "select SEQ_RECON_DETAIL.NEXTVAL from dual";
				pstmt = con.prepareStatement(query);
				rs = pstmt.executeQuery();
				if(rs.next()){
					id_recon_detail = rs.getString("nextval");
				}
				pstmt.close();rs.close();
							
				// insert into klaim-recon_detail
				query = "insert into recon_detail values('"+id_recon_detail+"', '"+KB_tidak_jam[i]+"', '"+KB_tidak_kartu[i]+"', '"+KB_tidak_jenis[i]+"', "+KB_tidak_nominal[i]+", '"+KB_tidak_setoran[i]+"', to_date('"+KB_tidak_tanggal[i]+"','DD/MM/YYYY'), '', '', '"+KB_tidak_resi[i]+"', '"+KB_tidak_terminal[i]+"', '0',sysdate, '', '','"+id_recon+"','"+KB_tidak_resi[i]+"')";
				System.out.println(query);
				pstmt = con.prepareStatement(query);
				pstmt.executeUpdate();
				pstmt.close();	
			}
			
			// insert into activity_log
			query = "INSERT INTO ACTIVITY_LOG (USERLOGIN, ACCESS_TIME, ACTIVITY, NOTE, IP, REASON) values ('"+user+"', sysdate, 'Recon cashin_claim_tidak inserted', '"+AJ_merchantid+"|"+KB_tidak_nominal.length+"|', '"+request.getRemoteAddr()+"', '-')";
			pstmt = con.prepareStatement(query);
			pstmt.executeUpdate();
			pstmt.close();
			
			outPUT+=("Recon Cashin Claim Tidak Ada Inserted|"+KB_tidak_nominal.length+"|");
			bb = true;
		}
					
		if(reconed!=null){
			if(bb){
				con.commit();
				out.println("<script language='javascript'>alert('Recon RPT Artajasa is successful. Recon detail inserted.')</script>");
				outPUT+=(AJ_merchantid+"|Recon RPT Artajasa is successful.Recon detail inserted|");
			}else{
				out.println("<script language='javascript'>alert('Recon RPT Artajasa is successful. All clear')</script>");
				outPUT+=(AJ_merchantid+"|Recon RPT Artajasa is successful.All clear|");
			}
			
			con.rollback();
			
			// moving from iso_trx_hist_tmp to iso_trx_all by tanggal_laporan
			int rowMoved = 0;
			int rowDeleted = 0;
			
			for(int i=0;i<tanggal_laporan.length;i++){
				query = "insert into iso_trx_all select * from iso_trx_hist_tmp where to_date(substr(ISO_TRXID,0,10), 'MMDDHH24MISS')+420/1440 between to_date('"+tanggal_laporan[i]+" 00:00:00','MM/DD/YY HH24:MI:SS') and to_date('"+tanggal_laporan[i]+" 23:59:59','MM/DD/YY HH24:MI:SS')";
				System.out.println(query);
				pstmt = con.prepareStatement(query);
				rowMoved += pstmt.executeUpdate();
				pstmt.close();
				
				query = "delete from iso_trx_hist_tmp where to_date(substr(ISO_TRXID,0,10), 'MMDDHH24MISS')+420/1440 between to_date('"+tanggal_laporan[i]+" 00:00:00','MM/DD/YY HH24:MI:SS') and to_date('"+tanggal_laporan[i]+" 23:59:59','MM/DD/YY HH24:MI:SS')";
				System.out.println(query);
				pstmt = con.prepareStatement(query);
				rowDeleted += pstmt.executeUpdate();
				pstmt.close();
				
				if(rowMoved>0 && rowDeleted>0){
					outPUT+=("Data successfully moved from iso_trx_hist_tmp to iso_trx_all on date "+tanggal_laporan[i]+". Records affected:"+Integer.toString(rowMoved)+"|");
					con.commit();
				}else{
					outPUT+=("There is no data to be moved or deleted on date "+tanggal_laporan[i]+"|");
				}	
				//done moving
			}
			
		}
	}
	else if (ServletFileUpload.isMultipartContent(request)){
       
		//yusuf

        Iterator i = fileItemsList.iterator();
		while(i.hasNext()){
			FileItem fi = (FileItem)i.next();
			if(!fi.isFormField()){	
				String fileName = fi.getName();
				String saveFile = fileName.substring(fileName.lastIndexOf("\\")+1);
				if(!fileName.equals("")&&!saveFile.equals("")){
					String ext = saveFile.substring(saveFile.length()-3, saveFile.length());
					if(ext.equalsIgnoreCase("rpt")){
						// write the file
						try {
							saveFile=saveFile.substring(0,saveFile.length()-4);
							saveFile+=timeNow;
							saveFile+=".rpt";
							String pathTes = application.getRealPath("/")+"artajasa_claim";

							File fileTes = new File(pathTes);
							if(!fileTes.exists())fileTes.mkdirs();
							fi.write(new File(application.getRealPath("/")+"artajasa_claim", saveFile));
							pathFile = pathTes+"/"+saveFile;
							out.println("<script language='javascript'>alert('File upload is successful.')</script>");
							outPUT+=("File upload of "+saveFile+" is successful|");

						}
						catch (Exception e) {
							outPUT+=("File upload of "+saveFile+" is error. Error message:"+e.getMessage()+"|");
							out.println("<script language='javascript'>alert('File upload is error. Message : "+e.getMessage()+".')</script>");
						}
					}else{
						out.println("Please insert rpt file.");
						outPUT +=("Please insert rpt file.");
					}
				}
			}
			else{
				/* Get form fields value */				
				if (fi.getFieldName().equals("idLog1"))encLog = fi.getString();
				if (fi.getFieldName().equals("idLog2"))encPass = fi.getString();				
			}
		}
		//==setelah selesai mengambil data.
		if(encLog==null)encLog="";if(encPass==null)encPass="";
		
		//==check database
		query = "select * from tsel_webstarter_user where username='"+encLog+"' and password='"+encPass+"'";
		stmt = con.createStatement();
		rs = stmt.executeQuery(query);
		if(!rs.next()){
			out.println("<script language='javascript'>alert('Not Logined, redirect to login page.')</script>");
			outPUT+="Not login|";
			response.sendRedirect("https://10.2.114.121:9082/tcash-web/web-starter/Login.jsp");
		}
		rs.close();stmt.close();
		
		if(pathFile.equals("")){
			//out.println("<script language='javascript'>alert('Path file is blank, please correct it.')</script>");
			outPUT+="Path blank|";
		}
    }
%>

<%
	if(!pathFile.equals("") && !encLog.equals("") && !encPass.equals("")){
%>

<%        // Do the magic. read the file

        out.println("<hr />");
        // reader parameter
        boolean startCashout = false;
		boolean startCashoutSuspect = false;
        boolean startCashoutSummary = false;
        
		boolean startCashin = false;
        boolean startCashinSuspect = false;
		boolean startCashinSummary = false;
		
		boolean startClaimSuspect = false;
		boolean startClaimBerhasil = false;
        
		boolean startNotaKredit = false;
		boolean startInformasiTransferUang = false;
		
		//boolean startFetchingCashoutDate = false;
		//boolean startFetchingCashinDate = false;
		
        String thisLine = "";
		String dateReport = "";
		String dateNow = sdf2.format(cal.getTime());
		ArrayList<String> cashout_date = new ArrayList<String>();
		ArrayList<String> cashin_date = new ArrayList<String>();
		
        // report parameter
        ArrayList<String[]> nota_kredit = new ArrayList<String[]>();
		ArrayList<String[]> informasi_transfer_uang = new ArrayList<String[]>();
		
		// klaim parameter
		ArrayList<String[]> al_claim_berhasil = new ArrayList<String[]>();
		ArrayList<String[]> al_claim_suspect = new ArrayList<String[]>();
		
        ArrayList<String[]> al_cashout = new ArrayList<String[]>();
		ArrayList<String[]> al_cashout_suspect = new ArrayList<String[]>();
        String cashout_total_approved = "";
        String cashout_total_declined = "";
        String cashout_total_declined_charge = "";
        String cashout_total_autoreq_approved = "";
        String cashout_total_autoreq_declined = "";
        String cashout_total_transactions = "";
        String cashout_total_switched = "";
        String cashout_total_offline = "";
		String cashout_total_nominal = "";

        ArrayList<String[]> al_cashin = new ArrayList<String[]>();
		ArrayList<String[]> al_cashin_suspect = new ArrayList<String[]>();
		String cashin_total_approved = "";
        String cashin_total_declined = "";
        String cashin_total_autoreq_approved = "";
        String cashin_total_autoreq_declined = "";
        String cashin_total_transactions = "";
        String cashin_total_switchedin = "";
        String cashin_total_nominal = "";
	
        fileIn = new BufferedReader(new FileReader(pathFile));
        int myi = 0;
        while((thisLine=fileIn.readLine())!=null){
            //System.out.println("Debug|thisLine : "+thisLine);
            System.out.println("Line : "+ myi++ );
            if(myi == 120){
            	System.out.println("Error -->");
            }
            // check if it cashout records
            if(thisLine.contains("ON/2 TERMINAL ACTIVITY FOR TRANSFER REPORT") && !thisLine.contains("SUSPECT TRANSACTION")){
                // go into next 4 line
                thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();
                //check if it is cashout summary
               // System.out.println("Debug|thisLine at Terminal Totals : "+thisLine);
				if(thisLine.contains("* * * T E R M I N A L  T O T A L S * * * ")){
                    startCashoutSummary = true;
                    //take the cashout summary
                    thisLine=fileIn.readLine();
                    cashout_total_declined = get_cashout_summary(thisLine); thisLine=fileIn.readLine();
                    cashout_total_declined_charge = get_cashout_summary(thisLine); thisLine=fileIn.readLine();
                    cashout_total_approved = get_cashout_summary(thisLine); thisLine=fileIn.readLine();
                    cashout_total_autoreq_declined = get_cashout_summary(thisLine); thisLine=fileIn.readLine();
                    cashout_total_autoreq_approved = get_cashout_summary(thisLine); thisLine=fileIn.readLine();
                    cashout_total_transactions = get_cashout_summary(thisLine); thisLine=fileIn.readLine();
                    cashout_total_offline = get_cashout_summary(thisLine); thisLine=fileIn.readLine();
                    cashout_total_switched = get_cashout_summary(thisLine); thisLine=fileIn.readLine(); thisLine=fileIn.readLine();
					cashout_total_nominal = ((thisLine.substring(83, thisLine.length())).trim()).replaceAll(",","");
				}
                else{
                    // go into next 3 line
                    thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();
                    
					//System.out.println("Debug|thisLine at Tran Date : "+thisLine);
					// fetch cashout tran date first, then the transaction itself
					if(thisLine.contains("TRAN DATE")){
						String cashout_date_detail = (thisLine.substring(16, thisLine.length())).trim();
						if(cashout_date.size()==0){
							cashout_date.add(cashout_date_detail);
						}else{
							boolean is_cashout_date_exist = false;
							for(int i=0; i<cashout_date.size(); i++){							
								if((cashout_date.get(i)).equals(cashout_date_detail)){
									is_cashout_date_exist = true;
									break;
								}
							}
							if(!is_cashout_date_exist){
								cashout_date.add(cashout_date_detail);
							}
						}
					
					// read 1 line
					thisLine=fileIn.readLine();
					}
					//System.out.println("Debug|thisLine at early startCashout : "+thisLine);
					// start fetching transaction
					startCashout = true;
                }
            }
			// check if it is cashout suspect records
			if(thisLine.contains("ON/2 TERMINAL ACTIVITY FOR TRANSFER REPORT") && thisLine.contains("SUSPECT TRANSACTION")){
				// go next 6 lines
				thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();
				startCashoutSuspect = true;
				
			}
			
			// check if it is al_claim_berhasil
			if(thisLine.contains("INFORMASI DETAIL KEWAJIBAN KLAIM/DENDA")){
				// go next 8 lines
				thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();
				startClaimBerhasil = true;
			}
			
			// check if it is al_claim_suspect
			if(thisLine.contains("INFORMASI DETAIL HAK KLAIM/DENDA")){
				// go next 8 lines
				thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();
				startClaimSuspect = true;
			}
			
            // check if it is cashin records
            if(thisLine.contains("ON/2 DESTINATION TRANSFER ACTIVITY REPORT ") && !thisLine.contains("SUSPECT TRANSACTION")){
                // go into next line
                thisLine=fileIn.readLine();
				// fetch the reportdate
				dateReport = thisLine.substring(116, 124);
				thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();
                //check if it is cashin summary
                if(thisLine.contains("* * * A P P L I C A T I O N   A C T I V I T Y   T O T A L S * * *")){
                    startCashinSummary = true;
                    //take the cashin summary
                    thisLine=fileIn.readLine();
                    cashin_total_approved = get_cashin_summary(thisLine); thisLine=fileIn.readLine();
                    cashin_total_declined = get_cashin_summary(thisLine); thisLine=fileIn.readLine();
                    cashin_total_autoreq_approved = get_cashin_summary(thisLine); thisLine=fileIn.readLine();
                    cashin_total_autoreq_declined = get_cashin_summary(thisLine); thisLine=fileIn.readLine();
                    cashin_total_transactions = get_cashin_summary(thisLine); thisLine=fileIn.readLine();
                    cashin_total_switchedin = get_cashin_summary(thisLine); thisLine=fileIn.readLine();
                    cashin_total_nominal = get_cashin_summary(thisLine).replaceAll(",","");
                }
                else{
                    // go into next 3 line
                    thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();
                    
					// start fetching transaction
					startCashin = true;
                }
            }
			
			// check if it is cashin suspect records
            if(thisLine.contains("ON/2 DESTINATION TRANSFER ACTIVITY REPORT ") && thisLine.contains("SUSPECT TRANSACTION")){
				// go next 6 lines
				thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();
				startCashinSuspect = true;
				//System.out.println("Debug|Masuk di startCashinSuspect true");
			}

            // check if it is nota kredit records
            if(thisLine.contains("N O T A   K R E D I T")){
                startNotaKredit = true;
				//System.out.println("DEBUG|Masuk di startNotaKredit true");
            }
			
			// check if it is informasi transfer uang
            if(thisLine.contains(" INFORMASI TRANSFER UANG")){
                startInformasiTransferUang = true;
            }

            // checking conditions of stopping
            if(startCashin && ( thisLine.length()<=1 || thisLine.contains("  TIDAK ADA TRANSAKSI  ") || (thisLine.trim()).equals(""))){
                startCashin = false;
            }
			if(startCashinSuspect && ( thisLine.length()<=1 || thisLine.contains("  TIDAK ADA TRANSAKSI  ") || (thisLine.trim()).equals("") )){
                startCashinSuspect = false;
				//System.out.println("Debug|Masuk di startCashinSuspect false");
            }
            if(startCashinSummary && (thisLine.length()<=1 || (thisLine.trim()).equals(""))){
                startCashinSummary = false;
            }
            if(startCashout && ( thisLine.length()<=1 || thisLine.contains("  TIDAK ADA TRANSAKSI  ") || (thisLine.trim()).equals(""))){
                startCashout = false;  
            }
			if(startCashoutSuspect && ( thisLine.length()<=1 || thisLine.contains("  TIDAK ADA TRANSAKSI  ") || (thisLine.trim()).equals(""))){
                startCashoutSuspect = false;  
            }
            if(startCashoutSummary && ( thisLine.length()<=1 || thisLine.contains("  TIDAK ADA TRANSAKSI  ") || (thisLine.trim()).equals("") )){
                startCashoutSummary = false;
            }
            if(startNotaKredit&& ( thisLine.length()<=1 || thisLine.contains("  TIDAK ADA TRANSAKSI  ") || (thisLine.trim()).equals(""))){
                //System.out.println("DEBUG|Masuk di startNotaKredit false");
				startNotaKredit = false;
            }
			if(startInformasiTransferUang&& ( thisLine.length()<=1 || thisLine.contains("  TIDAK ADA TRANSAKSI  ") || (thisLine.trim()).equals(""))){
               // System.out.println("DEBUG|Masuk di startInformasiTransferUang false");
				startInformasiTransferUang = false;
            }
			if(startClaimBerhasil && ( thisLine.length()<=1 || thisLine.contains("  TIDAK ADA TRANSAKSI  ") || thisLine.contains("--------------------------------------------------------") || (thisLine.trim()).equals(""))){
                startClaimBerhasil = false;
            }
			if(startClaimSuspect && ( thisLine.length()<=1 || thisLine.contains("  TIDAK ADA TRANSAKSI  ") || thisLine.contains("--------------------------------------------------------") || (thisLine.trim()).equals(""))){
                startClaimSuspect = false;
            }
			
            // start fetching data
            if(startClaimBerhasil){
				al_claim_berhasil.add(this.get_claim(thisLine));
			}
			if(startClaimSuspect){
				al_claim_suspect.add(this.get_claim(thisLine));
			}
			if(startCashoutSuspect){
				//System.out.println("Debug|thisLine at startCashout : "+thisLine);
                al_cashout_suspect.add(this.get_cashout_report(thisLine));
			}
			if(startCashinSuspect){				
				//System.out.println("Debug|Masuk di startCashinSuspect|thisLine:"+thisLine);
				al_cashin_suspect.add(this.get_cashin_report(thisLine));
				//System.out.println("Debug|Selesai ngeadd startCashinSuspect");
			}
			if(startCashout){
				//System.out.println("Debug|thisLine at startCashout : "+thisLine);
                al_cashout.add(this.get_cashout_report(thisLine));
            }
            if(startCashin){
				//System.out.println("Debug|Masuk di startCashin|thisLine:"+thisLine);
                al_cashin.add(this.get_cashin_report(thisLine));
				
				// fetch cashin tran date from array note_kredit_detail[9]
				String cashin_date_detail = (thisLine.substring(104, 113)).trim();
				if(cashin_date.size()==0){
					cashin_date.add(cashin_date_detail);
				}else{
					boolean is_cashin_date_exist = false;
					for(int i=0; i<cashin_date.size(); i++){						
						if((cashin_date.get(i)).equals(cashin_date_detail)){
							is_cashin_date_exist = true;
							break;
						}
					}
					if(!is_cashin_date_exist){
						cashin_date.add(cashin_date_detail);
					}
				}
            }
            if(startNotaKredit){
				//System.out.println("DEBUG|Masuk di startNotaKredit");
                String [] nota_kredit_detail = new String [22];
                // go to next 4 line
                thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();
                
				// start fetching
                nota_kredit_detail[0] = (thisLine.substring(33, thisLine.length())).trim(); thisLine=fileIn.readLine();
                nota_kredit_detail[1] = (thisLine.substring(33, thisLine.length())).trim(); thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();
                
                nota_kredit_detail[2] = ((thisLine.substring(33, 47)).trim()).replaceAll(",",""); thisLine=fileIn.readLine();
                nota_kredit_detail[3] = ((thisLine.substring(33, 47)).trim()).replaceAll(",",""); thisLine=fileIn.readLine();
                nota_kredit_detail[4] = ((thisLine.substring(33, 47)).trim()).replaceAll(",",""); thisLine=fileIn.readLine();
				nota_kredit_detail[5] = ((thisLine.substring(33, 47)).trim()).replaceAll(",",""); thisLine=fileIn.readLine();
                nota_kredit_detail[6] = ((thisLine.substring(33, 47)).trim()).replaceAll(",",""); thisLine=fileIn.readLine();thisLine=fileIn.readLine();

                // TOTAL
                nota_kredit_detail[7] = ((thisLine.substring(33, 47)).trim()).replaceAll(",",""); thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();

                nota_kredit_detail[8] = (thisLine.substring(35, 52)).trim(); nota_kredit_detail[9] = ((thisLine.substring(57, 73)).trim()).replaceAll(",",""); thisLine=fileIn.readLine();
                nota_kredit_detail[10] = (thisLine.substring(35, 52)).trim(); nota_kredit_detail[11] = ((thisLine.substring(57, 73)).trim()).replaceAll(",",""); thisLine=fileIn.readLine();thisLine=fileIn.readLine();

                nota_kredit_detail[12] = (thisLine.substring(35, 52)).trim(); nota_kredit_detail[13] = ((thisLine.substring(57, 73)).trim()).replaceAll(",",""); thisLine=fileIn.readLine();
                nota_kredit_detail[14] = (thisLine.substring(35, 52)).trim(); nota_kredit_detail[15] = ((thisLine.substring(57, 73)).trim()).replaceAll(",",""); thisLine=fileIn.readLine();
                nota_kredit_detail[16] = (thisLine.substring(35, 52)).trim(); nota_kredit_detail[17] = ((thisLine.substring(57, 73)).trim()).replaceAll(",",""); thisLine=fileIn.readLine();
                nota_kredit_detail[18] = (thisLine.substring(35, 52)).trim(); nota_kredit_detail[19] = ((thisLine.substring(57, 73)).trim()).replaceAll(",",""); thisLine=fileIn.readLine();thisLine=fileIn.readLine();
				
				//System.out.println("nota_kredit_detail[18]:"+nota_kredit_detail[18]+", nota_kredit_detail[19]:"+nota_kredit_detail[19]);
				
                nota_kredit_detail[20] = (thisLine.substring(35, 52)).trim(); nota_kredit_detail[21] = ((thisLine.substring(57, 73)).trim()).replaceAll(",",""); thisLine=fileIn.readLine();

                // finishing fetching records, adding to arraylist
                nota_kredit.add(nota_kredit_detail);
            }
			if(startInformasiTransferUang){
				//System.out.println("DEBUG|Masuk di startInformasiTransferUang");
				String [] informasi_transfer_uang_detail = new String [14];
                // go to next 6 line
                thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();
                
				// start fetching
                informasi_transfer_uang_detail[0] = (thisLine.substring(33, thisLine.length())).trim(); thisLine=fileIn.readLine();
                informasi_transfer_uang_detail[1] = (thisLine.substring(33, thisLine.length())).trim(); thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();
                
                informasi_transfer_uang_detail[2] = ((thisLine.substring(14, thisLine.length()-3)).trim()).replaceAll(",",""); thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();
                
				informasi_transfer_uang_detail[3] = ((thisLine.substring(33, thisLine.length()-3)).trim()).replaceAll(",",""); thisLine=fileIn.readLine();
                informasi_transfer_uang_detail[4] = ((thisLine.substring(33, thisLine.length()-3)).trim()).replaceAll(",",""); thisLine=fileIn.readLine();thisLine=fileIn.readLine();
                
				informasi_transfer_uang_detail[5] = ((thisLine.substring(33, thisLine.length()-3)).trim()).replaceAll(",","");
				
				
				// read 19 lines again
				thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();
                
				// TOTAL
                informasi_transfer_uang_detail[6] = (thisLine.substring(40, 50)).trim(); informasi_transfer_uang_detail[7] = ((thisLine.substring(54, thisLine.length()-3)).trim()).replaceAll(",",""); thisLine=fileIn.readLine();
                informasi_transfer_uang_detail[8] = (thisLine.substring(40, 50)).trim(); informasi_transfer_uang_detail[9] = ((thisLine.substring(54, thisLine.length()-3)).trim()).replaceAll(",",""); thisLine=fileIn.readLine();
                informasi_transfer_uang_detail[10] = (thisLine.substring(40, 50)).trim(); informasi_transfer_uang_detail[11] = ((thisLine.substring(54, thisLine.length()-3)).trim()).replaceAll(",",""); thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();thisLine=fileIn.readLine();
				
                informasi_transfer_uang_detail[12] = (thisLine.substring(40, 50)).trim(); informasi_transfer_uang_detail[13] = ((thisLine.substring(54, thisLine.length()-3)).trim()).replaceAll(",",""); thisLine=fileIn.readLine();
               
			   // finishing fetching records, adding to arraylist
                informasi_transfer_uang.add(informasi_transfer_uang_detail);
                // thisLine=fileIn.readLine();
			}
			//System.out.println("Pindah while");
        }
		b0 = true;
        
		fileIn.close();
%>

<%		
				
		// ========================= recon process
		
		// checking date of report with today's date
		dateNow = "03/07/11";
		
		if(b0){			
				/* =============================
				Recon Klaim berhasil, cek apakah data di klaim berhasil ada atau tidak, kalau tidak ada kasi ke al_claim_berhasil_tidakada, kalau ada kasi ke al_claim_berhasil_ada
				*/
				ArrayList<String[]> al_claim_berhasil_tidakada = new ArrayList<String[]>();
				ArrayList<String[]> al_claim_berhasil_ada = new ArrayList<String[]>();
				
				for(int i=0;i<al_claim_berhasil.size();i++){
					query = "select * from iso_trx_hist_tmp it where to_char((to_date(substr(it.ISO_TRXID,5,4),'HH24MI')+420/1440), 'HH24MI')='"+(al_claim_berhasil.get(i)[5]).substring(0,2)+(al_claim_berhasil.get(i)[5]).substring(3,5)+"' and (tx_date between to_date('"+al_claim_berhasil.get(i)[4]+" 00:00:00','DD/MM/YYYY HH24:MI:SS') and to_date('"+al_claim_berhasil.get(i)[4]+" 23:59:59','DD/MM/YYYY HH24:MI:SS')) and amount ='"+al_claim_berhasil.get(i)[7]+"'";
					System.out.println(query);
					stmt = con.createStatement();
					rs = stmt.executeQuery(query);
					if(rs.next()){
						al_claim_berhasil_ada.add(al_claim_berhasil.get(i));
					}else{
						al_claim_berhasil_tidakada.add(al_claim_berhasil.get(i));
					}
					rs.close();stmt.close();
				}
				
				
				// ambil dari database pertanggal yang ada di cashout_date yang suspect, lalu bandingkan dengan Cashout RPT yang gagal, suspect, dan berhasil. Kalau cocok dengan yang berhasil, maka hapus dari suspend, kalau cocok dengan yang suspect atau gagal, maka lakukan reversal dengan API
		
				// ========================= recon process CASHOUT
				/*
				Recon algorithm
				0. ambil dari database pertanggal yang ada di cashout_date yang statusnya suspect = db_cashout_suspect
				1. ambil data dari cashout rpt yang statusnya gagal (al_cashout) = al_cashout_gagal
				1.5 bandingkan dengan database suspect (cashout_suspect_gagal langsung reverse)
				2. ambil data dari cashout rpt yang statusnya berhasil (al_cashout) = al_cashout_berhasil
				2.5 bandingkan dengan database suspect (cashout_suspect_berhasil langsung delete) 
				3. al_cashout_suspect bandingkan dengan database suspect (cashout_suspect_suspect, kasi peringatan 3 hari) 
				*/
				
				// System.out.println("Debug masuk sebelum langkah 0");
				// 0. ambil dari database pertanggal yang ada di cashout_date yang statusnya suspect
				ArrayList<String[]> db_cashout_suspect = new ArrayList<String[]>();
				long db_cashout_suspect_total = 0;
				
				for(int i=0;i<cashout_date.size();i++){
					query = "select it.merchantid, it.tcash_ref, it.ISO_TRXID, it.status as result_code, substr(it.ISO_TRXID,5,4) as tran_time, concat('0',substr(it.cust_msisdn,3)) as acct_number, to_char(to_date(substr(it.ISO_TRXID,0,10), 'MMDDHH24MISS'), 'MM/DD/YY') as iso_date, it.trx_type as tran_code, it.AMOUNT as tran_amount, substr(it.ISO_TRXID,11,6) as trace_number, substr(it.data,0,(instr(it.data,';',1,1))-1) as bank_code, substr(it.data,(instr(it.data,';',1,1))+1,(instr(it.data,';',1,2))-(instr(it.data,';',1,1))-1) as pan_code, substr(it.data,instr(it.data,';',1,2)+1,12) as ref_number "+
							"from iso_trx_hist_tmp it " + 
							"where it.status='0' and it.trx_type='200' and (to_date(substr(it.ISO_TRXID,0,10), 'MMDDHH24MISS')+420/1440 between to_date('"+cashout_date.get(i)+" 00:00:01','MM/DD/YY HH24:MI:SS') and to_date('"+cashout_date.get(i)+" 23:59:59','MM/DD/YY HH24:MI:SS'))";
					System.out.println(query);
					stmt = con.createStatement();
					rs = stmt.executeQuery(query);
					while(rs.next()){
						String [] db_cashout_detail = new String [12];
						db_cashout_detail[0] = getGMTPlus7(rs.getString("tran_time"));
						db_cashout_detail[1] = rs.getString("acct_number");
						db_cashout_detail[2] = rs.getString("tran_code");
						db_cashout_detail[3] = rs.getString("tran_amount");
						db_cashout_detail[4] = rs.getString("result_code")+"|"+rs.getString("tcash_ref");
						db_cashout_detail[5] = rs.getString("iso_date");
						db_cashout_detail[6] = rs.getString("pan_code");
						db_cashout_detail[7] = rs.getString("bank_code");
						db_cashout_detail[8] = rs.getString("trace_number");
						db_cashout_detail[9] = rs.getString("ref_number");
						db_cashout_detail[10] = rs.getString("ISO_TRXID");
						db_cashout_detail[11] = rs.getString("merchantid");
						db_cashout_suspect_total += Long.parseLong(db_cashout_detail[3]);
						db_cashout_suspect.add(db_cashout_detail);
					}
					rs.close();stmt.close();
				}
				
				// System.out.println("Debug masuk sebelum langkah 0");
				// 0.5 ambil dari database pertanggal yang ada di cashout_date yang statusnya berhasil
				ArrayList<String[]> db_cashout_berhasil = new ArrayList<String[]>();
				long db_cashout_berhasil_total = 0;
				
				for(int i=0;i<cashout_date.size();i++){
					query = "select it.merchantid, it.ISO_TRXID, it.status as result_code, substr(it.ISO_TRXID,5,4) as tran_time, concat('0',substr(it.cust_msisdn,3)) as acct_number, to_char(to_date(substr(it.ISO_TRXID,0,10), 'MMDDHH24MISS'), 'MM/DD/YY') as iso_date, it.trx_type as tran_code, it.AMOUNT as tran_amount, substr(it.ISO_TRXID,11,6) as trace_number, substr(it.data,0,(instr(it.data,';',1,1))-1) as bank_code, substr(it.data,(instr(it.data,';',1,1))+1,(instr(it.data,';',1,2))-(instr(it.data,';',1,1))-1) as pan_code, substr(it.data,instr(it.data,';',1,2)+1,12) as ref_number "+
							"from iso_trx_hist_tmp it " + 
							"where it.status='1' and it.trx_type='200' and (to_date(substr(it.ISO_TRXID,0,10), 'MMDDHH24MISS')+420/1440 between to_date('"+cashout_date.get(i)+" 00:00:01','MM/DD/YY HH24:MI:SS') and to_date('"+cashout_date.get(i)+" 23:59:59','MM/DD/YY HH24:MI:SS'))";
					System.out.println(query);
					stmt = con.createStatement();
					rs = stmt.executeQuery(query);
					while(rs.next()){
						String [] db_cashout_detail = new String [12];
						db_cashout_detail[0] = getGMTPlus7(rs.getString("tran_time"));
						db_cashout_detail[1] = rs.getString("acct_number");
						db_cashout_detail[2] = rs.getString("tran_code");
						db_cashout_detail[3] = rs.getString("tran_amount");
						db_cashout_detail[4] = rs.getString("result_code");
						db_cashout_detail[5] = rs.getString("iso_date");
						db_cashout_detail[6] = rs.getString("pan_code");
						db_cashout_detail[7] = rs.getString("bank_code");
						db_cashout_detail[8] = rs.getString("trace_number");
						db_cashout_detail[9] = rs.getString("ref_number");
						db_cashout_detail[10] = rs.getString("ISO_TRXID");
						db_cashout_detail[11] = rs.getString("merchantid");
						db_cashout_berhasil_total += Long.parseLong(db_cashout_detail[3]);
						db_cashout_berhasil.add(db_cashout_detail);
					}
					rs.close();stmt.close();
				}
				
				System.out.println("Debug masuk sebelum langkah 1");
				// 1. ambil data dari cashout rpt yang statusnya gagal (al_cashout) = al_cashout_gagal
				ArrayList<String[]> al_cashout_gagal = new ArrayList<String[]>();
				for(int i=0;i<al_cashout.size();i++){
					if((( (al_cashout.get(i)[7]).equals("504") || (al_cashout.get(i)[7]).equals("404") ) && (al_cashout.get(i)[9]).equals(""))  || (!(al_cashout.get(i)[9]).equals("") && (!(al_cashout.get(i)[7]).equals("504") || !(al_cashout.get(i)[7]).equals("404")))){
						al_cashout_gagal.add(al_cashout.get(i));
					}
				}	
				
				System.out.println("Debug masuk sebelum langkah 1.5");
				// 1.5 bandingkan dengan database suspect (cashout_suspect_gagal langsung reverse)
				ArrayList<String[]> cashout_suspect_gagal = new ArrayList<String[]>();								
				for(int i=0;i<db_cashout_suspect.size();i++){
					if(al_cashout_gagal.size()!=0){
						int search = findReconCashout(al_cashout_gagal, db_cashout_suspect.get(i)[0], db_cashout_suspect.get(i)[1], db_cashout_suspect.get(i)[3], db_cashout_suspect.get(i)[5], db_cashout_suspect.get(i)[6], db_cashout_suspect.get(i)[7], db_cashout_suspect.get(i)[8], db_cashout_suspect.get(i)[9]);
						if(search!=-1){
							cashout_suspect_gagal.add(db_cashout_suspect.get(i));
						}
					}
				}
				
				System.out.println("Debug masuk sebelum langkah 2");
				//2.0 ambil data dari cashout rpt yang statusnya gagal, dan ambil statusnya berhasil
				ArrayList<String[]> al_cashout_rev = new ArrayList<String[]>();				
				for(int i=0;i<al_cashout.size();i++){
					if(( (al_cashout.get(i)[7]).equals("504") || (al_cashout.get(i)[7]).equals("404")) && (al_cashout.get(i)[9]).equals("")){
						al_cashout_rev.add(al_cashout.get(i));
					}
				}
				ArrayList<String[]> al_cashout_berhasil = new ArrayList<String[]>();
				long al_cashout_berhasil_total = 0;
				for(int i=0;i<al_cashout.size();i++){
					if(( !(al_cashout.get(i)[7]).equals("504") || !(al_cashout.get(i)[7]).equals("404") ) && (al_cashout.get(i)[9]).equals("")){
						// tambahan, cek dulu dengan pasangannya di al_cashout_rev
						boolean rev_found = false;
						for(int j=0;j<al_cashout_rev.size();j++){
							if(al_cashout.get(i)[8].equals(al_cashout_rev.get(j)[8]) && al_cashout.get(i)[13].equals(al_cashout_rev.get(j)[13]) && al_cashout.get(i)[14].equals(al_cashout_rev.get(j)[14])){
								rev_found = true;
								break;
							}
						}
						if(!rev_found){
							al_cashout_berhasil_total += Long.parseLong(al_cashout.get(i)[8]);
							al_cashout_berhasil.add(al_cashout.get(i));
						}
					}
				}
								
				System.out.println("Debug masuk sebelum langkah 2.5");
				//2.5 bandingkan dengan database suspect (cashout_suspect_berhasil langsung delete) 
				ArrayList<String[]> cashout_suspect_berhasil = new ArrayList<String[]>();								
				for(int i=0;i<db_cashout_suspect.size();i++){
					if(al_cashout_berhasil.size()!=0){
						int search = findReconCashout(al_cashout_berhasil, db_cashout_suspect.get(i)[0], db_cashout_suspect.get(i)[1], db_cashout_suspect.get(i)[3], db_cashout_suspect.get(i)[5], db_cashout_suspect.get(i)[6], db_cashout_suspect.get(i)[7], db_cashout_suspect.get(i)[8], db_cashout_suspect.get(i)[9]);
						if(search!=-1){
							cashout_suspect_berhasil.add(db_cashout_suspect.get(i));
						}
					}
				}
				
				System.out.println("Debug masuk sebelum langkah 3");
				//3. al_cashout_suspect bandingkan dengan database suspect (cashout_suspect_suspect, kasi peringatan 3 hari)
				ArrayList<String[]> cashout_suspect_suspect = new ArrayList<String[]>();								
				for(int i=0;i<db_cashout_suspect.size();i++){
					if(al_cashout_suspect.size()!=0){
						int search = findReconCashout(al_cashout_suspect, db_cashout_suspect.get(i)[0], db_cashout_suspect.get(i)[1], db_cashout_suspect.get(i)[3], db_cashout_suspect.get(i)[5], db_cashout_suspect.get(i)[6], db_cashout_suspect.get(i)[7], db_cashout_suspect.get(i)[8], db_cashout_suspect.get(i)[9]);
						if(search!=-1){
							cashout_suspect_suspect.add(db_cashout_suspect.get(i));
						}
					}
				}
				%>


				
				
<%
				/* start of recon cashout===================================================================================
				Recon Cashout algorithm
				0. Filter transaksi berhasil dari result_code tidak sukses (result code yang ada isinya) atau reversal = al_cashout_gagal = al_cashout_berhasil
				1. Filter suspect kotor (ambil baris yang memiliki ref number yang sama, hanya ambil yang result codenya 1081) = Filter suspect bersih1
				2. Filter suspect bersih1 dengan transaksi reversal berhasil di RPT = Filter suspect bersih2
				3. Filter suspect bersih2 dengan transaksi berhasil di database = Filter al_cashout_suspect_recon
				4. Untuk meyakinkan, Lakukan recon satu persatu antara db_cashout_berhasil_bersih dengan al_cashout_berhasil
				*/							
				
				//System.out.println("Debug masuk sebelum langkah 1");
				// 1. Filter suspect kotor (ambil baris yang memiliki ref number yang sama, hanya ambil yang result codenya 1081)
				ArrayList<String[]> al_cashout_suspect_bersih1 = new ArrayList<String[]>();
				
				//System.out.println("al_cashout_suspect.size() : "+al_cashout_suspect.size());
				for(int i=0;i<al_cashout_suspect.size();i++){
					if((al_cashout_suspect.get(i)[9]).equals("1081")){
						al_cashout_suspect_bersih1.add(al_cashout_suspect.get(i));
						//System.out.println("al_cashout_suspect_bersih1 :" + al_cashout_suspect.get(i)[14]);
					}
				}
				
				//System.out.println("Debug masuk sebelum langkah 2");
				// 2. Filter suspect bersih1 dengan transaksi reversal berhasil di RPT				
				// Filter al_cashout_suspect_bersih1 dengan al_cashout_gagal
				ArrayList<String[]> al_cashout_suspect_bersih2 = new ArrayList<String[]>();
				
				//System.out.println("al_cashout_suspect_bersih1.size() : "+al_cashout_suspect_bersih1.size());
				//System.out.println("al_cashout_gagal.size() : "+al_cashout_gagal.size());
				for(int i=0;i<al_cashout_suspect_bersih1.size();i++){
					boolean ada = false;
					for(int j=0;j<al_cashout_gagal.size();j++){
						if((al_cashout_suspect_bersih1.get(i)[14]).equals( al_cashout_gagal.get(j)[14] )){
							ada = true;
							break;
						}
					}
					if(!ada){
						// tambahkan ke al_cashout_suspect_bersih2
						//System.out.println("al_cashout_suspect_bersih2 : "+al_cashout_suspect_bersih1.get(i)[14]);
						al_cashout_suspect_bersih2.add(al_cashout_suspect_bersih1.get(i));
					}
				}
				//System.out.println("al_cashout_suspect_bersih2.size() : "+al_cashout_suspect_bersih2.size());
				
				
				//System.out.println("Debug masuk sebelum langkah 3");
				// 3. Filter suspect bersih2 dengan transaksi berhasil di database = Filter al_cashout_suspect_recon
				
				
				// Filter al_cashout_suspect_bersih2 dengan db_cashout_berhasil di database
				ArrayList<String[]> al_cashout_suspect_recon = new ArrayList<String[]>();
				ArrayList<String[]> db_cashout_berhasil_bersih = new ArrayList<String[]>();
				long al_cashout_suspect_recon_total = 0;
				
				
				//System.out.println("al_cashout_suspect_bersih2.size() : "+al_cashout_suspect_bersih2.size());
				if(al_cashout_suspect_bersih2.size()!=0){
					// Masukin al_cashout_suspect_recon
					for(int i=0;i<al_cashout_suspect_bersih2.size();i++){
						boolean ada = false;
						for(int j=0;j<db_cashout_berhasil.size();j++){
							if((al_cashout_suspect_bersih2.get(i)[14]).equals( db_cashout_berhasil.get(j)[9] )){
								ada = true;
								break;
							}
						}
						if(ada){
							// tambahkan ke al_cashout_suspect_recon
							al_cashout_suspect_recon_total += Long.parseLong(al_cashout_suspect_bersih2.get(i)[8]);
							al_cashout_suspect_recon.add( al_cashout_suspect_bersih2.get(i) );
						}
					}
					// Masukin db_cashout_berhasil_bersih
					for(int i=0;i<db_cashout_berhasil.size();i++){
						boolean ada = false;
						for(int j=0;j<al_cashout_suspect_bersih2.size();j++){
							if((al_cashout_suspect_bersih2.get(j)[14]).equals( db_cashout_berhasil.get(i)[9] )){
								ada = true;
								break;
							}
						}
						if(!ada){
							// tambahkan ke db_cashout_berhasil_bersih
							db_cashout_berhasil_bersih.add( db_cashout_berhasil.get(i) );
						}
					}
				}else{
					for(int j=0;j<db_cashout_berhasil.size();j++){
						db_cashout_berhasil_bersih.add( db_cashout_berhasil.get(j) );
					}
				}
				
				// ==================================
				//System.out.println("Debug masuk sebelum langkah 4");
				// 4. Untuk meyakinkan, Lakukan recon satu persatu antara db_cashout_berhasil_bersih dengan al_cashout_berhasil
				
				
				String index_rec_al2 = "";
				String index_rec_db2 = "";
				String index_recon_al2 = "";
				String index_recon_db2 = "";	

				String [] index_rec_al_array2 = null;
				String [] index_rec_db_array2 = null;
				String [] index_recon_al_array2 = null;
				String [] index_recon_db_array2 = null;								
					
				
				if(db_cashout_berhasil_bersih.size()!=0){
					if(al_cashout_berhasil.size()!=0){
						// start recon	
						
						// data di RPT dan di DB sama2 tidak kosong, masukkan yang sisa di RPT ke index_rec_al2, yang sisa di DB ke index_rec_db2, yang cocok di DB masukkan ke index_recon_db2, yang cocok di RPT masukkan ke index_recon_al2
						
						// filter db_cashout_berhasil_bersih and add to index_recon_db2 dan index_recon_al2
						for(int i=0;i<db_cashout_berhasil_bersih.size();i++){
							int search = findReconCashout(al_cashout_berhasil, db_cashout_berhasil_bersih.get(i)[0], db_cashout_berhasil_bersih.get(i)[1], db_cashout_berhasil_bersih.get(i)[3], db_cashout_berhasil_bersih.get(i)[5], db_cashout_berhasil_bersih.get(i)[6], db_cashout_berhasil_bersih.get(i)[7], db_cashout_berhasil_bersih.get(i)[8], db_cashout_berhasil_bersih.get(i)[9]);
							if(search!=-1){
								index_recon_db2 += i+",";
								index_recon_al2 += search+ ",";
							}
						}
						
						if(!index_recon_db2.equals("")){
							index_recon_db_array2 = index_recon_db2.split(",");
							index_recon_al_array2 = index_recon_al2.split(",");						
						
							// filter db_cashout_berhasil_bersih and add to index_rec_db2
							for(int i=0;i<db_cashout_berhasil_bersih.size();i++){
								boolean bbb = true;
								for(int j=0;j<index_recon_db_array2.length;j++){
									if(i==Integer.parseInt(index_recon_db_array2[j])){
										bbb = false;
										break;
									}
								}
								if(bbb){
									index_rec_db2 += i + ",";
								}
							}
							
							// filter al_cashout_berhasil and add to index_rec_al2
							for(int i=0;i<al_cashout_berhasil.size();i++){
								boolean bbb = true;
								for(int j=0;j<index_recon_al_array2.length;j++){
									if(i==Integer.parseInt(index_recon_al_array2[j])){
										bbb = false;
										break;
									}
								}
								if(bbb){
									index_rec_al2 += i + ",";
								}
							}
						}else{
							// filter db_cashout_berhasil_bersih and add to index_rec_db2
							for(int i=0;i<db_cashout_berhasil_bersih.size();i++){
								index_rec_db2 += i + ",";
							}
							
							// filter al_cashout_berhasil and add to index_rec_al2
							for(int i=0;i<al_cashout_berhasil.size();i++){
								index_rec_al2 += i + ",";
							}
						}
						
					}else{
						// data di RPT kosong, di DB ada, masukin ke index_rec_db2
						for(int i=0;i<db_cashout_berhasil_bersih.size();i++){
							index_rec_db2+= i + ",";
							i++;
						}
					}
					
				}else{
					if(al_cashout_berhasil.size()!=0){
						// data di DB kosong, di RPT tidak kosong, masukkan ke index_rec_al2
						for(int i=0;i<al_cashout_berhasil.size();i++){
							index_rec_al2+= i + ",";
							i++;
						}
					}else{
						// data di RPT dan DB sama2 kosong, ga usah recon
					}
				}
				
				if(!index_rec_db2.equals("")){
					index_rec_db_array2 = index_rec_db2.split(",");
				}
				if(!index_rec_al2.equals("")){
					index_rec_al_array2 = index_rec_al2.split(",");
				}
				
				System.out.println("index_recon_db2 : "+index_recon_db2);
				System.out.println("index_recon_al2 : "+index_recon_al2);
						
				System.out.println("index_rec_db2 : "+index_rec_db2);
				System.out.println("index_rec_al2 : "+index_rec_al2);
				
				// ==================================
				// end of recon cashout
				
%>				
				
				
				
				
				
				<%
				/* start of recon cashin===================================================================================
				Recon Cashin algorithm
				0. Filter transaksi berhasil dari result_code tidak sukses (result code yang ada isinya)
				1. Filter suspect kotor (ambil baris yang memiliki ref number yang sama, hanya ambil yang result codenya 1081) = Filter suspect bersih1
				2. Filter suspect bersih1 dengan transaksi reversal berhasil di RPT = Filter suspect bersih2
				3. Filter suspect bersih2 dengan transaksi berhasil di database = Filter al_cashin_suspect_recon
				4. Untuk meyakinkan, Lakukan recon satu persatu antara db_cashin_berhasil_bersih dengan al_cashin_berhasil
				*/
				
				//System.out.println("Debug masuk sebelum langkah 0");
				// 0. Filter transaksi berhasil dari result_code tidak sukses (result code yang ada isinya)
				
				ArrayList<String[]> al_cashin_rev = new ArrayList<String[]>();				
				long al_cashin_berhasil_total = 0; 
				
				//System.out.println("al_cashin.size() : "+al_cashin.size());
				for(int i=0;i<al_cashin.size();i++){
					//System.out.println("al_cashin.get("+i+")[3] : "+al_cashin.get(i)[3]);
					if(( (al_cashin.get(i)[2]).equals("504") || (al_cashin.get(i)[2]).equals("404")) && (al_cashin.get(i)[4]).equals("")){
						al_cashin_rev.add(al_cashin.get(i));
					}
				}
				ArrayList<String[]> al_cashin_berhasil = new ArrayList<String[]>();
				for(int i=0;i<al_cashin.size();i++){
					if(( !(al_cashin.get(i)[2]).equals("504") || !(al_cashin.get(i)[2]).equals("404") ) && (al_cashin.get(i)[4]).equals("")){
						// tambahan, cek dulu dengan pasangannya di al_cashin_rev
						boolean rev_found = false;
						for(int j=0;j<al_cashin_rev.size();j++){
							if(al_cashin.get(i)[3].equals(al_cashin_rev.get(j)[3]) && al_cashin.get(i)[12].equals(al_cashin_rev.get(j)[12]) && al_cashin.get(i)[13].equals(al_cashin_rev.get(j)[13])){
								rev_found = true;
								break;
							}
						}
						if(!rev_found){
							String my = al_cashin.get(i)[3].endsWith(".") ? al_cashin.get(i)[3].substring(0, al_cashin.get(i)[3].length() - 1) : al_cashin.get(i)[3]; //yusuf
							al_cashin_berhasil_total += Long.parseLong(my);//yusuf
							al_cashin_berhasil.add(al_cashin.get(i));
						}
					}
				}
				
				//System.out.println("Debug masuk sebelum langkah 1");
				// 1. Filter suspect kotor (ambil baris yang memiliki ref number yang sama, hanya ambil yang result codenya 1081)
				ArrayList<String[]> al_cashin_suspect_bersih1 = new ArrayList<String[]>();
				
				//System.out.println("al_cashin_suspect.size() : "+al_cashin_suspect.size());
				for(int i=0;i<al_cashin_suspect.size();i++){
					//System.out.println("al_cashin_suspect.get("+i+")[4] = " + al_cashin_suspect.get(i)[4]);
					if((al_cashin_suspect.get(i)[4]).equals("1081") || (al_cashin_suspect.get(i)[4]).equals("")){
						al_cashin_suspect_bersih1.add(al_cashin_suspect.get(i));
						// System.out.println("al_cashin_suspect_bersih1 :" + al_cashin_suspect.get(i)[13]);
					}
				}
				
				//System.out.println("Debug masuk sebelum langkah 2");
				// 2. Filter suspect bersih1 dengan transaksi reversal berhasil di RPT				
				// Filter al_cashin_suspect_bersih1 dengan al_cashin_rev
				ArrayList<String[]> al_cashin_suspect_bersih2 = new ArrayList<String[]>();
				
				//System.out.println("al_cashin_suspect_bersih1.size() : "+al_cashin_suspect_bersih1.size());
				//System.out.println("al_cashin_rev.size() : "+al_cashin_rev.size());
				for(int i=0;i<al_cashin_suspect_bersih1.size();i++){
					boolean ada = false;
					for(int j=0;j<al_cashin_rev.size();j++){
						if((al_cashin_suspect_bersih1.get(i)[13]).equals( al_cashin_rev.get(j)[13] )){
							ada = true;
							break;
						}
					}
					if(!ada){
						// tambahkan ke al_cashin_suspect_bersih2
						// System.out.println("al_cashin_suspect_bersih2 : "+al_cashin_suspect_bersih1.get(i)[13]);
						al_cashin_suspect_bersih2.add(al_cashin_suspect_bersih1.get(i));
					}
				}
				//System.out.println("al_cashin_suspect_bersih2.size() : "+al_cashin_suspect_bersih2.size());
				
				
				//System.out.println("Debug masuk sebelum langkah 3");
				// 3. Filter suspect bersih2 dengan transaksi berhasil di database = Filter al_cashin_suspect_recon
				ArrayList<String[]> db_cashin_berhasil = new ArrayList<String[]>();
				long db_cashin_success_total = 0;
				
				// ambil dari database pertanggal yang ada di cashin_date, lalu pisahkan yang berhasil dan reversal berhasil. Sekarang ambil hanya yang berhasil
				for(int i=0;i<cashin_date.size();i++){
					query = "select it.merchantid, it.ISO_TRXID, it.status as result_code, substr(it.ISO_TRXID,5,4) as tran_time, concat('0',substr(it.cust_msisdn,3)) as acct_number, to_char(to_date(substr(it.ISO_TRXID,0,10), 'MMDDHH24MISS'), 'MM/DD/YY') as iso_date, it.trx_type as tran_code, it.AMOUNT as tran_amount, substr(it.ISO_TRXID,11,6) as trace_number, substr(it.data,0,(instr(it.data,';',1,1))-1) as bank_code, substr(it.data,(instr(it.data,';',1,1))+1,(instr(it.data,';',1,2))-(instr(it.data,';',1,1))-1) as pan_code, substr(it.data,instr(it.data,';',1,2)+1,12) as ref_number "+
							"from iso_trx_hist_tmp it " + 
							"where it.status='1' and it.trx_type='300' and (to_date(substr(it.ISO_TRXID,0,10), 'MMDDHH24MISS')+420/1440 between to_date('"+cashin_date.get(i)+" 00:00:01','MM/DD/YY HH24:MI:SS') and to_date('"+cashin_date.get(i)+" 23:59:59','MM/DD/YY HH24:MI:SS'))";
					System.out.println(query);
					stmt = con.createStatement();
					rs = stmt.executeQuery(query);
					while(rs.next()){
						String [] db_cashin_detail = new String [12];
						db_cashin_detail[0] = getGMTPlus7(rs.getString("tran_time"));
						db_cashin_detail[1] = rs.getString("acct_number");
						db_cashin_detail[2] = rs.getString("tran_code");
						db_cashin_detail[3] = rs.getString("tran_amount");
						db_cashin_detail[4] = rs.getString("result_code");
						db_cashin_detail[5] = rs.getString("iso_date");
						db_cashin_detail[6] = rs.getString("pan_code");
						db_cashin_detail[7] = rs.getString("bank_code");
						db_cashin_detail[8] = rs.getString("trace_number");
						db_cashin_detail[9] = rs.getString("ref_number");
						db_cashin_detail[10] = rs.getString("ISO_TRXID");
						db_cashin_detail[11] = rs.getString("merchantid");
						db_cashin_success_total += Long.parseLong(db_cashin_detail[3]);
						db_cashin_berhasil.add(db_cashin_detail);
					}
					rs.close();stmt.close();
				}
				
				// Filter al_cashin_suspect_bersih2 dengan db_cashin_berhasil di database
				ArrayList<String[]> al_cashin_suspect_recon = new ArrayList<String[]>();
				ArrayList<String[]> db_cashin_berhasil_bersih = new ArrayList<String[]>();
				long al_cashin_suspect_recon_total = 0;
				
				
				System.out.println("al_cashin_suspect_bersih2.size() : "+al_cashin_suspect_bersih2.size());
				if(al_cashin_suspect_bersih2.size()!=0){
					// Masukin al_cashin_suspect_recon
					for(int i=0;i<al_cashin_suspect_bersih2.size();i++){
						boolean ada = false;
						for(int j=0;j<db_cashin_berhasil.size();j++){
							if((al_cashin_suspect_bersih2.get(i)[13]).equals( db_cashin_berhasil.get(j)[9] )){
								ada = true;
								break;
							}
						}
						if(ada){
							// tambahkan ke al_cashin_suspect_recon
							al_cashin_suspect_recon_total += Long.parseLong(al_cashin_suspect_bersih2.get(i)[3]);
							al_cashin_suspect_recon.add( al_cashin_suspect_bersih2.get(i) );
						}
					}
					// Masukin db_cashin_berhasil_bersih
					for(int i=0;i<db_cashin_berhasil.size();i++){
						boolean ada = false;
						for(int j=0;j<al_cashin_suspect_bersih2.size();j++){
							if((al_cashin_suspect_bersih2.get(j)[13]).equals( db_cashin_berhasil.get(i)[9] )){
								ada = true;
								break;
							}
						}
						if(!ada){
							// tambahkan ke db_cashin_berhasil_bersih
							db_cashin_berhasil_bersih.add( db_cashin_berhasil.get(i) );
						}
					}
				}else{
					for(int j=0;j<db_cashin_berhasil.size();j++){
						db_cashin_berhasil_bersih.add( db_cashin_berhasil.get(j) );
					}
				}
				
				// ==================================
				//System.out.println("Debug masuk sebelum langkah 4");
				// 4. Untuk meyakinkan, Lakukan recon satu persatu antara db_cashin_berhasil_bersih dengan al_cashin_berhasil
				
				
				String index_rec_al = "";
				String index_rec_db = "";
				String index_recon_al = "";
				String index_recon_db = "";	

				String [] index_rec_al_array = null;
				String [] index_rec_db_array = null;
				String [] index_recon_al_array = null;
				String [] index_recon_db_array = null;								
					
				
				if(db_cashin_berhasil_bersih.size()!=0){
					if(al_cashin_berhasil.size()!=0){
						// start recon	
						
						// data di RPT dan di DB sama2 tidak kosong, masukkan yang sisa di RPT ke index_rec_al, yang sisa di DB ke index_rec_db, yang cocok di DB masukkan ke index_recon_db, yang cocok di RPT masukkan ke index_recon_al
						
						// filter db_cashin_berhasil_bersih and add to index_recon_db dan index_recon_al
						for(int i=0;i<db_cashin_berhasil_bersih.size();i++){
							int search = findRecon(al_cashin_berhasil, db_cashin_berhasil_bersih.get(i)[0], db_cashin_berhasil_bersih.get(i)[1], db_cashin_berhasil_bersih.get(i)[3], db_cashin_berhasil_bersih.get(i)[5], db_cashin_berhasil_bersih.get(i)[6], db_cashin_berhasil_bersih.get(i)[7], db_cashin_berhasil_bersih.get(i)[8], db_cashin_berhasil_bersih.get(i)[9]);
							if(search!=-1){
								index_recon_db += i+",";
								index_recon_al += search+ ",";
							}
						}
						
						if(!index_recon_db.equals("")){
							index_recon_db_array = index_recon_db.split(",");
							index_recon_al_array = index_recon_al.split(",");						
						
							// filter db_cashin_berhasil_bersih and add to index_rec_db
							for(int i=0;i<db_cashin_berhasil_bersih.size();i++){
								boolean bbb = true;
								for(int j=0;j<index_recon_db_array.length;j++){
									if(i==Integer.parseInt(index_recon_db_array[j])){
										bbb = false;
										break;
									}
								}
								if(bbb){
									index_rec_db += i + ",";
								}
							}
							
							// filter al_cashin_berhasil and add to index_rec_al
							for(int i=0;i<al_cashin_berhasil.size();i++){
								boolean bbb = true;
								for(int j=0;j<index_recon_al_array.length;j++){
									if(i==Integer.parseInt(index_recon_al_array[j])){
										bbb = false;
										break;
									}
								}
								if(bbb){
									index_rec_al += i + ",";
								}
							}
						}else{
							// filter db_cashin_berhasil_bersih and add to index_rec_db
							for(int i=0;i<db_cashin_berhasil_bersih.size();i++){
								index_rec_db += i + ",";
							}
							
							// filter al_cashin_berhasil and add to index_rec_al
							for(int i=0;i<al_cashin_berhasil.size();i++){
								index_rec_al += i + ",";
							}
						}
						
					}else{
						// data di RPT kosong, di DB ada, masukin ke index_rec_db
						for(int i=0;i<db_cashin_berhasil_bersih.size();i++){
							index_rec_db+= i + ",";
							i++;
						}
					}
					
				}else{
					if(al_cashin_berhasil.size()!=0){
						// data di DB kosong, di RPT tidak kosong, masukkan ke index_rec_al
						for(int i=0;i<al_cashin_berhasil.size();i++){
							index_rec_al+= i + ",";
							i++;
						}
					}else{
						// data di RPT dan DB sama2 kosong, ga usah recon
					}
				}
				
				if(!index_rec_db.equals("")){
					index_rec_db_array = index_rec_db.split(",");
				}
				if(!index_rec_al.equals("")){
					index_rec_al_array = index_rec_al.split(",");
				}
				
				System.out.println("index_recon_db : "+index_recon_db);
				System.out.println("index_recon_al : "+index_recon_al);
						
				System.out.println("index_rec_db : "+index_rec_db);
				System.out.println("index_rec_al : "+index_rec_al);
				
				// ==================================
				// end of recon cashin
				%>

				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> RPT Artajasa - Cashin & Cashout Recon - SUMMARY </strong></font></div><br /><br />
				
				
				<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
				<thead>
					<td colspan="3"><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>  
					Hari, Tanggal Transaksi : |<%
					for(int i=0;i<cashin_date.size();i++){
						out.println(df.format(sdf2.parse(cashin_date.get(i)))+","+cashin_date.get(i)+"|");
					}
					%> 
					</strong></font></div></td>
				</thead>
				<tbody>
					<td colspan="3"><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Cashin </strong></font></div></td>
				</tbody>
				<%/*%>
				<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Kasus Cashin </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> 
					<%
					//System.out.println("db_cashin_berhasil_bersih.size() : "+db_cashin_berhasil_bersih.size()+" | al_cashin_berhasil.size() : "+al_cashin_berhasil.size());
					if((db_cashin_berhasil_bersih.size()!=al_cashin_berhasil.size())){
						out.println("Tak Mungkin");
						System.out.println("Tak Mungkin");
					}else if(al_cashin_suspect_recon.size()>0){
						out.println("Klaim, terdapat suspect berhasil");
						System.out.println("Klaim, terdapat suspect berhasil");
					}else{
						out.println("Normal");
						System.out.println("Klaim, terdapat suspect berhasil");
					}
					
					
					%> 
					</font></div></td>
				</tbody>
				<%*/
					int no_idx = 0;
					System.out.println("DEBUG|Print Summary");
				%>
				<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Jumlah Transaksi Cashin Berhasil di RPT </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_berhasil.size()%> Transaksi, Rp <%=nf.format(al_cashin_berhasil_total)%>,- </font></div></td>
				</tbody>
				<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Jumlah Transaksi Cashin Berhasil di TCASH </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil.size()%> Transaksi, Rp <%=nf.format(db_cashin_success_total)%>,- </font></div></td>
				</tbody>
				
				<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Jumlah Transaksi Cashin RPT dan TCash yang bersesuaian </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=(index_recon_db.equals(""))?"0":index_recon_db_array.length%> Transaksi </font></div></td>
				</tbody>
				<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Jumlah Transaksi Cashin Berlebih di RPT </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=(index_rec_al.equals(""))?"0":index_rec_al_array.length%> Transaksi </font></div></td>
				</tbody>
				<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Jumlah Transaksi Cashin Berlebih di TCash </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=(index_rec_db.equals(""))?"0":index_rec_db_array.length%> Transaksi </font></div></td>
				</tbody>
				<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Jumlah Klaim Berhasil yang ada di TCash </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_claim_berhasil_ada.size()%> Transaksi </font></div></td>
				</tbody>
				<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Jumlah Klaim Berhasil yang tidak ada di TCash </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_claim_berhasil_tidakada.size()%> Transaksi </font></div></td>
				</tbody>				
				<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Jumlah Transaksi Cashin di TCASH, tapi Suspect di RPT </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_suspect_recon.size()%> Transaksi, Rp <%=nf.format(al_cashin_suspect_recon_total)%>,- </font></div></td>
				</tbody>
				
				<tbody>
					<td colspan="3"><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Cashout </strong></font></div></td>
				</tbody>
				<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Jumlah Transaksi Cashout Berhasil di RPT </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashout_berhasil.size()%> Transaksi, Rp <%=nf.format(al_cashout_berhasil_total)%>,- </font></div></td>
				</tbody>
				<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Jumlah Transaksi Cashout Berhasil di TCASH </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil.size()%> Transaksi, Rp <%=nf.format(db_cashout_berhasil_total)%>,- </font></div></td>
				</tbody>				
				<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Jumlah Transaksi Cashout Suspect di TCASH </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_suspect.size()%> Transaksi, Rp <%=nf.format(db_cashout_suspect_total)%>,- </font></div></td>
				</tbody>
				<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Jumlah Transaksi Cashout TCASH Suspect tapi RPT Gagal </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_gagal.size()%> Transaksi </font></div></td>
				</tbody>
				<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Jumlah Transaksi Cashout TCASH Suspect tapi RPT Berhasil </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_berhasil.size()%> Transaksi </font></div></td>
				</tbody>
				<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Jumlah Transaksi Cashout TCASH Suspect tapi RPT Suspect </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_suspect.size()%> Transaksi </font></div></td>
				</tbody>
				
				</table>
				
				<br />
				
				<%
				// ================================================================================================================================================
				%>
				
				<%
				if(cashout_suspect_gagal.size()!=0){
				System.out.println("DEBUG|Print Cashout Recon Suspect yg Gagal");
				%>
				
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> == RECON == Transaksi Cashout Suspect yang gagal </strong></font></div>
				
				<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
					<thead>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No. </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br /> Time </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Acct Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br/> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran Amount </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Result<br /> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran Date </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Issuer/Source<br />Card Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Aba <br />Issuer/Source </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trace Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Retrieval <br /> Ref Number </strong></font></div></td>
					</thead>
				
				<%
				no_idx = 1;
				for(int i=0;i<cashout_suspect_gagal.size();i++){
					%>
					<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=no_idx%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_gagal.get(i)[0]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_gagal.get(i)[1]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_gagal.get(i)[2]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(cashout_suspect_gagal.get(i)[3])%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_gagal.get(i)[4]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_gagal.get(i)[5]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_gagal.get(i)[6]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_gagal.get(i)[7]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_gagal.get(i)[8]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_gagal.get(i)[9]%> </font></div></td>
					</tbody>
					<%
				no_idx++;
				}
				%>
				</table>
				
				<br />
				<%}%>
				
				
				<%
				if(cashout_suspect_berhasil.size()!=0){
				System.out.println("DEBUG|Print Cashout Recon Suspect yang Berhasil");
				%>
				
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> == RECON == Transaksi Cashout Suspect yang berhasil </strong></font></div>
				
				<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
					<thead>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No. </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br /> Time </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Acct Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br/> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran Amount </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Result<br /> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran Date </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Issuer/Source<br />Card Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Aba <br />Issuer/Source </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trace Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Retrieval <br /> Ref Number </strong></font></div></td>
					</thead>
				
				<%
				no_idx = 1;
				for(int i=0;i<cashout_suspect_berhasil.size();i++){
					%>
					<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=no_idx%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_berhasil.get(i)[0]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_berhasil.get(i)[1]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_berhasil.get(i)[2]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(cashout_suspect_berhasil.get(i)[3])%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_berhasil.get(i)[4]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_berhasil.get(i)[5]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_berhasil.get(i)[6]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_berhasil.get(i)[7]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_berhasil.get(i)[8]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_berhasil.get(i)[9]%> </font></div></td>
					</tbody>
					<%
				no_idx++;
				}
				%>
				</table>
				
				<br />
				<%}%>			
				
				<%
				if(cashout_suspect_suspect.size()!=0){
				System.out.println("DEBUG|Print Cashout Recon Suspect yg Suspect");
				%>
				
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> == RECON == Jumlah Transaksi Cashout Suspect yang Suspect </strong></font></div>
				
				<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
					<thead>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No. </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br /> Time </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Acct Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br/> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran Amount </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Result<br /> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran Date </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Issuer/Source<br />Card Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Aba <br />Issuer/Source </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trace Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Retrieval <br /> Ref Number </strong></font></div></td>
					</thead>
				
				<%
				no_idx = 1;
				for(int i=0;i<cashout_suspect_suspect.size();i++){
					%>
					<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=no_idx%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_suspect.get(i)[0]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_suspect.get(i)[1]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_suspect.get(i)[2]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(cashout_suspect_suspect.get(i)[3])%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_suspect.get(i)[4]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_suspect.get(i)[5]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_suspect.get(i)[6]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_suspect.get(i)[7]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_suspect.get(i)[8]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_suspect_suspect.get(i)[9]%> </font></div></td>
					</tbody>
					<%
				no_idx++;
				}
				%>
				</table>
				
				<br />
				<%}%>
				
				<%
				// ================================================================================================================================================
				// CASHOUT
				%>
				
				
				<%
				if(!index_recon_db2.equals("")){
				System.out.println("DEBUG|Print Cashout Recon Transaksi Cashin RPT dan DB yg Bersesuaian");
				%>
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> == RECON == Transaksi Cashout di RPT dan TCash yang bersesuaian  </strong></font></div>
				
				<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
					<thead>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No.<br />Log </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No.<br />RPT </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br /> Time </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Acct Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br/> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran Amount </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Result<br /> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran Date </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Issuer/Source<br />Card Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Aba <br />Issuer/Source </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trace Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Retrieval <br /> Ref Number </strong></font></div></td>
					</thead>
				
				<%
				
					for(int i=0;i<index_recon_db_array2.length;i++){
					%>
					<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=Integer.parseInt(index_recon_db_array2[i])+1%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=Integer.parseInt(index_recon_al_array2[i])+1%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_recon_db_array2[i]))[0]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_recon_db_array2[i]))[1]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_recon_db_array2[i]))[2]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_recon_db_array2[i]))[3]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_recon_db_array2[i]))[4]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_recon_db_array2[i]))[5]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_recon_db_array2[i]))[6]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_recon_db_array2[i]))[7]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_recon_db_array2[i]))[8]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_recon_db_array2[i]))[9]%> </font></div></td>
					</tbody>
					<%
					}
				%>
				</table>
				
				<br />
				<%}%>
				
				<%
				if(!index_rec_db2.equals("")){				
				System.out.println("DEBUG|Print Cashin Recon Cashout Investigasi DB TCash");
				%>
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> == RECON == Transaksi Cashout Ada di Transaksi Berhasil TCash, tidak ada di RPT </strong></font></div>
				<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
					<thead>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No. </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br /> Time </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Acct Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br/> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran Amount </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Result<br /> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran Date </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Issuer/Source<br />Card Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Aba <br />Issuer/Source </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trace Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Retrieval <br /> Ref Number </strong></font></div></td>
					</thead>
				
				<%
					for(int i=0;i<index_rec_db_array2.length;i++){
					%>
					<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=Integer.parseInt(index_rec_db_array2[i])+1%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_rec_db_array2[i]))[0]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_rec_db_array2[i]))[1]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_rec_db_array2[i]))[2]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_rec_db_array2[i]))[3]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_rec_db_array2[i]))[4]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_rec_db_array2[i]))[5]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_rec_db_array2[i]))[6]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_rec_db_array2[i]))[7]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_rec_db_array2[i]))[8]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_rec_db_array2[i]))[9]%> </font></div></td>
					</tbody>
				<%
					}
				
				%>
				</table>
				
				<br />
				
				<%}%>
				
				<%
				if(!index_rec_al2.equals("")){				
				System.out.println("DEBUG|Print Cashout Recon Cashout Investigasi RPT");
				%>
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> == RECON == Transaksi Cashout Ada di RPT, tapi tidak ada di TCash </strong></font></div>
				<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
					<thead>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No. </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br /> Time </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Terminal <br /> Receipt </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trans Card<br /> ABA NBR BR NBR </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Card Acct <br /> Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Card <br /> MBR </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trans <br /> BR NBR </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Account <br /> Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br /> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trans <br /> Amount </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Result <br /> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trm <br /> NBR </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Destination <br /> Acct NBR </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Aba <br /> Dest </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trace <br /> Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Retrieval <br /> Ref NBR </strong></font></div></td>
					</thead>
				
					<%
					for(int i=0;i<index_rec_al_array2.length;i++){
					%>
						<tbody>
						<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=Integer.parseInt(index_rec_al_array2[i])+1%> </font></div></td>
						<%
							for(int j=0;j<15;j++){
								if(j==8){
						%>
						<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=(get_decimal(al_cashout_berhasil.get(Integer.parseInt(index_rec_al_array2[i]))[j]))%> </font></div></td>
						<%
								}else{
									%>
						<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashout_berhasil.get(Integer.parseInt(index_rec_al_array2[i]))[j]%> </font></div></td>			
									<%
								}
							}
						%>
						</tbody>
					<%
					}
					%>
				
				</table>
				
				<br />				
				<%}%>
				
				<%				
				if( al_cashout_suspect_recon.size()!=0 ){
				System.out.println("DEBUG|Print Cashout Recon Transaksi Cashout Suspect");
				%>
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> == RECON == Jumlah Transaksi Cashout Berhasil di TCASH, Suspect di RPT Details </strong></font></div>
				
				<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
					<thead>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No. </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br /> Time </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Terminal <br /> Receipt </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trans Card<br /> ABA NBR BR NBR </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Card Acct <br /> Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Card <br /> MBR </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trans <br /> BR NBR </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Account <br /> Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br /> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trans <br /> Amount </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Result <br /> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trm <br /> NBR </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Destination <br /> Acct NBR </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Aba <br /> Dest </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trace <br /> Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Retrieval <br /> Ref NBR </strong></font></div></td>
					</thead>
				
					<%
					no_idx = 1;
					for(int i=0;i<al_cashout_suspect_recon.size();i++){
					%>
						<tbody>
						<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=no_idx%> </font></div></td>
						<%
							for(int j=0;j<15;j++){
								if(j==8){
						%>
						<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=(get_decimal(al_cashout_suspect_recon.get(i)[j]))%> </font></div></td>
						<%
								}else{
									%>
						<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashout_suspect_recon.get(i)[j]%> </font></div></td>			
									<%
								}
							}
						%>
						</tbody>
					<%
					no_idx++;
					}
					%>
				</table>
				
				<br />				
				<%}%>
				
				
				<%
				// ================================================================================================================================================
				%>
				
				
				<%
				if(!index_recon_db.equals("")){
				System.out.println("DEBUG|Print Cashin Recon Transaksi Cashin RPT dan DB yg Bersesuaian");
				%>
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> == RECON == Transaksi Cashin di RPT dan TCash yang bersesuaian  </strong></font></div>
				
				<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
					<thead>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No.<br />Log </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No.<br />RPT </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br /> Time </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Acct Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br/> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran Amount </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Result<br /> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran Date </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Issuer/Source<br />Card Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Aba <br />Issuer/Source </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trace Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Retrieval <br /> Ref Number </strong></font></div></td>
					</thead>
				
				<%
				
					for(int i=0;i<index_recon_db_array.length;i++){
					%>
					<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=Integer.parseInt(index_recon_db_array[i])+1%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=Integer.parseInt(index_recon_al_array[i])+1%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_recon_db_array[i]))[0]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_recon_db_array[i]))[1]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_recon_db_array[i]))[2]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_recon_db_array[i]))[3]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_recon_db_array[i]))[4]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_recon_db_array[i]))[5]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_recon_db_array[i]))[6]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_recon_db_array[i]))[7]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_recon_db_array[i]))[8]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_recon_db_array[i]))[9]%> </font></div></td>
					</tbody>
					<%
					}
				%>
				</table>
				
				<br />
				<%}%>
				
				<%
				if(!index_rec_db.equals("")){				
				System.out.println("DEBUG|Print Cashin Recon Cashin Investigasi DB TCash");
				%>
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> == RECON == Transaksi Cashin Ada di Transaksi Berhasil TCash, tidak ada di RPT </strong></font></div>
				<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
					<thead>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No. </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br /> Time </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Acct Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br/> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran Amount </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Result<br /> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran Date </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Issuer/Source<br />Card Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Aba <br />Issuer/Source </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trace Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Retrieval <br /> Ref Number </strong></font></div></td>
					</thead>
				
				<%
					for(int i=0;i<index_rec_db_array.length;i++){
					%>
					<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=Integer.parseInt(index_rec_db_array[i])+1%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_rec_db_array[i]))[0]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_rec_db_array[i]))[1]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_rec_db_array[i]))[2]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_rec_db_array[i]))[3]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_rec_db_array[i]))[4]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_rec_db_array[i]))[5]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_rec_db_array[i]))[6]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_rec_db_array[i]))[7]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_rec_db_array[i]))[8]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_rec_db_array[i]))[9]%> </font></div></td>
					</tbody>
				<%
					}
				
				%>
				</table>
				
				<br />
				
				<%}%>
				
				<%
				if(!index_rec_al.equals("")){				
				System.out.println("DEBUG|Print Cashin Recon Cashin Investigasi RPT");
				%>
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> == RECON == Transaksi Cashin Ada di RPT, tapi tidak ada di TCash </strong></font></div>
				<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
					<thead>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No. </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br /> Time </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Acct Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br/> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran Amount </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Result<br /> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran Date </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Issuer/Source<br />Card Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Aba <br />Issuer/Source </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trace Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Retrieval <br /> Ref Number </strong></font></div></td>
					</thead>
				
				<%
					for(int i=0;i<index_rec_al_array.length;i++){
					%>
					<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=Integer.parseInt(index_rec_al_array[i])+1%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_berhasil.get(Integer.parseInt(index_rec_al_array[i]))[0]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_berhasil.get(Integer.parseInt(index_rec_al_array[i]))[1]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_berhasil.get(Integer.parseInt(index_rec_al_array[i]))[2]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_berhasil.get(Integer.parseInt(index_rec_al_array[i]))[3]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_berhasil.get(Integer.parseInt(index_rec_al_array[i]))[4]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_berhasil.get(Integer.parseInt(index_rec_al_array[i]))[9]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_berhasil.get(Integer.parseInt(index_rec_al_array[i]))[10]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_berhasil.get(Integer.parseInt(index_rec_al_array[i]))[11]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_berhasil.get(Integer.parseInt(index_rec_al_array[i]))[12]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_berhasil.get(Integer.parseInt(index_rec_al_array[i]))[13]%> </font></div></td>
					</tbody>
				<%
					}
				
				%>
				</table>
				
				<br />				
				<%}%>
				
				<%				
				if( al_cashin_suspect_recon.size()!=0 ){
				System.out.println("DEBUG|Print Cashin Recon Transaksi Cashin Suspect");
				%>
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> == RECON == Jumlah Transaksi Cashin Berhasil di TCASH, Suspect di RPT Details (Klaim Suspect) </strong></font></div>
				
				<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
					<thead>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No. </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br /> Time </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Acct Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br/> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran Amount </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Result<br /> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran Date </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Issuer/Source<br />Card Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Aba <br />Issuer/Source </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trace Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Retrieval <br /> Ref Number </strong></font></div></td>
					</thead>
				
				<%
				no_idx = 1;
				for(int i=0;i<al_cashin_suspect_recon.size();i++){
					%>
					<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=no_idx%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_suspect_recon.get(i)[0]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_suspect_recon.get(i)[1]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_suspect_recon.get(i)[2]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(al_cashin_suspect_recon.get(i)[3])%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_suspect_recon.get(i)[4]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_suspect_recon.get(i)[9]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_suspect_recon.get(i)[10]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_suspect_recon.get(i)[11]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_suspect_recon.get(i)[12]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_suspect_recon.get(i)[13]%> </font></div></td>
					</tbody>
					<%
				no_idx++;
				}
				%>
				</table>
				
				<br />				
				<%}%>
				
				
				<%
				if( al_claim_berhasil_ada.size()!=0 ){
				System.out.println("DEBUG|Print Cashin Recon Klaim Berhasil Ada");
				%>
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> == RECON == Klaim Berhasil yang ada di TCash (Klaim Berhasil) </strong></font></div>
				
				<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
					<thead>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No. </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Jenis </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No Kartu </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No Resi </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Dasar Setoran </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tanggal Transaksi </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Jam Transaksi </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Terminal ID </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Nominal </strong></font></div></td>
					</thead>
				
				<%
				no_idx = 1;
				for(int i=0;i<al_claim_berhasil_ada.size();i++){
					%>
					<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=no_idx%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_claim_berhasil_ada.get(i)[0]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_claim_berhasil_ada.get(i)[1]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_claim_berhasil_ada.get(i)[2]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_claim_berhasil_ada.get(i)[3]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_claim_berhasil_ada.get(i)[4]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_claim_berhasil_ada.get(i)[5]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_claim_berhasil_ada.get(i)[6]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(al_claim_berhasil_ada.get(i)[7])%> </font></div></td>
					</tbody>
					<%
				no_idx++;
				}
				%>
				</table>
								
				<br />				
				<%}%>
				
				<%			
				if( al_claim_berhasil_tidakada.size()!=0 ){
				System.out.println("DEBUG|Print Recon Klaim Berhasil Tidak Ada");
				%>
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> == RECON == Klaim Berhasil yang tidak ada di TCash (Klaim Berhasil) </strong></font></div>
				
				<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
					<thead>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No. </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Jenis </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No Kartu </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No Resi </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Dasar Setoran </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tanggal Transaksi </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Jam Transaksi </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Terminal ID </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Nominal </strong></font></div></td>
					</thead>
				
				<%
				no_idx = 1;
				for(int i=0;i<al_claim_berhasil_tidakada.size();i++){
					%>
					<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=no_idx%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_claim_berhasil_tidakada.get(i)[0]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_claim_berhasil_tidakada.get(i)[1]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_claim_berhasil_tidakada.get(i)[2]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_claim_berhasil_tidakada.get(i)[3]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_claim_berhasil_tidakada.get(i)[4]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_claim_berhasil_tidakada.get(i)[5]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_claim_berhasil_tidakada.get(i)[6]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(al_claim_berhasil_tidakada.get(i)[7])%> </font></div></td>
					</tbody>
					<%
				no_idx++;
				}
				%>
				</table>
				
				<br />
				<%}%>
				
				<%
				// ================================================================================================================================================
				%>
				
				<%
				System.out.println("DEBUG|Print Hidden input form");
				// print the hidden input for that merchant deposit
				%>
				<form action='uploadArtajasaRPT.jsp' method='post'>					
					
					<%
					/*
					Yang dimasukkan dalam recon cashout detail adalah:
					1. Suspect Gagal : cashout_suspect_gagal
					2. Suspect Berhasil : cashout_suspect_berhasil
					3. Suspect Suspect : cashout_suspect_suspect
					*/					
					%>
					
					<%
					for(int i=0;i<cashout_suspect_gagal.size();i++){
					%>
						<input type='hidden' name='csgag_tran_time' value='<%=cashout_suspect_gagal.get(i)[0]%>'>
						<input type='hidden' name='csgag_acct_number' value='<%=cashout_suspect_gagal.get(i)[1]%>'>
						<input type='hidden' name='csgag_tran_code' value='<%=cashout_suspect_gagal.get(i)[2]%>'>
						<input type='hidden' name='csgag_tran_amount' value='<%=cashout_suspect_gagal.get(i)[3]%>'>
						<input type='hidden' name='csgag_result_code' value='<%=cashout_suspect_gagal.get(i)[4]%>'>
						<input type='hidden' name='csgag_iso_date' value='<%=cashout_suspect_gagal.get(i)[5]%>'>
						<input type='hidden' name='csgag_pan_code' value='<%=cashout_suspect_gagal.get(i)[6]%>'>
						<input type='hidden' name='csgag_bank_code' value='<%=cashout_suspect_gagal.get(i)[7]%>'>
						<input type='hidden' name='csgag_trace_number' value='<%=cashout_suspect_gagal.get(i)[8]%>'>
						<input type='hidden' name='csgag_ref_number' value='<%=cashout_suspect_gagal.get(i)[9]%>'>
					<%}%>
					
					<%
					for(int i=0;i<cashout_suspect_berhasil.size();i++){
					%>
						<input type='hidden' name='csber_tran_time' value='<%=cashout_suspect_berhasil.get(i)[0]%>'>
						<input type='hidden' name='csber_acct_number' value='<%=cashout_suspect_berhasil.get(i)[1]%>'>
						<input type='hidden' name='csber_tran_code' value='<%=cashout_suspect_berhasil.get(i)[2]%>'>
						<input type='hidden' name='csber_tran_amount' value='<%=cashout_suspect_berhasil.get(i)[3]%>'>
						<input type='hidden' name='csber_result_code' value='<%=cashout_suspect_berhasil.get(i)[4]%>'>
						<input type='hidden' name='csber_iso_date' value='<%=cashout_suspect_berhasil.get(i)[5]%>'>
						<input type='hidden' name='csber_pan_code' value='<%=cashout_suspect_berhasil.get(i)[6]%>'>
						<input type='hidden' name='csber_bank_code' value='<%=cashout_suspect_berhasil.get(i)[7]%>'>
						<input type='hidden' name='csber_trace_number' value='<%=cashout_suspect_berhasil.get(i)[8]%>'>
						<input type='hidden' name='csber_ref_number' value='<%=cashout_suspect_berhasil.get(i)[9]%>'>
					<%}%>
					
					<%
					for(int i=0;i<cashout_suspect_suspect.size();i++){
					%>
						<input type='hidden' name='cssus_tran_time' value='<%=cashout_suspect_suspect.get(i)[0]%>'>
						<input type='hidden' name='cssus_acct_number' value='<%=cashout_suspect_suspect.get(i)[1]%>'>
						<input type='hidden' name='cssus_tran_code' value='<%=cashout_suspect_suspect.get(i)[2]%>'>
						<input type='hidden' name='cssus_tran_amount' value='<%=cashout_suspect_suspect.get(i)[3]%>'>
						<input type='hidden' name='cssus_result_code' value='<%=cashout_suspect_suspect.get(i)[4]%>'>
						<input type='hidden' name='cssus_iso_date' value='<%=cashout_suspect_suspect.get(i)[5]%>'>
						<input type='hidden' name='cssus_pan_code' value='<%=cashout_suspect_suspect.get(i)[6]%>'>
						<input type='hidden' name='cssus_bank_code' value='<%=cashout_suspect_suspect.get(i)[7]%>'>
						<input type='hidden' name='cssus_trace_number' value='<%=cashout_suspect_suspect.get(i)[8]%>'>
						<input type='hidden' name='cssus_ref_number' value='<%=cashout_suspect_suspect.get(i)[9]%>'>
					<%}	%>
					
					<%
					if(!index_rec_al2.equals("")){
						for(int i=0;i<index_rec_al_array2.length;i++){
					%>
					<input type='hidden' name='al_tran_time2' value='<%=al_cashout_berhasil.get(Integer.parseInt(index_rec_al_array2[i]))[0]%>'>
					<input type='hidden' name='al_acct_number2' value='<%=al_cashout_berhasil.get(Integer.parseInt(index_rec_al_array2[i]))[6]%>'>
					<input type='hidden' name='al_tran_code2' value='<%=al_cashout_berhasil.get(Integer.parseInt(index_rec_al_array2[i]))[7]%>'>
					<input type='hidden' name='al_tran_amount2' value='<%=al_cashout_berhasil.get(Integer.parseInt(index_rec_al_array2[i]))[8]%>'>
					<input type='hidden' name='al_result_code2' value='<%=al_cashout_berhasil.get(Integer.parseInt(index_rec_al_array2[i]))[9]%>'>
					<input type='hidden' name='al_iso_date2' value='<%=cashout_date.get(0)%>'>
					<input type='hidden' name='al_pan_code2' value='<%=al_cashout_berhasil.get(Integer.parseInt(index_rec_al_array2[i]))[3]%>'>
					<input type='hidden' name='al_bank_code2' value='<%=al_cashout_berhasil.get(Integer.parseInt(index_rec_al_array2[i]))[12]%>'>
					<input type='hidden' name='al_trace_number2' value='<%=al_cashout_berhasil.get(Integer.parseInt(index_rec_al_array2[i]))[13]%>'>
					<input type='hidden' name='al_ref_number2' value='<%=al_cashout_berhasil.get(Integer.parseInt(index_rec_al_array2[i]))[14]%>'>
					<%
						}
					}
					%>
					
					<%
					if(!index_rec_db2.equals("")){
						for(int i=0;i<index_rec_db_array2.length;i++){
					%>
					<input type='hidden' name='db_tran_time2' value='<%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_rec_db_array2[i]))[0]%>'>
					<input type='hidden' name='db_acct_number2' value='<%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_rec_db_array2[i]))[1]%>'>
					<input type='hidden' name='db_tran_code2' value='<%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_rec_db_array2[i]))[2]%>'>
					<input type='hidden' name='db_tran_amount2' value='<%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_rec_db_array2[i]))[3]%>'>
					<input type='hidden' name='db_result_code2' value='<%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_rec_db_array2[i]))[4]%>'>
					<input type='hidden' name='db_iso_date2' value='<%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_rec_db_array2[i]))[5]%>'>
					<input type='hidden' name='db_pan_code2' value='<%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_rec_db_array2[i]))[6]%>'>
					<input type='hidden' name='db_bank_code2' value='<%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_rec_db_array2[i]))[7]%>'>
					<input type='hidden' name='db_trace_number2' value='<%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_rec_db_array2[i]))[8]%>'>
					<input type='hidden' name='db_ref_number2' value='<%=db_cashout_berhasil_bersih.get(Integer.parseInt(index_rec_db_array2[i]))[9]%>'>
					<%
						}
					}
					%>
					
					<%
					for(int i=0;i<al_cashout_suspect_recon.size();i++){
					%>
					<input type='hidden' name='r_tran_time2' value='<%=al_cashout_suspect_recon.get(i)[0]%>'>
					<input type='hidden' name='r_acct_number2' value='<%=al_cashout_suspect_recon.get(i)[6]%>'>
					<input type='hidden' name='r_tran_code2' value='<%=al_cashout_suspect_recon.get(i)[7]%>'>
					<input type='hidden' name='r_tran_amount2' value='<%=al_cashout_suspect_recon.get(i)[8]%>'>
					<input type='hidden' name='r_result_code2' value='<%=al_cashout_suspect_recon.get(i)[9]%>'>
					<input type='hidden' name='r_iso_date2' value='<%=cashout_date.get(0)%>'>
					<input type='hidden' name='r_pan_code2' value='<%=al_cashout_suspect_recon.get(i)[3]%>'>
					<input type='hidden' name='r_bank_code2' value='<%=al_cashout_suspect_recon.get(i)[12]%>'>
					<input type='hidden' name='r_trace_number2' value='<%=al_cashout_suspect_recon.get(i)[13]%>'>
					<input type='hidden' name='r_ref_number2' value='<%=al_cashout_suspect_recon.get(i)[14]%>'>
					<%}%>
					
										
					<%
					// ===================================================================================================
					/*
					Yang dimasukkan dalam recon cashin detail adalah:
					1. Klaim Suspect : al_cashin_suspect_recon
					2. Klaim Berhasil_ada : al_claim_berhasil_ada
					
					3. Klaim Berhasil_tidakada : al_claim_berhasil_tidakada
					4. Data Recon Cashin Kelebihan di RPT : index_rec_al_array 
					5. Data Recon Cashin Kelebihan di TCash DB : index_rec_db_array
					*/					
					// ===================================================================================================
					
					for(int i=0;i<al_cashin_suspect_recon.size();i++){
					%>
					<input type='hidden' name='r_tran_time' value='<%=al_cashin_suspect_recon.get(i)[0]%>'>
					<input type='hidden' name='r_acct_number' value='<%=al_cashin_suspect_recon.get(i)[1]%>'>
					<input type='hidden' name='r_tran_code' value='<%=al_cashin_suspect_recon.get(i)[2]%>'>
					<input type='hidden' name='r_tran_amount' value='<%=al_cashin_suspect_recon.get(i)[3]%>'>
					<input type='hidden' name='r_result_code' value='<%=al_cashin_suspect_recon.get(i)[4]%>'>
					<input type='hidden' name='r_iso_date' value='<%=al_cashin_suspect_recon.get(i)[9]%>'>
					<input type='hidden' name='r_pan_code' value='<%=al_cashin_suspect_recon.get(i)[10]%>'>
					<input type='hidden' name='r_bank_code' value='<%=al_cashin_suspect_recon.get(i)[11]%>'>
					<input type='hidden' name='r_trace_number' value='<%=al_cashin_suspect_recon.get(i)[12]%>'>
					<input type='hidden' name='r_ref_number' value='<%=al_cashin_suspect_recon.get(i)[13]%>'>
					<%}%>
					
					<%
					for(int i=0;i<al_claim_berhasil_ada.size();i++){
					%>
					<input type='hidden' name='KB_ada_jenis' value='<%=al_claim_berhasil_ada.get(i)[0]%>'>
					<input type='hidden' name='KB_ada_kartu' value='<%=al_claim_berhasil_ada.get(i)[1]%>'>
					<input type='hidden' name='KB_ada_resi' value='<%=al_claim_berhasil_ada.get(i)[2]%>'>
					<input type='hidden' name='KB_ada_setoran' value='<%=al_claim_berhasil_ada.get(i)[3]%>'>
					<input type='hidden' name='KB_ada_tanggal' value='<%=al_claim_berhasil_ada.get(i)[4]%>'>
					<input type='hidden' name='KB_ada_jam' value='<%=al_claim_berhasil_ada.get(i)[5]%>'>
					<input type='hidden' name='KB_ada_terminal' value='<%=al_claim_berhasil_ada.get(i)[6]%>'>
					<input type='hidden' name='KB_ada_nominal' value='<%=al_claim_berhasil_ada.get(i)[7]%>'>
					<%}%>
					
					<%
					for(int i=0;i<al_claim_berhasil_tidakada.size();i++){
					%>
					<input type='hidden' name='KB_tidak_jenis' value='<%=al_claim_berhasil_tidakada.get(i)[0]%>'>
					<input type='hidden' name='KB_tidak_kartu' value='<%=al_claim_berhasil_tidakada.get(i)[1]%>'>
					<input type='hidden' name='KB_tidak_resi' value='<%=al_claim_berhasil_tidakada.get(i)[2]%>'>
					<input type='hidden' name='KB_tidak_setoran' value='<%=al_claim_berhasil_tidakada.get(i)[3]%>'>
					<input type='hidden' name='KB_tidak_tanggal' value='<%=al_claim_berhasil_tidakada.get(i)[4]%>'>
					<input type='hidden' name='KB_tidak_jam' value='<%=al_claim_berhasil_tidakada.get(i)[5]%>'>
					<input type='hidden' name='KB_tidak_terminal' value='<%=al_claim_berhasil_tidakada.get(i)[6]%>'>
					<input type='hidden' name='KB_tidak_nominal' value='<%=al_claim_berhasil_tidakada.get(i)[7]%>'>
					<%}%>
					
					<%
					if(!index_rec_al.equals("")){
						for(int i=0;i<index_rec_al_array.length;i++){
					%>
					<input type='hidden' name='al_tran_time' value='<%=al_cashin_berhasil.get(Integer.parseInt(index_rec_al_array[i]))[0]%>'>
					<input type='hidden' name='al_acct_number' value='<%=al_cashin_berhasil.get(Integer.parseInt(index_rec_al_array[i]))[1]%>'>
					<input type='hidden' name='al_tran_code' value='<%=al_cashin_berhasil.get(Integer.parseInt(index_rec_al_array[i]))[2]%>'>
					<input type='hidden' name='al_tran_amount' value='<%=al_cashin_berhasil.get(Integer.parseInt(index_rec_al_array[i]))[3]%>'>
					<input type='hidden' name='al_result_code' value='<%=al_cashin_berhasil.get(Integer.parseInt(index_rec_al_array[i]))[4]%>'>
					<input type='hidden' name='al_iso_date' value='<%=al_cashin_berhasil.get(Integer.parseInt(index_rec_al_array[i]))[9]%>'>
					<input type='hidden' name='al_pan_code' value='<%=al_cashin_berhasil.get(Integer.parseInt(index_rec_al_array[i]))[10]%>'>
					<input type='hidden' name='al_bank_code' value='<%=al_cashin_berhasil.get(Integer.parseInt(index_rec_al_array[i]))[11]%>'>
					<input type='hidden' name='al_trace_number' value='<%=al_cashin_berhasil.get(Integer.parseInt(index_rec_al_array[i]))[12]%>'>
					<input type='hidden' name='al_ref_number' value='<%=al_cashin_berhasil.get(Integer.parseInt(index_rec_al_array[i]))[13]%>'>
					<%
						}
					}
					%>
					
					<%
					if(!index_rec_db.equals("")){
						for(int i=0;i<index_rec_db_array.length;i++){
					%>
					<input type='hidden' name='db_tran_time' value='<%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_rec_db_array[i]))[0]%>'>
					<input type='hidden' name='db_acct_number' value='<%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_rec_db_array[i]))[1]%>'>
					<input type='hidden' name='db_tran_code' value='<%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_rec_db_array[i]))[2]%>'>
					<input type='hidden' name='db_tran_amount' value='<%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_rec_db_array[i]))[3]%>'>
					<input type='hidden' name='db_result_code' value='<%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_rec_db_array[i]))[4]%>'>
					<input type='hidden' name='db_iso_date' value='<%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_rec_db_array[i]))[5]%>'>
					<input type='hidden' name='db_pan_code' value='<%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_rec_db_array[i]))[6]%>'>
					<input type='hidden' name='db_bank_code' value='<%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_rec_db_array[i]))[7]%>'>
					<input type='hidden' name='db_trace_number' value='<%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_rec_db_array[i]))[8]%>'>
					<input type='hidden' name='db_ref_number' value='<%=db_cashin_berhasil_bersih.get(Integer.parseInt(index_rec_db_array[i]))[9]%>'>
					<%
						}
					}
					%>
					
					<input type="hidden" name="idLog1" value="<%=(encLog.equals(""))?encLogP:encLog%>">
					<input type="hidden" name="idLog2" value="<%=(encPass.equals(""))?encPassP:encPass%>">
					
					<input type="hidden" name="reconed" value="1">
					
					<%
					for(int i=0;i<cashout_date.size();i++){
					%>
					<input type="hidden" name="tanggal_laporan" value="<%=cashout_date.get(i)%>">	
					<%
					}
					%> 
					
					<%
					for(int i=0;i<cashin_date.size();i++){
					%>
					<input type="hidden" name="tanggal_laporan" value="<%=cashin_date.get(i)%>">	
					<%
					}
					%> 
					
					<input type='submit' value='Recon' onclick='return checkExecute2();'>
					<%// check if there is claim%>
					
				</form>
				
				<hr />
				
				<%	
// =========================================================================
// print Database
				System.out.println("DEBUG|Print RPT Cashin Berhasil");
				%>
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Report Database - TCash </strong></font></div><br /><br />
				
				
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Transaksi Cashin Berhasil di Database Tcash </strong></font></div>
				
				<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
					<thead>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No. </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br /> Time </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Acct Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br/> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran Amount </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Result<br /> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran Date </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Issuer/Source<br />Card Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Aba <br />Issuer/Source </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trace Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Retrieval <br /> Ref Number </strong></font></div></td>
					</thead>
				
				<%
				no_idx = 1;
				for(int i=0;i<db_cashin_berhasil.size();i++){
					%>
					<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=no_idx%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil.get(i)[0]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil.get(i)[1]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil.get(i)[2]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(db_cashin_berhasil.get(i)[3])%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil.get(i)[4]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil.get(i)[5]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil.get(i)[6]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil.get(i)[7]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil.get(i)[8]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashin_berhasil.get(i)[9]%> </font></div></td>
					</tbody>
					<%
				no_idx++;
				}
				
				System.out.println("DEBUG|Print DB Cashout Berhasil");
				%>
				</table>
								
				<br />
				
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Transaksi Cashout Berhasil di Database Tcash </strong></font></div>
				
				<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
					<thead>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No. </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br /> Time </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Acct Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br/> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran Amount </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Result<br /> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran Date </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Issuer/Source<br />Card Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Aba <br />Issuer/Source </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trace Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Retrieval <br /> Ref Number </strong></font></div></td>
					</thead>
				
				<%
				no_idx = 1;
				for(int i=0;i<db_cashout_berhasil.size();i++){
					%>
					<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=no_idx%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil.get(i)[0]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil.get(i)[1]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil.get(i)[2]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(db_cashout_berhasil.get(i)[3])%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil.get(i)[4]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil.get(i)[5]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil.get(i)[6]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil.get(i)[7]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil.get(i)[8]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_berhasil.get(i)[9]%> </font></div></td>
					</tbody>
					<%
				no_idx++;
				}
				
				System.out.println("DEBUG|Print DB Cashout Suspect");
				%>
				</table>
				
				<br />
				
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Transaksi Cashout Suspect di Database Tcash </strong></font></div>
				
				<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
					<thead>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No. </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br /> Time </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Acct Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br/> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran Amount </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Result<br /> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran Date </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Issuer/Source<br />Card Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Aba <br />Issuer/Source </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trace Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Retrieval <br /> Ref Number </strong></font></div></td>
					</thead>
				
				<%
				no_idx = 1;
				for(int i=0;i<db_cashout_suspect.size();i++){
					%>
					<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=no_idx%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_suspect.get(i)[0]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_suspect.get(i)[1]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_suspect.get(i)[2]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(db_cashout_suspect.get(i)[3])%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_suspect.get(i)[4]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_suspect.get(i)[5]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_suspect.get(i)[6]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_suspect.get(i)[7]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_suspect.get(i)[8]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_cashout_suspect.get(i)[9]%> </font></div></td>
					</tbody>
					<%
				no_idx++;
				}
				
				System.out.println("DEBUG|Print DB Cashout suspect");
				%>
				</table>
				
				<br />
				<hr />
				
				<%
// =========================================================================
// print RPT
				System.out.println("DEBUG|Printing RPT Detail|");
				%>
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Report RPT - Artajasa </strong></font></div><br /><br />
				
				<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
				<thead>
					<td colspan="3"><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Summary Cashout - RPT </strong></font></div></td>
				</thead>
				<tbody>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Cashout total approved </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_total_approved%> </font></div></td>
				</tbody>
				<tbody>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Cashout total declined </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_total_declined%> </font></div></td>
				</tbody>
				<tbody>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Cashout total declined charge </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_total_declined_charge%> </font></div></td>
				</tbody>
				<tbody>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Cashout total autoreq approved </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_total_autoreq_approved%> </font></div></td>
				</tbody>
				<tbody>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Cashout total autoreq declined </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_total_autoreq_declined%> </font></div></td>
				</tbody>
				<tbody>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Cashout total transactions </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_total_transactions%> </font></div></td>
				</tbody>
				<tbody>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Cashout total switched </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_total_switched%> </font></div></td>
				</tbody>
				<tbody>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Cashout total offline </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashout_total_offline%> </font></div></td>
				</tbody>
				<tbody>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Cashout total nominal </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=(get_decimal(cashout_total_nominal))%> </font></div></td>
				</tbody>
				</table>
				
				<br />
				
				<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
				<thead>
					<td colspan="3"><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Summary Cashin - RPT </strong></font></div></td>
				</thead>
				<tbody>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Cashin total approved </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashin_total_approved%> </font></div></td>
				</tbody>
				<tbody>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Cashin total declined </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashin_total_declined%> </font></div></td>
				</tbody>
				<tbody>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Cashin total autoreq approved </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashin_total_autoreq_approved%> </font></div></td>
				</tbody>
				<tbody>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Cashin total autoreq declined </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashin_total_autoreq_declined%> </font></div></td>
				</tbody>
				<tbody>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Cashin total transactions </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashin_total_transactions%> </font></div></td>
				</tbody>
				<tbody>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Cashin total switchedin </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=cashin_total_switchedin%> </font></div></td>
				</tbody>
				<tbody>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Cashin total nominal </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
					<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=(get_decimal(cashin_total_nominal))%> </font></div></td>
				</tbody>
				</table>
				
				<%//System.out.println("DEBUG|Print Cashout Details");%>
				<br /><br />
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Cashout Details </strong></font></div>
				<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
					<thead>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No. </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br /> Time </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Terminal <br /> Receipt </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trans Card<br /> ABA NBR BR NBR </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Card Acct <br /> Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Card <br /> MBR </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trans <br /> BR NBR </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Account <br /> Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br /> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trans <br /> Amount </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Result <br /> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trm <br /> NBR </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Destination <br /> Acct NBR </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Aba <br /> Dest </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trace <br /> Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Retrieval <br /> Ref NBR </strong></font></div></td>
					</thead>
					
					<%
					int count = 1;
					for(int i=0;i<al_cashout.size();i++){
						%>
						<tbody>
						<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=count%> </font></div></td>
						<%
							for(int j=0;j<15;j++){
								if(j==8){
						%>
						<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=(get_decimal(al_cashout.get(i)[j]))%> </font></div></td>
						<%
								}else{
									%>
						<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashout.get(i)[j]%> </font></div></td>			
									<%
								}
							}
						%>
						</tbody>
						<%
						count++;
					}
					%>
					<tbody><td colspan="16"><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Cashout Suspect </strong></font></div></td></tbody>
					<%
					count = 1;
					for(int i=0;i<al_cashout_suspect.size();i++){
						%>
						<tbody>
						<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=count%> </font></div></td>
						<%
							for(int j=0;j<15;j++){
								if(j==8){
						%>
						<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=(get_decimal(al_cashout_suspect.get(i)[j]))%> </font></div></td>
						<%
								}else{
									%>
						<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashout_suspect.get(i)[j]%> </font></div></td>			
									<%
								}
							}
						%>
						</tbody>
						<%
						count++;
					}
					%>
				</table>
				<br />
				
				<%
				System.out.println("DEBUG|Print RPT Cashout Berhasil");				
				%>
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Transaksi Cashout Berhasil di RPT Details </strong></font></div>
				<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
					<thead>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No. </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br /> Time </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Terminal <br /> Receipt </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trans Card<br /> ABA NBR BR NBR </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Card Acct <br /> Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Card <br /> MBR </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trans <br /> BR NBR </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Account <br /> Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br /> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trans <br /> Amount </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Result <br /> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trm <br /> NBR </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Destination <br /> Acct NBR </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Aba <br /> Dest </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trace <br /> Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Retrieval <br /> Ref NBR </strong></font></div></td>
					</thead>
					
					<%
					no_idx = 1;
					for(int i=0;i<al_cashout_berhasil.size();i++){
						%>
						<tbody>
						<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=no_idx%> </font></div></td>
						<%
							for(int j=0;j<15;j++){
								if(j==8){
						%>
						<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=(get_decimal(al_cashout_berhasil.get(i)[j]))%> </font></div></td>
						<%
								}else{
									%>
						<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashout_berhasil.get(i)[j]%> </font></div></td>			
									<%
								}
							}
						%>
						</tbody>
						<%
						no_idx++;
					}
					%>
				</table>
				
				<br />
				<%%>
				
				<br /><br />
				<%//System.out.println("DEBUG|Print Cashin Details");%>
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Cashin Details </strong></font></div>
				<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
					<thead>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No. </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br /> Time </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Acct <br /> Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br /> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br /> Amount </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Result <br /> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Terminal <br /> Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Aba <br /> Terminal </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> SWT <br /> Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Terminal <br /> Receipt </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br /> Date </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Issuer/Source<br />Card Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Aba <br /> Issuer/Source </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trace <br /> Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Retrieval <br /> Ref Number </strong></font></div></td>
					</thead>

					<%
					count=1;
					for(int i=0;i<al_cashin.size();i++){
						%>
						<tbody>
						<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=count%> </font></div></td>
						<%
							for(int j=0;j<14;j++){
								if(j==3){
								%>
								<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=(get_decimal(al_cashin.get(i)[j]))%> </font></div></td>
								<%
								}else{
								%>
								<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin.get(i)[j]%> </font></div></td>
								<%	
								}
							}
						%>
						</tbody>
						<%
						count++;
					}
					%>
					<tbody><td colspan="15"><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Cashin Suspect </strong></font></div></td></tbody>
					<%
					count=1;
					for(int i=0;i<al_cashin_suspect.size();i++){
						%>
						<tbody>
						<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=count%> </font></div></td>
						<%
							for(int j=0;j<14;j++){
								if(j==3){
								%>
								<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=(get_decimal(al_cashin_suspect.get(i)[j]))%> </font></div></td>
								<%
								}else{
								%>
								<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_suspect.get(i)[j]%> </font></div></td>
								<%	
								}
							}
						%>
						</tbody>
						<%
						count++;
					}
					%>
				</table>
				
				<br />
				<%
				System.out.println("DEBUG|Print RPT Cashin Berhasil");				
				%>
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Transaksi Cashin Berhasil di RPT Details </strong></font></div>
				
				<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
					<thead>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No. </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br /> Time </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Acct Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran <br/> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran Amount </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Result<br /> Code </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tran Date </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Issuer/Source<br />Card Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Aba <br />Issuer/Source </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Trace Number </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Retrieval <br /> Ref Number </strong></font></div></td>
					</thead>
				
				<%
				no_idx = 1;
				for(int i=0;i<al_cashin_berhasil.size();i++){
					%>
					<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=no_idx%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_berhasil.get(i)[0]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_berhasil.get(i)[1]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_berhasil.get(i)[2]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(al_cashin_berhasil.get(i)[3])%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_berhasil.get(i)[4]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_berhasil.get(i)[9]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_berhasil.get(i)[10]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_berhasil.get(i)[11]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_berhasil.get(i)[12]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_cashin_berhasil.get(i)[13]%> </font></div></td>
					</tbody>
					<%
				no_idx++;
				}
				%>
				</table>
				
				<br />
				<%%>
				
				<br /><br />
				<%//System.out.println("DEBUG|Print Claim Details");%>
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Claim Berhasil </strong></font></div>
				<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
					<thead>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No. </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Jenis </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No Kartu </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No Resi </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Dasar <br /> Setoran </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tanggal  <br /> Transaksi </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Jam <br /> Transaksi </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Terminal <br /> ID </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Nominal </strong></font></div></td>
					</thead>

					<%
					count=1;
					for(int i=0;i<al_claim_berhasil.size();i++){
						%>
						<tbody>
						<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=count%> </font></div></td>
						<%
							for(int j=0;j<8;j++){
								if(j==7){
								%>
								<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=(get_decimal(al_claim_berhasil.get(i)[j]))%> </font></div></td>
								<%
								}else{
								%>
								<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_claim_berhasil.get(i)[j]%> </font></div></td>
								<%	
								}
							}
						%>
						</tbody>
						<%
						count++;
					}
					%>
				</table>

				<br /><br />
				<%//System.out.println("DEBUG|Print Claim Solved Details");%>
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Claim Suspect Solved </strong></font></div>
				<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
					<thead>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No. </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Jenis </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No Kartu </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No Resi </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Dasar <br /> Setoran </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tanggal  <br /> Transaksi </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Jam <br /> Transaksi </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Terminal <br /> ID </strong></font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Nominal </strong></font></div></td>
					</thead>

					<%
					count=1;
					for(int i=0;i<al_claim_suspect.size();i++){
						%>
						<tbody>
						<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=count%> </font></div></td>
						<%
							for(int j=0;j<8;j++){
								if(j==7){
								%>
								<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=(get_decimal(al_claim_suspect.get(i)[j]))%> </font></div></td>
								<%
								}else{
								%>
								<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=al_claim_suspect.get(i)[j]%> </font></div></td>
								<%	
								}
							}
						%>
						</tbody>
						<%
						count++;
					}
					%>
				</table>

				<br /><br />
				<%//System.out.println("DEBUG|Print Nota kredit Details");%>
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Nota Kredit Details </strong></font></div>
				<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
					<thead>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No. </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Bank </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> ABA/BR </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Nominal <br /> Penarikan </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Nominal <br /> Transfer </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Nominal <br /> Purchase </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Fee </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Klaim/Denda </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Total 1 </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Jml <br /> Penarikan </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Fee <br /> Penarikan </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Jml <br /> Others </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Fee <br /> Others </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Jml Pemilik <br /> Terminal </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Fee Pemilik <br /> Terminal </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Jml <br /> Tujuan </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Fee <br /> Tujuan </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Jml Declined <br /> Transaction </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Fee Declined <br /> Transaction </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Jml Fee <br /> Purchased </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Fee Purchased </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Jml <br /> Total 2 </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Total 2 </strong></font></div></td>
					</thead>

					<%
					count=1;
					for(int i=0;i<nota_kredit.size();i++){
						%>
						<tbody>
						<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=count%> </font></div></td>
						<%
							for(int j=0;j<22;j++){
								if(j==2 || j==3 || j==4 || j==5 || j==6 || j==7 || j==9 || j==11 || j==13 || j==15 || j==17 || j==19 || j==21){
								%>
								<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=(get_decimal(nota_kredit.get(i)[j]))%> </font></div></td>
								<%
								}else{
								%>
								<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=nota_kredit.get(i)[j]%> </font></div></td>
								<%	
								}
							}
						%>
						</tbody>
						<%
						count++;
					}
					%>
				</table>
				
				
				<br /><br />

				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Informasi Transfer Uang Details </strong></font></div>
				<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
					<thead>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No. </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Bank </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> ABA/BR </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Besaran <br /> Transfer </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Nominal <br /> Transaksi </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Fee Nominal <br /> Transaksi </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Total <br /> Transaksi </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Jml Fee <br /> Pemilik Terminal </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Fee Pemilik <br /> Terminal </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Jml Fee <br /> Tujuan Transfer </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Fee Tujuan <br /> Transfer </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Jml Fee <br /> Declined Transaction </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Fee Declined <br /> Transaction </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Jumlah Fee <br /> Total </strong></font></div></td>
						<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Fee Total </strong></font></div></td>
					</thead>

					<%
					count=1;
					for(int i=0;i<informasi_transfer_uang.size();i++){
						%>
						<tbody>
						<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=count%> </font></div></td>
						<%
							for(int j=0;j<14;j++){
								if(j==2 || j==3 || j==4 || j==5 || j==7 || j==9 || j==11 || j==13){
								%>
								<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=(get_decimal(informasi_transfer_uang.get(i)[j]))%> </font></div></td>
								<%
								}else{
								%>
								<td><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=informasi_transfer_uang.get(i)[j]%> </font></div></td>
								<%
								}
							}
						%>
						</tbody>
						<%
						count++;
					}
					%>
				</table>
				
				<br /><br />
				
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Cashout Date </strong></font></div><br />
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">
				<%
				for(int i=0;i<cashout_date.size();i++){
					out.println(cashout_date.get(i) + ", ");
				}
				%> 
				</font></div><br />
				
				
				<br /><br />
				
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Cashin Date </strong></font></div><br />
				<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">
				<%
				for(int i=0;i<cashin_date.size();i++){
					out.println(cashin_date.get(i) + ", ");
				}
				%> 
				</font></div><br />
				<hr />
				<%
				//}	
			/*}else{
				outPUT+=("System Error 1: error in processing report format|");
				out.println("<script language='javascript'>alert('Error : Report date is not today.')</script>");
			}*/
		}else{
			outPUT+=("System Error 1: error in processing report format|");
			out.println("<script language='javascript'>alert('Error : Format is wrong.')</script>");
		}
    }else{
		
	}
}
catch(Exception e){
	e.printStackTrace(System.out);
    out.println("Error : Please Try Again:"+e.getMessage());
	outPUT+=("Exception occured. Error :"+e.getMessage()+"|");
	try{con.rollback();}catch(Exception ee){}
}
finally{
    try{
		if(!con.getAutoCommit()) con.setAutoCommit(true);
		if(con!=null) con.close();
		if(rs!=null) rs.close();
		if(stmt!=null) stmt.close();
		if(pstmt!=null) pstmt.close();
		if(fileIn!=null)fileIn.close();
		//=====================================================================//
		if (!outPUT.equals(""))
			System.out.println("["+timeNOW+"]new_uploadPaymentStatus.jsp|"+outPUT);
		//=====================================================================//
	}catch(Exception e){}
}
%>		
		<p>Please input today's ATM bersama .rpt extension file to upload</p>
		<form action="uploadArtajasaRPT.jsp" enctype="multipart/form-data" method="post">                                                                       
			<input type="file" name="path">
			<input type="Submit" name="Submit" value="Upload File">
			<input type="hidden" name="idLog1" value="<%=(encLog.equals(""))?encLogP:encLog%>">
			<input type="hidden" name="idLog2" value="<%=(encPass.equals(""))?encPassP:encPass%>">
		
		</form>		
			
		
		<a href="https://10.2.114.121:9082/tcash-web/mcomm/artajasa_reconcile.jsp">Back to Artajasa Reconcile</a>
		
		<br /><br /><br />	
		
		
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
	  <td  valign="top" bgcolor="#CC6633"> <div align="right"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>IT 
	  VAS Development 2008 - Powered by Stripes Framework</strong></font></div></td>
    </tr>
  </table>	
		
	
    </body>
</html>
