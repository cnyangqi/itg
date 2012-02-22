<%@page import="tools.Pub"%>
<%@ page language="java" contentType="text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="nps.core.*" %>
                        
<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String id = request.getParameter("id");
    String isBusiness = Pub.getString(request.getParameter("isBusiness"),"");

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
        NpsContext ctxt = null;
        Connection conn = null;

        try
        {
            //首先查看本单位站点信息
            //site_list中存放的是以ID为索引，值为name
            java.util.Hashtable site_list = user.IsNormalUser()?user.GetUnitSites():user.GetOwnSites();
            if(site_list!=null && !site_list.isEmpty())
            {
                java.util.Enumeration  site_ids = site_list.keys();
                while(site_ids.hasMoreElements())
                {
                    String site_id = (String)site_ids.nextElement();
                    //产生栏目树
                    if(ctxt==null)
                    {
                        conn = Database.GetDatabase("nps").GetConnection();
                        ctxt = new NpsContext(conn,user);
                    }
                    Site site = ctxt.GetSite(site_id);
                    if(site!=null)
                    {
                        TopicTree topic_tree = site.GetTopicTree();
                        if(Pub.isEmpty(isBusiness)){
                          topic_tree.AjaxDHXTree(writer,null,TopicTree.ViewMode.VISIBLE);
                        }else{
                          topic_tree.AjaxDHXTree(writer,null,TopicTree.ViewMode.VISIBLE,Pub.getInteger(isBusiness).intValue());
                        }
                       
                    }
                }
             }

             //查看所有公开栏目的站点信息
             site_list = user.GetPublicSites();
             if(site_list!=null && !site_list.isEmpty())
             {
                java.util.Enumeration  site_ids = site_list.keys();
                while(site_ids.hasMoreElements())
                {
                    String site_id = (String)site_ids.nextElement();
                    //产生栏目树
                    if(ctxt==null)
                    {
                        conn = Database.GetDatabase("nps").GetConnection();
                        ctxt = new NpsContext(conn,user);
                    }

                    Site site = ctxt.GetSite(site_id);
                    if(site!=null)
                    {
                        TopicTree topic_tree = site.GetTopicTree();
                        
                        if(Pub.isEmpty(isBusiness)){
                          topic_tree.AjaxDHXTree(writer,null,TopicTree.ViewMode.PUBLIC);
                        }else{
                          topic_tree.AjaxDHXTree(writer,null,TopicTree.ViewMode.PUBLIC,Pub.getInteger(isBusiness).intValue());
                        }
                        
                    }
                }
             }
        }
        finally
        {
            if(ctxt!=null) ctxt.Clear();
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
            if(Pub.isEmpty(isBusiness)){
              topic_tree.AjaxDHXTree(writer,top_id, TopicTree.ViewMode.ALL);  
            }else{
              topic_tree.AjaxDHXTree(writer,top_id, TopicTree.ViewMode.ALL,Pub.getInteger(isBusiness).intValue());
            }
            
        }
    }
    catch(Exception e)
    {
        e.printStackTrace();
    }

    writer.println("</tree>");
    writer.flush();
%>