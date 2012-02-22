<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.nio.charset.Charset" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.quartz.Trigger" %>
<%@ page import="nps.core.NpsWrapper" %>
<%@ page import="nps.core.Config" %>
<%@ page import="nps.processor.Job" %>
<%@ page import="nps.processor.JobScheduler" %>
<%@ page import="nps.job.crawler.Task" %>
<%@ page import="nps.job.crawler.URLGenerator" %>
<%@ page import="nps.job.crawler.Tag" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.util.Utils" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String task_id = request.getParameter("id");
    if(task_id!=null) task_id = task_id.trim();
    boolean bNew = (task_id==null || task_id.length()==0);

    String creator = user.GetName()+"("+user.GetDeptName()+ "/" +user.GetUnitName()+")";
    String create_date = nps.util.Utils.FormateDate(new java.util.Date(),"yyyy-MM-dd HH:mm:ss");

    NpsWrapper wrapper = null;
    Task task = null;
    int jobstatus = -1;
    try
    {
        if(!bNew)
        {
            wrapper = new NpsWrapper(user);
            task = Task.LoadTask(wrapper.GetContext(), task_id);
            if(task==null) throw new NpsException(ErrorHelper.CRAWLER_NO_TASK);
        }

        ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_crawltask",user.GetLocale(), Config.RES_CLASSLOADER);
%>

<html>
  <head>
    <title><%=bNew?bundle.getString("TASK_HTMLTILE"):task.GetName()%></title>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>

    <script language="javascript">
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
            var url = "/config/selectuser.jsp";
            var rc = popupDialog(url);
            if(rc!=null && rc.length>0) f_adduser(rc[0],rc[1]);
        }

        function  f_adduser(userid,username)
        {
            document.taskFrm.task_runas.value = userid;
            document.taskFrm.task_runas_name.value = username;
        }

        function onchange_site(siteid)
        {
           document.taskFrm.topic.value = "";
           document.taskFrm.top_id.value = "";
        }

        function selectTopics()
        {
            var siteid = document.taskFrm.site.value;
            if(siteid=="")
            {
                alert("<%=bundle.getString("TASK_ALERT_SITE_IS_NULL")%>");
                return false;
            }
            var rc = popupDialog("selecttopic.jsp?siteid=" + siteid);
            if (rc == null || rc.length==0) return false;
            f_settopic(rc[0],rc[1],rc[2],rc[3]);
        }

        function f_settopic(siteid,sitename,topid,topname)
        {
            document.taskFrm.topic.value = topname;
            document.taskFrm.top_id.value = topid;
        }

        function onchange_savemode(mode)
        {
            if(mode=="0")
            {
                document.getElementById("savemode_sql").style.display = "none";
                document.getElementById("savemode_article").style.display = "block";
            }
            else
            {
                document.getElementById("savemode_sql").style.display = "block";
                document.getElementById("savemode_article").style.display = "none";
            }
        }

        function add_page(task_id)
        {
            if(task_id=="")
            {
                alert("<%=bundle.getString("TASK_ALERT_SAVEFIRST")%>");
                return false;
            }

            var url = 'popupwindow.jsp?src='+escape("task_page.jsp?task="+task_id);
            var rc = popupDialog(url);
            if (rc == null || rc.length==0) return false;
            f_addpage(rc[0],rc[1]);            
        }

        function open_page(page_id)
        {
            var url = 'popupwindow.jsp?src='+escape("task_page.jsp?id="+page_id);
            popupDialog(url);
        }

        function f_addpage(id,url)
        {
            var tbody = document.getElementById("PageTbl").getElementsByTagName("TBODY")[0];
            var row = document.createElement("TR");

            var td1 = document.createElement("Td");
            var input1=document.createElement("INPUT");
            input1.setAttribute("name", "page_id" );
            input1.setAttribute("type", "checkbox");
            input1.setAttribute("value", id);
            td1.appendChild(input1);
            row.appendChild(td1);

            td1 = document.createElement("TD");
            td1.innerHTML = "<a href=\"javascript:open_page(" + id + ")\">" + url + "</a>";
            row.appendChild(td1);

            tbody.appendChild(row);
        }

        function del_page()
        {
            var rows = document.getElementsByName("page_id");
            if( rows == null) return false;

            var r = confirm("<%=bundle.getString("TASK_ALERT_DELETE_PAGE")%>");
            if( r !=1 ) return false;

            var has_data = false;
            for(var i = 0; i < rows.length; i++)
            {
                if(rows[i].checked)
                {
                    has_data = true;
                    break;
                }
            }

            document.taskFrm.act.value='del_page';
            document.taskFrm.action ="task_save.jsp";
            document.taskFrm.target="_self";
            document.taskFrm.submit();
        }

       function open_tag(tag_id)
       {
            var url = 'popupwindow.jsp?src='+escape("task_tag.jsp?id="+tag_id);
            popupDialog(url);
       }

       function add_tag(task_id)
       {
           if(task_id=="")
           {
               alert("<%=bundle.getString("TASK_ALERT_SAVEFIRST")%>");
               return false;
           }

            var url = 'popupwindow.jsp?src='+escape("task_tag.jsp?task="+task_id);
            var rc = popupDialog(url);
            if (rc == null || rc.length==0) return false;
            f_addtag(rc[0],rc[1],rc[2],rc[3],rc[4]);
       }

       function f_addtag(id,title,tagname,tag_start,tag_end)
       {
           var tbody = document.getElementById("TagTbl").getElementsByTagName("TBODY")[0];
           var row = document.createElement("TR");

           var td1 = document.createElement("Td");
           var input1=document.createElement("INPUT");
           input1.setAttribute("name", "tag_id" );
           input1.setAttribute("type", "checkbox");
           input1.setAttribute("value", id);
           td1.appendChild(input1);
           row.appendChild(td1);

           td1 = document.createElement("TD");
           td1.setAttribute("align","left");
           td1.innerHTML = "<a href=\"javascript:open_tag(" + id + ")\">" + title + "</a>";
           row.appendChild(td1);

           td1 = document.createElement("TD");
           td1.setAttribute("align","left");
           td1.innerHTML = tagname;
           row.appendChild(td1);

           td1 = document.createElement("TD");
           td1.setAttribute("align","left");
           td1.innerHTML = tag_start;
           row.appendChild(td1);

           td1 = document.createElement("TD");
           td1.setAttribute("align","left");
           td1.innerHTML = tag_end;
           row.appendChild(td1);

           tbody.appendChild(row);
        }

        function del_tag()
        {
            var rows = document.getElementsByName("tag_id");
            if( rows == null) return false;

            var r = confirm("<%=bundle.getString("TASK_ALERT_DELETE_TAG")%>");
            if( r !=1 ) return false;
            var has_data = false;
            for(var i = 0; i < rows.length; i++)
            {
                if(rows[i].checked)
                {
                    has_data = true;
                    break;
                }
            }

            document.taskFrm.act.value='del_tag';
            document.taskFrm.action ="task_save.jsp";
            document.taskFrm.target="_self";
            document.taskFrm.submit();
        }

        function f_save()
        {
          var frm = document.taskFrm;
          if( frm.task_name.value.trim() == "")
          {
             alert( "<%=bundle.getString("TASK_ALERT_NAME_IS_NULL")%>");
             frm.task_name.focus();
             return false;
          }
          if( frm.site.value.trim() == "")
          {
             alert( "<%=bundle.getString("TASK_ALERT_SITE_IS_NULL")%>");
             frm.site.focus();
             return false;
          }
          if( frm.task_runas.value.trim() == "")
          {
             alert( "<%=bundle.getString("TASK_ALERT_RUNAS_IS_NULL")%>");
             frm.task_runas_name.focus();
             return false;
          }
          if( frm.save_mode.value=="0")
          {
             if( frm.top_id.value=="")
             {
                alert( "<%=bundle.getString("TASK_ALERT_TOPIC_IS_NULL")%>");
                frm.topic.focus();
                return false;
             }
          }
          else if( frm.save_mode.value=="1")
          {
             if( frm.sql.value=="")
             {
                alert( "<%=bundle.getString("TASK_ALERT_SQL_IS_NULL")%>");
                frm.sql.focus();
                return false;
             }
          }

          var article_rule = frm.article_rule.value;
          var article_link = frm.article_link.value;
          if((article_rule=="" && article_link!="") || (article_rule!="" && article_link==""))
          {
              alert( "<%=bundle.getString("TASK_ALERT_INVALID_ARTICLERULE")%>");
              frm.article_rule.focus();
              return false;
          }

          frm.act.value='save';
          frm.action ="task_save.jsp";
          frm.target="_self";
          frm.submit();
        }

        function f_delete()
        {
            var r = confirm("<%=bundle.getString("TASK_ALERT_DELETE")%>");
            if( r !=1 ) return false;

            document.taskFrm.act.value='del';
            document.taskFrm.action ="task_save.jsp";
            document.taskFrm.target="_self";
            document.taskFrm.submit();
        }

        function f_pause()
        {
            var r = confirm("<%=bundle.getString("TASK_ALERT_PAUSE")%>");
            if( r !=1 ) return false;

            var frm = document.taskFrm;
            frm.act.value='pause';
            frm.action ="task_save.jsp";
            frm.target="_self";
            frm.submit();
        }

        function f_resume()
        {
            var r = confirm("<%=bundle.getString("TASK_ALERT_RESUME")%>");
            if( r !=1 ) return false;

            var frm = document.taskFrm;
            frm.act.value='resume';
            frm.action ="task_save.jsp";
            frm.target="_self";
            frm.submit();
        }

       function f_viewlog()
       {
           window.open('viewlog.jsp?id=<%=Utils.Null2Empty(task_id)%>');
       }

        function f_schedule()
        {
            var frm = document.taskFrm;
            if(frm.task_cronexp.value=="")
            {
                alert("<%=bundle.getString("TASK_ALERT_CRONEXP_IS_NULL")%>");
                return false;
            }
            if(frm.job_code.value=="")
            {
                alert("<%=bundle.getString("TASK_ALERT_JOBCODE_IS_NULL")%>");
                return false;
            }

            var r = confirm("<%=bundle.getString("TASK_ALERT_SCHEDULE")%>");
            if( r !=1 ) return false;

            frm.act.value='sche';
            frm.action ="task_save.jsp";
            frm.target="_self";
            frm.submit();
        }

        function f_run()
        {
            var frm = document.taskFrm;
            frm.act.value='run';
            frm.action ="task_save.jsp";
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
  <form name="taskFrm" method="post" action ="task_save.jsp">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr height=30>
        <td>&nbsp;
      <%
           boolean bSavable = false;
           boolean bDeletable = false;
           boolean bSchedulable = false;
           boolean bResumable = false;
           boolean bPausable = false;
           boolean bViewlog = false;
           boolean bRun = false;
           if(bNew)
           {
               if(user.IsLocalAdmin() || user.IsSysAdmin())  bSavable = true;
               bDeletable = false;
               bSchedulable = false;
               bResumable = false;
               bPausable = false;
               bViewlog = false;
               jobstatus = Trigger.STATE_NONE;
           }
           else
           {
               if(task.GetJobId()!=null && task.GetJobId().length()>0)
               {
                   jobstatus = JobScheduler.GetStatus(task.GetJobId());
               }
               else
               {
                   bSchedulable = true;
               }

               //仅在以下情况下可以修改
               //1.系统管理员
               //2.作者
               if(user.IsSysAdmin() || user.GetId().equals(task.GetCreator()))
               {
                   bSavable = true;
                   bDeletable = true;
                   bViewlog = true;

                   if(task.GetJobId()!=null && task.GetJobId().length()>0) bRun = true;

                   if(jobstatus==Trigger.STATE_PAUSED)
                   {
                       bResumable = true;
                   }
                   else if(jobstatus != Trigger.STATE_PAUSED && jobstatus!=Trigger.STATE_NONE)
                   {
                       bPausable = true;
                   }
               }
           }

           if(bSavable)
           {
      %>
           <input type="button" name="okbtn" value="<%=bundle.getString("TASK_BUTTON_SAVE")%>" class="button" onclick="f_save()">
<%
           }
           if(bDeletable)
           {
%>
           <input type="button" name="deletebtn" value="<%=bundle.getString("TASK_BUTTON_DELETE")%>" class="button" onclick="f_delete()">
<%
           }
           if(bSchedulable)
           {
%>
           <input type="button" name="schedulebtn"  value="<%=bundle.getString("TASK_BUTTON_SCHEDULE")%>" class="button" onclick="f_schedule()">
<%
           }
           if(bResumable)
           {
%>
           <input type="button" name="resumebtn"  value="<%=bundle.getString("TASK_BUTTON_RESUME")%>" class="button" onclick="f_resume()">
<%
           }
           if(bPausable)
           {
%>
           <input type="button" name="pausebtn"  value="<%=bundle.getString("TASK_BUTTON_PAUSE")%>" class="button" onclick="f_pause()">
<%
           }
           if(bRun)
           {
%>
            <input type="button" name="runbtn"  value="<%=bundle.getString("TASK_BUTTON_RUN")%>" class="button" onclick="f_run()">
<%
           }
           if(bViewlog)
           {
%>
           <input type="button" name="viewlogbtn"  value="<%=bundle.getString("TASK_BUTTON_VIEWLOG")%>" class="button" onclick="f_viewlog()">
<%
            }
%>
           <input type="button" name="closebtn" value="<%=bundle.getString("TASK_BUTTON_CLOSE")%>" class="button" onclick="javascript:window.close();">
        </td>
      </tr>
    </table>
   <table width="100%" cellpadding = "0" cellspacing = "0" border="1">
     <input type="hidden" name="task_id" value="<%= task_id==null?"":task_id %>">
     <input type="hidden" name="act" value="save">
     <tr height="25">
       <td width=120 align=center><font color="red"><%=bundle.getString("TASK_NAME")%></font></td>
       <td colspan="3">
         <input type=text name="task_name" value="<%= task==null?"":task.GetName() %>" size=60>
       </td>
       <td width=80 align=center><%=bundle.getString("TASK_ID")%></td>
       <td width=140>
         <%= task_id==null?"NEW":task_id%>
       </td>
     </tr>
     <tr height="25">
       <td align=center><font color="red"><%=bundle.getString("TASK_SITE")%></font></td>
       <td width=120>
           <select name="site" onchange="onchange_site(this.options[this.selectedIndex].value)">
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
         <option value="<%=site_id%>" <% if(task!=null && site_id.equals(task.GetSiteId())) out.print("selected"); %>><%=site_caption%></option>
<%
      }
    }
