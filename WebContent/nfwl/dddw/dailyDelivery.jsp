<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="controllers.UserController"%>
<%@page import="models.UserModels"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ include file = "/include/header.jsp" %>

<% UserModels usermodel = UserController.getUserById(user.getId());  %>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 
<meta http-equiv="Content-Language" content="zh-CN" /> 
<title>定点单位配送</title>
  <link type="text/css" rel="stylesheet" href="/jquery/jquery-easyui-1.2.3/themes/default/easyui.css">
  <link type="text/css" rel="stylesheet" href="/jquery/jquery-easyui-1.2.3/themes/icon.css">
  <script type="text/javascript" src="/jquery/jquery-easyui-1.2.3/jquery-1.4.4.min.js"></script>
  <script type="text/javascript" src="/jquery/jquery-easyui-1.2.3/jquery.easyui.min.js"></script>
  <script type="text/javascript" src="/jquery/jquery.validate.js"></script>
  <script type="text/javascript" src="/jquery/jquery.validate.messages_cn.js"></script>
  <script type="text/javascript" src="/nfwl/js/dailyDelivery.js"></script>
</head>
<body>
<input type="hidden" id="user_utype" name="user_utype" value="<%=usermodel.getUtype() %>" />
  <table id="fp_table">
    <thead>
      <tr>
        <th field="fp_name" >单位名称</th>
        <th field="fp_code" >单位代码</th>
        <th field="fp_linker" >联系人</th>
        <th field="fp_phone" >联系电话</th>
        <th field="fp_delday" >预定配送日期</th>
      </tr>
    </thead>
  </table>
  <div id="carout-window" title="出车" style="width=400">
    <div style="padding:20px 20px 40px 80px;">
      <form id="inputFrm" name="inputFrm" method="post" action="">
      <input type="hidden" name="id" />
        <table>
          <tr>
            <td>驾驶员：</td>
            <td><input id="driver" name="driver"></input><span style="color:red"></td>
          </tr>
          <tr>
            <td>车牌号：</td>
            <td><input id="carno" name="carno" ></input><span id="span_account" style="color:red"></td>
          </tr>
         
         </table>
      </form>
    </div>
    <div style="text-align:center;padding:5px;">
      <a  onclick="javascript:saveUser();" id="btn-save" icon="icon-save">save</a>
      <a  onclick="javascript:closeWindow();" id="btn-cancel" icon="icon-cancel">取消</a>
    </div>    
</body>
</html>