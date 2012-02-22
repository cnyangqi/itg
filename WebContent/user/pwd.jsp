<%@page import="tools.Pub"%>
<%@page import="org.apache.commons.codec.binary.BinaryCodec"%>
<%@page import="com.nfwl.itg.user.UserService"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String account = request.getParameter("account");
	String logincode = Pub.getString(request.getParameter("logincode"), "");
	String sessioncode = (String) session.getAttribute("rand");

	System.out.println(logincode);
	System.out.println(sessioncode);

	if (!logincode.equalsIgnoreCase(sessioncode)) {
		System.out.println("验证码错误。");
%>

<script type="text/javascript">
	alert('验证码错误');
	window.history.go(-1);
</script>

<%
	}

	if (UserService.retrieveUserPwdByAccount(account)) {
		System.out.println("密码找回成功。");
%>

<script type="text/javascript">
	alert('密码找回成功');
	window.opener = null;
	window.close();
</script>

<%
	} else {
		System.out.println("密码找回失败，请检查账户名称是否正确。");
%>

<script type="text/javascript">
	alert('密码找回失败，请检查账户名称是否正确');
	window.history.go(-1);
</script>

<%
	}
%>
