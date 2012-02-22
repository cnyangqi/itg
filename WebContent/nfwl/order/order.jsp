<%@ page language="java" errorPage="/error.jsp"
	contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ include file="/include/header.jsp"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<title>订单管理</title>
		<LINK href="/css/style.css" rel="stylesheet">
		<script type="text/javascript" src="/jquery/jquery-1.6.js"></script>
	</head>
	<body>
		
		<table width="100% " border="0" cellpadding="0" cellspacing="1"
			class="TitleBar">
			<tr height="30">
				<td>订单号</td>
				<td>下单用户</td>
				<td>总金额</td>
				<td>支付方式</td>
				<td>订单状态 </td>
				<td>下单时间</td>
				<td>配送地址</td>
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
			          <td>${bean.or_no }</td>
			          <td>${bean.name }</td>
			          <td>${bean.or_money }</td>
			          <td>
			          <c:if test="${bean.or_paytype ==1}">
			          	账户余额 
			          </c:if>
			          <c:if test="${bean.or_paytype ==2}">
			          	储值卡
			          </c:if>
			          <c:if test="${bean.or_paytype ==3}">
			          	支付宝
			          </c:if>
			          <c:if test="${bean.or_paytype ==4}">
			          	 农行
			          </c:if>
			          </td>
			          <td>
			          <c:if test="${bean.or_status ==1}">
			          	未付款
			          </c:if>
			          <c:if test="${bean.or_status ==2}">
			          	已付款
			          </c:if>
			          <c:if test="${bean.or_status ==3}">
			          	 正在配送
			          </c:if>
			          <c:if test="${bean.or_status ==4}">
			          	  完成
			          </c:if>
			          <c:if test="${bean.or_status ==10}">
			          	  取消
			          </c:if>
			          </td>
			          <td>${bean.or_time }</td>
			          <td>${bean.adr_detail }</td>
			          <td class="nobr"><a href="/user/order.do?cmd=view&or_id=${bean.or_id }" target="_blank">查看明细</a></td>
			        </tr>
					</c:forEach>
				</c:otherwise>
			</c:choose>    
			

		</table>
	</body>
</html>