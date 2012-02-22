<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.core.Unit" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.core.Config" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.util.Utils" %>
<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String id=request.getParameter("id");//如果为null，将再保存时使用序列生成ID号
    if(id!=null) id=id.trim();   

    if(!(user.IsSysAdmin() || user.IsLocalAdmin()))
         throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);
    
    String create_date = nps.util.Utils.FormateDate(new java.util.Date(),"yyyy-MM-dd HH:mm:ss");

    boolean  bNew=(id==null || id.length()==0);
    Unit unit = null;

    if(!bNew)  //需要从数据库中加载信息
    {
        try
        {
            //通过user类校验本用户权限
            unit = user.GetUnit(id);
            if(unit==null)  throw new NpsException(ErrorHelper.SYS_NOUNIT);
            create_date = nps.util.Utils.FormateDate(unit.GetCreateDate(),"yyyy-MM-dd");
        }
         catch(Exception e)
         {
             throw e;
         }
    }  //if(!bNew)

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_unitinfo",user.GetLocale(), Config.RES_CLASSLOADER);

%>

<html>
<head>
    <title><%=bNew?bundle.getString("UNIT_HTMLTITLE"):unit.GetName()%></title>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>

    <script language="Javascript">
      function fill_check()
      {
        if (document.inputFrm.unitname.value.trim() == ""){
          alert("<%=bundle.getString("UNIT_ALERT_NAME_IS_NULL")%>");
          document.inputFrm.unitname.focus();
          return false;
        }
        var code = document.inputFrm.code.value;
        if (code == ""){
          alert("<%=bundle.getString("UNIT_ALERT_CODE_IS_NULL")%>");
          document.inputFrm.code.focus();
          return false;
        }

        for( var i=0; i < code.length; i++)
        {
           var ch = code.charAt(i);
           if( ( ch>='a'&& ch <= 'z') || (ch >='A' && ch <='Z' ) || (ch >='0' && ch <='9') || ch == '_' || ch == '-' )
           {

           }
           else
           {
             alert("<%=bundle.getString("UNIT_ALERT_CODE_INVALID")%>");
             document.inputFrm.code.focus();
             return false;
           }
        }

        return true;
      }

      function save()
      {
         if(!fill_check()) return;
         document.inputFrm.act.value=0;
         document.inputFrm.submit();
      }

      function deleteUnit()
      {
         var r = confirm("<%=bundle.getString("UNIT_ALERT_DELETE")%>");
		 if( r !=1 ) return false;
         document.inputFrm.act.value=1;
         document.inputFrm.submit();
      }
    </script>
</head>

<body leftmargin=20 topmargin=0>

<table align=center border="0" class="positionbar" cellpadding="0" cellspacing="0">
  <tr>
    <td>  &nbsp;
<%  
  if(user.IsSysAdmin())
  {
%>
      <input type="button" class="button" name="save" value="<%=bundle.getString("UNIT_BUTTON_SAVE")%>" onClick="save()" >
   <%
         if(!bNew)
         {
   %>
      <input type="button" class="button" name="delete" value="<%=bundle.getString("UNIT_BUTTON_DELETE")%>" onClick="deleteUnit()" >
<%
         }
  }
%>        
      <input type="button" class="button" name="close" value="<%=bundle.getString("UNIT_BUTTON_CLOSE")%>" onclick="javascript:window.close();">
    </td>
  </tr>
</table>

<table align=center  width="80%" cellpadding="0" border="0" cellspacing="0">
<form name="inputFrm" method="post" action="unitsave.jsp">
    <input type="hidden" name="id"  value="<%= id==null?"":id %>">
    <input type="hidden" name="act" value="0">
    <tr height=30>
        <td align=center><font color=red><%=bundle.getString("UNIT_CODE")%></font></td>
        <td>
          <input type="text" name="code" maxlength="10" value= "<%= unit==null?"":unit.GetCode() %>">
            <%=bundle.getString("UNIT_HINT_CODE")%>
        </td>
    </tr>
    <tr height=30>
        <td width="120" align=center><font color=red><%=bundle.getString("UNIT_NAME")%></font></td>
        <td>
          <input type="text" name="unitname" maxlength=50  style="width:100%" value= "<%= unit==null?"":Utils.TransferToHtmlEntity(unit.GetName()) %>">
        </td>
    </tr>
    <tr height=30>
		<td align=center><%=bundle.getString("UNIT_ATTACHMAN")%></td>
		<td >
			<input type="text" name="attachman"  maxlength=50 style="width:200"  value="<%= (unit==null || unit.GetAttachman()==null)?"":Utils.TransferToHtmlEntity(unit.GetAttachman()) %>">
	    </td>
    </tr>
    <tr height=30>
		<td align=center><%=bundle.getString("UNIT_TEL")%></td>
		<td >
			<input type="text" name="phonenum"  maxlength="100" style="width:200" value="<%= (unit==null || unit.GetPhonenum()==null)?"":Utils.TransferToHtmlEntity(unit.GetPhonenum()) %>">
	    </td>
    </tr>
    <tr height=30>
		<td align=center><%=bundle.getString("UNIT_MOBILE")%></td>
		<td >
			<input type="text" name="mobile"   maxlength="100" style="width:200" value="<%= (unit==null || unit.GetMobile()==null)?"":Utils.TransferToHtmlEntity(unit.GetMobile()) %>">
	    </td>
    </tr>
    <tr height=30>
		<td align=center><%=bundle.getString("UNIT_EMAIL")%></td>
		<td >
			<input type="text" name="email"   maxlength="100" style="width:200" value="<%= (unit==null || unit.GetEmail()==null)?"":Utils.TransferToHtmlEntity(unit.GetEmail()) %>">
	    </td>
    </tr>
    <tr height=30>
		<td align=center><%=bundle.getString("UNIT_ZIPCODE")%></td>
		<td >
			<input type="text" name="zipcode"   maxlength="10"  width=10 value="<%= (unit==null || unit.GetZipcode()==null)?"":Utils.TransferToHtmlEntity(unit.GetZipcode()) %>">
	    </td>
    </tr>
    <tr height=30>
		<td align=center><%=bundle.getString("UNIT_ADDRESS")%></td>
		<td >
            <textarea name="address" rows="5" cols="10"  style="width:100%"><%= (unit==null || unit.GetAddress()==null)?"":Utils.TransferToHtmlEntity(unit.GetAddress()) %></textarea>
	    </td>
    </tr>
    <tr height=30>
		<td align=center><%=bundle.getString("UNIT_CREATEDATE")%></td>
		<td >
            <%=Utils.Null2Empty(create_date)%>
	    </td>
    </tr>
</table>
</form>
</body>
</html>