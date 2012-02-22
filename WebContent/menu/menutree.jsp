<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>

<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
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
        var menutree=new dhtmlXTreeObject("divTree1","100%","100%",0);
        menutree.enableCheckBoxes(false);
        menutree.enableDragAndDrop(false);
        menutree.setOnClickHandler(f_click);
        menutree.setImagePath("/dhxtree/imgs/csh_vista/");
        menutree.setXMLAutoLoading("ajaxmenus.jsp");
        menutree.attachEvent("onXLE", f_xle);
        menutree.loadXML("ajaxmenus.jsp");

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
            var menuid = menutree.getUserData(nodeId,"menuid");
            document.menuform.id.value = menuid;
            document.menuform.submit();
        }
    </script>

    <form name="menuform" method="post" target="menuMain" action="menuinfo.jsp">
       <input type=hidden name="id" value="">
    </form>
</body>
</html>