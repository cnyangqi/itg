<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.Enumeration" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.core.*" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.util.Utils" %>
<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String id=request.getParameter("id");//如果为null，将再保存时使用序列生成ID号
    if(id!=null) id=id.trim();

    String site_id = request.getParameter("site_id");
    if(site_id!=null) site_id = site_id.trim();

    String top_id = request.getParameter("top_id");
    if(top_id!=null) top_id = top_id.trim();

    if(id==null || site_id==null || top_id==null || id.length()==0 || site_id.length()==0 || top_id.length()==0)
       throw new NpsException(ErrorHelper.INPUT_ERROR);


    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_customartinfo",user.GetLocale(), nps.core.Config.RES_CLASSLOADER);

    NpsWrapper wrapper = null;
    Site site = null;
    TopicTree tree = null;
    Topic top = null;
    CustomArticle art = null;

    try
    {
        wrapper = new NpsWrapper(user,site_id);
        site = wrapper.GetSite();
        if(site==null) throw new NpsException(ErrorHelper.SYS_NOSITE);
        tree = site.GetTopicTree();
        if(tree==null) throw new NpsException(ErrorHelper.SYS_NOTOPICTREE);
        top = tree.GetTopic(top_id);
        if(top==null) throw new NpsException(ErrorHelper.SYS_NOTOPIC);
        art = wrapper.GetArticle(id,top);
        if(art==null)  throw new NpsException(ErrorHelper.SYS_NOARTICLE);
%>

<html>
<head>
    <title><%=art.GetTitle()%></title>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <script type="text/javascript" src="/FCKeditor/fckeditor.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>

    <script language="Javascript">
      function publishArticle()
      {
          document.inputFrm.act.value=3;
          document.inputFrm.submit();
      }

      function timedPublish()
      {
          document.getElementById("div_time").style.display = "block";
      }

      function submitTimedPublish()
      {
          if (document.inputFrm.job_year.value.trim() == ""){
            alert("<%=bundle.getString("CUSTOM_ALERT_NO_YEAR")%>");
            document.inputFrm.job_year.focus();
            return;
          }
          if (document.inputFrm.job_month.value.trim() == ""){
            alert("<%=bundle.getString("CUSTOM_ALERT_NO_MONTH")%>");
            document.inputFrm.job_month.focus();
            return;
          }
          if (document.inputFrm.job_day.value.trim() == ""){
            alert("<%=bundle.getString("CUSTOM_ALERT_NO_DAY")%>");
            document.inputFrm.job_day.focus();
            return;
          }
          if (document.inputFrm.job_hour.value.trim() == ""){
            alert("<%=bundle.getString("CUSTOM_ALERT_NO_HOUR")%>");
            document.inputFrm.job_hour.focus();
            return;
          }
          if (document.inputFrm.job_minute.value.trim() == ""){
            alert("<%=bundle.getString("CUSTOM_ALERT_NO_MINUTE")%>");
            document.inputFrm.job_minute.focus();
            return;
          }
          if (document.inputFrm.job_second.value.trim() == ""){
            alert("<%=bundle.getString("CUSTOM_ALERT_NO_SECOND")%>");
            document.inputFrm.job_second.focus();
            return;
          }
          document.inputFrm.act.value=7;
          document.inputFrm.submit();
      }

      function cancelTimedPublish()
      {
          document.getElementById("div_time").style.display = "none";
      }
      
      function cancelArticle()
      {
          document.inputFrm.act.value=6;
          document.inputFrm.submit();
      }
    </script>
</head>

<body leftmargin=20 topmargin=0>

<table border="0" class="positionbar" cellpadding="0" cellspacing="0">
  <tr>
    <td>&nbsp;
<%
    //只有版主、站点管理员、管理员可以发布
    //一般由后台服务定时扫描发布，该方案应作为临时（紧急）措施使用
    boolean bPublishable  = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(site_id) || user.IsSysAdmin();  //是否显示发布按钮

    if(bPublishable)
    {
        if(art.GetState()==3)
        {
%>
       <input type="button" class="button" name="submit" value="<%=bundle.getString("CUSTOM_BUTTON_REPUBLISH")%>" onClick="javascript:publishArticle();" >
       <input type="button" class="button" name="submit" value="<%=bundle.getString("CUSTOM_BUTTON_CANCEL")%>" onClick="javascript:cancelArticle();" >
<%
        }
        else
        {
%>
        <input type="button" class="button" name="submit" value="<%=bundle.getString("CUSTOM_BUTTON_TIMED_PUBLISH")%>" onClick="timedPublish()" >
        <input type="button" class="button" name="submit" value="<%=bundle.getString("CUSTOM_BUTTON_PUBLISH")%>" onClick="javascript:publishArticle();" >
<%
        }
    }
%>
       <input type="button" class="button" name="close" value="<%=bundle.getString("CUSTOM_BUTTON_CLOSE")%>" onclick="javascript:window.close();">
    </td>
  </tr>
</table>

<table width="100%" cellpadding="0" border="1" cellspacing="0">
 <form name="inputFrm" method="post" action="customartsave.jsp">
    <input type="hidden" name="id"  value="<%= id %>">
    <input type="hidden" name="site_id" value="<%= site_id %>">
    <input type="hidden" name="top_id" value="<%= top_id %>">
    <input type="hidden" name="act" value="0">

    <tr><td colspan="2">
    <div id="div_time" style="display:none">
        <table align="center" width="400" cellpadding="0" border="1" cellspacing="0">
            <tr height="30">
                <td align="center"><input type="text" name="job_year" maxlength="4" style="width:60px"></td>
                <td align="center"><input type="text" name="job_month" maxlength="2" style="width:30px"></td>
                <td align="center"><input type="text" name="job_day" maxlength="2" style="width:30px"></td>
                <td align="center"><input type="text" name="job_hour" maxlength="2" style="width:30px"></td>
                <td align="center"><input type="text" name="job_minute" maxlength="2" style="width:30px"></td>
                <td align="center"><input type="text" name="job_second" maxlength="2" style="width:30px"></td>
            </tr>
            <tr height="30">
                <td align="center"><font color="red"><b><%=bundle.getString("CUSTOM_JOB_YEAR")%></b></font></td>
                <td align="center"><font color="red"><b><%=bundle.getString("CUSTOM_JOB_MONTH")%></b></font></td>
                <td align="center"><font color="red"><b><%=bundle.getString("CUSTOM_JOB_DAY")%></b></font></td>
                <td align="center"><font color="red"><b><%=bundle.getString("CUSTOM_JOB_HOUR")%></b></font></td>
                <td align="center"><font color="red"><b><%=bundle.getString("CUSTOM_JOB_MINUTE")%></b></font></td>
                <td align="center"><font color="red"><b><%=bundle.getString("CUSTOM_JOB_SECOND")%></b></font></td>
            </tr>
            <tr height="30">
                <td colspan="6" align="center">
                    <input type="button" class="button" name="okbtn" value="<%=bundle.getString("CUSTOM_BUTTON_TIMED_OK")%>" onclick="submitTimedPublish()">
                    <input type="button" class="button" name="cancelbtn" value="<%=bundle.getString("CUSTOM_BUTTON_TIMED_CANCEL")%>" onclick="cancelTimedPublish()">
                </td>
            </tr>
        </table>
    </div>
    </td></tr>
</form>    
    <tr height="30">
        <td width="120" align=center><b><%=bundle.getString("CUSTOM_TITLE")%></b></td>
        <td >
          <%= art.GetTitle() %>
        </td>
    </tr>
    <tr height="30">
        <td width="120" align=center><b><%=bundle.getString("CUSTOM_TOPIC")%></b></td>
        <td>
            <%= top.GetName() %>
        </td>
    </tr>
    <tr height="30">
        <td width="120" align=center><b><%=bundle.getString("CUSTOM_CREATEDATE")%></b></td>
        <td>
            <%= art.GetCreateDate()%>
        </td>
    </tr>
    <tr height="30">
        <td width="120" align=center><b><%=bundle.getString("CUSTOM_PUBLISHDATE")%></b></td>
        <td><%=art.GetPublishDate()==null?"&nbsp;":art.GetPublishDate()%></td>
    </tr>
    <%
        Enumeration fieldname_list = art.GetFieldNames();
        if(fieldname_list!=null)
        {
            while(fieldname_list.hasMoreElements())
            {
                String fieldname = (String)fieldname_list.nextElement();
    %>
      <tr height="30">
        <td width="120" align="center"><b><%= fieldname %></b> </td>
        <td> <%= Utils.Null2Empty(art.GetField(fieldname,-1)) %> </td>
      </tr>
    <%
            }
        }
    %>
</table>

</body>
</html>

<%
    }
    catch(Exception e)
    {
        throw e;
    }
    finally
    {
        if(art!=null) art.Clear();
        if(wrapper!=null) wrapper.Clear();        
    }
%>
