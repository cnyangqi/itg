<%@ page language="java" errorPage="/error.jsp" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
<%@ include file = "/include/header.jsp" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>订单详细信息</title>
<link href="/ithinkgo.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="/jquery/jquery-1.6.js"></script>
<link rel="stylesheet" href="/jquery/thickbox/thickbox.css" type="text/css" media="screen" />
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
    <div class="wddd">
    <ul>
   </ul>
    <ul>
      <table width="100%" border="0" cellpadding="0" cellspacing="0" class="table">
        <tr class="ti">
          <td>商品名称</td>
          <td>商品价格</td>
          <td>数量</td>
          <td class="nobr">操作</td>
        </tr>
          <c:choose>
				<c:when test="${empty list}">
				<tr>
					<td colspan="4">没有符合条件的数据!</td>
				</tr>
				</c:when>
				<c:otherwise>
					<c:forEach items="${list}" var="bean">
					<tr>
			          <td><a href="${bean.url_gen}" target="_blank">${bean.od_prdname }</a></td>
			          <td>${bean.od_price }</td>
			          <td>${bean.od_num }</td>
			          <td class="nobr"><a href="/user/ordereval.do?TB_iframe=true&height=455&width=350&cmd=orderEvalInit&od_id=${bean.od_id }" class="thickbox">评价</a></td>
			        </tr>
					</c:forEach>
				</c:otherwise>
			</c:choose>    
      </table>
    </ul>
    <ul class="gopage"></ul>
    </div>
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