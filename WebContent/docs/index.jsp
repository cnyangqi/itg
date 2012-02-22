<%@ page contentType="text/html; charset=UTF-8" language="java"%>
<%@ page import="java.util.Locale" %>
<%
    nps.core.User user = (nps.core.User) session.getAttribute("user");
    if(user!=null)
    {
        Locale locale = user.GetLocale();
        response.sendRedirect("/docs/"+locale.getLanguage()+"/index.html");
        return;
    }

    response.sendRedirect("/docs/en/index.html");
%>    