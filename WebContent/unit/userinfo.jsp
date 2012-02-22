<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.Connection" %>
<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String id=request.getParameter("id");//如果为null，将再保存时使用序列生成ID号
    if(id!=null) id=id.trim();

    String unitid = request.getParameter("unitid");
    if(unitid!=null) unitid=unitid.trim();

    String deptid = request.getParameter("deptid");
    if(deptid!=null) deptid=deptid.trim();

    boolean  bNew=(id==null || id.length()==0);
    User auser = null;

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_userinfo",user.GetLocale(), Config.RES_CLASSLOADER);

    Connection conn = null;
    try
    {
        conn = Database.GetDatabase("nps").GetConnection();
        conn.setAutoCommit(false);

        if(!bNew)  //需要从数据库中加载信息
        {
            auser = user.GetUser(conn,id);
            if(auser==null) throw new NpsException(ErrorHelper.SYS_NOUSER);
            unitid = auser.GetUnitId();
        }  //if(!bNew)
%>

<html>
<head>
    <title><%=bNew?bundle.getString("USER_HTMLTITLE"):auser.GetName()%></title>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>

    <script language="Javascript">
      function fill_check()
      {
        if (document.inputFrm.username.value.trim() == ""){
            alert("<%=bundle.getString("USER_ALERT_NAME_IS_NULL")%>");
            document.inputFrm.username.focus();
            return false;
        }
        if (document.inputFrm.useraccount.value.trim() == ""){
            alert("<%=bundle.getString("USER_ALERT_ACCOUNT_IS_NULL")%>");
            document.inputFrm.useraccount.focus();
            return false;
        }
<%
       if(bNew)
       {
%>
        if (document.inputFrm.userpass1.value.trim() == ""){
            alert("<%=bundle.getString("USER_ALERT_PASSWORD_IS_NULL")%>");
            document.inputFrm.userpass1.focus();
            return false;
        }
        if (document.inputFrm.userpass2.value.trim() == ""){
            alert("<%=bundle.getString("USER_ALERT_PASSWORD_IS_NULL")%>");
            document.inputFrm.userpass2.focus();
            return false;
        }
          
        if (document.inputFrm.userpass1.value!=inputFrm.userpass2.value){
            alert("<%=bundle.getString("USER_ALERT_PASSWORD_NOT_EQUAL")%>");
            document.inputFrm.userpass1.focus();
            return false;
        }
<%
        }
%>
        return true;
      }

      function saveuser()
      {
         if(!fill_check()) return;
         document.inputFrm.act.value=0;
         document.inputFrm.submit();
      }

      function deleteUser()
      {
         var r = confirm("<%=bundle.getString("USER_ALERT_DELETE")%>");
         if( r !=1 ) return false;

         document.inputFrm.act.value=1;
         document.inputFrm.submit();
      }

      function resetpassword()
      {
          if (document.inputFrm.userpass1.value.trim() == ""){
              alert("<%=bundle.getString("USER_ALERT_PASSWORD_IS_NULL")%>");
              document.inputFrm.userpass1.focus();
              return false;
          }
          if (document.inputFrm.userpass2.value.trim() == ""){
              alert("<%=bundle.getString("USER_ALERT_PASSWORD_IS_NULL")%>");
              document.inputFrm.userpass2.focus();
              return false;
          }

          if (document.inputFrm.userpass1.value!=inputFrm.userpass2.value){
              alert("<%=bundle.getString("USER_ALERT_PASSWORD_NOT_EQUAL")%>");
              document.inputFrm.userpass1.focus();
              return false;
          }
          
          document.inputFrm.act.value=2;
          document.inputFrm.submit();          
      }

      function check_all()
      {
            var roles = document.getElementsByName("roleid");
            for (var i = 0; i < roles.length; i++)
            {
                roles[i].checked = document.inputFrm.all_roleid.checked;
            }
      }

      function check_all_grant()
      {
          var roles = document.getElementsByName("role_grant_id");
          for (var i = 0; i < roles.length; i++)
          {
              roles[i].checked = document.inputFrm.all_role_grant_id.checked;
          }
      }
    </script>
</head>

<body leftmargin=10 topmargin=0 onload="document.inputFrm.username.focus();">

<table align=center border="0" class="positionbar" cellpadding="0" cellspacing="0">
  <tr>
    <td>  &nbsp;
<%
  if(bNew)
  {
%>
      <input type="button" class="button" name="save" value="<%=bundle.getString("USER_BUTTON_SAVE")%>" onClick="saveuser()" >
<%
   }
   if(auser!=null)
   {
%>
      <input type="button" class="button" name="save" value="<%=bundle.getString("USER_BUTTON_SAVE_EXCEPT_PASSWORD")%>" onClick="saveuser()" >
      <input type="button" class="button" name="resetpassword" value="<%=bundle.getString("USER_BUTTON_RESET_PASSWORD")%>" onClick="resetpassword()" >  
      <input type="button" class="button" name="delete" value="<%=bundle.getString("USER_BUTTON_DELETE")%>" onClick="deleteUser()" >
<%
     }
%>
    </td>
  </tr>
</table>

<table align=center  width="90%" cellpadding="0" border="0" cellspacing="0">
    <form name="inputFrm" method="post" action="usersave.jsp">
    <input type="hidden" name="id"  value="<%= id==null?"":id %>">
    <input type="hidden" name="unitid" value="<%=unitid==null?"":unitid%>">
    <input type="hidden" name="act" value="0">
    <tr>
        <td width="120" align=center><font color=red><%=bundle.getString("USER_NAME")%></font></td>
        <td width="200">
          <input type="text" name="username" maxlength=50  style="width:100%" value= "<%= auser==null?"":auser.GetName() %>">
        </td>
        <td width="80" align=center>
            <font color=red><%=bundle.getString("USER_TYPE")%></font>
        </td>
        <td>
            <select name="usertype" <%=user.IsSysAdmin()?"":"disabled"%>>
                <option value="0" <%= (auser!=null && auser.IsSysAdmin())?"":"selected"%>><%=bundle.getString("USER_TYPE_NORMAL")%></option>
                <option value="9" <%= (auser!=null && auser.IsSysAdmin())?"selected":""%>><%=bundle.getString("USER_TYPE_SUPER")%></option>
            </select>
        </td>
    </tr>
    <tr height="25">
        <td align=center><%=bundle.getString("USER_UNIT")%></td>
        <td>
            <%
                if(auser!=null)
                {
                    out.print(auser.GetUnit(conn).GetDeptTree(conn).toSelectBox("deptid",auser.GetDeptId()));                    
                }
                else
                {
                    Unit unit = user.GetUnit(conn,unitid);
                    if(unit!=null)  out.print(unit.GetDeptTree(conn).toSelectBox("deptid",deptid));
                }
            %>
        </td>
        <td width="80" align=center><%=bundle.getString("USER_ORDER")%></td>
        <td>
            <input type="text" name="index"  maxlength="5" style="width:50px" value="<%= auser==null?0:auser.GetIndex()%>">
        </td>
    </tr>
    <tr>
        <td align=center><font color=red><%=bundle.getString("USER_ACCOUNT")%></font></td>
        <td colspan="3">
          <input type="text" name="useraccount" maxlength="25" value= "<%= auser==null?"":auser.GetAccount() %>">
        </td>
    </tr>
    <tr>
        <td align=center><font color=red><%=bundle.getString("USER_PASSWORD")%></font></td>
        <td colspan="3">
          <input type="password" name="userpass1" maxlength="25" value= "">
        </td>
    </tr>
    <tr>
        <td colspan="4" align=left>
          &nbsp;&nbsp;<font color=red><%=bundle.getString("USER_PASSWORD_AGAIN")%></font>
          &nbsp;<input type="password" name="userpass2" maxlength="25" value= "">
        </td>
    </tr>
    <tr>
		<td align=center><%=bundle.getString("USER_TEL")%></td>
		<td colspan="3">
			<input type="text" name="phone"  maxlength=25 style="width:200"  value="<%= (auser==null || auser.GetTelephone()==null)?"":auser.GetTelephone() %>">
	    </td>
    </tr>
    <tr>
		<td align=center><%=bundle.getString("USER_EMAIL")%></td>
		<td colspan="3">
			<input type="text" name="email"  maxlength="50" style="width:200" value="<%= (auser==null || auser.GetEmail()==null)?"":auser.GetEmail() %>">
	    </td>
    </tr>
    <tr>
		<td align=center><%=bundle.getString("USER_MOBILE")%></td>
		<td colspan="3">
			<input type="text" name="mobile"   maxlength="25" style="width:200" value="<%= (auser==null || auser.GetMobile()==null)?"":auser.GetMobile() %>">
	    </td>
    </tr>
    <tr>
		<td align=center><%=bundle.getString("USER_FAX")%></td>
		<td colspan="3">
			<input type="text" name="fax"   maxlength="25" style="width:200" value="<%= (auser==null || auser.GetFax()==null)?"":auser.GetFax() %>">
	    </td>
    </tr>
</table>

<table align=center  width="90%" cellpadding="0" border="0" cellspacing="1" class="titlebar">
    <tr height="25">
        <td colspan="4"><%=bundle.getString("USER_ROLES_HINT")%></td>
    </tr>
    <tr height="25">
        <td><input type="checkbox" id="all_roleid" name="all_roleid" onclick="javascript:check_all()"></td>
        <td><%=bundle.getString("USER_ROLES_DOMAIN")%></td>
        <td><%=bundle.getString("USER_ROLES_NAME")%></td>
        <td><%=bundle.getString("USER_ROLES_DESC")%></td>
    </tr>
    <%
        NpsContext ctxt = new NpsContext(conn,user);
        List<Role> list = Role.GetRoles(ctxt);
        if(list!=null && list.size()>0)
        {
            //int i=0;
            for(Role role:list)
            {
                if(!(user.HasRole(role.GetId()) || user.HasRoleGrantable(role.GetId()) || (auser!=null && auser.HasRole(role.GetId())) )) continue;
    %>
                    <tr  height="25" class="detailbar">
                        <td width="15">
                            <input type = "checkBox" id="roleid" name="roleid" value = "<%= role.GetId() %>" <% if(auser!=null && auser.HasRole(role.GetId())) out.print("checked"); %>>
                        </td>
                        <td width="80"><%= role.GetDomain() %></td>
                        <td width="120"><%= role.GetName() %></td>
                        <td><%= nps.util.Utils.Null2Empty(role.GetDesc()) %></td>
                    </tr>
    <%
            }
        }
    %>
    <tr height="25">
        <td colspan="4"><%=bundle.getString("USER_ROLES_GRANTABLE_HINT")%></td>
    </tr>
    <tr height="25">
        <td><input type="checkbox" id="all_role_grant_id" name="all_role_grant_id" onclick="javascript:check_all_grant()"></td>
        <td><%=bundle.getString("USER_ROLES_DOMAIN")%></td>
        <td><%=bundle.getString("USER_ROLES_NAME")%></td>
        <td><%=bundle.getString("USER_ROLES_DESC")%></td>
    </tr>
    <%
        if(list!=null && list.size()>0)
        {
            //int i=0;
            for(Role role:list)
            {
                if(!user.HasRoleGrantable(role.GetId())) continue;
    %>
                <tr  height="25" class="detailbar">
                    <td width="15">
                        <input type = "checkBox" id="role_grant_id" name="role_grant_id" value = "<%= role.GetId() %>" <% if(auser!=null && auser.HasRoleGrantable(role.GetId())) out.print("checked"); %>>
                    </td>
                    <td width="80"><%= role.GetDomain() %></td>
                    <td width="120"><%= role.GetName() %></td>
                    <td><%= nps.util.Utils.Null2Empty(role.GetDesc()) %></td>
                </tr>
    <%
            }
        }
   %>
</form>
</table>
</body>
</html>
<%
}
finally
{
    if(conn!=null) try{conn.close();}catch(Exception e){}
}
%>