<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>

<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.io.*" %>
<%@ page import="nps.core.Resource" %>
<%@ page import="nps.core.NpsContext" %>

<%@ include file="/include/header.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");

    if(!user.IsSysAdmin()) throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

    out.println("Create all preview images...<br>");

    NpsContext ctxt = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String sql = null;

    try
    {
        conn = Database.GetDatabase("nps").GetConnection();
        ctxt = new NpsContext(conn,user);

        sql = "select id from resources where type=0";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        int rows=0;
        while(rs.next())
        {
            Resource resource = Resource.GetResource(ctxt,rs.getString("id"));
            resource.CreatePreviewImage(220,-1);
            rows++;
        }

        out.println("<font color=red>Total "+rows+" images created!</font><br>");
        out.println("<font color=red>Done!</font>");
        out.flush();
    }
    finally
    {
        try{rs.close();}catch(Exception e){}
        try{pstmt.close();}catch(Exception e){}
        try{conn.close();}catch(Exception e){}
    }
%>