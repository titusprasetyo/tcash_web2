<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.sql.*, java.util.*,java.text.*, oracle.jdbc.driver.*" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="org.apache.commons.fileupload.FileUploadException" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon" />

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Daily Artajasa Report - RTG</title>
<script language="JavaScript">
<!--
function checkExecute2(){
	with(document)
		return confirm("Do you really want to request this Artajasa deposit or cashout?");
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
	  	<div align="right"> <font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong><font color="#FFFFFF" size="2">TCash Web Interface :: Upload RTG Artajasa</font></strong></font><font color="#FFFFFF" face="Verdana, Arial, Helvetica, sans-serif"><strong>
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

List fileItemsList = null;

if (ServletFileUpload.isMultipartContent(request)){
    ServletFileUpload servletFileUpload = new ServletFileUpload(new DiskFileItemFactory());
    
    try {
        fileItemsList = servletFileUpload.parseRequest(request);
    }
    catch (FileUploadException e) {
        out.println("File upload failed. ["+e.getMessage()+"]");
		
    }
}

%>
<%!
String get_decimal(String input){
	String inputs  = (input.contains(".")?input.substring(0, input.length()-1):input);
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

int findRecon(ArrayList <String[]>  report_rtg, String bank_code, String bank_name){
	int result = -1;
	search:
	for(int i=0;i<report_rtg.size();i++){
		if( bank_code.equalsIgnoreCase(report_rtg.get(i)[1]) && bank_name.equalsIgnoreCase(report_rtg.get(i)[2])){
			result = i;
			break search;
		}
	}
	return result;
}
%>		
<%
//=========================
// database parameter
String user = "admin"; 

String 	merchant = "0711262322587022",
	stanggal_laporan = request.getParameter("tanggal_laporan_records"),
	ssandi_bank = request.getParameter("sandi_bank_records"),
	snama_bank = request.getParameter("nama_bank_records"),
	stotal_hak = request.getParameter("total_hak_records"),
	stotal_kewajiban = request.getParameter("total_kewajiban_records"),
	
	doc_number = request.getParameter("doc_number"),
	note = request.getParameter("note");
	
String [] sno = request.getParameterValues("no"),
		skode_bank = request.getParameterValues("kode_bank"),
		sbank_name = request.getParameterValues("bank_name"),
		
		skode_bank_denda = request.getParameterValues("kode_bank_denda"),
		snama_bank_denda = request.getParameterValues("bank_name_denda"),
		sdenda_hak = request.getParameterValues("denda_hak"),
		sdenda_kewajiban = request.getParameterValues("denda_kewajiban"),
		
		skewajiban_gross = request.getParameterValues("kewajiban_gross"),
		shak_gross = request.getParameterValues("hak_gross"),
		skewajiban_nett = request.getParameterValues("kewajiban_nett"),
		shak_nett = request.getParameterValues("hak_nett")
		
		;
		
if(merchant==null)merchant="";
if(doc_number==null)doc_number="";
if(note==null)note="";
if(stotal_hak==null)stotal_hak="";
if(stotal_kewajiban==null)stotal_kewajiban="";
		
//=========================================
Calendar CAL = Calendar.getInstance();
SimpleDateFormat SDF = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
String timeNOW=SDF.format(CAL.getTime());
String outPUT = "";
//=========================================
SimpleDateFormat SDF2 = new SimpleDateFormat("dd MMMM yyyy");

Calendar cal = Calendar.getInstance();
SimpleDateFormat sdf = new SimpleDateFormat("ddMMyyyyHHmmss");
String timeNow=sdf.format(cal.getTime());

NumberFormat nf =  NumberFormat.getInstance(Locale.ITALY);

// Database parameter
Connection con = null;
Statement stmt = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
String query = "";


//upload  csv file into file server
String pathFile = "";
BufferedReader fileIn = null;

String encLogP = ""; String encPassP=""; String encPass=""; String encLog="";

try{
    // Buka dulu si databasenya
	Class.forName("oracle.jdbc.OracleDriver");
	//con = DriverManager.getConnection("jdbc:oracle:thin:@10.2.114.121:1521:OPTUNAI", "tunai", "tunai123");
	con = DbCon.getConnection();
	con.setAutoCommit(false);
	
	// cek untuk yang buka pertama kali	
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
		
		// =======================================================================================
		// time to insert into merchant_deposit and insert into recon selisih
		if(!merchant.equals("") && !doc_number.equals("") && !note.equals("") && !stotal_hak.equals("") && !stotal_kewajiban.equals("")){
				if(!stotal_hak.equals("0")){
					// insert into merchant_deposit
					query = "insert into MERCHANT_DEPOSIT (MERCHANT_ID, AMOUNT, DOC_NUMBER, NOTE, DEPOSIT_TIME, IS_EXECUTED, ENTRY_LOGIN) VALUES ('"+merchant+"',"+stotal_hak+",'"+doc_number+"','"+note+"',sysdate,'0','"+user+"')";
					System.out.println(query);
					pstmt = con.prepareStatement(query);
					pstmt.executeUpdate();
					pstmt.close();
					
					// insert into activity_log
					query = "INSERT INTO ACTIVITY_LOG (USERLOGIN, ACCESS_TIME, ACTIVITY, NOTE, IP, REASON) values ('"+user+"', sysdate, 'Insert Deposit Artajasa', '"+merchant+"|"+stotal_hak+"|"+doc_number+"', '"+request.getRemoteAddr()+"', '-')";
					System.out.println(query);
					pstmt = con.prepareStatement(query);
					pstmt.executeUpdate();
					pstmt.close();
				}
				
				if(!stotal_kewajiban.equals("0")){
					// insert into merchant_cashout
					query = "insert into MERCHANT_CASHOUT (MERCHANT_ID, AMOUNT, DOC_NUMBER, NOTE, DEPOSIT_TIME, IS_EXECUTED, ENTRY_LOGIN) VALUES ('"+merchant+"',"+stotal_kewajiban+",'"+doc_number+"','"+note+"',sysdate,'0','"+user+"')";
					System.out.println(query);
					pstmt = con.prepareStatement(query);
					pstmt.executeUpdate();
					pstmt.close();
					
					// insert into activity_log
					query = "INSERT INTO ACTIVITY_LOG (USERLOGIN, ACCESS_TIME, ACTIVITY, NOTE, IP, REASON) values ('"+user+"', sysdate, 'Insert Cashout Artajasa', '"+merchant+"|"+stotal_kewajiban+"|"+doc_number+"', '"+request.getRemoteAddr()+"', '-')";
					System.out.println(query);
					pstmt = con.prepareStatement(query);
					pstmt.executeUpdate();
					pstmt.close();
				}
				
				// updating denda_hak & kewajiban RTG in recon_selisih
				//System.out.println("snama_bank_denda:"+snama_bank_denda.length+", sdenda_hak:"+sdenda_hak.length+", sdenda_kewajiban:"+sdenda_kewajiban.length+", skode_bank_denda:"+skode_bank_denda.length);
				if(skode_bank_denda!=null && snama_bank_denda!=null && sdenda_hak!=null && sdenda_kewajiban!=null){
					//System.out.println("Masuk ke IF nya");
					for(int i=0;i<skode_bank_denda.length;i++){
						query = "update recon_selisih set denda_kewajiban_rpt='"+sdenda_kewajiban[i]+"', denda_hak_rpt='"+sdenda_hak[i]+"' where merchant_id='"+merchant+"' and settle_date=(select max(settle_date) from recon_selisih) and status=0 and bank_code='"+skode_bank_denda[i]+"' and bank_name='"+snama_bank_denda[i]+"'";
						System.out.println(query);
						pstmt = con.prepareStatement(query);
						pstmt.executeUpdate();
						pstmt.close();
					}
				}
				
				// updating all old recon_selisih
				query = "update recon_selisih set status=1, solve_date=sysdate where merchant_id='"+merchant+"' and settle_date<to_char(to_date('"+stanggal_laporan+"','DD/MM/YYYY'), 'DD/MM/YYYY')";
				System.out.println(query);
				pstmt = con.prepareStatement(query);
				pstmt.executeUpdate();
				pstmt.close();
				
				// insert into recon_selisih
				if(sno!=null && skode_bank!=null && sbank_name!=null&& skewajiban_gross!=null&& shak_gross!=null&& skewajiban_nett!=null&& shak_nett!=null){
					for(int i=0;i<sno.length;i++){
						query = "insert into recon_selisih(settle_date, bank_code, bank_name, hak, kewajiban, solve_date, status, merchant_id, keterangan) values('"+stanggal_laporan+"','"+skode_bank[i]+"', '"+sbank_name[i]+"', "+shak_nett[i]+", "+skewajiban_nett[i]+", '', '0','"+merchant+"', 'new')";
						//System.out.println(query);
						pstmt = con.prepareStatement(query);
						pstmt.executeUpdate();
						pstmt.close();	
					}
				}
				
				con.commit();
				out.println("<script language='javascript'>alert('Deposit Artajasa is successful with amount Rp "+nf.format(Long.parseLong(stotal_hak))+". Cashout Artajasa is successful with amount Rp "+nf.format(Long.parseLong(stotal_kewajiban))+ ". There are "+sno.length+" banks.')</script>");
				
				outPUT+=("Deposit Artajasa is successful|"+stotal_hak+"|Cashout Artajasa is successful|"+stotal_kewajiban+"|"+doc_number+"|"+note+"|"+merchant+"|"+sno.length+"|");
		}
		// ====================================================================
		
	}
	// cek untuk yang buka kedua kali
	if (ServletFileUpload.isMultipartContent(request)){
        
        Iterator i = fileItemsList.iterator();
        while(i.hasNext()){
			FileItem fi = (FileItem)i.next();
			if(!fi.isFormField()){
				String fileName = fi.getName();

				String saveFile = fileName.substring(fileName.lastIndexOf("\\")+1);
				String saveBNI = "";
				String ext = saveFile.substring(saveFile.length()-3, saveFile.length());
				if(ext.equalsIgnoreCase("rtg")){
					// write the file
					try {
						saveFile=saveFile.substring(0,saveFile.length()-4);
						saveBNI = saveFile;
						saveFile+=timeNow;
						saveFile+=".rtg";
						saveBNI+=".rtg";
						String pathTes = application.getRealPath("/")+"artajasa_claim";

						File fileTes = new File(pathTes);
						if(!fileTes.exists())fileTes.mkdirs();
						fi.write(new File(application.getRealPath("/")+"artajasa_claim", saveFile));
						fi.write(new File(application.getRealPath("/")+"artajasa_claim", saveBNI));
						pathFile = pathTes+"/"+saveFile;
						out.println("<script language='javascript'>alert('File upload is successful.')</script>");
						// System.out.println("File upload of "+saveFile+" is successful.");
						outPUT+=("File upload of "+saveFile+" is successful|");

					}
					catch (Exception e) {
						// System.out.println("File upload of "+saveFile+" is error. Error message:"+e.getMessage()+".");
						outPUT +=("File upload of "+saveFile+" is error. Error message:"+e.getMessage()+"|");
						out.println("<script language='javascript'>alert('File upload is error. Message : "+e.getMessage()+".')</script>");
					}
				}else{
					out.println("Please insert rtg file.");
					outPUT+=("Please insert rtg file|");
				}
			}
			else{
				/* Get form fields value */
				if (fi.getFieldName().equals("idLog1"))encLog = fi.getString();
				if (fi.getFieldName().equals("idLog2"))encPass = fi.getString();			
			}
		}
		
		//==setelah selesai mengambil data.
		if(encLog==null)encLog="";
		if(encPass==null)encPass="";
		
		//==check database
		query = "select * from tsel_webstarter_user where username='"+encLog+"' and password='"+encPass+"'";
		stmt = con.createStatement();
		rs = stmt.executeQuery(query);
		if(!rs.next()){	
			//con.close();
			response.sendRedirect("https://10.2.114.121:9082/tcash-web/web-starter/Login.jsp");
		}
		rs.close();stmt.close();
		
		if(pathFile==""){
			//out.println("<script language='javascript'>alert('Path file is blank, please correct it.')</script>");
			outPUT+="Path blank|";
		}
		
    }

	
    if(!pathFile.equals("") && !encLog.equals("") && !encPass.equals("")){
        // Do the magic

        out.println("<hr />");
        
		// reader parameter
		 
		String thisLine = "";
		
		// report parameter
        //System.out.println("Masuk 1");
		// kewajiban
		ArrayList<String[]> records = new ArrayList<String[]>();
		// tunggakan
		ArrayList<String[]> records2 = new ArrayList<String[]>();
		// gabungan keduanya
		ArrayList<String[]> records3 = new ArrayList<String[]>();
		
		//System.out.println("Masuk 2");
		String sandi_bank_records = "";
		String nama_bank_records = "";
		String sandi_bank_records2 = "";
		String nama_bank_records2 = "";
		
		boolean startRecords = false;
		boolean startLaporan = false;
		boolean startLaporan2 = false;
		
		String total_hak_records = "";
		String total_kewajiban_records = "";
		String total_hak_records2 = "";
		String total_kewajiban_records2 = "";
		
		String tanggal_laporan_records = "";
		String tanggal_laporan_records2 = "";
		
		fileIn = new BufferedReader(new FileReader(pathFile));
        
		while((thisLine=fileIn.readLine())!=null){	
			// System.out.println(thisLine + "length " +thisLine.length());
			
			if(thisLine.contains("LAPORAN BILATERAL NETTING ANTAR BANK")){
				startLaporan = true;
				startLaporan2 = false;
			}
			if(thisLine.contains("POSISI HAK DAN KEWAJIBAN  YANG BELUM DISELESAIKAN")){
				startLaporan = false;
				startLaporan2 = true;
			}
			if(thisLine.contains("Sandi Bank :")){
				if(startLaporan)
					sandi_bank_records = (thisLine.substring(18,thisLine.length())).trim();
				else if(startLaporan2)
					sandi_bank_records2 = (thisLine.substring(18,thisLine.length())).trim();
			}
			
			if(thisLine.contains("Nama Bank  :")){
				if(startLaporan)
					nama_bank_records = (thisLine.substring(18,thisLine.length())).trim();
				else if(startLaporan2)
					nama_bank_records2 = (thisLine.substring(18,thisLine.length())).trim();
			}
			
			if(thisLine.contains("Tanggal Laporan :")){				
				if(startLaporan)
					tanggal_laporan_records = (thisLine.substring(68,thisLine.length())).trim();
				else if(startLaporan2)
					tanggal_laporan_records2 = (thisLine.substring(68,thisLine.length())).trim();
			}
			
			if(thisLine.contains("TOTAL NILAI")){
				if(startLaporan){
					total_kewajiban_records = ((thisLine.substring(96,114)).trim()).replaceAll(",","");
					total_hak_records = ((thisLine.substring(117,thisLine.length()-3)).trim()).replaceAll(",","");
				}else if(startLaporan2){
					total_kewajiban_records2 = ((thisLine.substring(75,93)).trim()).replaceAll(",","");
					total_hak_records2 = ((thisLine.substring(117,thisLine.length()-3)).trim()).replaceAll(",","");
				}
			}
			
			if(thisLine.contains("No. Snd Bank  Nama Bank ")){
				thisLine=fileIn.readLine();thisLine=fileIn.readLine();
				startRecords = true;
			}
			
			if(startRecords==true && (thisLine.length()==0) || (thisLine.trim()).equals("")){
				startRecords = false;
				// System.out.println("startRecords = false;");
			}
			
			if(startRecords){
				// start fetching records
				String [] records_detail = new String [7];
				records_detail[0] = (thisLine.substring(5,9)).trim();
				// System.out.println("records_detail[0] :"+records_detail[0]);
				records_detail[1] = (thisLine.substring(9,13)).trim();
				records_detail[2] = (thisLine.substring(19,52)).trim();
				records_detail[3] = ((thisLine.substring(52,72)).trim()).replaceAll(",","");
				records_detail[4] = ((thisLine.substring(75,93)).trim()).replaceAll(",","");
				records_detail[5] = ((thisLine.substring(96,114)).trim()).replaceAll(",","");
				records_detail[6] = ((thisLine.substring(117,thisLine.length()-3)).trim()).replaceAll(",","");
				if(startLaporan)
					records.add(records_detail);
				else if(startLaporan2)
					records2.add(records_detail);
			}
			
		}
		fileIn.close();
		
		// keluarkan data recon_selisih hari terakhir yang masih belum solved dan pasangkan dengan data di RTG
		// bandingkan 2 arraylist records2 dan db_recon_selisih
		ArrayList<String[]> db_recon_selisih = new ArrayList<String[]>();
		
		
		query = "select settle_date, bank_code, bank_name, hak-hak_dibayarkan as sisa_hak, denda_hak, kewajiban-kewajiban_dibayarkan as sisa_kewajiban, denda_kewajiban, solve_date, status, keterangan from recon_selisih where settle_date=(select max(settle_date) from recon_selisih) and status='0'";
		System.out.println(query);
		stmt = con.createStatement();
		rs = stmt.executeQuery(query);
		System.out.println("DEBUG|Masuk sini");
		while(rs.next()){
			String [] db_selisih_detail = new String [10];
			db_selisih_detail[0] = rs.getString("settle_date");
			db_selisih_detail[1] = rs.getString("bank_code");
			db_selisih_detail[2] = rs.getString("bank_name");
			db_selisih_detail[3] = rs.getString("sisa_hak");
			db_selisih_detail[4] = rs.getString("denda_hak");
			db_selisih_detail[5] = rs.getString("sisa_kewajiban");
			db_selisih_detail[6] = rs.getString("denda_kewajiban");
			db_selisih_detail[7] = rs.getString("solve_date");
			db_selisih_detail[8] = rs.getString("status");
			db_selisih_detail[9] = rs.getString("keterangan");
			db_recon_selisih.add(db_selisih_detail);
		}
		System.out.println("DEBUG|Masuk sini2");
		rs.close();stmt.close();
		
		
		if(records2.size()!=0){
		// =============================================================
		// penggabungan kedua data dari kewajiban dan tunggakan
		// start recon						
		// cari gabungan data dari kewajiban dan tunggakan
		
		System.out.println("DEBUG|Masuk sini3");
		String index_recon_records3 = "";
		
		for(int i=0;i<records.size();i++){
			int search = findRecon(records2, records.get(i)[1], records.get(i)[2]);
			if(search==-1){
				if(!records.get(i)[1].equals("000")){
					records3.add(records.get(i));
				}
			}else{
				String [] temp_records = new String[7];
				temp_records[0] = records.get(i)[0];
				temp_records[1] = records.get(i)[1];
				temp_records[2] = records.get(i)[2];
				temp_records[3] = records.get(i)[3];
				temp_records[4] = records.get(i)[4];
				temp_records[5] = records.get(i)[5];
				temp_records[6] = records.get(i)[6];
				
				//System.out.println("DEBUG|temp_records[5]:"+temp_records[5]+", records2.get(search)[3]:"+records2.get(search)[3]+", records2.get(search)[4]:"+records2.get(search)[4]);
				temp_records[5] = (Long.parseLong(temp_records[5]) + Long.parseLong(records2.get(search)[3]) + Long.parseLong(records2.get(search)[4])) + "";
				temp_records[6]  = (Long.parseLong(temp_records[6]) + Long.parseLong(records2.get(search)[5]) + Long.parseLong(records2.get(search)[6])) + "";
				
				if(!temp_records[1].equals("000")){
					records3.add(temp_records);
					index_recon_records3 += search+",";
					//System.out.println("DEBUG|temp_records[5]:"+temp_records[5]+", records.get(i)[5]:"+records.get(i)[5]);
				}
			}
		}
		System.out.println("DEBUG|Masuk sini4");
		if(!index_recon_records3.equals("")){
			String [] index_array_recon_records3 = index_recon_records3.split(",");
			for(int i=0;i<records2.size();i++){
				boolean bbb = true;
				for(int j=0;j<index_array_recon_records3.length;j++){
					if(i==Integer.parseInt(index_array_recon_records3[j])){
						bbb = false;
						break;
					}
				}
				if(bbb){
					// index_unrecon_records3 += i + ",";
					String [] temp_records = new String[7];
					temp_records[0] = records2.get(i)[0];
					temp_records[1] = records2.get(i)[1];
					temp_records[2] = records2.get(i)[2];
					temp_records[3] = records2.get(i)[3];
					temp_records[4] = records2.get(i)[4];
					temp_records[5] = records2.get(i)[5];
					temp_records[6] = records2.get(i)[6];
					
					//System.out.println("DEBUG|temp_records[5]:"+temp_records[5]+", records2.get(search)[3]:"+records2.get(search)[3]+", records2.get(search)[4]:"+records2.get(search)[4]);
					temp_records[6] = (Long.parseLong(temp_records[5]) + Long.parseLong(temp_records[6])) + "";
					temp_records[5] = (Long.parseLong(temp_records[3]) + Long.parseLong(temp_records[4])) + "";
					temp_records[4] = "0";
					temp_records[3] = "0";
					
					if(!temp_records[1].equals("000")){
						records3.add(temp_records);
						//System.out.println("DEBUG|temp_records[5]:"+temp_records[5]+", records.get(i)[5]:"+records.get(i)[5]);
					}
				}
			}
		}else{
			for(int i=0;i<records2.size();i++){
				if(!records2.get(i)[1].equals("000")){
					records3.add(records2.get(i));
				}
			}
		}
		System.out.println("DEBUG|Masuk sini5");
		
		
		
		// =============================================================
		}else{
			for(int i=0;i<records.size();i++){
				if(!records.get(i)[1].equals("000")){
					records3.add(records.get(i));
				}
			}
		}
		
		
		// pencocokan antara database dan RTG
		// =============================================================
		String index_rec = "";
		String index_recon_detail = "";
		String index_recon_detail2 = "";
		String index_unrecon_detail = "";
		String index_unrecon_detail_records = "";
		
		String [] index_recon = null;
		String [] index_recon2 = null;
		String [] index_unrecon = null;
		String [] index_unrecon_records = null;
		
		// start recon						
		// filter db_recon_selisih and add to db_recon
		for(int i=0;i<db_recon_selisih.size();i++){
			int search = findRecon(records2, db_recon_selisih.get(i)[1], db_recon_selisih.get(i)[2]);
			if(search!=-1){
				index_recon_detail += i+",";
				index_recon_detail2 += search+ ",";
			}
		}
		
		System.out.println("index_recon_detail : "+index_recon_detail);
		System.out.println("index_recon_detail2 : "+index_recon_detail2);
		
		if(!index_recon_detail.equals("")){
			index_recon = index_recon_detail.split(",");
			index_recon2 = index_recon_detail2.split(",");
		
			// filter db_recon_selisih and add to db_unrecon
			for(int i=0;i<db_recon_selisih.size();i++){
				boolean bbb = true;
				for(int j=0;j<index_recon.length;j++){
					if(i==Integer.parseInt(index_recon[j])){
						bbb = false;
						break;
					}
				}
				if(bbb){
					index_unrecon_detail += i + ",";
				}
			}
			
			// filter records2 and add to db_unrecon
			for(int i=0;i<records2.size();i++){
				boolean bbb = true;
				for(int j=0;j<index_recon2.length;j++){
					if(i==Integer.parseInt(index_recon[j])){
						bbb = false;
						break;
					}
				}
				if(bbb){
					index_unrecon_detail_records += i + ",";
				}
			}
		}else{
			// filter db_recon_selisih and add to db_unrecon
			for(int i=0;i<db_recon_selisih.size();i++){
				index_unrecon_detail += i + ",";
			}
			// filter records2 and add to db_unrecon
			for(int i=0;i<records2.size();i++){
				index_unrecon_detail_records += i + ",";
			}
		}
		
		System.out.println("index_unrecon_detail : "+index_unrecon_detail);
		System.out.println("index_unrecon_detail_records : "+index_unrecon_detail_records);
		
		if(!index_unrecon_detail.equals("")){
			index_unrecon = index_unrecon_detail.split(",");
		}	
		
		if(!index_unrecon_detail_records.equals("")){
			index_unrecon_records = index_unrecon_detail_records.split(",");
		}
		// =============================================================
		
		
		// show summary data
		%>		
		<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> SUMMARY LAPORAN RTG </strong></font></div>
		<br />
		<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
			<thead>
				<td colspan="3"><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Summary RTG LAPORAN BILATERAL NETTING ANTAR BANK</strong></font></div></td>
			</thead>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Tanggal Laporan </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=tanggal_laporan_records%> </font></div></td>
			</tbody>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Sandi Bank </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=sandi_bank_records%> </font></div></td>
			</tbody>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Nama Bank </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=nama_bank_records%> </font></div></td>
			</tbody>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total Bank </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=(records.size()!=0)?records.size():"0"%> </font></div></td>
			</tbody>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Total Hak </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> : </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> <%=get_decimal(total_hak_records)%> </strong></font></div></td>
			</tbody>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Total Kewajiban </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> : </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> <%=get_decimal(total_kewajiban_records)%> </strong></font></div></td>
			</tbody>
		</table>
		
		<br />
		<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
			<thead>
				<td colspan="3"><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Summary RTG POSISI HAK DAN KEWAJIBAN  YANG BELUM DISELESAIKAN</strong></font></div></td>
			</thead>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Tanggal Laporan </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=tanggal_laporan_records2%> </font></div></td>
			</tbody>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Sandi Bank </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=sandi_bank_records2%> </font></div></td>
			</tbody>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Nama Bank </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=nama_bank_records2%> </font></div></td>
			</tbody>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total Bank </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=(records2.size()!=0)?records2.size():"0"%> </font></div></td>
			</tbody>
			
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total Hak + Denda </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(total_hak_records2)%> </font></div></td>
			</tbody>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total Kewajiban + Denda </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(total_kewajiban_records2)%> </font></div></td>
			</tbody>
		</table>		
		
		<br />		
		
		<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
			<thead>
				<td colspan="3"><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Summary Recon Denda RTG dan Database</strong></font></div></td>
			</thead>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Tanggal Denda </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=(db_recon_selisih.size()!=0)?db_recon_selisih.get(0)[0]:tanggal_laporan_records2%> </font></div></td>
			</tbody>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Jumlah Campuran Bank Kewajiban dan Tunggakan </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=(records3.size()!=0)?records3.size():"0"%> </font></div></td>
			</tbody>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Jumlah Bank yang Denda di Database </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=(db_recon_selisih.size()!=0)?db_recon_selisih.size():"0"%> </font></div></td>
			</tbody>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Jumlah Bank yang Denda di RTG </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=(records2.size()!=0)?records2.size():"0"%> </font></div></td>
			</tbody>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Jumlah Denda Bank yang bersesuaian </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=(!index_recon_detail.equals(""))?index_recon.length:"0"%> </font></div></td>
			</tbody>
		</table>
		
		
		<br />
		
		<%// print the hidden form for processing %>
		<form action='uploadArtajasaRTG.jsp' method='post'>
			<input type='hidden' name='idLog1' value='<%=encLog%>'>
			<input type='hidden' name='idLog2' value='<%=encPass%>'>
			
			<input type='hidden' name='tanggal_laporan_records' value='<%=tanggal_laporan_records%>'>
			<input type='hidden' name='sandi_bank_records' value='<%=sandi_bank_records%>'>
			<input type='hidden' name='nama_bank_records' value='<%=nama_bank_records%>'>
			<input type='hidden' name='total_hak_records' value='<%=total_hak_records%>'>
			<input type='hidden' name='total_kewajiban_records' value='<%=total_kewajiban_records%>'>
			
			<input type='hidden' name='tanggal_laporan_records2' value='<%=tanggal_laporan_records2%>'>
			<input type='hidden' name='sandi_bank_records2' value='<%=sandi_bank_records2%>'>
			<input type='hidden' name='nama_bank_records2' value='<%=nama_bank_records2%>'>
			<input type='hidden' name='total_hak_records2' value='<%=total_hak_records2%>'>
			<input type='hidden' name='total_kewajiban_records2' value='<%=total_kewajiban_records2%>'>
			
			<input type='hidden' name='doc_number' value='<%=tanggal_laporan_records/*SDF2.format(cal.getTime())*/%>'>
			<input type='hidden' name='note' value='Deposit Artajasa'>
			
			<%
			for(int i=0;i<records3.size();i++){
				//if(!records3.get(i)[1].equals("000")){
			%>
				<input type='hidden' name='no' value='<%=records3.get(i)[0]%>'>
				<input type='hidden' name='kode_bank' value='<%=records3.get(i)[1]%>'>
				<input type='hidden' name='bank_name' value='<%=records3.get(i)[2]%>'>
				<input type='hidden' name='kewajiban_gross' value='<%=records3.get(i)[3]%>'>
				<input type='hidden' name='hak_gross' value='<%=records3.get(i)[4]%>'>
				<input type='hidden' name='kewajiban_nett' value='<%=records3.get(i)[5]%>'>
				<input type='hidden' name='hak_nett' value='<%=records3.get(i)[6]%>'>
			<%
				//}
			}
			
			if(!index_recon_detail.equals("")){
				for(int i=0;i<index_recon.length;i++){
			%>				
					<input type='hidden' name='kode_bank_denda' value='<%=db_recon_selisih.get(Integer.parseInt(index_recon[i]))[1]%>'>
					<input type='hidden' name='bank_name_denda' value='<%=db_recon_selisih.get(Integer.parseInt(index_recon[i]))[2]%>'>
					<input type='hidden' name='denda_kewajiban' value='<%=get_decimal(records2.get(Integer.parseInt(index_recon2[i]))[4])%>'>
					<input type='hidden' name='denda_hak' value='<%=get_decimal(records2.get(Integer.parseInt(index_recon2[i]))[6])%>'>
			<%
				}
			}
			%>	
			<input type='submit' value='Proceed to Settlement and Deposit' onclick='return checkExecute2();'>
			
			
		</form>
		
		<%		
		// ===========================================================
		// Print the recon result.		
		int no_idx=0;
		
		%>
		<hr />
		<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> ==RECON DETAIL - With Current Data== RECON Kewajiban dan Tunggakan </strong></font></div>
		
		<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
			<thead>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Sandi Bank </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Nama Bank </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Kewajiban <br /> Nett </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Hak Nett </strong></font></div></td>
			</thead>
		
		
		<%	
		System.out.println("display output records3");
		// display output
		no_idx = 1;
		for(int i=0;i<records3.size();i++){
			%>
				<tbody>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=no_idx%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=records3.get(i)[1]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=records3.get(i)[2]%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(records3.get(i)[5])%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(records3.get(i)[6])%> </font></div></td>
				</tbody>
			<%
			no_idx++;
		}
		
		%>
		</table>
		
		<br />
		<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> ==RECON DETAIL - With Past Data== RECON Denda dengan Denda Sebelumnya </strong></font></div>
		<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
			<thead>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Sandi Bank </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Nama Bank </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> RTG <br /> Kewajiban </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> RTG <br /> Denda </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> DB <br /> Kewajiban </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> DB <br /> Denda </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> RTG <br /> Hak </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> RTG <br /> Denda </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> DB <br /> Hak </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> DB <br /> Denda </strong></font></div></td>
			</thead>
		
		
		<%		
		System.out.println("display output first is for reconed, unrecon on records2 and unrecon on db_recon_selisih");
		no_idx = 1;
		if(!index_recon_detail.equals("")){
		for(int i=0;i<index_recon.length;i++){
			%>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=no_idx%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_recon_selisih.get(Integer.parseInt(index_recon[i]))[1]%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_recon_selisih.get(Integer.parseInt(index_recon[i]))[2]%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(records2.get(Integer.parseInt(index_recon2[i]))[3])%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(records2.get(Integer.parseInt(index_recon2[i]))[4])%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(db_recon_selisih.get(Integer.parseInt(index_recon[i]))[5])%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(db_recon_selisih.get(Integer.parseInt(index_recon[i]))[6])%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(records2.get(Integer.parseInt(index_recon2[i]))[5])%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(records2.get(Integer.parseInt(index_recon2[i]))[6])%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(db_recon_selisih.get(Integer.parseInt(index_recon[i]))[3])%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(db_recon_selisih.get(Integer.parseInt(index_recon[i]))[4])%> </font></div></td>
			</tbody>
			<%
			no_idx++;
		}
		}
		System.out.println("display unrecon on records2");
		if(!index_unrecon_detail_records.equals("")){
		for(int i=0;i<index_unrecon_records.length;i++){
			%>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=no_idx%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=records2.get(Integer.parseInt(index_unrecon_records[i]))[1]%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=records2.get(Integer.parseInt(index_unrecon_records[i]))[2]%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(records2.get(Integer.parseInt(index_unrecon_records[i]))[3])%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(records2.get(Integer.parseInt(index_unrecon_records[i]))[4])%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> - </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> - </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(records2.get(Integer.parseInt(index_unrecon_records[i]))[5])%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(records2.get(Integer.parseInt(index_unrecon_records[i]))[6])%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> - </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> - </font></div></td>
			</tbody>
			<%
			no_idx++;
		}
		}
		// 
		System.out.println("display unrecon on db_recon_selisih");
		if(!index_unrecon_detail.equals("")){
		for(int i=0;i<index_unrecon.length;i++){
			%>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=no_idx%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_recon_selisih.get(Integer.parseInt(index_unrecon[i]))[1]%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=db_recon_selisih.get(Integer.parseInt(index_unrecon[i]))[2]%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> - </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> - </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(db_recon_selisih.get(Integer.parseInt(index_unrecon[i]))[5])%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(db_recon_selisih.get(Integer.parseInt(index_unrecon[i]))[6])%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> - </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> - </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(db_recon_selisih.get(Integer.parseInt(index_unrecon[i]))[3])%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(db_recon_selisih.get(Integer.parseInt(index_unrecon[i]))[4])%> </font></div></td>
			</tbody>
			<%
			no_idx++;
		}
		}
		%>
		</table>
		
		<%
		System.out.println("end of printing recon result");
		
		// end of printing recon result
		// =======================================================================================================
		%>
		
		<hr />
		<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> DETAIL LAPORAN RTG </strong></font></div>
		
		
		<br /> <div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> DETAIL RTG LAPORAN BILATERAL NETTING ANTAR BANK </strong></font></div>
		
		<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
			<thead>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Sandi Bank </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Nama Bank </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Kewajiban <br /> Gross </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Hak Gross </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Kewajiban <br /> Nett </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Hak Nett </strong></font></div></td>
			</thead>
		
		
		<%		
		System.out.println("display output records");
		// display output
		for(int i=0;i<records.size();i++){
			%>
				<tbody>
			<%
			for(int j=0;j<7;j++){
				if(j==0 || j==1 || j==2){
				%>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=records.get(i)[j]%> </font></div></td>
				<%
				}else{
				%>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(records.get(i)[j])%> </font></div></td>
				<%
				}
			}
			%>
				</tbody>
			<%
		}
		
		%>
		</table>
		
		<br /><br /> <div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> DETAIL RTG POSISI HAK DAN KEWAJIBAN  YANG BELUM DISELESAIKAN </strong></font></div>
		
		<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
			<thead>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Sandi Bank </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Nama Bank </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Kewajiban </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Denda </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Hak </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Denda </strong></font></div></td>
			</thead>
		
		
		<%	
System.out.println("display output records2");		
		// display output
		for(int i=0;i<records2.size();i++){
			%>
				<tbody>
			<%
			for(int j=0;j<7;j++){
				if(j==0 || j==1 || j==2){
				%>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=records2.get(i)[j]%> </font></div></td>
				<%
				}else{
				%>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(records2.get(i)[j])%> </font></div></td>
				<%
				}
			}
			%>
				</tbody>
			<%
		}
		
		%>
		</table>
		
		<br /> <hr />
<%
    }
}
catch(Exception e){
    e.printStackTrace(System.out);
    outPUT+=("System Error : "+e.getMessage());
    out.println("System Error : "+e.getMessage());
	try{con.rollback();}catch(Exception ee){}
}
finally{
	try{
		if(fileIn!=null)fileIn.close();
		if(!con.getAutoCommit()) con.setAutoCommit(true);
		if(con!=null) con.close();
		if(rs!=null) rs.close();
		if(stmt!=null) stmt.close();
		if(pstmt!=null) pstmt.close();
		//=====================================================================//
		if (!outPUT.equals(""))
			System.out.println("["+timeNOW+"]uploadArtajasaRTG.jsp|"+outPUT);
		//=====================================================================//
	}
	catch(Exception e){}
}
%>		
		
		
		<p>Please input today's ATM bersama .rtg extension file to upload</p>
		<form action="uploadArtajasaRTG.jsp" enctype="multipart/form-data" method="post">                                                                       
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
