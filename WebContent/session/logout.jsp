<%@ page contentType="text/html;charset=UTF-8" %>
<%
    request.setCharacterEncoding("UTF-8");
    session.removeAttribute("user");
    response.sendRedirect("/index.jsp");
%>