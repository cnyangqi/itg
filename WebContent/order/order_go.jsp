<%@ page language="java" errorPage="/error.jsp" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<%@ taglib prefix="my" uri="http://www.ithinkgo.com/functions"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>确认收货地址</title>
<link href="/ithinkgo1.css" rel="stylesheet" type="text/css" />
<link href="/user/error.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="/jquery/jquery-1.6.js"></script>
<script type="text/javascript" src="/order/order_go.js"></script>
<script type="text/javascript" src="/jquery/jquery.validate.js"></script>
<script type="text/javascript" src="/user/myvalidate.js"></script>
<link rel="stylesheet" href="/jquery/thickbox/thickbox1.css" type="text/css" media="screen" />
<script type="text/javascript" src="/jquery/thickbox/thickbox.js"></script>
<script type="text/javascript" src="/jquery/thickbox/option.js"></script>
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
   	<li class="dian1">1.确认订单信息</li>
    <li class="dian2">2.选择送货方式</li>
    <li class="dian2">3.选择支付方式</li>
    <li class="dian3">4.确认订单</li>

    </ul>
    </div>
    <c:set var="zones" value="${my:getZone()}"></c:set>
	<c:set var="list" value="${my:getUserAddress(user.id)}"></c:set>
    <form action="/order/ordergo.do" name="ordergofrm" method="post" id="ordergofrm">
    <input type="hidden" name="cmd" id="cmd" value="confirm" />
    <input type="hidden" name="prd_id" value="${prd.prd_id }" />
    <input type="hidden" name="token" value="${token }" />
    <div class="ckgwc3">
    
    <div class="tjsp">
    <ul>
    <li class="til">商品信息</li>
    <li class="con">
    <div><a href="${prd.prd_url }"><img src="${prd.prd_picurl }" width="134" height="109"/></a></div>
    <div><a href="${prd.prd_url }">${prd.prd_name }</a></div>
    <div>￥<span class="font_bold text_red">${prd.prd_price }</span></div>
    <div><span class="zk">8.5折</span></div>
    </li>
    </ul>   
    </div>
    
    <div class="dzsl">
    <ul><div class="left font_bold font_ize_14">确认收货地址</div>
    <div class="right"><a href="/user/loadaddress.do?cmd=view" target="_blank">管理我的收货地址</a></div></ul>
    <ul><hr /></ul>
     <c:if test="${not empty user.itg_fixedpoint}">
    	<ul class="dz" id="ul_itg_fixedpoint" name="ul_adr"><input name="adr_id" id="fiexdpointRadio" type="radio" value="itg_fixedpoint" onclick="chk_adr_click(this,'','','','','','','','','')"/>
    	${user.itg_fixedpointname }<font color="red">[定点单位]</font>
    	</ul>
    </c:if>
    
    <c:choose>
		<c:when test="${empty list}">
		</c:when>
		<c:otherwise>
			<c:forEach items="${list}" var="bean" varStatus="vs">
			
				<ul id="ul_${bean.adr_id }" name="ul_adr">
					
					<c:choose>
							<c:when test="${bean.adr_id==user.adrid }">
								<input name="adr_id" type="radio" value="${bean.adr_id }" onclick="chk_adr_click(this,'${bean.adr_detail }','${bean.adr_postcode }','${bean.adr_name }','${bean.adr_mobile }','${bean.adr_email }','${bean.adr_areacode }','${bean.adr_telephone }','${bean.adr_subnum }','${bean.adr_zone }')" checked="checked" />
								${bean.adr_name }(${bean.adr_mobile })&nbsp;&nbsp;${bean.adr_detail }
								<c:set value="${bean}" var="addressForm"></c:set>
							</c:when>
							<c:otherwise>
								<input name="adr_id" type="radio" value="${bean.adr_id }" onclick="chk_adr_click(this,'${bean.adr_detail }','${bean.adr_postcode }','${bean.adr_name }','${bean.adr_mobile }','${bean.adr_email }','${bean.adr_areacode }','${bean.adr_telephone }','${bean.adr_subnum }','${bean.adr_zone }')" />
								${bean.adr_name }(${bean.adr_mobile })&nbsp;&nbsp;${bean.adr_detail }
							</c:otherwise>
						</c:choose>
				</ul>
			</c:forEach>
		</c:otherwise>
	</c:choose>
     <ul class="qtdz">地区：
      <select name="adr_zone" class="input itop">
       <c:forEach items="${zones}" var="zone">
			<option value="${zone.id }">${zone.name }</option>
		</c:forEach>
      </select>
      
    &nbsp;&nbsp;&nbsp;&nbsp;详细地址：<input  type="text" class="input itop" size="50" name="adr_detail" id="adr_detail" value="${addressForm.adr_detail }"/><font color="red"><html:errors property="adr_detail"/></font>&nbsp;&nbsp;&nbsp;&nbsp;
    邮政编码：<input type="text" class="input itop" size="8" name="adr_postcode" id="adr_postcode" value="${addressForm.adr_postcode }"/><font color="red"><html:errors property="adr_postcode"/></font><br />
    收货人：<input type="text" class="input" size="10" name="adr_name" id="adr_name" value="${addressForm.adr_name }"/><font color="red"><html:errors property="adr_name"/></font>&nbsp;&nbsp;&nbsp;&nbsp;
    手机号码：<input type="text" class="input itop" name="adr_mobile" id="adr_mobile" value="${addressForm.adr_mobile }"/><font color="red"><html:errors property="adr_mobile"/></font>&nbsp;&nbsp;&nbsp;&nbsp;
    电子邮箱：<input type="text" class="input itop" name="adr_email" id="adr_email" value="${addressForm.adr_email }"/><font color="red"><html:errors property="adr_mobile"/></font>&nbsp;&nbsp;&nbsp;&nbsp;<br />
    固定电话：<input name="adr_areacode" id="adr_areacode" type="text" class="input" size="3" value="${addressForm.adr_areacode }"/><font color="red"><html:errors property="adr_areacode"/></font>
    		-<input name="adr_telephone" id="adr_telephone" type="text" class="input " size="10" value="${addressForm.adr_telephone }"/><font color="red"><html:errors property="adr_telephone"/></font>
    		-<input name="adr_subnum" id="adr_subnum" type="text" class="input" size="3" value="${addressForm.adr_subnum }"/><font color="red"><html:errors property="adr_subnum"/></font>区号-号码-分机
    </ul>   
    <ul></ul>
    <ul class="font_bold font_ize_14">确认购买信息</ul>
    <ul><hr /></ul>
    <ul>购买数量：<input name="num" type="text" class="input text_center" value="${prd.amount }" size="4" onchange="numChange(this,${prd.prd_point},${prd.prd_price})"/>件&nbsp;&nbsp;</ul>
    <ul>&nbsp;&nbsp;&nbsp;&nbsp;送积分：<span id="pointSpan">${prd.prd_point*prd.amount }</span>分</ul>
    <ul>总金额（不含运费）：<span style="font-size:18px" class="font_bold text_red" id="priceSpan">${prd.prd_price*prd.amount }</span>元</ul>    
	<ul style="padding:10px;"><a href="javascript:ordergofrmSubmit()"><img src="/images/submit_06.png" /></a></ul>
    <ul><span class="font_bold" onclick="confirmclick()">购物提醒：</span><br />-&nbsp;配送地点不同的商品，不能放在同一张订单里。<br /></ul>
    </div>
 
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