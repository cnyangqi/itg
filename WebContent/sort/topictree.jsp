<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>

<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    if(!user.IsLocalAdmin()) throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);
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
        topictree.enableDragAndDrop(false);
        topictree.setOnClickHandler(f_click);
        topictree.setImagePath("/dhxtree/imgs/csh_vista/");
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
            if(topid!="")
            {
                document.orderform.site_id.value = siteid;
                document.orderform.top_id.value = topid;
                document.orderform.submit();
            }
        }

        function f_setpreview(b)
        {
            document.orderform.image_preview.value = b?1:0;
        }

        function f_sethtmlescape(b)
        {
            document.orderform.html_escape.value = b?1:0;
        }
    </script>

    <form name="orderform" method="post" target="artMain" action="linklist.jsp">
       <input type=hidden name="site_id" value="">
       <input type=hidden name="top_id" value="">
       <input type=hidden name="image_preview" value="0">
       <input type=hidden name="html_escape" value="1">
    </form>
</body>
</html>