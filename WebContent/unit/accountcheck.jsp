<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.core.NpsWrapper" %>
<%@ page import="nps.core.Config" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.core.User" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>

<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String account = request.getParameter("account");
    if( account!=null ) account = account.trim();
    if( account==null || account.length()==0 )  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_accountcheck",user.GetLocale(), Config.RES_CLASSLOADER);    
    NpsWrapper wrapper = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try
    {
        wrapper = new NpsWrapper(user);

        String sql = "select count(*) from users where account=?";
        pstmt = wrapper.GetContext().GetConnection().prepareStatement(sql);
        pstmt.setString(1,account.toUpperCase());
        rs = pstmt.executeQuery();
        rs.next();
        if(rs.getInt(1)>0)
        {
            out.println(bundle.getString("ACCOUNTCHECK_HINT_ALREADYEXIST"));
            return;
        }

        out.println(bundle.getString("ACCOUNTCHECK_HINT_NOTEXIST"));
    }
    finally
    {
        if(rs!=null) try{rs.close();}catch(Exception e1){}
        if(pstmt!=null) try{pstmt.close();}catch(Exception e1){}
        if(wrapper!=null) wrapper.Clear();
    }
%>