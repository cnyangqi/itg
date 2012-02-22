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
<title>用户管理</title>
  <link type="text/css" rel="stylesheet" href="/jquery/jquery-easyui-1.2.3/themes/default/easyui.css">
  <link type="text/css" rel="stylesheet" href="/jquery/jquery-easyui-1.2.3/themes/icon.css">
  <script type="text/javascript" src="/jquery/jquery-easyui-1.2.3/jquery-1.4.4.min.js"></script>
  <script type="text/javascript" src="/jquery/jquery-easyui-1.2.3/jquery.easyui.min.js"></script>
  <script type="text/javascript" src="/jquery/jquery.validate.js"></script>
  <script type="text/javascript" src="/jquery/jquery.validate.messages_cn.js"></script>
  <script type="text/javascript" src="/nfwl/js/userManager.js"></script>
</head>
<body>
<input type="hidden" id="user_utype" name="user_utype" value="<%=usermodel.getUtype() %>" />
  <table id="user_table">
    <thead>
      <tr>
        <th field="name" >姓名</th>
        <th field="account" >用户名</th>
        <th field="telephone" >电话</th>
        <th field="mobile" >手机</th>
        <th field="utype" >用户类型</th>
      </tr>
    </thead>
  </table>

  <div id="user-window" title="用户编辑窗口" style="width=400">
    <div style="padding:20px 20px 40px 80px;">
      <form id="inputFrm" name="inputFrm" method="post" action="">
      <input type="hidden" name="id" />
        <table>
          <tr>
            <td>姓名：</td>
            <td><input name="name"></input><span style="color:red"></td>
          </tr>
          <tr>
            <td>用户名：</td>
            <td><input id="account" name="account" onblur="verifyAccount(this.value)"></input><span id="span_account" style="color:red"></td>
          </tr>
          <tr>
            <td>工号：</td>
            <td><input id="worknum" name="worknum"></input><span style="color:red"></td>
          </tr>
          <tr>
            <td>电话：</td>
            <td><input name="telephone"></input></td>
          </tr>
          <tr>
            <td>手机：</td>
            <td><input name="mobile"></input></td>
          </tr>
          <tr>
            <td>定点单位：</td>
            <td><input class="easyui-combobox" 
          id="itg_fixedpoint"
          name="itg_fixedpoint"
          <%if(user.IsSysAdmin()){ %>
          url="/fixedpointcontroller/getAll/" 
          <%}else { %>
          url="/fixedpointcontroller/getAll/<%=usermodel.getItg_fixedpoint() %>"
          <%} %>
          valueField="fp_id" 
          selected ="selected"
          textField="fp_name" 
          panelHeight="auto" /></td>
          </tr>
          
          
          <tr>
            <td>电子邮件：</td>
            <td><input name="email"></input><span style="color:red"></td>
          </tr>
          <tr>
            <td>用户类型：</td>
            <td>
            <select name="utype">
            <option value="">普通用户</option>
            
            <%if(user.IsSysAdmin()){ %>
             <option value="5">定点单位管理员</option>
            <%}%>
            
            </select>
            </td>
          </tr>
         </table>
      </form>
    </div>
    <div style="text-align:center;padding:5px;">
      <a  onclick="javascript:saveUser();" id="btn-save" icon="icon-save">保存</a>
      <a  onclick="javascript:closeWindow();" id="btn-cancel" icon="icon-cancel">取消</a>
    </div>
  </div>
</body>
</html>