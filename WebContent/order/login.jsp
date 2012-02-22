<%@ page language="java" errorPage="/error.jsp" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="com.gemway.util.JUtil" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>我的订单</title>
<link href="/ithinkgo1.css" rel="stylesheet" type="text/css" />
<link href="/user/error.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="/jquery/jquery-1.6.js"></script>
<script type="text/javascript" src="/jquery/jquery.validate.js"></script>
<link rel="stylesheet" href="/jquery/thickbox/thickbox1.css" type="text/css" media="screen" />
<script type="text/javascript" src="/jquery/thickbox/thickbox.js"></script>
<script type="text/javascript" src="/jquery/thickbox/option.js"></script>
<script type="text/javascript" src="/order/login.js"></script>
</head>
<body>
<form name="loginrm" id="loginrm" action="/order/login.do" method="post">
<input name="cmd" type="hidden"  value="cartLogin"/>
<input name="to_url" type="hidden"  value="${to_url }"/>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="table">
<tr>
	<td colspan="2"><h2>用户登陆</h2></td>
</tr>
<tr>
	<td width="30%">用户名：</td><td width="70%">
		<input name="user" id="user" type="text"  value="" style="width: 120px;"/>
	</td>
</tr>
<tr>
	<td>密  码：</td><td>
		<input name="password" id="password" type="password"  value="" style="width: 120px;"/>
	</td>
</tr>
<tr>
	<td>验证码：</td><td>
		<input name="logincode" id="logincode" type="text"  value="" size="4"/>
		 <img  onclick="javascript:loadimage_login();" name="randImage_login" id="randImage_login" src="/nfwl/tools/image.jsp" width="60" height="20" border="1" align="absmiddle">
	</td>
</tr>

<tr>
	<td colspan="2" align="center"><input name="" type="submit" value="登陆" class="submit" /></td>
</tr>
</table>
</form>
<c:if test="${not empty msg}">
<script type="text/javascript">
	alert('${msg}');
</script>
</c:if>
<c:if test="${not empty user}">
	<c:choose>
		<c:when test="${not empty to_url}">
			<a href="${to_url }" target="_blank" id="id_to_url"></a>
			<script type="text/javascript">
				var element = document.getElementById('id_to_url');
				element.click();
				if(parent!=null){
					parent.TB_remove();
					window.close();
				}else{
					window.close();
				}
				
			</script>
		</c:when>
		<c:otherwise>
			<script type="text/javascript">
				parent.callback();
				parent.TB_remove();
			</script>	
		</c:otherwise>
	</c:choose>
</c:if>

</body>
</html>
