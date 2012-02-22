<%@ page language="java" errorPage="/error.jsp" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
<%@ include file = "/include/header.jsp" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>我的订单</title>
<link href="/ithinkgo1.css" rel="stylesheet" type="text/css" />
<link href="/user/error.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="/jquery/jquery-1.6.js"></script>
<script type="text/javascript" src="/jquery/jquery.validate.js"></script>
<script type="text/javascript" src="/user/myvalidate.js"></script>
<script type="text/javascript" src="/user/evalorder.js"></script>
<style type="text/css"> 
.starWrapper img{cursor:pointer;}
</style>
</head>
<body>
<form name="evalfrm" id="evalfrm" action="/user/ordereval.do" method="post">
<input name="cmd" id="cmd" type="hidden"  value="orderEval"/>
<input name="me_odid" id="me_odid" type="hidden"  value="${bean.od_id }"/>
<input name="me_orid" id="me_orid" type="hidden"  value="${bean.od_orid }"/>
<input name="me_desclevel" id="me_desclevel" type="hidden"  value="5"/>
<input name="me_attitudelevel" id="me_attitudelevel" type="hidden"  value="5"/>
<input name="me_speedlevel" id="me_speedlevel" type="hidden"  value="5"/>
<input name="me_deliverylevel" id="me_deliverylevel" type="hidden"  value="5"/>
<input name="me_level" id="me_level" type="hidden"  value="5"/>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="table">
<tr>
	<td colspan="2"><h2>订单评价</h2></td>
</tr>
<tr>
	<td width="30%">商品与描述相符：</td><td width="70%">
		<p class="starWrapper" onclick="rate(this,event,'me_desclevel')">
			<img src="/images/icon_star_2.gif" title="很烂" />
			<img src="/images/icon_star_2.gif" title="一般" />
			<img src="/images/icon_star_2.gif" title="还好" />
			<img src="/images/icon_star_2.gif" title="较好" />
			<img src="/images/icon_star_2.gif" title="很好" />
		</p>
	</td>
</tr>
<tr>
	<td>卖家服态度：</td><td>
		<p class="starWrapper" onclick="rate(this,event,'me_attitudelevel')">
			<img src="/images/icon_star_2.gif" title="很烂" />
			<img src="/images/icon_star_2.gif" title="一般" />
			<img src="/images/icon_star_2.gif" title="还好" />
			<img src="/images/icon_star_2.gif" title="较好" />
			<img src="/images/icon_star_2.gif" title="很好" />
		</p>
	</td>
</tr>
<tr>
	<td>卖家发货速度：</td><td>
		<p class="starWrapper" onclick="rate(this,event,'me_speedlevel')">
			<img src="/images/icon_star_2.gif" title="很烂" />
			<img src="/images/icon_star_2.gif" title="一般" />
			<img src="/images/icon_star_2.gif" title="还好" />
			<img src="/images/icon_star_2.gif" title="较好" />
			<img src="/images/icon_star_2.gif" title="很好" />
		</p>
	</td>
</tr>
<tr>
	<td>物流公司服务：</td><td>
		<p class="starWrapper" onclick="rate(this,event,'me_deliverylevel')">
			<img src="/images/icon_star_2.gif" title="很烂" />
			<img src="/images/icon_star_2.gif" title="一般" />
			<img src="/images/icon_star_2.gif" title="还好" />
			<img src="/images/icon_star_2.gif" title="较好" />
			<img src="/images/icon_star_2.gif" title="很好" />
		</p>
	</td>
</tr>
<tr>
	<td>综合评价：</td><td>
		<p class="starWrapper" onclick="rate(this,event,'me_level')">
			<img src="/images/icon_star_2.gif" title="很烂" />
			<img src="/images/icon_star_2.gif" title="一般" />
			<img src="/images/icon_star_2.gif" title="还好" />
			<img src="/images/icon_star_2.gif" title="较好" />
			<img src="/images/icon_star_2.gif" title="很好" />
		</p>
	</td>
</tr>
<tr>
	<td>综合评价：</td><td>
		<textarea rows="4" cols="28" name="me_content" id="me_content" onKeyPress= "return   check(this); "></textarea>
	</td>
</tr>
<tr>
	<td colspan="2" align="center">
	<input name="" type="submit" value="保存" class="submit" />&nbsp;&nbsp;&nbsp;
	<input name="" type="button" value="关闭" class="submit"  onclick="self.parent.tb_remove();"/>
	</td>
</tr>
</table>
</form>
</body>
</html>
<c:choose>
	<c:when test="${empty message}">
	</c:when>
	<c:otherwise>
		<c:choose>
			<c:when test="${message.flag}">
				<script type="text/javascript"> 
					alert("${message.msg}");
					self.parent.tb_remove();
				</script>
			</c:when>
			<c:otherwise>
				<script type="text/javascript"> 
					alert("${message.error}");
					self.parent.tb_remove();
				</script>
			</c:otherwise>
		</c:choose> 
	</c:otherwise>
</c:choose> 
