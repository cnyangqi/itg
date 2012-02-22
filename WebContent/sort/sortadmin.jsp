<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ include file = "/include/header.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
</head>
  <frameset id="leftFrameSet" rows="*" cols="160,*" framespacing="0" frameborder="no" border="0" >
	<frame name="topicNav" src="topictree.jsp">
    <frame name="artMain" src="">
  </frameset>
<noframes>
<body bgcolor="#FFFFFF" text="#000000"></body>
</noframes>
</html>