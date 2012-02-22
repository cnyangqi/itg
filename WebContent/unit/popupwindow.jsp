<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%
    request.setCharacterEncoding("UTF-8");
    String sSourceURL = (String)request.getParameter("src");
%>
<html>
<body>
    <iframe name="childFrame" id="childFrame" height="100%" width="100%" src="<%=sSourceURL%>"></iframe>
</body>
</html> 