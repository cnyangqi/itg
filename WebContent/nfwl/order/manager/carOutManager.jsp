<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 
<meta http-equiv="Content-Language" content="zh-CN" /> 
<title>车辆管理</title>
  <link type="text/css" rel="stylesheet" href="/jquery/jquery-easyui-1.2.3/themes/default/easyui.css">
  <link type="text/css" rel="stylesheet" href="/jquery/jquery-easyui-1.2.3/themes/icon.css">
  <script type="text/javascript" src="/jquery/jquery-easyui-1.2.3/jquery-1.4.4.min.js"></script>
  <script type="text/javascript" src="/jquery/jquery-easyui-1.2.3/jquery.easyui.min.js"></script>
  <script type="text/javascript" src="/nfwl/js/carOutManager.js"></script>
</head>
<body>
  <table id="carout_table">
    <thead>
      <tr>
      
        <th field="or_status" >状态</th>
        <th field="or_userid" >客户</th>
        <th field="or_money" >金额</th>
        <th field="or_point" >积分</th>
        <th field="or_telephone" >电话</th>
        <th field="or_mobile" >手机</th>
      </tr>
    </thead>
  </table>
  
  <div id="xxd-window" title="信息点窗口" style="width:800px;height:600px;">
    <div style="padding:20px 20px 40px 80px;">
      <form method="post">
        <table>
          <tr>
            <td>状态：</td>
            <td><input name="or_status"></input></td>
          </tr>
          <tr>
            <td>电话：</td>
            <td><input name=or_money></input></td>
          </tr>
          <tr>
            <td>手机：</td>
            <td><input name="or_carrymode"></input></td>
          </tr>
          <tr>
            <td>主营业务：</td>
            <td><input name="or_memo"></input></td>
          </tr>
          <tr>
            <td>地址：</td>
            <td><input name="or_id"></input></td>
          </tr>
        </table>
      </form>
    </div>
    <div style="text-align:center;padding:5px;">
      <a  onclick="javascript:saveOrder();" id="btn-save" icon="icon-save">保存</a>
      <a  onclick="javascript:closeWindow();" id="btn-cancel" icon="icon-cancel">取消</a>
    </div>
  </div>
</body>
</html>