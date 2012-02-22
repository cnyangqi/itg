<%@ page language="java" errorPage="/error.jsp" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
<%@ include file = "/include/header.jsp" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>储值卡充值</title>
<link href="/ithinkgo1.css" rel="stylesheet" type="text/css" />
<link href="/user/error.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="/jquery/jquery-1.6.js"></script>
<script type="text/javascript" src="/jquery/jquery.validate.js"></script>
<script type="text/javascript" src="/user/czkrechargerc.js"></script>
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

<!--my-->
<div class="my_ithinkgo">

	<!--user_munu-->
	<jsp:include page="/user/common/user_menu.inc"/>
	<!--user_munu_end-->
	
    <div class="content">
    <div class="menu2">
    <ul>
    <li>储值卡充值</li>
    <li><a href="/user/load.do?cmd=recharge">支付宝\网银充值</a></li>
    <li><a href="/user/rechargerec.do?cmd=search">充值记录</a></li>
    </ul>    
    </div>
    <form name="chargercfrm" id="chargercfrm" action="/user/rechargerec.do" method="post">
    <input type="hidden" name="cmd" value="czkRecharge"/>
    <input type="hidden" name="token" value="${token }" />
     <div class="zlxg">
    <ul><li class="ti">储值卡卡号：</li><li class="con"><input name="cardno" type="text" class="input itop" /></li></ul>
    <ul><li class="ti">储值卡密码：</li><li class="con"><input name="cardpwd" type="password" class="input itop" /></li></ul>
    <ul><li class="ti">&nbsp;</li><li class="con"><input name="" type="submit" value="确定" class="submit" /></li></ul>
    </div>
    </form>
    </div>
    <div class="firefox"></div>
    
</div>
<!--my_end-->
<!--service-->
<jsp:include page="/user/common/div_services.inc" />
<!--ervice_end-->

<!--about-->
<jsp:include page="/user/common/div_about.inc"  />
<!--ervice_end-->

<!--link-->
<jsp:include page="/user/common/div_links.inc"  />
<!--link_end-->

<!--down-->
<jsp:include page="/user/common/div_bottom.inc"  />
<!--down_end-->
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
					
				</script>
			</c:when>
			<c:otherwise>
				<script type="text/javascript"> 
					alert("${message.error}");
				</script>
			</c:otherwise>
		</c:choose> 
	</c:otherwise>
</c:choose> 