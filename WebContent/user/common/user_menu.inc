<%@ page language="java" errorPage="/error.jsp" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
﻿<div class="menu">
    <ul>
    <li><a href="/user/loaduser.do?cmd=acctountInfo">帐户信息</a></li>
    <li><a href="/user/loaduser.do?cmd=modfiy">资料修改</a></li>
    <li><a href="/user/load.do?cmd=changepassword">密码修改</a></li>
    <li><a href="/user/order.do?cmd=search">我的订单</a></li>
    <li><a href="/user/collectrec.do?cmd=search">我的收藏</a></li>
    <li><a href="/user/loadaddress.do?cmd=view">收货地址管理</a></li>
    <li><a href="/user/load.do?cmd=czkrecharge">充值中心</a></li>
    <li><a href="/user/pointrec.do?cmd=search">积分记录</a></li>
    <li><a href="/user/messageeval.do?cmd=search&me_type=1">我的留言/评价</a></li>
    <li><a href="/user/suggest.do?cmd=search">投诉/建议</a></li>
    <c:if test="${user.type==6}"><li><a href="/user/fixedpoint.do?cmd=search">定点用户管理</a></li></c:if>
    <li style="border:0px;"><a href="/nfwl/session/logout.jsp">退出</a></li>
    </ul>       
</div>