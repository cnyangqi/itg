<%@ page language = "java" contentType = "text/html;charset=UTF-8"%>
<%@ page import="nps.core.Database" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="nps.module.VisualModule" %>

<%@ include file = "/include/header.jsp" %>

<%
   request.setCharacterEncoding("UTF-8");

   String template_id = request.getParameter("template_id");
   String mod_id = request.getParameter("mod_id");

   Connection conn = null;
   VisualModule module = null;
   try
   {
       conn = Database.GetDatabase("nps").GetConnection();
       module = VisualModule.Load(conn,mod_id);
   }
   catch(Exception e)
   {
       e.printStackTrace();
       return;
   }   
   finally
   {
       if(conn!=null) try{conn.close();}catch(Exception e){}
   }
   out.clear();
%>
<%@ include file = "load_module_include.jsp" %>