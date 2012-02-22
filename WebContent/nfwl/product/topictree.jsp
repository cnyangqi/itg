<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>

<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String status = request.getParameter("status");
    if(status==null || status.length()==0) status="3";
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

        function f_setstatus(i)
        {
            document.artform.status.value = i;
        }

        function f_click(nodeId)
        {
            var siteid = topictree.getUserData(nodeId,"siteid");
            var topid = topictree.getUserData(nodeId,"topid");
            document.artform.site_id.value = siteid;
            document.artform.top_id.value = topid;
            document.artform.submit();
        }
    </script>

    <form name="artform" method="post" target="artMain" action="articlelist.jsp">
       <input type=hidden name="site_id" value="">
       <input type=hidden name="top_id" value="">
       <input type="hidden" name="status"  value="<%=status%>">
    </form>
</body>
</html>