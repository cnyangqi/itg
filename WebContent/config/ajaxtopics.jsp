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

    String tree_id = "0";
    if(params==null || params.length==1)
        tree_id = "0";
    else
       tree_id = id;

    response.setContentType("text/xml;charset=UTF-8");
    response.setCharacterEncoding("UTF-8");
    PrintWriter writer = response.getWriter();
    writer.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
    writer.println("<tree id=\""+tree_id+"\">");

    //顶级节点
    if(id==null || "0".equals(id))
    {
        //site_list中存放的是以ID为索引，值为name
        java.util.Hashtable site_list = user.GetOwnSites();
        if(site_list!=null && !site_list.isEmpty())
        {
            NpsContext ctxt = null;
            Connection conn = null;
            java.util.Enumeration  site_ids = site_list.keys();
            try
            {
                while(site_ids.hasMoreElements())
                {
                    if(ctxt==null)
                    {
                        conn = Database.GetDatabase("nps").GetConnection();
                        ctxt = new NpsContext(conn,user);
                    }

                    String site_id = (String)site_ids.nextElement();
                    //产生栏目树
                    Site site = ctxt.GetSite(site_id);
                    if(site!=null)
                    {
                        TopicTree topic_tree = site.GetTopicTree();
                        topic_tree.AjaxDHXTree(writer,null,TopicTree.ViewMode.ALL);
                    }
                }
            }
            catch(Exception e)
            {
                e.printStackTrace();
            }
            finally
            {
                if(ctxt!=null) ctxt.Clear();
            }
        }

        writer.println("</tree>");
        return;
    }

    //某级栏目
    String site_id = params[0];
    String top_id = null;
    if(params.length > 1) top_id = params[1];

    try
    {
        Site site = user.GetSite(site_id);
        if(site!=null)
        {
            TopicTree topic_tree = site.GetTopicTree();
            topic_tree.AjaxDHXTree(writer,top_id, TopicTree.ViewMode.ALL);
        }
    }
    catch(Exception e)
    {
        e.printStackTrace();
    }

    writer.println("</tree>");
    writer.flush();
%>
