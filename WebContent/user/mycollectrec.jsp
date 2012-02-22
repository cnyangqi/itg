<%@ page language="java" errorPage="/error.jsp" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
<%@ include file = "/include/header.jsp" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>我的收藏</title>
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
    <li>我的收藏</li>
    </ul>    
    </div>
    <form name="search_frm" action="/user/collectrec.do" method="post">
    <input type="hidden" name="cmd" value="search"/>
    <input type="hidden" name="pageCur" value="${PAGELIST.pageCur }"/>
    <div class="zlxg">
      <ul>
        <table width="100%" border="0" cellpadding="0" cellspacing="0" class="table">
        <tr class="ti">
          <td>商品名称</td>
          <td>收藏时间</td>
          <td>图片</td>
          <td>想购价</td>
         
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
			          <td><a href="${bean.url_gen }" target="_blank">${bean.prd_name }</a></td>
			          <td>${bean.col_time }</td>
			          <td><img src="${bean.pic_url }" height="60" width="60"/></td>
			          <td>${bean.prd_localprice }</td>
			          <td class="nobr"><a href="/user/collectrec.do?cmd=delete&id=${bean.col_id }&cur_page=${cur_page }">[删除]</a></td>
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
