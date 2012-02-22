<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="nps.util.Utils" %>
<%
    request.setCharacterEncoding("UTF-8");
    
    Enumeration enum_params = request.getParameterNames();
    String params = null;
    if(enum_params!=null)
    {
        while(enum_params.hasMoreElements())
        {
            String param_name = (String)enum_params.nextElement();
            String param_value = request.getParameter(param_name);

            if(params==null)
            {
                params = "?" + param_name + "=" + URLEncoder.encode(param_value,"UTF-8");
            }
            else
            {
                params += "&" + param_name + "=" + URLEncoder.encode(param_value,"UTF-8");
            }
        }
    }
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
</head>
  <frameset id="leftFrameSet" rows="*" cols="0,*" framespacing="0" frameborder="no" border="0" >
	<frame name="topicNav" src="topictree.jsp<%=Utils.Null2Empty(params)%>">
    <frame name="artMain" src="articlelist.jsp<%=Utils.Null2Empty(params)%>">
  </frameset>
<noframes>
<body bgcolor="#FFFFFF" text="#000000">

</body>
</noframes>
</html>