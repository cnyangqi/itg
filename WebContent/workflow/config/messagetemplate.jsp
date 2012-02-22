<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.core.Unit" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.List" %>
<%@ page import="nps.workflow.message.MessageTemplate" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.workflow_messagetemplate",user.GetLocale(), nps.core.Config.RES_CLASSLOADER);

    String id = request.getParameter("id");//如果为null，将在保存时使用序列生成ID号
    if(id!=null) id = id.trim();

    String creator = user.GetName()+"("+user.GetDeptName()+ "/" +user.GetUnitName()+")";
    String create_date = nps.util.Utils.FormateDate(new java.util.Date(),"yyyy-MM-dd HH:mm:ss");

    boolean  bNew=(id==null || id.length()==0);
    MessageTemplate template = null;
    if(!bNew)  //需要从数据库中加载信息
    {
        template = MessageTemplate.GetTemplate(id);
        if(template==null) throw new NpsException(ErrorHelper.SYS_NOTEXIST, "Message template id=" + id);
    }  //if(!bNew)
%>

<html>
<head>
    <title><%=bNew?bundle.getString("MESSAGETEMPLATE_HTMLTITLE"):template.GetSubject()%></title>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel=stylesheet>

    <script language="Javascript">
      function fill_check()
      {
        if (document.inputFrm.subject.value.trim() == ""){
          alert("<%=bundle.getString("MESSAGETEMPLATE_ALERT_NO_SUBJECT")%>");
          document.inputFrm.subject.focus();
          return false;
        }
        if(document.inputFrm.scope.value=="1") {
            if(document.inputFrm.unit_id.value=="") {
              alert("<%=bundle.getString("MESSAGETEMPLATE_ALERT_NO_COMPANY")%>");
              document.inputFrm.unit_id.focus();
              return false;
            }
        }
        if(document.inputFrm.content.value == ""){
           alert("<%=bundle.getString("MESSAGETEMPLATE_ALERT_NO_CONTENT")%>");
           return false;
        }
        return true;
      }

      function f_save()
      {
         if(!fill_check()) return;
         document.inputFrm.act.value=0;
         document.inputFrm.action='messagetemplatesave.jsp';
         document.inputFrm.target="_self";
         document.inputFrm.submit();
      }

      function f_delete()
      {
        var r=confirm('<%=bundle.getString("MESSAGETEMPLATE_ALERT_DELETE")%>');
        if( r ==1 )
        {
          document.inputFrm.act.value=1;
          document.inputFrm.action='messagetemplatesave.jsp';
          document.inputFrm.target="_self";
          document.inputFrm.submit();
        }
      }
    </script>
</head>

<body leftmargin=20 topmargin=0>
<table border="0" class="positionbar" cellpadding="0" cellspacing="0">
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
     if(template!=null)
     {
         if(template.GetCreator().equals(user.GetId()) || user.GetUnitId().equals(template.GetUnitId()))
         {
             bSavable = true;
             bDeletable = true;
         }
     }
  }

  if(bSavable)
  {
%>
      <input type="button" class="button" name="save" value="<%=bundle.getString("MESSAGETEMPLATE_BUTTON_SAVE")%>" onClick="f_save()" >
<%
  }
  if(bDeletable)
  {
%>
       <input type="button" class="button" name="delete" value="<%=bundle.getString("MESSAGETEMPLATE_BUTTON_DELETE")%>" onClick="f_delete()" >
<%
  }
%>
  </tr>
