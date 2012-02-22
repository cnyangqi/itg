<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.core.NpsWrapper" %>
<%@ page import="nps.core.Config" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.apps.poll.Poll" %>
<%@ page import="nps.apps.poll.Option" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="nps.util.Utils" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String poll_id = request.getParameter("id");
    if(poll_id!=null) poll_id = poll_id.trim();
    boolean bNew = (poll_id==null || poll_id.length()==0);

    String creator = user.GetName()+"("+user.GetDeptName()+ "/" +user.GetUnitName()+")";
    String create_date = nps.util.Utils.FormateDate(new java.util.Date(),"yyyy-MM-dd HH:mm:ss");

    NpsWrapper wrapper = null;
    Poll poll = null;
    try
    {
        if(!bNew)
        {
            wrapper = new NpsWrapper(user);
            poll = new Poll(wrapper.GetContext(), poll_id);
            if(poll==null) throw new NpsException(ErrorHelper.SYS_UNKOWN, "poll #" + poll_id + " not exist");
        }

        ResourceBundle bundle = ResourceBundle.getBundle("langs.app_poll",user.GetLocale(), Config.RES_CLASSLOADER);
%>

<html>
  <head>
    <title><%=bNew?bundle.getString("POLL_HTMLTILE"):poll.GetQuestion()%></title>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>

    <script language="javascript">
       function add_option()
       {
           var tbody = document.getElementById("OptionTbl").getElementsByTagName("TBODY")[0];
           var row = document.createElement("TR");

           var td1 = document.createElement("Td");
           var input1=document.createElement("INPUT");
           input1.setAttribute("id", "chk_option");
           input1.setAttribute("name", "chk_option");
           input1.setAttribute("type", "checkbox");
           input1.setAttribute("value", "");
           td1.appendChild(input1);
           
           input1=document.createElement("INPUT");
           input1.setAttribute("id", "option_id");
           input1.setAttribute("name", "option_id");
           input1.setAttribute("type", "hidden");
           input1.setAttribute("value", "");
           td1.appendChild(input1);
           row.appendChild(td1);

           td1 = document.createElement("TD");
           td1.setAttribute("align","left");
           input1=document.createElement("TEXTAREA");
           input1.setAttribute("id", "option_value" );
           input1.setAttribute("name", "option_value" );
           input1.setAttribute("rows", "3");
           input1.setAttribute("cols", "80");
           td1.appendChild(input1);
           row.appendChild(td1);

           td1 = document.createElement("TD");
           row.appendChild(td1);
          
           tbody.appendChild(row);
        }

        function del_option()
        {
            var rows = document.getElementsByName("chk_option");
            if( rows == null) return false;

            var r = confirm("<%=bundle.getString("POLL_ALERT_DELETE_OPTION")%>");
            if( r !=1 ) return false;

            var tbody = document.getElementById("OptionTbl").getElementsByTagName("TBODY")[0];
            for(var i = rows.length-1; i>=0; i--)
            {
                if(rows[i].checked)
                {
                    tbody.removeChild(rows[i].parentNode.parentNode);
                }
            }
        }

        function f_save()
        {
          <%
             if(!bNew)
             {
          %>
                var r = confirm("<%=bundle.getString("POLL_ALERT_SAVE")%>");
                if( r !=1 ) return false;
          <%
             }
          %>
          var frm = document.pollFrm;
          if( frm.question.value.trim() == "")
          {
             alert( "<%=bundle.getString("POLL_ALERT_QUESTION_IS_NULL")%>");
             frm.question.focus();
             return false;
          }

          frm.act.value='save';
          frm.action ="poll_save.jsp";
          frm.target="_self";
          frm.submit();
        }

        function f_delete()
        {
            var r = confirm("<%=bundle.getString("POLL_ALERT_DELETE")%>");
            if( r !=1 ) return false;

            document.pollFrm.act.value='del';
            document.pollFrm.action ="poll_save.jsp";
            document.pollFrm.target="_self";
            document.pollFrm.submit();
        }

        function f_start()
        {
            var r = confirm("<%=bundle.getString("POLL_ALERT_START")%>");
            if( r !=1 ) return false;

            var frm = document.pollFrm;
            frm.act.value='start';
            frm.action ="poll_save.jsp";
            frm.target="_self";
            frm.submit();
        }

        function f_stop()
        {
            var r = confirm("<%=bundle.getString("POLL_ALERT_STOP")%>");
            if( r !=1 ) return false;

            var frm = document.pollFrm;
            frm.act.value='stop';
            frm.action ="poll_save.jsp";
            frm.target="_self";
            frm.submit();
        }

        function f_abort()
        {
            var r = confirm("<%=bundle.getString("POLL_ALERT_ABORT")%>");
            if( r !=1 ) return false;

            var frm = document.pollFrm;
            frm.act.value='abort';
            frm.action ="poll_save.jsp";
            frm.target="_self";
            frm.submit();
        }
    </script>
  </head>

  <body leftmargin="20">
  <form name="pollFrm" method="post" action ="task_save.jsp">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr height=30>
        <td>&nbsp;
      <%
           boolean bSavable = false;
           boolean bDeletable = false;
           boolean bAbortable = false;
           boolean bStoppable = false;
           boolean bRunnable = false;
           if(bNew)
           {
               bSavable = true;
               bDeletable = false;
               bAbortable = false;
               bStoppable = false;
               bRunnable = false;
           }
           else
           {
               if(user.IsSysAdmin() || user.GetId().equals(poll.GetCreator()))
               {
                   bSavable = true;
                   bDeletable = true;
                   bAbortable = poll.isRunning();
                   bStoppable = poll.isRunning();
                   bRunnable = !poll.isRunning();
               }
           }

           if(bSavable)
           {
      %>
           <input type="button" name="okbtn" value="<%=bundle.getString("POLL_BUTTON_SAVE")%>" class="button" onclick="f_save()">
<%
           }
           if(bDeletable)
           {
%>
           <input type="button" name="deletebtn" value="<%=bundle.getString("POLL_BUTTON_DELETE")%>" class="button" onclick="f_delete()">
<%
           }
           if(bRunnable)
           {
%>
           <input type="button" name="startbtn"  value="<%=bundle.getString("POLL_BUTTON_START")%>" class="button" onclick="f_start()">
<%
           }
           if(bStoppable)
           {
%>
           <input type="button" name="stopbtn"  value="<%=bundle.getString("POLL_BUTTON_STOP")%>" class="button" onclick="f_stop()">
<%
           }
           if(bAbortable)
           {
%>
           <input type="button" name="abortbtn"  value="<%=bundle.getString("POLL_BUTTON_ABORT")%>" class="button" onclick="f_abort()">
<%
           }
%>
           <input type="button" name="closebtn" value="<%=bundle.getString("POLL_BUTTON_CLOSE")%>" class="button" onclick="javascript:window.close();">
        </td>
      </tr>
    </table>
   <table width="100%" cellpadding = "0" cellspacing = "0" border="1">
     <input type="hidden" name="poll_id" value="<%= poll_id==null?"":poll_id %>">
     <input type="hidden" name="act" value="save">
     <tr height="25">
       <td width=120 align=center><font color="red"><%=bundle.getString("POLL_QUESTION")%></font></td>
       <td width="600">
         <textarea name="question" rows="3" cols="10" style="width:100%"><%= poll==null?"":poll.GetQuestion() %></textarea>
       </td>
       <td width=80 align=center><%=bundle.getString("POLL_STATUS")%></td>
       <td>
         <%
             if(poll!=null)
             {
                 switch(poll.GetStatus())
                 {
                     case Poll.STATUS_NEW:
                         out.print(bundle.getString("POLL_STATUS_NEW"));
                         break;
                     case Poll.STATUS_RUNNING:
                         out.print(bundle.getString("POLL_STATUS_RUNNING"));
                         break;
                     case Poll.STATUS_STOPPED:
                         out.print(bundle.getString("POLL_STATUS_STOPPED"));
                         break;
                     case Poll.STATUS_ABORTED:
                         out.print(bundle.getString("POLL_STATUS_ABORTED"));
                         break;
                 }
             }
             else
             {
                 out.print(bundle.getString("POLL_STATUS_NOT_EXIST"));
             }
         %>
       </td>
     </tr>
     <tr height="25">
       <td align=center><font color="red"><%=bundle.getString("POLL_SITE")%></font></td>
       <td colspan="3">
           <select name="site">
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
         <option value="<%=site_id%>" <% if(poll!=null && site_id.equals(poll.GetSiteId())) out.print("selected"); %>><%=site_caption%></option>
<%
      }
    }