%>
        </select>
       </td>
       <td width="80" align="center" ><font color="red"><%=bundle.getString("TASK_ENCODING")%></font></td>
       <td width="120">
            <select name="encoding">
            <%
                String current_encoding = "UTF-8";
                if(task!=null) current_encoding = task.GetEncoding();

                java.util.SortedMap charsets = Charset.availableCharsets();
                java.util.Iterator iter = charsets.keySet().iterator();
                while(iter.hasNext())
                {
                    String charset_name = (String)iter.next();
            %>
                    <option value="<%=charset_name%>" <% if(current_encoding.equalsIgnoreCase(charset_name)) out.print("selected");%>><%=charset_name%></option>
            <%
                }
            %>
            </select>
       </td>
       <td align=center><font color="red"><%=bundle.getString("TASK_HTTPMETHOD")%></font></td>
       <td >
           <select name="http_method">
               <option value="GET" <% if(task!=null && "GET".equals(task.GetHttpMethod())) out.print("selected"); %>><%=bundle.getString("TASK_HTTPMETHOD_GET")%></option>
               <option value="POST" <% if(task!=null && "POST".equals(task.GetHttpMethod())) out.print("selected"); %>><%=bundle.getString("TASK_HTTPMETHOD_POST")%></option>
           </select>
           <input type="checkbox" name="detect_duplicate" value="1" <% if(bNew || (task!=null && task.IsDetectDuplicate())) out.print("checked='true'");%>><%=bundle.getString("TASK_DETECTDUPLICATE")%>
       </td>
     </tr>
     <tr height="25">
         <td align=center><%=bundle.getString("TASK_THREAD")%></td>
         <td>
             <input type="text" name="task_thread" value="<%=task==null?Task.DEFAULT_THREADS:task.GetThreads()%>">
             <font color="red"><%=bundle.getString("TASK_THREAD_HINT")%></font>
         </td>
         <td align=center><%=bundle.getString("TASK_INTERVAL")%></td>
         <td colspan="3">
             <input type="text" name="internal_time" value="<%=task==null?Task.DEFAULT_THREAD_INTERNAL_TIME:task.GetInternal()%>">ms
             &nbsp;<font color="red"><%=bundle.getString("TASK_INTERVAL_HINT")%></font>
         </td>
     </tr>
     <tr height="25">
        <td align=center><%=bundle.getString("TASK_CRONEXP")%></td>
        <td>
           <input type="text" name="task_cronexp" value="<%=task==null?"":Utils.Null2Empty(task.GetJobCronExpr())%>" size="100" style="width:200px">
           <input type="button" class="button" value="<%=bundle.getString("TASK_BUTTON_CRONEXP_HELP")%>" onclick="show_exphelp()">
           <br>Seconds Minutes Hours Day Month Week Year(Optional)
        </td>
        <td align=center><font color="red"><%=bundle.getString("TASK_RUNAS")%></font></td>
        <td>
         <input type="hidden" name="task_runas" value="<%= task==null?"":task.GetRunAsId()%>">
         <input type="text" name="task_runas_name" readonly value="<%= task==null?"":task.GetRunAsName()%>" onclick="<%=bSavable?"setUser()":""%>" style="width:80px">
         <%
             if(bSavable)
             {
         %>
         <input type="button" class="button" name="userbtn" value="<%=bundle.getString("TASK_BUTTON_RUNAS")%>" onclick="setUser()">
         <%
             }
         %>
        </td>
        <td align=center><%=bundle.getString("TASK_STATUS")%></td>
        <td>
         <%
             if(task==null)
             {
               out.print(bundle.getString("TASK_HINT_STATUS_NEW"));
             }
             out.print("&nbsp;&nbsp;");
             switch(jobstatus)
             {
                 case Trigger.STATE_BLOCKED:
                     out.print(bundle.getString("TASK_HINT_STATUS_BLOCKED"));
                     break;
                 case Trigger.STATE_COMPLETE:
                     out.print(bundle.getString("TASK_HINT_STATUS_BLOCKED"));
                     break;
                 case Trigger.STATE_ERROR:
                     out.print(bundle.getString("TASK_HINT_STATUS_ERROR"));
                     break;
                 case Trigger.STATE_NONE:
                     out.print(bundle.getString("TASK_HINT_STATUS_NONE"));
                     break;
                 case Trigger.STATE_NORMAL:
                     out.print(bundle.getString("TASK_HINT_STATUS_NORMAL"));
                     break;
                 case Trigger.STATE_PAUSED:
                     out.print(bundle.getString("TASK_HINT_STATUS_PAUSED"));
                     break;
             }
           %>
        </td>
    </tr>
    <%
        if(!bNew)
        {
            Job job = task.GetJob(wrapper.GetContext());
            if(job!=null)
            {
    %>
            <tr height="25">
              <td width=120 align=center><%=bundle.getString("TASK_LASTRUN_SERVER")%></td>
              <td><%=job.GetLastServer()==null?"&nbsp;":job.GetLastServer()%></td>
              <td width=120 align=center><%=bundle.getString("TASK_LASTRUN_STATE")%></td>
              <td colspan="3">
                  <%
                      switch(job.GetLastRunState())
                      {
                          case 0:
                              out.print(bundle.getString("TASK_LASTRUN_STATUS_NORMAL"));
                              break;
                          case 1:
                              out.print(bundle.getString("TASK_LASTRUN_STATUS_ERROR"));
                              break;
                      }
                  %>
              </td>
           </tr>
           <tr height="25">
              <td width=120 align=center><%=bundle.getString("TASK_LASTRUN_DATE")%></td>
              <td><%=job.GetLastRunDate()==null?"&nbsp;":Utils.FormateDate(job.GetLastRunDate(),"yyyy-MM-dd HH:mm:ss")%></td>
              <td width=120 align=center><%=bundle.getString("TASK_LASTRUN_TIME")%></td>
              <td colspan="3"><%=job.GetLastRunTime()%>ms</td>
           </tr>
   <%
           }
       }
   %>     
     <tr height="25">
         <td align=center><%=bundle.getString("TASK_REGION_START")%></td>
         <td>
             <textarea id="region_start" name="region_start" rows=3 cols="10" style="width:100%"><%=task==null?"":Utils.Null2Empty(task.GetRegionStart())%></textarea>
         </td>
         <td align=center><%=bundle.getString("TASK_REGION_END")%></td>
         <td colspan="3">
             <textarea id="region_end" name="region_end" rows=3 cols="10" style="width:100%"><%=task==null?"":Utils.Null2Empty(task.GetRegionEnd())%></textarea>
         </td>
     </tr>
     <tr height="25">
         <td align=center><%=bundle.getString("TASK_NEXTPAGE_START")%></td>
         <td>
             <textarea id="region_nextpage_start" name="region_nextpage_start"  rows=3 cols="10" style="width:100%"><%=task==null?"":Utils.Null2Empty(task.GetNextPageStart())%></textarea>
         </td>
         <td align=center><%=bundle.getString("TASK_NEXTPAGE_END")%></td>
         <td colspan="3">
             <textarea id="region_nextpage_end" name="region_nextpage_end"  rows=3 cols="10" style="width:100%"><%=task==null?"":Utils.Null2Empty(task.GetNextPageEnd())%></textarea>
         </td>
     </tr>
     <tr height="25">
        <td align=center><%=bundle.getString("TASK_CREATOR")%></td>
        <td><%=task==null?creator:task.GetCreatorName()%></td>
        <td align=center><%=bundle.getString("TASK_CREATEDATE")%></td>
        <td colspan="3"><%=task==null?create_date:task.GetCreateDate()%></td>
     </tr>
 </table>

  <br>
  <table id="ArticleTbl" width="100%" border="1" cellpadding="0" cellspacing="1">
     <tr >
        <td colspan="4">
           <b><%=bundle.getString("TASK_ARTICLE")%></b>
           &nbsp;&nbsp;<font color="red"><%=bundle.getString("TASK_SAVEMODE")%></font>
            <select name="save_mode" onchange="onchange_savemode(this.options[this.selectedIndex].value)">
                <option value="0" <% if(task!=null && task.GetSaveMode()==0) out.print("selected"); %>><%=bundle.getString("TASK_SAVEMODE_ARTICLE")%></option>
                <option value="1" <% if(task!=null && task.GetSaveMode()==1) out.print("selected"); %>><%=bundle.getString("TASK_SAVEMODE_SQL")%></option>
            </select>
        </td>
     </tr>
     <tr id="savemode_article" style="display:<%=bNew || (task!=null && task.GetSaveMode()==0)?"block":"none"%>">
        <td align="center"><font color="red"><%=bundle.getString("TASK_TOPIC")%></font></td>
        <td align=left colspan="3">
          <input type="text" name="topic" value="<%= task==null||task.GetTopic()==null?"":task.GetTopic().GetName() %>" readonly onclick='javascript:selectTopics();'>
          <input type="hidden" name="top_id" value="<%= task==null||task.GetTopic()==null?"":task.GetTopic().GetId()%>">
