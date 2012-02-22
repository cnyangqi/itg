<%@ page contentType="text/html; charset=UTF-8" language="java"%>
<%@ page import="java.util.Locale" %>
<%
    String accept_language = "zh-cn";
    nps.core.User user = (nps.core.User) session.getAttribute("user");
    if(user!=null)
    {
        response.sendRedirect("/main.html");
        return;
    }
    else
    {
        accept_language = request.getHeader("accept-language");
        if(accept_language!=null)
        {
            String[] langs_array = accept_language.split("[,;]");
            accept_language = langs_array[0];
        }
        //System.out.println(accept_language);
        if("zh-cn".equalsIgnoreCase(accept_language))
        {
            response.sendRedirect("/index_zh_CN.jsp");
            return;
        }
        if("en".equalsIgnoreCase(accept_language) || "en-us".equalsIgnoreCase(accept_language) || "en-uk".equalsIgnoreCase(accept_language))
        {
            response.sendRedirect("/index_en.jsp");
            return;
        }

    }

    //默认登录页
    response.sendRedirect("/index_zh_CN.jsp");
%>