<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.core.NpsWrapper" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.core.Config" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.processor.Job" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="nps.processor.JobScheduler" %>
<%@ page import="org.quartz.Trigger" %>
<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String job_id = request.getParameter("id");
    if(job_id!=null) job_id = job_id.trim();
    boolean bNew=(job_id==null || job_id.length()==0);

    String creator = user.GetName()+"("+user.GetDeptName()+ "/" +user.GetUnitName()+")";
    String create_date = nps.util.Utils.FormateDate(new java.util.Date(),"yyyy-MM-dd HH:mm:ss");

    NpsWrapper wrapper = null;
    Job job = null;
    int jobstatus = -1;
    try
    {
        if(!bNew)
        {
            wrapper = new NpsWrapper(user);
            job = Job.GetJob(wrapper.GetContext(),job_id);
            if(job==null) throw new NpsException(ErrorHelper.SYS_NOJOB);
        }

        ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_jobinfo",user.GetLocale(), Config.RES_CLASSLOADER);
%>

<html>
  <head>
    <title><%=bNew?bundle.getString("JOB_HTMLTILE"):job.GetName()%></title>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <script type="text/javascript" src="/editarea/edit_area_full.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>

    <script  language="javascript">
          editAreaLoader.init({
                            id: "id_job_code"
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

        function setUser()
        {
            var userid='',username='';
            var url = "popupwindow.jsp?src=selectuser.jsp";
            var rc = popupDialog(url);
            //var rc = window.showModalDialog(url);

            if(rc!=null && rc.length>0)
                f_adduser(rc[0],rc[1]);
        }

        function  f_adduser(userid,username)
        {
            document.jobFrm.job_runas.value = userid;
            document.jobFrm.job_runas_name.value = username;
        }
        
        function f_save()
        {
          var frm = document.jobFrm;
          if( frm.job_name.value.trim() == "")
          {
             alert( "<%=bundle.getString("JOB_ALERT_NAME_IS_NULL")%>");
             frm.job_name.focus();
             return false;
          }
          if( frm.job_site.value.trim() == "")
          {
             alert( "<%=bundle.getString("JOB_ALERT_SITE_IS_NULL")%>");
             frm.job_site_name.focus();
             return false;
          }
          if( frm.job_runas.value.trim() == "")
          {
             alert( "<%=bundle.getString("JOB_ALERT_RUNAS_IS_NULL")%>");
             frm.job_runas_name.focus();
             return false;
          }
          if( frm.job_cronexp.value.trim()=="")
          {
             alert( "<%=bundle.getString("JOB_ALERT_CRONEXP_IS_NULL")%>");
             frm.job_cronexp.focus();
             return false;
          }
          if( editAreaLoader.getValue("id_job_code").trim() == "")
          {
             alert( "<%=bundle.getString("JOB_ALERT_CODE_IS_NULL")%>");
             return false;
          }
          frm.job_code.value=editAreaLoader.getValue("id_job_code");
          frm.act.value='0';
          frm.action ="jobsave.jsp";
          frm.target="_self";
          frm.submit();
        }

        function f_delete()
        {
            var r = confirm("<%=bundle.getString("JOB_ALERT_DELETE")%>");
            if( r !=1 ) return false;

            var frm = document.jobFrm;
            frm.act.value='1';
            frm.action ="jobsave.jsp";
            frm.target="_self";
            frm.submit();
        }

        function f_pause()
        {
            var r = confirm("<%=bundle.getString("JOB_ALERT_PAUSE")%>");
            if( r !=1 ) return false;

            var frm = document.jobFrm;
            frm.act.value='2';
            frm.action ="jobsave.jsp";
            frm.target="_self";
            frm.submit();
        }

        function f_stop()
        {
            var r = confirm("<%=bundle.getString("JOB_ALERT_STOP")%>");
            if( r !=1 ) return false;

            var frm = document.jobFrm;
            frm.act.value='7';
            frm.action ="jobsave.jsp";
            frm.target="_self";
            frm.submit();
        }

        function f_resume()
        {
            var r = confirm("<%=bundle.getString("JOB_ALERT_RESUME")%>");
            if( r !=1 ) return false;

            var frm = document.jobFrm;
            frm.act.value='3';
            frm.action ="jobsave.jsp";
            frm.target="_self";
            frm.submit();            
        }

        function f_enable()
        {
            var r = confirm("<%=bundle.getString("JOB_ALERT_ENABLE")%>");
            if( r !=1 ) return false;

            var frm = document.jobFrm;
            frm.act.value='4';
            frm.action ="jobsave.jsp";
            frm.target="_self";
            frm.submit();
        }

        function f_disable()
        {
            var r = confirm("<%=bundle.getString("JOB_ALERT_DISABLE")%>");
            if( r !=1 ) return false;

            var frm = document.jobFrm;
            frm.act.value='5';
            frm.action ="jobsave.jsp";
            frm.target="_self";
            frm.submit();            
        }


        function f_run()
        {
            var frm = document.jobFrm;
            frm.act.value='6';
            frm.action ="jobsave.jsp";
            frm.target="_self";
            frm.submit();            
        }
       
        function showhelp()
        {
            window.open('/help/<%=user.GetLocale().getLanguage()%>/js.html');
        }

        function show_exphelp()
        {
            window.open("/help/<%=user.GetLocale().getLanguage()%>/js_cronexp.html");
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
           boolean bResumable = false;
           boolean bPausable = false;
           boolean bStoppable = false; 
           if(bNew)
           {
               if(user.IsLocalAdmin() || user.IsSysAdmin())  bSavable = true;
               bDeletable = false;
               bEnabled = false;
               bDisabled = false;               
               bResumable = false;
               bPausable = false;
               bStoppable = false;
               jobstatus = Trigger.STATE_NONE;
           }
           else
           {
               jobstatus = JobScheduler.GetStatus(job_id);
               
               //仅在以下情况下可以修改
               //1.系统管理员
               //2.作者
               if(user.IsSysAdmin() || user.GetId().equals(job.GetCreator()))  bSavable = true;
               if(user.IsSysAdmin() || user.GetId().equals(job.GetCreator()))  bDeletable = true;
               if(user.IsSysAdmin() || user.GetId().equals(job.GetCreator()))
               {
                   if(job.IsEnable())
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

               if(user.IsSysAdmin() || user.GetId().equals(job.GetCreator()))
               {
                   if(jobstatus== Trigger.STATE_PAUSED || jobstatus == Trigger.STATE_NONE)
                       bResumable = true;

                   if(jobstatus != Trigger.STATE_PAUSED && jobstatus!=Trigger.STATE_NONE)
                       bPausable = true;

                   if(jobstatus==Trigger.STATE_BLOCKED || jobstatus==Trigger.STATE_NORMAL)
                       bStoppable = true;
               }
           }

           if(bSavable)
           {
      %>
           <input type="button" name="okbtn" value="<%=bundle.getString("JOB_BUTTON_SAVE")%>" class="button" onclick="f_save()">
<%
           }
           if(bDeletable)
           {
%>
           <input type="button" name="deletebtn" value="<%=bundle.getString("JOB_BUTTON_DELETE")%>" class="button" onclick="f_delete()">
<%
           }
           if(bEnabled)
           {
%>
           <input type="button" name="enablebtn"  value="<%=bundle.getString("JOB_BUTTON_ENABLE")%>" class="button" onclick="f_enable()">
<%
           }
           if(bDisabled)
           {
%>
           <input type="button" name="disablebtn"  value="<%=bundle.getString("JOB_BUTTON_DISABLE")%>" class="button" onclick="f_disable()">
           <input type="button" name="runbtn"  value="<%=bundle.getString("JOB_BUTTON_RUN_IMMEDIATELY")%>" class="button" onclick="f_run()">            

<%
           }
           if(bResumable)
           {
%>
           <input type="button" name="resumebtn"  value="<%=bundle.getString("JOB_BUTTON_RESUME")%>" class="button" onclick="f_resume()">
<%
           }
           if(bPausable)
           {
%>
           <input type="button" name="pausebtn"  value="<%=bundle.getString("JOB_BUTTON_PAUSE")%>" class="button" onclick="f_pause()">
<%
           }
           if(bStoppable)
           {
%>
            <input type="button" name="stopbtn"  value="<%=bundle.getString("JOB_BUTTON_STOP")%>" class="button" onclick="f_stop()">
<%
           }
%>
           <input type="button" name="closebtn" value="<%=bundle.getString("JOB_BUTTON_CLOSE")%>" class="button" onclick="javascript:window.close();">
        </td>
      </tr>
    </table>
  <fieldset>
  <form name="jobFrm" method="post" action ="jobsave.jsp">
   <table width="100%" cellpadding = "0" cellspacing = "0" border="1">
     <input type="hidden" name="job_id" value="<%= job_id==null?"":job_id %>">
     <input type="hidden" name="act" value="0">
     <tr height="25">
       <td width=120 align=center><font color="red"><%=bundle.getString("JOB_NAME")%></font></td>
       <td colspan="3">
         <input type=text name="job_name" value="<%= job==null?"":job.GetName() %>" size=50>
       </td>
       <td width=120 align=center><%=bundle.getString("JOB_ID")%></td>
       <td>
         <%= job_id==null?"NEW":job_id%>
       </td>
     </tr>
     <tr height="25">
       <td width=120 align=center><font color="red"><%=bundle.getString("JOB_SITE")%></font></td>
       <td>
           <select name="job_site">
<%
    java.util.Hashtable sites = user.GetOwnSites();
    if((sites!=null) && !sites.isEmpty())
    {
       java.util.Enumeration sitekeys = sites.keys();
       while(sitekeys.hasMoreElements())
       {
         String site_id = (String)sitekeys.nextElement();
         String site_caption = (String)sites.get(site_id);
%>
         <option value="<%=site_id%>" <% if(job!=null && site_id.equals(job.GetDefaultSiteId())) out.print("selected"); %>><%=site_caption%></option>           
<%
      }
    }
%>
        </select>
       </td>
       <td width=120 align=center><font color="red"><%=bundle.getString("JOB_RUNAS")%></font></td>
       <td>
           <input type="hidden" name="job_runas" value="<%= job==null?"":job.GetUserRunAs()%>">
           <input type="text" name="job_runas_name" readonly value="<%= job==null?"":job.GetUserRunAsName()%>"
                onclick="<%=bSavable?"setUser()":""%>">
           <%
               if(bSavable)
               {
           %>
           <input type="button" class="button" name="userbtn" value="<%=bundle.getString("JOB_BUTTON_RUNAS")%>" onclick="setUser()">
           <%
               }
           %>
       </td>
       <td width=120 align=center><%=bundle.getString("JOB_STATUS")%></td>
       <td>
           <%
               if(job==null)
               {
                 out.print(bundle.getString("JOB_HINT_STATUS_NEW"));
               }
               else
               {
                   if(job.IsEnable())
                       out.print(bundle.getString("JOB_HINT_ENABLE"));
                   else
                       out.print(bundle.getString("JOB_HINT_DISABLE"));
               }
               out.print("&nbsp;&nbsp;"); 
               switch(jobstatus)
               {
                   case Trigger.STATE_BLOCKED:
                       out.print(bundle.getString("JOB_HINT_STATUS_BLOCKED"));
                       break;
                   case Trigger.STATE_COMPLETE:
                       out.print(bundle.getString("JOB_HINT_STATUS_BLOCKED"));
                       break;
                   case Trigger.STATE_ERROR:
                       out.print(bundle.getString("JOB_HINT_STATUS_ERROR"));
                       break;
                   case Trigger.STATE_NONE:
                       out.print(bundle.getString("JOB_HINT_STATUS_NONE"));                       
                       break;
                   case Trigger.STATE_NORMAL:
                       out.print(bundle.getString("JOB_HINT_STATUS_NORMAL"));
                       break;
                   case Trigger.STATE_PAUSED:
                       out.print(bundle.getString("JOB_HINT_STATUS_PAUSED"));
                       break;
               }
             %>
       </td>
     </tr>
     <tr height="25">
       <td width=120 align=center><font color="red"><%=bundle.getString("JOB_CRONEXP")%></font></td>
       <td colspan="5">
           <input type="text" name="job_cronexp" value="<%=job==null?"":job.GetExp()%>" size="100" style="width:200px">
           <input type="button" class="button" value="<%=bundle.getString("JOB_BUTTON_CRONEXP_HELP")%>" onclick="show_exphelp()">
           <br>Seconds Minutes Hours Day Month Week Year(Optional)

       </td>
    </tr>
    <tr height="25">
       <td width=120 align=center><%=bundle.getString("JOB_CREATOR")%></td>
       <td><%=job==null?creator:job.GetCreatorName()%></td>
       <td width=120 align=center><%=bundle.getString("JOB_CREATEDATE")%></td>
       <td colspan="3"><%=job==null?create_date:job.GetCreateDate()%></td>
    </tr>
    <tr height="25">
      <td width=120 align=center><%=bundle.getString("JOB_LASTRUN_SERVER")%></td>
      <td><%=(job==null || job.GetLastServer()==null)?"&nbsp;":job.GetLastServer()%></td>
      <td width=120 align=center><%=bundle.getString("JOB_LASTRUN_STATE")%></td>
      <td colspan="3">
          <%
              if(job!=null)
              {
                  switch(job.GetLastRunState())
                  {
                      case 0:
                          out.print(bundle.getString("JOB_LASTRUN_STATUS_NORMAL"));
                          break;
                      case 1:
                          out.print(bundle.getString("JOB_LASTRUN_STATUS_ERROR"));
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
      <td width=120 align=center><%=bundle.getString("JOB_LASTRUN_DATE")%></td>
      <td><%=(job==null || job.GetLastRunDate()==null)?"&nbsp;":Utils.FormateDate(job.GetLastRunDate(),"yyyy-MM-dd HH:mm:ss")%></td>
      <td width=120 align=center><%=bundle.getString("JOB_LASTRUN_TIME")%></td>
      <td colspan="3"><%=job==null?"&nbsp;":String.valueOf(job.GetLastRunTime())%>ms</td>
   </tr>
 </table>
 <table width="100%" cellpadding = "0" cellspacing = "0" border="0">
 <tr height="25">
     <td>
         <%=bundle.getString("JOB_LANG")%>
         <select name="job_lang">
             <option value="0" <% if(job!=null && job.GetLang()==0) out.print("selected");%>>JavaScript</option>
             <option value="1" <% if(job!=null && job.GetLang()==1) out.print("selected");%>>DynamicJava</option>
         </select>
         &nbsp;&nbsp;&nbsp;&nbsp;
         <input type="button" name="helpbtn"  value="<%=bundle.getString("JOB_BUTTON_JS_HELP")%>" class="button" onclick="javascript:showhelp();">
    </td>
 </tr>
 <tr>
   <td>
       <div id="src" style="height:410px">
         <textarea id="id_job_code" name="job_code" style="width:996px;height:100%;"><% if(job!=null) out.print(job.GetCode()); %></textarea>
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
    catch(Exception e)
    {
        throw e;
    }
    finally
    {
        if(wrapper!=null) wrapper.Clear();
    }
%>