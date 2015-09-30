<%@ page language="java" import="javazoom.upload.*,java.util.*,java.text.*,java.io.*, java.net.*" %>
<%@ include file="/web-starter/taglibs.jsp"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>

<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Upload File">
	<stripes:layout-component name="contents">


<jsp:useBean id="fileMover" scope="page" class="uploadutilities.FileMover" />
<jsp:useBean id="upBean" scope="page" class="javazoom.upload.UploadBean" >
  <% upBean.setFolderstore("/tmp/");upBean.setOverwrite(true); %>
  <% upBean.addUploadListener(fileMover); %>
</jsp:useBean>

Upload Summary : <br />
<%
    try{
	//if (corpid != null && corpid.length() >0) {
	out.println("<script language='javascript'>alert('Masuk program.')</script>");
        if (MultipartFormDataRequest.isMultipartFormData(request))  {
			out.println("<script language='javascript'>alert('Masuk kalang kalau requestnya multipart.')</script>");
            // Rename the file name with the following rule.
            SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd_HHmmss");
            fileMover.setNewfilename("upload"+sdf.format(new Date()));
			out.println("<script language='javascript'>alert('Nama file yang baru selesai direname.')</script>");
			 
            // Uses MultipartFormDataRequest to parse the HTTP request.
            MultipartFormDataRequest mrequest = new MultipartFormDataRequest(request);
			out.println("<script language='javascript'>alert('Parse request berhasil.')</script>");
            /*String todo = mrequest.getParameter("todo");


            if ( (todo != null) && (todo.equalsIgnoreCase("upload")) )  {
                Hashtable files = mrequest.getFiles();
                if ( (files != null) || (!files.isEmpty()) )  {
                    UploadFile file = (UploadFile) files.get("uploadfile");
                    // The store method must be invoked to trigger the fileMover
                    // Object's fileUploaded() callback function.  This is the function
                    // That actually writes the file to disk.
                    upBean.store(mrequest, "uploadfile");
                    // Modified this slightly to retrieve the filename from the fileMover object.
                    // The same could be done for the file size.
                    out.println("<b>done</b><br>Form field : uploadfile"+"<BR> Uploaded file : " + fileMover.getFileName() + " (" + file.getFileSize() + " bytes)" + "<BR> Content Type : " + file.getContentType());
                    
                }  else  {
                    out.println("<li>No uploaded files");
                }
            }
            else out.println("<BR> todo="+todo); */
        }
    //} else out.println("must login first");
	}catch(Exception e){ out.println(e.getMessage()); }
%>
<br />

	</stripes:layout-component>
</stripes:layout-render>
