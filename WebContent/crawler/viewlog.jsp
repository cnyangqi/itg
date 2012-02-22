<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.core.Config" %>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.job.crawler.Task" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="nps.job.crawler.PageFetchStatus" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.StringReader" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_crawltask_log",user.GetLocale(), Config.RES_CLASSLOADER);

    int rowperpage = 25;
    int currpage = 1, startnum = 0, endnum = 0, totalrows = 0, totalpages = 0, rownum=0;
    String scrollstr = "", nextpage = "viewlog.jsp";
    String currpg    = request.getParameter("page");
    try{ currpage = Integer.parseInt(currpg);	}catch (Exception e){currpage = 1;	}

    Connection con   = null;
    PreparedStatement pstmt   = null;
    ResultSet rs     = null;
    String sql 		 = null;

    String id = request.getParameter("id");
    if(id==null || id.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    scrollstr = "id="+id;

    String from_date = request.getParameter("from_date");
    if(from_date!=null && from_date.length()>0)
    {
        from_date = from_date.trim();
        scrollstr += "&from_date="+from_date;
    }

    String to_date = request.getParameter("to_date");
    if(to_date!=null && to_date.length()>0)
    {
        to_date = to_date.trim();
        scrollstr += "&to_date="+to_date;
    }

    String error_only = request.getParameter("error_only");
    if(error_only!=null && error_only.length()>0)
    {
        error_only = error_only.trim();
        scrollstr += "&error_only="+error_only;
    }

    Task task = null;
    try
    {
        //只能编辑自己管理的站点
        con = Database.GetDatabase("nps").GetConnection();
        task = Task.LoadTask(con,id);
        if(task==null) throw new NpsException(ErrorHelper.CRAWLER_NO_TASK,"id=" + id);
%>

<HTML>
	<HEAD>
		<TITLE><%=bundle.getString("LOG_HTMLTILE")%> - <%=task.GetName()%></TITLE>
        <LINK href="/css/style.css" rel = stylesheet>
        <script type="text/javascript" src="/jscript/calendar.js"></script>
	</HEAD>

  <BODY leftMargin="20" topMargin = "0">
  <table width = "100% " border = "0" align = "center" cellpadding = "0" cellspacing = "0" class="positionbar">
    <tr>
      <td valign="middle">&nbsp;
          <input type="button" name="qrybtn" value="<%=bundle.getString("LOG_BUTTON_QUERY")%>" class="button" onclick="javascript:document.searchFrm.submit();">
          <input type="button" name="closebtn" value="<%=bundle.getString("LOG_BUTTON_CLOSE")%>" class="button" onclick="javascript:window.close();">
      </td>
      <td align="right">
          <%=task.GetName()%>
          &nbsp;&nbsp;
      </td>
    </tr>
  </table>

  <table width = "100% " border = "0" align = "center" cellpadding = "0" cellspacing = "0" class="positionbar">
    <form name = "searchFrm" method = "post" action="viewlog.jsp">
       <input type="hidden" name="id" value="<%=id%>">
      <tr align="center">
          <td align="left">
              <%=bundle.getString("LOG_QUERY_DATE")%>
              <input type="text" id="from_date" name="from_date" style="width:80px" value="<%=Utils.Null2Empty(from_date)%>" onClick="getDateString(this,<% if("zh".equalsIgnoreCase(user.GetLocale().getLanguage())) out.print("oCalendarChs"); else out.print("oCalendarEn");%>)">
              - <input type="text" id="to_date" name="to_date" style="width:80px" value="<%=Utils.Null2Empty(to_date)%>" onClick="getDateString(this,<% if("zh".equalsIgnoreCase(user.GetLocale().getLanguage())) out.print("oCalendarChs"); else out.print("oCalendarEn");%>)">

              &nbsp;&nbsp;
              <input type="checkbox" name="error_only" value="1" <% if("1".equals(error_only)) out.print("checked"); %>>
              <%=bundle.getString("LOG_QUERY_ERROR_ONLY")%>
      </tr>
      </form>
  </table>

  <table width = "100% " border = "0" align = "center" cellpadding = "0" cellspacing = "1" class="titlebar">
      <tr height=30>
 	      <td width="300"><%=bundle.getString("LOG_URL")%></td>
          <td width = "120"><%=bundle.getString("LOG_DOWNLOAD")%></td>
          <td width = "120"><%=bundle.getString("LOG_LAST_MODIFIED")%></td>
          <td width = "80"><%=bundle.getString("LOG_LENGTH")%></td>
          <td width = "120"><%=bundle.getString("LOG_STATE")%></td>
          <td><%=bundle.getString("LOG_MSG")%></td>
      </tr>
<%
        sql = "select count(*) from ROBOT_RESULT Where task_id=?";
        if(from_date!=null && from_date.length()>0)
            sql += " and update_date>=to_date(?,'YYYY-MM-DD')";

        if(to_date!=null && to_date.length()>0)
            sql += " and update_date<=to_date(?,'YYYY-MM-DD')";

        if("1".equals(error_only))
            sql += " and status<>?";

        int index = 1;
        pstmt = con.prepareStatement(sql);
        pstmt.setString(index++,id);
        if(from_date!=null && from_date.length()>0) pstmt.setString(index++,from_date);
        if(to_date!=null && to_date.length()>0) pstmt.setString(index++,to_date);
        if("1".equals(error_only)) pstmt.setInt(index++,PageFetchStatus.OK);

        rs = pstmt.executeQuery();
        if (rs.next())  totalrows = rs.getInt(1);
        try{rs.close();}catch(Exception e){}
        try{pstmt.close();}catch(Exception e){}

        if (totalrows > 0)
        {
            totalpages = (int )((totalrows - 1) / rowperpage) + 1;
            startnum = rowperpage * (currpage - 1) + 1;
            endnum = currpage * rowperpage;

            sql = "select * from ROBOT_RESULT Where task_id=?";
            if(from_date!=null && from_date.length()>0)
                sql += " and update_date>=to_date(?,'YYYY-MM-DD')";

            if(to_date!=null && to_date.length()>0)
                sql += " and update_date<=to_date(?,'YYYY-MM-DD')";

            if("1".equals(error_only))
                sql += " and status<>?";

            sql += " order by update_date desc";
            
            index = 1;
            pstmt = con.prepareStatement(sql);
            pstmt.setString(index++,id);
            if(from_date!=null && from_date.length()>0) pstmt.setString(index++,from_date);
            if(to_date!=null && to_date.length()>0) pstmt.setString(index++,to_date);
            if("1".equals(error_only)) pstmt.setInt(index++,PageFetchStatus.OK);
            rs = pstmt.executeQuery();

            rownum = 0;
            while (rs.next() && (rs.getRow() <= endnum))
            {
                if (rs.getRow() < startnum) continue;
                int status = rs.getInt("status");
%>
	          <tr height="25" class="detailbar">
				<td align="left">
                    <%
                        if(status!=PageFetchStatus.OK) out.print("<font color=red>");
                        out.print(rs.getString("url"));
                        if(status!=PageFetchStatus.OK) out.print("</font>");
                    %>
                </td>
				<td align="center"><%=Utils.FormateDate(rs.getTimestamp("update_date"),"yyyy-MM-dd HH:mm:ss")%></td>
                <td align="center"><% if(rs.getTimestamp("last_modified")!=null) out.print(Utils.FormateDate(rs.getTimestamp("last_modified"),"yyyy-MM-dd HH:mm:ss")); %></td>
                <td align="center"><%=Utils.Null2Empty(rs.getString("content_length"))%></td>
                <td align="center"><%=PageFetchStatus.CodesToString(status)%></td>
                <td align="left">
                    <%
                        String msg = rs.getString("status_line");
                        if(status==PageFetchStatus.SQLError || status==PageFetchStatus.UnknownError)
                        {
                    %>
                        <textarea rows="5" cols="50"><%=msg%></textarea>
                    <%
                        }
                        else
                        {
                            out.println(msg);
                        }
                    %>

                </td>
              </tr>
          <%
              }
			}  //end of if (totalrows >0)
         %>
 </table>
<%@ include file = "/include/scrollpage.jsp" %>
</body>
</html>
<%
    }
    finally
    {
        if (pstmt != null) try{ pstmt.close();}catch(Exception e){}
        if (con != null)  try{ con.close(); }catch(Exception e){}
    }
%>