<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.core.*" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.List" %>
<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String id = null;
    Connection con   = null;

    String act = request.getParameter("act");
    if(act!=null)  act = act.trim();

    if(!(user.IsSysAdmin() || user.IsLocalAdmin()))
       throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_triggeradmin",user.GetLocale(), Config.RES_CLASSLOADER);
%>

<HTML>
	<HEAD>
		<TITLE><%=bundle.getString("TRIGGERADMIN_HTMLTILE")%></TITLE>
        <script type="text/javascript" src="/jscript/global.js"></script>
        <LINK href="/css/style.css" rel = stylesheet>
		<script langauge = "javascript">
			function f_new()
			{
				document.listFrm.action	= "triggerinfo.jsp";
                document.listFrm.target="_blank";
                document.listFrm.submit();
            }

            function openTrigger(idvalue)
            {
                document.frmOpen.id.value = idvalue;
                document.frmOpen.submit();
            }

            function selectTrigger()
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
        <input name="newBtn" type="button" onClick="f_new()" value="<%=bundle.getString("TRIGGERADMIN_BUTTON_NEW")%>" class="button">
      </td>
	</tr>
  </table>

  <table width = "100% " border = "0" align = "center" cellpadding = "0" cellspacing = "1" class="titlebar">
  <form name = "listFrm" method = "post">
     <input type="hidden" name="act" value="">
      <tr height=30>
	      <td width="25">
    		<input type = "checkBox" name = "AllId" value = "0" onclick = "selectTrigger()">
		  </td>
 	      <td width = "200"><%=bundle.getString("TRIGGERADMIN_NAME")%></td>
          <td width = "120"><%=bundle.getString("TRIGGERADMIN_TOPIC")%></td>
          <td width = "120"><%=bundle.getString("TRIGGERADMIN_EVENT")%></td>
          <td width = "80"><%=bundle.getString("TRIGGERADMIN_STATUS")%></td>
          <td width = "80"><%=bundle.getString("TRIGGERADMIN_LASTRUN_STATE")%></td>
          <td width = "80"><%=bundle.getString("TRIGGERADMIN_CREATOR")%></td>
          <td width = "80"><%=bundle.getString("TRIGGERADMIN_CREATEDATE")%></td>
      </tr>
<%
    try
    {
        //只能编辑自己管理的站点
        con = Database.GetDatabase("nps").GetConnection();
        NpsContext ctxt = new NpsContext(con,user);
        TriggerManager manager = TriggerManager.LoadTriggers(ctxt);
        java.util.Hashtable sites = user.GetOwnSites();
        //key:id value:caption
        if((sites!=null) && !sites.isEmpty())
        {
            int i=0;
            java.util.Enumeration sitekeys = sites.keys();
            while(sitekeys.hasMoreElements())
            {
                String site_id = (String)sitekeys.nextElement();
                Hashtable topic_triggers = manager.GetTriggersBySite(ctxt,site_id);
                if(topic_triggers!=null && !topic_triggers.isEmpty())
                {
                    java.util.Enumeration enum_topic_triggers = topic_triggers.elements();
                    while(enum_topic_triggers.hasMoreElements())
                    {
                        List list_triggers = (List)enum_topic_triggers.nextElement();
                        for(Object obj:list_triggers)
                        {
                            Trigger trigger = (Trigger)obj;
                            i++;
%>
      <tr class="detailbar">
        <td>
          <input type = "checkBox" id="rowno" name="rowno" value = "<%= i %>">
          <input type = "hidden" name = "trigger_id_<%= i %>" value = "<%= trigger.GetId() %>">
        </td>
        <td>
          <a href="javascript:openTrigger('<%= trigger.GetId() %>');"><%= trigger.GetName() %></a>
        </td>
        <td><%=trigger.GetTopic().GetName()+"("+trigger.GetTopic().GetSite().GetName()+")"%></td>
        <td>
            <%
                switch(trigger.GetEvent())
                {
                    case 0:
                        out.print(bundle.getString("TRIGGERADMIN_EVENT_INSERT"));
                        break;
                    case 1:
                        out.print(bundle.getString("TRIGGERADMIN_EVENT_UPDATE"));
                        break;
                    case 2:
                        out.print(bundle.getString("TRIGGERADMIN_EVENT_READY"));
                        break;
                    case 3:
                        out.print(bundle.getString("TRIGGERADMIN_EVENT_PUBLISH"));
                        break;
                    case 4:
                        out.print(bundle.getString("TRIGGERADMIN_EVENT_CANCEL"));
                        break;
                    case 5:
                        out.print(bundle.getString("TRIGGERADMIN_EVENT_DELETE"));
                        break;
                }
            %>
        </td>
        <td>
            <%
                if(trigger.IsEnable())
                    out.print(bundle.getString("TRIGGERADMIN_STATUS_ENABLED"));
                else
                    out.print(bundle.getString("TRIGGERADMIN_STATUS_DISABLED"));
            %>
        </td>
        <td>
            <%
            switch(trigger.GetLastRunState())
            {
              case 0:
                  out.print(bundle.getString("TRIGGERADMIN_LASTRUN_STATUS_NORMAL"));
                  break;
              case 1:
                  out.print(bundle.getString("TRIGGERADMIN_LASTRUN_STATUS_ERROR"));
                  break;
            }
            %>
        </td>
        <td><%=trigger.GetCreatorName()%></td>
        <td><%=Utils.FormateDate(trigger.GetCreateDate(),"yyyy-MM-dd")%></td>
      </tr>
<%
                        }
                    }
                }
            }
        }
    }
    finally
    {
        if (con != null)  try{ con.close(); }catch(Exception e){}
    }
 %>
 </form>
 </table>
<form name=frmOpen action="triggerinfo.jsp" target="_blank">
  <input type = "hidden" name = "id">
</form>
</body>
</html>