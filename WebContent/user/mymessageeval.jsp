<%@ page language="java" errorPage="/error.jsp" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
<%@ include file = "/include/header.jsp" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>我的留言/评价</title>
<link href="/ithinkgo.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="/jquery/jquery-1.6.js"></script>
</head>
<body>
<form name="search_frm" action="/user/messageeval.do" method="post">
<input type="hidden" name="cmd" value="search"/>
<input type="hidden" name="pageCur" value="${PAGELIST.pageCur }"/>
<input type="hidden" name="me_type" value="${PAGELIST.parameter.me_type }"/>
</form>
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
     <c:choose>
		<c:when test="${PAGELIST.parameter.me_type=='1'}">
			<li>商品留言</li>
    		<li><a href="/user/messageeval.do?cmd=search&me_type=2">评价反馈</a></li>
		</c:when>
		<c:otherwise>
			<li><a href="/user/messageeval.do?cmd=search&me_type=1">商品留言</a></li>
    		<li>评价反馈</li>
		</c:otherwise>
	</c:choose>
    </ul>    
    </div>
    <form>
    <div class="zlxg">
    <ul>
	    <c:choose>
			<c:when test="${me_type=='1'}">
				 <table width="100%" border="0" cellpadding="0" cellspacing="0" class="table">
			        <tr class="ti">
			          <td>状态</td>
			          <td>商品名称</td>
			          <td>内容</td>
			          <td>留言时间</td>
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
						          <td>xxxxxxx</td>
						          <td><a href="#">${bean.od_prdname }</a></td>
						          <td>${bean.me_content }</td>
						          <td>${bean.me_time }</td>
						          <td class="nobr">xxxxxxxxxx</td>
						          </tr>
						      
								</c:forEach>
							</c:otherwise>
						</c:choose>   
			       </table>
			</c:when>
			<c:otherwise>
				<table width="100%" border="0" cellpadding="0" cellspacing="0" class="table">
			        <tr class="ti">
			          <td>商品名称</td>
			          <td>评价等级</td>
			          <td>商品与描述相符</td>
			          <td>卖家服态度</td>
			          <td>卖家发货速度</td>
			          <td>物流公司服务</td>
			          <td class="nobr">详细信息</td>
			          </tr>
			        <c:choose>
						<c:when test="${empty PAGELIST.list}">
							<tr>
								<td colspan="7">没有符合条件的数据!</td>
							</tr>
							</c:when>
							<c:otherwise>
								<c:forEach items="${PAGELIST.list}" var="bean">
								  <tr>
							          <td><a href="#">${bean.od_prdname }</a></td>
							          <td>${bean.me_level }</td>
							          <td>${bean.me_desclevel }</td>
							          <td>${bean.me_attitudelevel }</td>
							          <td>${bean.me_speedlevel }</td>
							          <td>${bean.me_deliverylevel }</td>
							          <td class="nobr">${bean.me_content}</td>
							          </tr>
								</c:forEach>
							</c:otherwise>
						</c:choose>  
			       
			      </table>
			</c:otherwise>
		</c:choose>
     
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