<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.core.Unit" %>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.workflow.Engine" %>
<%@ page import="nps.workflow.WorkProcess" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.Connection" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.workflow_processinfo",user.GetLocale(), nps.core.Config.RES_CLASSLOADER);

    String id=request.getParameter("id");//如果为null，将在保存时使用序列生成ID号
    if(id!=null) id=id.trim();

    String creator = user.GetName()+"("+user.GetDeptName()+ "/" +user.GetUnitName()+")";
    String create_date = nps.util.Utils.FormateDate(new java.util.Date(),"yyyy-MM-dd HH:mm:ss");

    boolean  bNew=(id==null || id.length()==0);
    Connection conn = null;
    WorkProcess process = null;
    if(!bNew)  //需要从数据库中加载信息
    {
        process = Engine.GetInstance().GetProcess(id);
        if(process==null) throw new NpsException(ErrorHelper.SYS_NOTEXIST, "process id=" + id);
    }  //if(!bNew)
%>

<html>
<head>
    <title><%=bNew?bundle.getString("PROCESS_HTMLTITLE"):process.GetName()%></title>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel=stylesheet>

    <script language="Javascript">
      function fill_check()
      {
        if (document.inputFrm.process_name.value.trim() == ""){
          alert("<%=bundle.getString("PROCESS_ALERT_NO_NAME")%>");
          document.inputFrm.process_name.focus();
          return false;
        }
        if (document.inputFrm.process_scope.value == "2"){
          if(document.inputFrm.unit_id.value=="") {
              alert("<%=bundle.getString("PROCESS_ALERT_NO_UNIT")%>");
              document.inputFrm.unit_id.focus();
              return false;
          }
        }
        if(!flash2XML()) return false;
        return true;
      }
      function f_save()
      {
         if(!fill_check()) return;
         document.inputFrm.act.value=0;
         document.inputFrm.action='processsave.jsp';
         document.inputFrm.target="_self";
         document.inputFrm.submit();
      }
      function f_delete()
      {
        var r=confirm('<%=bundle.getString("PROCESS_ALERT_DELETE")%>');
        if( r ==1 )
        {
          document.inputFrm.act.value=1;
          document.inputFrm.action='processsave.jsp';
          document.inputFrm.target="_self";
          document.inputFrm.submit();
        }
      }
      function getFlashEditor()
      {
          if (navigator.appName.indexOf("Microsoft") != -1)
          {
              return window["editor"];
          }
          else
          {
             return document["editor"];
          }
      }
      function flash2XML()
      {
          var xml = getFlashEditor().getXML();
          if(xml==null) return false;
          document.getElementById('xml').value = xml;
          return true;
      }
      function js_loadxml()
      {
          getFlashEditor().loadXML(document.getElementById('xml').value);
      }
    </script>
    <script type="text/javascript" src="/workflow/designer/swfobject.js"></script>
    <script type="text/javascript">
        var swfVersionStr = "10.0.0";
        var xiSwfUrlStr = "/workflow/designer/playerProductInstall.swf";
        var flashvars = {};
        var params = {};
        params.quality = "high";
        params.bgcolor = "#ffffff";
        params.allowscriptaccess = "sameDomain";
        params.allowfullscreen = "true";
        var attributes = {};
        attributes.id = "editor";
        attributes.name = "editor";
        attributes.align = "middle";
        swfobject.embedSWF(
            "/workflow/designer/editor.swf", "flashContent",
            "100%", "100%",
            swfVersionStr, xiSwfUrlStr,
            flashvars, params, attributes);

        swfobject.createCSS("#flashContent", "display:block;text-align:left;");
    </script>
</head>

<body leftmargin=20 topmargin=0>
<table id="pbar" border="0" class="positionbar" cellpadding="0" cellspacing="0">
  <tr>
    <td>&nbsp;
