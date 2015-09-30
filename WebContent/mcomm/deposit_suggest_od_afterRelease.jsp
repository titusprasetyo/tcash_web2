<%-- 
    Document   : deposit_suggest_od
    Created on : Apr 5, 2010, 12:04:39 PM
    Author     : madeady
--%>

<%@page import="java.io.*, java.util.*, java.text.*, java.sql.*"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<jsp:useBean id="reg" scope="request" class="tsel_tunai.Register2Bean"></jsp:useBean>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>

<%!
String insertDeposit(Connection con, String merchant_id, String amount, String doc_number, String note, String login, String ip_address)throws SQLException{
	String ret = "99;Error";
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	String sql = "";
	try{
		sql = "insert into MERCHANT_DEPOSIT (MERCHANT_ID, AMOUNT, DOC_NUMBER, NOTE, DEPOSIT_TIME, EXEC_TIME, IS_EXECUTED, ENTRY_LOGIN) VALUES ('"+merchant_id+"',"+amount+",'"+doc_number+"','"+note+"',sysdate,sysdate,'1','"+login+"')"; //returning deposit_id into OracleTypes.STRING";
		//System.out.println(sql);
		pstmt = con.prepareStatement(sql, new String[] {"deposit_id"});
		pstmt.executeUpdate();
		rs = pstmt.getGeneratedKeys();
		String newId = "0";
		if(rs.next()){
		   newId = rs.getString(1);
		}
		pstmt.close();rs.close();
		
		sql = "INSERT INTO ACTIVITY_LOG (USERLOGIN, ACCESS_TIME, ACTIVITY, NOTE, IP, REASON) values ('"+login+"', sysdate, 'Merchant Deposit Insertion', 'Virtual Account', '"+ip_address+"', '-')";
		pstmt = con.prepareStatement(sql);
		pstmt.executeUpdate();
		pstmt.close();
		
		ret = "00;"+newId;
	}catch(Exception e){
		e.printStackTrace(System.out);
		con.rollback();
		ret = "99;DB Error:"+e.getMessage();
	}finally{
		if(pstmt!=null) pstmt.close();
		if(rs!=null) rs.close();
	}
	return ret;
}
%>

<%!
String updateAccount(Connection con, String merchant_id, String tx_date, String tipe, String description, String amount)throws SQLException{
	String ret = "99;Error";
	PreparedStatement pstmt = null;
	String sql = "";
	
	try{
		sql = "UPDATE ACC_STATEMENT SET REF='"+merchant_id+"' WHERE TX_DATE=TO_DATE('"+tx_date.substring(0,10)+"', 'YYYY-MM-DD') AND TIPE='"+tipe+"' AND DESCRIPTION='"+description+"' AND AMOUNT="+amount;
		pstmt = con.prepareStatement(sql);
		pstmt.executeUpdate();
		pstmt.close();
		System.out.println(sql);
		
		ret = "00;"+merchant_id;
	}catch(Exception e){
		e.printStackTrace(System.out);
		con.rollback();
		ret = "99;DB Error";
	}finally{
		if(pstmt!=null) pstmt.close();
	}
	return ret;
}
%>


<%!
String deleteAccount(Connection con, String tx_date, String description, String amount, String tipe)throws SQLException{
	String ret = "99;Error";
	PreparedStatement pstmt = null;
	String sql = "";
	
	try{
		sql = "DELETE FROM ACC_STATEMENT WHERE TX_DATE=TO_DATE('"+tx_date.substring(0,10)+"', 'YYYY-MM-DD') AND TIPE='"+tipe+"' AND DESCRIPTION='"+description+"' AND AMOUNT="+amount;
		pstmt = con.prepareStatement(sql);
		pstmt.executeUpdate();
		pstmt.close();
		System.out.println(sql);
		
		ret = "00;"+description;
	}catch(Exception e){
		e.printStackTrace(System.out);
		con.rollback();
		ret = "99;DB Error";
	}finally{
		if(pstmt!=null) pstmt.close();
	}
	return ret;
}
%>


