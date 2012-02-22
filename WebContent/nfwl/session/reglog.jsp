<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>想购网-家产品配送专家|健康食品管家</title>
<link href="ithinkgo.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="correctPNG.js"></script>
<script type="text/javascript" src="/nfwl/js/inputcheck.js"></script>

<script type='text/javascript' src='/dwr/interface/AjaxUtils.js'></script>    
<script type='text/javascript' src='/dwr/engine.js'></script>   
<script type='text/javascript' src='/dwr/util.js'></script>   

<script type="text/javascript"> 
function loadimage_login(){ 
document.getElementById("randImage_login").src = "/nfwl/tools/image.jsp?"+Math.random(); 
} 
function loadimage_reg(){ 
  document.getElementById("randImage_reg").src = "/nfwl/tools/image.jsp?"+Math.random(); 
  } 
  
  function addOptionfp(fpid,fpname){
    var objselect = document.getElementById("itg_fixedpoint");
    
    var oOption = document.createElement("option");
    oOption.text= fpname;
    oOption.value= fpid;
    objselect.add(oOption); 

  }
  
  function f_save(){
   // debugger;
    var doc = document.regform;
    //doc.action = "/nfwl/session/usersave.jsp";
    //doc.submit();
    if(!CheckIsEnCode('document.regform','useraccount')){
      alert("请输入正确的用户名（只能包含英文和数字）");
      return false;
    }
    if(!CheckIsNull('document.regform','userpass')){
      alert("请输入密码");
      return false;
    }
    
    if(doc.userpass.value!=doc.userpass1.value){
      alert("请确保密码和确认密码相同");
      return false;
    }
    
    doc.action = "/nfwl/session/usersave2.jsp";
    doc.submit();
   
    
  }
  

  function pageCheckNo(no){
    AjaxUtils.checkNo(no,function (result){
     // alert("["+result+"]");
      if(result==''){
        //alert("[可以注册]");
        var accounttip = document.getElementById("id_account");
        if(accounttip!=null){
          accounttip.className="er";
          accounttip.innerHTML="恭喜你，该用户名可以正常试用";
        }
        
        
      }else{
        alert("该用户名已经存在，请更换");
        var accounttip = document.getElementById("id_account");
        if(accounttip!=null){
          accounttip.className="t";
          accounttip.innerHTML="注册后不可修改";
        }
        return false;
      }
    });
  }
  
  
</script>
</head>

<body onload="dwr.engine.setActiveReverseAjax(true);">
<!--top-->
<!--#include virtual="/common/div_top.inc"-->
<!--top_end-->

<!--menu-->
<!--#include virtual="/common/div_menu.inc"-->
<!--menu_end-->

<!--search-->
<!--#include virtual="/common/div_hotsearch.inc"-->
<!--search_end-->

<!--reglog-->
<div class="reglog">

    <form name="regform">
    <div class="left" style="border-right:1px #ccc solid; width:50%; padding-left:50px;">
    <ul><img src="images/zc_01.png" /> </ul>
    <ul><li class="ti">用户名：</li><li class="con"><input name="useraccount" type="text" class="input itop" onBlur="pageCheckNo(this.value)" /></li><li id="id_account" class="t">注册后不可修改</li></ul>
    <ul><li class="ti">密码：</li><li class="con"><input name="userpass" type="password" class="input itop" /></li></ul>
    <ul><li class="ti">确认密码：</li><li class="con"><input name="userpass1" type="password" class="input itop" /></li></ul>
    <ul><li class="ti">昵称：</li><li class="con"><input name="username" type="text" class="input itop" /></li><li class="er"></li></ul>
    <ul><li class="ti">定点单位：</li>
      <li class="con"> 
        <select name="itg_fixedpoint" id="itg_fixedpoint">
          <option value=""></option>
          </select>
          <script type="text/javascript" src="/nfwl/tools/getfixedpointoption.jsp"></script>
      </li><li class="er"></li>
      
      </ul>
<!-- 
    <ul><li class="ti">性别：</li><li class="con"><input name="sex" type="radio" value="0" />男&nbsp;&nbsp;<input name="sex" type="radio" value="1" />女</li></ul>
 -->
    <ul><li class="ti">验证码：</li><li class="con"><input name="" type="text" class="input itop" size="5" />&nbsp;
    <img alt="code..." name="randImage_reg" id="randImage_reg" src="/nfwl/tools/image.jsp" width="60" height="20" border="1" align="absmiddle">
    <a href="javascript:loadimage_reg();"><font class=pt95>看不清点我</font></a>
    </li></ul>
    <ul><li class="ti">&nbsp;</li><li class="con"><input name="" type="checkbox" value="" />同意服务协议</li></ul> 
    <ul><li class="ti">&nbsp;</li><li class="con"><input onclick="f_save();" name="" type="image" src="images/submit_07.png" /></li></ul>
    </div>
    </form>
    
     <form action="my_ithinkgo.html">
     <div class="right" style=" width:40%;">
    <ul><img src="images/dl_01.png" /></ul>
    <ul><li class="ti">邮箱：</li><li class="con"><input name="" type="text" class="input itop" /></li></ul>
    <ul><li class="ti">密码：</li><li class="con"><input name="" type="password" class="input itop" /></li></ul>
    <ul><li class="ti">验证码：</li><li class="con"><input name="" type="text" class="input itop" size="5" />&nbsp;
    <img alt="code..." name="randImage_login" id="randImage_login" src="/nfwl/tools/image.jsp" width="60" height="20" border="1" align="absmiddle">
    <a href="javascript:loadimage_login();"><font class=pt95>看不清点我</font></a>
    
    </li></ul>
    <ul style="padding-top:10px;"><li class="ti">&nbsp;</li><li class="con"><input name="" type="image" src="images/submit_08.png" /></li></ul>
    <ul><li class="ti">&nbsp;</li><li class="con"><img src="images/ico_13.png" /><a href="passw.html">我忘记密码了</a></li></ul>
    </div>
    </form>
        
    <div class="firefox"></div>
    
</div>
<!--reglog_end-->


<!--down-->
<!--#include virtual="/common/div_bottom.inc"  -->
<!--down_end-->

</body>
</html>
