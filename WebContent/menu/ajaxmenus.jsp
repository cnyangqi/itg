<%@ page language="java" contentType="text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.core.*" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="nps.exception.NpsException" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String id = request.getParameter("id");

    String tree_id = "0";
    if(id!=null && id.length()>0)  tree_id = id;

    response.setContentType("text/xml;charset=UTF-8");
    response.setCharacterEncoding("UTF-8");
    PrintWriter writer = response.getWriter();
    writer.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
    writer.println("<tree id=\""+tree_id+"\">");

    try
    {
       MenuTree tree = MenuTree.GetInstance();
       tree.AjaxDHXTree(writer,id,user);
    }
    catch(NpsException e)
    {
    }

    writer.println("</tree>");
    writer.flush();
%>