</table>
<table width="100%" cellpadding="0" border="1" cellspacing="0">
    <form name="inputFrm" method="post" action="messagetemplatesave.jsp">
    <input type="hidden" name="act" value="0">
    <input type="hidden" name="id"  value="<%=Utils.Null2Empty(id)%>">

    <tr height="30">
        <td width="120" align=center><font color=red><%=bundle.getString("MESSAGETEMPLATE_SUBJECT")%></font></td>
        <td colspan="3">
          <input type="text" name="subject" style="width:600px" value= "<%= template==null?"":Utils.TransferToHtmlEntity(template.GetSubject()) %>">
            &nbsp;&nbsp;<font color="red"><%=bundle.getString("MESSAGETEMPLATE_SUBJECT_HINT")%></font>
        </td>
    </tr>
    <tr height="30">
		<td width="120" align=center><font color=red><%=bundle.getString("MESSAGETEMPLATE_STATUS")%></font></td>
		<td width=200>
            <select name="job_status">
                <option value="0" <%=(template!=null&&template.GetJobStatus()==0)?"selected":""%>><%=bundle.getString("MESSAGETEMPLATE_STATUS_PENDING")%></option>
                <option value="1" <%=(template!=null&&template.GetJobStatus()==1)?"selected":""%>><%=bundle.getString("MESSAGETEMPLATE_STATUS_AGREED")%></option>
                <option value="2" <%=(template!=null&&template.GetJobStatus()==2)?"selected":""%>><%=bundle.getString("MESSAGETEMPLATE_STATUS_REJECTED")%></option>
                <option value="3" <%=(template!=null&&template.GetJobStatus()==3)?"selected":""%>><%=bundle.getString("MESSAGETEMPLATE_STATUS_RETURNED")%></option>
                <option value="4" <%=(template!=null&&template.GetJobStatus()==4)?"selected":""%>><%=bundle.getString("MESSAGETEMPLATE_STATUS_FINISHED")%></option>
                <option value="5" <%=(template!=null&&template.GetJobStatus()==5)?"selected":""%>><%=bundle.getString("MESSAGETEMPLATE_STATUS_TERMINATED")%></option>
                <option value="6" <%=(template!=null&&template.GetJobStatus()==6)?"selected":""%>><%=bundle.getString("MESSAGETEMPLATE_STATUS_REVOKED")%></option>
                <option value="7" <%=(template!=null&&template.GetJobStatus()==7)?"selected":""%>><%=bundle.getString("MESSAGETEMPLATE_STATUS_DELETED")%></option>
            </select>
	    </td>
        <td width=80 align=center><font color=red><%=bundle.getString("MESSAGETEMPLATE_SCOPE")%></font></td>
        <td>
            <input type="radio" name="scope" value="0" <%=bNew||template.IsGlobal()?"checked":""%>><%=bundle.getString("MESSAGETEMPLATE_SCOPE_GLOBAL")%>
            <input type="radio" name="scope" value="1" <%=template!=null&&template.IsCompany()?"checked":""%>><%=bundle.getString("MESSAGETEMPLATE_SCOPE_UNIT")%>
            <select name="unit_id">
                <option></option>
                <%
                    List<Unit> units = user.GetUnits();
                    if(units!=null)
                    {
                        for(Unit unit: units)
                        {
                %>
                        <option value="<%=unit.GetId()%>" <% if(template!=null && unit.GetId().equals(template.GetUnitId())) out.print("selected"); %>><%=unit.GetName()%></option>
                <%
                        }
                    }
                %>
            </select>
        </td>
    </tr>
    <tr height=30>
        <td width=120 align=center><%=bundle.getString("MESSAGETEMPLATE_CREATOR")%></td>
        <td width=200><%= bNew?creator:template.GetCreatorName()%></td>
        <td  width=80 align=center><%=bundle.getString("MESSAGETEMPLATE_CREATEDATE")%></td>
        <td>
            <%= bNew?create_date:Utils.FormateDate(template.GetCreateDate(),"yyyy-MM-dd")%>
        </td>
    </tr>
    <tr height=30>
        <td colspan="4">&nbsp;&nbsp;
            <%=bundle.getString("MESSAGETEMPLATE_TYPE")%>
            <select name="message_type">
                <option value="0" <%=(template!=null&&template.IsEmail())?"selected":""%>><%=bundle.getString("MESSAGETEMPLATE_TYPE_EMAIL")%></option>
                <option value="1" <%=(template!=null&&template.IsSMS())?"selected":""%>><%=bundle.getString("MESSAGETEMPLATE_TYPE_SMS")%></option>
            </select>
            &nbsp;&nbsp;<font color=red><%=bundle.getString("MESSAGETEMPLATE_CONTENT_HINT")%></font>
        </td>
    </tr>
    <tr>
        <td colspan="4">
            <textarea name="content" cols="40" rows=20 style="width:98%;height:450px;"><% if(template!=null) out.print(template.GetContent());%></textarea>
        </td>
    </tr>
    </form>
</table>
</body>
</html>