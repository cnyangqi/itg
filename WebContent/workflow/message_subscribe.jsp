<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.workflow.message.MessageTemplate" %>
<%@ page import="nps.core.Database" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.BasicContext" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.workflow_message_subscribe",user.GetLocale(), nps.core.Config.RES_CLASSLOADER);

    String act = request.getParameter("act");
    if("0".equals(act))
    {
        //save
        BasicContext ctxt = null;
        Connection conn = Database.GetDatabase("nps").GetConnection();
        conn.setAutoCommit(false);
        ctxt = new BasicContext(conn,  user);
        try
        {
            MessageTemplate.ClearListener(ctxt, user.GetId());

            String pending_email = request.getParameter("pending_email");
            String pending_sms = request.getParameter("pending_sms");
            if("1".equals(pending_email)) MessageTemplate.AddListener(ctxt, user, MessageTemplate.STATUS_PENDING, MessageTemplate.MESSAGE_EMAIL);
            if("1".equals(pending_sms)) MessageTemplate.AddListener(ctxt, user, MessageTemplate.STATUS_PENDING, MessageTemplate.MESSAGE_SMS);

            String agreed_email = request.getParameter("agreed_email");
            String agreed_sms = request.getParameter("agreed_sms");
            if("1".equals(agreed_email)) MessageTemplate.AddListener(ctxt, user, MessageTemplate.STATUS_AGREED, MessageTemplate.MESSAGE_EMAIL);
            if("1".equals(agreed_sms)) MessageTemplate.AddListener(ctxt, user, MessageTemplate.STATUS_AGREED, MessageTemplate.MESSAGE_SMS);

            String rejected_email = request.getParameter("rejected_email");
            String rejected_sms = request.getParameter("rejected_sms");
            if("1".equals(rejected_email)) MessageTemplate.AddListener(ctxt, user, MessageTemplate.STATUS_REJECTED, MessageTemplate.MESSAGE_EMAIL);
            if("1".equals(rejected_sms)) MessageTemplate.AddListener(ctxt, user, MessageTemplate.STATUS_REJECTED, MessageTemplate.MESSAGE_SMS);

            String returned_email = request.getParameter("returned_email");
            String returned_sms = request.getParameter("returned_sms");
            if("1".equals(returned_email)) MessageTemplate.AddListener(ctxt, user, MessageTemplate.STATUS_RETURNED, MessageTemplate.MESSAGE_EMAIL);
            if("1".equals(returned_sms)) MessageTemplate.AddListener(ctxt, user, MessageTemplate.STATUS_RETURNED, MessageTemplate.MESSAGE_SMS);

            String terminated_email = request.getParameter("terminated_email");
            String terminated_sms = request.getParameter("terminated_sms");
            if("1".equals(terminated_email)) MessageTemplate.AddListener(ctxt, user, MessageTemplate.STATUS_TERMINATED, MessageTemplate.MESSAGE_EMAIL);
            if("1".equals(terminated_sms)) MessageTemplate.AddListener(ctxt, user, MessageTemplate.STATUS_TERMINATED, MessageTemplate.MESSAGE_SMS);

            String finished_email = request.getParameter("finished_email");
            String finished_sms = request.getParameter("finished_sms");
            if("1".equals(finished_email)) MessageTemplate.AddListener(ctxt, user, MessageTemplate.STATUS_FINISHED, MessageTemplate.MESSAGE_EMAIL);
            if("1".equals(finished_sms)) MessageTemplate.AddListener(ctxt, user, MessageTemplate.STATUS_FINISHED, MessageTemplate.MESSAGE_SMS);

            String revoked_email = request.getParameter("revoked_email");
            String revoked_sms = request.getParameter("revoked_sms");
            if("1".equals(revoked_email)) MessageTemplate.AddListener(ctxt, user, MessageTemplate.STATUS_REVOKED, MessageTemplate.MESSAGE_EMAIL);
            if("1".equals(revoked_sms)) MessageTemplate.AddListener(ctxt, user, MessageTemplate.STATUS_REVOKED, MessageTemplate.MESSAGE_SMS);

            String deleted_email = request.getParameter("deleted_email");
            String deleted_sms = request.getParameter("deleted_sms");
            if("1".equals(deleted_email)) MessageTemplate.AddListener(ctxt, user, MessageTemplate.STATUS_DELETED, MessageTemplate.MESSAGE_EMAIL);
            if("1".equals(deleted_sms)) MessageTemplate.AddListener(ctxt, user, MessageTemplate.STATUS_DELETED, MessageTemplate.MESSAGE_SMS);

            ctxt.Commit();
        }
        catch(NpsException e)
        {
            if(ctxt!=null) ctxt.Rollback();
            throw e;
        }
        finally
        {
            if(ctxt!=null) ctxt.Clear();
        }
    }
