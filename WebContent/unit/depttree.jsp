<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.exception.*" %>
<%@ page import="nps.util.*" %>

<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_depttree",user.GetLocale(), Config.RES_CLASSLOADER);

    String id = request.getParameter("id");
    if(id!=null) id = id.trim();

    Unit unit = null;
    if(id!=null && id.length()>0)
    {
        unit = user.GetUnit(id);
        if(unit==null) throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);
    }
%>

<head>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <script  src="/dhxtree/dhtmlxcommon.js"></script>
    <script  src="/dhxtree/dhtmlxtree.js"></script>

    <link rel="STYLESHEET" type="text/css" href="/dhxtree/dhtmlxtree.css">
    <LINK href="/css/style.css" rel = stylesheet>
</head>
<BODY leftmargin="0" topmargin="0" style="background-color: #fafaf0">
    <DIV id=divTree1 noWrap></DIV>

    <script language="javascript">
        var depttree=new dhtmlXTreeObject("divTree1","100%","100%","-1");
        depttree.enableCheckBoxes(false);
        depttree.enableDragAndDrop(true);
        depttree.setImagePath("/dhxtree/imgs/csh_vista/");
        depttree.setOnClickHandler(f_click);
        depttree.attachEvent("onDrag","f_drag");
        depttree.setXMLAutoLoading("ajaxdepts.jsp");
        depttree.attachEvent("onXLE", f_xle);
        depttree.loadXML("ajaxdepts.jsp?id=<%=Utils.Null2Empty(id)%>");

        function f_xle(tree,nodeId)
        {
            if(nodeId=="-1")
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
            var unitid = depttree.getUserData(nodeId,"unitid");
            var deptid = depttree.getUserData(nodeId,"deptid");
            document.deptform.unitid.value = unitid;
            document.deptform.deptid.value = deptid;
            document.deptform.submit();
        }

       function f_drag(nodeId,targetNodeId,targetBeforeNodeId,srcTree,destTree)
        {
            var unit_fromid = srcTree.getUserData(nodeId,"unitid");
            var unit_fromname = srcTree.getUserData(nodeId,"unitname");
            var dept_fromid = srcTree.getUserData(nodeId,"deptid");
            var dept_fromname = srcTree.getUserData(nodeId,"deptname");

            var unit_toid = destTree.getUserData(targetNodeId,"unitid");
            var unit_toname = destTree.getUserData(targetNodeId,"unitname");
            var dept_toid = destTree.getUserData(targetNodeId,"deptid");
            var dept_toname = destTree.getUserData(targetNodeId,"deptname");

            if(unit_toid==null || unit_toid.length==0)  return false;
            if(dept_fromid==null || dept_fromid.length==0)  return false;
            
            var message = "<%=bundle.getString("DEPTTREE_ALTER_MOVE")%>";
            message += "\r\n<%=bundle.getString("DEPTTREE_MOVE_SOURCE")%>"+dept_fromname;

            if(dept_toid!=null && dept_toid.length>0)
            {
                message += "\r\n<%=bundle.getString("DEPTTREE_MOVE_DEST")%>"+dept_toname;
            }
            else
            {
                message += "\r\n<%=bundle.getString("DEPTTREE_MOVE_DEST")%>"+unit_toname;
            }

            var r = confirm(message);
            if(r==1)
            {
                document.moveform.unit_fromid.value = unit_fromid;
                document.moveform.dept_fromid.value = dept_fromid;
                document.moveform.unit_toid.value = unit_toid;
                document.moveform.dept_toid.value = dept_toid;
                document.moveform.submit();
                return true;
            }
            return false;
        }
    </script>

    <form name="deptform" method="post" target="deptMain" action="deptinfo.jsp">
       <input type=hidden name="unitid" value="">
       <input type=hidden name="deptid" value="">
    </form>

    <form name="moveform" method="post" target="deptMain" action="deptmove.jsp">
       <input type=hidden name="unit_fromid" value="">
       <input type=hidden name="dept_fromid" value="">
       <input type=hidden name="unit_toid" value="">
       <input type=hidden name="dept_toid" value="">
    </form>
</body>
</html>