<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.core.NpsWrapper" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.core.Config" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="nps.core.Trigger" %>
<%@ page import="nps.core.TriggerManager" %>
<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String trigger_id = request.getParameter("id");
    if(trigger_id!=null) trigger_id = trigger_id.trim();
    boolean bNew=(trigger_id==null || trigger_id.length()==0);

    String creator = user.GetName()+"("+user.GetDeptName()+ "/" +user.GetUnitName()+")";
    String create_date = nps.util.Utils.FormateDate(new java.util.Date(),"yyyy-MM-dd HH:mm:ss");

    NpsWrapper wrapper = null;
    Trigger trigger = null;
    try
    {
        if(!bNew)
        {
            wrapper = new NpsWrapper(user);
            TriggerManager manager = TriggerManager.LoadTriggers(wrapper.GetContext());
            trigger = manager.GetTrigger(wrapper.GetContext(),trigger_id);
            if(trigger==null) throw new NpsException(ErrorHelper.SYS_NOTRIGGER);
        }

        ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_triggerinfo",user.GetLocale(), Config.RES_CLASSLOADER);
%>

<html>
  <head>
    <title><%=bNew?bundle.getString("TRIGGER_HTMLTILE"):trigger.GetName()%></title>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <script type="text/javascript" src="/editarea/edit_area_full.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>

    <script  language="javascript">
          editAreaLoader.init({
                            id: "id_trigger_code"
                            ,start_highlight: true
                            ,allow_toggle: false
                            ,font_size: 10
                            ,allow_resize: "no"
                            ,language: "en"
                            ,syntax: "js"
                            ,toolbar: "search, go_to_line, |, undo, redo, |, select_font"
                            ,EA_load_callback: "editor_ready"
                        });
        window.onerror=function(){return true};
    </script>

    <script language="javascript">
        function editor_ready(id) {
            document.getElementById("pbar").style.display = 'block';
        }
      function popupDialog(url)
      {
         var isMSIE= (navigator.appName == "Microsoft Internet Explorer");

         if (isMSIE)
         {
             return window.showModalDialog(url);
         }
         else
         {
             var win = window.open(url, "mcePopup","dialog=yes,modal=yes" );
             win.focus();
         }
     }

      function selectTopics()
      {
          var rc = popupDialog("selectalltopic.jsp");
    	  if (rc == null || rc.length==0) return false;

          f_settopic(rc[0],rc[1],rc[2],rc[3]);
      }

      function f_settopic(siteid,sitename,topid,topname)
      {
          document.triggerFrm.siteid.value= siteid;
    	  document.triggerFrm.topic.value = topname + "(" + sitename + ")";
    	  document.triggerFrm.topid.value = topid;
      }
      
        function f_save()
        {
          var frm = document.triggerFrm;
          if( frm.trigger_name.value.trim() == "")
          {
             alert( "<%=bundle.getString("TRIGGER_ALERT_NAME_IS_NULL")%>");
             frm.trigger_name.focus();
             return false;
          }
          if( frm.topid.value.trim() == "")
          {
             alert( "<%=bundle.getString("TRIGGER_ALERT_TOPIC_IS_NULL")%>");
             frm.topic.focus();
             return false;
          }
          if( editAreaLoader.getValue("id_trigger_code").trim() == "")
          {
             alert( "<%=bundle.getString("TRIGGER_ALERT_CODE_IS_NULL")%>");
             return false;
          }
          frm.trigger_code.value=editAreaLoader.getValue("id_trigger_code");
          frm.act.value='0';
          frm.action ="triggersave.jsp";
          frm.target="_self";
          frm.submit();
        }

        function f_delete()
        {
            var r = confirm("<%=bundle.getString("TRIGGER_ALERT_DELETE")%>");
            if( r !=1 ) return false;

            var frm = document.triggerFrm;
            frm.act.value='1';
            frm.action ="triggersave.jsp";
            frm.target="_self";
            frm.submit();
        }

        function f_enable()
        {
            var r = confirm("<%=bundle.getString("TRIGGER_ALERT_ENABLE")%>");
            if( r !=1 ) return false;

            var frm = document.triggerFrm;
            frm.act.value='4';
            frm.action ="triggersave.jsp";
            frm.target="_self";
            frm.submit();
        }

        function f_disable()
        {
            var r = confirm("<%=bundle.getString("TRIGGER_ALERT_DISABLE")%>");
            if( r !=1 ) return false;

            var frm = document.triggerFrm;
            frm.act.value='5';
            frm.action ="triggersave.jsp";
            frm.target="_self";
            frm.submit();
        }

        function showhelp()
        {
            window.open('/help/<%=user.GetLocale().getLanguage()%>/js.html');
        }
    </script>
  </head>

  <body leftmargin="20">
  <table id="pbar" width="100%" border="0" cellspacing="0" cellpadding="0" style="display:none">
      <tr height=30>
        <td>&nbsp;
      <%
           boolean bSavable = false;
           boolean bDeletable = false;
           boolean bEnabled = false;
           boolean bDisabled = false;
           if(bNew)
           {
               if(user.IsLocalAdmin() || user.IsSysAdmin())  bSavable = true;
               bDeletable = false;
               bEnabled = false;
               bDisabled = false;
           }
           else
           {
               //仅在以下情况下可以修改
               //1.系统管理员
               //2.作者
               if(user.IsSysAdmin() || user.GetId().equals(trigger.GetCreator()))  bSavable = true;
               if(user.IsSysAdmin() || user.GetId().equals(trigger.GetCreator()))  bDeletable = true;
               if(user.IsSysAdmin() || user.GetId().equals(trigger.GetCreator()))
               {
                   if(trigger.IsEnable())
                   {
                       bEnabled = false;
                       bDisabled = true;
                   }
                   else
                   {
                       bEnabled = true;
                       bDisabled = false;
                   }
               }             
           }

           if(bSavable)
           {
      %>
           <input type="button" name="okbtn" value="<%=bundle.getString("TRIGGER_BUTTON_SAVE")%>" class="button" onclick="f_save()">
<%
           }
           if(bDeletable)
           {
%>
           <input type="button" name="deletebtn" value="<%=bundle.getString("TRIGGER_BUTTON_DELETE")%>" class="button" onclick="f_delete()">
<%
           }
           if(bEnabled)
           {
%>
           <input type="button" name="enablebtn"  value="<%=bundle.getString("TRIGGER_BUTTON_ENABLE")%>" class="button" onclick="f_enable()">
<%
           }
           if(bDisabled)
           {
%>
           <input type="button" name="disablebtn"  value="<%=bundle.getString("TRIGGER_BUTTON_DISABLE")%>" class="button" onclick="f_disable()">
<%
           }
%>
           <input type="button" name="closebtn" value="<%=bundle.getString("TRIGGER_BUTTON_CLOSE")%>" class="button" onclick="javascript:window.close();">
        </td>
      </tr>
    </table>
  <fieldset>
  <form name="triggerFrm" method="post" action ="triggersave.jsp">
   <table width="100%" cellpadding = "0" cellspacing = "0" border="1">
     <input type="hidden" name="trigger_id" value="<%= trigger_id==null?"":trigger_id %>">
     <input type="hidden" name="act" value="0">
     <tr height="25">
       <td width=120 align=center><font color="red"><%=bundle.getString("TRIGGER_NAME")%></font></td>
       <td>
         <input type=text name="trigger_name" value="<%= trigger==null?"":trigger.GetName() %>" size=50>
       </td>
        <td width=120 align=center><%=bundle.getString("TRIGGER_STATUS")%></td>
        <td width="350">
             <%
                 if(trigger==null)
                 {
                   out.print(bundle.getString("TRIGGER_HINT_STATUS_NEW"));
                 }
                 else
                 {
                     if(trigger.IsEnable())
                         out.print(bundle.getString("TRIGGER_HINT_ENABLE"));
                     else
                         out.print(bundle.getString("TRIGGER_HINT_DISABLE"));
                 }
               %>
        </td>
     </tr>
     <tr height="25">
       <td width=120 align=center><font color="red"><%=bundle.getString("TRIGGER_TOPIC")%></font></td>
       <td>
          <input type="text" name="topic" size=40 value="<%= trigger==null?"":trigger.GetTopic().GetName() +"(" + trigger.GetTopic().GetSite().GetName() + ")" %>" readonly>
<%
   if(bSavable)
   {
%>
          <input type="button" value="<%=bundle.getString("TRIGGER_BUTTON_SELTOPIC")%>" class="button" name="btn_topic" onclick='javascript:selectTopics();'>
<%
   }
%>
          <input type="hidden" name="siteid" value="<%= trigger==null?"":trigger.GetTopic().GetSiteId() %>">
          <input type="hidden" name="topid" value="<%= trigger==null?"":trigger.GetTopic().GetId() %>">
       </td>
        <td width=120 align=center><font color="red"><%=bundle.getString("TRIGGER_EVENT")%></font></td>
        <td>
            <select name="trigger_event">
                <option value="0" <% if(trigger!=null && trigger.GetEvent()==0) out.print("selected"); %>><%=bundle.getString("TRIGGER_EVENT_INSERT")%></option>
                <option value="1" <% if(trigger!=null && trigger.GetEvent()==1) out.print("selected"); %>><%=bundle.getString("TRIGGER_EVENT_UPDATE")%></option>
                <option value="2" <% if(trigger!=null && trigger.GetEvent()==2) out.print("selected"); %>><%=bundle.getString("TRIGGER_EVENT_READY")%></option>
                <option value="3" <% if(trigger!=null && trigger.GetEvent()==3) out.print("selected"); %>><%=bundle.getString("TRIGGER_EVENT_PUBLISH")%></option>
                <option value="4" <% if(trigger!=null && trigger.GetEvent()==4) out.print("selected"); %>><%=bundle.getString("TRIGGER_EVENT_CANCEL")%></option>
                <option value="5" <% if(trigger!=null && trigger.GetEvent()==5) out.print("selected"); %>><%=bundle.getString("TRIGGER_EVENT_DELETE")%></option>
              </select>  
        </td>
     </tr>
    <tr height="25">
       <td width=120 align=center><%=bundle.getString("TRIGGER_CREATOR")%></td>
       <td><%=trigger==null?creator:trigger.GetCreatorName()%></td>
       <td width=120 align=center><%=bundle.getString("TRIGGER_CREATEDATE")%></td>
       <td><%=trigger==null?create_date:trigger.GetCreateDate()%></td>
    </tr>
    <tr height="25">
      <td width=120 align=center><%=bundle.getString("TRIGGER_LASTRUN_SERVER")%></td>
      <td><%=(trigger==null || trigger.GetLastServer()==null)?"&nbsp;":trigger.GetLastServer()%></td>
      <td width=120 align=center><%=bundle.getString("TRIGGER_LASTRUN_STATE")%></td>
      <td>
          <%
              if(trigger!=null)
              {
                  switch(trigger.GetLastRunState())
                  {
                      case 0:
                          out.print(bundle.getString("TRIGGER_LASTRUN_STATUS_NORMAL"));
                          break;
                      case 1:
                          out.print(bundle.getString("TRIGGER_LASTRUN_STATUS_ERROR"));
                          break;
                  }
              }
              else
              {
                  out.print("&nbsp;");
              }
          %>
      </td>
   </tr>
   <tr height="25">
      <td width=120 align=center><%=bundle.getString("TRIGGER_LASTRUN_DATE")%></td>
      <td><%=(trigger==null || trigger.GetLastRunDate()==null)?"&nbsp;":Utils.FormateDate(trigger.GetLastRunDate(),"yyyy-MM-dd HH:mm:ss")%></td>
      <td width=120 align=center><%=bundle.getString("TRIGGER_LASTRUN_TIME")%></td>
      <td><%=trigger==null?"&nbsp;":String.valueOf(trigger.GetLastRunTime())%>ms</td>
   </tr>
 </table>
 <table width="100%" cellpadding = "0" cellspacing = "0" border="0">
 <tr height="25">
     <td>
         <%=bundle.getString("TRIGGER_LANG")%>
         <select name="trigger_lang">
             <option value="0" <% if(trigger!=null && trigger.GetLang()==0) out.print("selected");%>>JavaScript</option>
             <option value="1" <% if(trigger!=null && trigger.GetLang()==1) out.print("selected");%>>DynamicJava</option>
         </select>
         &nbsp;&nbsp;&nbsp;&nbsp;
         <input type="button" name="helpbtn"  value="<%=bundle.getString("TRIGGER_BUTTON_JS_HELP")%>" class="button" onclick="javascript:showhelp();">
    </td>
 </tr>
 <tr>
   <td>
       <div id="src" style="height:410px">
         <textarea id="id_trigger_code" name="trigger_code" style="width:996px;height:100%;"><% if(trigger!=null) out.print(trigger.GetCode()); %></textarea>
       </div>
   </td>
 </tr>
 </table>
 </form>
</fieldset>
</body>
</html>
<%
    }
    finally
    {
        if(wrapper!=null) wrapper.Clear();
    }
%>