%>

<html>
<head>
    <title><%=bundle.getString("MSGSUBSCRIBE_HTMLTITLE")%></title>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel=stylesheet>

    <script language="Javascript">
      function f_save()
      {
         document.inputFrm.action='message_subscribe.jsp';
         document.inputFrm.target="_self";
         document.inputFrm.submit();
      }
    </script>
</head>

<body leftmargin=20 topmargin=0>
<table id="pbar" border="0" class="positionbar" cellpadding="0" cellspacing="0">
  <tr>
    <td>&nbsp;
      <input type="button" class="button" name="save" value="<%=bundle.getString("MSGSUBSCRIBE_BUTTON_SAVE")%>" onClick="f_save()" >
  </tr>
</table>
<table width="100%" cellpadding="0" border="0" cellspacing="0" style="padding:15px;">
    <form name="inputFrm" method="post" action="message_subscribe.jsp">
    <input type="hidden" name="act" value="0">
<%
    MessageTemplate template_email = MessageTemplate.GetTemplate(user.GetUnitId(), MessageTemplate.MESSAGE_EMAIL, MessageTemplate.STATUS_PENDING);
    MessageTemplate template_sms = MessageTemplate.GetTemplate(user.GetUnitId(), MessageTemplate.MESSAGE_SMS, MessageTemplate.STATUS_PENDING);
    if(template_email!=null || template_sms!=null)
    {
%>
    <tr height="30">
        <td width="250"><b><%=bundle.getString("MSGSUBSCRIBE_PENDING")%></b></td>
        <td>
            <%
                if(template_email!=null)
                {
                    boolean is_listening = MessageTemplate.IsListening(user.GetId(), MessageTemplate.STATUS_PENDING, MessageTemplate.MESSAGE_EMAIL);
                    out.println("<input type='checkbox' name='pending_email' value='1' " + (is_listening?"checked":"") + ">" + bundle.getString("MSGSUBSCRIBE_EMAIL"));
                }
                if(template_sms!=null)
                {
                    boolean is_listening = MessageTemplate.IsListening(user.GetId(), MessageTemplate.STATUS_PENDING, MessageTemplate.MESSAGE_SMS);
                    out.println("<input type='checkbox' name='pending_sms' value='1' " + (is_listening?"checked":"") + ">" + bundle.getString("MSGSUBSCRIBE_SMS"));
                }
            %>
        </td>
    </tr>
<%
    }
%>

    <tr height="30">
        <td colspan=2><span style="font-weight:bold;color:red"><%=bundle.getString("MSGSUBSCRIBE_JOBSTATUS")%></span></td>
    </tr>
