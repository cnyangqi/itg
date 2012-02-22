<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.core.Unit" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.Config" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="nps.core.Database" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ include file="/include/header.jsp" %>


<%
    request.setCharacterEncoding("UTF-8");
    if(!(user.IsSysAdmin() || user.IsLocalAdmin()))  throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);
    int rowperpage = 25;
    int currpage = 1, startnum = 0, endnum = 0, totalrows = 0, totalpages = 0, rownum=0;
    String scrollstr = "", nextpage = "unitadmin.jsp";
    String currpg    = request.getParameter("page");
    try{ currpage = Integer.parseInt(currpg);	}catch (Exception e){currpage = 1;	}

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_unitadmin",user.GetLocale(), Config.RES_CLASSLOADER);

    String job = request.getParameter("job");
    if("delete".equalsIgnoreCase(job))
    {
        //删除单位
        String[] rownos = request.getParameterValues("rowno");
        Connection conn = null;
        try
        {
            conn = Database.GetDatabase("nps").GetConnection();
            conn.setAutoCommit(false);

            for(int i=0;rownos!=null && i<rownos.length;i++)
            {
                String id = request.getParameter("unit_id_" + rownos[i]);
                Unit unit = user.GetUnit(conn,id);
                if(unit!=null)  unit.Delete(conn);
            }

            conn.commit();
        }
        catch(Exception e)
        {
            conn.rollback();
            throw e;
        }
        finally
        {
            if(conn!=null) try{conn.close();}catch(Exception e){}
        }

    }
%>


<HTML>
	<HEAD>
		<TITLE><%=bundle.getString("UNITADMIN_HTMLTITLE")%></TITLE>
        <script type="text/javascript" src="/jscript/global.js"></script>
        <LINK href="/css/style.css" rel = stylesheet>
        <script langauge = "javascript">
			function f_new()
			{
				document.listFrm.action	= "unitinfo.jsp";
                document.listFrm.target="_blank";
                document.listFrm.submit();
			}
            function openUnit(idvalue)
            {
                document.frmOpen.id.value = idvalue;
                document.frmOpen.submit();
            }
            
            function f_newdept(unitid)
            {
                document.frmDept.unit_id.value = unitid;
                document.frmDept.submit();
            }

            function f_delete(actiontype)
			{
                var rownos = document.getElementsByName("rowno");
                var hasChecked = false;
                for(var i = 0; i < rownos.length; i++)
                {
                    if( rownos[i].checked )
                    {
                        hasChecked = true;
                        break; 
                    }
                }
                if( !hasChecked )
                {
                    alert("<%=bundle.getString("UNITADMIN_ALERT_NO_UNIT_SELECT")%>");
                    return false;
                }

                var r = confirm("<%=bundle.getString("UNITADMIN_ALERT_DELETE")%>");
                if( r !=1 ) return false;

                document.listFrm.action = "unitadmin.jsp?job=delete";
                document.listFrm.target="_self";
				document.listFrm.submit();
			}

			function SelectUnit()
			{
                var rownos = document.getElementsByName("rowno");
				for(var i = 0; i < rownos.length; i++)
				{
					rownos[i].checked = document.listFrm.AllId.checked;
				}
			}
		</script>
	</HEAD>
<BODY>
  <table width = "100% " border = "0" cellpadding = "0" cellspacing = "0" class="PositionBar">
    <tr>
      <td valign="middle">&nbsp;
<%
   if(user.IsSysAdmin())
   {
%>
        <input name="newBtn" type="button" onClick="f_new()" value="<%=bundle.getString("UNITADMIN_BUTTON_NEW")%>" class="button">
        <input name="delBtn" type="button" onClick="f_delete()" value="<%=bundle.getString("UNITADMIN_BUTTON_DELETE")%>" class="button">
<%
    }
%>
        <input type="hidden" name="urlTo" value="unitadmin.jsp?page=<%=currpage%>" >
      </td>
    </tr>
  </table>
  <table width = "100% " border = "0" cellpadding = "0" cellspacing = "1" class="TitleBar">
  <form name = "listFrm" method = "post">
      <tr height=30>
	      <td width="25">
    		<input type = "checkBox" name = "AllId" value = "0" onclick = "SelectUnit()">
		  </td>
 	      <td width=160><%=bundle.getString("UNITADMIN_NAME")%></td>
    <%
        if(user.IsLocalAdmin())
        {
    %>
          <td width=120 align=center><%=bundle.getString("UNITADMIN_OPERATION")%></td>
    <%
        }
    %>
          <td width=80><%=bundle.getString("UNITADMIN_ATTACHMAN")%></td>
          <td width=80><%=bundle.getString("UNITADMIN_TEL")%></td>
          <td width=80><%=bundle.getString("UNITADMIN_EMAIL")%></td>
          <td ><%=bundle.getString("UNITADMIN_ADDRESS")%></td>
      </tr>
<%
        String unitId = "";
        rownum = 0;
        List list = user.GetUnits();
        for(Object obj:list)
        {
            Unit unit = (Unit)obj;
            unitId = unit.GetId();
%>
	          <tr class="DetailBar">
				<td>
                  <input type = "checkBox" id="rowno" name="rowno" value = "<%= rownum %>">
                  <input type = "hidden" name = "unit_id_<%= rownum %>" value = "<%= unit.GetId() %>">
				</td>
				<td>
                  <a href="javascript:openUnit('<%= unitId %>');"><%= Utils.TransferToHtmlEntity(unit.GetName()) %></a>
                </td>
                <td align="center">
                <%
                    if(user.IsLocalAdmin())
                    {
                %>
                    <a href="deptadmin.jsp?unit_id=<%=unitId%>" target="_blank"><%=bundle.getString("UNITADMIN_BUTTON_DEPTADMIN")%></a>
                <%
                    }
                %>
                </td>
                <td>
                  <%= unit.GetAttachman()==null?"":unit.GetAttachman() %>
                </td>
                <td>
                   <%= unit.GetPhonenum()==null?"":unit.GetPhonenum() %>
                   <%= unit.GetMobile()==null?"":unit.GetMobile() %>
                </td>
                <td>
	      		   <%= unit.GetEmail()==null?"":unit.GetEmail() %>
                </td>
                <td>
                    <%= unit.GetAddress()==null?"":unit.GetAddress() %>
                <%
                    if(unit.GetZipcode()!=null)
                    {
                %>
                        <br>
                        <%=bundle.getString("UNITADMIN_ZIPCODE")%>: <%= unit.GetZipcode()%>
                <%
                    }
                %>
                </td>
              </tr>
<%
             rownum++;
        }
 %>
 </form>
 </table>
<form name=frmOpen action="unitinfo.jsp" target="_blank">
  <input type = "hidden" name = "id">
</form>
<form name=frmDept action="deptadmin.jsp" target="_blank">
  <input type = "hidden" name = "unit_id">
</form>
</BODY>
</HTML>