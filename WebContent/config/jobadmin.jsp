<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.core.NpsWrapper" %>
<%@ page import="nps.util.Utils" %>
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
    String scrollstr = "", nextpage = "jobadmin.jsp";
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

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_jobadmin",user.GetLocale(), Config.RES_CLASSLOADER);
    NpsWrapper wrapper = null;

    if("1".equals(act))
    {
        //resumeall
        if(user.IsSysAdmin())
        {
            JobScheduler.ResumeAll();
        }
    }
    else if("2".equals(act))
    {
        //pauseall
        if(user.IsSysAdmin())
        {
            JobScheduler.PauseAll();
        }
    }
%>

<HTML>
	<HEAD>
		<TITLE><%=bundle.getString("JOBADMIN_HTMLTILE")%></TITLE>
        <script type="text/javascript" src="/jscript/global.js"></script>
        <LINK href="/css/style.css" rel = stylesheet>
		<script langauge = "javascript">
			function f_new()
			{
				document.listFrm.action	= "jobinfo.jsp";
                document.listFrm.target="_blank";
                document.listFrm.submit();
            }

            function f_resumeall()
            {
                document.listFrm.action	= "jobadmin.jsp";
                document.listFrm.target= "_self";
                document.listFrm.act.value = "1";
                document.listFrm.submit();
            }

            function f_pauseall()
            {
                document.listFrm.action	= "jobadmin.jsp";
                document.listFrm.target= "_self";
                document.listFrm.act.value = "2";
                document.listFrm.submit();
            }
            
            function openJob(idvalue)
            {
                document.frmOpen.id.value = idvalue;
                document.frmOpen.submit();
            }

            function selectJob()
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
        <input name="newBtn" type="button" onClick="f_new()" value="<%=bundle.getString("JOBADMIN_BUTTON_NEW")%>" class="button">
<%
    if(user.IsSysAdmin())
    {
%>
        <input name="resumeallBtn" type="button" onClick="f_resumeall()" value="<%=bundle.getString("JOBADMIN_BUTTON_RESUMEALL")%>" class="button">
        <input name="pauseallBtn" type="button" onClick="f_pauseall()" value="<%=bundle.getString("JOBADMIN_BUTTON_PAUSEALL")%>" class="button">
<%
    }
%>
      </td>
	</tr>
  </table>


  <table width = "100% " border = "0" align = "center" cellpadding = "0" cellspacing = "1" class="titlebar">
  <form name = "listFrm" method = "post">
     <input type="hidden" name="act" value="">
      <tr height=30>
	      <td width="25">
    		<input type = "checkBox" name = "AllId" value = "0" onclick = "selectJob()">
		  </td>
 	      <td width = "120"><%=bundle.getString("JOBADMIN_NAME")%></td>
          <td width = "80"><%=bundle.getString("JOBADMIN_RUNAS")%></td>
          <td width = "120"><%=bundle.getString("JOBADMIN_SITE")%></td>
          <td width = "120"><%=bundle.getString("JOBADMIN_CRONEXP")%></td>
          <td width = "120"><%=bundle.getString("JOBADMIN_STATUS")%></td>
          <td width = "120"><%=bundle.getString("JOBADMIN_LASTRUN_STATE")%></td>
          <td width = "80"><%=bundle.getString("JOBADMIN_CREATOR")%></td>
          <td width = "80"><%=bundle.getString("JOBADMIN_CREATEDATE")%></td>
      </tr>                   
