<%@ page language="java" errorPage="/error.jsp"
	contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<%@ include file="/include/header.jsp"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<title>密码修改</title>
		<link href="/ithinkgo1.css" rel="stylesheet" type="text/css" />
		<link href="/user/error.css" rel="stylesheet" type="text/css" />
		<script type="text/javascript" src="/jquery/jquery-1.6.js"></script>
		<script type="text/javascript" src="/jquery/jquery.validate.js"></script>
		<script type="text/javascript" src="/user/changepassword.js"></script>
	</head>
	<body>

		<!--top-->
		<jsp:include page="/user/common/div_top.inc" />
		<!--top_end-->

		<!--menu-->
		<jsp:include page="/user/common/div_menu.inc" />
		<!--menu_end-->

		<!--search-->
		<jsp:include page="/user/common/div_hotsearch.inc" />
		<!--search_end-->

		<!--my-->
		<div class="my_ithinkgo">

			<!--user_munu-->
			<jsp:include page="/user/common/user_menu.inc" />
			<!--user_munu_end-->

			<div class="content">
				<div class="menu2">
					<ul>
						<li>
							密码修改
						</li>
					</ul>
				</div>
				<html:form action="/user/user.do" >
				<input type="hidden" name="token" value="${token }" />
					<input type="hidden" name="cmd" value="changepassword" />
					<input type="hidden" name="id" value="${user.id }" />
					<div class="zlxg">
						<ul>
							<li class="ti">
								当前密码：
							</li>
							<li class="con">
								<input name="oldpassword" type="password" class="input itop" />
							</li>
						</ul>
						<ul>
							<li class="ti">
								新密码：
							</li>
							<li class="con">
								<input name="password" id="password" type="password"
									class="input itop" />
							</li>
						</ul>
						<ul>
							<li class="ti">
								确认密码：
							</li>
							<li class="con">
								<input name="password1" type="password" class="input itop" />
							</li>
						</ul>
						<ul>
							<li class="ti">
								&nbsp;
							</li>
							<li class="con">
								<input name="" type="submit" value="保存" class="submit" />
							</li>
						</ul>
					</div>
				</html:form>
			</div>


			<div class="firefox"></div>

		</div>
		<!--my_end-->
		<!--service-->
		<jsp:include page="/user/common/div_services.inc" />
		<!--ervice_end-->

		<!--about-->
		<jsp:include page="/user/common/div_about.inc" />
		<!--ervice_end-->

		<!--link-->
		<jsp:include page="/user/common/div_links.inc" />
		<!--link_end-->

		<!--down-->
		<jsp:include page="/user/common/div_bottom.inc" />
		<!--down_end-->
	</body>
</html>
<c:choose>
	<c:when test="${empty message}">
	</c:when>
	<c:otherwise>
		<c:choose>
			<c:when test="${message.flag}">
				<script type="text/javascript"> 
					alert("${message.msg}");
				</script>
			</c:when>
			<c:otherwise>
				<script type="text/javascript"> 
				alert("${message.error}");
				</script>
			</c:otherwise>
		</c:choose> 
	</c:otherwise>
</c:choose>  