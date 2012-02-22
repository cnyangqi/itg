<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.core.*" %>
<%@ page import="java.util.List" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>

<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_deptinfo",user.GetLocale(), Config.RES_CLASSLOADER);
    
    String unitid = request.getParameter("unitid");
    if( unitid == null)  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    unitid = unitid.trim();

    String deptid = request.getParameter("deptid");
    if(deptid!=null) deptid = deptid.trim();

    String cmd = request.getParameter("cmd");
    String refresh_cmd = request.getParameter("refresh");
    String delete_cmd = request.getParameter("delete");
    String dept_parentid = request.getParameter("dept_parentid");

    if("addchild".equalsIgnoreCase(cmd))
    {
        //添加下级部门
        dept_parentid = deptid;
        deptid = "";
    }

    Unit unit = user.GetUnit(unitid);
    Dept dept = null;
    boolean bNew = (deptid==null || deptid.length()==0);

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try
    {
        if(!bNew)
        {
            if(conn==null)
            {
                conn = Database.GetDatabase("nps").GetConnection();
                conn.setAutoCommit(false);
            }
            dept = unit.GetDeptTree(conn).GetDept(deptid);
        }

        if("deluser".equalsIgnoreCase(cmd))
        {
            //删除用户
            String rownos[] = request.getParameterValues("rowno");
            if(rownos!=null && rownos.length>0)
            {
                String del_users[] = new String[rownos.length];
                int del_user_index=0;
                for(Object obj:rownos)
                {
                    del_users[del_user_index] = request.getParameter("user_id_"+(String)obj);
                    del_user_index++;
                }
                user.Delete(conn,del_users);
            }
        }
%>

<html>
<head>
  <title><%=bundle.getString("DEPT_HTMLTITLE")%></title>
    <script language = "javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>

  <SCRIPT language="JavaScript">
    var totalRows =0;
<%
    //如果需要刷新左侧树型结构
    if(refresh_cmd!=null && refresh_cmd.length()>0 && dept!=null)
    {
%>
        var depttree = parent.frames["deptList"].window.depttree;

        var node = depttree.getItemText('<%=unitid%>.<%=deptid%>');

        if(node)
        {
            depttree.setItemText('<%=unitid%>.<%=deptid%>','<%=dept.GetName()%>');
            depttree.setUserData('<%=unitid%>.<%=deptid%>','unitid','<%=unitid%>');
            depttree.setUserData('<%=unitid%>.<%=deptid%>','unitname','<%=Utils.TransferToHtmlEntity(unit.GetName())%>');
            depttree.setUserData('<%=unitid%>.<%=deptid%>','deptid','<%=dept.GetId()%>');
            depttree.setUserData('<%=unitid%>.<%=deptid%>','deptname','<%=dept.GetName()%>');
        }
        else
        {
<%
            //是新增的节点
            String node_parentname = null;
            if(dept.GetParentId()==null || dept.GetParentId().length()==0 ||"-1".equalsIgnoreCase(dept.GetParentId()))
            {
                node_parentname = unitid;
            }
            else
            {
               node_parentname = unitid+"."+dept.GetParentId();
            }

            String node_id = unitid + "." + deptid;
            String jstree = "depttree.insertNewItem('" + node_parentname + "',"
                                                         + "'"+ node_id +"',"
                                                         +"\""+ Utils.TranferToXmlEntity(dept.GetName()) +"\",0,0,0,0,'SELECT');";
            jstree += "depttree.setUserData('"+node_id+"',"
                                                +"'unitid',"
                                                +"'"+ unitid +"');";

            jstree += "depttree.setUserData('"+node_id+"',"
                                                +"'unitname',"
                                                +"\""+ Utils.TranferToXmlEntity(dept.GetUnit().GetName()) +"\");";

            jstree += "depttree.setUserData('"+node_id+"',"
                                                +"'deptid',"
                                                +"'" + dept.GetId() +"');";

            jstree += "depttree.setUserData('"+node_id+"',"
                                                +"'deptname',"
                                                +"\"" + Utils.TranferToXmlEntity(dept.GetName()) +"\");";

            out.println(jstree);
%>
          }
<%
    }

    if(delete_cmd!=null && delete_cmd.length()>0)
    {
%>
        var depttree = parent.frames["deptList"].window.depttree;

        var node = depttree.getItemText('<%=unitid + "." + deptid%>');
        if(node)
        {
            depttree.deleteItem('<%=unitid + "." + deptid%>');
        }
<%
    }
%>
    function f_save()
    {
        if( document.frm.dept_name.value.trim() == '' )
        {
            alert("<%=bundle.getString("DEPT_ALERT_NO_NAME")%>");
            document.frm.dept_name.focus();
            return false;
        }
       
        if( document.frm.dept_code.value.trim() == '' )
        {
            alert("<%=bundle.getString("DEPT_ALERT_NO_CODE")%>");
            document.frm.dept_code.focus();
            return false;
        }
        else
        {
              var dept_code =document.frm.dept_code.value;
              for(var i=0; i < dept_code.length; i++)
             {
               var ch = dept_code.charAt(i);
               if( ( ch>='a'&& ch <= 'z') || (ch >='A' && ch <='Z' ) || (ch >='0' && ch <='9') || ch == '_' || ch == '-' || ch=='.' )
               {

               }
               else
               {
                 alert("<%=bundle.getString("DEPT_ALERT_CODE_INVALID")%>");
                 document.frm.dept_code.focus();
                 return false;
               }
             }
        }
        document.frm.cmd.value = "save";
        document.frm.action="deptsave.jsp";
        document.frm.submit();
    }

    function f_addchild()
    {
        document.frm.cmd.value = "addchild";
        document.frm.action = "deptinfo.jsp";
        document.frm.submit();
    }
    
    function f_delDept()
    {
      var r = confirm("<%=bundle.getString("DEPT_ALERT_DELETE")%>");
      if( r ==1 )
      {
          document.frm.cmd.value = "delete";
          document.frm.action = "deptsave.jsp";
          document.frm.submit();
      }
    }

    function popupDialog(url)
    {
         var isMSIE= (navigator.appName == "Microsoft Internet Explorer");

         if (isMSIE)
         {
             return window.showModalDialog(url);
         }
         else
         {
             var win = window.open(url, "mcePopup","dialog=yes,modal=yes" );
             win.focus();
         }
    }
    
    function adduser(unitid,deptid)
    {
        var url = 'popupwindow.jsp?src='+escape("userinfo.jsp?unitid=" + unitid + "&deptid=" + deptid);
        var rc = popupDialog(url);
        //var rc = window.showModalDialog(url);
        if (rc == null || rc.length==0) return false;

        f_adduser(rc[0],rc[1],rc[2],rc[3]);
    }

    function f_adduser(uid,uname,uaccount,dept)
    {
        var tbody = document.getElementById("pttable").getElementsByTagName("TBODY")[0];

        totalRows = totalRows+1;

        var row = document.createElement("TR");
        row.setAttribute("id","row_" + totalRows)  ;
        row.setAttribute("class","detailbar")  ;

        var td1 = document.createElement("Td");
        var input1=document.createElement("INPUT");
        input1.setAttribute("name", "rowno" );
        input1.setAttribute("type", "checkbox");
        input1.setAttribute("value", totalRows);
        td1.appendChild(input1);

        var input1=document.createElement("INPUT");
        input1.setAttribute("name", "user_id_"+totalRows );
        input1.setAttribute("type", "hidden");
        input1.setAttribute("value", uid);
        td1.appendChild(input1);

        row.appendChild(td1);

        td1 = document.createElement("TD");
        td1.innerHTML = "<a href=\"f_alterUser('"+uid+"')\"> "+ uname +"</a>";
        row.appendChild(td1);

        td1 = document.createElement("TD");
        td1.innerHTML = uaccount;
        row.appendChild(td1);

        td1 = document.createElement("TD");
        td1.innerHTML = dept;
        row.appendChild(td1);

        tbody.appendChild(row);        
    }

    function deleteuser()
    {
        var r = confirm("<%=bundle.getString("DEPT_ALERT_DELETE_USER")%>");
        if( r ==1 )
        {
           document.frm.cmd.value = "deluser";
           document.frm.action = "deptinfo.jsp";
           document.frm.submit();
        }
    }
    
    function SelectUser()
    {
        var rownos = document.getElementsByName("rowno");
        for (var i = 0; i < rownos.length; i++)
        {
            rownos[i].checked = document.frm.AllId.checked;
        }
    }

   function f_alterUser(user_id)
   {
        var url = 'popupwindow.jsp?src='+escape("userinfo.jsp?id=" + user_id);
        popupDialog(url);
   }
  </script>
</head>

<body leftmargin="20" topmargin="10" >
<form name="frm" method="post" action ="deptsave.jsp">
  <table width="100%"  border=0 cellspacing=0 cellpadding=0>
    <tr height="30">
     <td> &nbsp;
       <input type="button" name=okbtn value="<%=bundle.getString("DEPT_BUTTON_SAVE")%>" onclick="f_save()" class="button">
       <% if(  !bNew ){ %>
         <input type="button" name=childbtn value="<%=bundle.getString("DEPT_BUTTON_ADDCHILD")%>" onclick="f_addchild()" class="button">
         <input type="button" name=delbtn value="<%=bundle.getString("DEPT_BUTTON_DELETE")%>" onclick="f_delDept()" class="button">
       <% }%>
         &nbsp;&nbsp;<font color="red"><%=bundle.getString("DEPT_HINT")%></font>
     </td>
   </tr>
  </table>
  
   <table width="100%" border=1 cellspacing=0 cellpadding=0>
       <input type="hidden" name="unitid" value="<%= unitid %>" >
       <input type="hidden" name="deptid" value="<%= deptid %>">
       <input type="hidden" name="dept_parentid" value="<%= dept_parentid==null?"":dept_parentid %>">
       <input type="hidden" name="cmd" value="">
     <tr>
         <td align=center><font color="red"><b><%=bundle.getString("DEPT_NAME")%></b></font></td>
         <td >
             <input type=text name="dept_name" value="<%= dept==null?"":Utils.TransferToHtmlEntity(dept.GetName()) %>" size=25 >
         </td>
        <td align=center width="80"><font color="red"><b><%=bundle.getString("DEPT_CODE")%></b></font></td>
        <td width="80">
            <input type=text name="dept_code" value="<%= dept==null?"":dept.GetCode() %>" size=25 >
        </td>
        <td align=center width="80"><%=bundle.getString("DEPT_ORDER")%></td>
         <td width="80" >
            <input type="text" name="dept_index" value="<%= dept==null?0:dept.GetIndex() %>" size="25"  maxlength="3">
         </td>
     </tr>     
   </table>

  <table width="100%" cellpadding="0" cellspacing="1" border="0">
      <tr height="30">
         <td align=left>
           <b><%=bundle.getString("DEPT_USERS")%></b>
<%
    if(!bNew)
    {
%>
           <input type="button" class="button" value="<%=bundle.getString("DEPT_BUTTON_ADDUSER")%>" onclick="adduser('<%=unitid%>','<%=deptid%>')">
           <input type="button" class="button" value="<%=bundle.getString("DEPT_BUTTON_DELUSER")%>" onclick="deleteuser()">
<%
     }
%>             
         </td>
     </tr>
   </table>

   <table id="pttable" name="pttable"  width="100%" cellpadding="0" cellspacing="1" border="0">
    <TBody>
     <tr height=30 class="titlebar">
       <td width="25"><input type = "checkBox" name = "AllId" value = "0" onclick = "SelectUser()"></td>
       <td width="180"><%=bundle.getString("DEPT_USERNAME")%></td>
       <td width="120"><%=bundle.getString("DEPT_USERACCOUNT")%></td>
       <td><%=bundle.getString("DEPT_DEPTNAME")%></td>  
     </tr>

<%
    if(conn==null) conn = Database.GetDatabase("nps").GetConnection();
    String sql = null;

    if(!bNew)
    {
        sql = "select a.id,a.name,a.account,b.name dept_name from users a,dept b where a.dept=b.id and b.id=? order by a.cx";
    }
    else
    {
        sql = "select a.id,a.name,a.account,b.name dept_name from users a,dept b where a.dept=b.id and b.unit=? order by b.cx,a.cx";
    }

    pstmt = conn.prepareStatement(sql);

    if(!bNew)
    {
        pstmt.setString(1,deptid);
    }
    else
    {
        pstmt.setString(1,unitid);
    }

    rs = pstmt.executeQuery();
    int i = 0;
    while(rs.next())
    {
        i++;
%>
     <tr height=30 id="row<%= i%>">
       <td>
           <input type = "checkBox" name = "rowno" value = "<%= i %>">
           <input type="hidden" name="user_id_<%= i %>" value="<%= rs.getString("id") %>">
       </td>
       <td>
         <a href="javascript:f_alterUser('<%= rs.getString("id") %>')">  <%= rs.getString("name")  %></a>
       </td>
       <td><%= rs.getString("account") %></td>
       <td><%= rs.getString("dept_name") %></td>
     </tr>
<%
    }
%>
     <script type="text/javascript">totalRows=<%=i%>;</script>
    </TBody>
  </table>
</form>

<form name="user_form" action="userinfo.jsp" method="post" target="_blank">
    <input type="hidden" name="id"  value="">
</form>
<%
}
catch(Exception e)
{
    if(conn!=null) conn.rollback();
    throw e;
}
finally
{
    if(conn!=null) try{conn.close();}catch(Exception e){}
}
%>
</body>
</html>