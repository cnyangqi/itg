<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.core.NpsWrapper" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.Config" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.processor.JobScheduler" %>
<%@ page import="org.quartz.Trigger" %>

<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    int rowperpage = 25;
    int currpage = 1, startnum = 0, endnum = 0, totalrows = 0, totalpages = 0, rownum=0;
    String scrollstr = "", nextpage = "tasks.jsp";
    String currpg    = request.getParameter("page");
    try{ currpage = Integer.parseInt(currpg);	}catch (Exception e){currpage = 1;	}
    String id = null;
    Connection con   = null;
    PreparedStatement pstmt   = null;
    ResultSet rs     = null;
    String sql 		 = null;

    String act = request.getParameter("act");
    if(act!=null)  act = act.trim();

    if(!(user.IsSysAdmin() || user.IsLocalAdmin()))
       throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_crawltasks",user.GetLocale(), Config.RES_CLASSLOADER);
%>

<HTML>
	<HEAD>
		<TITLE><%=bundle.getString("CRAWLTASKS_HTMLTILE")%></TITLE>
        <script type="text/javascript" src="/jscript/global.js"></script>
        <LINK href="/css/style.css" rel = stylesheet>
		<script langauge = "javascript">
			function f_new()
			{
				document.listFrm.action	= "task.jsp";
                document.listFrm.target="_blank";
                document.listFrm.submit();
            }

            function selectTask()
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
        <input name="newBtn" type="button" onClick="f_new()" value="<%=bundle.getString("CRAWLTASKS_BUTTON_NEW")%>" class="button">
      </td>
	</tr>
  </table>


  <table width = "100% " border = "0" align = "center" cellpadding = "0" cellspacing = "1" class="titlebar">
  <form name = "listFrm" method = "post">
     <input type="hidden" name="act" value="">
      <tr height=30>
	      <td width="25">
    		<input type = "checkBox" name = "AllId" value = "0" onclick = "selectTask()">
		  </td>
 	      <td><%=bundle.getString("CRAWLTASKS_NAME")%></td>
          <td width = "80"><%=bundle.getString("CRAWLTASKS_RUNAS")%></td>
          <td width = "120"><%=bundle.getString("CRAWLTASKS_SITE")%></td>
          <td width = "120"><%=bundle.getString("CRAWLTASKS_CRONEXP")%></td>
          <td width = "120"><%=bundle.getString("CRAWLTASKS_STATUS")%></td>
          <td width = "80"><%=bundle.getString("CRAWLTASKS_CREATOR")%></td>
          <td width = "80"><%=bundle.getString("CRAWLTASKS_CREATEDATE")%></td>
      </tr>
<%
    try
    {
        //只能编辑自己管理的站点
        con = Database.GetDatabase("nps").GetConnection();
        if(user.IsSysAdmin())
        {
            sql = "select count(*) from ROBOT_TASK";
        }
        else
        {
            sql = "select count(*) from ROBOT_TASK a Where a.creator=? OR a.siteid In (Select b.Id From site b Where b.unit=?)";
        }

        pstmt = con.prepareStatement(sql);
        if(!user.IsSysAdmin())
        {
            pstmt.setString(1,user.GetUID());
            pstmt.setString(2,user.GetUnitId());
        }

        rs = pstmt.executeQuery();
        if (rs.next())  totalrows = rs.getInt(1);
        try{rs.close();}catch(Exception e){}
        try{pstmt.close();}catch(Exception e){}

        if (totalrows > 0)
        {
            totalpages = (int )((totalrows - 1) / rowperpage) + 1;
            startnum = rowperpage * (currpage - 1) + 1;
            endnum = currpage * rowperpage;
            if(user.IsSysAdmin())
            {
                sql = "select id,name,job_id,job_cronexp,creator_name,create_date," +
                      "(select name from users d where d.id=a.run_as) runas," +
                      "(select name from site c where c.id=a.siteid) sitename" +
                      " from ROBOT_TASK a";
            }
            else
            {
                sql = "select id,name,job_id,job_cronexp,creator_name,create_date," +
                      "(select name from users d where d.id=a.run_as) runas," +
                      "(select name from site c where c.id=a.siteid) sitename" +
                      " from ROBOT_TASK a" +
                      "Where a.creator=? Or a.siteid In (Select b.Id From site b Where b.unit=?)";
            }

            pstmt = con.prepareStatement(sql);
            if(!user.IsSysAdmin())
            {
                pstmt.setString(1,user.GetUID());
                pstmt.setString(2,user.GetUnitId());
            }
            rs = pstmt.executeQuery();

            rownum = 0;
            while (rs.next() && (rs.getRow() <= endnum))
            {
                if (rs.getRow() < startnum) continue;

                String taskid = rs.getString("id");
%>
	          <tr height="25" class="detailbar">
				<td>
                  <input type = "checkBox" id="rowno" name="rowno" value = "<%= rs.getRow() %>">
                  <input type = "hidden" name = "taskid_<%= rs.getRow() %>" value = "<%= taskid %>">
				</td>
				<td>
                  <a href="task.jsp?id=<%=taskid%>" target="_blank"><%= rs.getString("name") %></a>
                   &nbsp;&nbsp;
                   <a href="viewlog.jsp?id=<%=taskid%>" target="_blank"><font color="red"><%=bundle.getString("CRAWLTASKS_VIEWLOG")%></font></a>
                </td>
                <td><%=rs.getString("runas")%></td>
                <td><%=rs.getString("sitename")%></td>
                <td><%=nps.util.Utils.Null2Empty(rs.getString("job_cronexp"))%></td>
                <td>
                   <%
                       int jobstatus = -1;
                       
                       String jobid = rs.getString("job_id");
                       if(jobid!=null && jobid.length()>0)
                           jobstatus = JobScheduler.GetStatus(jobid);

                       switch(jobstatus)
                       {
                           case Trigger.STATE_BLOCKED:
                               out.print(bundle.getString("CRAWLTASKS_HINT_STATUS_BLOCKED"));
                               break;
                           case Trigger.STATE_COMPLETE:
                               out.print(bundle.getString("CRAWLTASKS_HINT_STATUS_BLOCKED"));
                               break;
                           case Trigger.STATE_ERROR:
                               out.print(bundle.getString("CRAWLTASKS_HINT_STATUS_ERROR"));
                               break;
                           case Trigger.STATE_NONE:
                               out.print(bundle.getString("CRAWLTASKS_HINT_STATUS_NONE"));
                               break;
                           case Trigger.STATE_NORMAL:
                               out.print(bundle.getString("CRAWLTASKS_HINT_STATUS_NORMAL"));
                               break;
                           case Trigger.STATE_PAUSED:
                               out.print(bundle.getString("CRAWLTASKS_HINT_STATUS_PAUSED"));
                               break;
                           default:
                               out.print(bundle.getString("CRAWLTASKS_STATUS_NOT_SCHEDULED"));
                               break;
                       }
                        %>
                </td>
                <td><%=rs.getString("creator_name")%></td>
                <td><%=rs.getDate("create_date")%></td>
              </tr>
          <%
              }
			}  //end of if (totalrows >0)
    }
    finally
    {
        if (pstmt != null) try{ pstmt.close();}catch(Exception e){}
        if (con != null)  try{ con.close(); }catch(Exception e){}
    }
 %>
 </form>
 </table>
<%@ include file = "/include/scrollpage.jsp" %>
</body>
</html>