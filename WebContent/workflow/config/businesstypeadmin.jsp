<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.Config" %>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.workflow.BusinessType" %>

<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    String act = request.getParameter("act");
    if(act!=null)  act = act.trim();

    if(!(user.IsSysAdmin() || user.IsLocalAdmin())) throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

    ResourceBundle bundle = ResourceBundle.getBundle("langs.workflow_businesstypeadmin",user.GetLocale(), Config.RES_CLASSLOADER);

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    try
    {
        conn = Database.GetDatabase("nps").GetConnection();
        conn.setAutoCommit(false);
        if("del".equalsIgnoreCase(act))
        {
            //删除
            String[] rowno = request.getParameterValues("rowno");
            if(rowno!=null && rowno.length>0)
            {
                for(int i=0;i<rowno.length;i++)
                {
                    String id = request.getParameter("type_id_"+ rowno[i]);
                    BusinessType type = BusinessType.Get(id);
                    if(type==null) continue;
                    type.Remove(conn,false);
                }
                conn.commit();
                out.println("<font color=red>" + bundle.getString("BUSINESSTYPEADMIN_HINT_REMOVED") + "</font>");
            }
        }
        else if("delforce".equalsIgnoreCase(act))
        {
            //删除所有表和数据
            String[] rowno = request.getParameterValues("rowno");
            if(rowno!=null && rowno.length>0)
            {
                for(int i=0;i<rowno.length;i++)
                {
                    String id = request.getParameter("type_id_"+ rowno[i]);
                    BusinessType type = BusinessType.Get(id);
                    if(type==null) continue;
                    type.Remove(conn,true);
                }
                conn.commit();
                out.println("<font color=red>" + bundle.getString("BUSINESSTYPEADMIN_HINT_REMOVED") + "</font>");
            }
        }
%>

<HTML>
  <HEAD>
    <TITLE><%=bundle.getString("BUSINESSTYPEADMIN_HTMLTILE")%></TITLE>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>
    <script langauge = "javascript">
        function f_new()
        {
            document.listFrm.action="businesstype.jsp";
            document.listFrm.target="_blank";
            document.listFrm.submit();
        }
        function f_delete()
        {
            var checked_counter = 0;
            var rownos = document.getElementsByName("rowno");
            for (var i = 0; i < rownos.length; i++)
            {
               if(rownos[i].checked)
               {
                   checked_counter++;
                   break;
               }
            }
            if(checked_counter==0)
            {
                alert("<%=bundle.getString("BUSINESSTYPEADMIN_HINT_NONE_SELECTED")%>");
                return false;
            }

            var r = confirm("<%=bundle.getString("BUSINESSTYPEADMIN_HINT_DELETE")%>");
            if(r==0) return;

            document.listFrm.act.value="del";
            document.listFrm.action="businesstypeadmin.jsp";
            document.listFrm.target="_self";
            document.listFrm.submit();
        }
        function f_deleteforce()
        {
            var checked_counter = 0;
            var rownos = document.getElementsByName("rowno");
            for (var i = 0; i < rownos.length; i++)
            {
               if(rownos[i].checked)
               {
                   checked_counter++;
                   break;
               }
            }
            if(checked_counter==0)
            {
                alert("<%=bundle.getString("BUSINESSTYPEADMIN_HINT_NONE_SELECTED")%>");
                return false;
            }

            var r = confirm("<%=bundle.getString("BUSINESSTYPEADMIN_HINT_DELETEFORCE")%>");
            if(r==0) return;

            document.listFrm.act.value="delforce";
            document.listFrm.action="businesstypeadmin.jsp";
            document.listFrm.target="_self";
            document.listFrm.submit();
        }
        function f_select()
        {
            var rownos = document.getElementsByName("rowno");
            for (var i = 0; i < rownos.length; i++)
            {
               rownos[i].checked = document.listFrm.AllId.checked;
            }
        }
    </script>
  </HEAD>

  <BODY leftMargin="20" topMargin = "0">
  <table width = "100% " border = "0" align = "center" cellpadding = "0" cellspacing = "0" class="positionbar">
    <tr>
      <td valign="middle">&nbsp;
        <input name="newBtn" type="button" onClick="f_new()" value="<%=bundle.getString("BUSINESSTYPEADMIN_BUTTON_NEW")%>" class="button">
        <input name="delBtn" type="button" onClick="f_delete()" value="<%=bundle.getString("BUSINESSTYPEADMIN_BUTTON_DEL")%>" class="button">
        <input name="delBtn" type="button" onClick="f_deleteforce()" value="<%=bundle.getString("BUSINESSTYPEADMIN_BUTTON_DELFORCE")%>" class="button">
      </td>
	</tr>
  </table>

  <table width = "100% " border = "0" align = "center" cellpadding = "0" cellspacing = "1" class="titlebar">
  <form name = "listFrm" method = "post">
     <input type="hidden" name="act" value="">
      <tr height=30>
	      <td width="25">
    		<input type = "checkBox" name = "AllId" value = "0" onclick = "f_select()">
		  </td>
          <td width = "60"><%=bundle.getString("BUSINESSTYPEADMIN_ID")%></td>
          <td width = "220"><%=bundle.getString("BUSINESSTYPEADMIN_NAME")%></td>
          <td width = "150" align="center" ><%=bundle.getString("BUSINESSTYPEADMIN_COMPANY")%></td>
          <td width = "150" align="center" ><%=bundle.getString("BUSINESSTYPEADMIN_PROCESS")%></td>
          <td width = "80" align="center" ><%=bundle.getString("BUSINESSTYPEADMIN_STATUS")%></td>
          <td width = "80" align="center" ><%=bundle.getString("BUSINESSTYPEADMIN_CREATOR")%></td>
          <td><%=bundle.getString("BUSINESSTYPEADMIN_CREATEDATE")%></td>
      </tr>
<%
    String sql = "SELECT a.*,b.name unit_name,c.name process_name FROM WF_BUSINESS_TYPE a,UNIT b, WF_Process c where a.unitid=b.id and a.process_id=c.id ";
    if(!user.IsSysAdmin()) sql += " and b.id=?";
    sql += "ORDER BY a.idx,a.create_date";

    pstmt = conn.prepareStatement(sql);
    if(!user.IsSysAdmin()) pstmt.setString(1,user.GetUnitId());
    rs = pstmt.executeQuery();
    while(rs.next())
    {
%>
          <tr height="25" class="detailbar">
            <td>
              <input type = "checkBox" id="rowno" name="rowno" value = "<%= rs.getRow() %>">
              <input type = "hidden" name = "type_id_<%= rs.getRow() %>" value = "<%= rs.getString("id") %>">
            </td>
            <td><%=rs.getString("id")%></td>
            <td>
              <a href="businesstype.jsp?id=<%= rs.getString("id") %>" target="_blank"><%= rs.getString("name") %></a>
            </td>
            <td align="center"><%=rs.getString("unit_name")%></td>  
            <td align="center">
              <a href="processinfo.jsp?id=<%=rs.getString("process_id")%>" target="_blank"><%=rs.getString("process_name")%></a>
            </td>
            <td align="center">
                <%
                    if(rs.getInt("state")==1)
                        out.print(bundle.getString("BUSINESSTYPEADMIN_STATUS_VALID"));
                    else
                        out.print("<font color=red>" + bundle.getString("BUSINESSTYPEADMIN_STATUS_INVALID") + "</font>");
                %>
            </td>
            <td align="center"><%=rs.getString("creator_name")%></td>
            <td><%=Utils.FormateDate(rs.getDate("create_date"),"yyyy-MM-dd")%></td>
          </tr>
<%
      }
%>
 </form>
 </table>
</body>
</html>
<%
    }
    catch(NpsException nps_e)
    {
        try{conn.rollback();}catch(Exception e1){}
    }
    finally
    {
        if(conn!=null) try{conn.close();}catch(Exception e){}
    }
%>