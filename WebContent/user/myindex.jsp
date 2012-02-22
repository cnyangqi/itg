<%@ page language="java" errorPage="/error.jsp" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ include file="/include/header.jsp"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<title>帐户信息</title>
		<link href="/ithinkgo.css" rel="stylesheet" type="text/css" />
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
							帐户信息
						</li>
					</ul>
				</div>

				<div class="zhxx">
					<ul>
						<li>
							${user.name }，您好，欢迎回来，这里是您的管理中心，可以管理您在想购网上的所有信息。
						</li>
						<!-- <li>
							消息提示：
							5条咨询回复&nbsp;&nbsp;&nbsp;&nbsp;
							3条投诉回复&nbsp;&nbsp;&nbsp;&nbsp;
							0条待处理订单
						</li> -->
						<li>
							您的帐户余额：${accountInfo.money }元&nbsp;&nbsp;&nbsp;&nbsp;
							去选购产品<a href="/" target="_blank">>></a>
						</li>
						<li>
							您的积分：${accountInfo.point }&nbsp;&nbsp;(500积分可以兑换1元)&nbsp;&nbsp;&nbsp;&nbsp;
							
						</li>
						<li>
							您的订单数：
							${accountInfo.orderSize }笔
						</li>
					</ul>
				</div>
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