<%
  //发布后不能修改
  boolean bSavable = false;  //是否显示保存按钮
  boolean bDeletable = false; //是否显示删除按钮

  if(bNew)
  {
     bSavable = true;
     bDeletable = false;
  }
  else
  {
     if(process!=null)
     {
         if(process.GetCreator().equals(user.GetId()))
         {
             bSavable = true;
             bDeletable = true;
         }
         else
         {
             switch(process.GetScope())
             {
                 case WorkProcess.SCOPE_GLOBAL:
                     break;
                 case WorkProcess.SCOPE_COMPANY:
                     if(user.GetUnitId().equals(process.GetUnitId()))
                     {
                         bSavable = true;
                         bDeletable = true;
                     }
             }
         }
     }
  }

  if(bSavable)
  {
%>
      <input type="button" class="button" name="save" value="<%=bundle.getString("PROCESS_BUTTON_SAVE")%>" onClick="f_save()" >
<%
  }
  if(bDeletable)
  {
%>
       <input type="button" class="button" name="submit" value="<%=bundle.getString("PROCESS_BUTTON_DELETE")%>" onClick="f_delete()" >
<%
  }
%>
  </tr>
</table>
<%
    conn = Database.GetDatabase("nps").GetConnection();
    try
    {
%>
<table width="100%" cellpadding="0" border="1" cellspacing="0">
    <form name="inputFrm" method="post" action="processsave.jsp">
    <input type="hidden" name="id"  value="<%=Utils.Null2Empty(id)%>">
    <input type="hidden" name="act" value="0">

    <tr height="30">
        <td width="80" align=center><font color=red><%=bundle.getString("PROCESS_NAME")%></font></td>
        <td width="300">
          <input type="text" name="process_name" style="width:90%" value= "<%= (process==null || process.GetName()==null)?"":Utils.TransferToHtmlEntity(process.GetName()) %>">
        </td>
        <td width="80" align=center><%=bundle.getString("PROCESS_STATUS")%></td>
        <td>
            <input type="radio" name="process_status" value="1" <%= (process==null || process.GetStatus())?"checked":""%> <%= bNew?"checked":""%>><%=bundle.getString("PROCESS_STATUS_VALID")%>
            <input type="radio" name="process_status" value="0" <%= (process!=null && !process.GetStatus())?"checked":""%>><%=bundle.getString("PROCESS_STATUS_INVALID")%>
        </td>
    </tr>
    <tr height="30">
		<td align=center><%=bundle.getString("PROCESS_SCOPE")%></td>
		<td colspan="3">
            <input type="radio" name="process_scope" value="0" <%= (process!=null && process.IsGlobal())?"checked":""%>><%=bundle.getString("PROCESS_SCOPE_GLOBAL")%>
            <input type="radio" name="process_scope" value="1" <%= (process==null || process.IsCompany())?"checked":""%>><%=bundle.getString("PROCESS_SCOPE_COMPANY")%>
            <select name="unit_id">
                <option></option>
    <%
        List<Unit> units = user.GetUnits(conn);
        for(Unit unit: units)
        {
    %>
                <option value="<%=unit.GetId()%>" <% if( (process==null && unit.GetId().equals(user.GetUnitId())) ||(process!=null && unit.GetId().equals(process.GetUnitId()))) out.print("selected"); %>><%=unit.GetName()%></option>
    <%
        }
    %>
            </select>
	    </td>
    </tr>
    <tr height=30>
        <td align=center><%=bundle.getString("PROCESS_CREATOR")%></td>
        <td><%= bNew?creator:process.GetCreatorName()%></td>
        <td align=center><%=bundle.getString("PROCESS_CREATEDATE")%></td>
        <td>
            <%= bNew?create_date:process.GetCreateDate()%>
        </td>
    </tr>
    <tr>
        <td colspan="4">
            <textarea id="xml" name="xml" style="display:none"><% if(process!=null) process.GetXML(conn,out); %></textarea>
        </td>
    </tr>
 </form>
</table>
<div id="flashContent">
        <script type="text/javascript">
            var pageHost = ((document.location.protocol == "https:") ? "https://" :	"http://");
            document.write("<a href='http://www.adobe.com/go/getflashplayer'><img src='"
                            + pageHost + "www.adobe.com/images/shared/download_buttons/get_flash_player.gif' alt='Get Adobe Flash player' /></a>" );
        </script>
</div>

<%
    }
    finally
    {
        try{conn.close();}catch(Exception e){}
    }
%>
</body>
</html>