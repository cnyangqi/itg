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
﻿
<div class="login">
	<ul class="title">&nbsp;
	</ul>
	<ul class="content">
		<form action="/nfwl/session/login.jsp">
			<!-- <input type="hidden" name="to_url" value="/user/loaduser.do?cmd=acctountInfo" /> -->
			<input type="hidden" name="to_url" value="/" />
			<ul>
				<li>用户名：<input name="user" type="text" class="input" size="15" /></li>
				<li>密&nbsp;&nbsp;&nbsp;&nbsp;码：<input name="password" type="password" class="input" size="15" /></li>
				<li class="ti">
				验证码：<input name="logincode" type="text" class="input itop" size="5" />&nbsp;
				<img onclick="javascript:loadimage_login();" name="randImage_login" id="randImage_login" src="/nfwl/tools/image.jsp" width="60" height="20" border="1" align="absmiddle">
				</li>
				<li style="padding: 5px 0 0 50px;">
				<div style="float: left; padding-right: 10px;">
					<input name="" type="image" src="images/button_01.png" />
				</div>
					<span><a href="/user/pwd.html" target="_blank">忘记密码了</a></span></li>
				<li class="register"><a href="/reglog.shtml" class="text_green">没帐号？<br />30秒免费注册一个>>
				</a></li>
			</ul>
		</form>
	</ul>
</div>

<%
	return;
	} else {
%>

<div class="login">
	<ul class="title">&nbsp;
	</ul>
	<ul class="content">
		<form action="/nfwl/session/login.jsp">
			<!-- <input type="hidden" name="to_url" value="/user/loaduser.do?cmd=acctountInfo" /> -->
			<ul>
				<li>欢迎你：<%=user.GetName()%></li>
				<li>账户余额：<%=user.getMoney()%> 元</li>
				<li>当前积分：<%=user.getPoint()%> 分</li>
				<li><a href="/user/loaduser.do?cmd=acctountInfo">我的账户</a></li>
				<li><a href="/user/logout.jsp">退出</a></li>
			</ul>
		</form>
	</ul>
</div>

<%
	return;
	}
%>