<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.workflow.WorkProcess" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.workflow.Engine" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String act = request.getParameter("act");
    String id = request.getParameter("id");
    if(id!=null) id = id.trim();
    if(id!=null && id.length()==0) id = null;
    boolean bNew = (id==null);
    
    Connection conn = null;
    WorkProcess process = null;
    try
    {
        conn = Database.GetDatabase("nps").GetConnection();
        conn.setAutoCommit(false);
        if("0".equals(act))
        {
            //保存
            String name = request.getParameter("process_name");
            if(name==null||name.length()==0)  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
            String s_scope = request.getParameter("process_scope");
            int scope = WorkProcess.SCOPE_GLOBAL;
            try{scope = Integer.parseInt(s_scope); } catch(Exception e){}
            String unit_id = request.getParameter("unit_id");
            String s_status = request.getParameter("process_status");
            String xml = request.getParameter("xml");
            if(xml==null||xml.length()==0)  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
            
            if(bNew)
            {
                process = new WorkProcess(name);
                process.SetCreator(user.GetId(),user.GetName());
            }
            else
            {
                process = Engine.GetInstance().GetProcess(id);
                if(process==null) throw new NpsException(ErrorHelper.SYS_NOTEXIST, "process id=" + id);
                process.SetName(name);
            }

            process.SetScope(scope);
            switch(scope)
            {
                case WorkProcess.SCOPE_GLOBAL:
                    process.SetUnitId(null);
                    break;
                case WorkProcess.SCOPE_COMPANY:
                    if(unit_id==null || unit_id.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
                    process.SetUnitId(unit_id);
                    break;
            }
            process.SetStatus("1".equals(s_status));
            process.Save(conn);
            process.UpdateXML(conn,xml);

            if(bNew) Engine.GetInstance().AddProcess(process);
            id = process.GetId();
            conn.commit();
            response.sendRedirect("processinfo.jsp?id=" + id);
            return;
        }
        else if("1".equals(act))
        {
            //删除
            process = Engine.GetInstance().GetProcess(id);
            if(process==null) throw new NpsException(ErrorHelper.SYS_NOTEXIST, "process id=" + id);

            process.Remove(conn);
            Engine.GetInstance().RemoveProcess(id);

            conn.commit();
            out.println("<font color=red>" + process.GetName()+ " removed.</font>");
            return;
        }
    }
    catch(Exception e)
    {
        try{conn.rollback();}catch(Exception e1){}
        throw e;
    }
    finally
    {
        if(conn!=null) try{conn.close();}catch(Exception e){}
    }
%>