<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.Config" %>

<%@ include file = "/include/header.jsp" %>

<%
   request.setCharacterEncoding("UTF-8");
   ResourceBundle bundle = ResourceBundle.getBundle("langs.workflow_client", user.GetLocale(), Config.RES_CLASSLOADER);

   String business_type = request.getParameter("business_type");
   if(business_type==null || business_type.trim().length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

   String app_id = request.getParameter("app_id");
%>
<div id="workflow_titlebar"><div id="title"><%=bundle.getString("WORKFLOW_TITLE")%></div></div>
<div id="workflow_suggest">
    <div><%=bundle.getString("WORKFLOW_SUGGEST")%></div><textarea id="suggest"></textarea>
</div>
<div id="workflow_toolbar">
    <input type="button" id="btn_workflow_ok" name="btn_workflow_ok" value="<%=bundle.getString("WORKFLOW_BUTTON_OK")%>">
    <input type="button" id="btn_workflow_cancel" name="btn_workflow_cancel" value="<%=bundle.getString("WORKFLOW_BUTTON_CANCEL")%>">
</div>