<%!
String findVA(Connection con, String VA) throws SQLException{
	String merchantID = "";
	String merchantName = "";
	String VAname="";
	String merchantInfoID = "";
	String ret = " ; ; ";
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	String sql = "";
	
	boolean b1 = false, b2 = false, b3 = false;
	try{
		sql = "select merchant_id, merchant_name as VAname from merchant_virtual_id where merchant_virtual_id='"+(VA.substring(6, VA.length())).trim()+"' and status=1";
		pstmt = con.prepareStatement(sql);
		rs = pstmt.executeQuery();            
		if(rs.next()){
			merchantID = rs.getString("merchant_id");
			VAname = rs.getString("VAname");
			b1 = true;
		}            
		pstmt.close();rs.close();		
		if(b1){
			sql = "select merchant_info_id from merchant where merchant_id='"+merchantID+"'";
			pstmt = con.prepareStatement(sql);
			rs = pstmt.executeQuery();            
			if(rs.next()){
				merchantInfoID = rs.getString("merchant_info_id");
				b2 = true;
			}
			pstmt.close();rs.close();
			if(b2){
				//
				sql = "select name from merchant_info where merchant_info_id='"+merchantInfoID+"'";
				pstmt = con.prepareStatement(sql);
				rs = pstmt.executeQuery();            
				if(rs.next()){
					merchantName = rs.getString("name");
					b3 = true;
				}
				pstmt.close();rs.close();
			}
		}
		if(!b1 || !b2 || !b3){
			ret = " ; ; ";
		}
	}catch(Exception e){
		e.printStackTrace(System.out);
		ret = " ; ; ";
	}finally{
		if(rs!=null) rs.close();
		if(pstmt!=null) pstmt.close();
	}
	
	ret=merchantID+";"+merchantName+";"+VAname;
	return ret;
}
%>

<%
//=========================================
Calendar CAL = Calendar.getInstance();
SimpleDateFormat SDF = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
String timeNOW=SDF.format(CAL.getTime());
String outPUT = "";
//=========================================

User user = (User)session.getValue("user");

String encLogin = user.getUsername();
String encPass = user.getPassword();

//keperluan melakukan update tsel_merchant_account, tsel_merchant_account_history, merchant_deposit
//String userName = "admin";

String comm = request.getParameter("comm");

//keperluan untuk melakukan pencocokan
String []   suggestedMercId = request.getParameterValues("suggestedMercId"),
            fileID1 = request.getParameterValues("file_id1"),
            fileID2 = request.getParameterValues("file_id2"),
            fileID3 = request.getParameterValues("file_id3"),
			depositID1 = request.getParameterValues("deposit_id1"),
            depositID2 = request.getParameterValues("deposit_id2"),
            depositID3 = request.getParameterValues("deposit_id3"),
			tipe = request.getParameterValues("tipe");

//keperluan untuk akses basisdatanya
Connection con = null;
Statement stmt = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

%>

