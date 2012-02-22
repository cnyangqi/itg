<%@ page language = "java" contentType = "text/html;charset=UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.module.VisualModule" %>

<%@ include file = "/include/header.jsp" %>

<%
   request.setCharacterEncoding("UTF-8");

   String template_id = request.getParameter("template_id");
   String type = request.getParameter("type");
   String index = request.getParameter("position");

   Connection conn = null;
   try
   {
       conn = Database.GetDatabase("nps").GetConnection();
       conn.setAutoCommit(false);
       VisualModule module = new VisualModule(conn,template_id,type,Integer.parseInt(index));
       module.Save(conn);
       conn.commit();

       response.addHeader("X-JSON", module.toJSONString());
       out.print("<DIV class=\"modfloat full\">");
       out.print("<DIV id=\"" + module.HTML_Div() + "\" class=mod>");
       out.print("<img src=\"/images/modules/loader.gif\" alt=\"Loading...\">");
       out.print("</DIV>");
       out.println("</DIV>");
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