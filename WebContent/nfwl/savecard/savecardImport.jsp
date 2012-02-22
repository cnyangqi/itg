<%@ page contentType="text/html;charset=UTF-8" %>
<HTML>
<head>
<title>上传文件</title>
</head>
<BODY>
文件内容应为如下结构: <br/>
(十位数字的卡号+逗号+十位数字的密码+逗号+金额)
<br/>
3234565435,8764789536,100
<br/>
2234563435,8764289536,100
<br/>
2234564435,8674354546,100
<br/>
5234562435,8345546536,100
<FORM action="AccepteUploadFile.jsp" method="POST" ENCTYPE="multipart/form-data">
请选择要上传的文件:<br/>
<input type="file" size="50" name="importfile"> 
<INPUT type="submit" value="提交">
</FORM>
 </BODY>
</HTML>



