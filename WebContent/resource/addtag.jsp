<%@ page language="java" contentType="text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.ResourceBundle" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_addtag",user.GetLocale(), nps.core.Config.RES_CLASSLOADER);
%>

<html>
  <head>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>
    <title><%=bundle.getString("TAG_HTMLTITLE")%></title>
  </head>
  <BODY leftmargin="0" topmargin="0">
    <script language="javascript">
        function add()
        {
            var tags = document.frm_tag.tag.value;
            if(tags=='')
            {
                alert("<%=bundle.getString("TAG_ALERT_NO_TAGS")%>");
                return false;
            }
            var isMSIE= (navigator.appName == "Microsoft Internet Explorer");
            if (isMSIE)
            {
                var   rt = new Array(1);
                rt[0] = tags;
                window.returnValue= rt;
            }
            else
            {
                parent.opener.f_addtag(tags);
            }

            top.close();
        }
    </script>
    <table border="0" cellspacing="0" cellpadding="0" width="100%" style="padding-left:10px;padding-right:10px">
        <form name="frm_tag" method="post" action="addtag.jsp">
        <tr height="30"><td><font color="red"><%=bundle.getString("TAG_HINT_ADD")%></font></td></tr>
        <tr>
            <td>
                <textarea name="tag" rows="10" cols="10" style="width:100%"></textarea>
            </td>
        </tr>
        <tr height="30">
            <td align="center">
                <input type="button" class="button" name="btn_ok" value="<%=bundle.getString("TAG_BUTTON_OK")%>" onclick="add()">
                <input type="button" class="button" name="btn_cancel" value="<%=bundle.getString("TAG_BUTTON_CANCEL")%>" onclick="javascript:window.close()">
            </td>
        </tr>
        </form>    
    </table>
  </body>
</html>