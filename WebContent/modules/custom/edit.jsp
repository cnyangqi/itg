<%@ page language = "java" contentType = "text/html;charset=UTF-8"%>
<%@ page import="nps.module.VisualModule" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.Config" %>

<%@ include file="/include/header.jsp" %>

<%
    ResourceBundle bundle_module = ResourceBundle.getBundle("langs.module_custom",user.GetLocale(), Config.RES_CLASSLOADER);
    VisualModule module = (VisualModule)request.getAttribute("module");

    String suffix = request.getParameter("suffix");
    if(suffix==null || suffix.length()==0) suffix = module.GetId();
%>
<div style="color:red;font-weight:600;font-size:12px;padding:15px 0 5px 0;"><%=bundle_module.getString("CUSTOM_HINT")%></div>
<textarea id="custom_<%=suffix%>" name="custom_<%=suffix%>" rows="15" cols="80" style="width:100%"><%=Utils.Null2Empty(module.GetDataString("custom",suffix))%></textarea>