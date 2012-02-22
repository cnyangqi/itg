<%@ page language = "java" contentType = "text/html;charset=UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.module.VisualModule" %>

<%@ include file = "/include/header.jsp" %>

<%
   request.setCharacterEncoding("UTF-8");

   String template_id = request.getParameter("template_id");
   String mod_id = request.getParameter("mod_id");
   String align = request.getParameter("horiz_id");

   Connection conn = null;
   try
   {
       conn = Database.GetDatabase("nps").GetConnection();
       conn.setAutoCommit(false);

       //保存
       VisualModule module = VisualModule.Load(conn,mod_id);
       module.SetAlign(Integer.parseInt(align));
       module.SaveFloat(conn);
       conn.commit();
%>
<%@ include file = "load_module_include.jsp" %>
<%
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