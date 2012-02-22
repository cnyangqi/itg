<%@ page language="java" contentType="text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.core.NpsWrapper" %>
<%@ page import="nps.core.TopicTree" %>
<%@ page import="nps.core.Site" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
%>
<html>
  <head>
    <script type="text/javascript" src="/jscript/global.js"></script>
      <script  src="/dhxtree/dhtmlxcommon.js"></script>
      <script  src="/dhxtree/dhtmlxtree.js"></script>

      <link rel="STYLESHEET" type="text/css" href="/dhxtree/dhtmlxtree.css">
      <LINK href="/css/style.css" rel = stylesheet>
  </head>
  <BODY leftmargin="0" topmargin="0">
    <DIV id=divTree1 noWrap></DIV>

    <script language="javascript">
        var topictree=new dhtmlXTreeObject("divTree1","100%","100%",0);
        topictree.enableCheckBoxes(false);
        topictree.enableDragAndDrop(false);
        topictree.setOnClickHandler(f_click);
        topictree.setImagePath("/dhxtree/imgs/csh_vista/");
<%
        //site_list中存放的是以ID为索引，值为name
        java.util.Hashtable site_list = null;

        NpsWrapper wrapper = null;
        try
        {
            //首先查看本单位站点信息
            //site_list中存放的是以ID为索引，值为name
            site_list = user.IsNormalUser()?user.GetUnitSites():user.GetOwnSites();
            if(site_list!=null && !site_list.isEmpty())
            {
                java.util.Enumeration  site_ids = site_list.keys();
                while(site_ids.hasMoreElements())
                {
                    String site_id = (String)site_ids.nextElement();
                    //产生栏目树
                    if(wrapper==null) wrapper = new NpsWrapper(user,site_id);
                    Site site = wrapper.GetSite(site_id);
                    if(site!=null)
                    {
                        TopicTree topic_tree = site.GetTopicTree();
                        if(topic_tree!=null) out.println(topic_tree.toDHXTree("topictree","0",TopicTree.ViewMode.VISIBLE));
                    }
                }
             }
        }
        catch(Exception e)
        {
            e.printStackTrace();
        }
        finally
        {
            if(wrapper!=null) wrapper.Clear();
        }
%>
        function f_click(nodeId)
        {
            var siteid = topictree.getUserData(nodeId,"siteid");
            var sitename = topictree.getUserData(nodeId,"sitename");
            var topid = topictree.getUserData(nodeId,"topid");
            var topname = topictree.getUserData(nodeId,"topname");
            var tname = topictree.getUserData(nodeId,"tname");

            if(topictree.hasChildren(nodeId)>0)
            {
                topictree.openItem(nodeId);
            }
            else
            {
                if(tname)    return;

                var isMSIE= (navigator.appName == "Microsoft Internet Explorer");
                 if (isMSIE)
                 {
                     var   rt = new Array(4);
                     rt[0] = siteid;
                     rt[1] = sitename;
                     rt[2] = topid;
                     rt[3] = topname;
                     window.returnValue= rt;
                 }
                 else
                 {
                     parent.opener.f_settopic(siteid,sitename,topid,topname);
                 }

                 top.close();
            }
        }
    </script>
  </body>
</html>