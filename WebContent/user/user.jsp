<%@ page language="java" errorPage="/error.jsp"
	contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<%@ taglib prefix="my" uri="http://www.ithinkgo.com/functions"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ include file="/include/header.jsp"%>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<title>会员信息</title>
		<link href="/ithinkgo1.css" rel="stylesheet" type="text/css" />
		<link href="/user/error.css" rel="stylesheet" type="text/css" />
		<script type="text/javascript" src="/jquery/jquery-1.6.js"></script>
		<script type="text/javascript" src="/jquery/jquery.validate.js"></script>
		<script type="text/javascript" src="/user/myvalidate.js"></script>
		<script type="text/javascript" src="/user/user.js"></script>

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
							资料修改
						</li>
					</ul>
				</div>
				<form name="userForm" id="userForm" action="/user/user.do"
					method="post">
					<input type="hidden" name="token" value="${token }" />
					<input type="hidden" name="cmd" value="modfiy" />
					<input type="hidden" name="id" value="${userForm.id }" />
					<div class="zlxg">
						<ul>
							<li class="ti">
								邮箱：
							</li>
							<li class="con">
								<input name="email" type="text" class="input itop"
									value="${userForm.email }" size="20" />
								<font color="red"><html:errors property="email" />
								</font>
							</li>
						</ul>
						<ul>
							<li class="ti">
								呢称：
							</li>
							<li class="con">
								<input name="nickname" type="text" class="input itop"
									value="${userForm.nickname }" size="20" />
								<font color="red"><html:errors property="nickname"/></font>
							</li>
						</ul>
						<ul>
							<li class="ti">
								真实姓名：
							</li>
							<li class="con">
								<input name="name" type="text" class="input itop"
									value="${userForm.name }" size="20" />
								<font color="red"><html:errors property="name"/></font>
							</li>
						</ul>
						<ul>
							<li class="ti">
								性别：
							</li>
							<li class="con">
								<input name="sex" type="radio" value="0"
									<c:if test="${userForm.sex=='0' }"> checked="checked"</c:if> />
								男&nbsp;&nbsp;
								<input name="sex" type="radio" value="1"
									<c:if test="${userForm.sex=='1' }"> checked="checked"</c:if> />
								女
							</li>
						</ul>
						<ul>
							<li class="ti">
								所在区：
							</li>
							<li class="con">
								<select name="zoneid" class="input itop">
									<c:forEach items="${my:getZone()}" var="zone">
										<option value="${zone.id }"
											<c:if test="${userForm.zoneid==zone.id }">
								 				selected="selected"
								 			</c:if>>
											${zone.name }
										</option>
									</c:forEach>
								</select>
							</li>
						</ul>
						<ul>
							<li class="ti">
								详细地址：
							</li>
							<li class="con">
								<input name="detailadr" type="text" class="input itop"
									size="90" value="${userForm.detailadr }" />
								<font color="red"><html:errors property="detailadr"/></font>
							</li>
						</ul>
						<ul>
							<li class="ti">
								手机号码：
							</li>
							<li class="con">
								<input name="mobile" type="text" class="input itop"
									value="${userForm.mobile }" cnname="手机 " cannull="true"
									datatype="mobile" ignore="false" />
								<font color="red"><html:errors property="mobile"/></font>
							</li>
						</ul>
						<ul>
							<li class="ti">
								固定电话：
							</li>
							<li class="con">
								<input name="areacode" type="text" class="input" size="4"
									value="${userForm.areacode }" />
								<font color="red"><html:errors property="areacode"/></font>
								-
								<input name="telephone" type="text" class="input " size="10"
									value="${userForm.telephone }" />
								<font color="red"><html:errors property="telephone"/></font>
								-
								<input name="subnum" type="text" class="input" size="3"
									value="${userForm.subnum }" />
								<font color="red"><html:errors property="subnum"/></font>
							</li>
							<li class="t">
								区号-号码-分机
							</li>
						</ul>
						<ul>
							<li class="ti">
								传真：
							</li>
							<li class="con">
								<input name="faxareacode" type="text" class="input" size="4"
									value="${userForm.faxareacode }" />
								<font color="red"><html:errors property="faxareacode"/></font>
								-
								<input name="fax" type="text" class="input " size="10"
									value="${userForm.fax }" />
								<font color="red"><html:errors property="fax"/></font>
							</li>
							<li class="t">
								区号-号码
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
				</form>
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