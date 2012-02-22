<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.core.*" %>
<%@ page import="java.util.ResourceBundle" %>

<%@ include file="/include/header.jsp" %>

<%
        request.setCharacterEncoding("UTF-8");
        ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_topictree",user.GetLocale(), Config.RES_CLASSLOADER);
%>

<head>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <script  src="/dhxtree/dhtmlxcommon.js"></script>
    <script  src="/dhxtree/dhtmlxtree.js"></script>

    <link rel="STYLESHEET" type="text/css" href="/dhxtree/dhtmlxtree.css">
</head>
<BODY leftmargin="0" topmargin="0" style="background-color: #fafaf0;overflow-y: hidden;">
    <DIV id=divTree1 noWrap></DIV>

    <script language="javascript">
        var topictree=new dhtmlXTreeObject("divTree1","100%","100%",0);
        topictree.enableCheckBoxes(false);
        topictree.enableDragAndDrop(true);
        topictree.setOnClickHandler(f_click);
        topictree.setImagePath("/dhxtree/imgs/csh_vista/");
        topictree.attachEvent("onDrag","f_drag");
        topictree.setXMLAutoLoading("ajaxtopics.jsp");
        topictree.attachEvent("onXLE", f_xle);
        topictree.loadXML("ajaxtopics.jsp?id=0");

        function f_xle(tree,nodeId)
        {
            if(nodeId=="0")
            {
                var childs = tree.hasChildren(nodeId);
                for(var i=0;i<childs;i++)
                {
                    tree.openItem(tree.getChildItemIdByIndex(nodeId,i));
                }
            }
        }

        function f_click(nodeId)
        {
            var siteid = topictree.getUserData(nodeId,"siteid");
            var topid = topictree.getUserData(nodeId,"topid");
            document.topicform.siteid.value = siteid;
            document.topicform.topid.value = topid;
            document.topicform.submit();
        }

        function f_drag(nodeId,targetNodeId,targetBeforeNodeId,srcTree,destTree)
        {
            var site_fromid = srcTree.getUserData(nodeId,"siteid");
            var site_fromname = srcTree.getUserData(nodeId,"sitename");
            var top_fromid = srcTree.getUserData(nodeId,"topid");
            var top_fromname = srcTree.getUserData(nodeId,"topname");

            var site_toid = destTree.getUserData(targetNodeId,"siteid");
            var site_toname = destTree.getUserData(targetNodeId,"sitename");
            var top_toid = destTree.getUserData(targetNodeId,"topid");
            var top_toname = destTree.getUserData(targetNodeId,"topname");

            if(site_toid==null || site_toid.length==0)  return false;
            
            var message = "<%=bundle.getString("TOPICTREE_ALERT_CONFIRM_COPY")%>";
            if(top_fromid!=null && top_fromid.length>0)
            {
                message += "\r\n<%=bundle.getString("TOPICTREE_ALERT_COPY_SOURCE")%>"+top_fromname+"("+site_fromname+")";
            }
            else
            {
                message += "\r\n<%=bundle.getString("TOPICTREE_ALERT_COPY_SOURCE")%>"+site_fromname;
            }
            if(top_toid!=null && top_toid.length>0)
            {
                message += "\r\n<%=bundle.getString("TOPICTREE_ALERT_COPY_DEST")%>"+top_toname+"("+site_toname+")";
            }
            else
            {
                message += "\r\n<%=bundle.getString("TOPICTREE_ALERT_COPY_DEST")%>"+site_toname;
            }

            var r = confirm(message);
            if(r==1)
            {
               var r_mode =  confirm("<%=bundle.getString("TOPICTREE_ALERT_COPY_OR_MOVE")%>");
               if(r_mode==1)
               {
                    document.moveform.move_mode.value = "0";
                    document.moveform.site_fromid.value = site_fromid;
                    document.moveform.top_fromid.value = top_fromid;
                    document.moveform.site_toid.value = site_toid;
                    document.moveform.top_toid.value = top_toid;
                    document.moveform.submit();
                    return false;
               }
               else
               {
                   document.moveform.move_mode.value = "1"; 
                   document.moveform.site_fromid.value = site_fromid;
                   document.moveform.top_fromid.value = top_fromid;
                   document.moveform.site_toid.value = site_toid;
                   document.moveform.top_toid.value = top_toid;
                   document.moveform.submit();
                   return true;
               }
            }
            return false;
        }
        
        function f_update(topid,topname)
        {
            var nodeid="topic"+topid;
            topictree.setItemText(nodeid,topname);
        }

        function f_delete(topid)
        {
            var nodeid="topic"+topid;
            topictree.deleteItem(nodeid);
        }
    </script>
    
    <form name="topicform" method="post" target="topicMain" action="topicinfo.jsp">      
       <input type=hidden name="siteid" value="">
       <input type=hidden name="topid" value="">
    </form>

    <form name="moveform" method="post" target="topicMain" action="topicmove.jsp">      
       <input type=hidden name="site_fromid" value="">
       <input type=hidden name="top_fromid" value="">
       <input type=hidden name="site_toid" value="">
       <input type=hidden name="top_toid" value="">
       <input type="hidden" name="move_mode" value="0">
    </form>
</body>
</html>