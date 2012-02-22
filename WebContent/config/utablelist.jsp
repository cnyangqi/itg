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
    String scrollstr = "", nextpage = "utablelist.jsp";
    String currpg    = request.getParameter("page");
    try{ currpage = Integer.parseInt(currpg);	}catch (Exception e){currpage = 1;	}
    String id = null;
    Connection con   = null;
    PreparedStatement pstmt   = null;
    ResultSet rs     = null;
    String sql 		 = null;

    String act = request.getParameter("act");
    if(act!=null)  act = act.trim();

    String site = request.getParameter("site");
    if(site!=null)
    {
        site = site.trim();
        if(site.length()==0) site = null;
    }

    String table_name = request.getParameter("table_name");
    if(table_name!=null)
    {
        table_name = table_name.trim();
        if(table_name.length()==0) table_name = null;
    }

    if(site!=null)
    {
        if(scrollstr.length()>0)
           scrollstr += "&site="+site;
        else
           scrollstr += "site="+site;
    }

    if(table_name!=null)
    {
        if(scrollstr.length()>0)
           scrollstr += "&table_name="+table_name;
        else
           scrollstr += "table_name="+table_name;
    }

    if(!user.IsSysAdmin()) throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_utablelist",user.GetLocale(), Config.RES_CLASSLOADER);

   if("delete".equalsIgnoreCase(act))
   {
        String[] rownos = request.getParameterValues("rowno");
        if(rownos!=null && rownos.length>0)
        {
            try
            {
                con = Database.GetDatabase("nps").GetConnection();
                con.setAutoCommit(false);
                
                sql = "delete from config_backup where siteid=? and table_name=?";
                pstmt = con.prepareStatement(sql);
                for(int i=0;i<rownos.length;i++)
                {
                    String site_id = request.getParameter("site_" + rownos[i]);
                    String table = request.getParameter("table_"+ rownos[i]);

                    pstmt.setString(1,site_id);
                    pstmt.setString(2,table);
                    pstmt.executeUpdate();
                }

                con.commit();
            }
            catch(Exception e)
            {
                try{con.rollback();}catch(Exception e1){}
                throw e;
            }
            finally
            {
                if(pstmt!=null) try{pstmt.close();}catch(Exception e){}
            }
        }
   }
%>

<HTML>
	<HEAD>
		<TITLE><%=bundle.getString("UTABLELIST_HTMLTILE")%></TITLE>
        <script type="text/javascript" src="/jscript/global.js"></script>
        <LINK href="/css/style.css" rel = stylesheet>
		<script langauge = "javascript">
			function f_new()
			{
				document.listFrm.action	= "utable.jsp";
                document.listFrm.target="_blank";
                document.listFrm.submit();
            }

            function f_search()
            {
                document.searchFrm.submit();
            }

            function f_delete()
            {
                document.listFrm.action = "utablelist.jsp";
                document.listFrm.act.value = "delete";
                document.listFrm.target ="_self";
                document.listFrm.submit();
            }

            function openTable(site,table)
            {
                document.frmOpen.site.value = site;
                document.frmOpen.table.value = table;
                document.frmOpen.submit();
            }

            function selectTable()
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
        <input name="newBtn" type="button" onClick="f_new()" value="<%=bundle.getString("UTABLELIST_BUTTON_NEW")%>" class="button">
        <input name="searchBtn" type="button" onClick="f_search()" value="<%=bundle.getString("UTABLELIST_BUTTON_SEARCH")%>" class="button">
        <input name="delBtn" type="button" onclick="f_delete()" value="<%=bundle.getString("UTABLELIST_BUTTON_DELETE")%>" class="button">
      </td>
	</tr>
  </table>

  <table width = "100% " border = "0" align = "center" cellpadding = "0" cellspacing = "0" class="positionbar">
    <form name = "searchFrm" method = "post" action="utablelist.jsp">
      <tr align="center">
          <td width="80"><%=bundle.getString("UTABLELIST_SITE")%></td>
          <td width=120 align="left">
              <select name="site">
                  <option value=""></option>
    <%
        java.util.Hashtable sites = user.GetOwnSites();
        //key:id value:caption
        if((sites!=null) && !sites.isEmpty())
        {
           int i=0;
           java.util.Enumeration sitekeys = sites.keys();
           while(sitekeys.hasMoreElements())
           {
             String site_id = (String)sitekeys.nextElement();
             String site_caption = (String)sites.get(site_id);
    %>
                  <option value="<%=site_id%>" <% if(site_id.equals(site)) out.print("selected");%>><%=site_caption%></option>
        <%
               i++;
             }//while(sitekeys.hasMoreElements())
           }//if((sites!=null) && !sites.isEmpty())
        %>
              </select>
          </td>
          <td width="80"><%=bundle.getString("UTABLELIST_TABLE")%></td>
          <td width=120  align="left">
              <input type="text" name="table_name" value="<%=Utils.Null2Empty(table_name)%>">
          </td>
          <td>&nbsp;</td>
      </tr>
      </form>
  </table>


  <table width = "100%" border = "0" align = "center" cellpadding = "0" cellspacing = "1" class="titlebar">
  <form name = "listFrm" method = "post">
     <input type="hidden" name="act" value="">
      <tr height=30>
	      <td width="25">
    		<input type = "checkBox" name = "AllId" value = "0" onclick = "selectTable()">
		  </td>
 	      <td width="80"><%=bundle.getString("UTABLELIST_SITE")%></td>
		  <td width = "120"><%=bundle.getString("UTABLELIST_TABLE")%></td>
          <td><%=bundle.getString("UTABLELIST_SQL")%></td>
      </tr>