%>
        </select>
       </td>
    </tr>
   <tr height="25">
       <td align="center" ><font color="red"><%=bundle.getString("POLL_TYPE")%></font></td>
       <td colspan="3">
            <select name="poll_type">
               <option value="0" <% if(bNew || poll.isSingleAnswer()) out.print("selected");%>><%=bundle.getString("POLL_TYPE_SINGLE_ANSWER")%></option>
               <option value="1" <% if(poll!=null && poll.isMultipleChoice()) out.print("selected");%>><%=bundle.getString("POLL_TYPE_MULTIPLE_CHOICE")%></option>
            </select>
       </td>
   </tr>
   <tr height="25">
       <td align=center><font color="red"><%=bundle.getString("POLL_VIEW")%></font></td>
       <td colspan="3">
           <select name="view_type">
               <option value="0" <% if(bNew || poll.GetViewType()==0) out.print("selected"); %>><%=bundle.getString("POLL_VIEW_HORIZONTAL_BAR")%></option>
               <option value="1" <% if(poll!=null && poll.GetViewType()==1) out.print("selected"); %>><%=bundle.getString("POLL_VIEW_VERTICAL_BAR")%></option>
               <option value="2" <% if(poll!=null && poll.GetViewType()==2) out.print("selected"); %>><%=bundle.getString("POLL_VIEW_PIE")%></option>
           </select>
       </td>
     </tr>
     <tr height="25">
         <td align=center><font color="red"><%=bundle.getString("POLL_VOTE")%></font></td>
         <td align=left colspan=3>
             <input type="checkbox" name="member_only" value="1" <% if(poll!=null && poll.MemberOnly()) out.print("checked"); %>><%=bundle.getString("POLL_MEMBER_ONLY")%>
             &nbsp;
             <input type="checkbox" name="allow_same_ip" value="1" <% if(poll!=null && poll.allowAllIP()) out.print("checked"); %>><%=bundle.getString("POLL_ALLOW_SAME_IP")%>,
             <%=bundle.getString("POLL_SAME_IP_INTERVAL")%>
             <input type="text" name="same_ip_interval" value="<%=poll==null||poll.GetSameIPInternal()==0?"":poll.GetSameIPInternal()%>" style="width:80px">s
             <font color="red">(<%=bundle.getString("POLL_HINT_SAME_IP_INTERVAL")%>)</font>
         </td>
     </tr>
     <tr height="25">
        <td align=center><%=bundle.getString("POLL_CREATOR")%></td>
        <td colspan="3">
            <%=poll==null?creator:poll.GetCreatorName()%> &nbsp;&nbsp;
            <%=poll==null?create_date:poll.GetCreateDate()%>
        </td>
     </tr>
 </table>

  <br>
  <table id="OptionTbl" width="100%" border="0" cellpadding="0" cellspacing="1">
  <TBODY>
  <tr >
    <td colspan="2">
       <b><%=bundle.getString("POLL_OPTIONS")%></b>
       &nbsp;&nbsp;
       <input type=button class="button" value="<%=bundle.getString("POLL_BUTTON_ADD_OPTION")%>" onclick="javascript:add_option();">
       <input type=button class="button" value="<%=bundle.getString("POLL_BUTTON_DEL_OPTION")%>" onclick="javascript:del_option();">
    </td>
  </tr>
  <tr height="25">
     <td width=25><input type = "checkBox" name = "OptionAllId" value = "0" onclick = "javascript:selectoption();"></td>
     <td width=700 align="left"><%=bundle.getString("POLL_OPTION")%></td>
     <td align="left"><%=bundle.getString("POLL_OPTION_COUNT")%></td>
  </tr>
  <%
      if(poll!=null)
      {
          ArrayList<Option> options = poll.GetOptions();
          if(options!=null && !options.isEmpty())
          {
            for(Option option: options)
            {
  %>
    <tr height="25">
      <td width="25">
          <input type="checkbox" id="chk_option" name="chk_option" value="<%=option.GetId()%>">
          <input type="hidden" id="option_id" name="option_id" value="<%=option.GetId()%>">
      </td>
      <td>
          <textarea  id="option_value" name="option_value" rows="3" cols="80"><%=option.GetOption()%></textarea>
      </td>
      <td>
          <%=option.GetNumber()%>
      </td>
    </tr>
  <%
               }
          }
      }
  %>
    </TBODY>
  </table>
  </form>
     
 <br>
 <table width="100%" cellpadding = "0" cellspacing = "0" border="0">
 <tr height="25">
     <td width=50%>
         <b><%=bundle.getString("POLL_CODE")%></b>
    </td>
     <td width=50%>
         <b><%=bundle.getString("POLL_PREVIEW")%></b>
    </td>
 </tr>
 <%
   StringBuffer buf = null;
   if(poll!=null)
   {
       buf = new StringBuffer(8192);
       String input_type = "radio";
       if(poll.isMultipleChoice()) input_type = "checkbox";

       buf.append("<style type=\"text/css\">");
       buf.append("\n");
       buf.append(".vote {margin-top: 10px; padding-bottom: 18px; }");
       buf.append("\n");
       buf.append(".vote .votetitle {  background: #FFB822; height: 30px; line-height: 30px; overflow: hidden; }");
       buf.append("\n");
       buf.append(".vote H3 {  padding-left: 10px; }");
       buf.append("\n");
       buf.append(".vote .voteContent { padding: 0 15px 0; border-left: 1px solid #FDBE0F; border-right: 1px solid #FDBE0F; }");
       buf.append("\n");
       buf.append(".vote dl { list-style: none outside none; }");
       buf.append("\n");
       buf.append(".vote dt { font-weight: bold; line-height: 1.5; padding: 0 0 11px; }");
       buf.append("\n");
       buf.append(".vote dd { clear: both; padding: 0 0 9px; }");
       buf.append("\n");
       buf.append(".vote .voteBtn { padding: 10px 0 0; text-align: center;}");
       buf.append("\n");
       buf.append(".cmnbtn {display: inline-block; padding: 5px 15px; font-size: 12px; font-weight: bold; color: black;}");
       buf.append("\n");
       buf.append(".okBtn { background: #FFB822; }");
       buf.append("\n");
       buf.append(".viewBtn { background: #FFFFFF; }");
       buf.append("\n");
       buf.append("</style>");
       buf.append("\n");

       buf.append("<form name='pollform_" + poll.GetId() + "' method='post' action='/poll/poll.jsp?poll_id="+poll.GetId()+"&poll_type=1' target='_blank'>");
       buf.append("\n");
       buf.append("<div class='vote'>");
       buf.append("\n");
       buf.append("    <div class='voteTitle'><h3>"+bundle.getString("POLL_BUTTON_VOTE")+"</h3></div>");
       buf.append("\n");
       buf.append("    <div class='voteContent'>");
       buf.append("\n");
       buf.append("    <dl>");
       buf.append("\n");
       buf.append("       <dt>" + poll.GetQuestion() + "</dt>");
       buf.append("\n");

       ArrayList<Option> options = poll.GetOptions();
       if(options!=null && options.size()>0)
       {
           for(Option option:options)
           {
               buf.append("       <dd>");
               buf.append("<input id='poll_" + poll.GetId() + "' name='poll_" + poll.GetId() + "' type=" + input_type + " value='" + option.GetId() + "' />");
               buf.append(option.GetOption());
               buf.append("</dd>");
               buf.append("\n");
           }
       }

       buf.append("    </dl>");
       buf.append("\n");
       buf.append("    </div>");
       buf.append("\n");
       buf.append("    <div class='voteBtn'>");
       buf.append("\n");
       buf.append("       <a class='cmnbtn okBtn' href=\"javascript:document.pollform_" + poll.GetId() + ".submit();\" title='"+bundle.getString("POLL_BUTTON_VOTE")+"'><span>"+bundle.getString("POLL_BUTTON_VOTE")+"</span></a>");
       buf.append("\n");
       buf.append("       <a class='cmnbtn viewBtn' href=\"/poll/poll.jsp?poll_id=" + poll.GetId() + "\" title='"+bundle.getString("POLL_BUTTON_VIEW")+"'><span>"+bundle.getString("POLL_BUTTON_VIEW")+"</span></a>");
       buf.append("\n");
       buf.append("    </div>");
       buf.append("\n");
       buf.append("</div>");
       buf.append("\n");
       buf.append("</form>");
   }
 %>

 <tr>
     <td valign="top">
       <textarea id="code" name="code" rows="50" style="width:100%;" ondblclick="this.select()" readonly><%=buf==null?"":buf.toString()%></textarea>
   </td>
   <td valign="top"><%=buf==null?"":buf.toString()%></td>
 </tr>
 </table>
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