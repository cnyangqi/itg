<%@ page language="java" errorPage="/error.jsp" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ include file = "/include/header.jsp" %>
<%@ taglib prefix="my" uri="http://www.ithinkgo.com/functions"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>我的订单</title>
<link href="/ithinkgo.css" rel="stylesheet" type="text/css" />
</head>
<script language="javascript">
function state_change(){
	document.search_frm.submit();
}
</script>
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
    <li>我的订单</li>
    </ul>    
    </div>
    <form name="search_frm" action="/user/order.do" method="post">
    <input type="hidden" name="cmd" value="search"/>
    <input type="hidden" name="pageCur" value="${PAGELIST.pageCur }"/>
    <div class="wddd">
    <ul>
    <li class="con"><select name="state" class="input itop" onchange="state_change()">
      <option  value="">交易状态</option>
      <c:forEach items="${PAGELIST.parameter.status}" var="statu">
		<option value="${statu.code }"
		<c:if test="${statu.code==PAGELIST.parameter.state}">
 				selected="selected"
 			</c:if>	
		>${statu.info }</option>
		</c:forEach>
    </select>
    &nbsp;</li></ul>
    <ul>
      <table width="100%" border="0" cellpadding="0" cellspacing="0" class="table">
        <tr class="ti">
          <td>订单号</td>
          <td>下单时间</td>
          <td>订单金额</td>
          <td>状态</td>
          <td class="nobr">操作</td>
        </tr>
          <c:choose>
				<c:when test="${empty PAGELIST.list}">
				<tr>
					<td colspan="5">没有符合条件的数据!</td>
				</tr>
				</c:when>
				<c:otherwise>
					<c:forEach items="${PAGELIST.list}" var="bean">
					<tr>
			          <td>${bean.or_no }</td>
			          <td>${bean.or_time }</td>
			          <td>${bean.or_money }</td>
			          <td>
			          	${my:getOrderStatusInfo1(bean.or_status)}
			          </td>
			          <td class="nobr">&nbsp;<a href="/user/ordermodify.do?cmd=view&or_id=${bean.or_id }" target="_blank">订单详情</a></td>
			        </tr>
					</c:forEach>
				</c:otherwise>
			</c:choose>    
        
      </table>
    </ul>
    <ul class="gopage"><jsp:include page="/user/page.jsp" /></ul>
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