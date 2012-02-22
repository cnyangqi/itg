<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>

<%@ page import="nps.core.NpsWrapper" %>
<%@ page import="nps.core.Role" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.Config" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Enumeration" %>

<%@ include file = "/include/header.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");
    String roleid =  request.getParameter("id");
    NpsWrapper wrapper = null;
    Role role = null;
    boolean bNew = (roleid==null || roleid.length()==0);

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_roleinfo",user.GetLocale(), Config.RES_CLASSLOADER);

    if(bNew && !user.IsSysAdmin())
    {
        throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);
    }

    if(!bNew)
    {
        try
        {
            wrapper = new NpsWrapper(user);
            role = Role.GetRole(wrapper.GetContext(),roleid);
        }
        finally
        {
           if(wrapper!=null) wrapper.Clear();
        }
    }
%>

<HTML>
	<HEAD>
		<TITLE><%= role==null?"":role.GetName() %><%=bundle.getString("ROLE_HTMLTITLE")%></TITLE>
        <LINK href="/css/style.css" rel = stylesheet>
        <script type="text/javascript" src="/jscript/global.js"></script>
        <script type="text/javascript">
            function f_save()
            {
                if(role_form.name.value.trim()=="")
                {
                    alert("<%=bundle.getString("ROLE_ALERT_NONAME")%>");
                    return false;
                }

                role_form.act.value = "0";
                role_form.submit();
            }

            function f_delete()
            {
                role_form.act.value = "1";
                role_form.submit();
            }

            function f_deluser(uid)
            {
                role_form.act.value="2";
                role_form.uid.value=uid;
                role_form.submit();
            }
            
        </script>
    </HEAD>

<BODY leftMargin="10" topMargin = "0">
<form name="role_form" action="rolesave.jsp" method="post" >
  <input type="hidden" name="act" value="0">
  <input type="hidden" name="id" value="<% if(role!=null) out.print(role.GetId());%>">  
  <input type="hidden" name="uid" value="">
    
  <table width ="100%" border = "0" align ="center" cellpadding = "0" cellspacing = "0" class="positionbar">
    <tr height="25" >
      <td  valign="middle" >&nbsp;
          <input name="saveBtn" type="button" class="button" onClick="f_save()"  value="<%=bundle.getString("ROLE_BUTTON_SAVE")%>">
          <input name="deleteBtn" type="button" class="button" onClick="f_delete()"  value="<%=bundle.getString("ROLE_BUTTON_DELETE")%>">
          <input name="closeBtn" type="button" class="button" onClick="javascript:window.close();"  value="<%=bundle.getString("ROLE_BUTTON_CLOSE")%>">
      </td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing=0 cellpadding=0 >
    <tr height="30">
        <td width=120 align="center"><%=bundle.getString("ROLE_ID")%></td>
        <td><% if(role!=null) out.print(role.GetId()); %></td>
    </tr>
    <tr height="30">
        <td width=120 align="center"><%=bundle.getString("ROLE_DOMAIN")%></td>
        <td>
            <input type="text" size="25" name="domain" value="<%= role==null?"":Utils.TransferToHtmlEntity(Utils.Null2Empty(role.GetDomain())) %>">
            <%=bundle.getString("ROLE_DOMAIN_HINT")%>
        </td>
    </tr>
    <tr height="30">
        <td width=120 align="center">
            <font color="red"><%=bundle.getString("ROLE_NAME")%></font>
        </td>
        <td>
            <input type="text" size="25" name="name" value="<%= role==null?"":Utils.TransferToHtmlEntity(Utils.Null2Empty(role.GetName())) %>">
        </td>
    </tr>
    <tr height="30">
        <td width=120 align="center"><%=bundle.getString("ROLE_DESC")%></td>
        <td>
            <textarea rows="5" cols="40" name="desc"><%= role==null?"":Utils.TransferToHtmlEntity(Utils.Null2Empty(role.GetDesc())) %></textarea>
        </td>
    </tr>
    <tr height="30">
        <td colspan="2">
            <table width="80%" border="0" cellpadding="0" cellspacing="0" class="titlebar">
            <tr height="30">
                <td colspan="5">&nbsp;&nbsp;<%=bundle.getString("ROLE_USERLIST")%></td>
            </tr>

            <%
                  Hashtable users = null;
                  if(role!=null) users=role.GetUsers();
                  if(users!=null && users.size()>0)
                  {
                    Enumeration uids = users.keys();
                    int i=0;
                    while(uids.hasMoreElements())
                    {
                        String uid = (String)uids.nextElement();
                        if(i==0)
                        {
                            out.print("<tr class=detailbar height='30'>");
                        }
                        else if(i%5==0)
                        {
                           out.print("</tr>");
                           out.print("<tr class=detailbar height='30'>");
                        }
                        out.print("<td width=20% align=center>");
                        out.print(users.get(uid));
                        out.print("&nbsp;&nbsp;");
                        out.print("<a href=\"javascript:f_deluser('"+uid+"');\">X</a>");
                        out.print("</td>");

                        i++;
                    }

                    for(int j=1;j<=(5-i/5);j++)
                    {
                        out.print("<td width='20%'>&nbsp;</td>");
                    }
                    if(i%5!=0) out.print("</tr>");
                  }
            %>
            </table>
        </td>
    </tr>
  </table>    
  </form>
</BODY>
</HTML>