<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.core.NpsWrapper" %>
<%@ page import="nps.core.TemplateBase" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.Config" %>


<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    String template_id = request.getParameter("template_id");
    if(template_id!=null) template_id = template_id.trim();
    if(template_id==null || template_id.length()==0) throw new NpsException(ErrorHelper.INPUT_ERROR);

    NpsWrapper wrapper = null;
    TemplateBase template = null;

    try
    {
        wrapper = new NpsWrapper(user);
        template = wrapper.GetTemplate(template_id);
    }
    finally
    {
       if(wrapper!=null) wrapper.Clear();
       wrapper = null;
    }

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_templatejavasource",user.GetLocale(), Config.RES_CLASSLOADER);
%>
<html>
  <head>
    <title><%=template.GetName()+bundle.getString("JAVA_HTMLTITLE")%></title>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>
    <link rel="stylesheet" href="/highlight/styles/idea.css">
    <style type="text/css">
        span
        {
            width: 40px;
            text-align: right;
            back-ground:grey;
            padding-right:20px;
            color:red;
            font-weight:bold;
        }
    </style>
  </head>
  
  <body leftmargin="20">
  <br>  
  &nbsp;&nbsp;
           <%=bundle.getString("JAVA_TEMPLATENAME")%><b><%=template.GetName()%></b>
        &nbsp;&nbsp;
            <%=bundle.getString("JAVA_CLASSNAME")%><b>nps.runtime.<%=template.GetClassName()%></b>
  <div id="highlight-view"><% if(template!=null)  template.ViewHtmlJavaSource(out);%></div>
  </body>
</html>