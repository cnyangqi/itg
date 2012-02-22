<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.core.Config" %>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.ResourceBundle" %>

<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    int rowperpage = 20;
    int currpage = 1, startnum = 0, endnum = 0, totalrows = 0, totalpages = 0, rownum=0;
    String scrollstr = "", nextpage = "bulletin_board.jsp.jsp";
    String currpg    = request.getParameter("page");
    try{ currpage = Integer.parseInt(currpg);	}catch (Exception e){currpage = 1;	}

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_bulletin_board",user.GetLocale(), Config.RES_CLASSLOADER);
    
    Connection con   = null;
    PreparedStatement pstmt   = null;
    ResultSet rs     = null;
    String sql 		 = null;
%>

<HTML>
	<HEAD>
		<TITLE><%=bundle.getString("BULLETINLIST_HTMLTITLE")%></TITLE>
        <script type="text/javascript" src="/jscript/global.js"></script>
        <LINK href="/css/style.css" rel = stylesheet>
        <script type="text/javascript">
            function new_bulletin()
            {
                document.frm_bulletin.action="edit.jsp";
                document.frm_bulletin.target="_blank";
                document.frm_bulletin.submit();
            }
        </script>
    </HEAD>

  <BODY leftMargin="20" topMargin = "10">
  <table width = "100% " border = "0" align = "center" cellpadding = "0" cellspacing = "0" class="positionbar">
  <tr>
      <td>&nbsp;
          <input type="button" name="btn_new" value="<%=bundle.getString("BULLETINLIST_BUTTON_NEW")%>" onclick="javascript:new_bulletin()" class="button">
      </td>
      <td align="right">
          <%=bundle.getString("BULLETINLIST_HTMLTITLE")%>&nbsp;&nbsp;&nbsp;&nbsp;
      </td>
    </tr>
  </table>

  <table width = "100% " border = "0" align = "center" cellpadding = "0" cellspacing = "1" class="titlebar">
      <tr height=30>
          <td width="20"></td>
          <td width="350"><%=bundle.getString("BULLETINLIST_TITLE")%></td>
          <td width="80" align="center"><%=bundle.getString("BULLETINLIST_CREATOR")%></td>
          <td width="160" align="center"><%=bundle.getString("BULLETINLIST_PUBLISHDATE")%></td>
      </tr>
<%
    try
    {
        con = Database.GetDatabase("nps").GetConnection();

        sql = "Select count(*) From bulletin a, users b";
        String where = " Where a.creator=b.id";
        if(!user.IsSysAdmin())
        {
            where += " and (a.visibility=0 \n" +
                    " Or (a.visibility=1 And Exists (Select * From dept c Where b.dept=c.Id And c.unit=?))\n" +
                    " Or (a.visibility=2 And b.dept=?))";
        }

        pstmt = con.prepareStatement(sql+where);
        if(!user.IsSysAdmin())
        {
            pstmt.setString(1,user.GetUnitId());
            pstmt.setString(2,user.GetDeptId());
        }
        
        rs = pstmt.executeQuery();

        //query search now
        if (rs.next())  totalrows = rs.getInt(1);
        try{rs.close();}catch(Exception e){}
        try{pstmt.close();}catch(Exception e){}

        int i = 1;
        if (totalrows > 0)
        {
            totalpages = (int)((totalrows - 1) / rowperpage) + 1;
            startnum = rowperpage * (currpage - 1) + 1;
            endnum = currpage * rowperpage;

            sql = "select a.id,a.title,a.publishdate,b.name,a.creator from bulletin a,users b";
            String orderby = " order by publishdate desc";

            pstmt = con.prepareStatement(sql+where+orderby);
            if(!user.IsSysAdmin())
            {
                pstmt.setString(1,user.GetUnitId());
                pstmt.setString(2,user.GetDeptId());
            }
            rs = pstmt.executeQuery();

            while(rs.next() && (rs.getRow() <= endnum))
            {
                if (rs.getRow() < startnum) continue;
%>
              <tr  class="detailbar" height="25">
                  <td align="center"><%=i++%></td>
                  <td>
                      <%
                          if(user.GetId().equals(rs.getString("creator")))
                          {
                      %>
                      <a href="edit.jsp?id=<%=rs.getString("id")%>" target="_blank">
                      <%
                          }
                          else
                          {
                      %>
                      <a href="view.jsp?id=<%=rs.getString("id")%>" target="_blank">
                      <%
                           }
                      %>
                      <%=rs.getString("title")%>
                      </a>
                  </td>
                  <td align="center"><%=Utils.Null2Empty(rs.getString("name"))%></td>
                  <td align="center"><%=Utils.FormateDate(rs.getTimestamp("publishdate"),"yyyy-MM-dd HH:mm:ss")%></td>
             </tr>
<%
            }
       }  //end of if (totalrows >0)
    }
    finally
    {
        if (rs != null) try{ rs.close();}catch(Exception e){}
        if (pstmt != null) try{ pstmt.close();}catch(Exception e){}
        if (con != null)  try{ con.close(); }catch(Exception e){}
    }
 %>
 </table>
<%@ include file = "/include/scrollpage.jsp" %>

<form name="frm_bulletin" action="edit.jsp" method="post" target="_blank">
</form>
</body>
</html>