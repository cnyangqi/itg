<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.workflow.WorkProcess" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.workflow.Engine" %>
<%@ page import="nps.workflow.BusinessType" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String act = request.getParameter("act");
    String id = request.getParameter("id");
    if(id==null||id.length()==0)  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    String is_new = request.getParameter("is_new");
    boolean bNew = "1".equals(is_new);

    Connection conn = null;
    BusinessType type = null;
    try
    {
        conn = Database.GetDatabase("nps").GetConnection();
        conn.setAutoCommit(false);
        if("0".equals(act))
        {
            //保存
            String name = request.getParameter("type_name");
            if(name==null||name.length()==0)  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
            String unit_id = request.getParameter("unit_id");
            if(unit_id==null||unit_id.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
            String s_status = request.getParameter("type_status");
            String process_id = request.getParameter("process_id");
            if(process_id==null||process_id.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
            WorkProcess process =  Engine.GetInstance().GetProcess(process_id);
            if(process==null) throw new NpsException(ErrorHelper.SYS_NOTEXIST, "process id=" + process_id);
            String sIndex = request.getParameter("type_index");
            int index = 0;
            try{index = Integer.parseInt(sIndex);}catch(Exception e){}
            String url = request.getParameter("url");
            if(url==null||url.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

            if(bNew)
            {
                type = new BusinessType(id,name,process);
                type.SetCreator(user.GetId(), user.GetName());
            }
            else
            {
                type = BusinessType.Get(id);
                if(type==null) throw new NpsException(ErrorHelper.SYS_NOTEXIST, "business type=" + id);
                type.SetName(name);
                type.SetProcess(process_id);
            }

            type.SetUnitId(unit_id);
            type.SetStatus("1".equals(s_status));
            type.SetURL(url);
            type.SetIndex(index);
            type.Save(conn);

            id = type.GetId();
            conn.commit();
            response.sendRedirect("businesstype.jsp?id=" + id);
            return;
        }
        else if("1".equals(act))
        {
            //删除
            type = BusinessType.Get(id);
            if(type==null) throw new NpsException(ErrorHelper.SYS_NOTEXIST, "business type id=" + id);

            type.Remove(conn,false);

            conn.commit();
            out.println("<font color=red>" + type.GetName()+ " removed.</font>");
            return;
        }
        else if("2".equals(act))
        {
            //彻底删除，包括drop表
            type = BusinessType.Get(id);
            if(type==null) throw new NpsException(ErrorHelper.SYS_NOTEXIST, "business type id=" + id);

            type.Remove(conn,true);

            conn.commit();
            out.println("<font color=red>" + type.GetName()+ " removed.</font>");
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