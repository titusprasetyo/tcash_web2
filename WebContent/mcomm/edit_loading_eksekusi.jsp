<%@ page import="java.sql.*,java.lang.String.*,java.util.*,java.text.*,java.util.regex.*" %>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%!public String expDate() {
	Calendar cal = new GregorianCalendar();
	java.util.Date dt = new java.util.Date();
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
	cal.setTime(dt);
	//cal.set(cal.DAY_OF_MONTH,cal.getActualMaximum(cal.DAY_OF_MONTH)+1) ;
	cal.set(cal.DAY_OF_MONTH,cal.DAY_OF_MONTH+30) ;
	dt = cal.getTime();
	return sdf.format(dt);
}%>
<%
	String ipaddr = request.getRemoteAddr();
	String name = request.getParameter("nama");
	//String no1 = request.getParameter("no1");
	//String no2 = request.getParameter("no2");
	String tid = request.getParameter("tid");
	String description = request.getParameter("description");
	String address = request.getParameter("address");
	//String msisdn = request.getParameter("msisdn");
	Connection conn = null;
	conn = DbCon.getConnection();
	User user = (User)session.getValue("user"); 
	if (user != null) {
		session.putValue("user", user);
		/*if (no2.equals("")) {
			//out.println( "<SCRIPT LANGUAGE=javascript> alert('username and password cannot be empty');</SCRIPT>" );
			try {
				String s = "insert into activity_log (userlogin,access_time,activity,note,IP,Reason) values('"+user.getUsername()+"',now(),'Edit Loading','Failed','"+ipaddr+"','MSISDN Cannot be empty ')";
				PreparedStatement st = conn.prepareStatement(s);
				st.executeUpdate();
				st.close();
			}
			catch(Exception  e){
				e.printStackTrace(System.out);
			} finally{
				try { conn.close(); } catch(Exception ee){}
			}
			response.sendRedirect("edit_payment.jsp?stat=1&tid="+tid+"&name="+name+"&msisdn="+msisdn+"&desc="+description);
		} else {
		*/
				//cek existing user
				
				//msisdn = no1+""+no2;
				try {
					
					String sql = "update loading_terminal set description = ?, address=? where terminal_id = ? ";
					PreparedStatement pstmt = conn.prepareStatement(sql);
					pstmt.setString(1,description);
					pstmt.setString(2,address);
					pstmt.setString(3,tid);
					pstmt.executeUpdate();
					pstmt.close();
					
					response.sendRedirect("list_loading.jsp?name=");
				}
				catch(Exception  e){
					e.printStackTrace(System.out);
					response.sendRedirect("edit_loading.jsp?stat=1&tid="+tid+"&name="+name+"&desc="+description);
				} finally{
					try { conn.close(); } catch(Exception ee){}
				}
		//}
	} else {
		response.sendRedirect("admin.html");
	} 
%>
