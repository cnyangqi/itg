<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    String siteid = request.getParameter("siteid");
    if(siteid!=null) siteid = siteid.trim();

    String func = request.getParameter("func");
    if(func!=null) func = func.trim();
    
    String prd_id = request.getParameter("prd_id");
    if(prd_id!=null) prd_id = prd_id.trim();
    if(func==null || func.length()==0) func = "AddResource";
%>

<html>
<head>
    <title>上传文件</title>
    <script type="text/javascript" src="/jscript/str.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>

    <script language="Javascript">
      function fill_check()
      {
        

        
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
      <input type="button" class="button" name="save" value="上传" onClick="uploadResource()" >
      <input type="button" class="button" name="close" value="关闭" onclick="javascript:window.close();">
    </td>
  </tr>
</table>

<table width="100%" cellpadding="0" border="1" cellspacing="0">
    <form name="inputFrm" method="post" action="processresource.jsp" encType="multipart/form-data">
        <input type="hidden" name="upload" value="0">
        <input type="hidden" id="content" name="content" value="">
        <input type="hidden" name="func" value="<%=func%>">
        <input type="hidden" name="type" value="-1">
        <input type="hidden" name="scope" value="1">
        <input type="hidden" name="tag" value="">
        <input type="hidden" name="prd_id" value="<%=prd_id%>">
    <tr>
        <td width="80" align=center>标题</td>
        <td colspan="3">
          <input type="text" name="title" style="width:100%" value="">
        </td>
    </tr>
    <tr>
        <td width="80" align=center>顺序</td>
        <td colspan="3">
          <input type="text" name="pi_pos" style="width:100%" value="">
        </td>
    </tr>
    <tr>
      <td width="80" align=center><font color=red>上传文件</font></td>
      <td>
          <input type="file" id="f" name="f" style="width:300px">
      </td>
    </tr>
    
    </form>
</table>
</body>
</html>