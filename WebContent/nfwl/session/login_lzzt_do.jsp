<%@ page language = "java" contentType = "text/html; charset=UTF-8"%>
<%@ page import="nps.util.Utils" %>

<%
    request.setCharacterEncoding("UTF-8");

    session.removeAttribute("user");
    
    String account = request.getParameter("user");
    String passwd  = request.getParameter("password");
    String language = request.getParameter("language");

    try
    {
        nps.core.User user = nps.core.User.Login(account,passwd);
        if( user == null  )
        {
            response.sendRedirect("/index.shtml");
            return;
        }
        user.SetLocale(Utils.GetLocale(language));
        session.setAttribute("user", user);
        response.sendRedirect("/index.shtml");
    }
    catch(Exception e)
    {
        response.sendRedirect("/index.shtml");
    }
%>