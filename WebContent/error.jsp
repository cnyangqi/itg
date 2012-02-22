<%@ page contentType="text/html; charset=UTF-8" language="java" isErrorPage="true"%>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.io.StringWriter" %>
<%@ page import="java.io.PrintWriter" %>
<html>
<body>
<div style="color:red;width:300px; height:400px; margin:-200px 0 0 -150px; position:absolute; top:50%; left:50%;">
 <%
    String error_msg = exception.toString();

    if(exception instanceof NpsException)
    {
       NpsException ex = (NpsException)exception;
       switch(ex.getErrorCode())
       {
          case ErrorHelper.ACCESS_NOTLOGIN:
             response.sendRedirect("/index.jsp");
             return;
       }
    }
     
    if(error_msg!=null)
    {
        error_msg = error_msg.replaceAll("\n","<br>");
        out.println(error_msg);
    }

    out.println("<!--");
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);
        exception.printStackTrace(pw);
        out.print(sw);
        sw.close();
        pw.close();
    out.println("-->");
%>
</div>
</body>
</html>