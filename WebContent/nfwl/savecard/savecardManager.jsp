<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="controllers.UserController"%>
<%@page import="models.UserModels"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ include file = "/include/header.jsp" %>

<% UserModels usermodel = UserController.getUserById(user.getId());  %>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 
<title>储值卡管理</title>
  <link type="text/css" rel="stylesheet" href="/jquery/jquery-easyui-1.2.3/themes/default/easyui.css">
  <link type="text/css" rel="stylesheet" href="/jquery/jquery-easyui-1.2.3/themes/icon.css">
  <link type="text/css" rel="stylesheet" href="/jquery/jquery-easyui-1.2.3/demo/jquery.ui.all.css">
  <script type="text/javascript" src="/jquery/jquery-easyui-1.2.3/jquery-1.4.4.min.js"></script>
  <script type="text/javascript" src="/jquery/jquery-easyui-1.2.3/jquery.easyui.min.js"></script>
  <script type="text/javascript" src="/jquery/jquery.validate.js"></script>
  <script type="text/javascript" src="/jquery/jquery.validate.messages_cn.js"></script>
  <script type="text/javascript" src="/jquery/jquery.ui.datepicker.js"></script>
  <script type="text/javascript" src="/nfwl/js/savecardManager.js"></script>
  <script type="text/javascript" src="/jscript/calendar.js"></script>
</head>
<body>
<input type="hidden" id="user_utype" name="user_utype" value="<%=usermodel.getUtype() %>" />
  <table id="savecard_table">
   
  </table>
 <div id="newcavecard-window" title="用户编辑窗口" style="width=400">
    <div style="padding:20px 20px 40px 80px;">
      <form id="inputFrm" name="inputFrm" method="post" action="">
      <input type="hidden" name="id" />
        <table>
          <tr>
            <td>创建数量：</td>
            <td><input id="num" name="num"></input><span style="color:red"></td>
          </tr>
          <tr>
            <td>储值金额：</td>
            <td><input id="money" name="money" ></input><span id="span_money" style="color:red"></td>
          </tr>
         
         </table>
      </form>
    </div>
    <div style="text-align:center;padding:5px;">
      <a  onclick="javascript:createSaveCard();" id="btn-save"  name="btn-save" icon="icon-save">save</a>
      <a  onclick="javascript:closeWindow();" id="btn-cancel" icon="icon-cancel">取消</a>
    </div>
  </div>
</body>
</html>