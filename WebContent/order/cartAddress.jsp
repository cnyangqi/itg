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
<script type="text/javascript" src="/order/cartAddress.js"></script>
<script type="text/javascript" src="/jquery/jquery.validate.js"></script>
<script type="text/javascript" src="/user/myvalidate.js"></script>
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
    <li class="dian2">1.查看购物车</li>
    <li class="dian1">2.确认收货地址</li>
    <li class="dian2">3.选择送货方式</li>
    <li class="dian2">4.选择支付方式</li>
    <li class="dian3">5.确认订单</li>
    </ul>
    </div>
    <c:set var="zones" value="${my:getZone()}"></c:set>
	<c:set var="list" value="${my:getUserAddress(user.id)}"></c:set>
	
    <form action="/order/address.do" name="cartAddressfrm" method="post" id="cartAddressfrm">
    <input type="hidden" name="cmd" id="cmd" value="confirm" />
    <input type="hidden" name="token" value="${token }" />
	<div class="ckgwc2">
    <ul class="text_right"><a href="/user/address.do?cmd=view" target="_blank">管理我的收货地址</a></ul>
    <c:if test="${not empty user.itg_fixedpoint}">
    	<c:choose>
			<c:when test="${empty address}">
				<ul class="dz" id="ul_itg_fixedpoint" name="ul_adr"><input name="adr_id" type="radio" id="fiexdpointRadio" value="itg_fixedpoint" onclick="chk_adr_click(this,'','','','','','','','','')" />
		    		${user.itg_fixedpointname }<font color="red">[定点单位]</font>
		    	</ul>
			</c:when>
			<c:otherwise>
				<ul class="dz" id="ul_itg_fixedpoint" name="ul_adr"><input name="adr_id" type="radio" id="fiexdpointRadio" value="itg_fixedpoint" onclick="chk_adr_click(this,'','','','','','','','','')" <c:if test="${not empty address.fpid }"> checked="checked"</c:if> />
		    		${user.itg_fixedpointname }<font color="red">[定点单位]</font>
		    	</ul>
			</c:otherwise>
		</c:choose>
    	
    	
    </c:if>
    
    <c:choose>
		<c:when test="${empty list}">
		</c:when>
		<c:otherwise>
			<c:forEach items="${list}" var="bean" varStatus="vs">
				<ul id="ul_${bean.adr_id }" name="ul_adr">
				<c:choose>
					<c:when test="${empty address}">
						<c:choose>
							<c:when test="${bean.adr_id==user.adrid }">
								<input name="adr_id" type="radio" value="${bean.adr_id }" onclick="chk_adr_click(this,'${bean.adr_detail }','${bean.adr_postcode }','${bean.adr_name }','${bean.adr_mobile }','${bean.adr_email }','${bean.adr_areacode }','${bean.adr_telephone }','${bean.adr_subnum }','${bean.adr_zone }')" checked="checked" />
								${bean.adr_name }(${bean.adr_mobile })&nbsp;&nbsp;${bean.adr_detail }
								<c:set value="${bean}" var="addressTmp"></c:set>
							</c:when>
							<c:otherwise>
								<input name="adr_id" type="radio" value="${bean.adr_id }" onclick="chk_adr_click(this,'${bean.adr_detail }','${bean.adr_postcode }','${bean.adr_name }','${bean.adr_mobile }','${bean.adr_email }','${bean.adr_areacode }','${bean.adr_telephone }','${bean.adr_subnum }','${bean.adr_zone }')" />
								${bean.adr_name }(${bean.adr_mobile })&nbsp;&nbsp;${bean.adr_detail }
							</c:otherwise>
						</c:choose>
					</c:when>
					<c:otherwise>
						<input name="adr_id" type="radio" value="${bean.adr_id }" onclick="chk_adr_click(this,'${bean.adr_detail }','${bean.adr_postcode }','${bean.adr_name }','${bean.adr_mobile }','${bean.adr_email }','${bean.adr_areacode }','${bean.adr_telephone }','${bean.adr_subnum }','${bean.adr_zone }')" <c:if test="${bean.adr_id==address.adrid }">checked="checked"</c:if>/>
							${bean.adr_name }(${bean.adr_mobile })&nbsp;&nbsp;${bean.adr_detail }
					</c:otherwise>
				</c:choose>
					
				</ul>
			</c:forEach>
		</c:otherwise>
	</c:choose>
	<!-- 
    <ul id="ul_other" name="ul_adr">
    	<input name="adr_id" id="chk_adr_other" type="radio"  value="other" onclick="chk_adr_click(this)" />使用其它地址</ul> -->
   
    <c:choose>
		<c:when test="${empty address }">
			 <ul class="qtdz">地区：
		      <select name="adr_zone" class="input itop">
		       <c:forEach items="${zones}" var="zone">
					<option value="${zone.id }" <c:if test="${zone.id==addressTmp.adr_zone }">selected="selected"</c:if>>${zone.name }</option>
				</c:forEach>
		      </select>&nbsp;&nbsp;&nbsp;&nbsp;
		           详细地址：<input  type="text" class="input itop" size="50" name="adr_detail" id="adr_detail" value="${addressTmp.adr_detail }"/><font color="red"><html:errors property="adr_detail"/></font>&nbsp;&nbsp;&nbsp;&nbsp;
		          邮政编码：<input type="text" class="input itop" size="8" name="adr_postcode" id="adr_postcode" value="${addressTmp.adr_postcode }"/><font color="red"><html:errors property="adr_postcode"/></font><br />
		   	 收货人：<input type="text" class="input" size="10" name="adr_name" id="adr_name" value="${addressTmp.adr_name }"/><font color="red"><html:errors property="adr_name"/></font>&nbsp;&nbsp;&nbsp;&nbsp;
		   	 手机号码：<input type="text" class="input itop" name="adr_mobile" id="adr_mobile" value="${addressTmp.adr_mobile }"/><font color="red"><html:errors property="adr_mobile"/></font>&nbsp;&nbsp;&nbsp;&nbsp;
		   	 电子邮箱：<input type="text" class="input itop" name="adr_email" id="adr_email" value="${addressTmp.adr_email }"/><font color="red"><html:errors property="adr_mobile"/></font>&nbsp;&nbsp;&nbsp;&nbsp;<br />
		           固定电话：<input name="adr_areacode" id="adr_areacode" type="text" class="input" size="3" value="${addressTmp.adr_areacode }"/><font color="red"><html:errors property="adr_areacode"/></font>
		           	 -<input name="adr_telephone" id="adr_telephone" type="text" class="input " size="10" value="${addressTmp.adr_telephone }"/><font color="red"><html:errors property="adr_telephone"/></font>
		           	 -<input name="adr_subnum" id="adr_subnum" type="text" class="input" size="3" value="${addressTmp.adr_subnum }"/><font color="red"><html:errors property="adr_subnum"/></font>区号-号码-分机
		    </ul>
		</c:when>
		<c:otherwise>
			<ul class="qtdz">地区：
		      <select name="adr_zone" class="input itop">
		       <c:forEach items="${zones}" var="zone">
					<option value="${zone.id }" <c:if test="${zone.id==address.zone }">selected="selected"</c:if>>${zone.name }</option>
				</c:forEach>
		      </select>&nbsp;&nbsp;&nbsp;&nbsp;
		           详细地址：<input  type="text" class="input itop" size="50" name="adr_detail" id="adr_detail" value="${address.detail }"/><font color="red"><html:errors property="adr_detail"/></font>&nbsp;&nbsp;&nbsp;&nbsp;
		          邮政编码：<input type="text" class="input itop" size="8" name="adr_postcode" id="adr_postcode" value="${address.postcode }"/><font color="red"><html:errors property="adr_postcode"/></font><br />
		   	 收货人：<input type="text" class="input" size="10" name="adr_name" id="adr_name" value="${address.name }"/><font color="red"><html:errors property="adr_name"/></font>&nbsp;&nbsp;&nbsp;&nbsp;
		   	 手机号码：<input type="text" class="input itop" name="adr_mobile" id="adr_mobile" value="${address.mobile }"/><font color="red"><html:errors property="adr_mobile"/></font>&nbsp;&nbsp;&nbsp;&nbsp;
		   	 电子邮箱：<input type="text" class="input itop" name="adr_email" id="adr_email" value="${address.email }"/><font color="red"><html:errors property="adr_mobile"/></font>&nbsp;&nbsp;&nbsp;&nbsp;<br />
		           固定电话：<input name="adr_areacode" id="adr_areacode" type="text" class="input" size="3" value="${address.areacode }"/><font color="red"><html:errors property="adr_areacode"/></font>
		           	 -<input name="adr_telephone" id="adr_telephone" type="text" class="input " size="10" value="${address.telephone }"/><font color="red"><html:errors property="adr_telephone"/></font>
		           	 -<input name="adr_subnum" id="adr_subnum" type="text" class="input" size="3" value="${address.subnum }"/><font color="red"><html:errors property="adr_subnum"/></font>区号-号码-分机
		    </ul>
		</c:otherwise>
	</c:choose>
      <div class="firefox"></div>
    </div>
    <div class="text_center" style="padding-top:10px;"><a href="/order/cart.do?cmd=view">上一步</a>&nbsp;&nbsp;<a href="javascript:cartAddressfrmSubmit()"><img src="/images/submit_04.png" /></a></div>

    </form>
    
</div>
<!--order_end-->

<!--down-->
<jsp:include page="/user/common/div_bottom.inc"  />
<!--down_end-->
</body>
</html>