<%@ page language="java" errorPage="/error.jsp" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<script>
function to_page(page) 
{
   if(!isNumeric(page))
   {
   	     alert("不是有效的数字");
   		return;
   }
  //var temp_count_page = document.getElementById("temp_page_count").value;
  var int_page = parseInt(page);
  var int_temp_count_page = ${PAGELIST.pageCount};//parseInt(temp_count_page);
  if (int_page<=0 || int_page>int_temp_count_page){
  	return;
  }
  var doc = document.search_frm;
  doc.pageCur.value=page;
  doc.submit();
}
// 验证是否 数字
function isNumeric(strNumber) {
    return (strNumber.search(/^(-|\+)?\d+(\.\d+)?$/) != -1);
}
</script>

<table class="page">
<tr>
	<td align="left">
		<a href="javascript:to_page('1')">首页</a>
	        <c:choose>
				<c:when test="${PAGELIST.pageCur <= 1}">
					前页
				</c:when>
				<c:otherwise>
					<a href="javascript:to_page('${PAGELIST.pageCur-1}')">前页</a>  
				</c:otherwise>
			</c:choose>
	        <c:choose>
				<c:when test="${PAGELIST.pageCur >= PAGELIST.pageCount}">
					后页
				</c:when>
				<c:otherwise>
					<a href="javascript:to_page('${PAGELIST.pageCur+1}')">后页</a>
				</c:otherwise>
			</c:choose>
	       <a href="javascript:to_page('${PAGELIST.pageCount}')">尾页</a>
	       每页${PAGELIST.pageSize}条
	</td>
	<td align="right">
		 第${PAGELIST.pageCur }页/共${PAGELIST.size }条记录
	</td>
</tr>
</table>

      
   