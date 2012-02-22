<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="nps.module.VisualTemplate" %>
<%@ page import="nps.core.Database" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    String title = request.getParameter("vt_title");

    Connection conn = null;
    VisualTemplate template = null;

    try
    {
        conn = Database.GetDatabase("nps").GetConnection();
        conn.setAutoCommit(false);
        template = new VisualTemplate(conn,title,user);
        template.Save(conn);
        conn.commit();

        response.sendRedirect("visual_template.jsp?id="+template.GetId());
    }
    catch(Exception e)
    {
        try{conn.rollback();}catch(Exception e1){}
        throw e;
    }
    finally
    {
        if(conn!=null) try{conn.close();}catch(Exception e){}
    }
%>