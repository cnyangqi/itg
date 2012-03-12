<%@ page language="java" errorPage="/error.jsp"
	contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<title>确认订单</title>
		<link href="/ithinkgo1.css" rel="stylesheet" type="text/css" />
		<link href="/user/error.css" rel="stylesheet" type="text/css" />
		<script type="text/javascript" src="/jquery/jquery-1.6.js"></script>
		<script type="text/javascript" src="/jquery/jquery.validate.js"></script>
		<script type="text/javascript" src="/order/confirmOrder.js"></script>
		<script type="text/javascript" src="/user/myvalidate.js"></script>
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
					<li class="dian2">
						4.选择支付方式
					</li>
					<li class="dian4">
						5.确认订单
					</li>
				</ul>
			</div>

			<form action="/order/confirmorder.do" name="confirmorder" method="post" id="confirmorder">
				<input type="hidden" name="cmd" id="cmd" value="confirm" />
				<input type="hidden" name="token" value="${token }" />
				<div class="ckgwc2">
					<ul class="font_bold">
						商品信息&nbsp;&nbsp;
						<!-- <a href="/order/cart.do?cmd=view">[修改]</a> -->
					</ul>
					<ul>
						<table width="100%" border="0" cellpadding="0" cellspacing="0"
							class="table">
							<tr class="ti">
								<td width="6%" class="text_center">
									序号
								</td>
								<td width="62%" class="text_center">
									商品
								</td>
								<td width="8%" class="text_center">
									积分
								</td>
								<td width="7%" class="text_center">
									单价
								</td>
								<td width="8%" class="text_center">
									数量
								</td>
								<td width="9%" class="text_center nobr">
									金额
								</td>
							</tr>
							<c:choose>
								<c:when test="${empty list}">
								<tr>
									<td colspan="6">没有符合条件的数据!</td>
								</tr>
								</c:when>
								<c:otherwise>
									<c:forEach items="${list}" var="bean" varStatus="vs">
									 <tr>
							            <td class="text_center">${vs.count }</td>
							            <td>
											<div class="left text_center" style="width: 20%">
												<img src="${bean.prd_picurl }" width="78" height="59"/>
											</div>
											<div class="left " style="width: 80%">
												<a href="${bean.prd_url }" target="_blank">${bean.prd_name }</a>
											</div>
										</td>
										<td class="text_center">
											${bean.prd_point }
										</td>
							            <td class="text_center">
											${bean.prd_price }
										</td>
							            <td class="text_center">
											${bean.amount }
										</td>
							            <td class="text_red text_center nobr">
											${bean.amount*bean.prd_price }
										</td>							            
							          </tr>
									</c:forEach>
								</c:otherwise>
							</c:choose>
						</table>
					</ul>
					<ul>
						<span class="right">购买此订单可获得&nbsp;<span class="font_bold">${orderrec.or_point }</span>&nbsp;个积分&nbsp;&nbsp;&nbsp;&nbsp;总金额（含运费<span
							class="text_red">5元</span>）：<span style="font-size: 18px"
							class="font_bold text_red">${orderrec.or_money+5 }</span>元</span>
					</ul>
					<ul class="font_bold">
						收货地址&nbsp;&nbsp;
						<!-- <a href="/user/loadaddress.do?cmd=orderAddress">[修改]</a> -->
					</ul>
					<ul>
					<c:choose>
							<c:when test="${not empty address.fpid}">
								${user.itg_fixedpointname }
							</c:when>
							<c:otherwise>
								${address.name }(${address.mobile })&nbsp;&nbsp;${address.detail }
							</c:otherwise>
						</c:choose>
								
								
								
					</ul>
					<ul class="font_bold">
						送货方式&nbsp;&nbsp;
						<!-- <a href="/order/carrymode.do?cmd=init">[修改]</a> -->
					</ul>
					<ul>
						送货上门
					</ul>
					<ul class="font_bold">
						支付方式&nbsp;&nbsp;
						<!-- <a href="/order/paymode.do?cmd=init">[修改]</a> -->
					</ul>
					<ul>
						<c:choose>
							<c:when test="${pay.pay_type=='default'}">
								储值卡余额支付
							</c:when>
							<c:otherwise>
								<c:choose>
									<c:when test="${pay.pay_type=='directPay'}">
										<img src="/order/images/alipay_1.gif" border="0"/>
									</c:when>
									<c:otherwise>
										<img src="/order/images/${pay.defaultbank }_OUT.gif" border="0"/>
									</c:otherwise>
								</c:choose>
							</c:otherwise>
						</c:choose>
					</ul>
					<ul class="font_bold">
						索要发票
					</ul>
					<ul>
						发票抬头：
						<input name="or_invoicetitle" id="or_invoicetitle" type="text" class="input" value="${orderrec.or_invoicetitle }"/><font color="red"><html:errors property="or_invoicetitle"/></font>
						<span class="text_gray">发票需扣商品价6%，不需要请留空</span>
					</ul>
					<ul class="font_bold">
						留言
					</ul>
					<ul>
						<textarea cols="60" rows="2" id="or_memo" name="or_memo">${orderrec.or_memo }</textarea><font color="red"><html:errors property="or_memo"/></font>
						<span class="text_gray">请填写需要送货上门的时间</span>
					</ul>
					<ul class="font_bold">
						送货上门时间范围
					</ul>
					<ul>
						当天12点前的订单，我们将于第2天早上8:00至下午3:00送货，12点之后的订单，将于第3天配送。
					</ul>

					<div class="firefox"></div>
				</div>
				<div class="text_center" style="padding-top: 10px;">
					<a href="/order/paymode.do?cmd=init">上一步</a>&nbsp;&nbsp;
					<a href="javascript:confirmordersubmit()"><img src="/images/submit_05.png" />
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