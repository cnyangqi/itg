<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.core.NpsWrapper" %>
<%@ page import="nps.core.TemplateBase" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.Config" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    int rowperpage = 25;
    int currpage = 1, startnum = 0, endnum = 0, totalrows = 0, totalpages = 0, rownum=0;
    String scrollstr = "", nextpage = "rolelist.jsp";
    String currpg    = request.getParameter("page");
    try{ currpage = Integer.parseInt(currpg);	}catch (Exception e){currpage = 1;	}
    String id = null;
    Connection con   = null;
    PreparedStatement pstmt   = null;
    ResultSet rs     = null;
    String sql 		 = null;

    String act = request.getParameter("act");
    if(act!=null)  act = act.trim();

    if(!user.IsSysAdmin()) throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_rolelist",user.GetLocale(), Config.RES_CLASSLOADER);
    NpsWrapper wrapper = null;
%>

<HTML>
	<HEAD>
		<TITLE><%=bundle.getString("ROLELIST_HTMLTILE")%></TITLE>
        <script type="text/javascript" src="/jscript/global.js"></script>
        <LINK href="/css/style.css" rel = stylesheet>
		<script langauge = "javascript">
			function f_new()
			{
				document.listFrm.action	= "roleinfo.jsp";
                document.listFrm.target="_blank";
                document.listFrm.submit();
            }

            function openRole(idvalue)
            {
                document.frmOpen.id.value = idvalue;
                document.frmOpen.submit();
            }

            function selectRole()
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
        <input name="newBtn" type="button" onClick="f_new()" value="<%=bundle.getString("ROLELIST_BUTTON_NEW")%>" class="button">
      </td>
	</tr>
  </table>


  <table width = "100% " border = "0" align = "center" cellpadding = "0" cellspacing = "1" class="titlebar">
  <form name = "listFrm" method = "post">
     <input type="hidden" name="act" value="">
      <tr height=30>
	      <td width="25">
    		<input type = "checkBox" name = "AllId" value = "0" onclick = "selectRole()">
		  </td>
          <td><%=bundle.getString("ROLELIST_ID")%></td>
          <td><%=bundle.getString("ROLELIST_DOMAIN")%></td>
          <td><%=bundle.getString("ROLELIST_NAME")%></td>
          <td><%=bundle.getString("ROLELIST_DESC")%></td>
      </tr>
<%
    try
    {
        con = Database.GetDatabase("nps").GetConnection();
        sql = "select count(*) from role";
        pstmt = con.prepareStatement(sql);
        rs = pstmt.executeQuery();
        if (rs.next())  totalrows = rs.getInt(1);
        try{rs.close();}catch(Exception e){}
        try{pstmt.close();}catch(Exception e){}

        if (totalrows > 0)
        {
            totalpages = (int )((totalrows - 1) / rowperpage) + 1;
            startnum = rowperpage * (currpage - 1) + 1;
            endnum = currpage * rowperpage;
            sql = "select * from role";
            pstmt = con.prepareStatement(sql);
            rs = pstmt.executeQuery();

            String roleId = null;
            rownum = 0;
            while (rs.next() && (rs.getRow() <= endnum))
            {
                if (rs.getRow() < startnum) continue;

                roleId = rs.getString("id");
%>
	          <tr class="detailbar" height="25">
				<td>
                  <input type = "checkBox" id="rowno" name="rowno" value = "<%= rs.getRow() %>">
                  <input type = "hidden" name = "role_id_<%= rs.getRow() %>" value = "<%= roleId %>">
				</td>
                <td width="80"><%= roleId %></td>
                <td width="120"><a href="javascript:openRole('<%= roleId %>');"><%= rs.getString("domain")==null?"default":rs.getString("domain") %></a></td>
                <td width="120">
                  <a href="javascript:openRole('<%= roleId %>');"><%= rs.getString("name") %></a>
				</td>
				<td>&nbsp;<%=Utils.Null2Empty(rs.getString("memo"))%></td>
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
<form name=frmOpen action="roleinfo.jsp" target="_blank">
  <input type = "hidden" name = "id">
</form>
<%@ include file = "/include/scrollpage.jsp" %>
</body>
</html>