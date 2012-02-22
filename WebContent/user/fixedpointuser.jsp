<%@ page language="java" errorPage="/error.jsp" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ include file="/include/header.jsp"%>
<%@ taglib prefix="my" uri="http://www.ithinkgo.com/functions"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>定点用户管理</title>
<link href="/ithinkgo.css" rel="stylesheet" type="text/css" />
</head>
<script language="javascript">
	function state_change() {
		document.search_frm.submit();
	}
</script>
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
					<li>定点用户管理</li>
				</ul>
			</div>
			<form name="search_frm" action="/user/fixedpoint.do" method="post">
				<input type="hidden" name="cmd" value="search" />
				<input type="hidden" name="pageCur" value="${PAGELIST.pageCur}" />
				<div class="wddd">
					<ul>
						<li class="con">
						<a href="fixedpointuseradd.jsp">新增用户</a>
						</li>
					</ul>
					<ul>
						<table width="100%" border="0" cellpadding="0" cellspacing="0" class="table">
							<tr class="ti">
								<td>用户姓名</td>
								<td>用户账户</td>
								<td>联系电话</td>
								<td>联系手机</td>
								<td>电子邮件</td>
								<td class="nobr">操作</td>
							</tr>
							<c:choose>
								<c:when test="${empty PAGELIST.list}">
									<tr>
										<td colspan="5">没有符合条件的数据!</td>
									</tr>
								</c:when>
								<c:otherwise>
									<c:forEach items="${PAGELIST.list}" var="bean">
										<tr>
											<td>${bean.name}</td>
											<td>${bean.account}</td>
											<td>${bean.telephone}</td>
											<td>${bean.mobile}</td>
											<td>${bean.email}</td>
											<td class="nobr">
												<a href="/user/fixedpoint.do?cmd=edit&id=${bean.id}">编辑</a>
												&nbsp;
												<a href="/user/fixedpoint.do?cmd=delete&id=${bean.id}">删除</a>
											</td>
										</tr>
									</c:forEach>
								</c:otherwise>
							</c:choose>

						</table>
					</ul>
					<ul class="gopage"><jsp:include page="/user/page.jsp" /></ul>
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