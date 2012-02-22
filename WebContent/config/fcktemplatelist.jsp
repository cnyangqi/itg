<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.core.NpsWrapper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.core.Config" %>
<%@ page import="nps.core.FCKTemplateManager" %>
<%@ page import="nps.core.FCKTemplate" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.util.Vector" %>
<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    int rowperpage = 25;
    int currpage = 1, startnum = 0, endnum = 0, totalrows = 0, totalpages = 0, rownum=0;
    String scrollstr = "", nextpage = "fcktemplatelist.jsp";
    String currpg    = request.getParameter("page");
    try{ currpage = Integer.parseInt(currpg);	}catch (Exception e){currpage = 1;	}
    String id = null;

    String act = request.getParameter("act");
    if(act!=null)  act = act.trim();

    if(!(user.IsSysAdmin() || user.IsLocalAdmin()))
       throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_fcktemplatelist",user.GetLocale(), Config.RES_CLASSLOADER);

    NpsWrapper wrapper = null;
%>

<HTML>
	<HEAD>
		<TITLE><%=bundle.getString("FCKTEMPLATELIST_HTMLTILE")%></TITLE>
        <script type="text/javascript" src="/jscript/global.js"></script>
        <LINK href="/css/style.css" rel = stylesheet>
		<script langauge = "javascript">
			function f_new()
			{
				document.listFrm.action	= "fcktemplateinfo.jsp";
                document.listFrm.target="_blank";
                document.listFrm.submit();
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
        <input name="newBtn" type="button" onClick="f_new()" value="<%=bundle.getString("FCKTEMPLATELIST_BUTTON_NEW")%>" class="button">
      </td>
	</tr>
  </table>


  <table width = "100% " border = "0" align = "center" cellpadding = "0" cellspacing = "1" class="titlebar">
  <form name = "listFrm" method = "post">
     <input type="hidden" name="act" value="">
      <tr height=30>
	      <td width="25">
    		<input type = "checkBox" name = "AllId" value = "0" onclick = "selectTemplate()">
		  </td>
          <td width = "120"><%=bundle.getString("FCKTEMPLATELIST_IMAGE")%></td>
          <td><%=bundle.getString("FCKTEMPLATELIST_TITLE")%></td>
          <td width = "80"><%=bundle.getString("FCKTEMPLATELIST_SCOPE")%></td>
          <td width = "80"><%=bundle.getString("FCKTEMPLATELIST_CREATOR")%></td>
          <td width = "80"><%=bundle.getString("FCKTEMPLATELIST_CREATEDATE")%></td>
      </tr>
<%
    try
    {
        wrapper = new NpsWrapper(user);
        Vector<FCKTemplate> v_templates = FCKTemplateManager.GetAllTemplates(wrapper.GetContext(),user.GetUnitId());
        totalrows = (v_templates==null?0:v_templates.size());

        if (totalrows > 0)
        {
            totalpages = (int )((totalrows - 1) / rowperpage) + 1;
            startnum = rowperpage * (currpage - 1) + 1;
            endnum = currpage * rowperpage;

            rownum = 0;
            for(Object obj:v_templates)
            {
                rownum++;
                if(rownum < startnum)  continue;
                if(rownum > endnum) break;

                FCKTemplate template = (FCKTemplate)obj;
%>
	          <tr class="detailbar">
				<td>
                  <input type = "checkBox" id="rowno" name="rowno" value = "<%= rownum %>">
                  <input type = "hidden" name = "template_id_<%= rownum %>" value = "<%= template.GetId() %>">
				</td>
                <td><a href="javascript:openTemplate('<%= template.GetId() %>');">
                    <img border=0 src="/userdir/fcktemplate/<%= template.GetId()+".jpg" %>">
                    </a>
                </td>
                <td>
                  <a href="javascript:openTemplate('<%= template.GetId() %>');"><%= template.GetTitle() %></a>
                   <br>
                  <%= template.GetDescription() %>  
                </td>
				<td>
                  <%
                      switch(template.GetScope())
                      {
                          case 0:
                              out.print(bundle.getString("FCKTEMPLATELIST_SCOPE_FULL"));
                              break;
                          case 1:
                              out.print(bundle.getString("FCKTEMPLATELIST_SCOPE_MYUNIT"));
                              break;
                      }
                  %>
                </td>
                <td>
	      		   <%= template.GetCreatorCN() %>
                </td>
                <td>
	      		   <%= Utils.FormateDate(template.GetCreateDate(),"yyyy-MM-dd") %>
                </td>
              </tr>
          <%
              }
			}  //end of if (totalrows >0)
    }
    finally
    {
        if(wrapper!=null) wrapper.Clear();
    }
 %>
 </form>
 </table>
<form name=frmOpen action="fcktemplateinfo.jsp" target="_blank">
  <input type = "hidden" name = "id">
</form>
<%@ include file = "/include/scrollpage.jsp" %>
</body>
</html>
