<%@ page language = "java" contentType = "text/html;charset=UTF-8"%>

<%@ include file = "/include/header.jsp" %>

<%
   request.setCharacterEncoding("UTF-8");
   java.util.ResourceBundle module_bundle = java.util.ResourceBundle.getBundle("langs.module_tabs",user.GetLocale(), nps.core.Config.RES_CLASSLOADER);
   String tab_id = request.getParameter("tab_id");
%>
<div id="tabslink_<%=tab_id%>" class="linkbar">
    <%=module_bundle.getString("TABS_LINK")%>
    <input type="text" id="tab_link_<%=tab_id%>" name="tab_link_<%=tab_id%>" value="" style="width: 160px">
    &nbsp;&nbsp;
    <%=module_bundle.getString("TABS_TARGET")%>
    <input type="text" id="tab_target_<%=tab_id%>" name="tab_target_<%=tab_id%>" value="" style="width: 80px">
    &nbsp;&nbsp;
    <font color="red"><%=module_bundle.getString("TABS_TABHINT")%></font>
</div>