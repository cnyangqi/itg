<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@page import="java.io.File"%>
<%@page import="com.nfwl.itg.common.ITG_UNITINFO"%>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="nps.core.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.nfwl.itg.product.*" %>

<%@ include file = "/include/header.jsp" %>

<%

    request.setCharacterEncoding("UTF-8");

    String prd_id=request.getParameter("prd_id");//如果为null，将在保存时使用序列生成ID号
    if(prd_id!=null) prd_id=prd_id.trim();
    

    String what = request.getParameter("what");
    if(what!=null) what = what.trim();
    
    String creator = user.GetName()+"("+user.GetDeptName()+ "/" +user.GetUnitName()+")";    
    String create_date = nps.util.Utils.FormateDate(new java.util.Date(),"yyyy-MM-dd HH:mm:ss");
    
    boolean  bNew=(prd_id==null || prd_id.length()==0);
    String create_user = user.GetName();
    String create_userid = user.GetUID();
    
    ITG_PRODUCT product = null;
    Vector vipimage = null;
    Vector vUnit = null;
    Vector vBrand = null;
    Connection con = null;
    ITG_PRODUCTIMAGE tempImage = null;
   //ITG_PRODUCTSORT productsort = null;
    try
    {
      con = nps.core.Database.GetDatabase("nfwl").GetConnection();
      
      if("deleteImage".equals(what)){
        //删除图片 deleteImageID
        String deleteImageID = request.getParameter("deleteImageID");
        if(deleteImageID!=null) deleteImageID = deleteImageID.trim();
        tempImage = ITG_PRODUCTIMAGE.get(con,deleteImageID);
        if(tempImage!=null){
          try{
             new File(request.getRealPath("/")+tempImage.getFilepath()+tempImage.getId()+tempImage.getExt()).delete();
             ITG_PRODUCTIMAGE.delete(con,deleteImageID);
             
          }catch(Exception e){
            e.printStackTrace();
          }finally{
            
          }
        }
      }
      
      vUnit = ITG_UNITINFO.getAll(con);
      vBrand = ITG_BRANDINFO.getAll(con); 
    if(!bNew)  //需要从数据库中加载信息
    {
        
            product = ITG_PRODUCT.get(con,prd_id);
            if(product == null) throw new Exception("没有prd_id为"+prd_id+"的产品");
            vipimage = ITG_PRODUCTIMAGE.getByPrdid(con,prd_id);
            //productsort = ITG_PRODUCTSORT.get(con,product.getPsid());
            
            create_date = nps.util.Utils.FormateDate(product.getTime(),"yyyy-MM-dd");
            create_user = user.GetUser(product.getRegisterid()).GetName();
            create_userid = product.getRegisterid();
            
    }  //if(!bNew)
      
      
      
%>

<html>
<head>
    <title><%=bNew?"新建产品":product.getName()%></title>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <script type="text/javascript" src="/jscript/ajax_common.js"></script>
    <script type="text/javascript" src="/nfwl/FCKeditor/fckeditor.js"></script>   
    <script type="text/javascript" src="/nfwl/js/inputcheck.js"></script>
    <script type="text/javascript" src="/nfwl/js/xtree.js"></script>
    <script type="text/javascript" src="/nfwl/js/treeselect.js"></script>
    <link type="text/css" rel="stylesheet" href="/nfwl/css/style.css">
    <script language="Javascript">
    function endsWith(str, suffix){
      return str.indexOf(suffix, str.length - suffix.length) !== -1;
    }
    

      function setValue(productclasscontrol,productclass_name,productclassidcontrol,productclassid){
        
        document.inputFrm.prd_psname.value=productclass_name;      
        document.inputFrm.prd_psid.value=productclassid;    
      }
      function selectProductClass()
      {
        
          page='/nfwl/product/selectPorductClass.jsp?productclasscontrol=prd_psname&productclassidcontrol=prd_psid' ;
          bWin = window.open(page,'browseWin','resizable=yes,scrollbars=yes,status=yes,width=500,height=500,screenX=300,screenY=400');
          bWin.focus();
      }
      
      
      function fill_check(){

        if(!CheckIsNull('document.inputFrm','prd_name')){
          alert("请输入名称");
          return false;
        }
        
        if(!CheckIsEnCode('document.inputFrm','prd_code')){
          alert("编号请输入数字或字母");
          return false;
        }
        if(!CheckIsNull('document.inputFrm','prd_psname')){
          alert("请选择类别");
          return false;
        }//prd_localprice  prd_marketprice
        
        if(!CheckIsNum('document.inputFrm','prd_localprice')){
          alert("请正确输入想购价");
          return false;
        }
        
        if(!CheckIsNum('document.inputFrm','prd_marketprice')){
          alert("请正确输入市场价");
          return false;
        }
        if(!CheckIsNum('document.inputFrm','prd_shipfee')){
          alert("请正确输入运费");
          return false;
        }
        if(!CheckIsNum('document.inputFrm','prd_point')){
          alert("请正确输入积分");
          return false;
        }
        var oEditor = FCKeditorAPI.GetInstance('DataFCKeditor') ;
        

        document.inputFrm.prd_content.value = oEditor.GetXHTML(true);
       return true;
      }     
      function saveProduct(){
         if(!fill_check()) return;      
         document.inputFrm.act.value=0;
         document.inputFrm.action='productSave.jsp';
         document.inputFrm.target="_self";
         //alert(document.inputFrm.action);
         document.inputFrm.submit();
      }
      

      function previewProduct(){
          alert("预览页面");
      }
    

      function publishProduct()
      {
          if(!fill_check()) return;
          
          
          if(!fill_check()) return;      

          if(document.inputFrm.prd_id.value==''||document.inputFrm.prd_id.value.trim()==''){
            //alert("没有保存，先保存！");
            //if(!fill_check()) return;      
            document.inputFrm.act.value=0;
            document.inputFrm.what.value='publishProduct';
            document.inputFrm.action='productSave.jsp';
            document.inputFrm.target="_self";
            //alert(document.inputFrm.action);
            document.inputFrm.submit();
          }else{
            document.inputFrm.act.value=3;
            document.inputFrm.action='productPublish.jsp';
            document.inputFrm.target="_self";
            document.inputFrm.submit();
          }
      }

      function republishProduct()
      {
        alert("修改重发布");if(true) return ;
          if(!fill_check()) return;
          document.inputFrm.act.value=5;
          document.inputFrm.action='productSave.jsp';
          document.inputFrm.target="_self";
          document.inputFrm.submit();
      }

      function cancelProduct()
      {alert("撤销");if(true) return ;
          document.inputFrm.act.value=6;
          document.inputFrm.action='productSave.jsp';
          document.inputFrm.target="_self";
          document.inputFrm.submit();
      }

      function uploadimage()
      {
        if(!fill_check()) return;      

          if(document.inputFrm.prd_id.value==''||document.inputFrm.prd_id.value.trim()==''){
            //alert("没有保存，先保存！");
            //if(!fill_check()) return;      
            document.inputFrm.act.value=0;
            document.inputFrm.what.value='uploadimage';
            document.inputFrm.action='productSave.jsp';
            document.inputFrm.target="_self";
            //alert(document.inputFrm.action);
            document.inputFrm.submit();
          }else{
            document.inputFrm.what.value='';
            document.resFrm.multiple.value = "0";
            document.resFrm.func.value = "SetImage";
            document.resFrm.action="uploadresource.jsp";
            document.resFrm.submit();
          }
      }
      function deleteImage(imageid){//
        document.inputFrm.deleteImageID.value=imageid;
        document.inputFrm.what.value='deleteImage';
        document.inputFrm.action='productInfo.jsp';
        document.inputFrm.target="_self";
        //alert(document.inputFrm.action);
        document.inputFrm.submit();
        
      }
      function createFCKEditor()
      {
            var oFCKeditor = new FCKeditor( 'DataFCKeditor' ) ;
            oFCKeditor.BasePath = "/nfwl/FCKeditor/";
            oFCKeditor.Width = '98%' ;
            oFCKeditor.Height = '650' ;
            oFCKeditor.ToolbarSet = "Image";
          
            oFCKeditor.ReplaceTextarea() ;
      }
      function init(){
        document.inputFrm.prd_brandname.value=document.inputFrm.prd_brandid.options[document.inputFrm.prd_brandid.selectedIndex].text;
        document.inputFrm.prd_unitname.value=document.inputFrm.prd_unitid.options[document.inputFrm.prd_unitid.selectedIndex].text;
        createFCKEditor();
        //publishProduct
        <%if("uploadimage".equals(what)){
          out.println("uploadimage();");
        }%>
        
        <%if("publishProduct".equals(what)){
          out.println("publishProduct();");
        }%>
        
      }
    </script>    
</head>

<body leftmargin=20 topmargin=0 onload="init();">   

<table width="100%" cellpadding="0" border="1" cellspacing="0">
    <form name="inputFrm" method="post" action="productSave.jsp">
    <input type="hidden" name="prd_id"  value="<%=Utils.Null2Empty(prd_id)%>">
    <input type="hidden" name="act" value="0">
    <input type="hidden" name="what" value="">
    <input type="hidden" name="deleteImageID" value="">
    <input type="hidden" id="prd_content" name="prd_content" value="">

    <tr>
    <td colspan="4">&nbsp;
      
      <input type="button" class="button" name="btn_save" value="保存" onClick="saveProduct()" >
      <input type="button" class="button" name="btn_publish" value="发布" onClick="publishProduct()" >
      <input type="button" class="button" name="btn_republish" value="修改重发布" onClick="republishProduct()" >
      <input type="button" class="button" name="btn_cancel" value="撤销" onClick="cancelProduct()" >    
      <input type="button" class="button" name="btn_preview" value="预览" onClick="previewProduct()" >

    </td>
    <td align="right">
       
        &nbsp;&nbsp;
    </td>
  </tr>

    <tr>
        <td width="60" align=center><font color=red>商品名称</font></td>
        <td colspan="3">
          <input type="text" name="prd_name" style="width:100%" value= "<%= (product==null || product.getName()==null)?"":Utils.TransferToHtmlEntity( product.getName()) %>">
        </td>
    </tr>
    <tr>
    <td width="60" align=center>编号</td>
    <td  width=35%>
    <input type="text" name="prd_code" style="width:100%" value= "<%= (product==null || product.getCode()==null)?"":Utils.TransferToHtmlEntity( product.getCode()) %>">
      </td>
      <td width="60" align=center>类别</td>
      <td>
       <input type="hidden" name="prd_psid"   value="<%= (product==null || product.getPsid()==null)?"":Utils.TransferToHtmlEntity( product.getPsid()) %>">
       <input type="text"  readonly  name="prd_psname" value="<%= (product==null || product.getPsname()==null)?"":Utils.TransferToHtmlEntity( product.getPsname()) %>"  style="width:100%"  onclick='javascript:selectProductClass();'>
    </td>
    </tr>
    
    <tr>
    <td width="60" align=center>新鲜程度</td>
    <td  width=35%>
      <select name="prd_newlevel" >
      <% for(int i=0;i<10;i++){ %>
        <option value="<%=i %>" <%=(product!=null&&product.getNewlevel()!=null&&product.getNewlevel().intValue()==i)?"selected":"" %> ><%=i %></option>
        <%} %>
      </select>
    </td>
    <td width="60" align=center>产地</td>
    <td  width=35%>
    <%
    String originprovinceid = "";
    String originprovincename = "";
    String origincountryid = "";
    String origincountryname = "";
    
    if(product!=null){
      originprovinceid = product.getOriginprovinceid();
      originprovincename = product.getOriginprovincename();
    }
    %>
     <script language="JavaScript" >
     <%=com.nfwl.itg.common.ITG_ZONEINFO.getJSString(con,"cjgTree","prd_originprovinceid",originprovincename,originprovinceid,"EXCEPT_ROOT_ELEMENT") %>     
        </script> 
    </td>
    </tr>
    
     <tr>
    <td width="60" align=center>市场价</td>
    <td>
     <input type="text" name="prd_marketprice" style="width:100%" value= "<%= (product==null || product.getMarketprice()==null)?"":String.valueOf( product.getMarketprice()) %>">
    </td>
    <td width="60" align=center>想购价</td>
    <td>
    <input type="text" name="prd_localprice" style="width:100%" value= "<%= (product==null || product.getLocalprice()==null)?"":String.valueOf( product.getLocalprice()) %>">
    </td>
    </tr>
    
    
    <tr>
    <td width="60" align=center>积分</td>
    <td  width=35%>
    <input type="text" name="prd_point" style="width:100%" value= "<%= (product==null || product.getPoint()==null)?"":String.valueOf( product.getPoint()) %>">
    
    </td>
    
    <td width="60" align=center>规格</td>
    <td  width=35%><input type="text" name="prd_spec" style="width:100%" value= "<%= (product==null || product.getSpec()==null)?"":Utils.TransferToHtmlEntity( product.getSpec()) %>">
    </td>
    </tr>
    
    
    <tr>
    <td width="60" align=center>品牌</td>
    <td  width=35%>
    
    <select name="prd_brandid" onchange="javascript:document.inputFrm.prd_brandname.value=document.inputFrm.prd_brandid.options[document.inputFrm.prd_brandid.selectedIndex].text;">
    
    <option value=""  ></option>
    <% ITG_BRANDINFO tempBrand = null;
    for(int i=0;vBrand!=null&&i<vBrand.size();i++){
      tempBrand = (ITG_BRANDINFO)vBrand.get(i);
      if(tempBrand!=null){
        
    %>
     <option value="<%=tempBrand.getId() %>" <%=(product!=null&&product.getUnitid()!=null&&product.getBrandid().equals(tempBrand.getId()))?"selected":"" %> ><%=tempBrand.getName() %></option>
    <%}} %>
    </select>
    
    <input type="hidden"   name="prd_brandname" value="<%= (product==null || product.getBrandname()==null)?"":Utils.TransferToHtmlEntity( product.getBrandname()) %>"  style="width:100%"  >
    
    </td>
    
    <td width="60" align=center>单位</td>
    <td  width=35%>
    
    
    
    <select name="prd_unitid" onchange="javascript:document.inputFrm.prd_unitname.value=document.inputFrm.prd_unitid.options[document.inputFrm.prd_unitid.selectedIndex].text;">
    
    <option value=""  ></option>
    <% ITG_UNITINFO tempUnit = null;
    for(int i=0;vUnit!=null&&i<vUnit.size();i++){
      tempUnit = (ITG_UNITINFO)vUnit.get(i);
      if(tempUnit!=null){
        
    %>
     <option value="<%=tempUnit.getId() %>" <%=(product!=null&&product.getUnitid()!=null&&product.getUnitid().equals(tempUnit.getId()))?"selected":"" %> ><%=tempUnit.getName() %></option>
    <%}} %>
    </select>
    
    <input type="hidden"   name="prd_unitname" value="<%= (product==null || product.getUnitname()==null)?"":Utils.TransferToHtmlEntity( product.getUnitname()) %>"  style="width:100%"  >
     
    </td>
    </tr>
    
     <tr>
    <td width="60" align=center>运费</td>
    <td  width=35%>
    <input type="text" name="prd_shipfee" style="width:100%" value= "<%= (product==null || product.getShipfee()==null)?"":String.valueOf( product.getShipfee()) %>">
    
    </td>
    
    <td width="60" align=center>&nbsp;</td>
    <td  width=35%>&nbsp;</td>
    </tr>
     <tr height="30">
      <td align="center">上传图片</td>
      <td colspan="">
          <input type="button" class="button" value="上传图片" onClick="javascript:uploadimage()" >
      </td>
      <td colspan="2" >
      
       <%
       //vipimage = ITG_PRODUCTIMAGE.getByPrdid(con,prd_id);
       
    for(int i=0;vipimage!=null&&i<vipimage.size();i++){
      tempImage = (ITG_PRODUCTIMAGE)vipimage.get(i);
      if(tempImage!=null){
    %>
    <a href="javascript:deleteImage('<%=tempImage.getId() %>')"  >删除</a>&nbsp;
    <a href="/<%=tempImage.getFilepath()+tempImage.getId()+tempImage.getExt() %>" target="_blank" ><%=tempImage.getFilename() %></a><br/>
    <%}} %>
      </td>
    </tr>
     <tr>
        <td width="60" align=center><font color=red>详细介绍</font></td>
        <td colspan="3">
        <div id="FCKeditor">
            <textarea id="DataFCKeditor" cols="80" rows="20"><%= (product==null || product.getContent()==null)?"":Utils.TransferToHtmlEntity( product.getContent()) %></textarea>
    </div>
        </td>
    </tr>
    
     <tr>
        <td width="60" align=center><font color=red>详细参数</font></td>
        <td colspan="3">
        <div id="FCKeditor_parameter">
            <textarea id="DataFCKeditor_parameter" name="prd_parameter" cols="120" rows="10"><%= (product==null || product.getParameter()==null)?"":Utils.TransferToHtmlEntity( product.getParameter()) %></textarea>
        </div>
        </td>
    </tr>
    <tr>
    <td width="60"  align=center>登记人</td>
    <td >
            <input type="hidden" name="prd_registerid"   maxlength="100" style="width:200" value="<%=create_userid %>">
            <%=Utils.Null2Empty(create_user)%>
      </td>
    </tr>
     <tr>
        <td width="60" align=center>登记时间</td>
    <td >
            <%=Utils.Null2Empty(create_date)%>
      </td>
    </tr>
    
</form>
</table>


<form name="resFrm" action="selectresource.jsp" target="_blank">
    <input type="hidden" name="multiple" value="1">
    <input type="hidden" name="func" value="">    
    <input type="hidden" name="prd_id" value="<%=prd_id %>">    
    <input type="hidden" name="type" value="-1">
</form>
</body>
</html>

<%
    }
    catch(Exception e)
    {

        java.io.CharArrayWriter cw = new java.io.CharArrayWriter();
        java.io.PrintWriter pw = new java.io.PrintWriter(cw,true);
        e.printStackTrace(pw);
        out.println(cw.toString());
        
        return;
    }finally{
      if(con!=null) try{con.close();}catch(Exception e){}
    }
%>