<%
   if(bSavable)
   {
%>
          <input type="button" value="<%=bundle.getString("TASK_BUTTON_SELTOPIC")%>" class="button" name="btn_topic" onclick='javascript:selectTopics();'>
<%
   }
%>
      </td>
     </tr>

     <tr id="savemode_sql" style="display:<%=task!=null && task.GetSaveMode()==1?"block":"none"%>">
         <td align="center"><font color="red"><%=bundle.getString("TASK_SQL")%></font></td>
         <td align=left colspan="3">
             <font color="red"><%=bundle.getString("TASK_SQL_HINT")%></font>
             <br>
             Declare <br>
             &nbsp;&nbsp;tag varchar2(10);<br>
             Begin <br>
             <textarea id="sql" name="sql" rows="8" cols="10" style="width:100%"><%= task==null?"":Utils.Null2Empty(task.GetSQL())%></textarea>
             End;<br>
         </td>
     </tr>      
     <tr height="25">
         <td align=center><%=bundle.getString("TASK_URLFILTER")%></td>
         <td align=left colspan="3">
             <input type="text" name="article_urlfilter" value="<%=task==null?"":Utils.Null2Empty(task.GetArticleURLFilter())%>" style="width:400px">
             <%=bundle.getString("TASK_URLFILTER_HINT")%>
         </td>
     </tr>
     <tr height="25">
         <td align=center><%=bundle.getString("TASK_ARTICLE_RULE")%></td>
         <td align=left colspan="3">
             <input type="text" name="article_rule" value="<%=task==null?"":Utils.Null2Empty(task.GetArticleRule())%>" style="width:400px">
             <font color="red"><%=bundle.getString("TASK_ARTICLE_RULE_SAMPLE")%></font>
             <br>
             <%=bundle.getString("TASK_ARTICLE_RULE_HINT")%>
         </td>
     </tr>
     <tr height="25">
         <td align=center><%=bundle.getString("TASK_ARTICLE_LINK")%></td>
         <td align=left colspan="3">
             <input type="text" name="article_link" value="<%=task==null?"":Utils.Null2Empty(task.GetArticleLink())%>" style="width:400px">
             <font color="red"><%=bundle.getString("TASK_ARTICLE_LINK_SAMPLE")%></font>
             <br>
             <%=bundle.getString("TASK_ARTICLE_LINK_HINT")%>
         </td>
     </tr>
     <tr height="25">
         <td width=120  align=center><%=bundle.getString("TASK_ARTICLE_NEXTPAGE_START")%></td>
         <td width="360">
             <textarea id="article_nextpage_start" name="article_nextpage_start" rows=3 cols="10" style="width:100%"><%=task==null?"":Utils.Null2Empty(task.GetArticleNextPageStart())%></textarea>
         </td>
         <td width=120 align=center><%=bundle.getString("TASK_ARTICLE_NEXTPAGE_END")%></td>
         <td width="360">
             <textarea id="article_nextpage_end" name="article_nextpage_end" rows=3 cols="10" style="width:100%"><%=task==null?"":Utils.Null2Empty(task.GetArticleNextPageEnd())%></textarea>
         </td>
     </tr>
  </table>

  <br>
  <table id="PageTbl" width="100%" border="0" cellpadding="0" cellspacing="1">
  <TBODY>
  <tr >
    <td colspan="2">
       <b><%=bundle.getString("TASK_PAGES")%></b>
       &nbsp;&nbsp;<font color="red"><%=bundle.getString("TASK_PAGETYPE")%></font>
       <select name="page_type">
           <option value="0" <% if(task!=null && task.GetPageType()==0) out.print("selected"); %>><%=bundle.getString("TASK_PAGETYPE_LIST")%></option>
           <option value="1" <% if(task!=null && task.GetPageType()==1) out.print("selected"); %>><%=bundle.getString("TASK_PAGETYPE_HTML")%></option>
           <option value="3" <% if(task!=null && task.GetPageType()==3) out.print("selected"); %>><%=bundle.getString("TASK_PAGETYPE_RSS")%></option>
       </select>
       &nbsp;&nbsp;
       <input type=button class="button" value="<%=bundle.getString("TASK_BUTTON_ADD_PAGE")%>" onclick="javascript:add_page('<%=Utils.Null2Empty(task_id)%>');">
       <input type=button class="button" value="<%=bundle.getString("TASK_BUTTON_DEL_PAGE")%>" onclick="javascript:del_page();">
    </td>
  </tr>
  <tr height="25">
     <td width=25><input type = "checkBox" name = "PageAllId" value = "0" onclick = "javascript:selectpage();"></td>
     <td width=700 align="left"><%=bundle.getString("TASK_PAGE_URL")%></td>
  </tr>
  <%
      if(task!=null)
      {
          ArrayList<URLGenerator> urls = task.GetURLs();
          if(urls!=null && !urls.isEmpty())
          {
            for(URLGenerator url_gen: urls)
            {
  %>
    <tr height="25">
      <td width="25">
          <input type="checkbox" name="page_id" value="<%=url_gen.GetId()%>">
      </td>
      <td align=left>
          <a href="javascript:open_page(<%=url_gen.GetId()%>)"><%=url_gen.GetPattern()%></a>
      </td>
    </tr>
  <%
               }
          }
      }
  %>
    </TBODY>
  </table>

   <br>
   <table id="TagTbl" width="100%" border="0" cellpadding="0" cellspacing="1">
   <TBODY>
   <tr >
     <td colspan="5">
        <b><%=bundle.getString("TASK_TAGS")%></b>
        &nbsp;&nbsp;
        <input type=button class="button" value="<%=bundle.getString("TASK_BUTTON_ADD_TAG")%>" onclick="javascript:add_tag('<%=Utils.Null2Empty(task_id)%>');">
        <input type=button class="button" value="<%=bundle.getString("TASK_BUTTON_DEL_TAG")%>" onclick="javascript:del_tag();">
     </td>
   </tr>
   <tr height="25">
      <td width=25><input type = "checkBox" name = "TagAllId" value = "0" onclick = "javascript:selecttag();"></td>
      <td width=120 align="left"><%=bundle.getString("TASK_TAG_TITLE")%></td>
      <td width=160 align="left"><%=bundle.getString("TASK_TAG_NAME")%></td>
      <td width=240 align="left"><%=bundle.getString("TASK_TAG_START")%></td>
      <td width=240 align="left"><%=bundle.getString("TASK_TAG_END")%></td> 
   </tr>
   <%
       if(task!=null)
       {
           ArrayList<Tag> tags = task.GetTags();
           if(tags!=null && !tags.isEmpty())
           {
             for(Tag tag:tags)
             {
   %>
     <tr height="25">
       <td width="25">
           <input type="checkbox" name="tag_id" value="<%=tag.GetId()%>">
       </td>
       <td align=left>
           <a href="javascript:open_tag(<%=tag.GetId()%>)"><%=tag.GetTitle()%></a>
       </td>
       <td align=left>
           <%=tag.GetTagName()%>
       </td>
       <td align=left>
           <%
               if(tag.isConst())
               {
                   out.print(tag.GetConstValue());
               }
               else
               {
                   out.print(Utils.Null2Empty(tag.GetTagStartString()));
               }
           %>
       </td>
       <td align=left>
           <%
               if(!tag.isConst()) out.print(Utils.Null2Empty(tag.GetTagEndString()));
           %>
       </td>
     </tr>
   <%
                }
           }
       }
   %>
     </TBODY>
   </table>

 <br>
 <table width="100%" cellpadding = "0" cellspacing = "0" border="0">
 <tr height="25">
     <td>
         <b><%=bundle.getString("TASK_JOB")%></b>
         &nbsp;&nbsp;<%=bundle.getString("TASK_LANG")%>
         <select name="job_lang">
             <option value="0" <% if(task!=null && task.GetJobLang()==0) out.print("selected");%>>JavaScript</option>
             <option value="1" <% if(task!=null && task.GetJobLang()==1) out.print("selected");%>>DynamicJava</option>
         </select>
         &nbsp;&nbsp;&nbsp;&nbsp;
         <input type="button" name="helpbtn"  value="<%=bundle.getString("TASK_BUTTON_JS_HELP")%>" class="button" onclick="javascript:showhelp();">
    </td>
 </tr>
 <tr>
   <td>
      <textarea id="job_code" name="job_code" rows="25" style="width:100%;"><% if(task!=null) out.print(task.GetJobCode()); %></textarea>
   </td>
 </tr>
 </table>
 </form>
  <br><br><br><br><br><br><br><br><br><br><br><br><br>
</body>
</html>
<%
    }
    finally
    {
        if(wrapper!=null) wrapper.Clear();
    }
%>