<%@ page language="java" errorPage="/error.jsp"
	contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="my" uri="http://www.ithinkgo.com/functions"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<title>订单详细信息</title>
		<link href="/ithinkgo1.css" rel="stylesheet" type="text/css" />
		<link href="/user/error.css" rel="stylesheet" type="text/css" />
		<script type="text/javascript" src="/jquery/jquery-1.6.js"></script>
		<script type="text/javascript" src="/jquery/jquery.validate.js"></script>
		<script type="text/javascript" src="/user/orderdetail.js"></script>
		<script type="text/javascript" src="/user/myvalidate.js"></script>
		
		<link href="/jquery/thickbox31/thickbox.css" rel="stylesheet" type="text/css" />
		<link rel="alternate stylesheet" type="text/css" href="/jquery/thickbox31/1024.css" title="1024 x 768" />
		<script src="/jquery/thickbox31/thickbox-compressed.js" type="text/javascript"></script>
		<script src="/jquery/thickbox31/global.js" type="text/javascript"></script>
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
			<form action="/user/ordermodify.do" name="orderfrm" method="post"
				id="orderfrm">
				<input type="hidden" name="cmd" id="ordercmd"/>
				<input type="hidden" name="token" value="${token }" />
				<input type="hidden" name="or_id" id="or_id" value="${orderrec.or_id }" />
			</form>
			<form action="/user/ordermodify.do" name="confirmorder" method="post"
				id="confirmorder">
				<input type="hidden" name="cmd" id="comfirmcmd" value="confirm" />
				<input type="hidden" name="or_id" value="${orderrec.or_id }" />
				<input type="hidden" name="token" value="${token }" />
				<div class="ckgwc2">
					<ul class="font_bold">
						订单状态&nbsp;&nbsp;
					</ul>
					<ul>
						${my:getOrderStatusInfo1(orderrec.or_status)}
					</ul>
					<ul class="font_bold">
						商品信息&nbsp;&nbsp;
					</ul>
					<ul>
						<table width="100%" border="0" cellpadding="0" cellspacing="0"
							class="table">
							<tr class="ti">
								<td width="6%" class="text_center">
									序号
								</td>
								<td width="56%" class="text_center">
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
								<c:if test="${orderrec.or_userid==user.id}">
								<c:if test="${orderrec.or_status==4}">
									<td width="6%" class="text_center nobr">
										评价
									</td>		
								</c:if>
								</c:if>
								
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
												<img src="${bean.pic_url }" width="78" height="59"/>
											</div>
											<div class="left " style="width: 80%">
												<a href="${bean.url_gen }" target="_blank">${bean.prd_name }</a>
											</div>
										</td>
										<td class="text_center">
											${bean.prd_point }
										</td>
							            <td class="text_center">
											${bean.prd_localprice }
										</td>
							            <td class="text_center">
											${bean.od_num }
										</td>
							            <td class="text_center">
											${bean.od_price*bean.od_num }
										</td>
										<c:if test="${orderrec.or_userid==user.id}">
										<c:if test="${orderrec.or_status==4}">
											<td class="text_center">
												<a href="/user/ordereval.do?height=455&width=350&cmd=orderEvalInit&od_id=${bean.od_id }&TB_iframe=true&height=455&amp;width=350&amp;modal=true" class="thickbox">评价</a>
											</td>		
										</c:if>
										</c:if>							            
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
						<c:if test="${orderrec.or_userid==user.id}">
						<c:if test="${orderrec.or_status==0}">
							<a href="/user/changeorderaddress.jsp?or_id=${orderrec.or_id }&TB_iframe=true&height=300&amp;width=500&amp;modal=true" class="thickbox">[修改]</a>
						</c:if>
						</c:if>
						
					</ul>
					<ul>
						<span id="addressSpan">
							<c:choose>
								<c:when test="${not empty address.fpid}">
									${user.itg_fixedpointname }
								</c:when>
								<c:otherwise>
									${address.name }(${address.mobile })&nbsp;&nbsp;${address.detail }
								</c:otherwise>
							</c:choose>
						
						</span>
					</ul>
					<ul class="font_bold">
						送货方式&nbsp;&nbsp;
						<!--
						<c:if test="${orderrec.or_status==0}">
							<!-- <a href="">[修改]</a> -->
						</c:if>
						-->
					</ul>
					<ul>
						送货上门
					</ul>
					<ul class="font_bold">
						支付方式&nbsp;&nbsp;
						<!-- 
						<c:if test="${orderrec.or_userid==user.id}">
						<c:if test="${orderrec.or_status==0||orderrec.or_status==1}">
							<a  href="/user/changeorderpay.jsp?or_id=${orderrec.or_id }&TB_iframe=true&height=300&amp;width=500&amp;modal=true" class="thickbox">[修改]</a>
						</c:if>
						</c:if>
						 -->
					</ul>
					<ul>
						<span id="paySpan">
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
						</span>
					</ul>
					<ul class="font_bold">
						索要发票
					</ul>
					<ul>
						发票抬头：
						${orderrec.or_invoicetitle }
						
					</ul>
					<ul class="font_bold">
						留言
					</ul>
					<ul>
						${orderrec.or_memo }
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
				<c:if test="${orderrec.or_userid==user.id}">
					<c:if test="${orderrec.or_status==0}">
						<input type="button" name="确认订单" value="确认订单" onclick="javascript:confirmordersubmit();">&nbsp;&nbsp;&nbsp;
						<input type="button" name="取消订单" value="取消订单" onclick="javascript:cancheordersubmit();">		
					</c:if>
					<c:if test="${orderrec.or_status==1}">
						<input type="button" name="确认付款" value="确认付款" onclick="javascript:payordersubmit();">&nbsp;&nbsp;&nbsp;
						<input type="button" name="取消订单" value="取消订单" onclick="javascript:cancheordersubmit();">
					</c:if>
					<c:if test="${orderrec.or_status==3}">
						<input type="button" name="确认收货" value="确认收货" onclick="javascript:receivingordersubmit();">&nbsp;&nbsp;&nbsp;
					</c:if>
				</c:if>
				</div>
			</form>
		</div>
		<!--order_end-->

		<!--down-->
		<jsp:include page="/user/common/div_bottom.inc" />
		<!--down_end-->
	</body>
</html>
<c:choose>
	<c:when test="${empty message}">
	</c:when>
	<c:otherwise>
	<a href="${message.url }" target="_self" id="to_url"></a>
		<c:choose>
			<c:when test="${message.flag}">
				<script type="text/javascript"> 
					alert("${message.msg}");
					var element = document.getElementById('to_url');
					element.click();
					
				</script>
			</c:when>
			<c:otherwise>
				<script type="text/javascript"> 
					alert("${message.error}");
					var element = document.getElementById('to_url');
					element.click();
				</script>
			</c:otherwise>
		</c:choose> 
	</c:otherwise>
</c:choose> 