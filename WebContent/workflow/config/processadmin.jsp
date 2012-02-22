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
<%@ page import="nps.workflow.Engine" %>
<%@ page import="nps.workflow.WorkProcess" %>
<%@ page import="java.util.List" %>
<%@ page import="nps.workflow.WorkflowContext" %>

<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    String act = request.getParameter("act");
    if(act!=null)  act = act.trim();

    if(!(user.IsSysAdmin() || user.IsLocalAdmin())) throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

    ResourceBundle bundle = ResourceBundle.getBundle("langs.workflow_processadmin",user.GetLocale(), Config.RES_CLASSLOADER);

    if("del".equalsIgnoreCase(act))
    {
        //删除
        String[] rowno = request.getParameterValues("rowno");
        if(rowno!=null && rowno.length>0)
        {
            Connection conn = null;
            try
            {
                conn = Database.GetDatabase("nps").GetConnection();
                conn.setAutoCommit(false);

                for(int i=0;i<rowno.length;i++)
                {
                    String id = request.getParameter("process_id_" + rowno[i]);
                    WorkProcess process = Engine.GetInstance().GetProcess(id);
                    if(process==null) continue;
                    process.Remove(conn);
                }
                conn.commit();

                for(int i=0;i<rowno.length;i++)
                {
                    String id = request.getParameter("process_id_" + rowno[i]);
                    Engine.GetInstance().RemoveProcess(id);
                }

                out.println("<font color=red>" + bundle.getString("PROCESS_ADMIN_HINT_REMOVED")  + "</font>");
            }
            catch(NpsException nps_e)
            {
                try{conn.rollback();}catch(Exception e1){}
            }
            finally
            {
                if(conn!=null) try{conn.close();}catch(Exception e){}
            }
        }
    }
%>

<HTML>
  <HEAD>
    <TITLE><%=bundle.getString("PROCESSADMIN_HTMLTILE")%></TITLE>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>
    <script langauge = "javascript">
        function f_new()
        {
            document.listFrm.action="processinfo.jsp";
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
                alert("<%=bundle.getString("PROCESSADMIN_HINT_NONE_SELECTED")%>");
                return false;
            }

            var r = confirm("<%=bundle.getString("PROCESSADMIN_HINT_DELETE")%>");
            if(r==0) return;

            document.listFrm.act.value="del";
            document.listFrm.action="processadmin.jsp";
            document.listFrm.target="_self";
            document.listFrm.submit();
        }
        function selectProcess()
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
        <input name="newBtn" type="button" onClick="f_new()" value="<%=bundle.getString("PROCESSADMIN_BUTTON_NEW")%>" class="button">
        <input name="delBtn" type="button" onClick="f_delete()" value="<%=bundle.getString("PROCESSADMIN_BUTTON_DEL")%>" class="button">
      </td>
	</tr>
  </table>

  <table width = "100% " border = "0" align = "center" cellpadding = "0" cellspacing = "1" class="titlebar">
  <form name = "listFrm" method = "post">
     <input type="hidden" name="act" value="">
      <tr height=30>
	      <td width="25">
    		<input type = "checkBox" name = "AllId" value = "0" onclick = "selectProcess()">
		  </td>
          <td width = "120"><%=bundle.getString("PROCESSADMIN_NAME")%></td>
          <td width = "80" align="center" ><%=bundle.getString("PROCESSADMIN_STATUS")%></td>
          <td width = "80" align="center" ><%=bundle.getString("PROCESSADMIN_CREATOR")%></td>
          <td><%=bundle.getString("PROCESSADMIN_CREATEDATE")%></td>
      </tr>
<%
    List<WorkProcess> processes = null;
    if(user.IsSysAdmin())
    {
        processes = Engine.GetInstance().GetAllProcess();
    }
    else
    {
        processes = Engine.GetInstance().GetAllProcess(user.GetUnitId());
    }

    if(processes!=null && !processes.isEmpty())
    {
        int index = 0;
        for(WorkProcess process: processes)
        {
%>
	          <tr height="25" class="detailbar">
				<td>
                  <input type = "checkBox" id="rowno" name="rowno" value = "<%= ++index %>">
                  <input type = "hidden" name = "process_id_<%= index %>" value = "<%= process.GetId() %>">
				</td>
				<td>
                  <a href="processinfo.jsp?id=<%= process.GetId() %>" target="_blank"><%= process.GetName() %></a>
				</td>
                <td align="center">
                    <%
                        if(process.IsValid())
                            out.print(bundle.getString("PROCESSADMIN_STATUS_VALID"));
                        else
                            out.print("<font color=red>" + bundle.getString("PROCESSADMIN_STATUS_INVALID") + "</font>");
                    %>
                </td>
                <td align="center"><%=process.GetCreatorName()%></td>
                <td><%=Utils.FormateDate(process.GetCreateDate(),"yyyy-MM-dd")%></td>
              </tr>
 <%
         }
      }
 %>
 </form>
 </table>
</body>
</html>