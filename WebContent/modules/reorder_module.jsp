<%@ page language = "java" contentType = "text/html;charset=UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.module.VisualTemplate" %>

<%@ include file = "/include/header.jsp" %>

<%
   request.setCharacterEncoding("UTF-8");

   String template_id = request.getParameter("template_id");
   String json = request.getParameter("json");

   Connection conn = null;
   try
   {
       conn = Database.GetDatabase("nps").GetConnection();
       conn.setAutoCommit(false);
       VisualTemplate template = VisualTemplate.Load(conn,template_id);
       template.ReorderModule(conn,json);
       conn.commit();
   }
   catch(Exception e)
   {
       try{conn.rollback();}catch(Exception e1){}
       e.printStackTrace();
   }
   finally
   {
       if(conn!=null) try{conn.close();}catch(Exception e){}
   }
%>