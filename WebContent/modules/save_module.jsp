<%@ page language = "java" contentType = "text/html;charset=UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.module.VisualTemplate" %>
<%@ page import="nps.module.VisualModule" %>

<%@ include file = "/include/header.jsp" %>

<%
   request.setCharacterEncoding("UTF-8");

   String template_id = request.getParameter("template_id");
   String mod_id = request.getParameter("mod_id");
   String index = request.getParameter("position");
   String align = request.getParameter("horiz_id");
   String title = request.getParameter("title");
   String displaytitle = request.getParameter("displaytitle");
   String color = request.getParameter("color");
   String width = request.getParameter("width");
   String height = request.getParameter("height");
   String border = request.getParameter("border");
   String textalign = request.getParameter("textalign");
   String overflow = request.getParameter("overflow");
   String data_json = request.getParameter("data_json");

   Connection conn = null;
   try
   {
       conn = Database.GetDatabase("nps").GetConnection();
       conn.setAutoCommit(false);

       //保存
       VisualModule module = VisualModule.Load(conn,mod_id);
       module.SetAlign(Integer.parseInt(align));
       module.SetTitle(title);
       module.SetDisplayTitle(displaytitle);
       module.SetBackgroundColor(color);
       module.SetWidth(width);
       module.SetHeight(height);
       module.SetBorder(border);
       module.SetTextAlign(textalign);
       module.SetOverflow(overflow);
       module.SetDataFromJSON(data_json);
       module.SetIndex(Integer.parseInt(index));
       module.Save(conn);
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