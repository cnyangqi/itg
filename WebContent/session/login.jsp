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
            response.sendRedirect("/index.jsp");
            return;
        }
        user.SetLocale(Utils.GetLocale(language));
        session.setAttribute("user", user);
        response.sendRedirect("/main.html");
    }
    catch(Exception e)
    {
        response.sendRedirect("/index.jsp");
    }
%>