<%@page import="java.io.*, java.util.*, java.text.*, java.sql.*"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>

<jsp:useBean id="reg" scope="request" class="tsel_tunai.Register2Bean"></jsp:useBean>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%
	User user = (User) session.getValue("user");

	String encLogin = user.getUsername();
	String encPass = user.getPassword();
%>
<stripes:layout-render name="/web-starter/layout/standard.jsp"
	title="Bank Statement Reconcile">
	<stripes:layout-component name="contents">
		<a
			href='./bank_statement_upload.jsp?idLog1=<%=encLogin%>&idLog2=<%=encPass%>'>Upload
			Bank Statement File</a>
	</stripes:layout-component>
</stripes:layout-render>
