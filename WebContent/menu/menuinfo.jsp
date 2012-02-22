<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="nps.exception.*" %>
<%@ page import="nps.core.*" %>

<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    if(!user.IsSysAdmin()) throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

    String id = request.getParameter("id");
    String cmd = request.getParameter("cmd");
    String refresh_cmd = request.getParameter("refresh");
    String delete_cmd = request.getParameter("delete");
    String parentid = request.getParameter("parentid");
    if("addchild".equalsIgnoreCase(cmd))
    {
        //添加下级菜单
        parentid = id;
        id = "";
    }

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_menuinfo",user.GetLocale(), Config.RES_CLASSLOADER);

    boolean bNew = (id==null || id.length()==0);
    Menu menu = MenuTree.GetInstance().GetMenu(id);
%>

<html>
<head>
  <title><%=menu==null?bundle.getString("MENU_HTMLTITLE"):menu.GetName()%></title>
    <script language = "javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>

  <SCRIPT language="JavaScript">
<%
    //如果需要刷新左侧树型结构
    if(refresh_cmd!=null && refresh_cmd.length()>0 && menu!=null)
    {
%>
        if(parent)
        {
            var menutree = parent.frames["menuList"].window.menutree;

            var node = menutree.getItemText('<%=id%>');
            if(node)
            {
                 menutree.setItemText('<%=id%>','<%=menu.GetName()%>');
                 menutree.setUserData('<%=id%>','menuid','<%=id%>');
            }
            else  //是新增的节点
            {
<%
            String node_parentname = null;
            if(menu.GetParentId()==null || menu.GetParentId().length()==0 ||"-1".equalsIgnoreCase(menu.GetParentId()))
            {
                node_parentname = "-1";
            }
            else
            {
                node_parentname = menu.GetParentId();
            }

            String node_id = id;
            String jstree = "menutree.insertNewItem('" + node_parentname + "',"
                                                      + "'"+ node_id +"',"
                                                      +"\""+ Utils.TranferToXmlEntity(menu.GetName()) +"\",0,0,0,0,'SELECT');";
            jstree += "menutree.setUserData('"+node_id+"',"
                                                +"'menuid',"
                                                +"'"+ id +"');";

             out.println(jstree);
%>
            }
          }
<%
    }

    if(delete_cmd!=null && delete_cmd.length()>0)
    {
%>
        if(parent)
        {
            var menutree = parent.frames["menuList"].window.menutree;

            var node = menutree.getItemText('<%=id%>');
            if(node)
            {
                menutree.deleteItem('<%=id%>');
            }
        }
<%
       id="";
       bNew=true;
    }
%>
    function f_submit()
    {
        if( document.frm.menu_name.value.trim() == '' )
        {
            alert("<%=bundle.getString("MENU_ALERT_NO_NAME")%>");
            document.frm.menu_name.focus();
            return false;
        }

        document.frm.cmd.value = "save";
        document.frm.action="menusave.jsp";
        document.frm.submit();
    }

    function f_addchild()
    {
        document.frm.cmd.value = "addchild";
        document.frm.action = "menuinfo.jsp";
        document.frm.submit();
    }

    function f_delMenu()
    {
      var r = confirm("<%=bundle.getString("MENU_ALERT_DELETE")%>");
      if( r ==1 )
      {
          document.frm.cmd.value = "delete";
          document.frm.action = "menusave.jsp";
          document.frm.submit();
      }
    }
  </script>
</head>

