<%@ page language = "java" contentType = "text/html;charset=UTF-8"%>
<%@ page import="nps.module.VisualModule" %>
<%@ page import="nps.util.Utils" %>

<%
    out.clear();
    VisualModule module = (VisualModule)request.getAttribute("module");

    String suffix = request.getParameter("suffix");
    if(suffix==null || suffix.length()==0) suffix = module.GetId();

    out.print(Utils.Null2Empty(module.GetDataString("custom",suffix)));
%>
