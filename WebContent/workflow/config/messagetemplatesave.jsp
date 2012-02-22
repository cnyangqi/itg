<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.workflow.message.MessageTemplate" %>
<%@ page import="nps.BasicContext" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String act = request.getParameter("act");
    String id = request.getParameter("id");
    boolean bNew = id==null||id.length()==0;

    BasicContext ctxt = null;
    MessageTemplate template = null;
    try
    {
        Connection conn = Database.GetDatabase("nps").GetConnection();
        conn.setAutoCommit(false);
        ctxt = new BasicContext(conn, user);
        if("0".equals(act))
        {
            //保存
            String subject = request.getParameter("subject");
            if(subject==null||subject.length()==0)  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

            String s_job_status = request.getParameter("job_status");
            if(s_job_status==null||s_job_status.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
            int job_status = MessageTemplate.STATUS_PENDING;
            try{job_status=Integer.parseInt(s_job_status);}catch(Exception e){}

            String s_scope = request.getParameter("scope");
            int scope = MessageTemplate.SCOPE_GLOBAL;
            try{scope=Integer.parseInt(s_scope);}catch(Exception e){}
            String unit_id = request.getParameter("unit_id");
            if(scope==MessageTemplate.SCOPE_COMPANY && (unit_id==null||unit_id.length()==0)) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

            String s_message_type = request.getParameter("message_type");
            int message_type = MessageTemplate.MESSAGE_EMAIL;
            try{message_type=Integer.parseInt(s_message_type);}catch(Exception e){}

            String content = request.getParameter("content");
            if(content==null||content.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
            if(bNew)
            {
                template = new MessageTemplate(message_type,job_status,subject);
                template.SetCreator(user.GetId(), user.GetName());
            }
            else
            {
                template = MessageTemplate.GetTemplate(id);
                if(template==null) throw new NpsException(ErrorHelper.SYS_NOTEXIST, "message template=" + id);
                template.SetType(message_type);
                template.SetJobStatus(job_status);
                template.SetSubject(subject);
            }

            if(scope==MessageTemplate.SCOPE_GLOBAL)
                template.SetGlobal();
            else
                template.SetScope(unit_id);

            template.SetContent(content);
            template.Save(ctxt);

            id = template.GetId();
            ctxt.Commit();
            response.sendRedirect("messagetemplate.jsp?id=" + id);
            return;
        }
        else if("1".equals(act))
        {
            //删除
            template = MessageTemplate.GetTemplate(id);
            if(template==null) throw new NpsException(ErrorHelper.SYS_NOTEXIST, "Message template id=" + id);

            template.Delete(ctxt);

            ctxt.Commit();
            out.println("<font color=red>" + template.GetSubject() + " removed.</font>");
            return;
        }
    }
    catch(Exception e)
    {
        try{ctxt.Rollback();}catch(Exception e1){}
        throw e;
    }
    finally
    {
        if(ctxt!=null) try{ctxt.Clear();}catch(Exception e){}
    }
%>