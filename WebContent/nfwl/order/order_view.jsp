<%@ page language="java" errorPage="/error.jsp"
	contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ include file="/include/header.jsp"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<title>订单详细信息</title>
		<LINK href="/css/style.css" rel="stylesheet">
		<script type="text/javascript" src="/jquery/jquery-1.6.js"></script>
	</head>
	<body>
	<table width="100% " border="0" cellpadding="0" cellspacing="1"
			class="TitleBar">
			<tr height="30">
				<td colspan="4"><h2>订单信息</h2></td>
			</tr>
			<tr class="DetailBar" height="30">
				<td width="15">总金额:</td>
				<td width="35">${order.or_money }</td>
				<td width="15">支付方式:</td>
				<td width="35">
				<c:if test="${order.or_paytype ==1}">
			          	账户余额 
			          </c:if>
			          <c:if test="${order.or_paytype ==2}">
			          	储值卡
			          </c:if>
			          <c:if test="${order.or_paytype ==3}">
			          	支付宝
			          </c:if>
			          <c:if test="${order.or_paytype ==4}">
			          	 农行
			          </c:if>
				</td>
			</tr>
			<tr class="DetailBar" height="30">
				<td width="15">订单状态:</td>
				<td width="35">
					<c:if test="${order.or_status ==1}">
			          	未付款
			          </c:if>
			          <c:if test="${order.or_status ==2}">
			          	已付款
			          </c:if>
			          <c:if test="${order.or_status ==3}">
			          	 正在配送
			          </c:if>
			          <c:if test="${order.or_status ==4}">
			          	  完成
			          </c:if>
			          <c:if test="${order.or_status ==10}">
			          	  取消
			          </c:if>
				</td>
				<td width="15">下单时间:</td>
				<td width="35">${order.or_time }</td>
			</tr>
			
			<tr class="DetailBar" height="30">
				<td width="15">订单号:</td>
				<td width="35">${order.or_no }</td>
			</tr>
		</table>
		<table width="100% " border="0" cellpadding="0" cellspacing="1"
			class="TitleBar">
			<tr height="30">
				<td colspan="4"><h2>用户信息</h2></td>
			</tr>
			<tr class="DetailBar" height="30">
				<td width="15">账号:</td>
				<td width="35">${user.account }</td>
				<td width="15">呢称:</td>
				<td width="35">${user.nickname }</td>
			</tr>
			<tr class="DetailBar" height="30">
				<td width="15">真实姓名:</td>
				<td width="35">${user.name }</td>
				<td width="15">性别:</td>
				<td width="35">
				<c:if test="${user.sex=='0' }"> 男</c:if>
				<c:if test="${user.sex=='1' }"> 女</c:if>
				</td>
			</tr>
			<tr class="DetailBar" height="30">
				<td width="15">手机号码:</td>
				<td width="35">${user.mobile }</td>
				<td width="15">固定电话:</td>
				<td width="35">${user.areacode }-${user.telephone }-${user.subnum }(区号-号码-分机)</td>
			</tr>
			<tr class="DetailBar" height="30">
				<td width="15">传真:</td>
				<td width="35">${user.faxareacode }-${user.fax }(区号-号码)</td>
				<td width="15">详细地址:</td>
				<td width="35">${user.detailadr }</td>
			</tr>
		</table>
		<table width="100% " border="0" cellpadding="0" cellspacing="1"
			class="TitleBar">
			<tr height="30">
				<td colspan="4"><h2>收货地址信息</h2></td>
			</tr>
			<tr class="DetailBar" height="30">
				<td width="15">收货人:</td>
				<td width="35">${user.account }</td>
				<td width="15">固定电话:</td>
				<td width="35">${address.adr_areacode }-${address.adr_telephone }-${address.adr_subnum }${address.adr_subnum }(区号-号码-分机)</td>
			</tr>
			<tr class="DetailBar" height="30">
				<td width="15">手机号码:</td>
				<td width="35">${address.adr_postcode }</td>
				<td width="15">电子邮箱:</td>
				<td width="35">${address.adr_email }</td>
			</tr>
			
			<tr class="DetailBar" height="30">
				<td width="15">详细地址:</td>
				<td width="35">${address.adr_detail }</td>
			</tr>
		</table>
		<table width="100% " border="0" cellpadding="0" cellspacing="1" class="TitleBar">
			<tr height="30">
				<td colspan="3"><h2>订单商品</h2></td>
			</tr>
			<tr class="DetailBar" height="30">
	          <td>商品名称</td>
	          <td>商品价格</td>
	          <td>数量</td>
	        </tr>
			<c:choose>
				<c:when test="${empty list}">
				<tr>
					<td colspan="7">没有符合条件的数据!</td>
				</tr>
				</c:when>
				<c:otherwise>
					<c:forEach items="${list}" var="bean">
					<tr class="DetailBar" height="30">
			          <td><a href="${bean.url_gen}" target="_blank">${bean.od_prdname }</a></td>
			          <td>${bean.od_price }</td>
			          <td>${bean.od_num }</td>
			        </tr>
					</c:forEach>
				</c:otherwise>
			</c:choose>    
		</table>
	</body>
</html>