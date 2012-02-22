<%@ page language="java" errorPage="/error.jsp"
	contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<title>选择送货方式 </title>
		<link href="/ithinkgo1.css" rel="stylesheet" type="text/css" />
		<link href="/user/error.css" rel="stylesheet" type="text/css" />
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

		<!--order-->
		<div class="order">

			<div class="step">
				<ul>
					<li class="dian2">
						1.查看购物车
					</li>
					<li class="dian2">
						2.确认收货地址
					</li>
					<li class="dian1">
						3.选择送货方式
					</li>
					<li class="dian2">
						4.选择支付方式
					</li>
					<li class="dian3">
						5.确认订单
					</li>
				</ul>
			</div>

			<form action="/order/carrymode.do" name="carrymodefrm" method="post" id="carrymodefrm">
				<input type="hidden" name="cmd" id="cmd" value="setCarrymode" />
				<input type="hidden" name="token" value="${token }" />
					<div class="ckgwc2">
						<ul>
							<input name="carrymode" type="radio" value="1" checked="checked"/>
							送货上门
						</ul>
						<ul class="qtdz">
							直接送货上门
						</ul>
						<div class="firefox"></div>
					</div>
					<div class="text_center" style="padding-top: 10px;">
						<a href="/user/loadaddress.do?cmd=orderAddress">上一步</a>&nbsp;&nbsp;
						<a href="/order/carrymode.do?cmd=setCarrymode&token=${token }"><img src="/images/submit_04.png" />
						</a>
					</div>


				</form>
		</div>
		<!--order_end-->

		<!--down-->
		<jsp:include page="/user/common/div_bottom.inc" />
		<!--down_end-->
	</body>
</html>