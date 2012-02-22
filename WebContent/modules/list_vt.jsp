<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="nps.core.Config" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.net.URLEncoder" %>

<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    int rowperpage = 25;
    int currpage = 1, startnum = 0, endnum = 0, totalrows = 0, totalpages = 0, rownum=0;
    String scrollstr = "", nextpage = "list_vt.jsp";
    String currpg    = request.getParameter("page");
    try{ currpage = Integer.parseInt(currpg);	}catch (Exception e){currpage = 1;	}
    String id = null;
    Connection con   = null;
    PreparedStatement pstmt   = null;
    ResultSet rs     = null;
    String sql 		 = null;

    String act = request.getParameter("act");
    if(act!=null)  act = act.trim();

    String template_name = request.getParameter("template_name");
    if(template_name!=null)
    {
        template_name = template_name.trim();
        if(template_name.length()==0) template_name = null;
        if(template_name!=null && !template_name.endsWith("%")) template_name = template_name + "%";
    }
    
    if(template_name!=null)
    {
        if(scrollstr.length()>0)
           scrollstr += "&template_name=" + URLEncoder.encode(template_name,"UTF-8");
        else
           scrollstr += "template_name="+ URLEncoder.encode(template_name,"UTF-8");
    }

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_vtlist",user.GetLocale(), Config.RES_CLASSLOADER);
%>

<HTML>
	<HEAD>
		<TITLE><%=bundle.getString("VTLIST_HTMLTILE")%></TITLE>
        <script type="text/javascript" src="/jscript/global.js"></script>
        <LINK href="/css/style.css" rel = stylesheet>        
		<script langauge = "javascript">
            function shownewdiv()
            {
                document.getElementById("newvt").style.display = "block";
            }

            function f_new()
			{
                if(document.newFrm.vt_title.value=="")
                {
                    alert("<%=bundle.getString("VTLIST_NOTITLE_HINT")%>");
                    return false;
                }
                document.getElementById("newvt").style.display = "none";
                document.newFrm.submit();
            }

            function f_search()
            {
                document.searchFrm.submit();
            }
            
            function openTemplate(idvalue)
            {
                document.frmOpen.id.value = idvalue;
                document.frmOpen.submit();
            }

            function selectTemplate()
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
        <input name="newBtn" type="button" onClick="shownewdiv()" value="<%=bundle.getString("VTLIST_BUTTON_NEW")%>" class="button">
        <input name="searchBtn" type="button" onClick="f_search()" value="<%=bundle.getString("VTLIST_BUTTON_SEARCH")%>" class="button">          
      </td>
	</tr>
  </table> 

  <div id="newvt" style="display:none">
     <form name="newFrm" action="new_vt.jsp" method="post" target="_blank">
          &nbsp;&nbsp;<%=bundle.getString("VTLIST_TITLE_HINT")%>
          <input type="text" name="vt_title" value="" size="50">
          <input type="button" name="continueBtn" onClick="f_new()" value="<%=bundle.getString("VTLIST_BUTTON_CONTINUE")%>" class="button">
      </form>   
  </div>

  <table width = "100% " border = "0" align = "center" cellpadding = "0" cellspacing = "0" class="positionbar">
    <form name = "searchFrm" method = "post" action="list_vt.jsp">
      <tr align="center">
          <td width="80"><%=bundle.getString("VTLIST_NAME")%></td>
          <td width=120  align="left">
              <input type="text" name="template_name" value="<%=Utils.Null2Empty(template_name)%>">
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
    		<input type = "checkBox" name = "AllId" value = "0" onclick = "selectTemplate()">
		  </td>
 	      <td><%=bundle.getString("VTLIST_NAME")%></td>
          <td width = "120"><%=bundle.getString("VTLIST_CREATOR")%></td>
          <td width = "120"><%=bundle.getString("VTLIST_CREATEDATE")%></td>
      </tr>
<%
    try
    {
        //只能编辑本单位的模板
        con = Database.GetDatabase("nps").GetConnection();
        if(user.IsSysAdmin())
        {
            sql = "select count(*) from visual_template a where 1=1";
        }
        else
        {
            sql = "select count(*) from visual_template a where (a.creator=? "
                + " or exists(Select b.Id From users b,dept c Where b.Id=a.creator And b.dept=c.Id And c.unit=?))";
        }

        if(template_name!=null)
        {
            sql += " and title like ?";
        }

        pstmt = con.prepareStatement(sql);
        int j=1;
        if(!user.IsSysAdmin()) pstmt.setString(j++,user.GetUnitId());
        if(template_name!=null) pstmt.setString(j++,template_name);
        
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
                sql = "select * from visual_template a where 1=1";
            }
            else
            {
                sql = "select * from visual_template a where (a.creator=? "
                    + " or exists(Select b.Id From users b,dept c Where b.Id=a.creator And b.dept=c.Id And c.unit=?))";
            }

            if(template_name!=null) sql += " and name like ?";

            pstmt = con.prepareStatement(sql);

            j=1;
            if(!user.IsSysAdmin()) pstmt.setString(j++,user.GetUnitId());
            if(template_name!=null) pstmt.setString(j++,template_name);
            rs = pstmt.executeQuery();

            String templateId = null;
            rownum = 0;
            while (rs.next() && (rs.getRow() <= endnum))
            {
                if (rs.getRow() < startnum) continue;

                templateId = rs.getString("id");
%>
	          <tr class="detailbar" height="25">
				<td> 
                  <input type = "checkBox" id="rowno" name="rowno" value = "<%= rs.getRow() %>"> 
                  <input type = "hidden" name = "template_id_<%= rs.getRow() %>" value = "<%= templateId %>"> 
				</td>
				<td>
                  <a href="javascript:openTemplate('<%= templateId %>');"><%= rs.getString("title") %></a>
				</td>				
                <td>
                   <%= rs.getString("creator_name")==null?"&nbsp;":rs.getString("creator_name") %>
                </td>
                <td>
	      		   <%= Utils.FormateDate(rs.getDate("createdate"),"yyyy-MM-dd") %>
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
<form name=frmOpen action="visual_template.jsp" target="_blank">
  <input type = "hidden" name = "id">
</form>
<%@ include file = "/include/scrollpage.jsp" %>
</body>
</html>