<body leftmargin="20" topmargin="10" >
<form name="frm" method="post" action ="menusave.jsp">
  <table width="100%"  border=0 cellspacing=0 cellpadding=0>
    <tr height="30">
     <td> &nbsp;
        <input type="button" name=okbtn value="<%=bundle.getString("MENU_BUTTON_SAVE")%>" onclick="f_submit()" class="button">
        <input type="button" name=childbtn value="<%=bundle.getString("MENU_BUTTON_ADDCHILD")%>" onclick="f_addchild()" class="button">
        <input type="button" name=delbtn value="<%=bundle.getString("MENU_BUTTON_DELETE")%>" onclick="f_delMenu()" class="button">
     </td>
   </tr>
  </table>

   <table width="100%" border=1 cellspacing=0 cellpadding=0>
       <input type="hidden" name="id" value="<%=Utils.Null2Empty(id)%>">
       <input type="hidden" name="parentid" value="<% if(parentid!=null) out.print(parentid); else if(menu!=null && !"-1".equals(parentid)) out.print(Utils.Null2Empty(menu.GetParentId()));%>">
       <input type="hidden" name="cmd" value="">
     <tr height="25">
         <td align=center width="120" ><font color="red"><b><%=bundle.getString("MENU_NAME")%></b></font></td>
         <td>
             <input type=text name="menu_name" value="<%= menu==null?"":menu.GetName() %>">
         </td>
         <td width=120 align=center><%=bundle.getString("MENU_INDEX")%></td>
         <td >
            <input type="text" name="menu_index" value="<%= menu==null?0:menu.GetIndex() %>" size="6"  maxlength="3">
         </td>
     </tr>
     <tr height="25">
         <td align=center><b><%=bundle.getString("MENU_URL")%></b></td>
         <td>
             <input type=text name="menu_url" value="<%= menu==null?"":Utils.Null2Empty(menu.GetURL()) %>" style="width:320px">
         </td>
         <td colspan="2">
             &nbsp;<input type="checkbox" name="menu_def" value="1" <% if(menu!=null && menu.IsDefault()) out.print("checked"); %> ><%=bundle.getString("MENU_DEFAULT")%>
         </td>
     </tr>
     <tr height="25">
         <td align=center><b><%=bundle.getString("MENU_TARGET")%></b></td>
         <td colspan="3">
             <input type=text name="menu_target" value="<%= menu==null?"":Utils.Null2Empty(menu.GetTarget()) %>">
             <font color="red">
               <%=bundle.getString("MENU_TARGET_HINT")%>
             </font>
         </td>
     </tr>
     <tr height="25">
       <td colspan="4">
           <div style="color:red;padding-left:40px;padding-top:2px;padding-bottom:5px">
             <%=bundle.getString("MENU_PREVILEGE_HINT")%>
           </div>
       </td>
     </tr>
     <tr height="25">
        <td align="center"><%=bundle.getString("MENU_VISIBLE")%></td>
        <td colspan="3">
           <select name="menu_visible">
             <option value="0" <% if(menu!=null&&menu.GetVisibility()==0) out.print("selected"); %> ><%=bundle.getString("MENU_VISIBLE_SYSADMIN")%></option>
             <option value="1" <% if(menu!=null&&menu.GetVisibility()==1) out.print("selected"); %> ><%=bundle.getString("MENU_VISIBLE_SITEADMIN")%></option>
             <option value="2" <% if(menu==null || menu.GetVisibility()==2) out.print("selected"); %> ><%=bundle.getString("MENU_VISIBLE_ALL")%></option>
           </select>
        </td>
     </tr>
     <tr height="25">
       <td align="center"><%=bundle.getString("MENU_SITES")%></td>
       <td  colspan="3">
         <input type="text" name="menu_sites" value="<% if(menu!=null) out.print(Utils.Null2Empty(menu.GetSites())); %>" style="width:300px">
         <div style="color:red;padding-top:2px;padding-bottom:5px">
           <%=bundle.getString("MENU_SITES_HINT")%>
         </div>
       </td>
    </tr>
    <tr height="25">
       <td align="center"><%=bundle.getString("MENU_ROLES")%></td>
       <td  colspan="3">
         <input type="text" name="menu_roles" value="<% if(menu!=null) out.print(Utils.Null2Empty(menu.GetRoles()));%>" style="width:300px">
         <div style="color:red;padding-top:2px;padding-bottom:5px">
            <%=bundle.getString("MENU_ROLES_HINT")%>
         </div>
       </td>
    </tr>
   </table>
  </form>
</body>
</html>