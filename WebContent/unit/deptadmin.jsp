<%@ page language="java" contentType="text/html;charset=UTF-8"%>
<%@ page import="nps.util.Utils" %>
<%
    request.setCharacterEncoding("UTF-8");
    String id = request.getParameter("unit_id");
    if(id!=null) id = id.trim();
%>
<html>
<head>
</head>
  <frameset id="leftFrameSet" rows="*" cols="160,*" framespacing="0" frameborder="no" border="0" >
	<frame name="deptList" src="depttree.jsp?id=<%=Utils.Null2Empty(id)%>">
    <frame name="deptMain" src="">
  </frameset>
<noframes>
<body bgcolor="#FFFFFF" text="#000000">
</body>
</noframes>
</html>

