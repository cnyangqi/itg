<%@ page language="java" errorPage="/error.jsp"
	contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<title>选择支付方式 </title>
		<link href="/ithinkgo1.css" rel="stylesheet" type="text/css" />
		<link href="/user/error.css" rel="stylesheet" type="text/css" />
		<LINK href="/order/images/layout.css" type="text/css" rel="stylesheet">
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
					<li class="dian2">
						3.选择送货方式
					</li>
					<li class="dian1">
						4.选择支付方式
					</li>
					<li class="dian3">
						5.确认订单
					</li>
				</ul>
			</div>

			<form action="/order/paymode.do" name="paymodefrm" method="post" id="paymodefrm">
				<input type="hidden" name="cmd" id="cmd" value="setPaymode" />
				<input type="hidden" name="token" value="${token }" />
					<div class="ckgwc2">
						 <table>
						 	<tr>
			                   <td><input type="radio" name="pay_bank" value="default" checked="checked" >储值卡余额支付</td>
			                 </tr>
			                 <tr>
			                   <td><input type="radio" name="pay_bank" value="directPay" <c:if test="${pay.pay_type=='directPay' }">checked="checked"</c:if> ><img src="/order/images/alipay_1.gif" border="0"/></td>
			                 </tr>
			                 <tr>
			                   <td><input type="radio" name="pay_bank" value="ABC" <c:if test="${pay.defaultbank=='ABC' }">checked="checked"</c:if>/><img src="/order/images/ABC_OUT.gif" border="0"/></td>
			                 </tr>
			               </table>
						
						<div class="firefox"></div>
					</div>
					<div class="text_center" style="padding-top: 10px;">
						<a href="/order/carrymode.do?cmd=init">上一步</a>&nbsp;&nbsp;
						<a href="javascript:document.paymodefrm.submit();"><img src="/images/submit_04.png" />
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