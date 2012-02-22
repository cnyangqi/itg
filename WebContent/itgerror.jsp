<%@ page language="java" errorPage="/error.jsp" contentType="text/html; charset=utf-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
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