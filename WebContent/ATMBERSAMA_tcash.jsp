<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, jxl.*, java.sql.*, java.util.*,java.text.*, oracle.jdbc.driver.*" %>

<%
//=========================================
Calendar CAL = Calendar.getInstance();
SimpleDateFormat SDF = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
String timeNOW=SDF.format(CAL.getTime());
SDF = new SimpleDateFormat("EEE");
String dayName = SDF.format(CAL.getTime());
SDF = new SimpleDateFormat("yyMMdd");
String outPUT = "";
//=========================================

String wusername = request.getParameter("username");
String wpassword = request.getParameter("password");
String pathTes = application.getRealPath("/")+"artajasa_claim";
String fileName = "tk"+SDF.format(CAL.getTime())+".rtg";
String pathFile = pathTes+"/"+fileName;
//System.out.println(pathFile);
String data = "99|System Error.";

if(wusername!=null && wpassword!= null && ((wusername.equals("bni1") && wpassword.equals("bni1_123_"+SDF.format(CAL.getTime()))) || (wusername.equals("bni2") && wpassword.equals("bni2_123_"+SDF.format(CAL.getTime()))) || (wusername.equals("bni3") && wpassword.equals("bni3_123_"+SDF.format(CAL.getTime())))) ){
	outPUT+=("username:"+wusername+"|");
	// check today's date
	if(dayName.equals("Sat") || dayName.equals("Sun")){
		data = "02|Today is not a working date.";
		outPUT +=("Not Working Date|");
		out.println(data);
	}else{
		ServletOutputStream outPut = null;
		BufferedInputStream buf= null;
		try{
			// check for the file that exist
			File fileTes = new File(pathFile);
			if(!fileTes.exists()){
				data = "03|File is not found. Please contact TCash Operation at <fianita_ariesanti@telkomsel.co.id> or 628111006455.";
				outPUT +=("File is not found|");
				out.println(data);
			}else{
				//try fetching the file.
				outPUT +=("File is exists|"); 
				//menuliskan response
				response.reset();
				response.setContentType("application/text");
				response.setHeader("Content-disposition","attachment;filename=" +fileName);
				
				FileInputStream fileIn = new FileInputStream(fileTes);
				outPut = response.getOutputStream();
				buf= new BufferedInputStream(fileIn);
				
				int readBytes = 0;
				while((readBytes = buf.read())!=-1){
					outPut.write(readBytes);
				}
				outPUT +=("File is written to user|");
			}
		}catch(Exception e){
			data = "99|System Error. Please contact TCash Technical at <made_m_adyatman@telkomsel.co.id> or 628111009137.";
			out.println(data);
			outPUT+="System Error. Error :"+e.getMessage()+"|";
		}
		finally{
			//close the input/output streams
			if (outPut!=null)outPut.close();
			if (buf!=null)buf.close();
		}
	}	
}else{
	data = "01|Username or password doesn't match.";
	outPUT +=("Username and password mismatch|");
	out.println(data);
}

//=====================================================================//
if (!outPUT.equals(""))
	System.out.println("["+timeNOW+"]ATMBERSAMA_tcash.jsp|"+outPUT);
//=====================================================================//
%>