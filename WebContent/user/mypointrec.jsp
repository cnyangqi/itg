<%@ page language="java" errorPage="/error.jsp" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
<%@ include file = "/include/header.jsp" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>我的积分</title>
<link href="/ithinkgo.css" rel="stylesheet" type="text/css" />

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
    <li>我的积分</li>
    </ul>    
    </div>
    <form name="search_frm" action="/user/pointrec.do" method="post">
    <input type="hidden" name="cmd" value="search"/>
    <input type="hidden" name="pageCur" value="${PAGELIST.pageCur }"/>
    <div  class="zlxg">
    <ul>
      <table width="100%" border="0" cellpadding="0" cellspacing="0" class="table">
         <tr class="ti">
          <td>积分变化</td>
          <td>来源</td>
          <td>时间</td>
          </tr>
          <c:choose>
				<c:when test="${empty PAGELIST.list}">
				<tr>
					<td colspan="4">没有符合条件的数据!</td>
				</tr>
				</c:when>
				<c:otherwise>
					<c:forEach items="${PAGELIST.list}" var="bean">
					<tr>
			          <td>${bean.pr_point }</td>
			          <td>
			          <c:if test="${bean.pr_type==1 }">
			          		购买商品
			          </c:if>
			          </td>
			          <td>${bean.pr_time }</td>
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