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
<%@ page import="nps.workflow.message.MessageTemplate" %>
<%@ page import="nps.BasicContext" %>

<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    String act = request.getParameter("act");
    if(act!=null)  act = act.trim();

    if(!(user.IsSysAdmin() || user.IsLocalAdmin())) throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

    ResourceBundle bundle = ResourceBundle.getBundle("langs.workflow_messagetemplateadmin",user.GetLocale(), Config.RES_CLASSLOADER);

    BasicContext ctxt = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    try
    {
        conn = Database.GetDatabase("nps").GetConnection();
        conn.setAutoCommit(false);
        ctxt = new BasicContext(conn, user);
        if("del".equalsIgnoreCase(act))
        {
            //删除
            String[] rowno = request.getParameterValues("rowno");
            if(rowno!=null && rowno.length>0)
            {
                for(int i=0;i<rowno.length;i++)
                {
                    String id = request.getParameter("template_id_"+ rowno[i]);
                    MessageTemplate template = MessageTemplate.GetTemplate(id);
                    if(template==null) continue;
                    template.Delete(ctxt);
                    out.println("<font color=red>" + template.GetSubject() + "   " + bundle.getString("MESSAGETEMPLATEADMIN_HINT_REMOVED") + "</font><br>");
                }
                ctxt.Commit();
            }
        }
%>

<HTML>
  <HEAD>
    <TITLE><%=bundle.getString("MESSAGETEMPLATEADMIN_HTMLTILE")%></TITLE>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>
    <script langauge = "javascript">
        function f_new()
        {
            document.listFrm.action="messagetemplate.jsp";
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
                alert("<%=bundle.getString("MESSAGETEMPLATEADMIN_HINT_NONE_SELECTED")%>");
                return false;
            }

            var r = confirm("<%=bundle.getString("MESSAGETEMPLATEADMIN_HINT_DELETE")%>");
            if(r==0) return;

            document.listFrm.act.value="del";
            document.listFrm.action="messagetemplateadmin.jsp";
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
        <input name="newBtn" type="button" onClick="f_new()" value="<%=bundle.getString("MESSAGETEMPLATEADMIN_BUTTON_NEW")%>" class="button">
        <input name="delBtn" type="button" onClick="f_delete()" value="<%=bundle.getString("MESSAGETEMPLATEADMIN_BUTTON_DEL")%>" class="button">
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
          <td width = "220"><%=bundle.getString("MESSAGETEMPLATEADMIN_SUBJECT")%></td>
          <td width = "80"  align="center"><%=bundle.getString("MESSAGETEMPLATEADMIN_TYPE")%></td>
          <td width = "200" align="center" ><%=bundle.getString("MESSAGETEMPLATEADMIN_STATUS")%></td>
          <td width = "150" align="center" ><%=bundle.getString("MESSAGETEMPLATEADMIN_CREATOR")%></td>
          <td align="center" ><%=bundle.getString("MESSAGETEMPLATEADMIN_CREATEDATE")%></td>
      </tr>
<%
    String sql = "SELECT id,message_type,job_status,subject,creator_name,createdate FROM WF_MSG_TEMPLATE where 1=1 ";
    if(!user.IsSysAdmin()) sql += " and (scope=0 or unitid=?)";

    pstmt = conn.prepareStatement(sql);
    if(!user.IsSysAdmin()) pstmt.setString(1,user.GetUnitId());
    rs = pstmt.executeQuery();
    while(rs.next())
    {
%>
          <tr height="25" class="detailbar">
            <td>
              <input type = "checkBox" id="rowno" name="rowno" value = "<%= rs.getRow() %>">
              <input type = "hidden" name = "template_id_<%= rs.getRow() %>" value = "<%= rs.getString("id") %>">
            </td>
            <td><a href="messagetemplate.jsp?id=<%= rs.getString("id") %>" target="_blank"><%=rs.getString("subject")%></a></td>
            <td align="center">
              <%
                  switch(rs.getInt("message_type"))
                  {
                      case MessageTemplate.MESSAGE_EMAIL:
                          out.print(bundle.getString("MESSAGETEMPLATEADMIN_TYPE_EMAIL"));
                          break;
                      case MessageTemplate.MESSAGE_SMS:
                          out.print(bundle.getString("MESSAGETEMPLATEADMIN_TYPE_SMS"));
                          break;
                  }
              %>
            </td>
            <td align="center">
                <%
                    switch(rs.getInt("job_status"))
                    {
                        case MessageTemplate.STATUS_PENDING:
                            out.print(bundle.getString("MESSAGETEMPLATEADMIN_STATUS_PENDING"));
                            break;
                        case MessageTemplate.STATUS_AGREED:
                            out.print(bundle.getString("MESSAGETEMPLATEADMIN_STATUS_AGREED"));
                            break;
                        case MessageTemplate.STATUS_REJECTED:
                            out.print(bundle.getString("MESSAGETEMPLATEADMIN_STATUS_REJECTED"));
                            break;
                        case MessageTemplate.STATUS_RETURNED:
                            out.print(bundle.getString("MESSAGETEMPLATEADMIN_STATUS_RETURNED"));
                            break;
                        case MessageTemplate.STATUS_FINISHED:
                            out.print(bundle.getString("MESSAGETEMPLATEADMIN_STATUS_FINISHED"));
                            break;
                        case MessageTemplate.STATUS_TERMINATED:
                            out.print(bundle.getString("MESSAGETEMPLATEADMIN_STATUS_TERMINATED"));
                            break;
                        case MessageTemplate.STATUS_REVOKED:
                            out.print(bundle.getString("MESSAGETEMPLATEADMIN_STATUS_REVOKED"));
                            break;
                        case MessageTemplate.STATUS_DELETED:
                            out.print(bundle.getString("MESSAGETEMPLATEADMIN_STATUS_DELETED"));
                            break;
                    }
                %>
            </td>
            <td align="center"><%=rs.getString("creator_name")%></td>
            <td align="center"><%=Utils.FormateDate(rs.getDate("createdate"),"yyyy-MM-dd")%></td>
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
        if(ctxt!=null) ctxt.Rollback();
        throw nps_e;
    }
    finally
    {
        if(ctxt!=null) ctxt.Clear();
    }
%>