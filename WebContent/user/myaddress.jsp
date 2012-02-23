<%@ page language="java" errorPage="/error.jsp" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<%@ taglib prefix="my" uri="http://www.ithinkgo.com/functions"%>
<%@ include file="/include/header.jsp"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<title>我的订单</title>
		<link href="/ithinkgo1.css" rel="stylesheet" type="text/css" />
		<link href="/user/error.css" rel="stylesheet" type="text/css" />
		<script type="text/javascript" src="/jquery/jquery-1.6.js"></script>
		<script type="text/javascript" src="/jquery/jquery.validate.js"></script>
		<script type="text/javascript" src="/user/myvalidate.js"></script>
		<script type="text/javascript" src="/user/myaddress.js"></script> 
	</head>
	<body>

		<!--top-->
		<jsp:include page="/user/common/div_top.inc" />
		<!--top_end-->

		<!--menu-->
		<jsp:include page="/user/common/div_menu.inc" />
		<!--menu_end-->

		<!--search-->
		<jsp:include page="/user/common/div_hotsearch.inc" />
		<!--search_end-->
		<form name="tempform" id="tempform" action="/user/loadaddress.do"
			method="post">
			<input type="hidden" name="cmd" value="" />
			<input type="hidden" name="id" value="" />
			<input type="hidden" name="token" value="${token }" />
		</form>
		<!--my-->
		<div class="my_ithinkgo">
			<c:set var="zones" value="${my:getZone()}"></c:set>
			<c:set var="list" value="${my:getUserAddress(user.id)}"></c:set>
			<!--user_munu-->
			<jsp:include page="/user/common/user_menu.inc" />
			<!--user_munu_end-->

			<div class="content">
				<div class="menu2">
					<ul>
						<li>
							收货地址管理
						</li>
					</ul>
				</div>
				<form name="addressForm" id="addressForm" action="/user/address.do" method="post">
					<input type="hidden" name="token" value="${token }" />
					<c:choose>
						<c:when test="${empty addressForm}">
							<input type="hidden" name="cmd" value="insert" />
						</c:when>
						<c:otherwise>
							<input type="hidden" name="cmd" value="modify" />
						</c:otherwise>
					</c:choose>
					<input type="hidden" name="adr_id" value="${addressForm.adr_id }" />
					<div class="dzgl">
						<ul>
							<li class="con">
								最多保存5个有效地址
							</li>
						</ul>
						<ul>
							<table width="100%" border="0" cellpadding="0" cellspacing="0"
								class="table">
								<tr class="ti">
									<td>
										收货人
									</td>
									<td>
										所在地区
									</td>
									<td>
										详细地址
									</td>
									<td>
										电话/手机
									</td>
									<td class="nobr">
										操作
									</td>
								</tr>
								<c:choose>
									<c:when test="${empty list}">
										<tr>
											<td colspan="5">
												没有符合条件的数据!
											</td>
										</tr>
									</c:when>
									<c:otherwise>
										<c:forEach items="${list}" var="bean">
											<tr>
												<td>
													${bean.adr_name }
													<c:if test="${user.adrid==bean.adr_id }">
					 									<font color="red">(默认)</font>
					 								</c:if>
												</td>
												<td>
													<c:forEach items="${zones}" var="zone">
														<c:if test="${bean.adr_zone==zone.id }">
					 			${zone.name }
					 		</c:if>
													</c:forEach>
												</td>
												<td>
													${bean.adr_detail }
												</td>
												<td>
													${bean.adr_subnum}-${bean.adr_telephone }/${bean.adr_mobile
													}
												</td>
												<td>
													<a href="javascript:view('${bean.adr_id }')">[修改]</a>&nbsp;&nbsp;
													<a href="javascript:del('${bean.adr_id }')">[删除]</a>&nbsp;&nbsp;
													<c:if test="${user.adrid!=bean.adr_id }">
														<a href="javascript:setdefault('${bean.adr_id }')">[设为默认]</a>
													</c:if>
												</td>
											</tr>
										</c:forEach>
									</c:otherwise>
								</c:choose>
							</table>
						</ul>
						<ul>
							<li class="con font_bold">
								<c:choose>
									<c:when test="${empty addressForm}">
			新增地址
		</c:when>
									<c:otherwise>
			修改地址	
		</c:otherwise>
								</c:choose>
							</li>
						</ul>
						<ul>
							<li class="ti">
								收货人：
							</li>
							<li class="con">
								<input name="adr_name" type="text" class="input itop"
									value="${addressForm.adr_name }" />
								<font color="red"><html:errors property="adr_name"/></font>
							</li>
							<font color="red">*</font>
						</ul>
						<ul>
							<li class="ti">
								所在地区：
							</li>
							<li class="con">
								<select name="adr_zone" class="input itop">
									<c:forEach items="${zones}" var="zone">
										<option value="${zone.id }"
											<c:if test="${addressForm.adr_zone==zone.id }">
	 				selected="selected"
	 			</c:if>>
											${zone.name }
										</option>
									</c:forEach>
								</select>
							</li>
							<font color="red">*</font>
						</ul>
						<ul>
							<li class="ti">
								详细地址：
							</li>
							<li class="con">
								<input name="adr_detail" type="text" class="input itop"
									size="50" value="${addressForm.adr_detail }" />
							</li>
							<font color="red">*</font>
						</ul>
						<ul>
							<li class="ti">
								邮政编码：
							</li>
							<li class="con">
								<input name="adr_postcode" type="text" class="input itop"
									size="8" value="${addressForm.adr_postcode }" />
							</li>
						</ul>
						<ul>
							<li class="ti">
								手机号码：
							</li>
							<li class="con">
								<input name="adr_mobile" type="text" class="input itop"
									value="${addressForm.adr_mobile }" />
							</li>
							<font color="red">*</font>
						</ul>
						<ul>
							<li class="ti">
								固定电话：
							</li>
							<li class="con">
								<input name="adr_areacode" type="text" class="input" size="3"
									value="${addressForm.adr_areacode }" />
								-
								<input name="adr_telephone" type="text" class="input " size="10"
									value="${addressForm.adr_telephone }" />
								-
								<input name="adr_subnum" type="text" class="input" size="3"
									value="${addressForm.adr_subnum }" />
							</li>
							<li class="t">
								区号-号码-分机
							</li>
						</ul>
						<ul>
							<li class="ti">
								电子邮箱：
							</li>
							<li class="con">
								<input name="adr_email" type="text" class="input itop"
									value="${addressForm.adr_email }" />
							</li>
						</ul>
						<ul>
							<li class="ti">
								&nbsp;
							</li>
							<li class="con">
								<input name="" type="submit" value="保存" class="submit" />
							</li>
						</ul>
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
		<jsp:include page="/user/common/div_about.inc" />
		<!--ervice_end-->

		<!--link-->
		<jsp:include page="/user/common/div_links.inc" />
		<!--link_end-->

		<!--down-->
		<jsp:include page="/user/common/div_bottom.inc" />
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
