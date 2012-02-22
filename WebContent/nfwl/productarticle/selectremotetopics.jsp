<%@ page language="java" contentType="text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.core.NpsWrapper" %>
<%@ page import="nps.core.TopicTree" %>
<%@ page import="nps.exception.*" %>
<%@ page import="nps.core.Site" %>
<%@ page import="nps.job.atom.AtomClient" %>
<%@ page import="nps.util.Utils" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    String remote_host = request.getParameter("remote_host");
    String uid = request.getParameter("uid");
    String pwd = request.getParameter("pwd");

    if(   remote_host==null || remote_host.trim().length()==0
       || uid==null || uid.trim().length()==0
       || pwd==null || pwd.trim().length()==0)
        throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
%>
<html>
  <head>
    <script type="text/javascript" src="/jscript/global.js"></script>
      <script  src="/dhxtree/dhtmlxcommon.js"></script>
      <script  src="/dhxtree/dhtmlxtree.js"></script>

      <link rel="STYLESHEET" type="text/css" href="/dhxtree/dhtmlxtree.css">
      <LINK href="/css/style.css" rel = stylesheet>
  </head>
  <BODY leftmargin="0" topmargin="0" scroll="no" style="overflow-x:hidden;overflow-y:hidden">
    <DIV id=divTree1 noWrap></DIV>

    <script language="javascript">
        var topictree=new dhtmlXTreeObject("divTree1","100%","100%",0);
        topictree.enableCheckBoxes(false);
        topictree.enableDragAndDrop(false);
        topictree.setOnClickHandler(f_click);
        topictree.setImagePath("/dhxtree/imgs/csh_vista/");
<%
        AtomClient client = new AtomClient(remote_host);

        String url_login = remote_host + "/webapi/login";
        url_login = Utils.FixURL(url_login);
        client.NpsLogin(url_login,uid,pwd);

        String url_topics = remote_host + "/webapi/topics/tree";
        url_topics = Utils.FixURL(url_topics);
        out.println(client.GetTopics(url_topics));
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
            
            parent.f_settopic(siteid,sitename,topid,topname);
        }
    </script>
  </body>
</html>