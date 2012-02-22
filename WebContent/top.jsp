<%@ page contentType="text/html; charset=UTF-8" language="java" errorPage="/error.jsp"%>
<%@ page import="java.sql.*" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.util.*" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="nps.util.tree.Node" %>

<%@ include file = "/include/header.jsp" %>

<%
    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_top",user.GetLocale(), nps.core.Config.RES_CLASSLOADER);

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String sql = null;
    String where = "";

    int i = 0;
    try
    {
        conn = Database.GetDatabase("nps").GetConnection();
%>        
<html>
<head>
  <title>NPS</title>
    <LINK href = "/css/top.css" rel = stylesheet type="text/css">
	<base target="mainFrame">

    <script language="javascript">
        var marqueeContent=new Array();
<%
        sql = "Select a.id,a.title,a.publishdate From bulletin a, users b";
        where = " Where a.creator=b.id and sysdate-a.publishdate<=a.validdays";
        if(!user.IsSysAdmin())
        {
            where += "  and (a.visibility=0 \n" +
                    " Or (a.visibility=1 And Exists (Select * From dept c Where b.dept=c.Id And c.unit=?))\n" +
                    " Or (a.visibility=2 And b.dept=?))";
        }

        pstmt = conn.prepareStatement(sql+where+" order by publishdate desc");
        if(!user.IsSysAdmin())
        {
            pstmt.setString(1,user.GetUnitId());
            pstmt.setString(2,user.GetDeptId());
        }

        rs = pstmt.executeQuery();
        while(rs.next())
        {
            out.print("marqueeContent[" + i + "]=");
            out.print("\"");
            out.print("<a href='/bulletin/view.jsp?id=" + rs.getString("id") + "' target='_blank'>" + rs.getString("title") + "</a>");
            out.print("(" + Utils.FormateDate(rs.getTimestamp("publishdate"),"yyyy-MM-dd HH:mm:ss") + ")<br>");
            out.println("\";");                                                                                          
            i++;
        }

        if(i==0)
        {
            out.print("marqueeContent[0] = \"&nbsp;\";");
        }

        if(rs!=null) try{rs.close();}catch(Exception e){}
        if(pstmt!=null) try{pstmt.close();}catch(Exception e){}
        rs = null;
        pstmt = null;
%>
        var marqueeInterval=new Array();
        var marqueeId=0;
        var marqueeDelay=2500;
        var marqueeHeight=16;

        function initMarquee()
        {
            if(marqueeContent.length==0) return;

            var str=marqueeContent[0];
            if(marqueeContent.length==1)
            {
                document.write('<div id=marqueeBox style="overflow:hidden;height:'+marqueeHeight+'px">'+str+'</div>');
            }
            else
            {
                document.write('<div id=marqueeBox style="overflow:hidden;height:'+marqueeHeight+'px" onmouseover="clearInterval(marqueeInterval[0])" onmouseout="marqueeInterval[0]=setInterval(\'startMarquee()\',marqueeDelay)"><div>'+str+'</div></div>');
                marqueeId++;
                marqueeInterval[0]=setInterval("startMarquee()",marqueeDelay);
            }
        }
        function startMarquee()
        {
            if(marqueeContent.length==0) return;

            var str=marqueeContent[marqueeId];
            marqueeId++;
            if(marqueeId>=marqueeContent.length) marqueeId=0;
            if(marqueeBox.childNodes.length==1)
            {
                var nextLine=document.createElement('DIV');
                nextLine.innerHTML=str;
                marqueeBox.appendChild(nextLine);
            }
            else
            {
                marqueeBox.childNodes[0].innerHTML=str;
                marqueeBox.appendChild(marqueeBox.childNodes[0]);
                marqueeBox.scrollTop=0;
            }
            clearInterval(marqueeInterval[1]);
            marqueeInterval[1]=setInterval("scrollMarquee()",20);
        }
        function scrollMarquee()
        {
            marqueeBox.scrollTop++;
            if(marqueeBox.scrollTop%marqueeHeight==(marqueeHeight-1))
            {
                clearInterval(marqueeInterval[1]);
            }
        }

        function changeMenu(obj)
        {
            var menu = document.getElementById("modernbricksmenu2");
            var lis = menu.getElementsByTagName("li");
            for(var i=0;i<lis.length;i++)
            {
                lis[i].id = "";
            }
            obj.id = "current";
        }
    </script>    
</head>
<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<table width="100%" border="0" cellspacing="0" cellpadding="0" style="height:33px">
  <tr>
    <td width="200" style="padding-left:10px;">
        <a href="<%=Version.URI%>" target="_blank"><img src="/images/logo.gif" border="0"></a>
    </td>
    <td width="100" align="center" valign="middle">
       <div><%=bundle.getString("TOP_BULLETIN")%>(<%=i%>)</div>
    </td>
    <td align="left" valign="middle">
        <script>
            initMarquee();
        </script>
    </td>
    <td width="210" style="vertical-align:middle;textfloat:right;padding-right:10px">
        <%
            java.text.SimpleDateFormat format = new java.text.SimpleDateFormat("yyyy-MM-dd EEE",user.GetLocale());
            java.util.Date current_date = new java.util.Date();
            out.print(format.format(current_date));
       %>
        &nbsp;&nbsp;
        <a href="<%=Version.URI%>" target="_blank"><%=Version.APP_NAME%> <%=Version.VERSION%></a>
    </td>
  </tr>
</table>
<div id="modernbricksmenu2">
<ul>
    <%
        MenuTree menutree = MenuTree.GetInstance(conn);
        Iterator childs_iterator = menutree.GetChilds(null);

        if(childs_iterator==null)
        {
            //No menu items
            out.print("<li style=\"margin-left:1px\" id=\"current\">");
            out.print("<a href=\"/menu/menuadmin.jsp\" target=\"mainFrame\" title=\"Menu Config\">Menu Config</a>");
            out.print("</li>");
        }
        else
        {
            int index = 0;

            //确认默认项
            String def_menu = null;
            while(childs_iterator.hasNext())
            {
                Node node = (Node)childs_iterator.next();
                Menu menu = (Menu)node.GetValue();

                //如果没有设置任何默认项，以第一个为准
                if(def_menu==null)
                {
                    def_menu = menu.GetId();
                    if(menu.IsDefault()) break;
                }
                else if(menu.IsDefault())
                {
                    //如果设置多个默认项，以第一个为准
                    def_menu = menu.GetId();
                    break;
                }
            }

            //打印菜单
            childs_iterator = menutree.GetChilds(null);
            while(childs_iterator.hasNext())
            {
                Node node = (Node)childs_iterator.next();
                Menu menu = (Menu)node.GetValue();

                if(!menu.IsAccessbile(user)) continue;

                if(index==0)
                {
                    out.print("<li style='margin-left:1px' onclick='changeMenu(this)'");
                    if(menu.GetId().equals(def_menu)) out.print(" id='current'");
                    out.print(">");
                    out.print("<a href=\"" + Utils.NVL(menu.GetURL(),"/navigator.jsp?id="+menu.GetId()) + "\"");
                    out.print("  title=\"" + Utils.TransferToHtmlEntity(menu.GetName()) + "\"");
                    out.print("  target=\"" + Utils.NVL(menu.GetTarget(),"navFrame") + "\"");
                    out.print(">");
                    out.print(Utils.TransferToHtmlEntity(menu.GetName()));
                    out.print("</a>");
                    out.print("</li>");
                }
                else
                {
                    out.print("<li onclick='changeMenu(this)'");
                    if(menu.GetId().equals(def_menu)) out.print(" id='current'");
                    out.print(">");                    
                    out.print("<a href=\"" + Utils.NVL(menu.GetURL(),"/navigator.jsp?id="+menu.GetId()) + "\"");
                    out.print("  title=\"" + Utils.TransferToHtmlEntity(menu.GetName()) + "\"");
                    out.print("  target=\"" + Utils.NVL(menu.GetTarget(),"navFrame") + "\"");
                    out.print(">");
                    out.print(Utils.TransferToHtmlEntity(menu.GetName()));
                    out.print("</a>");
                    out.print("</li>");
                }

                index++;
            }
        }
    %>
</ul>
<form id="myform" action="/info/articleadmin.jsp" method="post" target="mainFrame">
  <input type="hidden" name="status" value="3">
  <input type="text" name="keyword" class="textinput" />
  <input class="submit" type="submit" value="Find" />
</form>
</div>
</body>
</html>
<%
    }
    finally
    {
        if(rs!=null) try{rs.close();}catch(Exception e){}
        if(pstmt!=null) try{pstmt.close();}catch(Exception e){}
        if(conn!=null) try{conn.close();}catch(Exception e){}
    }
%>