<%
        template_email = MessageTemplate.GetTemplate(user.GetUnitId(), MessageTemplate.MESSAGE_EMAIL, MessageTemplate.STATUS_FINISHED);
        template_sms = MessageTemplate.GetTemplate(user.GetUnitId(), MessageTemplate.MESSAGE_SMS, MessageTemplate.STATUS_FINISHED);
        if(template_email!=null || template_sms!=null)
        {
%>
        <tr height="30">
            <td width="250"><b><%=bundle.getString("MSGSUBSCRIBE_FINISHED")%></b></td>
            <td>
                <%
                    if(template_email!=null)
                    {
                        boolean is_listening = MessageTemplate.IsListening(user.GetId(), MessageTemplate.STATUS_FINISHED, MessageTemplate.MESSAGE_EMAIL);
                        out.println("<input type='checkbox' name='finished_email' value='1' " + (is_listening?"checked":"") + ">" + bundle.getString("MSGSUBSCRIBE_EMAIL"));
                    }
                    if(template_sms!=null)
                    {
                        boolean is_listening = MessageTemplate.IsListening(user.GetId(), MessageTemplate.STATUS_FINISHED, MessageTemplate.MESSAGE_SMS);
                        out.println("<input type='checkbox' name='finished_sms' value='1' " + (is_listening?"checked":"") + ">" + bundle.getString("MSGSUBSCRIBE_SMS"));
                    }
                %>
            </td>
        </tr>
<%
    }

    template_email = MessageTemplate.GetTemplate(user.GetUnitId(), MessageTemplate.MESSAGE_EMAIL, MessageTemplate.STATUS_FINISHED);
    template_sms = MessageTemplate.GetTemplate(user.GetUnitId(), MessageTemplate.MESSAGE_SMS, MessageTemplate.STATUS_FINISHED);
    if(template_email!=null || template_sms!=null)
    {
%>
    <tr height="30">
        <td width="250"><b><%=bundle.getString("MSGSUBSCRIBE_REJECTED")%></b></td>
        <td>
            <%
                if(template_email!=null)
                {
                    boolean is_listening = MessageTemplate.IsListening(user.GetId(), MessageTemplate.STATUS_REJECTED, MessageTemplate.MESSAGE_EMAIL);
                    out.println("<input type='checkbox' name='rejected_email' value='1' " + (is_listening?"checked":"") + ">" + bundle.getString("MSGSUBSCRIBE_EMAIL"));
                }
                if(template_sms!=null)
                {
                    boolean is_listening = MessageTemplate.IsListening(user.GetId(), MessageTemplate.STATUS_REJECTED, MessageTemplate.MESSAGE_SMS);
                    out.println("<input type='checkbox' name='rejected_sms' value='1' "+ (is_listening?"checked":"") +">" + bundle.getString("MSGSUBSCRIBE_SMS"));
                }
            %>
        </td>
    </tr>
<%
    }

    template_email = MessageTemplate.GetTemplate(user.GetUnitId(), MessageTemplate.MESSAGE_EMAIL, MessageTemplate.STATUS_FINISHED);
    template_sms = MessageTemplate.GetTemplate(user.GetUnitId(), MessageTemplate.MESSAGE_SMS, MessageTemplate.STATUS_FINISHED);
    if(template_email!=null || template_sms!=null)
    {
%>
    <tr height="30">
        <td width="250"><b><%=bundle.getString("MSGSUBSCRIBE_TERMINATED")%></b></td>
        <td>
            <%
                if(template_email!=null)
                {
                    boolean is_listening = MessageTemplate.IsListening(user.GetId(), MessageTemplate.STATUS_TERMINATED, MessageTemplate.MESSAGE_EMAIL);
                    out.println("<input type='checkbox' name='terminated_email' value='1' " + (is_listening?"checked":"") + ">" + bundle.getString("MSGSUBSCRIBE_EMAIL"));
                }
                if(template_sms!=null)
                {
                    boolean is_listening = MessageTemplate.IsListening(user.GetId(), MessageTemplate.STATUS_TERMINATED, MessageTemplate.MESSAGE_SMS);
                    out.println("<input type='checkbox' name='terminated_sms' value='1' " + (is_listening?"checked":"") + ">" + bundle.getString("MSGSUBSCRIBE_SMS"));
                }
            %>
        </td>
    </tr>
<%
    }

    template_email = MessageTemplate.GetTemplate(user.GetUnitId(), MessageTemplate.MESSAGE_EMAIL, MessageTemplate.STATUS_FINISHED);
    template_sms = MessageTemplate.GetTemplate(user.GetUnitId(), MessageTemplate.MESSAGE_SMS, MessageTemplate.STATUS_FINISHED);
    if(template_email!=null || template_sms!=null)
    {
%>
    <tr height="30">
        <td width="250"><b><%=bundle.getString("MSGSUBSCRIBE_REVOKED")%></b></td>
        <td>
            <%
                if(template_email!=null)
                {
                    boolean is_listening = MessageTemplate.IsListening(user.GetId(), MessageTemplate.STATUS_REVOKED, MessageTemplate.MESSAGE_EMAIL);
                    out.println("<input type='checkbox' name='revoked_email' value='1' " + (is_listening?"checked":"") + ">" + bundle.getString("MSGSUBSCRIBE_EMAIL"));
                }
                if(template_sms!=null)
                {
                    boolean is_listening = MessageTemplate.IsListening(user.GetId(), MessageTemplate.STATUS_REVOKED, MessageTemplate.MESSAGE_SMS);
                    out.println("<input type='checkbox' name='revoked_sms' value='1' " + (is_listening?"checked":"") + ">" + bundle.getString("MSGSUBSCRIBE_SMS"));
                }
            %>
        </td>
    </tr>
<%
    }

    template_email = MessageTemplate.GetTemplate(user.GetUnitId(), MessageTemplate.MESSAGE_EMAIL, MessageTemplate.STATUS_AGREED);
    template_sms = MessageTemplate.GetTemplate(user.GetUnitId(), MessageTemplate.MESSAGE_SMS, MessageTemplate.STATUS_AGREED);
    if(template_email!=null || template_sms!=null)
    {
%>
    <tr height="30">
        <td width="250"><b><%=bundle.getString("MSGSUBSCRIBE_AGREED")%></b></td>
        <td>
            <%
                if(template_email!=null)
                {
                    boolean is_listening = MessageTemplate.IsListening(user.GetId(), MessageTemplate.STATUS_AGREED, MessageTemplate.MESSAGE_EMAIL);
                    out.println("<input type='checkbox' name='agreed_email' value='1' " +  (is_listening?"checked":"")  + ">" + bundle.getString("MSGSUBSCRIBE_EMAIL"));
                }
                if(template_sms!=null)
                {
                    boolean is_listening = MessageTemplate.IsListening(user.GetId(), MessageTemplate.STATUS_AGREED, MessageTemplate.MESSAGE_SMS);
                    out.println("<input type='checkbox' name='agreed_sms' value='1' " +  (is_listening?"checked":"")  + ">" + bundle.getString("MSGSUBSCRIBE_SMS"));
                }
            %>
        </td>
    </tr>
<%
    }

    template_email = MessageTemplate.GetTemplate(user.GetUnitId(), MessageTemplate.MESSAGE_EMAIL, MessageTemplate.STATUS_FINISHED);
    template_sms = MessageTemplate.GetTemplate(user.GetUnitId(), MessageTemplate.MESSAGE_SMS, MessageTemplate.STATUS_FINISHED);
    if(template_email!=null || template_sms!=null)
    {
%>
    <tr height="30">
        <td width="250"><b><%=bundle.getString("MSGSUBSCRIBE_RETURNED")%></b></td>
        <td>
            <%
                if(template_email!=null)
                {
                    boolean is_listening = MessageTemplate.IsListening(user.GetId(), MessageTemplate.STATUS_RETURNED, MessageTemplate.MESSAGE_EMAIL);
                    out.println("<input type='checkbox' name='returned_email' value='1' " + (is_listening?"checked":"") + ">" + bundle.getString("MSGSUBSCRIBE_EMAIL"));
                }
                if(template_sms!=null)
                {
                    boolean is_listening = MessageTemplate.IsListening(user.GetId(), MessageTemplate.STATUS_RETURNED, MessageTemplate.MESSAGE_SMS);
                    out.println("<input type='checkbox' name='returned_sms' value='1' " + (is_listening?"checked":"") + ">" + bundle.getString("MSGSUBSCRIBE_SMS"));
                }
            %>
        </td>
    </tr>
<%
    }

    template_email = MessageTemplate.GetTemplate(user.GetUnitId(), MessageTemplate.MESSAGE_EMAIL, MessageTemplate.STATUS_FINISHED);
    template_sms = MessageTemplate.GetTemplate(user.GetUnitId(), MessageTemplate.MESSAGE_SMS, MessageTemplate.STATUS_FINISHED);
    if(template_email!=null || template_sms!=null)
    {
%>
    <tr height="30">
       <td width="250"><b><%=bundle.getString("MSGSUBSCRIBE_DELETED")%></b></td>
       <td>
           <%
               if(template_email!=null)
               {
                   boolean is_listening = MessageTemplate.IsListening(user.GetId(), MessageTemplate.STATUS_DELETED, MessageTemplate.MESSAGE_EMAIL);
                   out.println("<input type='checkbox' name='deleted_email' value='1' " + (is_listening?"checked":"") + ">" + bundle.getString("MSGSUBSCRIBE_EMAIL"));
               }
               if(template_sms!=null)
               {
                   boolean is_listening = MessageTemplate.IsListening(user.GetId(), MessageTemplate.STATUS_DELETED, MessageTemplate.MESSAGE_SMS);
                   out.println("<input type='checkbox' name='deleted_sms' value='1' " + (is_listening?"checked":"") + ">" + bundle.getString("MSGSUBSCRIBE_SMS"));
               }
           %>
       </td>
    </tr>
<%
    }
%>
</form>
</table>
</body>
</html>