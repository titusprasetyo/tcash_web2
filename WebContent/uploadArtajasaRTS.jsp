<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.sql.*, java.util.*,java.text.*, oracle.jdbc.driver.*" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="org.apache.commons.fileupload.FileUploadException" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon" />

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
//System.out.println("input:"+input);
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
	
	if(bank_code!=null && bank_name!=null && !bank_code.equals("") && !bank_name.equals("")){
		search:
		for(int i=0;i<report_rtg.size();i++){
			if(!report_rtg.get(i)[1].equals("") && !report_rtg.get(i)[2].equals("") && report_rtg.get(i)[1]!=null && report_rtg.get(i)[2]!=null){
				if( bank_code.equalsIgnoreCase(report_rtg.get(i)[1]) && bank_name.equalsIgnoreCase(report_rtg.get(i)[2])){
					result = i;
					break search;
				}
			}
		}
	}
	
	return result;
}

%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Daily Artajasa Report - RTS</title>
<script language="JavaScript">
<!--
function checkExecute2(){
	with(document)
		return confirm("Do you really want to update this Artajasa deposit?");
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
	  	<div align="right"> <font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong><font color="#FFFFFF" size="2">TCash Web Interface :: Upload RTS Artajasa</font></strong></font><font color="#FFFFFF" face="Verdana, Arial, Helvetica, sans-serif"><strong>
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
//=========================
// database parameter
String user = "admin"; 

String 	merchant = "0711262322587022",
	amount = request.getParameter("amount"),
	
	stanggal_laporan = request.getParameter("tanggal_laporan_records"),
	ssandi_bank = request.getParameter("sandi_bank_records"),
	snama_bank = request.getParameter("nama_bank_records"),
	stotal_hak = request.getParameter("total_hak_records"),
	stotal_kewajiban = request.getParameter("total_kewajiban_records"),
	
	doc_number = request.getParameter("doc_number"),
	note = request.getParameter("note"),
	bunga_jibor = request.getParameter("bunga_jibor"),
	hari_telat = request.getParameter("hari_telat");
	
String [] sno = request.getParameterValues("no"),
		skode_bank = request.getParameterValues("kode_bank"),
		sbank_name = request.getParameterValues("bank_name"),
		skewajiban = request.getParameterValues("kewajiban"),
		skewajiban_bayar = request.getParameterValues("kewajiban_bayar"),
		shak = request.getParameterValues("hak"),
		shak_bayar = request.getParameterValues("hak_bayar");

if(merchant==null)merchant="";
if(doc_number==null)doc_number="";
if(note==null)note="";
if(amount==null)amount="";


//=========================================
Calendar CAL = Calendar.getInstance();
SimpleDateFormat SDF = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
String timeNOW=SDF.format(CAL.getTime());
String outPUT = "";
//=========================================

SimpleDateFormat SDF2 = new SimpleDateFormat("dd/MM/yyyy");

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
		
		int deposit_id_old = 0; long amount_old = 0; String note_old = ""; String doc_number_old = "";
		if(!merchant.equals("") && !doc_number.equals("") && !note.equals("") && !amount.equals("")){
			// ambil dulu amount, doc,  deposit yang lama
			query = "select deposit_id,amount,doc_number,note from merchant_deposit where is_executed='0' and merchant_id='"+merchant+"'  and  doc_number='"+doc_number+"' and to_char(deposit_time,'DD/MM/YYYY') = to_char(sysdate,'DD/MM/YYYY')";
			System.out.println(query);
			stmt = con.createStatement();
			rs = stmt.executeQuery(query);
			if(rs.next()){
				deposit_id_old = rs.getInt("deposit_id");
				amount_old = rs.getLong("amount");
				note_old = rs.getString("note");
				doc_number_old = rs.getString("doc_number");
			}
			rs.close();stmt.close();
			
			// lalu adjust deposit yang lama
			query = "update merchant_deposit set amount="+amount+", doc_number='"+doc_number+"', note='"+note+" " +amount_old +"' where deposit_id='"+deposit_id_old+"'";
			System.out.println(query);
			pstmt = con.prepareStatement(query);
			pstmt.executeUpdate();
			pstmt.close();
			
			// update recon_selisih pertama ambil dulu kewajiban yang dibayarkan dan hak yang dibayarkan dari tiap bank
			// lalu cari apakah bank-bank tersebut ada di kelompok bank yang mempunyai tunggakan
			// setelah dijumlahkan baru dihitung dendanya
			int jml_bank_edit = 0;
			int jml_bank_pas = 0;
			if(sno!=null && skode_bank!=null && sbank_name!=null&& skewajiban!=null&& skewajiban_bayar!=null&& shak!=null&& shak_bayar!=null){
				
				for(int i=0;i<sno.length;i++){
			System.out.println("DEBUG|skode_bank:"+skode_bank[i]+", sbank_name:"+sbank_name[i]);		
					// ambil value dari hak lama 					
					long hak_old = -1;
					long kewajiban_old = -1;
					
					query = "select hak, kewajiban from recon_selisih where merchant_id='"+merchant+"' and settle_date='"+stanggal_laporan+"' and status=0 and bank_code='"+skode_bank[i]+"' and bank_name='"+sbank_name[i]+"'";
					System.out.println(query);
					stmt = con.createStatement();
					rs = stmt.executeQuery(query);
					if(rs.next()){
						hak_old = rs.getLong("hak");
						kewajiban_old = rs.getLong("kewajiban");
					}
					rs.close();stmt.close();
					
					System.out.println("DEBUG|hak_old:"+hak_old+", kewajiban_old:"+kewajiban_old);
						
					if(hak_old!=-1 && kewajiban_old!=-1){
						System.out.println("DEBUG|shak_bayar:"+shak_bayar[i]+", skewajiban_bayar:"+skewajiban_bayar[i]);
						if(hak_old == Long.parseLong(shak_bayar[i]) && kewajiban_old == Long.parseLong(skewajiban_bayar[i])){
							// cek apakah pas
							// pas atau tidak pas, tapi utang pas
							query = "update recon_selisih set keterangan='reconed|X|', status=1, solve_date=sysdate, hak_dibayarkan=hak, kewajiban_dibayarkan=kewajiban where merchant_id='"+merchant+"' and settle_date='"+stanggal_laporan+"' and status=0 and bank_code='"+skode_bank[i]+"' and bank_name='"+sbank_name[i]+"'";
							System.out.println(query);
							pstmt = con.prepareStatement(query);
							pstmt.executeUpdate();
							pstmt.close();
							
							jml_bank_pas++;
						}
						else{
							// hitung denda
							Long denda_hak = (hak_old - Long.parseLong(shak_bayar[i]) * (Long.parseLong(bunga_jibor)*Long.parseLong(hari_telat)))/360 ;
							Long denda_kewajiban = (kewajiban_old - Long.parseLong(skewajiban_bayar[i]) * (Long.parseLong(bunga_jibor)*Long.parseLong(hari_telat)))/360 ;
							if (denda_hak!=0 && denda_hak <=25000) 
								denda_hak = (long)25000;
							if (denda_kewajiban!=0 && denda_kewajiban <=25000) 
								denda_kewajiban = (long)25000;
							
							query = "update recon_selisih set keterangan='reconed|XX|', denda_hak="+denda_hak+",denda_kewajiban="+denda_kewajiban+", hak_dibayarkan="+shak_bayar[i]+", kewajiban_dibayarkan="+skewajiban_bayar[i]+" where merchant_id='"+merchant+"' and settle_date='"+stanggal_laporan+"' and status=0 and bank_code='"+skode_bank[i]+"' and bank_name='"+sbank_name[i]+"'";
							System.out.println(query);
							pstmt = con.prepareStatement(query);
							pstmt.executeUpdate();
							pstmt.close();
						}
						
						// counter
						jml_bank_edit++;
					}else{
						outPUT+=("Bank "+skode_bank[i]+" not existed|");
					}
				}
			}
			
			con.commit();
			out.println("<script language='javascript'>alert('Deposit Artajasa is successfully updated with amount Rp "+nf.format(Long.parseLong(amount))+" from old amount Rp "+nf.format(amount_old)+". There are "+jml_bank_edit+" banks edited. "+jml_bank_pas+" banks pay the exact amount.')</script>");
			outPUT+=("Deposit Artajasa is successful|"+merchant+"|"+doc_number+"|"+note+"|"+amount+"|"+sno.length+"|"+jml_bank_edit+"|"+jml_bank_pas+"|");
		}
	}
	
	//==cek untuk yang buka kedua kali
	if (ServletFileUpload.isMultipartContent(request)){
       
        Iterator i = fileItemsList.iterator();
        while(i.hasNext()){
			FileItem fi = (FileItem)i.next();
			if(!fi.isFormField()){
				String fileName = fi.getName();

				String saveFile = fileName.substring(fileName.lastIndexOf("\\")+1);
				String ext = saveFile.substring(saveFile.length()-3, saveFile.length());
				if(ext.equalsIgnoreCase("rts")){
					// write the file
					try {
						saveFile=saveFile.substring(0,saveFile.length()-4);
						saveFile+=timeNow;
						saveFile+=".rts";
						String pathTes = application.getRealPath("/")+"artajasa_claim";

						File fileTes = new File(pathTes);
						if(!fileTes.exists())fileTes.mkdirs();
						fi.write(new File(application.getRealPath("/")+"artajasa_claim", saveFile));
						pathFile = pathTes+"/"+saveFile;
						out.println("<script language='javascript'>alert('File upload is successful.')</script>");
						// System.out.println("File upload of "+saveFile+" is successful.");
						outPUT+=("File upload of "+saveFile+" is successful|");

					}
					catch (Exception e) {
						// System.out.println("File upload of "+saveFile+" is error. Error message:"+e.getMessage()+".");
						outPUT+=("File upload of "+saveFile+" is error. Error message:"+e.getMessage()+"|");
						out.println("<script language='javascript'>alert('File upload is error. Message : "+e.getMessage()+".')</script>");
					}
				}else{
					out.println("Please insert rts file.");
					outPUT+=("Please insert rts file.");
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
		
		ArrayList<String[]> records = new ArrayList<String[]>();
		ArrayList<String[]> records2 = new ArrayList<String[]>();
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
		String total_hak_terima_records = "";
		
		String total_hak_dibayarkan_records = "";
		
		String total_kewajiban_records = "";
		String total_kewajiban_bayar_records = "";
		
		String tanggal_laporan_records = "";
		
		String total_hak_records2 = "";
		String total_hak_terima_records2 = "";
		String total_kewajiban_records2 = "";
		String total_kewajiban_bayar_records2 = "";
		String tanggal_laporan_records2 = "";
		
		fileIn = new BufferedReader(new FileReader(pathFile));
        
		while((thisLine=fileIn.readLine())!=null){	
			// System.out.println(thisLine + "length " +thisLine.length());
			
			if(thisLine.contains("LAPORAN HASIL SETTLEMENT ANTAR BANK ANGGOTA")){
				startLaporan = true;
				startLaporan2 = false;
			}
			if(thisLine.contains("RINCIAN HASIL SETTLEMENT ANTAR BANK YANG MEMPUNYAI TUNGGAKAN")){
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
			
			if(thisLine.contains("TOTAL NILAI SETTLEMENT")){				
				if(startLaporan){
					total_kewajiban_records = ((thisLine.substring(56,72)).trim()).replaceAll(",","");
					total_kewajiban_bayar_records = ((thisLine.substring(75,93)).trim()).replaceAll(",","");
					total_hak_records = ((thisLine.substring(96,114)).trim()).replaceAll(",","");
					total_hak_terima_records = ((thisLine.substring(117,thisLine.length()-3)).trim()).replaceAll(",","");			
				}else if(startLaporan2){
					total_kewajiban_records2 = ((thisLine.substring(56,72)).trim()).replaceAll(",","");
					total_kewajiban_bayar_records2 = ((thisLine.substring(75,93)).trim()).replaceAll(",","");
					total_hak_records2 = ((thisLine.substring(96,114)).trim()).replaceAll(",","");
					total_hak_terima_records2 = ((thisLine.substring(117,thisLine.length()-3)).trim()).replaceAll(",","");
				}
			}
			
			if(thisLine.contains("TOTAL HAK YANG DIBAYARKAN ARTAJASA")){				
				total_hak_dibayarkan_records = ((thisLine.substring(117,thisLine.length()-3)).trim()).replaceAll(",","");
			}
			
			if(thisLine.contains("No. Snd Bank  Nama Bank ")){
				thisLine=fileIn.readLine();thisLine=fileIn.readLine();
				startRecords = true;
			}
			
			if(startRecords==true && (thisLine.length()==0 || (thisLine.trim()).equals(""))){
				startRecords = false;
			}
			
			if(startRecords){
				// start fetching records
				String [] records_detail = new String [7];
				records_detail[0] = (thisLine.substring(4,9)).trim();
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
		System.out.println("DEBUG|records.size()"+records.size());
		System.out.println("DEBUG|records2.size()"+records2.size());

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
				temp_records[3] = (Long.parseLong(temp_records[3]) + Long.parseLong(records2.get(search)[3])) + "";
				temp_records[4] = (Long.parseLong(temp_records[4]) + Long.parseLong(records2.get(search)[4])) + "";
				temp_records[5] = (Long.parseLong(temp_records[5]) + Long.parseLong(records2.get(search)[5])) + "";
				temp_records[6] = (Long.parseLong(temp_records[6]) + Long.parseLong(records2.get(search)[6])) + "";
				records3.add(temp_records);
				index_recon_records3 += search+",";
				//System.out.println("DEBUG|temp_records[5]:"+temp_records[5]+", records.get(i)[5]:"+records.get(i)[5]);
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
					records3.add(records2.get(i));
				}
			}
		}else{
			for(int i=0;i<records2.size();i++){
				records3.add(records2.get(i));
			}
		}
		System.out.println("DEBUG|Masuk sini5");	
		
		
		
		// =============================================================
		}else{
			for(int i=0;i<records.size();i++){
				records3.add(records.get(i));
			}
		}
		
		System.out.println("DEBUG|records3.size()"+records3.size());
		// keluarkan data recon_selisih hari terakhir yang masih belum solved dan pasangkan dengan data di RTG
		// bandingkan 2 arraylist records dan records2
		
		// pencocokan antara database dan RTG
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
		// filter records and add to db_recon
		for(int i=0;i<records.size();i++){
			int search = findRecon(records2, records.get(i)[1], records.get(i)[2]);
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
		
			// filter records and add to db_unrecon
			for(int i=0;i<records.size();i++){
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
			// filter records and add to db_unrecon
			for(int i=0;i<records.size();i++){
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
		boolean is_differs = true;
		// checking if there is one single difference between hak and kewajiban. If there is, then show the form
		for(int i=0;i<records3.size();i++){
			if(!(records3.get(i)[3]).equals(records3.get(i)[4]) || !(records3.get(i)[5]).equals(records3.get(i)[6])){
				is_differs = false;
				break;
			}
		}
		System.out.println("Show Data");
		// show data
		%>
		<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> SUMMARY LAPORAN RTS </strong></font></div>
		<br />		
		<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
			<thead>
				<td colspan="3"><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> LAPORAN HASIL SETTLEMENT ANTAR BANK ANGGOTA </strong></font></div></td>
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
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total Hak </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(total_hak_records)%> </font></div></td>
			</tbody>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total Hak Terima </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(total_hak_terima_records)%> </font></div></td>
			</tbody>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Total Hak yang Dibayarkan </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> : </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> <%=get_decimal(total_hak_dibayarkan_records)%> </strong></font></div></td>
			</tbody>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total Kewajiban </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(total_kewajiban_records)%> </font></div></td>
			</tbody>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Total Kewajiban yg Harus Dibayar </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> : </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> <%=get_decimal(total_kewajiban_bayar_records)%> </strong></font></div></td>
			</tbody>
		</table>
		
		<br />		
		<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
			<thead>
				<td colspan="3"><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> RINCIAN HASIL SETTLEMENT ANTAR BANK YANG MEMPUNYAI TUNGGAKAN </strong></font></div></td>
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
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Jumlah Campuran Bank Kewajiban dan Tunggakan </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=(records3.size()!=0)?records3.size()-2:"0"%> </font></div></td>
			</tbody>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total Hak </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(total_hak_records2)%> </font></div></td>
			</tbody>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total Hak Terima </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(total_hak_terima_records2)%> </font></div></td>
			</tbody>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total Kewajiban </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(total_kewajiban_records2)%> </font></div></td>
			</tbody>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total Kewajiban yg Harus Dibayar </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(total_kewajiban_bayar_records2)%> </font></div></td>
			</tbody>
		</table>
		
		<br />
			
		<%
		System.out.println("print the hidden form for processing");
		// print the hidden form for processing %>
		<form action='uploadArtajasaRTS.jsp' method='post'>
			<input type='hidden' name='idLog1' value='<%=encLog%>'>
			<input type='hidden' name='idLog2' value='<%=encPass%>'>
			
			<input type='hidden' name='tanggal_laporan_records' value='<%=tanggal_laporan_records%>'>
			<input type='hidden' name='sandi_bank_records' value='<%=sandi_bank_records%>'>
			<input type='hidden' name='nama_bank_records' value='<%=nama_bank_records%>'>
			
			<input type='hidden' name='total_hak_records' value='<%=total_hak_terima_records.replaceAll(",","")%>'>
			<input type='hidden' name='total_kewajiban_records' value='<%=total_kewajiban_bayar_records.replaceAll(",","")%>'>
			
			<input type='hidden' name='doc_number' value='<%=SDF2.format(cal.getTime())%>'>
			<input type='hidden' name='note' value='Deposit Artajasa - Adjusted from '>
			
			<%for(int i=0;i<records3.size();i++){%>
				<input type='hidden' name='no' value='<%=records3.get(i)[0]%>'>
				<input type='hidden' name='kode_bank' value='<%=records3.get(i)[1]%>'>
				<input type='hidden' name='bank_name' value='<%=records3.get(i)[2]%>'>
				<input type='hidden' name='kewajiban' value='<%=records3.get(i)[3].replaceAll(",","")%>'>
				<input type='hidden' name='kewajiban_bayar' value='<%=records3.get(i)[4].replaceAll(",","")%>'>
				<input type='hidden' name='hak' value='<%=records3.get(i)[5].replaceAll(",","")%>'>
				<input type='hidden' name='hak_bayar' value='<%=records3.get(i)[6].replaceAll(",","")%>'>
			<%}%>

			<%
			/*
			if(!index_recon_detail.equals("")){
			for(int i=0;i<index_recon.length;i++){
				%>
				<input type='hidden' name='rkode_bank' value='<%=records.get(Integer.parseInt(index_recon[i]))[1]%>'>
				<input type='hidden' name='rnama_bank' value='<%=records.get(Integer.parseInt(index_recon[i]))[2]%>'>
				<input type='hidden' name='rkewajiban' value='<%=records2.get(Integer.parseInt(index_recon2[i]))[3]%>'>
				<input type='hidden' name='rkewajiban_bayar' value='<%=records2.get(Integer.parseInt(index_recon2[i]))[4]%>'>
				<input type='hidden' name='rhak' value='<%=records2.get(Integer.parseInt(index_recon2[i]))[5]%>'>
				<input type='hidden' name='rhak_terima' value='<%=records2.get(Integer.parseInt(index_recon2[i]))[6]%>'>
				<%
			}
			}
			*/
			%>
			
			
			<input type='hidden' name='amount' value='<%=total_hak_dibayarkan_records.substring(0, total_hak_dibayarkan_records.length()).replaceAll(",","")%>'>
			
			<font size="1" face="Verdana, Arial, Helvetica, sans-serif"> 
			<%if(!is_differs){%>Bunga Jibor : <input type='text' name='bunga_jibor' value="0"> | Hari Telat : <input type='text' name='hari_telat' value="1"> | <%}%>
			<input type='submit' value='Proceed to Deposit Adjustment' onclick='return checkExecute2();'>
			</font>
			
		</form>
		
		<hr />
		
		<%		
		// ===========================================================
		System.out.println("Print the recon result.");
		// Print the recon result.		
		int no_idx = 0;
		System.out.println("DEBUG|SHOW RECON DETAIL");
		%>
		<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> ==RECON DETAIL - With Current Data== RECON Kewajiban dan Tunggakan </strong></font></div>
		
		<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
			<thead>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Sandi Bank </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Nama Bank </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Total Kewajiban </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Total Kewajiban <br /> Dibayarkan </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Total Hak </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Total Hak <br /> Diterima </strong></font></div></td>
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
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(records3.get(i)[3])%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(records3.get(i)[4])%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(records3.get(i)[5])%> </font></div></td>
					<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(records3.get(i)[6])%> </font></div></td>
				</tbody>
			<%
			no_idx++;
		}
		
		%>
		</table>
		
		<br />
		<%/*%>
		<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> ==RECON DETAIL== Laporan Settlement Bank yang ada Tunggakan </strong></font></div>
		<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
			<thead>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Sandi Bank </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Nama Bank </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Kewajiban </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Pembayaran <br /> Kewajiban </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Hak </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Hak <br /> Yang Diterima </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tunggakan <br /> Kewajiban </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tunggakan <br /> Pembayaran Kewajiban </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tunggakan <br /> Hak </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Tunggakan <br /> Hak yg Diterima </strong></font></div></td>
			</thead>
		
		
		<%		
		System.out.println("display output first is for reconed, unrecon on records2 and unrecon on records");
		no_idx = 1;
		if(!index_recon_detail.equals("")){
		for(int i=0;i<index_recon.length;i++){
			%>
			<tbody>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=no_idx%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=records.get(Integer.parseInt(index_recon[i]))[1]%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=records.get(Integer.parseInt(index_recon[i]))[2]%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(records.get(Integer.parseInt(index_recon[i]))[3])%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(records.get(Integer.parseInt(index_recon[i]))[4])%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(records.get(Integer.parseInt(index_recon[i]))[5])%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(records.get(Integer.parseInt(index_recon[i]))[6])%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(records2.get(Integer.parseInt(index_recon2[i]))[3])%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(records2.get(Integer.parseInt(index_recon2[i]))[4])%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(records2.get(Integer.parseInt(index_recon2[i]))[5])%> </font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%=get_decimal(records2.get(Integer.parseInt(index_recon2[i]))[6])%> </font></div></td>
			</tbody>
			<%
			no_idx++;
		}
		}		
		%>
		</table>
		<%*/%>
		<hr />
		<%
		System.out.println("end of printing recon result");
		
		// end of printing recon result
		// ========================================================
		%>
		<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> DETAIL LAPORAN HASIL SETTLEMENT ANTAR BANK ANGGOTA </strong></font></div>
		
		<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
			<thead>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Kode Bank </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Nama Bank </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Kewajiban </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Pembayaran <br /> Kewajiban </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Hak </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Hak <br /> yg diterima </strong></font></div></td>
			</thead>
			
			
		<%		
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

		<br />	
		<div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> DETAIL RINCIAN HASIL SETTLEMENT ANTAR BANK YANG MEMPUNYAI TUNGGAKAN </strong></font></div>
		
		<table border="1" bordercolor="#FFF6EF" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
			<thead>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> No </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Kode Bank </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Nama Bank </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Kewajiban </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Pembayaran <br /> Kewajiban </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Hak </strong></font></div></td>
				<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Hak <br /> yg diterima </strong></font></div></td>
			</thead>
			
			
		<%		
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
		
		<hr />
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
			System.out.println("["+timeNOW+"]uploadArtajasaRTS.jsp|"+outPUT);
		//=====================================================================//
	}
	catch(Exception e){}
}
%>		
		<p>Please input today's ATM bersama .rts extension file to upload</p>
		<form action="uploadArtajasaRTS.jsp" enctype="multipart/form-data" method="post">                                                                       
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
