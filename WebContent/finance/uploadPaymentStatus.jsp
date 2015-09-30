<%@page import="java.io.*, java.util.*, java.text.*, java.sql.*"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%
String path = request.getParameter("F1");

%>

<%
//PROSES UPLOAD FILE CSV MENJADI KE DATABASE
Connection con = null;
Statement stmt = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try{
    //Buka dulu si databasenya
    //Class.forName("oracle.jdbc.OracleDriver");
    //con = DriverManager.getConnection("jdbc:oracle:thin:@10.2.114.121:1521:OPTUNAI", "tunai", "tunai123");
    con = DbCon.getConnection();
	con.setAutoCommit(false);

    if (path!=null && path!=""){
        int idxAwal = path.length()-3;
        int idxAkhir = path.length();
        String ext = path.substring(idxAwal, idxAkhir);
        if(ext.equalsIgnoreCase("txt") || ext.equalsIgnoreCase("csv")){
            //UPDATE DATABASE ACC_STATEMENT DARI FILE CSV

            //SISTEMNYA YANG BAKALAN NGURUSIN, jadi ngebaca dulu, terus tentuin itu filenya Mandiri atau BNI
            String Hasil[]= new String [6];
            //baca satu baris dulu, liat kalau kosong itu BNI, kalau Mandiri kan ga kosong dari awal
            String thisLine;
            ArrayList al = new ArrayList();
            BufferedReader fileIn = new BufferedReader(new FileReader(path));
            thisLine = fileIn.readLine();
            int rowAffected = 0;
            String bankType = "";
            int jmlInsert = 0;
            int jmlUpdate = 0;
            if(thisLine.equalsIgnoreCase("")){
                thisLine = fileIn.readLine();
                if(thisLine.equalsIgnoreCase("PT BANK NEGARA INDONESIA (PERSERO) TBK.")){
                    //ini file BNI
                    bankType = "BNI";
                    //baca 4x dulu biar sampai diatas datanya
                    thisLine = fileIn.readLine();thisLine = fileIn.readLine();thisLine = fileIn.readLine();thisLine = fileIn.readLine();
                    while((thisLine=fileIn.readLine())!=null){
                        if(thisLine.equalsIgnoreCase("")){
                            break;
                        }
                        else{
                            Hasil = thisLine.split(";", 8);
                            if(!Hasil[6].equalsIgnoreCase("C")){
                                pstmt = con.prepareStatement("UPDATE ACC_STATEMENT SET TIPE='D' WHERE TX_DATE=TO_DATE('"+Hasil[1].substring(0, 19)+"', 'YYYY-MM-DD HH24:MI:SS') AND DESCRIPTION='"+Hasil[4]+"' AND AMOUNT="+Hasil[5]);
                                rowAffected = pstmt.executeUpdate();
                                pstmt.close();
                                if(rowAffected==0){
                                    pstmt = con.prepareStatement("INSERT INTO ACC_STATEMENT (TX_DATE, DESCRIPTION, AMOUNT, TIPE) VALUES (TO_DATE('"+Hasil[1].substring(0, 19)+"', 'YYYY-MM-DD HH24:MI:SS'), '"+Hasil[4]+"', "+Hasil[5]+", 'D')");
                                    pstmt.executeUpdate();
                                    pstmt.close();
                                    jmlInsert++;
                                }else jmlUpdate++;
                            }
                        }
                    }
                }
                else{
                    out.println("File yang diupload tidak mempunyai format standar dari BNI atau Mandiri.");
                }
            }
            else if(!thisLine.equalsIgnoreCase("")){
                //ini file Mandiri
                bankType = "Mandiri";
                //simpan baris pertama yang sudah dibaca sebelumnya
                Hasil = thisLine.split(";", 7) ;
                if(Hasil[5].contains("DR")){
                    pstmt = con.prepareStatement("UPDATE ACC_STATEMENT SET TIPE='D' WHERE TX_DATE=TO_DATE('"+Hasil[2].substring(0, 10)+"', 'DD/MM/YYYY') AND DESCRIPTION='"+Hasil[3]+"' AND AMOUNT="+Hasil[5].substring(0, (Hasil[5].length())-2));
                    rowAffected = pstmt.executeUpdate();
                    pstmt.close();
                    //con.commit();
                    if (rowAffected==0){
                        pstmt = con.prepareStatement("INSERT INTO ACC_STATEMENT (TX_DATE, DESCRIPTION, AMOUNT, TIPE) VALUES (TO_DATE('"+Hasil[2].substring(0, 10)+"', 'DD/MM/YYYY'), '"+Hasil[3]+"', "+Hasil[5].substring(0, (Hasil[5].length())-2)+", 'D')");
                        pstmt.executeUpdate();
                        pstmt.close();
                        jmlInsert++;
                    }else jmlUpdate++;
                }
                //simpan baris-baris selanjutnya
                while((thisLine=fileIn.readLine())!=null){
                    if(thisLine.equalsIgnoreCase("")){
                        break;
                    }
                    else{
                        Hasil = thisLine.split(";", 7) ;
                        if(Hasil[5].contains("DR")){
                            pstmt = con.prepareStatement("UPDATE ACC_STATEMENT SET TIPE='D' WHERE TX_DATE=TO_DATE('"+Hasil[2].substring(0, 10)+"', 'DD/MM/YYYY') AND DESCRIPTION='"+Hasil[3]+"' AND AMOUNT="+Hasil[5].substring(0, (Hasil[5].length())-2));
                            rowAffected = pstmt.executeUpdate();
                            pstmt.close();
                            //con.commit();
                            if (rowAffected==0){
                                pstmt = con.prepareStatement("INSERT INTO ACC_STATEMENT (TX_DATE, DESCRIPTION, AMOUNT, TIPE) VALUES (TO_DATE('"+Hasil[2].substring(0, 10)+"', 'DD/MM/YYYY'), '"+Hasil[3]+"', "+Hasil[5].substring(0, (Hasil[5].length())-2)+", 'D')");
                                pstmt.executeUpdate();
                                pstmt.close();
                                jmlInsert++;
                            }else jmlUpdate++;
                        }
                    }
                }
            }
            con.commit();
            //Proses berhasil, keluarkan alert
            out.println("<script language='javascript'>alert('"+bankType+" Account Statement has successfully uploaded("+jmlInsert+") or updated("+jmlUpdate+"). ')</script>");
        }
        else{
            out.println("<script language='javascript'>alert(' File extension must be CSV or TXT tipe.')</script>");
        }

        %>

        <%
        //PENCOCOKAN ANTARA REQUEST SETTLEMENT DAN ACCOUNT STATEMENT DIMULAI
        //untuk keperluan pencocokan
        int jmlFileInt = 0, jmlRecordInt = 0;
        String username = "finance";

        pstmt = con.prepareStatement("SELECT COUNT(*) AS jmlFile FROM ACC_STATEMENT WHERE STATUS='0' AND TIPE='D' AND REF IS NULL");
        rs = pstmt.executeQuery();
        while(rs.next()){
            jmlFileInt = rs.getInt("jmlFile");
        }
        pstmt.close();rs.close();

        pstmt = con.prepareStatement("SELECT COUNT(*) AS jmlRecord from merchant a, merchant_cashout b, merchant_info c where b.MERCHANT_ID=a.MERCHANT_ID AND a.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID AND b.IS_EXECUTED='1' AND b.PRINT_DATE IS NOT NULL AND b.COMPLETION_DATE IS NULL AND b.RECEIPT_ID IS NOT NULL AND b.ENTRY_LOGIN!= 'Daily Settlement' ORDER BY DEPOSIT_TIME DESC");
        rs = pstmt.executeQuery();
        while(rs.next()){
            jmlRecordInt = rs.getInt("jmlRecord");
        }
        pstmt.close();rs.close();

        //cek kalau ada request settlement atau account statement yang akan dibandingkan
        if (jmlFileInt!=0 && jmlRecordInt!=0){
            //load dari tabel ke array HasilFile
            ArrayList<String> tabelFile = new ArrayList<String>();
            pstmt = con.prepareStatement("SELECT TX_DATE, DESCRIPTION, AMOUNT FROM ACC_STATEMENT WHERE STATUS='0' AND TIPE='D' AND REF IS NULL");
            rs = pstmt.executeQuery();
            while(rs.next()){
                tabelFile.add((rs.getTimestamp(1)).toString()+","+rs.getString(2)+","+rs.getString(3));
            }
            pstmt.close();rs.close();

            String matriksFile[][] = new String[jmlFileInt][3];

            //load matriksFilenya
            for (int i=0;i<jmlFileInt;i++){
                matriksFile[i] = tabelFile.get(i).split(",");
            }

            ArrayList<String> tabelDeposit = new ArrayList<String>();
            pstmt = con.prepareStatement("SELECT b.DEPOSIT_TIME, b.MERCHANT_ID, b.AMOUNT, CASHOUT_ID from merchant a, merchant_cashout b, merchant_info c where b.MERCHANT_ID=a.MERCHANT_ID AND a.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID AND b.IS_EXECUTED='1' AND b.PRINT_DATE IS NOT NULL AND b.COMPLETION_DATE IS NULL AND b.RECEIPT_ID IS NOT NULL AND b.ENTRY_LOGIN!= 'Daily Settlement' ORDER BY DEPOSIT_TIME DESC");
            rs = pstmt.executeQuery();
            while(rs.next()){
                tabelDeposit.add((rs.getTimestamp(1)).toString()+","+rs.getString(2)+","+rs.getString(3)+","+rs.getString(4));
            }
            pstmt.close();rs.close();

            //load tabel merchant deposit ke array

            String matriksDeposit[][] = new String[jmlRecordInt][4];
            //load matriksDepositnya
            for (int i=0;i<jmlRecordInt;i++){
                matriksDeposit[i] = tabelDeposit.get(i).split(",");
            }

            //load array pencocokan
            int [] matchedOnes = new int [jmlRecordInt];
            for (int i=0;i<jmlRecordInt;i++){
                matchedOnes[i] = 0;
            }
            //sesudah me-load kedua matriks, saatnya mencocokan dan menaruhnya ke 4 array
            int [] idMatch = new int[50], fileIdMatch = new int[50];
            int idMatchInt = 0, fileIdMatchInt = 0;

            //proses mencocokan
            for(int i=0;i<jmlFileInt;i++){
                for(int j=0;j<jmlRecordInt;j++){
                    if(/*((matriksFile[i][0].substring(0, 10)).equalsIgnoreCase(matriksDeposit[j][0].substring(0, 10)))&&*/(matriksFile[i][2].equalsIgnoreCase(matriksDeposit[j][2]))&&(matriksFile[i][1].contains(matriksDeposit[j][3]))&&matchedOnes[j]==0){
                        //mulai pencocokan, kalau cocok masukin ke array hasil idMatch dan fileIdMatch
                        idMatch[idMatchInt] = j;
                        fileIdMatch[fileIdMatchInt] = i;
                        idMatchInt++;
                        fileIdMatchInt++;
                        matchedOnes[j] = 1;
                        break;
                    }
                }
            }

            //PROSES PENGUPDATEAN
            if(idMatchInt!=0){
                //keluarkan hasil pencocokan
                out.println("<hr /><h3>DEBUG DEBUG DEBUG DEBUG DEBUG</h3><table border='1' width='100%'>");
                out.println("<tr><td>Baris File</td><td>Transaction Date</td><td>Description</td><td>Amount</td>  <td>Baris Record</td><td>Settlement Date</td><td>Merchant ID</td><td>Settlement Amount</td><td>Settlement ID</td></tr>");
                con.setAutoCommit(false);
                for(int i=0;i<idMatchInt;i++){
                    out.println("<tr>");
                        out.println("<td>"+fileIdMatch[i]+"</td><td>"+matriksFile[fileIdMatch[i]][0]+"</td><td>"+matriksFile[fileIdMatch[i]][1]+"</td><td>"+matriksFile[fileIdMatch[i]][2]+"</td>   <td>"+idMatch[i]+"</td><td>"+matriksDeposit[idMatch[i]][0]+"</td><td>"+matriksDeposit[idMatch[i]][1]+"</td><td>"+matriksDeposit[idMatch[i]][2]+"</td><td>"+matriksDeposit[idMatch[i]][3]+"</td>");
                    out.println("</tr>");
                }
                out.println("</table>");

                out.println("<h3>DEBUG DEBUG DEBUG DEBUG DEBUG</h3><hr />");

                //PROSES PENGUPDATEAN
                String sXid = ", ";
                for(int i=0;i<idMatchInt;i++){
                    sXid = sXid + matriksDeposit[idMatch[i]][3] + ", ";
                    //UPDATE 1
                    pstmt = con.prepareStatement("UPDATE merchant_cashout SET is_executed = '2', completion_date = TO_DATE('"+(matriksFile[fileIdMatch[i]][0]).substring(0, 10)+"', 'YYYY-MM-DD'), executor = '"+username+"' WHERE cashout_id = '"+matriksDeposit[idMatch[i]][3]+"'");
                    pstmt.executeUpdate();
                    pstmt.close();

                    pstmt = con.prepareStatement("UPDATE settlement_history SET status = '2' WHERE exec_id = '"+matriksDeposit[idMatch[i]][3]+"' AND amount > 0");
                    pstmt.executeUpdate();
                    pstmt.close();

                    //UPDATE 2
                    String sql = "UPDATE ACC_STATEMENT SET REF='"+matriksDeposit[idMatch[i]][3]+"', STATUS='2' WHERE TX_DATE=TO_DATE('"+matriksFile[fileIdMatch[i]][0].substring(0,10)+"', 'YYYY-MM-DD') AND DESCRIPTION='"+matriksFile[fileIdMatch[i]][1]+"' AND TIPE='D' AND AMOUNT="+matriksFile[fileIdMatch[i]][2];
                    pstmt = con.prepareStatement(sql);
                    pstmt.executeUpdate();
                    pstmt.close();
                }
                con.commit();
                out.println("<script language='javascript'>alert('Solve tickets no " + sXid.substring(2) + " successful')</script>");
                con.setAutoCommit(true);
            }
            else out.println("<script language='javascript'>alert('There are not any acc statements that match with cashout records. No data are affected.')</script>");
        }else out.println("<script language='javascript'>alert('There are not any acc statements or cashout records.')</script>");
    }    
}
catch(Exception e){
	e.printStackTrace();
	out.println("<script language='javascript'>alert(' There is an internal system error.')</script>");
	try{con.rollback();}catch(Exception ee){}
}
finally{
	try{
            if(!con.getAutoCommit()) con.setAutoCommit(true);
            if(con!=null) con.close();
            if(rs!=null) rs.close();
            if(stmt!=null) stmt.close();
            if(pstmt!=null) pstmt.close();

	}
	catch(Exception e){}
}

%>
            <table>
                <form action="uploadPaymentStatus.jsp" method="get" enctype="multipart/form-data">
                    <tr>
                        <td>Select a file : </td> <td><input type="file" name="F1" /></td>
                    </tr>
                    <tr>
                        <td colspan="2" align="centre"><input type="submit" name="button" value="Upload" /></td>
                    </tr>
                </form>
            </table>
