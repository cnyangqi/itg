<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.core.Config" %>
<%@ page import="java.sql.*" %>
<%@ page import="nps.util.Utils" %>
<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String fp_id=request.getParameter("fp_id");//如果为null，将再保存时使用序列生成ID号
    if(fp_id!=null) fp_id=fp_id.trim();   

    //if(!(user.IsSysAdmin() || user.IsLocalAdmin()))
    //     throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);
    
    String create_date = nps.util.Utils.FormateDate(new java.util.Date(),"yyyy-MM-dd HH:mm:ss");
    String create_user = user.GetName();
    String create_userid = user.GetUID();

    boolean  bNew=(fp_id==null || fp_id.length()==0);
    //Unit unit = null;
    
    com.nfwl.itg.dddw.ITG_FIXEDPOINT fixedPoint = null;
    Connection con = null;
    
      
     
    if(!bNew)  //需要从数据库中加载信息
    {
        try{   
          con = nps.core.Database.GetDatabase("nps").GetConnection();
          fixedPoint = com.nfwl.itg.dddw.ITG_FIXEDPOINT.get(con,fp_id);
          if(fixedPoint==null)  throw new NpsException(ErrorHelper.SYS_NOUNIT);
          create_date = nps.util.Utils.FormateDate(fixedPoint.getTime(),"yyyy-MM-dd");
          create_user = user.GetUser(fixedPoint.getRegisterid()).GetName();
          create_userid = fixedPoint.getRegisterid();
        }catch(Exception e){
             throw e;
        }finally{
          if(con!=null)try{con.close();}catch(Exception ex){}
        }
    }  //if(!bNew)


%>

<html>
<head>
    <title><%=(bNew?"新建":"编辑")+"定点单位"%></title>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <script type="text/javascript" src="/nfwl/js/inputcheck.js"></script>
    
  <script type="text/javascript" src="/jquery/jquery-1.6.js"></script>
  <script type="text/javascript" src="/jquery/jquery.validate.js"></script>
  <script type="text/javascript" src="/jquery/jquery.validate.messages_cn.js"></script>
  <script type="text/javascript" src="/jquery/jquery-easyui-1.2.3/jquery.easyui.min.js"></script>
  <link type="text/css" rel="stylesheet" href="/jquery/jquery-easyui-1.2.3/themes/default/easyui.css">
  <link type="text/css" rel="stylesheet" href="/jquery/jquery-easyui-1.2.3/thmes/icon.css">
    <LINK href="/css/style.css" rel = stylesheet />

  <script type="text/javascript" >

  function fill_check() {

    if (!CheckIsNull('document.inputFrm', 'fp_name')) {
      alert("请输入单位名称");
      return false;
    }

    if (!CheckIsEnCode('document.inputFrm', 'fp_code')) {
      alert("请输入正确的单位代码（只能包含英文和数字）");
      return false;
    }
    if (!CheckIsEmail('document.inputFrm', 'fp_email')) {
      alert("请输入正确的电子邮件");
      return false;
    }

    return true;
  }

  function save() {
    
  //valid( ) Returns: Boolean 
  //var frm = $("#inputFrm");
  //var frm = document.inputFrm;
  //validate().form()
  //if($("#inputFrm").validate()){

    //$('inputFrm').form();
  //debugger;
    //validate(frm);

  //if($("#inputFrm").validate().form()){
    //alert("true");
  //}else{
    //alert("false");
  //}

    if (!fill_check())
      return;
    document.inputFrm.act.value = 0;
    //document.forms[0].submit();
    document.inputFrm.submit();
  }
  </script>
</head>

<body leftmargin=20 topmargin=0>

<table align=center border="0" class="positionbar" cellpadding="0" cellspacing="0">
  <tr>
    <td>  &nbsp;

      <input type="button" class="button" name="save" value="保存" onClick="save()" >
      <input type="button" class="button" name="close" value="关闭" onclick="javascript:window.close();">
    </td>
  </tr>
</table>

