<%@ page contentType="text/html; charset=UTF-8" language="java" errorPage="/error.jsp" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.Config" %>
<%@ include file="/include/header.jsp" %>
<%
   request.setCharacterEncoding("UTF-8");    
   String action = request.getParameter("action");
   if(action!=null)  action = action.trim();
   String old_password = request.getParameter("oldpass");
   String new_password = request.getParameter("newpass1");

   ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_changepassword",user.GetLocale(), Config.RES_CLASSLOADER);

   if("0".equalsIgnoreCase(action))
   {
       try
       {
           user.ChangePassword(old_password,new_password);
           out.println(bundle.getString("PASSWORD_SUCCESS"));
           return;
       }
       catch(Exception e)
       {
            throw e;
       }
   }

%>
<html>
<head>
   <LINK href = "/css/style.css" rel = stylesheet type="text/css">
</head>
<script language="javaScript">
    function change()
    { 
        if (frm_view.oldpass.value=="")
        {
            alert("<%=bundle.getString("PASSWORD_OLD_PASSWORD_IS_NULL")%>");
            frm_view.oldpass.focus();
            return false;
        }
        if (frm_view.newpass1.value=="")
        {
            alert("<%=bundle.getString("PASSWORD_NEW_PASSWORD_IS_NULL")%>");
            frm_view.newpass1.focus();
            return false;
        }
        if (frm_view.newpass2.value=="")
        {
            alert("<%=bundle.getString("PASSWORD_NEW_PASSWORD_IS_NULL")%>");
            frm_view.newpass2.focus();
            return false;
        }
        if (frm_view.newpass1.value!=frm_view.newpass2.value)
        {
            alert("<%=bundle.getString("PASSWORD_NEW_PASSWORD_NOT_EQUAL")%>");
            frm_view.newpass1.focus();
            return false;
        }
        frm_view.submit();
    }
</script>
<body leftmargin=3 topmargin=0>
  <table width="100%" border="0" valign=top align="center" cellpadding="0" cellspacing="0" class="PositionBar">  
    <tr> 
       <td height=30>&nbsp;&nbsp;
          <input type="button" name="btn_reset" value="<%=bundle.getString("PASSWORD_BUTTON_CHANGE")%>" class="Button" onClick="change();">
       </td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
    <form name="frm_view" action="changepassword.jsp" method="post">      
    <input type="hidden" name="action" value="0">
    <tr  height=30>
      <td width=150 align="right" ><%=bundle.getString("PASSWORD_INPUT_OLD_PASSWORD")%></td>
      <td>
          <input type="password" name="oldpass" maxlength="25"  value="">
      </td>
    </tr>
    <tr  height=30>
      <td width=150 align="right" ><%=bundle.getString("PASSWORD_INPUT_NEW_PASSWORD")%></td>
      <td>
          <input type="password" name="newpass1" maxlength="25"  value="">
      </td>
    </tr>
    <tr height=30>
      <td align="right" ><%=bundle.getString("PASSWORD_INPUT_NEW_PASSWORD_AGAIN")%></td>
      <td >
          <input type="password" name="newpass2" maxlength="25"  value="">
      </td>
    </tr>
    </form>        
  </table>
</body>
</html>