<%
    try
    {
        if(con==null) con = Database.GetDatabase("nps").GetConnection();
        sql = "select count(*) from config_backup where 1=1";

        if(site!=null) sql += " and siteid=?";
        if(table_name!=null)  sql += " and table_name=?";

        pstmt = con.prepareStatement(sql);
        int j=1;
        if(site!=null) pstmt.setString(j++,site);
        if(table_name!=null) pstmt.setString(j++,table_name);

        rs = pstmt.executeQuery();
        if (rs.next())  totalrows = rs.getInt(1);
        try{rs.close();}catch(Exception e){}
        try{pstmt.close();}catch(Exception e){}

        if (totalrows > 0)
        {
            totalpages = (int )((totalrows - 1) / rowperpage) + 1;
            startnum = rowperpage * (currpage - 1) + 1;
            endnum = currpage * rowperpage;

            sql = "select * from config_backup a where 1=1";

            if(site!=null) sql += " and siteid=?";
            if(table_name!=null)  sql += " and table_name=?";

            pstmt = con.prepareStatement(sql);

            j=1;
            if(site!=null) pstmt.setString(j++,site);
            if(table_name!=null) pstmt.setString(j++,table_name);

            rs = pstmt.executeQuery();

            rownum = 0;
            while (rs.next() && (rs.getRow() <= endnum))
            {
                if (rs.getRow() < startnum) continue;

%>
	          <tr class="detailbar" height="30">
				<td>
                  <input type = "checkBox" id="rowno" name="rowno" value = "<%= rs.getRow() %>">
                  <input type = "hidden" name = "site_<%= rs.getRow() %>" value = "<%= rs.getString("siteid") %>">
                  <input type = "hidden" name = "table_<%= rs.getRow() %>" value = "<%= rs.getString("table_name") %>">  
                </td>
				<td>
                  <a href="javascript:openTable('<%= rs.getString("siteid") %>','<%=rs.getString("table_name")%>');"><%= rs.getString("siteid") %></a>
				</td>
				<td>
                    <%=rs.getString("table_name")%>
                </td>
				<td>
                    <%=rs.getString("sql")%>
                </td>
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
<form name=frmOpen action="utable.jsp" target="_blank">
  <input type = "hidden" name = "site" value="">
  <input type = "hidden" name = "table" value="">  
</form>
<%@ include file = "/include/scrollpage.jsp" %>
</body>
</html>