<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Suggest Merchant Deposit">
	<stripes:layout-component name="contents">


        <script language="JavaScript">
        <!--
        function checkExecute(){
            with(document) return confirm("Do you really want to suggest these deposits?");
        }        
        
		function doDeleteAccount(file1, file2, file3, tipe){
			var id = confirm("Do you really want to delete this deposits?");
			if(id){
				window.location = "deposit_suggest_od.jsp?comm=single&file_id1="+file1+"&file_id2="+file2+"&file_id3="+file3+"&tipe="+tipe;
			}
		}
		
        function isNotDouble(){
            
        }
        //-->
		</script>

		<a href='https://10.2.114.121:9082/new_uploadDepositFile.jsp?idLog1=<%=encLogin%>&idLog2=<%=encPass%>'>Upload Deposit File</a>
		<br /><br />
        <%
        try{
            //Buka dulu si databasenya
            con = DbCon.getConnection();
			con.setAutoCommit(false);
        %>
       
	   <%
            //PROSES DELETE ACCOUNT STATEMENT
            if(comm!=null&&fileID1!=null&&fileID2!=null&&fileID3!=null&&tipe!=null){
				for(int i=0;i<fileID1.length;i++){
					String [] resDelete = (deleteAccount(con, fileID1[i], fileID2[i], fileID3[i], tipe[i])).split(";");
					if(resDelete[0].equals("00")){
						con.commit();
						out.println("<script language='javascript'>alert('Account Statement with "+resDelete[1]+" has successfully deleted.')</script>");
					}else{
						out.println("<script language='javascript'>alert('Account Statement with "+resDelete[1]+" has not successfully deleted.')</script>");
					}
				}
            }
        %>
	   
	   <%
            //PROSES UPDATE ACCOUNT STATEMENT DAN DEPOSIT INSERTION
            if(comm!=null&&fileID1!=null&&fileID2!=null&&fileID3!=null&&depositID1!=null&&depositID2!=null&&depositID3!=null){
				try{
					boolean isAll = true;
					String listMID = "Virtual Account Creation ";
					for(int i=0;i<depositID1.length;i++){						
						String [] resultIns = (insertDeposit(con, depositID1[i], fileID3[i], "Virtual Account "+depositID3[i]+" Merchant "+depositID2[i], "Virtual Account", encLogin, request.getRemoteAddr())).split(";");
						String [] resultUpd = (updateAccount(con, resultIns[1], fileID1[i], "C", fileID2[i], fileID3[i])).split(";");
						outPUT+=("resultUpd[0]"+resultUpd[0]+"resultUpd[1]"+resultUpd[1]+"resultIns[0]:"+resultIns[0]+"resultIns[1]"+resultIns[1]);
						if(!resultUpd[0].equals("00") || !resultIns[0].equals("00")){
							isAll&=false;
							break;
						}else{
							listMID+=("mdID:"+depositID1[i]+"|");
						}
					}					
					if(isAll){
						con.commit();
						outPUT+=("Virtual Account Request Deposit Creation Success|");
						out.println("<script language='javascript'>alert('Virtual Account Request Deposit Creation Success')</script>");
					}else{
						con.rollback();
						outPUT+=("Virtual Account Request Deposit Creation Failed|");
						out.println("<script language='javascript'>alert('Virtual Account Request Deposit Creation Failed')</script>");
					}
				}
				catch(SQLException e){
					e.printStackTrace(System.out);
					out.println("<script language='javascript'>alert('Virtual Account Request Deposit Creation Failed')</script>");
					outPUT+=("Virtual Account Request Deposit Creation Failed|");
					try{con.rollback();}catch(Exception ee){}
				}
            }
        %>
	   
	   
	   
        <%
            //PROSES UPDATE FILE DAN RECORD YANG MANUALLY MATCHED
            if(suggestedMercId!=null&&fileID1!=null&&fileID2!=null&&fileID3!=null){
                //cek kalau misalkan ada suggestedMercId yang sama atau dobel
                Boolean doubleStatus = true;
                if (suggestedMercId.length > 1){
                    for(int i=0;i<(suggestedMercId.length)-1;i++){
                        for(int j=i+1;j<suggestedMercId.length;j++){
                            if(suggestedMercId[i].equalsIgnoreCase(suggestedMercId[j]) && !suggestedMercId[i].equalsIgnoreCase("") ){                                
                                doubleStatus = false;
                                break;
                            }
                        }
                        if(!doubleStatus)break;
                    }
                }else if (suggestedMercId.length == 1){
                    doubleStatus = true;
                }else if (suggestedMercId.length == 0){
                    doubleStatus = false;
                }
                //kalau misalkan tidak ada yang double
                if(doubleStatus){
                    try{
                        int jmlUpdateRecord = 0;
						for(int i=0;i<suggestedMercId.length;i++){
                            if(!(suggestedMercId[i].trim()).equals("")){
                                String [] resultUpd = (updateAccount(con, suggestedMercId[i], fileID1[i], "C", fileID2[i], fileID3[i])).split(";");
								jmlUpdateRecord ++;
								outPUT+=resultUpd[1]+"|";
							}
                        }
						con.commit();
						outPUT+=("Suggest approval successful|"+jmlUpdateRecord+" records affected");
                        out.println("<script language='javascript'>alert('Suggest approval successful. "+jmlUpdateRecord+" records affected')</script>");
						//con.setAutoCommit(true);
                    }
                    catch(SQLException e){
                        e.printStackTrace(System.out);
						out.println("<script language='javascript'>alert('Suggest approval unsuccessful')</script>");
						outPUT+=("Suggest approval unsuccessful|");
						try{con.rollback();}catch(Exception ee){}
                    }
					
					/*
					// AFTER SUGGEST, send SMS to FINANCE
					reg.sendSms("628111009137", "Admin sudah melakukan sugesti deposit, silahkan finance untuk melakukan approval.", "2828");
					outPUT+=("SMS sent|");
					*/
				}
                else{
                    out.println("<script language='javascript'>alert('Suggest approval unsuccessful, check your suggestion, make sure there is no duplicate.')</script>");
					outPUT+=("Suggest approval/update successful|");
				}                
            }
        %>
            
        <%
            //PENCOCOKAN ANTARA REQUEST DEPOSIT DAN ACCOUNT STATEMENT DIMULAI
            
            //untuk keperluan pencocokan
            int jmlFileVAInt = 0, jmlFileInt = 0, jmlRecordInt = 0;
            
            //pstmt = con.prepareStatement("SELECT COUNT(*) AS jmlFile FROM ACC_STATEMENT WHERE STATUS='0' AND TIPE='C' AND REF IS NULL");
            pstmt = con.prepareStatement("SELECT COUNT(*) AS jmlFile FROM ACC_STATEMENT WHERE STATUS='0' AND (tx_date between sysdate-30 and sysdate) AND TIPE='C' AND REF IS NULL");
            rs = pstmt.executeQuery();            
            while(rs.next()){
                jmlFileInt = rs.getInt("jmlFile");
            }            
            pstmt.close();rs.close();
            
            //pstmt = con.prepareStatement("SELECT COUNT(*) AS jmlRecord FROM MERCHANT_DEPOSIT WHERE IS_EXECUTED='1' AND exec_time is not null AND NOT DEPOSIT_ID IN (SELECT REF FROM ACC_STATEMENT WHERE NOT REF IS NULL)");
			pstmt = con.prepareStatement("SELECT COUNT(*) AS jmlRecord FROM MERCHANT_DEPOSIT WHERE IS_EXECUTED='1' and (deposit_time between sysdate-30 and sysdate) AND exec_time is not null AND NOT DEPOSIT_ID IN (SELECT REF FROM ACC_STATEMENT WHERE NOT REF IS NULL)");
			rs = pstmt.executeQuery();            
            while(rs.next()){
                jmlRecordInt = rs.getInt("jmlRecord");
            }            
            pstmt.close();rs.close();
			
			pstmt = con.prepareStatement("SELECT COUNT(*) AS jmlFileVA FROM ACC_STATEMENT WHERE STATUS='0' AND UPPER(DESCRIPTION) like '%988911%' AND (tx_date between sysdate-30 and sysdate) and TIPE='C' AND REF IS NULL");
            rs = pstmt.executeQuery();            
            while(rs.next()){
                jmlFileVAInt = rs.getInt("jmlFileVA");
            }            
            pstmt.close();rs.close();
            
			ArrayList<String> tabelFileVA = new ArrayList<String>();
			pstmt = con.prepareStatement("SELECT TX_DATE, DESCRIPTION, AMOUNT FROM ACC_STATEMENT WHERE STATUS='0' AND UPPER(DESCRIPTION) like '%988911%' AND (tx_date between sysdate-30 and sysdate) and TIPE='C' AND REF IS NULL");
			rs = pstmt.executeQuery();            
			while(rs.next()){
				tabelFileVA.add(rs.getString(1)+";"+rs.getString(2)+";"+rs.getString(3));
			}            
			pstmt.close();rs.close();
			
			String matriksFileVA[][] = new String[jmlFileVAInt][3];
            //load matriksFileVAnya
			for (int i=0;i<jmlFileVAInt;i++){
				matriksFileVA[i] = tabelFileVA.get(i).split(";");
			}
			
			%>
			<hr />
				<form action='deposit_suggest_od.jsp' method='get'>
				<table width='45%' border='1' cellspacing='0' cellpadding='0' bordercolor='#FFF6EF'>
				<tr><td colspan='8'><div align='right'><font color='#CC6633' size='2' face='Verdana, Arial, Helvetica, sans-serif'><strong>.:: Account Statement - Virtual Account</strong></font></div></td></tr>
				<tr>
					<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>No Index</strong></font></div></td>
					<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Trx Date</strong></font></div></td>
					<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Description</strong></font></div></td>
					<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Amount</strong></font></div></td>
					<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Merchant ID</strong></font></div></td>
					<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Merchant Name</strong></font></div></td>
					<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Virtual Account Name</strong></font></div></td>
					<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Action</strong></font></div></td>
				</tr>
				<%
				int noIndex=1;
				int jmlAction = 0;
				for(int i=0;i<matriksFileVA.length;i++){
					String tempVA = matriksFileVA[i][1].substring(matriksFileVA[i][1].indexOf("988911"), (matriksFileVA[i][1].indexOf("988911"))+16);
					String [] tempArrayVA = findVA(con, tempVA).split(";");
					boolean bolAction = true;
					if((tempArrayVA[0].trim()).equals("") || (tempArrayVA[1].trim()).equals("") || (tempArrayVA[2].trim()).equals(""))
						bolAction=false;
					//outPUT+=("bolAction:"+bolAction);
					%>
				<tr>
					<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=noIndex%></font></div></td>
					<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=matriksFileVA[i][0]%></font></div></td>
					<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=matriksFileVA[i][1]%></font></div></td>
					<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=matriksFileVA[i][2]%></font></div></td>
					<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=tempArrayVA[0]%></font></div></td>
					<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=tempArrayVA[1]%></font></div></td>
					<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=tempArrayVA[2]%></font></div></td>
					<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'>
					<%
					if(bolAction){
					%>
					<a href='deposit_suggest_od.jsp?comm=single&file_id1=<%=matriksFileVA[i][0]%>&file_id2=<%=matriksFileVA[i][1]%>&file_id3=<%=matriksFileVA[i][2]%>&deposit_id1=<%=tempArrayVA[0]%>&deposit_id2=<%=tempArrayVA[1]%>&deposit_id3=<%=tempArrayVA[2]%>'>Create Deposit Request</a>
					<%
					}
					%>
					</font></div></td>
				</tr>
					<%
					noIndex++;
					if(bolAction){
						jmlAction++;
						%>
						<input type='hidden' name='file_id1' value='<%=matriksFileVA[i][0]%>'>
						<input type='hidden' name='file_id2' value='<%=matriksFileVA[i][1]%>'>
						<input type='hidden' name='file_id3' value='<%=matriksFileVA[i][2]%>'>
						
						<input type='hidden' name='deposit_id1' value='<%=tempArrayVA[0]%>'>
						<input type='hidden' name='deposit_id2' value='<%=tempArrayVA[1]%>'>
						<input type='hidden' name='deposit_id3' value='<%=tempArrayVA[2]%>'>
						<%
					}
				}
				if(jmlAction>0){
					%>
				<tr>
					<td colspan="8">
					<input type='hidden' name='comm' value='all'>
					<div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><input type='submit' name='submit' value='Create All'></font></div>
					</td>
				</tr>
					<%
				}
				%>
				</table>
				</form>
				<%
			
            //cek kalau ada request deposit atau account statement yang akan dibandingkan                  
            //if (jmlFileInt!=0 && jmlRecordInt!=0){
                //load dari tabel ke array HasilFile
                ArrayList<String> tabelFile = new ArrayList<String>();
                //pstmt = con.prepareStatement("SELECT TX_DATE, DESCRIPTION, AMOUNT FROM ACC_STATEMENT WHERE STATUS='0' AND TIPE='C' AND REF IS NULL");
                pstmt = con.prepareStatement("SELECT TX_DATE, DESCRIPTION, AMOUNT FROM ACC_STATEMENT WHERE STATUS='0' AND (tx_date between sysdate-30 and sysdate) and TIPE='C' AND REF IS NULL");
                rs = pstmt.executeQuery();            
                while(rs.next()){
                    tabelFile.add(rs.getString(1)+";"+rs.getString(2)+";"+rs.getString(3));
                }            
                pstmt.close();rs.close();
                
                String matriksFile[][] = new String[jmlFileInt][3];
                
                //load matriksFilenya
                for (int i=0;i<jmlFileInt;i++){
                    matriksFile[i] = tabelFile.get(i).split(";");
                }

                ArrayList<String> tabelDeposit = new ArrayList<String>();                
				//pstmt = con.prepareStatement("SELECT DEPOSIT_TIME, MERCHANT_ID, AMOUNT, DEPOSIT_ID FROM MERCHANT_DEPOSIT WHERE IS_EXECUTED='1' and exec_time is not null AND NOT DEPOSIT_ID IN (SELECT REF FROM ACC_STATEMENT WHERE NOT REF IS NULL)");
				pstmt = con.prepareStatement("SELECT DEPOSIT_TIME, MERCHANT_ID, AMOUNT, DEPOSIT_ID FROM MERCHANT_DEPOSIT WHERE IS_EXECUTED='1' and (deposit_time between sysdate-30 and sysdate) and exec_time is not null AND NOT DEPOSIT_ID IN (SELECT REF FROM ACC_STATEMENT WHERE NOT REF IS NULL)");
				rs = pstmt.executeQuery();            
                while(rs.next()){
                    tabelDeposit.add(rs.getString(1)+";"+rs.getString(2)+";"+rs.getString(3)+";"+rs.getString(4));
                }            
                pstmt.close();rs.close();
                //load tabel merchant deposit ke array
                String matriksDeposit[][] = new String[jmlRecordInt][4];
                //load matriksDepositnya
                for (int i=0;i<jmlRecordInt;i++){
                    matriksDeposit[i] = tabelDeposit.get(i).split(";");
                }
                
                //load array pencocokan
                int [] matchedOnes = new int [jmlRecordInt];
                for (int i=0;i<jmlRecordInt;i++){
                    matchedOnes[i] = 0;
                }
                //sesudah me-load kedua matriks, saatnya mencocokan dan menaruhnya ke 4 array
                int [] idMatch = new int[50], idUnMatch = new int[50], fileIdMatch = new int[50], fileIdUnMatch = new int[50];
                int idMatchInt = 0, idUnMatchInt = 0, fileIdMatchInt = 0, fileIdUnMatchInt = 0;
				
				for(int i=0;i<jmlRecordInt;i++){
					idUnMatch[idUnMatchInt] = i;
					idUnMatchInt++;
				}
				for(int i=0;i<jmlFileInt;i++){
					fileIdUnMatch[fileIdUnMatchInt] = i;
					fileIdUnMatchInt++;
				}                    
				
				%>
				<hr />
					<table width='45%' border='1' cellspacing='0' cellpadding='0' bordercolor='#FFF6EF'>
					<tr><td colspan='5'><div align='right'><font color='#CC6633' size='2' face='Verdana, Arial, Helvetica, sans-serif'><strong>.:: Unmatched Deposit List</strong></font></div></td></tr>
                    <tr><td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Baris Record</strong></font></div></td>
					<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Deposit Date</strong></font></div></td>
					<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Merchant ID</strong></font></div></td>
					<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Deposit Amount</strong></font></div></td>
					<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Deposit ID</strong></font></div></td></tr>
				<%
				//KELUARKAN HASIL YANG TIDAK COCOK
                if(idUnMatchInt!=0){
                    %>
					<%
                    for(int i=0;i<idUnMatchInt;i++){
						%>
						<tr><td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=idUnMatch[i]%></font></div></td>
						<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=matriksDeposit[idUnMatch[i]][0]%></font></div></td>
						<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=matriksDeposit[idUnMatch[i]][1]%></font></div></td>
						<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=matriksDeposit[idUnMatch[i]][2]%></font></div></td>
						<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=matriksDeposit[idUnMatch[i]][3]%></font></div></td></tr>
						<%
					}
                }
                else{
                    out.println("<br /><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><b>Semua request deposit sudah memiliki pasangan atau tidak sama sekali, tidah ada yang bisa disugesti.</b></font>");
					outPUT+=("All deposit is not matched, there is not any suggestion|");
                }
				%>
				</table>
					
					<hr />
					<form action='deposit_suggest_od.jsp' method='get'>
					<table width='45%' border='1' cellspacing='0' cellpadding='0' bordercolor='#FFF6EF'>
					<tr><td colspan='6'><div align='right'><font color='#CC6633' size='2' face='Verdana, Arial, Helvetica, sans-serif'><strong>.:: Unmatched Account Statement</strong></font></div></td></tr>
                    <tr><td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Baris File</strong></font></div></td>
					<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Account Date</strong></font></div></td>
					<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Notes</strong></font></div></td>
					<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Amount</strong></font></div></td>
					<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Suggested Deposit</strong></font></div></td>
					<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>*</strong></font></div></td></tr>
				<%
                
				if(fileIdUnMatchInt!=0){
					for(int i=0;i<fileIdUnMatchInt;i++){
						boolean ifexist = true;
						
						%>
						<tr>
						<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=fileIdUnMatch[i]%></font></div></td>
						<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=matriksFile[fileIdUnMatch[i]][0]%></font></div></td>
						<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=matriksFile[fileIdUnMatch[i]][1]%></font></div></td>
						<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=matriksFile[fileIdUnMatch[i]][2]%></font></div></td>
						<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'>
						<select name='suggestedMercId'>
						<option value=''>&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp</option>
						<%
						for(int j=0;j<idUnMatchInt;j++) {
							if((matriksFile[fileIdUnMatch[i]][2]).equalsIgnoreCase(matriksDeposit[idUnMatch[j]][2])){
							%><option value='<%=matriksDeposit[idUnMatch[j]][3]%>'><%=matriksDeposit[idUnMatch[j]][1]%></option><%
							ifexist &= false;
							}
						}
                        %>
						</select>
						<input type='hidden' name='file_id1' value='<%=matriksFile[fileIdUnMatch[i]][0]%>'>
						<input type='hidden' name='file_id2' value='<%=matriksFile[fileIdUnMatch[i]][1]%>'>
						<input type='hidden' name='file_id3' value='<%=matriksFile[fileIdUnMatch[i]][2]%>'>
                        </font></div></td>
						<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><b>
						<%if(!ifexist){
							%>*<%;
							}else{
							%><a href="deposit_entry.jsp?amountx=<%=matriksFile[fileIdUnMatch[i]][2]%>&doc_numberx=<%=matriksFile[fileIdUnMatch[i]][0]%>&notex=<%=matriksFile[fileIdUnMatch[i]][1]%>">+</a>|<a href="javascript:doDeleteAccount('<%=(matriksFile[fileIdUnMatch[i]][0])%>','<%=(matriksFile[fileIdUnMatch[i]][1])%>','<%=(matriksFile[fileIdUnMatch[i]][2])%>','C');">-</a>
							<%
							}
							%>
						</b></font></div></td>
						</tr>
						
							<%
                    }
					%>
						<tr><td colspan="6"><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><input type='submit' name='submit' value='Suggest' onclick='return checkExecute();'></font></div></td></tr>
					<%
				}
                else{
                    outPUT+=("All statement is matched|");
                }
                    %>
					</table>                   
                    </form>
					<%
            /*
			}
            else{
                out.println("<br /><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><b>Tidak ada data yang bisa dicocokkan (request deposit atau file).</b></font>");
				//outPUT+=("No data can be matched|");
            }*/
        }
        catch(Exception e){
            e.printStackTrace(System.out);
			out.println("<br/ > <font size='1' face='Verdana, Arial, Helvetica, sans-serif'><b>Basis data error.</b></font>");
            try{con.rollback();}catch(Exception ee){}
			outPUT+=("Exception occured. Error:"+e.getMessage());
        }
        finally{
            try{
                if(con!=null) con.close();
                if(rs!=null) rs.close();
                if(stmt!=null) stmt.close();
                if(pstmt!=null) pstmt.close();
				//=====================================================================//
				if (!outPUT.equals(""))
					System.out.println("["+timeNOW+"]deposit_suggest_od.jsp|"+outPUT);
				//=====================================================================//
            }
            catch(Exception e){}
        }

        %>

	</stripes:layout-component>
</stripes:layout-render>