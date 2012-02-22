<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.ResourceBundle" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_uploadresource",user.GetLocale(), nps.core.Config.RES_CLASSLOADER);

    String siteid = request.getParameter("siteid");
    if(siteid!=null) siteid = siteid.trim();

    String func = request.getParameter("func");
    if(func!=null) func = func.trim();
    if(func==null || func.length()==0) func = "AddResource";
%>

<html>
<head>
    <title><%=bundle.getString("RES_HTMLTITLE")%></title>
    <script type="text/javascript" src="/jscript/str.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>

    <script language="Javascript">
      function fill_check()
      {
        if (document.inputFrm.siteid.value == ""){
          alert("<%=bundle.getString("RES_ALERT_NO_SITE")%>");
          document.inputFrm.siteid.focus();
          return false;
        }

        var oFile = document.getElementById('f');
        if(oFile.value==""){
            alert("<%=bundle.getString("RES_ALERT_NO_FILE")%>");
            document.inputFrm.f.focus();
            return false;
        }
        return true;
      }

      function uploadResource()
      {
         if(!fill_check()) return;
         document.inputFrm.upload.value=1;
         document.inputFrm.submit();
      }
    </script>
</head>

<body leftmargin=20 topmargin=0>
<table id="pbar" border="0" class="positionbar" cellpadding="0" cellspacing="0">
  <tr>
    <td width="180">&nbsp;
      <input type="button" class="button" name="save" value="<%=bundle.getString("RES_BUTTON_SAVE")%>" onClick="uploadResource()" >
      <input type="button" class="button" name="close" value="<%=bundle.getString("RES_BUTTON_CLOSE")%>" onclick="javascript:window.close();">
    </td>
  </tr>
</table>

<table width="100%" cellpadding="0" border="1" cellspacing="0">
    <form name="inputFrm" method="post" action="processresource.jsp" encType="multipart/form-data">
        <input type="hidden" name="upload" value="0">
        <input type="hidden" id="content" name="content" value="">
        <input type="hidden" name="siteid" value="<%=siteid%>">
        <input type="hidden" name="func" value="<%=func%>">
        <input type="hidden" name="type" value="-1">
        <input type="hidden" name="scope" value="1">
        <input type="hidden" name="tag" value="">
    <tr>
        <td width="80" align=center><%=bundle.getString("RES_TITLE")%></td>
        <td colspan="3">
          <input type="text" name="title" style="width:100%" value="">
        </td>
    </tr>
    <tr>
      <td width="80" align=center><font color=red><%=bundle.getString("RES_FILE")%></font></td>
      <td>
          <input type="file" id="f" name="f" style="width:300px">
      </td>
    </tr>
    <tr>
      <td width="80" align="center"><%=bundle.getString("RES_IMAGE_SCALE")%></td>
      <td>
            &nbsp;<%=bundle.getString("RES_IMAGE_WIDTH")%>
            <input type="text" name="img_width" style="width:50px">
            <%=bundle.getString("RES_IMAGE_HEIGHT")%>
            <input type="text" name="image_height" style="width:50px">
            <%=bundle.getString("RES_IMAGE_SCLAE_HINT")%>
      </td>
    </tr>
    </form>
</table>
</body>
</html>