<table align=center  width="80%" cellpadding="0" border="0" cellspacing="0">
<form id="inputFrm" name="inputFrm" method="post" action="dddwSave.jsp">
    <input type="hidden" name="fp_id"  value="<%= fp_id==null?"":fp_id %>">
    <input type="hidden" name="act" value="0">
    <tr height=30>
        <td align=center><font color=red>单位名称</font></td>
        <td>
          <input type="text" id="fp_name" name="fp_name"  maxlength="10" value= "<%= fixedPoint==null?"":fixedPoint.getName() %>">
          <font color="red">*</font> <span style="color:red"></span>
        </td>
    </tr>
     <tr height=30>
    <td align=center>单位代码</td>
    <td >
      <input type="text" id="fp_code" name="fp_code"   maxlength="10"  width=10 value="<%= (fixedPoint==null || fixedPoint.getCode()==null)?"":Utils.TransferToHtmlEntity(fixedPoint.getCode() )%>">
      <span></span></td>
    </tr>
    <tr height=30>
        <td align=center>地址</td>
        <td>
          <input type="text" name="fp_address" maxlength=50  style="width:100%" value= "<%= (fixedPoint==null || fixedPoint.getAddress()==null)?"":Utils.TransferToHtmlEntity(fixedPoint.getAddress()) %>">
        </td>
    </tr>
    <tr height=30>
		<td align=center>联系人</td>
		<td >
			<input type="text" name="fp_linker"  maxlength=50 style="width:200"  value="<%= (fixedPoint==null || fixedPoint.getLinker()==null)?"":Utils.TransferToHtmlEntity(fixedPoint.getLinker()) %>">
	    </td>
    </tr>
    <tr height=30>
		<td align=center>联系电话</td>
		<td >
			<input type="text" name="fp_phone"  maxlength="100" style="width:200" value="<%= (fixedPoint==null || fixedPoint.getPhone()==null)?"":Utils.TransferToHtmlEntity(fixedPoint.getPhone()) %>">
	    </td>
    </tr>
    <tr height=30>
		<td align=center>EMAIL地址</td>
		<td >
			<input type="text" id="fp_email" name="fp_email"   maxlength="100" style="width:200" value="<%= (fixedPoint==null || fixedPoint.getEmail()==null)?"":Utils.TransferToHtmlEntity(fixedPoint.getEmail()) %>">
	   <font color="red">*</font> <span style="color:red"></span></td>
    </tr>
    <tr height=30>
		<td align=center>邮编</td>
		<td >
			<input type="text" name="fp_postcode"   maxlength="100" style="width:200" value="<%= (fixedPoint==null || fixedPoint.getPostcode()==null)?"":Utils.TransferToHtmlEntity(fixedPoint.getPostcode()) %>">
	    </td>
    </tr>
    <tr height=30>
    <td align=center>送货日期：（如每周一三五 填写 135即可）</td>
    <td >
      <input type="text" name="fp_delday"   maxlength="100" style="width:200" value="<%= (fixedPoint==null || fixedPoint.getDelday()==null)?"":Utils.TransferToHtmlEntity(fixedPoint.getDelday()) %>">
      </td>
    </tr>
    <tr height=30>
    <td align=center>是否有效</td>
    <td >
      <select name="fp_valid" >
                <option value="1" <% if(fixedPoint!=null&&1==fixedPoint.getValid()) out.print("selected");%>>是</option>
                <option value="0" <% if(fixedPoint!=null&&0==fixedPoint.getValid()) out.print("selected");%>>否</option>
            </select>
      </td>
    </tr>
     <tr height=30>
		<td align=center>登记人ID</td>
		<td >
            <input type="hidden" name="fp_registerid"   maxlength="100" style="width:200" value="<%=create_userid %>">
            <%=Utils.Null2Empty(create_user)%>
	    </td>
    </tr>
    <tr height=30>
		<td align=center>created</td>
		<td >
            <%=Utils.Null2Empty(create_date)%>
	    </td>
    </tr>
</table>
</form>
</body>
</html>