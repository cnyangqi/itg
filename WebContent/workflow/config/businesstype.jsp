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
<%@ page import="nps.workflow.BusinessType" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.workflow_businesstype",user.GetLocale(), nps.core.Config.RES_CLASSLOADER);

    String id=request.getParameter("id");//如果为null，将在保存时使用序列生成ID号
    if(id!=null) id=id.trim();

    String creator = user.GetName()+"("+user.GetDeptName()+ "/" +user.GetUnitName()+")";
    String create_date = nps.util.Utils.FormateDate(new java.util.Date(),"yyyy-MM-dd HH:mm:ss");

    boolean  bNew=(id==null || id.length()==0);
    Connection conn = null;
    BusinessType type = null;
    if(!bNew)  //需要从数据库中加载信息
    {
        type = BusinessType.Get(id);
        if(type==null) throw new NpsException(ErrorHelper.SYS_NOTEXIST, "business type id=" + id);
    }  //if(!bNew)
%>

<html>
<head>
    <title><%=bNew?bundle.getString("BUSINESSTYPE_HTMLTITLE"):type.GetName()%></title>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel=stylesheet>

    <script language="Javascript">
      function fill_check()
      {
        if (document.inputFrm.id.value.trim() == ""){
          alert("<%=bundle.getString("BUSINESSTYPE_ALERT_NO_ID")%>");
          document.inputFrm.id.focus();
          return false;
        }
        if (document.inputFrm.type_name.value.trim() == ""){
          alert("<%=bundle.getString("BUSINESSTYPE_ALERT_NO_NAME")%>");
          document.inputFrm.type_name.focus();
          return false;
        }
        if(document.inputFrm.unit_id.value=="") {
          alert("<%=bundle.getString("BUSINESSTYPE_ALERT_NO_UNIT")%>");
          document.inputFrm.unit_id.focus();
          return false;
        }
        if(document.inputFrm.process_id.value=="") {
          alert("<%=bundle.getString("BUSINESSTYPE_ALERT_NO_PROCESS")%>");
          document.inputFrm.process_id.focus();
          return false;
        }
        if(document.inputFrm.url.value=="") {
          alert("<%=bundle.getString("BUSINESSTYPE_ALERT_NO_URL")%>");
          document.inputFrm.url.focus();
          return false;
        }
        return true;
      }

      function f_save()
      {
         if(!fill_check()) return;
         document.inputFrm.act.value=0;
         document.inputFrm.action='businesstypesave.jsp';
         document.inputFrm.target="_self";
         document.inputFrm.submit();
      }

      function f_delete()
      {
        var r=confirm('<%=bundle.getString("BUSINESSTYPE_ALERT_DELETE")%>');
        if( r ==1 )
        {
          document.inputFrm.act.value=1;
          document.inputFrm.action='businesstypesave.jsp';
          document.inputFrm.target="_self";
          document.inputFrm.submit();
        }
      }

      function f_deleteforce()
      {
        var r=confirm('<%=bundle.getString("BUSINESSTYPE_ALERT_DELETEFORCE")%>');
        if( r ==1 )
        {
          document.inputFrm.act.value=2;
          document.inputFrm.action='businesstypesave.jsp';
          document.inputFrm.target="_self";
          document.inputFrm.submit();
        }
      }
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
     if(type!=null)
     {
         if(    type.GetCreator().equals(user.GetId())
             || user.GetUnitId().equals(type.GetUnitId())
            )
         {
             bSavable = true;
             bDeletable = true;
         }
     }
  }

  if(bSavable)
  {
%>
      <input type="button" class="button" name="save" value="<%=bundle.getString("BUSINESSTYPE_BUTTON_SAVE")%>" onClick="f_save()" >
<%
  }
  if(bDeletable)
  {
%>
       <input type="button" class="button" name="submit" value="<%=bundle.getString("BUSINESSTYPE_BUTTON_DELETE")%>" onClick="f_delete()" >
       <input type="button" class="button" name="submit" value="<%=bundle.getString("BUSINESSTYPE_BUTTON_DELETEFORCE")%>" onClick="f_deleteforce()" > 
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
    <form name="inputFrm" method="post" action="businesstypesave.jsp">
    <input type="hidden" name="act" value="0">

    <tr height="30">
        <td width="120" align=center><font color=red><%=bundle.getString("BUSINESSTYPE_NAME")%></font></td>
        <td>
          <input type="text" name="type_name" style="width:90%" value= "<%= (type==null || type.GetName()==null)?"":Utils.TransferToHtmlEntity(type.GetName()) %>">
        </td>
        <td width="120" align="center"><%=bundle.getString("BUSINESSTYPE_ID")%></td>
        <td width="400">
            <%
                if(type!=null)
                {
                    out.print(type.GetId());
                }
                else
                {
                     out.print("<input type='hidden' name='is_new' value='1'>");
                }
            %>
            <input type="<%=bNew?"text":"hidden"%>" name="id"  value="<%=Utils.Null2Empty(id)%>">
            &nbsp;&nbsp;<font color="red"><%=bundle.getString("BUSINESSTYPE_ID_HINT")%></font>
        </td>
    </tr>
    <tr height="30">
		<td align=center><font color=red><%=bundle.getString("BUSINESSTYPE_UNIT")%></font></td>
		<td>
            <select name="unit_id">
                <option></option>
    <%
        List<Unit> units = user.GetUnits(conn);
        for(Unit unit: units)
        {
    %>
                <option value="<%=unit.GetId()%>" <% if( (type==null && unit.GetId().equals(user.GetUnitId())) ||(type!=null && unit.GetId().equals(type.GetUnitId()))) out.print("selected"); %>><%=unit.GetName()%></option>
    <%
        }
    %>
            </select>
	    </td>
        <td align=center><%=bundle.getString("BUSINESSTYPE_STATUS")%></td>
        <td>
            <input type="radio" name="type_status" value="1" <%= (type==null || type.IsValid())?"checked":""%> <%= bNew?"checked":""%>><%=bundle.getString("BUSINESSTYPE_STATUS_ENABLED")%>
            <input type="radio" name="type_status" value="0" <%= (type!=null && !type.IsValid())?"checked":""%>><%=bundle.getString("BUSINESSTYPE_STATUS_DISABLED")%>
        </td>
    </tr>
    <tr height=30>
        <td align="center"><font color=red><%=bundle.getString("BUSINESSTYPE_PROCESS")%></font></td>
        <td>
            <select name="process_id">
                <option value=""></option>
    <%
        List<WorkProcess> processes = Engine.GetInstance().GetAllProcess(user.GetUnitId());
        if(processes!=null)
        {
            for(WorkProcess process: processes)
            {
    %>

                <option value="<%=process.GetId()%>" <% if(type!=null && process.GetId().equals(type.GetProcessId())) out.print("selected"); %>><%=process.GetName()%></option>
    <%
            }
        }
    %>
            </select>
        </td>
        <td align="center"><%=bundle.getString("BUSINESSTYPE_INDEX")%></td>
        <td><input type="text" name="type_index" value="<%=bNew?0:type.GetIndex()%>"></td>
    </tr>
    <tr height=30>
        <td align=center><font color=red><%=bundle.getString("BUSINESSTYPE_URL")%></font></td>
        <td colspan="3">
            <input type="text" name="url" style="width:400px" value="<%=bNew?"":type.GetURL()%>">
            <%=bundle.getString("BUSINESSTYPE_HINT_URL")%>
        </td>
    </tr>
    <tr height=30>
        <td align=center><%=bundle.getString("BUSINESSTYPE_CREATOR")%></td>
        <td><%= bNew?creator:type.GetCreatorName()%></td>
        <td align=center><%=bundle.getString("BUSINESSTYPE_CREATEDATE")%></td>
        <td>
            <%= bNew?create_date:Utils.FormateDate(type.GetCreateDate(),"yyyy-MM-dd")%>
        </td>
    </tr>
</form>
</table>
<%
    }
    finally
    {
        try{conn.close();}catch(Exception e){}
    }
%>
</body>
</html>