<%@ page contentType="text/html; charset=UTF-8" language="java"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3c.org/TR/1999/REC-html401-19991224/loose.dtd">
<HTML xmlns="http://www.w3.org/1999/xhtml">
<HEAD>
<TITLE>登录–NPS</TITLE>
<LINK href="/css/cslogin.css" type=text/css rel=stylesheet>
<script type="text/javascript">
    function getCookieValue(cookieName)
    {
        var cookieString = document.cookie;
        var start = cookieString.indexOf(cookieName + '=');
        if (start == -1) return null;
        start += cookieName.length + 1;
        var end = cookieString.indexOf(';', start);
        if (end == -1) return unescape(cookieString.substring(start));
        return unescape(cookieString.substring(start, end));
    }

    function setCookies()
    {
        var expires = new Date();
        expires.setTime(expires.getTime() + 3 * 30 * 24 * 60 * 60 * 1000);
        document.cookie = 'username=' + escape( document.formLogin.user.value) + ';expires=' + expires.toGMTString();
    }

    function getCookies()
    {
        var username = getCookieValue("username");
        if( username && username.length >0 )
        {
            document.formLogin.user.value = username;
            document.formLogin.password.focus();
        }
        else
        {
            document.formLogin.user.focus();
        }
    }

    function f_login()
    {
        var frm = document.formLogin;
        if( frm.user.value =='' )
        {
            alert('请输入用户名');
            frm.user.focus();
            return false;
        }
        if( frm.password.value == '')
        {
            alert('请输入密码');
            frm.password.focus();
            return false;
        }

        if(frm.save.checked) setCookies();
        frm.submit();
    }
</script>
</HEAD>
<BODY onload="getCookies();">
<br><br><br><br><br>
<FORM name=formLogin action="/session/login.jsp" method=post>
<DIV class=zuce_m>
<DIV class=zc>
<DIV class=zc_t style="BACKGROUND: url(/images/zc_4.gif) no-repeat left 50%;"></DIV>
<DIV class=zc_1></DIV>
<DIV class=zc_2>
<DIV class=zc_m1>
<UL>
  <LI id=clueMsg style="PADDING-LEFT: 50px; COLOR: red"></LI>
  <LI class=yfm>用户名：<INPUT type="text" name=user tabindex=1></LI>
  <LI class=mm>密　码：<INPUT type=password name=password tabindex=2></LI>
  <LI class=mm>语　言：
      <SELECT name="language">
          <option value="CHINA">中文</option>
          <option value="ENGLISH">英语</option>
      </SELECT>
  </LI>
  <LI class=jz><INPUT id=save type=checkbox CHECKED value=0 name=save><LABEL for=save>记住我的登录信息</LABEL> </LI>
  <LI class=qt>如果您是在网吧等公用电脑上使用请不要选择此项</LI>
  <LI class=dl><INPUT type=image src="/images/dl.gif" onclick="javascript:f_login();"> </LI></UL></DIV></DIV>
<DIV class=zc_3></DIV></DIV></DIV>
</FORM>
<DIV class=b_t></DIV>

<div style="margin:auto; text-align:center;">
<div class="footer">
   <span>&copy;2010 - <a href="http://www.jwebstar.com" target="_blank">JWebStar.com</a>. All rights reserved.</span>
</div>
</div>

</BODY>
</HTML>