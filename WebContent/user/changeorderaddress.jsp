<%@ page language="java" errorPage="/error.jsp"
	contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="com.nfwl.itg.common.TokenManager"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="my" uri="http://www.ithinkgo.com/functions"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<title>订单详细信息</title>
		<link href="/ithinkgo1.css" rel="stylesheet" type="text/css" />
		<script type="text/javascript" src="/jquery/jquery-1.6.js"></script>
		
		<link href="/jquery/thickbox31/thickbox.css" rel="stylesheet" type="text/css" />
		<link rel="alternate stylesheet" type="text/css" href="/jquery/thickbox31/1024.css" title="1024 x 768" />
		<script src="/jquery/thickbox31/thickbox-compressed.js" type="text/javascript"></script>
		<script src="/jquery/thickbox31/global.js" type="text/javascript"></script>
		<script type="text/javascript">
		function addressSubmit(){
			
			var or_id = $("#or_id").val();
			if(or_id==""){
				alert("没有可以设置地址的订单");
				return;
			}
			
			var _flag=false;
			$("input[name='adr_id']").each(function(){
				if(this.checked){
					_flag=true;
					return;
				}
			});
			if(_flag){
				$("#addressfrm").submit();
			}else{
				alert("你必须选择地址!");
			}
		} 
		</script>
	</head>
	<% 
		String or_id = request.getParameter("or_id");
		if(or_id==null||or_id==""){
			or_id="";
		}else{
			TokenManager.saveToken(request);
		}
		
	%>
	<c:set var="list" value="${my:getUserAddress(user.id)}"></c:set>
	<body>
	 <form action="/user/ordermodify.do" name="addressfrm" method="post" id="addressfrm">
	 	<input type="hidden" name="cmd" id="cmd" value="changeAddress" />
	 	<input type="hidden" name="or_id" id="or_id" value="<%=or_id %>" />
	    <input type="hidden" name="token" value="${token }" />
		<div class="popup" style="width:529px;height:300px;">
			<div class="bt"><div class="left">&nbsp;&nbsp;收货地址</div><div class="right" style="height:100%;"><a href="javascript:self.parent.tb_remove();" title="关闭"><img src="/images/ico_17.png" /></a></div></div>
		    <div class="rr">
		    <div>
		     <c:if test="${not empty user.itg_fixedpoint}">
		    	<ul class="dz" id="ul_itg_fixedpoint" name="ul_adr"><input name="adr_id" type="radio" value="itg_fixedpoint" />
		    	${user.itg_fixedpointname }<font color="red">[定点单位]</font>
		    	</ul>
		    </c:if>
			<c:forEach items="${list}" var="bean" varStatus="vs">
					<ul class="dz"  name="ul_adr">
					<input name="adr_id" type="radio" value="${bean.adr_id }"/>
					${bean.adr_name }(${bean.adr_mobile })&nbsp;&nbsp;&nbsp;
					${bean.adr_detail } &nbsp;&nbsp;&nbsp;
				</ul>
			</c:forEach>
			</div>
		    <div class="text_center"><input name="确定" type="button" value="确定" onclick="addressSubmit()"/></div>
		    </div>
		</div>
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
					<c:choose>
						<c:when test="${address.fpid!='' }">
							self.parent.callBackAddress('${user.itg_fixedpointname }<font color="red">[定点单位]</font>');	
						</c:when>
						<c:otherwise>
							self.parent.callBackAddress('${address.name }(${address.mobile })&nbsp;&nbsp;&nbsp;${address.detail } &nbsp;&nbsp;&nbsp;');		
						</c:otherwise>
					</c:choose> 
					
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