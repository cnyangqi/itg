<%@ page contentType="text/html; charset=UTF-8" language="java" errorPage="/error.jsp" %>
<%@ page import="nps.core.MenuTree" %>
<%@ page import="nps.core.Menu" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="nps.util.tree.Node" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.util.List" %>

<%@ include file="/include/header.jsp" %>

<%
    String id = request.getParameter("id");
%>
<html>
<head>
    <title>Navigation</title>
    <LINK href="/css/nav.css" rel = stylesheet>
    <script language="javascript">
        function selected(obj)
        {
            for(var i=0;i<document.links.length;i++)
            {
                document.links[i].className="";
            }

            obj.className="selected";
        }
    </script>
</head>
<BODY leftmargin="0" topmargin="0" rightmargin="0">
<div class="userInfor">	  
    <a href="/unit/myinfo.jsp" target="mainFrame"><img src="<%=user.GetFace()==null?"/images/face.jpg":"/images/face/"+user.GetFace()%>" width=100 border="0"></a>
    <br><strong><%=user.GetName()%></strong>
</div>
<div id="PARENT">
<ul id="nav">
<%
    MenuTree menutree = MenuTree.GetInstance();
    if(id==null || id.length()==0)
    {
        //确认默认项
        id = null;
        Iterator childs_iterator = menutree.GetChilds(null);
        while(childs_iterator!=null && childs_iterator.hasNext())
        {
            Node node = (Node)childs_iterator.next();
            Menu menu = (Menu)node.GetValue();

            //如果没有设置任何默认项，以第一个为准
            if(id==null)
            {
                id = menu.GetId();
                if(menu.IsDefault()) break;
            }
            else if(menu.IsDefault())
            {
                //如果设置多个默认项，以第一个为准
                id = menu.GetId();
                break;
            }
        }
    }

    Menu parent = menutree.GetMenu(id);
    Iterator childs_iterator = menutree.GetChilds(parent);
    if(childs_iterator!=null)
    {
        //默认打开Default菜单项
        boolean bOpen = false;
        String default_menu = null;
        while(childs_iterator.hasNext())
        {
            Node node = (Node)childs_iterator.next();
            Menu menu = (Menu)node.GetValue();

            if(!menu.IsAccessbile(user)) continue;

            if(menu.IsDefault() && menu.GetURL()!=null && !bOpen)
            {
                out.print("<script language='javascript'>");
                out.print("window.open(");
                out.print("\"" + menu.GetURL() + "\",");
                out.print("\"" + Utils.NVL(menu.GetTarget(),"mainFrame") + "\"");
                out.print(");");
                out.println("</script>");

                bOpen = true;
                default_menu = menu.GetId();
            }

            if(menu.HasChilds())
            {
%>
    <li><a href="#Menu=menu_<%=menu.GetId()%>"  onclick="DoMenu('menu_<%=menu.GetId()%>')" <% if(menu.GetId().equals(default_menu)) out.print(" class=\"selected\"");%>><%=Utils.TransferToHtmlEntity(menu.GetName())%></a>
        <ul id="menu_<%=menu.GetId()%>" class="collapsed">
            <%
                List<Menu> childs = menu.GetChilds();
                if(childs!=null)
                {
                    for(Menu menu_subitem:childs)
                    {
                        out.print("<li>");
                        out.print("<a href=\"" + Utils.Null2Empty(menu_subitem.GetURL())+"\"");
                        out.print(" target=\"" + Utils.NVL(menu_subitem.GetTarget(),"mainFrame") + "\"");
                        out.print(" onclick=\"selected(this)\"");
                        out.print(">");
                        out.print(menu_subitem.GetName());
                        out.print("</a>");
                        out.println("</li>");
                    }
                }
            %>
        </ul>
    </li>
<%
            }
            else
            {
                out.print("<li>");
                out.print("<a href=\"" + Utils.Null2Empty(menu.GetURL())+"\"");
                if(menu.GetId().equals(default_menu)) out.print(" class=\"selected\"");
                out.print(" target=\"" + Utils.NVL(menu.GetTarget(),"mainFrame") + "\"");
                out.print(" onclick=\"selected(this)\"");
                out.print(">");
                out.print(menu.GetName());
                out.print("</a>");
                out.println("</li>");
            }
        }
   }
%>
</ul>
</div>
</body>
</html>
<script type="text/javascript">
    var LastLeftID = "";

    function menuFix() {
        var obj = document.getElementById("Nav").getElementsByTagName("li");

        for (var i=0; i<obj.length; i++) {
            obj[i].onmouseover=function() {
                this.className+=(this.className.length>0? " ": "") + "sfhover";
            }
            obj[i].onMouseDown=function() {
                this.className+=(this.className.length>0? " ": "") + "sfhover";
            }
            obj[i].onMouseUp=function() {
                this.className+=(this.className.length>0? " ": "") + "sfhover";
            }
            obj[i].onmouseout=function() {
                this.className=this.className.replace(new RegExp("( ?|^)sfhover\\b"), "");
            }
        }
    }

    function DoMenu(emid)
    {
        var obj = document.getElementById(emid);
        obj.className = (obj.className.toLowerCase() == "expanded"?"collapsed":"expanded");
        if((LastLeftID!="")&&(emid!=LastLeftID))
        {
            document.getElementById(LastLeftID).className = "collapsed";
        }
        LastLeftID = emid;
    }

    function GetMenuID()
    {

        var MenuID="";
        var _paramStr = new String(window.location.href);

        var _sharpPos = _paramStr.indexOf("#");

        if (_sharpPos >= 0 && _sharpPos < _paramStr.length - 1)
        {
            _paramStr = _paramStr.substring(_sharpPos + 1, _paramStr.length);
        }
        else
        {
            _paramStr = "";
        }

        if (_paramStr.length > 0)
        {
            var _paramArr = _paramStr.split("&");
            if (_paramArr.length>0)
            {
                var _paramKeyVal = _paramArr[0].split("=");
                if (_paramKeyVal.length>0)
                {
                    MenuID = _paramKeyVal[1];
                }
            }
        }

        if(MenuID!="")
        {
            DoMenu(MenuID);
        }
    }

    GetMenuID();
    menuFix();
</script>