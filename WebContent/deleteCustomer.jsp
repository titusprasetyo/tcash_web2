<%@ page import="java.io.*, java.util.*,java.text.*, oracle.jdbc.driver.*, java.sql.*;" %>

<%
String msisdn = request.getParameter("msisdn");
Calendar cal = Calendar.getInstance();
SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
String timeNow=sdf.format(cal.getTime());
String [] outPut = new String [2];
outPut[0] = "99";outPut[1] = "MSISDN null";

if(msisdn!=null && !msisdn.equals("")){
    //database parameter
    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String sqlQuery = "";

    //parameter tambahan
    Boolean isCustomer = false;
    Boolean isTransaction = false;
    String accNo = "";
    String custInfoID = "";
    String custID = "";

    try{

        Class.forName("oracle.jdbc.OracleDriver");
        con = DriverManager.getConnection("jdbc:oracle:thin:@10.2.114.121:1521:OPTUNAI", "tunai", "tunai123");
        con.setAutoCommit(false);

        //check for registered customer

        sqlQuery = "SELECT * FROM CUSTOMER WHERE msisdn='"+msisdn+"'";
        pstmt = con.prepareStatement(sqlQuery);
        rs = pstmt.executeQuery();
        if(rs.next()){
            isCustomer = true;
            accNo = rs.getString("ACC_NO");
            custInfoID = rs.getString("CUST_INFO_ID");
            custID = rs.getString("CUST_ID");
        }
        pstmt.close();rs.close();

        if(!isCustomer){
            outPut[0] = "98";outPut[1] = "Customer is not registered.";
        }
        else{

            //check for customer transaction history
            sqlQuery = "SELECT * FROM TSEL_CUST_ACCOUNT_HISTORY WHERE ACC_NO='"+accNo+"'";
            pstmt = con.prepareStatement(sqlQuery);
            rs = pstmt.executeQuery();
            if(rs.next()){
                isTransaction = true;
            }
            pstmt.close();rs.close();

            if(isTransaction){
               outPut[0] = "97";outPut[1] = "Customer had transaction history.";
            }
            else{
                //begin deleting
                //1. delete the CUSTOMER_LAST_TRX
                sqlQuery = "DELETE FROM CUSTOMER_LAST_TRX WHERE msisdn='"+msisdn+"'";
                pstmt = con.prepareStatement(sqlQuery);
                pstmt.executeUpdate();
                pstmt.close();
                //2. delete the MSISDN_TRXID
                sqlQuery = "DELETE FROM MSISDN_TRXID WHERE msisdn='"+msisdn+"'";
                pstmt = con.prepareStatement(sqlQuery);
                pstmt.executeUpdate();
                pstmt.close();
                //3. delete the RECHARGE_TX
                sqlQuery = "DELETE FROM RECHARGE_TX WHERE msisdn='"+msisdn+"'";
                pstmt = con.prepareStatement(sqlQuery);
                pstmt.executeUpdate();
                pstmt.close();
                //4. delete the LOG_USSD
                sqlQuery = "DELETE FROM LOG_USSD WHERE msisdn='"+msisdn+"'";
                pstmt = con.prepareStatement(sqlQuery);
                pstmt.executeUpdate();
                pstmt.close();
                //5. delete the ACC_NO
                sqlQuery = "DELETE FROM ACC_NO WHERE ACC_NO='"+accNo+"'";
                pstmt = con.prepareStatement(sqlQuery);
                pstmt.executeUpdate();
                pstmt.close();
                //6. delete the CUSTOMER
                sqlQuery = "DELETE FROM CUSTOMER WHERE ACC_NO='"+accNo+"'";
                pstmt = con.prepareStatement(sqlQuery);
                pstmt.executeUpdate();
                pstmt.close();
                //7. delete the TSEL_CUST_ACCOUNT
                sqlQuery = "DELETE FROM TSEL_CUST_ACCOUNT WHERE ACC_NO='"+accNo+"'";
                pstmt = con.prepareStatement(sqlQuery);
                pstmt.executeUpdate();
                pstmt.close();
                //8. delete the TSEL_CUST_ACCOUNT_HISTORY
                sqlQuery = "DELETE FROM TSEL_CUST_ACCOUNT_HISTORY WHERE ACC_NO='"+accNo+"'";
                pstmt = con.prepareStatement(sqlQuery);
                pstmt.executeUpdate();
                pstmt.close();
                //9. delete the TSEL_SUSPEND_ACCOUNT
                sqlQuery = "DELETE FROM TSEL_SUSPEND_ACCOUNT WHERE ACC_NO='"+accNo+"'";
                pstmt = con.prepareStatement(sqlQuery);
                pstmt.executeUpdate();
                pstmt.close();
                //10. delete the TSEL_SUSPEND_ACCOUNT_HISTORY
                sqlQuery = "DELETE FROM TSEL_SUSPEND_ACCOUNT_HISTORY WHERE ACC_NO='"+accNo+"'";
                pstmt = con.prepareStatement(sqlQuery);
                pstmt.executeUpdate();
                pstmt.close();
                //11. delete the CUSTOMER_INFO
                sqlQuery = "DELETE FROM CUSTOMER_INFO WHERE cust_info_id='"+custInfoID+"'";
                pstmt = con.prepareStatement(sqlQuery);
                pstmt.executeUpdate();
                pstmt.close();

                con.commit();
                outPut[0] = "00";outPut[1] = "Customer is deleted.";
            }
        }
    }
    catch(Exception e){
        outPut[0] = "99";outPut[1] = "Exception is occured.";
        try{con.rollback();}catch(Exception ee){}
    }
    finally{
        try{
            if(con!=null) con.close();
            if(rs!=null) rs.close();
            if(pstmt!=null) pstmt.close();
        }
        catch(Exception e){}
    }
}
System.out.println(timeNow+" | deleteCustomer.jsp | "+msisdn+" | "+outPut[0]+":"+outPut[1]);
out.println(outPut[0]+":"+outPut[1]);
%>
