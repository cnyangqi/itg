<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.core.NpsWrapper" %>
<%@ page import="nps.core.Site" %>
<%@ page import="nps.core.Config" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ include file="/include/header.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");
    String id = request.getParameter("id");
    if( id!=null ) id = id.trim();
    if(id==null || id.length()==0)  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_sitecheck",user.GetLocale(), Config.RES_CLASSLOADER);    
    NpsWrapper wrapper = null;
    try
    {
        wrapper = new NpsWrapper(user);

        Site site = wrapper.GetSite(id);
        if(site!=null)
        {
            out.println(bundle.getString("SITECHECK_HINT_ALREADYEXIST"));
            return;
        }
        out.println(bundle.getString("SITECHECK_HINT_NOTEXIST"));
    }
    catch(Exception e)
    {
        throw e;
    }
    finally
    {
        if(wrapper!=null) wrapper.Clear();
    }
%>