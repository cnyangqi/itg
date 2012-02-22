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
		function paySubmit(){
			
			var or_id = $("#or_id").val();
			if(or_id==""){
				alert("没有可以设置支付方式的订单");
				return;
			}
			
			var _flag=false;
			$("input[name='pay_bank']").each(function(){
				if(this.checked){
					_flag=true;
					return;
				}
			});
			if(_flag){
				$("#payfrm").submit();
			}else{
				alert("你必须支付方式!");
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
	 <form action="/user/ordermodify.do" name="payfrm" method="post" id="payfrm">
	 	<input type="hidden" name="cmd" id="cmd" value="changePay" />
	 	<input type="hidden" name="or_id" id="or_id" value="<%=or_id %>" />
	    <input type="hidden" name="token" value="${token }" />
		<div class="popup" style="width:529px;height:300px;">
			<div class="bt"><div class="left">&nbsp;&nbsp;支付方式</div><div class="right" style="height:100%;"><a href="javascript:self.parent.tb_remove();" title="关闭"><img src="/images/ico_17.png" /></a></div></div>
		    <div class="rr">
		    <div class="ckgwc2">
						 <table>
						 	<tr>
			                   <td><input type="radio" name="pay_bank" value="default" checked="checked" >储值卡余额支付</td>
			                 </tr>
			                 <tr>
			                   <td><input type="radio" name="pay_bank" value="directPay" ><img src="/order/images/alipay_1.gif" border="0"/></td>
			                 </tr>
			                 <tr>
			                   <td><input type="radio" name="pay_bank" value="ICBCB2C"/><img src="/order/images/ICBCB2C_OUT.gif" border="0"/></td>
			                   <td><input type="radio" name="pay_bank" value="CMB"  /><img src="/order/images/CMB_OUT.gif" border="0"/></td>
			                   <td><input type="radio" name="pay_bank" value="CCB"/><img src="/order/images/CCB_OUT.gif" border="0"/></td>
			                   <td><input type="radio" name="pay_bank" value="BOCB2C" /><img src="/order/images/BOCB2C_OUT.gif" border="0"/></td>
			                 </tr>
			                 <tr>
			                   <td><input type="radio" name="pay_bank" value="ABC" /><img src="/order/images/ABC_OUT.gif" border="0"/></td>
			                   <td><input type="radio" name="pay_bank" value="COMM"  /><img src="/order/images/COMM_OUT.gif" border="0"/></td>
			                   <td><input type="radio" name="pay_bank" value="SPDB" /><img src="/order/images/SPDB_OUT.gif" border="0"/></td>
			                   <td><input type="radio" name="pay_bank" value="GDB"/><img src="/order/images/GDB_OUT.gif" border="0"/></td>
			                 </tr>
			                 <tr>
			                   <td><input type="radio" name="pay_bank" value="CITIC"  /><img src="/order/images/CITIC_OUT.gif" border="0"/></td>
			                   <td><input type="radio" name="pay_bank" value="CEBBANK"  /><img src="/order/images/CEBBANK_OUT.gif" border="0"/></td>
			                   <td><input type="radio" name="pay_bank" value="CIB" /><img src="/order/images/CIB_OUT.gif" border="0"/></td>
			                   <td><input type="radio" name="pay_bank" value="SDB"  /><img src="/order/images/SDB_OUT.gif" border="0"/></td>
			                 </tr>
			                 <tr>
			                   <td><input type="radio" name="pay_bank" value="CMBC"  /><img src="/order/images/CMBC_OUT.gif" border="0"/></td>
			                   <td><input type="radio" name="pay_bank" value="HZCBB2C"  /><img src="/order/images/HZCBB2C_OUT.gif" border="0"/></td>
			                   <td><input type="radio" name="pay_bank" value="SHBANK" /><img src="/order/images/SHBANK_OUT.gif" border="0"/></td>
			                   <td><input type="radio" name="pay_bank" value="NBBANK" /><img src="/order/images/NBBANK_OUT.gif" border="0"/></td>
			                 </tr>
			                 <tr>
			                   <td><input type="radio" name="pay_bank" value="SPABANK" /><img src="/order/images/SPABANK_OUT.gif" border="0"/></td>
			                   <td><input type="radio" name="pay_bank" value="BJRCB" /><img src="/order/images/BJRCB_OUT.gif" border="0"/></td>
			                   <td><input type="radio" name="pay_bank" value="ICBCBTB" /><img src="/order/images/ICBCBTB_OUT.gif" border="0"/></td>
			                   <td><input type="radio" name="pay_bank" value="CCBBTB" /><img src="/order/images/CCBBTB_OUT.gif" border="0"/></td>
			                 </tr>
			                 <tr>
			                   <td><input type="radio" name="pay_bank" value="SPDBB2B"/><img src="/order/images/SPDBB2B_OUT.gif" border="0"/></td>
			                   <td><input type="radio" name="pay_bank" value="ABCBTB"/><img src="/order/images/ABCBTB_OUT.gif" border="0"/></td>
							   <td><input type="radio" name="pay_bank" value="fdb101"/><img src="/order/images/fdb101_OUT.gif" border="0" /></td>
							   <td><input type="radio" name="pay_bank" value="PSBC-DEBIT" /><img src="/order/images/PSBC-DEBIT_OUT.gif" border="0" /></td>
			                 </tr>
			               </table>
						
						<div class="firefox"></div>
					</div>
		    <div class="text_center"><input name="确定" type="button" value="确定" onclick="paySubmit()"/></div>
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
						<c:when test="${pay.pay_type=='default'}">
							self.parent.callBackPay('储值卡余额支付');
						</c:when>
						<c:otherwise>
							<c:choose>
								<c:when test="${pay.pay_type=='directPay'}">
									self.parent.callBackPay('<img src="/order/images/alipay_1.gif" border="0"/>');
								</c:when>
								<c:otherwise>
									self.parent.callBackPay('<img src="/order/images/${pay.defaultbank }_OUT.gif" border="0"/>')
								</c:otherwise>
							</c:choose>
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