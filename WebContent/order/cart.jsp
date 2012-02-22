<%@ page language="java" errorPage="/error.jsp" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>我的购物车</title>
<link href="/ithinkgo.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="/jquery/jquery-1.6.js"></script>
<link rel="stylesheet" href="/jquery/thickbox/thickbox1.css" type="text/css" media="screen" />
<script type="text/javascript" src="/jquery/thickbox/thickbox.js"></script>
<script type="text/javascript" src="/jquery/thickbox/option.js"></script>
<script type="text/javascript" src="/order/cart.js"></script>
</head>
<body>

<!--top-->
<jsp:include page="/user/common/div_top.inc"/>
<!--top_end-->

<!--menu-->
<jsp:include page="/user/common/div_menu.inc"/>
<!--menu_end-->

<!--search-->
<jsp:include page="/user/common/div_hotsearch.inc"/>
<!--search_end-->

<!--order-->
<div class="order">

	<div class="step">
    <ul>
    <li class="dian1">1.查看购物车</li>
    <li class="dian2">2.确认收货地址</li>
    <li class="dian2">3.选择送货方式</li>
    <li class="dian2">4.选择支付方式</li>
    <li class="dian3">5.确认订单</li>
    </ul>
    </div>
    
    <form action="/order/cart.do" name="cartfrm" method="post" id="cartfrm">
	<input type="hidden" name="cmd" id="cmd" value="del" />
	<input type="hidden" name="prdsize" id="prdsize" value="${fn:length(beans)}" />
	<input type="hidden" name="token" value="${token }" />
	<c:if test="${not empty user}">
	<input type="hidden" name="islogin" id="islogin" value="true" />
	</c:if>
    <div class="ckgwc">
      <ul>
        <table width="100%" border="0" cellpadding="0" cellspacing="0" class="table">
          <tr class="ti">
            <td width="47%"><input name="checkedAll"  id="checkedAll" type="checkbox" value="" />全选/反选</td>
            <td width="9%" class="text_center">积分<a href="#" title="什么是积分"><img src="/images/ico_13.png" /></a></td>
            <td width="10%" class="text_center">单价</td>
            <td width="13%" class="text_center">数量</td>
            <td width="10%" class="text_center">金额</td>
            <td width="11%" class="text_center nobr">操作</td>
          </tr>
          <c:set var="_price" value="0"></c:set>
          <c:set var="_point" value="0"></c:set>
          <c:choose>
				<c:when test="${empty beans}">
				<tr>
					<td colspan="6">没有符合条件的数据!</td>
				</tr>
				</c:when>
				<c:otherwise>
					<c:forEach items="${beans}" var="bean" varStatus="vs">
					 <tr>
			            <td>
			            	<c:set var="_price" value="${_price+(bean.amount*bean.prd_price)}"></c:set>
			            	<c:set var="_point" value="${_point+(bean.amount*bean.prd_point)}"></c:set>
			            	<!-- 全选按钮 -->
			            	<div class="left text_center" style="width:10%"><input name="cart_id" type="checkbox" value="${bean.id }" style="margin-top:20px;" /></div>
			            	<!-- 商品图片 -->
			            	<div class="left text_center" style="width:20%"><a href="${bean.prd_url }"><img src="${bean.prd_picurl }" width="78" height="59"/></a></div>
			            	<!-- 商品名称 -->
			            	<div class="left " style="width:70%"><a href="${bean.prd_url }">${bean.prd_name }</a></div></td>
			            	<td class="text_center"><span id="point_${vs.count }">${bean.prd_point }</span></td>
			            	<td class="text_center"><span id="price_${vs.count }">${bean.prd_price }</span></td>
			            	<td class="text_center"><img src="/images/ico_15.png" title="减少" onclick="minus_amount('${vs.count }')" style="cursor: hand;"/>
							<input name="amount" id="amount_${vs.count }" type="text" class="input text_center" value="${bean.amount }" size="3" onchange="amountChange(this)"/>
							<input name="cartid" id="cartid_${vs.count }" type="hidden" value="${bean.id }"/>
							<img src="/images/ico_14.png" title="增加" onclick="add_amount('${vs.count }')" style="cursor: hand;"/></td>
			            <td class="text_red text_center">${bean.prd_price*bean.amount }</td>
			            <td class="text_center nobr"><a href="/order/cart.do?cmd=del&cart_id=${bean.id }&token=${token }">[删除]</a></td>
			          </tr>
					</c:forEach>
				</c:otherwise>
			</c:choose>
          <tr>
            <td colspan="6" class="ti">
            <div class="left"><a href="javascript:batchdel()"><img src="/images/button_02.png" /></a></div>
            <div class="right">购买此订单可获得&nbsp;<span class="font_bold" id="sp_point">${_point}</span>&nbsp;个积分&nbsp;&nbsp;&nbsp;&nbsp;总金额（不含运费）：<span style="font-size:18px" class="font_bold text_red" id="sp_price">${_price }</span>元</div>
            </td>
          </tr>
        </table>
      </ul>
      <ul>
      <li class="left" style="padding:10px 0 0 20px;"><span class="font_bold">购物提醒：</span><br />-&nbsp;配送地点不同的商品，不能放在同一张订单里。<br />-&nbsp;购物满188元起送货</li>
      <li class="right" style="padding:20px 0 0 0;">
      	<c:choose>
			<c:when test="${not empty user}">
				<a href="javascript:cartSubmit()"><img src="/images/submit_03.png" /></a>
			</c:when>
			<c:otherwise>
				<a href="/order/login.jsp?TB_iframe=true&height=230&width=350"  class="thickbox"><img src="/images/submit_03.png" /></a>
			</c:otherwise>
		</c:choose>
      	
      	</li>
      </ul>
      <div class="firefox"></div>
    </div>
    </form>
    
</div>
<!--order_end-->

<!--down-->
<jsp:include page="/user/common/div_bottom.inc"  />
<!--down_end-->
</body>
</html>