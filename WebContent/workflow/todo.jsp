<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.Config" %>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="nps.workflow.IApp" %>

<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.workflow_todo",user.GetLocale(), Config.RES_CLASSLOADER);
%>

<HTML>
  <HEAD>
    <TITLE><%=bundle.getString("TODO_HTMLTILE")%></TITLE>
    <meta http-equiv="refresh" content="300"/>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>
  </HEAD>

  <BODY leftMargin="20" topMargin = "0">
  <table width = "100% " border = "0" align = "center" cellpadding = "0" cellspacing = "1" class="titlebar">
  <form name = "listFrm" method = "post">
     <input type="hidden" name="act" value="">
      <tr height=30>
          <td width="60" align="center" ><%=bundle.getString("TODO_FROM")%></td>
          <td width=400 align="left"><%=bundle.getString("TODO_TITLE")%></td>
          <td width=80 align="center"><%=bundle.getString("TODO_APPROVER")%></td>
          <td width="120" align="center" ><%=bundle.getString("TODO_CREATEDATE")%></td>
      </tr>
<%
  Connection conn = null;
  PreparedStatement pstmt = null;
  ResultSet rs = null;
  try
  {
    conn = Database.GetDatabase("nps").GetConnection();
    String sql = "select b.name business_type_name,b.APPROVE_URL,a.*\n" +
        " from wf_todo a, WF_BUSINESS_TYPE b\n" +
        "  where a.status=1 and a.business_type=b.id\n" +
        "   and ( a.approver=? or exists(select * from WF_ATTORNEY z where z.to_userId=? and z.business_type=a.business_type and z.from_userid=a.approver and z.status=1 and z.valid_from<=sysdate and z.valid_to>=sysdate))\n" +
        " order by a.business_type,a.createdate desc ";

    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1,user.GetId());
    pstmt.setString(2,user.GetId());
    rs = pstmt.executeQuery();

    String business_type = null;
    while(rs.next())
    {
        if(business_type==null || !rs.getString("business_type_name").equals(business_type))
        {
            business_type = rs.getString("business_type_name");
%>
        <tr height="25" class="detailbar">
            <td colspan=4>&nbsp;<b><%=business_type%></b></td>
        </tr>
<%
        }
%>
          <tr height="25" class="detailbar">
            <td align="center"><%=rs.getString("creator_name")%></td>
            <td align="left">
              <%
                 switch(rs.getInt("emergency"))
                 {
                     case IApp.EMERGENCY_NORMAL:
                         break;
                     case IApp.EMERGENCY_HIGH:
                         out.print("<img src='/images/workflow/emergency_high.png'>");
                         break;
                     case IApp.EMERGENCY_URGENT:
                         out.print("<img src='/images/workflow/emergency_urgent.png'>");
                         break;
                 }
              %>
              <a href="<%=rs.getString("APPROVE_URL")%>?business_type=<%=rs.getString("business_type")%>&app_id=<%= rs.getString("app_id") %>&job_id=<%=rs.getString("job_id")%>" target="_blank">
                  <%= rs.getString("app_title") %>
              </a>
            </td>
            <td align=center>
                <%
                    if(rs.getString("approver").equals(user.GetId()))
                        out.print("&nbsp;");
                    else
                        out.print(rs.getString("approver_name"));
                %>
            </td>
            <td align="center"><%=Utils.FormateDate(rs.getDate("createdate"),"yyyy-MM-dd HH:mm:ss")%></td>
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
    finally
    {
        if(conn!=null) try{conn.close();}catch(Exception e){}
    }
%>