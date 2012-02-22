<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.Config" %>
<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    int rowperpage = 100;
    int currpage = 1, startnum = 0, endnum = 0, totalrows = 0, totalpages = 0, rownum=0;
    String scrollstr = "", nextpage = "customer_admin.jsp";
    String currpg    = request.getParameter("page");
    try{ currpage = Integer.parseInt(currpg);	}catch (Exception e){currpage = 1;	}
    Connection con   = null;
    PreparedStatement pstmt   = null;
    ResultSet rs     = null;
    String sql 		 = null;

    ResourceBundle bundle = ResourceBundle.getBundle("langs.app_customeradmin",user.GetLocale(), Config.RES_CLASSLOADER);
%>

<HTML>
	<HEAD>
		<TITLE><%=bundle.getString("CUSTOMERADMIN_HTMLTILE")%></TITLE>
        <script type="text/javascript" src="/jscript/global.js"></script>
        <LINK href="/css/style.css" rel = stylesheet>
		<script langauge = "javascript">
            function openCustomer(idvalue)
            {
              document.frmOpen.id.value = idvalue;
              document.frmOpen.submit();
            }

            function f_email()
            {
                
            }
        </script>
	</HEAD>

  <BODY leftMargin="20" topMargin = "0">
  <table width = "100% " border = "0" align = "center" cellpadding = "0" cellspacing = "0" class="positionbar">
    <tr>
      <td valign="middle">&nbsp;
          <input name="emailBtn" type="button" onClick="f_email()" value="<%=bundle.getString("CUSTOMERADMIN_BUTTON_EMAIL")%>" class="button">
      </td>
    </tr>
  </table>

  <table width = "100% " border = "0" align = "center" cellpadding = "0" cellspacing = "1" class="titlebar">
  <form name = "listFrm" method = "post">
     <input type="hidden" name="act" value="">
      <tr height=30>
	      <td width="25">
    		<input type = "checkBox" name = "AllId" value = "0">
		  </td>
 	      <td width="200"><%=bundle.getString("CUSTOMERADMIN_NAME")%></td>
          <td align="center" width="200"><%=bundle.getString("CUSTOMERADMIN_CONTACT")%></td>
          <td align="center" width="200"><%=bundle.getString("CUSTOMERADMIN_ADDRESS")%></td>
          <td align="center"><%=bundle.getString("CUSTOMERADMIN_CREATEDATE")%></td>
      </tr>
<%
    try
    {
        con = Database.GetDatabase("nps").GetConnection();

        int i = 1;
        if(user.IsSysAdmin())
        {
            sql = "select count(*) from CUSTOMER a,SITE b where a.siteid=b.id";
        }
        else
        {
            sql = "select count(*) from CUSTOMER a,SITE b where a.siteid=b.id and b.unit=?";
        }

        pstmt = con.prepareStatement(sql);
        if(!user.IsSysAdmin())
        {
            pstmt.setString(i++,user.GetUnitId());
        }

        //query search now
        rs = pstmt.executeQuery();
        if (rs.next())  totalrows = rs.getInt(1);
        try{rs.close();}catch(Exception e){}
        try{pstmt.close();}catch(Exception e){}

        if (totalrows > 0)
        {
            totalpages = (int )((totalrows - 1) / rowperpage) + 1;
            startnum = rowperpage * (currpage - 1) + 1;
            endnum = currpage * rowperpage;
            i=1;
            if(user.IsSysAdmin())
            {
                sql = "select a.* from CUSTOMER a,SITE b where a.siteid=b.id";
            }
            else
            {
                sql = "select a.* from CUSTOMER a,SITE b where a.siteid=b.id and b.unit=?";
            }

            String orderby = " order by a.createdate desc";
            pstmt = con.prepareStatement(sql+orderby);

            if(!user.IsSysAdmin())
            {
                pstmt.setString(i++,user.GetUnitId());
            }
            rs = pstmt.executeQuery();

            String customerId = null;
            rownum = 0;
            while (rs.next() && (rs.getRow() <= endnum))
            {
                if (rs.getRow() < startnum) continue;

                customerId = rs.getString("id");
%>
	          <tr class="detailbar">
				<td>
                  <input type = "checkBox" id="rowno" name="rowno" value = "<%= rs.getRow() %>">
                  <input type = "hidden" name = "customer_id_<%= rs.getRow() %>" value = "<%= customerId %>">
				</td>
				<td align="left">
                  <%= Utils.Null2Empty(Utils.TransferToHtmlEntity(rs.getString("jobtitle")))%> &nbsp;&nbsp;&nbsp;&nbsp;
                  <%= Utils.Null2Empty(Utils.TransferToHtmlEntity(rs.getString("company")))%><br>
                  <font size="4"><b><%= Utils.Null2Empty(Utils.TransferToHtmlEntity(rs.getString("name")))%></b></font>
				</td>
                <td align="left">
                    Tel:<%= Utils.Null2Empty(Utils.TransferToHtmlEntity(rs.getString("telephone")))%><br>
                    Mobile:<%= Utils.Null2Empty(Utils.TransferToHtmlEntity(rs.getString("mobile")))%><br>
                    Fax:<%= Utils.Null2Empty(Utils.TransferToHtmlEntity(rs.getString("fax")))%><br>
                    Email:<%= Utils.Null2Empty(Utils.TransferToHtmlEntity(rs.getString("email")))%>
                </td>
                <td align="left">
                    <%= Utils.Null2Empty(Utils.TransferToHtmlEntity(rs.getString("address")))%><br>
                    <%= Utils.Null2Empty(rs.getString("city"))%>&nbsp;&nbsp;&nbsp;&nbsp;
                    <%= Utils.Null2Empty(rs.getString("province"))%>&nbsp;&nbsp;&nbsp;&nbsp;
                    <%
                        String country_code = rs.getString("country");
                        if(country_code!=null)
                        {
                            String[] arrs = country_code.split("|");
                            out.println(arrs[0]);
                        }
                    %>
                    <br>
                    <%= Utils.Null2Empty(rs.getString("postal_code"))%>
                </td>
                <td align="center">
                  <%= Utils.FormateDate(rs.getDate("createdate"),"yyyy-MM-dd")%>
                </td>
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
 <form name=frmOpen action="inquire_info.jsp" target="_blank">
    <input type = "hidden" name = "id">
 </form>

<%@ include file = "/include/scrollpage.jsp" %>
</body>
</html>