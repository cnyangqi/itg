<%@ page language="java" contentType="text/html;charset=UTF-8" errorPage="/error.jsp"%>

<%@ include file = "/include/header.jsp" %>

<%
   String siteid = request.getParameter("siteid");
%>
<html>
  <head>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <script src="/dhxtree/dhtmlxcommon.js"></script>
    <script src="/dhxtree/dhtmlxtree.js"></script>

    <link rel="STYLESHEET" type="text/css" href="/dhxtree/dhtmlxtree.css">
    <link rel="STYLESHEET" type="text/css" href="/css/style.css">
  </head>
  <BODY leftmargin="0" topmargin="0">
    <DIV id=divTree1 noWrap></DIV>

    <script language="javascript">
        var topictree=new dhtmlXTreeObject("divTree1","100%","100%",0);
        topictree.enableCheckBoxes(false);
        topictree.enableDragAndDrop(false);
        topictree.setOnClickHandler(f_click);
        topictree.setImagePath("/dhxtree/imgs/csh_vista/");
        topictree.setXMLAutoLoading("ajaxtopics.jsp");
        topictree.attachEvent("onXLE", f_xle);
        topictree.loadXML("ajaxtopics.jsp?id=<%=siteid==null||siteid.length()==0?"0":siteid%>");

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
            var sitename = topictree.getUserData(nodeId,"sitename");
            var topid = topictree.getUserData(nodeId,"topid");
            var topname = topictree.getUserData(nodeId,"topname");
            var tname = topictree.getUserData(nodeId,"tname");

            if(topid)
            {
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