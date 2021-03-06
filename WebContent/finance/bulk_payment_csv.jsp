<%@page import="java.io.*, java.util.*, java.text.*, java.sql.*"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%
String comm = request.getParameter("comm");


%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Bulk Payment CSV Maker">
	<stripes:layout-component name="contents">
<%
//=========================================
Calendar CAL = Calendar.getInstance();
SimpleDateFormat SDF = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
String timeNOW=SDF.format(CAL.getTime());
String outPUT = "";
//=========================================

Connection con = null;
Statement stmt = null;
PreparedStatement pstmt = null;
PreparedStatement pstmt2 = null;
ResultSet rs = null;

String TotalDetailRecords = "";
String TotalData = "";
String TotalAmount = "";
String JumlahBaris = "";
String TanggalTransaksi = "";
String TotalNominal = "";

String TotalDetailRecords_bni = "";
String TotalData_bni = "";
String TotalAmount_bni = "";
String JumlahBaris_bni = "";
String TanggalTransaksi_bni = "";
String TotalNominal_bni = "";

Boolean existt = false;

try{
	//untuk keperluan save as csv Mandiri
	String DATE_FORMAT_NOW = "ddMMyyyy_HHmmss";
	String DATE_FORMAT_NOW2 = "yyyyMMdd";
	String DATE_FORMAT_NOW3 = "yyyyMMddHHmmss";
	String DATE_FORMAT_NOW4 = "ddMMyyyy";
	String DATE_FORMAT_NOW5 = "dd-MM-yyyy";
	
	//untuk keperluan save as csv BNI
	String DATE_FORMAT_NOW_BNI = "dd/MM/yyyy hh:mm:ss a";
	String DATE_FORMAT_NOW2_BNI = "yyyyMMdd";
	
	Calendar cal = Calendar.getInstance();
	
	SimpleDateFormat sdf = new SimpleDateFormat(DATE_FORMAT_NOW);
	String time=sdf.format(cal.getTime());
	SimpleDateFormat sdf2 = new SimpleDateFormat(DATE_FORMAT_NOW2);
	String time2=sdf2.format(cal.getTime());
	SimpleDateFormat sdf3 = new SimpleDateFormat(DATE_FORMAT_NOW3);
	String time3=sdf3.format(cal.getTime());
	SimpleDateFormat sdf4 = new SimpleDateFormat(DATE_FORMAT_NOW4);
	String time4=sdf4.format(cal.getTime());
	SimpleDateFormat sdf5 = new SimpleDateFormat(DATE_FORMAT_NOW5);
	String time5=sdf5.format(cal.getTime());
	
	SimpleDateFormat sdf_bni = new SimpleDateFormat(DATE_FORMAT_NOW_BNI);
	String time_bni=sdf_bni.format(cal.getTime());
	SimpleDateFormat sdf_bni2 = new SimpleDateFormat(DATE_FORMAT_NOW2_BNI);
	String time_bni2=sdf_bni2.format(cal.getTime());
	
	
    con = DbCon.getConnection();
	String [] _month = {"I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII"};
	String [] _date = null;
	%>
    <table width='90%' border='1' cellspacing='0' cellpadding='0' bordercolor='#FFF6EF'>
    <tr>
		<td colspan='10'><div align='right'><font color='#CC6633' size='2' face='Verdana, Arial, Helvetica, sans-serif'><strong>.:: Cashout List Mandiri</strong></font></div>
		</td>
	</tr>
    
    <tr>
		<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Cashout ID</strong></font></div></td>
		<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Merchant ID</strong></font></div></td>
		<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Deposit Time</strong></font></div></td>
		<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Amount</strong></font></div></td>
		<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Note</strong></font></div></td>
		<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Entry Login</strong></font></div></td>
		<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Bank Acc No</strong></font></div></td>
		<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Bank Acc Holder</strong></font></div></td>
		<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Tsel Bank Acc</strong></font></div></td>
		<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Bank Name</strong></font></div></td>
	</tr>
    <%
	pstmt = con.prepareStatement("select b.CASHOUT_ID, b.MERCHANT_ID, b.DEPOSIT_TIME, b.AMOUNT, b.NOTE, b.ENTRY_LOGIN, c.BANK_ACC_NO, c.BANK_ACC_HOLDER, c.TSEL_BANK_ACC, c.BANK_NAME from merchant a, merchant_cashout b, merchant_info c where b.MERCHANT_ID=a.MERCHANT_ID AND a.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID AND b.IS_EXECUTED='1' AND b.PRINT_DATE IS NOT NULL AND (b.PRINT_DATE between to_date('"+time5+" 00:00:00','DD-MM-YYYY HH24:MI:SS') AND sysdate) AND b.COMPLETION_DATE IS NULL AND b.RECEIPT_ID IS NOT NULL AND c.BANK_NAME LIKE '%andiri' ORDER BY DEPOSIT_TIME DESC");
	rs = pstmt.executeQuery();            
    while(rs.next()){
		existt = true;
		%>
		<tr><td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("CASHOUT_ID") %></font></div></td>
		<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("MERCHANT_ID") %></font></div></td>
		<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("DEPOSIT_TIME") %></font></div></td>
		<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("AMOUNT") %></font></div></td>
		<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("NOTE") %></font></div></td>
		<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("ENTRY_LOGIN") %></font></div></td>
		<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("BANK_ACC_NO") %></font></div></td>
		<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("BANK_ACC_HOLDER") %></font></div></td>
		<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("TSEL_BANK_ACC") %></font></div></td>
		<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("BANK_NAME") %></font></div></td></tr>
		<%
	}            
    pstmt.close();rs.close();
    %>
	</table>
	
	<table width='90%' border='1' cellspacing='0' cellpadding='0' bordercolor='#FFF6EF'>
    <tr>
		<td colspan='10'><div align='right'><font color='#CC6633' size='2' face='Verdana, Arial, Helvetica, sans-serif'><strong>.:: Cashout List BNI</strong></font></div>
		</td>
	</tr>
    
    <tr>
		<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Cashout ID</strong></font></div></td>
		<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Merchant ID</strong></font></div></td>
		<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Deposit Time</strong></font></div></td>
		<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Amount</strong></font></div></td>
		<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Note</strong></font></div></td>
		<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Entry Login</strong></font></div></td>
		<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Bank Acc No</strong></font></div></td>
		<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Bank Acc Holder</strong></font></div></td>
		<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Tsel Bank Acc</strong></font></div></td>
		<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Bank Name</strong></font></div></td>
	</tr>
    <%
	pstmt = con.prepareStatement("select b.CASHOUT_ID, b.MERCHANT_ID, b.DEPOSIT_TIME, b.AMOUNT, b.NOTE, b.ENTRY_LOGIN, c.BANK_ACC_NO, c.BANK_ACC_HOLDER, c.TSEL_BANK_ACC, c.BANK_NAME from merchant a, merchant_cashout b, merchant_info c where b.MERCHANT_ID=a.MERCHANT_ID AND a.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID AND b.IS_EXECUTED='1' AND b.PRINT_DATE IS NOT NULL AND (b.PRINT_DATE between to_date('"+time5+" 00:00:00','DD-MM-YYYY HH24:MI:SS') AND sysdate) AND b.COMPLETION_DATE IS NULL AND b.RECEIPT_ID IS NOT NULL AND c.BANK_NAME LIKE '%BNI%' ORDER BY DEPOSIT_TIME DESC");
	rs = pstmt.executeQuery();            
    while(rs.next()){
		existt = true;
		%>
		<tr><td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("CASHOUT_ID") %></font></div></td>
		<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("MERCHANT_ID") %></font></div></td>
		<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("DEPOSIT_TIME") %></font></div></td>
		<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("AMOUNT") %></font></div></td>
		<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("NOTE") %></font></div></td>
		<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("ENTRY_LOGIN") %></font></div></td>
		<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("BANK_ACC_NO") %></font></div></td>
		<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("BANK_ACC_HOLDER") %></font></div></td>
		<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("TSEL_BANK_ACC") %></font></div></td>
		<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("BANK_NAME") %></font></div></td></tr>
		<%
	}            
    pstmt.close();rs.close();
    %>
	</table>
	
	
	
	
	
	<%  
    if(comm!=null && comm.equalsIgnoreCase("save") && existt){
        try{
            String pathTes = application.getRealPath("/")+"CSV";
            File fileTes = new File(pathTes);
            if(!fileTes.exists())fileTes.mkdirs();
        }catch(Exception eee){}
        
		// parameter Mandiri
        String fileName = "Mandiri_"+time+".csv";
        String pathFile = application.getRealPath("/")+"CSV/"+fileName;
		String ContentHeaderMarker = "P";
        String DebitAccountNumber = "";

        pstmt = con.prepareStatement("select distinct TSEL_BANK_ACC  from MERCHANT_INFO WHERE BANK_NAME LIKE '%andiri'");
        rs = pstmt.executeQuery();            
        if(rs.next())
			DebitAccountNumber = rs.getString("TSEL_BANK_ACC");           
        pstmt.close();rs.close();

        String TransactionInstructionDate = time2;
        
        pstmt = con.prepareStatement("select count(*) as jml from merchant a, merchant_cashout b, merchant_info c where b.MERCHANT_ID=a.MERCHANT_ID AND a.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID AND b.IS_EXECUTED='1' AND b.PRINT_DATE IS NOT NULL AND (b.PRINT_DATE between to_date('"+time5+" 00:00:00','DD-MM-YYYY HH24:MI:SS') AND sysdate) AND b.COMPLETION_DATE IS NULL AND b.RECEIPT_ID IS NOT NULL AND c.BANK_NAME LIKE '%andiri%'");
        rs = pstmt.executeQuery();            
        if(rs.next())
            TotalDetailRecords = String.valueOf(rs.getInt("jml"));           
        pstmt.close();rs.close();
        
		//============================
		if(!TotalDetailRecords.equals("0")){
			pstmt = con.prepareStatement("select SUM(b.AMOUNT) AS TOTALAMOUNT from merchant a, merchant_cashout b, merchant_info c where b.MERCHANT_ID=a.MERCHANT_ID AND a.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID  AND c.BANK_NAME LIKE '%andiri%' AND b.PRINT_DATE IS NOT NULL AND (b.PRINT_DATE between to_date('"+time5+" 00:00:00','DD-MM-YYYY HH24:MI:SS') AND sysdate) AND b.COMPLETION_DATE IS NULL AND b.RECEIPT_ID IS NOT NULL AND b.IS_EXECUTED='1'");
			rs = pstmt.executeQuery();            
			if(rs.next())
					TotalAmount = String.valueOf(rs.getInt("TOTALAMOUNT"));           
			pstmt.close();rs.close();
		}
		
        // parameter BNI
        String fileName2 = "BNI_"+time+".csv";
        String pathFile2 = application.getRealPath("/")+"CSV/"+fileName2;
		String HeaderMarker = "P";
        String RekDebet = "";
        
		pstmt = con.prepareStatement("select distinct TSEL_BANK_ACC from MERCHANT_INFO WHERE BANK_NAME like '%BNI%'");
        rs = pstmt.executeQuery();
        if(rs.next())
            RekDebet = (rs.getString("TSEL_BANK_ACC")).substring(1);           
        pstmt.close();rs.close();
        
        String FileCreationTime = time_bni;
        
        pstmt = con.prepareStatement("select Count(*) as jml from merchant a, merchant_cashout b, merchant_info c where b.MERCHANT_ID=a.MERCHANT_ID AND a.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID AND b.IS_EXECUTED='1' AND b.PRINT_DATE IS NOT NULL  AND (b.PRINT_DATE between to_date('"+time5+" 00:00:00','DD-MM-YYYY HH24:MI:SS') AND sysdate) AND b.COMPLETION_DATE IS NULL AND b.RECEIPT_ID IS NOT NULL AND c.BANK_NAME LIKE '%BNI%' ORDER BY DEPOSIT_TIME DESC");
        rs = pstmt.executeQuery();            
        if(rs.next())
			TotalData = String.valueOf(rs.getInt("jml"));          
        pstmt.close();rs.close();
		
		// BNI =================
        if(!TotalData.equals("0")){
			JumlahBaris = String.valueOf(2+Integer.valueOf(TotalData));
			TanggalTransaksi = time2;

			pstmt = con.prepareStatement("select SUM(b.AMOUNT) AS TOTALAMOUNT from merchant a, merchant_cashout b, merchant_info c where b.MERCHANT_ID=a.MERCHANT_ID AND a.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID  AND c.BANK_NAME LIKE '%BNI%' AND b.IS_EXECUTED='1' AND b.PRINT_DATE IS NOT NULL AND (b.PRINT_DATE between to_date('"+time5+" 00:00:00','DD-MM-YYYY HH24:MI:SS') AND sysdate) AND b.COMPLETION_DATE IS NULL AND b.RECEIPT_ID IS NOT NULL");
			rs = pstmt.executeQuery();
			if(rs.next())
				TotalNominal = String.valueOf(rs.getInt("TOTALAMOUNT"));
			pstmt.close();rs.close();
        }
        
		// Mandiri ===============
        if(!TotalDetailRecords.equals("0")){		
			// SAVE Mandiri CSV
			String content = "";
			
			pstmt = con.prepareStatement("select to_char(b.PRINT_DATE, 'YYYY') as THN, to_char(b.PRINT_DATE, 'MM') as MNT, b.RECEIPT_ID,b.CASHOUT_ID, b.MERCHANT_ID, b.DEPOSIT_TIME, b.AMOUNT, b.NOTE, b.ENTRY_LOGIN, c.BANK_ACC_NO, c.BANK_ACC_HOLDER, c.TSEL_BANK_ACC, c.BANK_NAME from merchant a, merchant_cashout b, merchant_info c where b.MERCHANT_ID=a.MERCHANT_ID AND a.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID AND b.IS_EXECUTED='1' AND b.PRINT_DATE IS NOT NULL AND (b.PRINT_DATE between to_date('"+time5+" 00:00:00','DD-MM-YYYY HH24:MI:SS') AND sysdate) AND b.COMPLETION_DATE IS NULL AND b.RECEIPT_ID IS NOT NULL AND c.BANK_NAME LIKE '%andiri%' ORDER BY DEPOSIT_TIME DESC");
			rs = pstmt.executeQuery();            
			con.setAutoCommit(false);
			while(rs.next()){
				content+= rs.getString("BANK_ACC_NO")+",";
				content+= rs.getString("BANK_ACC_HOLDER")+",";
				content+="Indonesia,,,IDR,";
				content+= rs.getString("AMOUNT")+",";
				// naruh remark disini, maksimum karakter 20 karakter
				// check for daily settlement format
				content+= _month[rs.getInt("MNT")-1]+"/"+rs.getString("THN")+",";
				outPUT+=(rs.getString("CASHOUT_ID")+"|");
				if(rs.getString("NOTE").equals("Daily Settlement"))
					content+=rs.getString("CASHOUT_ID")+ " " + "DS_" + time4+ ",";
				else
					content+=rs.getString("CASHOUT_ID")+ " " +rs.getString("NOTE")+",";
				content+="IBU,,,";
				content+=",,,,Y";
				content+=",lisa_rahmawati@telkomsel.co.id,,,,,,,,,,,,,,,,,,,,,,,extended detail will be sent\n";
				
				//update is_executed=3
				pstmt2 = con.prepareStatement("UPDATE merchant_cashout SET is_executed = '3' WHERE cashout_id = '"+rs.getString("CASHOUT_ID")+"'");
				pstmt2.executeUpdate();
				pstmt2.close();
			}            
			pstmt.close();rs.close();		

			//menulis ke file menggunakan FileWriter (MASIH MANDIRI)
			try{
				File f = new File(pathFile);
				if(!f.exists()){
					f.createNewFile();
					out.println("<a href='file_download.jsp?pathFile="+pathFile+"&fileName="+fileName+"'>"+fileName+"</a> <br />");
					}else{
					out.println("Error, file is exist <br />");
				}
				
				// Create file
				BufferedWriter output = new BufferedWriter(new FileWriter(pathFile));
				output.write(ContentHeaderMarker+","+TransactionInstructionDate+","+DebitAccountNumber+","+TotalDetailRecords+","+TotalAmount+"\n");
				
				output.write(content);
				// Close the output stream
				output.close();
				//out.println("File Mandiri has been written. To save file, click right at it and Save Target As. <br />");
				con.commit();
				outPUT+="Mandiri file written,"+pathFile+","+fileName+"|";
			}catch (Exception e){//Catch exception if any
				out.println("Error: " + e.getMessage()+"<br />");
				con.rollback();
			}
			finally{
				con.setAutoCommit(true);
			}
		}

		// BNI ==============
		if(!TotalData.equals("0")){			
			
			// SAVE BNI CSV
			String content2 = "";

			pstmt = con.prepareStatement("select b.CASHOUT_ID, b.MERCHANT_ID, b.DEPOSIT_TIME, b.AMOUNT, b.NOTE, b.ENTRY_LOGIN, c.BANK_ACC_NO, c.BANK_ACC_HOLDER, c.TSEL_BANK_ACC, c.BANK_NAME from merchant a, merchant_cashout b, merchant_info c where b.MERCHANT_ID=a.MERCHANT_ID AND a.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID AND b.IS_EXECUTED='1' AND b.PRINT_DATE IS NOT NULL AND (b.PRINT_DATE between to_date('"+time5+" 00:00:00','DD-MM-YYYY HH24:MI:SS') AND sysdate) AND b.COMPLETION_DATE IS NULL AND b.RECEIPT_ID IS NOT NULL AND c.BANK_NAME LIKE '%BNI%' ORDER BY DEPOSIT_TIME DESC");
			rs = pstmt.executeQuery();
			
			con.setAutoCommit(false);

			while(rs.next()){
				content2+= rs.getString("BANK_ACC_NO")+",";
				content2+= rs.getString("BANK_ACC_HOLDER")+",";
				content2+= rs.getString("AMOUNT")+",";
				
				//Disini naruh remarknya, ada 3 remark dengan masing2 remark maximum 33 karakter
				if(rs.getString("NOTE").equals("Daily Settlement"))
					content2+= rs.getString("CASHOUT_ID") + " " + "DS_" + time4 + ",";
				else
					content2+= rs.getString("CASHOUT_ID") + " " + rs.getString("NOTE") + ",";
				
				outPUT+=(rs.getString("CASHOUT_ID")+"|");				
				content2+=",,,,,,,,,,,,N,,,N\n";
				
				//update is_executed = 3
				pstmt2 = con.prepareStatement("UPDATE merchant_cashout SET is_executed = '3' WHERE cashout_id = '"+rs.getString("CASHOUT_ID")+"'");
				pstmt2.executeUpdate();
				pstmt2.close();
				
			}
			pstmt.close();rs.close();

			//menulis ke file menggunakan FileWriter (SUDAH BNI)
			try{
				// Create file

				File f2 = new File(pathFile2);
				if(!f2.exists()){
					f2.createNewFile();
					out.println("<a href='file_download.jsp?pathFile="+pathFile2+"&fileName="+fileName2+"'>"+fileName2+"</a> <br />");
				}else{
					out.println("Error, file is exist <br />");
				}
				
				BufferedWriter output2 = new BufferedWriter(new FileWriter(pathFile2));
				output2.write(FileCreationTime+","+JumlahBaris+",,,,,,,,,,,,,,,,,,\n"+HeaderMarker+","+TanggalTransaksi+","+RekDebet+","+TotalData+","+TotalNominal+",,,,,,,,,,,,,,,\n");
				output2.write(content2);
				// Close the output stream
				output2.close();
				//out.println("File BNI has been written. To save file, click right at it and Save Target As. <br />");
				con.commit();
				outPUT+="BNI file written,"+pathFile+","+fileName+"|";
			}catch (Exception e){
				out.println("Error: " + e.getMessage()+"<br />");
				con.rollback();
			}
			finally{
				con.setAutoCommit(true);
			}
		}
	}
}
catch(Exception e){
	e.printStackTrace(System.out);
	out.println("<br/ > <b> Database error, automation failed, please proceed with manual process.</b>");
	//System.out.println("<br/ > <b> Database error, automation failed, please proceed with manual process.</b>");
	
	try{con.rollback();} catch(Exception e2){}
	outPUT+=("Exception occured,error:"+e.getMessage());
}
finally{
	try{
		if(con!=null) con.close();
		if(rs!=null) rs.close();
		if(stmt!=null) stmt.close();
		if(pstmt!=null) pstmt.close();
	}
	catch(Exception e){}
	//=====================================================================//
	if (!outPUT.equals(""))
		System.out.println("["+timeNOW+"]bulk_payment_csv.jsp|"+outPUT);
	//=====================================================================//
}
if(existt){

%>
                
        <form action="bulk_payment_csv.jsp">
            Save as CSV file
            <input type="submit" value="Save" />
            <input type="hidden" name="comm" value="save">
        </form>
		
<%
}
%>
	</stripes:layout-component>
</stripes:layout-render>