<%
    try
    {
        //只能编辑自己管理的站点
        con = Database.GetDatabase("nps").GetConnection();
        if(user.IsSysAdmin())
        {
            sql = "select count(*) from job";
        }
        else
        {
            sql = "select count(*) from job a Where a.creator=? Or a.site In (Select b.Id From site b Where b.unit=?)";
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
                sql = "select id,name,enabled,cronexp,lastrunstate,servername,lastrundate,lastruntime,"+
                      "(select name from users d where d.id=a.runas) runas,"+
                      "(select name from site c where c.id=a.site) sitename,"+
                      "(select name from users b where b.id=a.creator) creator,"+
                      "createdate from job a";
            }
            else
            {
                sql = "select id,name,enabled,cronexp,lastrunstate,servername,lastrundate,lastruntime,"+
                      "(select name from users d where d.id=a.runas) runas,"+
                      "(select name from site c where c.id=a.site) sitename,"+
                      "(select name from users b where b.id=a.creator) creator,"+
                      "createdate from job a " +
                      "Where a.creator=? Or a.site In (Select b.Id From site b Where b.unit=?)";
            }

            pstmt = con.prepareStatement(sql);
            if(!user.IsSysAdmin())
            {
                pstmt.setString(1,user.GetUID());
                pstmt.setString(2,user.GetUnitId());
            }
            rs = pstmt.executeQuery();

            String jobId = null;
            rownum = 0;
            int jobstatus = -1;
            while (rs.next() && (rs.getRow() <= endnum))
            {
                if (rs.getRow() < startnum) continue;

                jobId = rs.getString("id");
                jobstatus = JobScheduler.GetStatus(jobId);
%>
	          <tr class="detailbar">
				<td>
                  <input type = "checkBox" id="rowno" name="rowno" value = "<%= rs.getRow() %>">
                  <input type = "hidden" name = "job_id_<%= rs.getRow() %>" value = "<%= jobId %>">
				</td>
				<td>
                  <a href="javascript:openJob('<%= jobId %>');"><%= rs.getString("name") %></a>
				</td>
                <td><%=rs.getString("runas")%></td>
                <td><%=rs.getString("sitename")%></td>
                <td><%=rs.getString("cronexp")%></td>  
                <td>
                    <%
                        if(rs.getInt("enabled")==1)
                            out.print(bundle.getString("JOBADMIN_STATUS_ENABLED"));
                        else
                            out.print(bundle.getString("JOBADMIN_STATUS_DISABLED"));
                        out.print("&nbsp;&nbsp;");
                        
                       switch(jobstatus)
                       {
                           case Trigger.STATE_BLOCKED:
                               out.print(bundle.getString("JOBADMIN_HINT_STATUS_BLOCKED"));
                               break;
                           case Trigger.STATE_COMPLETE:
                               out.print(bundle.getString("JOBADMIN_HINT_STATUS_BLOCKED"));
                               break;
                           case Trigger.STATE_ERROR:
                               out.print(bundle.getString("JOBADMIN_HINT_STATUS_ERROR"));
                               break;
                           case Trigger.STATE_NONE:
                               out.print(bundle.getString("JOBADMIN_HINT_STATUS_NONE"));
                               break;
                           case Trigger.STATE_NORMAL:
                               out.print(bundle.getString("JOBADMIN_HINT_STATUS_NORMAL"));
                               break;
                           case Trigger.STATE_PAUSED:
                               out.print(bundle.getString("JOBADMIN_HINT_STATUS_PAUSED"));
                               break;
                       }
                        %>
                </td>
                <td>
                    <%
                    switch(rs.getInt("lastrunstate"))
                    {
                      case 0:
                          out.print(bundle.getString("JOBADMIN_LASTRUN_STATUS_NORMAL"));
                          break;
                      case 1:
                          out.print(bundle.getString("JOBADMIN_LASTRUN_STATUS_ERROR"));
                          break;
                    }
                    %>
                </td>
                <td><%=rs.getString("creator")%></td>
                <td><%=rs.getDate("createdate")%></td>
              </tr>
          <%
              }
			}  //end of if (totalrows >0)
    }
    catch (Exception ee)
    {
         throw ee;
    }
    finally
    {
        if (pstmt != null) try{ pstmt.close();}catch(Exception e){}
        if (con != null)  try{ con.close(); }catch(Exception e){}
    }
 %>
 </form>
 </table>
<form name=frmOpen action="jobinfo.jsp" target="_blank">
  <input type = "hidden" name = "id">
</form>
<%@ include file = "/include/scrollpage.jsp" %>
</body>
</html>