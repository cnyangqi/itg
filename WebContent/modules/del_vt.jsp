<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="nps.module.VisualTemplate" %>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>

<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    String template_id = request.getParameter("template_id");
    if(template_id==null || template_id.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

    Connection conn = null;
    VisualTemplate template = null;
    try
    {
        conn = Database.GetDatabase("nps").GetConnection();
        conn.setAutoCommit(false);
        template = VisualTemplate.Load(conn,template_id);
        template.Delete(conn);
        conn.commit();

        out.println(template.GetTitle() + " removed");
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