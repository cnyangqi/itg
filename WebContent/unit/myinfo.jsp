<%@ page contentType="text/html; charset=UTF-8" language="java" errorPage="/error.jsp" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.Config" %>
<%@ include file="/include/header.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_myinfo",user.GetLocale(), Config.RES_CLASSLOADER);    
%>
<html>
<head>
<title><%=bundle.getString("MYINFO_HTMLTITLE")%></title>
   <LINK href = "/css/style.css" rel = stylesheet type="text/css">
   <script type="text/javascript"  src="/jscript/global.js"></script>
</head>
<script language="javaScript">
    function changeinfo()
    {
        if(frm_view.name.value.trim()=='')
        {
            alert("<%=bundle.getString("MYINFO_ALERT_NAME_IS_NULL")%>")
            frm_view.name.focus();
            return false;
        }
        frm_view.submit();
    }
</script>
<body leftmargin=3 topmargin=0>
  <table width="100%" border="0" valign=top align="center" cellpadding="0" cellspacing="0" class="PositionBar">
    <tr>
       <td height=30>&nbsp;&nbsp;
          <input type="button" name="btn_reset" value="<%=bundle.getString("MYINFO_BUTTON_SAVE")%>" class="Button" onClick="changeinfo();">
       </td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
    <form name="frm_view" action="myinfosave.jsp" method="post" encType="multipart/form-data">
    <input type="hidden" name="action" value="0">
    <tr  height=30>
      <td width=150 align="right" ><%=bundle.getString("MYINFO_NAME")%></td>
      <td>
          <input type="text" name="name" maxlength="25"  value="<%= user.GetName()==null?"":user.GetName() %>">
      </td>
    </tr>
    <tr  height=30>
      <td width=150 align="right" ><%=bundle.getString("MYINFO_TEL")%></td>
      <td>
          <input type="text" name="telephone" maxlength="25"  value="<%= user.GetTelephone()==null?"":user.GetTelephone() %>">
      </td>
    </tr>
    <tr height=30>
      <td align="right" ><%=bundle.getString("MYINFO_EMAIL")%></td>
      <td >
          <input type="text" name="email" maxlength="50"  value="<%= user.GetEmail()==null?"":user.GetEmail() %>">
      </td>
    </tr>
    <tr height=30>
      <td align="right" ><%=bundle.getString("MYINFO_MOBILE")%></td>
      <td >
          <input type="text" name="mobile" maxlength="25"  value="<%= user.GetMobile()==null?"":user.GetMobile() %>">
      </td>
    </tr>
    <tr  height=30>
      <td align="right" ><%=bundle.getString("MYINFO_FAX")%></td>
      <td>
          <input type="text" name="fax" maxlength="25"  value="<%= user.GetFax()==null?"":user.GetFax() %>">
      </td>
    </tr>
    <tr  height=30>
      <td align="right" ><%=bundle.getString("MYINFO_FACE")%></td>
      <td>
          <input type="file" name="myface">
      </td>
    </tr>
    </form>
  </table>
</body>
</html>