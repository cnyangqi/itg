<%@ page language="java" contentType="text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.core.*" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="java.sql.Connection" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    String id = request.getParameter("id");
    String[] params = null;
    if(id!=null) params = id.split("\\.");

    String tree_id = "-1";
    if(params==null || params.length==1)
        tree_id = "-1";
    else
       tree_id = id;

    Connection conn = null;

    response.setContentType("text/xml;charset=UTF-8");
    response.setCharacterEncoding("UTF-8");
    PrintWriter writer = response.getWriter();
    writer.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
    writer.println("<tree id=\""+tree_id+"\">");

    try
    {
        //顶级节点
        if(id==null || id.length()==0 || "-1".equals(id))
        {
            conn = Database.GetDatabase("nps").GetConnection();
            java.util.List units = user.GetUnits(conn);
            
            if(units!=null)
            {
                for(Object obj:units)
                {
                    try
                    {
                        Unit  unit = (Unit)obj;

                        DeptTree tree = unit.GetDeptTree(conn);
                        if(tree!=null) tree.AjaxDHXTree(writer,null);
                    }
                    catch(Exception e)
                    {
                        e.printStackTrace();
                    }
                }
             }

            writer.println("</tree>");
            return;
        }

        //某个部门
        if(params.length>2)
        {
            //已经到用户一级了
            writer.println("</tree>");
            return;
        }

        String unit_id = params[0];
        String dept_id = null;
        if(params.length > 1) dept_id = params[1];

        try
        {
            if(conn==null) conn = Database.GetDatabase("nps").GetConnection();

            //加载指定unit的信息
            Unit unit = Unit.GetUnit(conn,unit_id);
            if(unit!=null)
            {
                DeptTree tree = unit.GetDeptTree(conn);
                if(tree!=null) tree.AjaxDHXTree(writer,dept_id);
            }
        }
        catch(Exception e)
        {
            e.printStackTrace();
        }
    }
    finally
    {
        if(conn!=null) try{conn.close();}catch(Exception e){}
    }

    writer.println("</tree>");
    writer.flush();
%>