<%@page import="nps.core.User"%>
<%@page import="tools.Pub"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="nps.util.Utils"%>
<%@ page import="com.gemway.util.JUtil"%>

<%
	request.setCharacterEncoding("UTF-8");

	nps.core.User user = (User) session.getAttribute("user");
	if (user == null) {
%>
    <form action="/nfwl/session/login_lzzt_do.jsp">
        <div>用户名：<input name="user" type="text" class="input" style="width: 95px;"/></div>
        <div>密&nbsp;&nbsp;&nbsp;&nbsp;码：<input name="password" type="password" class="input" style="width: 95px;" /></div>
        <div style="padding-left:5px; padding-top:5px;">
			<input type="image" name="imageField" id="imageField" src="/images/button_01.png" />&nbsp;&nbsp;&nbsp;&nbsp;<a href="registration.html"><img src="/images/button_02.png"/></a>
		</div>
        <div style="padding-left:0px;">
			<input name="save" type="checkbox" value="" />
			保持登录状态&nbsp;&nbsp;<a href="password.html">忘记密码</a>
		</div>
    </form>﻿
<%
	return;
	} else {
%>
   <form>
        <div><%=user.GetName()%>，您已成功登录！</div>
        <div><a href="http://admin.lzzt.com" target="_blank">【进入管理中心】</a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="/nfwl/session/logout_lzzt.jsp">【退出】</a></div>
   </form>
<%
	return;
	}
%>