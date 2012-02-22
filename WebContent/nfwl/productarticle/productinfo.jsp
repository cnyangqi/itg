<%@page import="tools.Pub"%>
<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="nps.core.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.nfwl.itg.product.*" %>
<%@ page import="com.nfwl.itg.common.*" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_articleinfo",user.GetLocale(), nps.core.Config.RES_CLASSLOADER);

    String id=request.getParameter("id");//如果为null，将在保存时使用序列生成ID号
    if(id!=null) id=id.trim();
    
    String site_id = request.getParameter("site_id");
    if(site_id!=null) site_id = site_id.trim();

    String creator = user.GetName()+"("+user.GetDeptName()+ "/" +user.GetUnitName()+")";    
    String create_date = nps.util.Utils.FormateDate(new java.util.Date(),"yyyy-MM-dd HH:mm:ss");
    
    boolean  bNew=(id==null || id.length()==0);

    NormalArticle art = null;
    NpsWrapper wrapper = null;

    Vector vUnit = null;
    Vector vBrand = null;

    wrapper = new NpsWrapper(user,site_id);
    if(!bNew)  //需要从数据库中加载信息
    {
      
        try
        {
            
            art = wrapper.GetArticle(id);
            if(art==null) throw new NpsException(ErrorHelper.SYS_NOARTICLE);
        }
        catch(Exception e)
        {
            art = null;
            if(wrapper!=null) wrapper.Clear();

            java.io.CharArrayWriter cw = new java.io.CharArrayWriter();
            java.io.PrintWriter pw = new java.io.PrintWriter(cw,true);
            e.printStackTrace(pw);
            out.println(cw.toString());
            
            return;
        }
    }  //if(!bNew)
   

    vUnit = ITG_UNITINFO.getAll(wrapper.GetContext().GetConnection());
    vBrand = ITG_BRANDINFO.getAll(wrapper.GetContext().GetConnection()); 
%>

<html>
<head>
    <title><%=bNew?"新产品":art.GetTitle()%></title>
    <script type="text/javascript" src="/FCKeditor/fckeditor.js"></script>  
    <script type="text/javascript" src="/jscript/global.js"></script>
    <script type="text/javascript" src="/jscript/calendar.js"></script>
    <script type="text/javascript" src="/jscript/ajax_common.js"></script> 
    <script type="text/javascript" src="/nfwl/js/inputcheck.js"></script>
    <script type="text/javascript" src="/nfwl/js/xtree.js"></script>
    <script type="text/javascript" src="/nfwl/js/treeselect.js"></script>
    <script type="text/javascript" src="/nfwl/js/productInfo.js"></script>
    <link type="text/css" rel="stylesheet" href="/nfwl/css/style.css">  
  
    <script language="Javascript">
    function createFCKEditor()
    {
          var oFCKeditor = new FCKeditor( 'DataFCKeditor' ) ;
          oFCKeditor.BasePath = "/FCKeditor/";
          oFCKeditor.Width = '98%' ;
          oFCKeditor.Height = '650' ;
          oFCKeditor.ToolbarSet = "Image";
          oFCKeditor.Config['ImageBrowserURL'] = '/info/selectresource.jsp?type=0&siteid=<%=Utils.Null2Empty(site_id)%>&id=<%=Utils.Null2Empty(id)%>';
          oFCKeditor.Config['LinkBrowserURL'] = '/info/selectresource.jsp?siteid=<%=Utils.Null2Empty(site_id)%>&id=<%=Utils.Null2Empty(id)%>';
          oFCKeditor.Config['FlashBrowserURL'] = '/info/selectresource.jsp?type=4&siteid=<%=Utils.Null2Empty(site_id)%>&id=<%=Utils.Null2Empty(id)%>';
          oFCKeditor.Config['MediaBrowserURL'] = '/info/selectresource.jsp?type=2&siteid=<%=Utils.Null2Empty(site_id)%>&id=<%=Utils.Null2Empty(id)%>';
        
          oFCKeditor.ReplaceTextarea() ;
    }
    function postArticle()
    {
        var rc = popupDialog("postremote.jsp?art_id=<%=Utils.Null2Empty(id)%>");
        return false;
    }

    function init(){
        createFCKEditor();
        <%if(art!=null&&art.GetTopic()!=null&&"礼包产品".equals(art.GetTopic().GetName())){
          %>
          f_showLBCP();
          <%
          Vector vsp = SUBPRODUCT.getByParentid(wrapper.GetContext().GetConnection(), art.GetId());
          SUBPRODUCT tempsubprd = null;
          
          for(int i=0;vsp!=null&&i<vsp.size();i++){
            tempsubprd = (SUBPRODUCT)vsp.get(i);
            if(tempsubprd!=null){
          %>
          addSubProduct("<%=tempsubprd.getPrdid() %>","<%=tempsubprd.getPrd_name() %>","<%=tempsubprd.getNum() %>","<%=tempsubprd.getUnit() %>");
        
        <%} }} %>
    }
    </script>    
</head>

<body leftmargin=20 topmargin=0 onload="javascript:init();">   
<table id="pbar" border="0" class="positionbar" cellpadding="0" cellspacing="0" style="display:none">
  <tr>
    <td>&nbsp;
<%
System.out.println("发布后不能修改");
  //发布后不能修改
  boolean bSavable = false;  //是否显示保存按钮
  boolean bSubmitable = false; //是否显示提交按钮
  boolean bCheckable = false; //是否显示审核按钮
  boolean bDownable = false; //是否显示上架按钮
  boolean bUpable = false; //是否显示上架按钮
  boolean bDeletable = false; //是否显示删除按钮
  boolean bPublishable  = false;  //是否显示发布按钮
  boolean bRepublishable = false;  //是否显示重发布按钮
  boolean bCancel  = false; //是否显示撤销按钮
  boolean bChangeable = false; //是否显示选择栏目及添加从栏目按钮
  boolean bPreview = false; //是否显示预览按钮

  if(bNew)
  {
     bSavable = true;
     bCheckable = false;
     bSubmitable = true;
     bDeletable = false;
     bPublishable = false;
     bRepublishable = false;
     bCancel = false;
     bChangeable = true;
     bPreview = false;
  }
  else
  {
     if(art!=null)
     {
         switch(art.GetState())
         {
             case 0:
                //草稿状态,只有自己能保存
                bSavable = user.GetUID().equals(art.GetCreatorID());
                bDeletable = user.GetUID().equals(art.GetCreatorID()); 
                bSubmitable = user.GetUID().equals(art.GetCreatorID());
                bCheckable = false;
                bRepublishable = false;
                bCancel = false;
                bDownable = false;
                bUpable = false;
                bChangeable = user.GetUID().equals(art.GetCreatorID());
                bPreview = true;
                break;
             case 1:
                //提交状态，只有版主或者站点管理员能保存
                //本单位管理员不能相互串位
                bSavable = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(site_id) || user.IsSysAdmin();

                //不能提交
                bSubmitable = false;

                //只有站点管理员、版主可以审核 
                bCheckable = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(site_id) || user.IsSysAdmin();

                //属主、站点管理员、版主可以删除文章
                bDeletable = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(site_id) || user.IsSysAdmin();

                bRepublishable = false;
                bCancel = false;

                bDownable = false;
                bUpable = false;
                bChangeable = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(site_id) || user.IsSysAdmin();
                bPreview = true; 
                
                break;
             case 2:
                //待发布，由于前后没有文章模板等导致需要重新发布
                 bSavable = false;
                 bSubmitable = false;
                 bCheckable = false;

                 bDownable = false;
                 bUpable = false;
                 bDeletable = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(site_id) || user.IsSysAdmin();
                 bPublishable = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(site_id) || user.IsSysAdmin();
                 bRepublishable = false;
                 bCancel = false;
                 bChangeable = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(site_id) || user.IsSysAdmin();
                 bPreview = true;
                 break;                 
             case 3:
                 //已发布状态
                 bSavable = false;
                 bSubmitable = false;
                 bCheckable = false;

                 bDownable = true;
                 bUpable = false;
                 bDeletable = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(site_id) || user.IsSysAdmin();
                 bRepublishable = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(site_id) || user.IsSysAdmin();
                 bCancel = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(site_id) || user.IsSysAdmin();
                 bChangeable = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(site_id) || user.IsSysAdmin();
                 bPreview = true;
                 break;
             case 8:
             case 9:
               //下架状态
               bSavable = false;
               bSubmitable = false;
               bCheckable = false;

               bDownable = false;
               bUpable = true;
               bDeletable = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(site_id) || user.IsSysAdmin();
               bRepublishable = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(site_id) || user.IsSysAdmin();
               bCancel = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(site_id) || user.IsSysAdmin();
               bChangeable = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(site_id) || user.IsSysAdmin();
               bPreview = true;
               break;                 
         }
     }

  }
    
  if(bSavable)
  {
%>        
      <input type="button" class="button" name="save" value="<%=bundle.getString("ARTICLE_BUTTON_SAVE")%>" onClick="saveArticle()" >
<%
  }

  if(bSubmitable)
  {
%>        
       <input type="button" class="button" name="submit" value="<%=bundle.getString("ARTICLE_BUTTON_SUBMIT")%>" onClick="submitArticle()" >
<%
  }

  if(bDeletable)
  {
%>
       <input type="button" class="button" name="submit" value="<%=bundle.getString("ARTICLE_BUTTON_DELETE")%>" onClick="deleteArticle()" >
<%
  }

  if(bCheckable) 
  {
%>        
       <input type="button" class="button" name="submit" value="<%=bundle.getString("ARTICLE_BUTTON_CHECK")%>" onClick="checkArticle()" >
<!--        <input type="button" class="button" name="submit" value="<%=bundle.getString("ARTICLE_BUTTON_TIMED_PUBLISH")%>" onClick="timedPublish()" >  -->
<%
  }

  if(bPublishable) 
  {
%>
       <input type="button" class="button" name="submit" value="<%=bundle.getString("ARTICLE_BUTTON_PUBLISH")%>" onClick="publishArticle()" >
<%
  }

  if(bRepublishable)
  {
%>
        <input type="button" class="button" name="submit" value="<%=bundle.getString("ARTICLE_BUTTON_REPUBLISH")%>" onClick="republishArticle()" >
<%
   }

  if(bCancel)
  {
%>
        <input type="button" class="button" name="submit" value="<%=bundle.getString("ARTICLE_BUTTON_CANCEL")%>" onClick="cancelArticle()" >  
<%
  }
  
  if(bUpable)
  {
%>
        <input type="button" class="button" name="submit" value="上架" onClick="upArticle()" >    
<%
  }
  if(bDownable)
  {
%>
        <input type="button" class="button" name="submit" value="下架" onClick="downArticle()" >    
<%
  }  

  if(!bNew)
  {
%>
  <!--    <input type="button" class="button" name="submit" value="<%=bundle.getString("ARTICLE_BUTTON_POSTREMOTE")%>" onClick="postArticle()" >     -->       
<%
  }
  
  if(bPreview)
  {
%>
    <input type="button" class="button" name="preview" value="<%=bundle.getString("ARTICLE_BUTTON_PREVIEW")%>" onClick="previewArticle()" >
<%
  }
%>
    </td>
    <td align="right">
        <%
            if(!bNew)
            {
        %>
        URL: <span style="width:320px;overflow:hidden;text-overflow:ellipsis;word-break:keep-all"><a href="<%=art.GetURL()%>" target='_blank' title="<%=art.GetURL()%>"><%=art.GetURL()%></a></span>            
        <%
            }
        %>
        &nbsp;&nbsp;
    </td>
  </tr>
</table>
<form name="inputFrm" method="post" action="productsave.jsp">

  <table width="100%" cellpadding="0" border="1" cellspacing="0">
    <input type="hidden" name="id"  value="<%=Utils.Null2Empty(id)%>">
    <input type="hidden" name="del_att_id" value="">
    <input type="hidden" name="act" value="0">
    <input type="hidden" id="isBusiness" value="0">
    <input type="hidden" id="content" name="content" value="">

    <tr><td colspan="4">
    <div id="div_time" style="display:none">
        <table align="center" width="400" cellpadding="0" border="1" cellspacing="0">
            <tr height="30">
                <td align="center"><input type="text" name="job_year" maxlength="4" style="width:60px"></td>
                <td align="center"><input type="text" name="job_month" maxlength="2" style="width:30px"></td>
                <td align="center"><input type="text" name="job_day" maxlength="2" style="width:30px"></td>
                <td align="center"><input type="text" name="job_hour" maxlength="2" style="width:30px"></td>
                <td align="center"><input type="text" name="job_minute" maxlength="2" style="width:30px"></td>
                <td align="center"><input type="text" name="job_second" maxlength="2" style="width:30px"></td>
            </tr>
            <tr height="30">
                <td align="center"><font color="red"><b><%=bundle.getString("ARTICLE_JOB_YEAR")%></b></font></td>
                <td align="center"><font color="red"><b><%=bundle.getString("ARTICLE_JOB_MONTH")%></b></font></td>
                <td align="center"><font color="red"><b><%=bundle.getString("ARTICLE_JOB_DAY")%></b></font></td>
                <td align="center"><font color="red"><b><%=bundle.getString("ARTICLE_JOB_HOUR")%></b></font></td>
                <td align="center"><font color="red"><b><%=bundle.getString("ARTICLE_JOB_MINUTE")%></b></font></td>
                <td align="center"><font color="red"><b><%=bundle.getString("ARTICLE_JOB_SECOND")%></b></font></td>
            </tr>
            <tr height="30">
                <td colspan="6" align="center">
                    <input type="button" class="button" name="okbtn" value="<%=bundle.getString("ARTICLE_BUTTON_TIMED_OK")%>" onclick="submitTimedPublish()">
                    <input type="button" class="button" name="cancelbtn" value="<%=bundle.getString("ARTICLE_BUTTON_TIMED_CANCEL")%>" onclick="cancelTimedPublish()">
                </td>
            </tr>
        </table>
    </div>
    </td></tr>
        <tr>
        <td width="15%" align=center><font color=black>商品名称</font></td>
        <td colspan="3">
          <input type="text" name="title" style="width:100%" value= "<%= (art==null || art.GetTitle()==null)?"":Utils.TransferToHtmlEntity(art.GetTitle()) %>">
        </td>
    </tr>
    <tr>
    <td width="15%" align=center>商品简称</td>
    <td  colspan="3">
      <input type="text" name="subtitle"  style="width:100%" value="<%= (art==null || art.GetSubtitle()==null)?"":Utils.TransferToHtmlEntity(art.GetSubtitle()) %>">
      </td>
     
    </tr>
      
      <tr>
        
        <td width="15%" align=center><font color=black>产品类别</font></td>
       <td >
            <input type="text" name="topic" value="<%= art==null?"":art.GetTopic().GetName() %>" readonly>
  <%
     if(bChangeable)
     {
  %>
            <input type="button" value="<%=bundle.getString("ARTICLE_BUTTON_SELTOPIC")%>" class="button" name="btn_topic" onclick='javascript:selectTopics();'>
  <%
     }
  %>
  <!-- 
            <select id="template" name="template">
                <option value=""><%=bundle.getString("TEMPLATE_HINT")%></option>
            <%
                if(!bNew && art!=null)
                {
                    Template template = art.GetTopic().GetCascadedArticleTemplate();
                    if(template!=null)
                    {
                        for(int i=0;i<3;i++)
                        {
                            String template_name = template.GetTemplateName(i);
                            if(template_name==null) continue;
            %>
                <option value="<%=i%>" <% if(String.valueOf(i).equals(art.GetCurrentTemplateNo())) out.print("selected"); %> ><%=template_name%></option>
           <%
                       }
                   }
                }
           %>
            </select>
 -->
            <input type="hidden" name="site_id" value="<%= site_id==null?"":site_id %>">
            <input type="hidden" name="top_id" value="<%= art==null?"":art.GetTopic().GetId() %>">
        </td>
        
         <td width="15%" align=center>有效天数</td>
          <td  width=35%>
          <input type="text" name="validdays" value="<% if(art!=null && art.GetValiddays()!=0) out.print(art.GetValiddays()); %>" size="3">
          不填为长期有效
            </td>
      </tr>
      

    <tr height="30">
      <td width="15%" align=center>
          <%=bundle.getString("ARTICLE_IMAGE")%>
      </td>
      <td colspan="2">
          <input type="text" name="pic_url" maxlength="500"  style="width:350px" value="<%=bNew?"":Utils.Null2Empty(art.GetImageURL())%>">
          <input type="button" class="button" value="<%=bundle.getString("ARTICLE_IMAGE_UPLOAD")%>" onClick="javascript:uploadimage()" >
          <input type="button" class="button" value="<%=bundle.getString("ARTICLE_IMAGE_MEDIALIB")%>" onClick="javascript:attachimage()" >
      </td>
      <td >
                     是否是零库存：<input  type = "checkBox" name = "prd_jit" value = "1" <%= (art==null||art.getPrdJit()!=1)?"":"checked" %>> &nbsp;
      </td>
    </tr>
          <tr>
          <td width="15%" align=center>编号</td>
          <td  width=35%>
          <input type="text" name="prd_code" style="width:100%" value= "<%= (art==null || art.getPrdCode()==null)?"":Utils.TransferToHtmlEntity( art.getPrdCode()) %>">
            </td>
            
          <td width="15%" align=center>产品特性</td>
          <td   >
          <input  type = "checkBox" name = "prd_season" value = "1" <%= (art==null||art.getPrdSeason()!=1)?"":"checked" %>  > 时令  &nbsp;
          <input  type = "checkBox" name = "prd_import" value = "1" <%= (art==null||art.getPrdImport()!=1)?"":"checked" %>  > 进口  &nbsp;
          <input  type = "checkBox" name = "prd_reduce" value = "1" <%= (art==null||art.getPrdReduce()!=1)?"":"checked" %>  > 减肥  &nbsp;
          <input  type = "checkBox" name = "prd_beauty" value = "1" <%= (art==null||art.getPrdBeauty()!=1)?"":"checked" %>  > 美容  &nbsp;
          <input  type = "checkBox" name = "prd_nutrition" value = "1" <%= (art==null||art.getPrdNutrition()!=1)?"":"checked" %>> 健康  &nbsp;
          </td>
          </tr>
          <tr>
          <td width="15%" align=center>新鲜程度</td>
          <td  width=35%>
            <select name="prd_newlevel" >
            <% for(int i=0;i<6;i++){ %>
              <option value="<%=i %>" <%=(art!=null&&art.getPrdNewlevel()==i)?"selected":"" %> ><%=i %></option>
              <%} %>
            </select>
          </td>
          <td width="15%" align=center>产地</td>
          <td  width=35%>
          <%
          String originprovinceid = "";
          String originprovincename = "";
          String origincountryid = "";
          String origincountryname = "";
          
          if(art!=null){
            originprovinceid = art.getPrdOriginprovinceid();
            originprovincename = art.getPrdOriginprovincename();
          }
          %>
           <script language="JavaScript" >
           <%=com.nfwl.itg.common.ITG_ZONEINFO.getJSString(wrapper.GetContext().GetConnection(),"cjgTree","prd_originprovinceid",originprovincename,originprovinceid,"EXCEPT_ROOT_ELEMENT") %>     
              </script> 
          </td>
          </tr>
          
           <tr>
          <td width="15%" align=center>市场价</td>
          <td>
           <input type="text" name="prd_marketprice" style="width:100%" value= "<%= (art==null)?"":String.valueOf( art.getPrdMarketprice()) %>">
          </td>
          <td width="15%" align=center>想购价</td>
          <td>
          <input type="text" name="prd_localprice" style="width:100%" value= "<%= (art==null )?"":String.valueOf( art.getPrdLocalprice()) %>">
          </td>
          </tr>
          
          <tr>
          <td width="15%" align=center>活动价</td>
          <td>
           <input type="text" name="prd_saleprice" style="width:100%" value= "<%= (art==null)?"":String.valueOf( art.getPrdSaleprice()) %>">
          </td>
          <td width="15%" align=center>活动截至日期</td>
          <td>
          <div>
          <input type="text" name="prd_saleend" style="width:100%" onClick="getDateString(this,oCalendarChs)"  value= "<%= (art==null )?"":Pub.getString(art.getPrdSaleend(), "") %>">
          </div>
          </td>
          </tr>
          
          <tr>
          <td width="15%" align=center>积分</td>
          <td  width=35%>
          <input type="text" name="prd_point" style="width:100%" value= "<%= (art==null )?"":String.valueOf( art.getPrdPoint()) %>">
          
          </td>
          
          <td width="15%" align=center>规格</td>
          <td  width=35%><input type="text" name="prd_spec" style="width:100%" value= "<%= (art==null || art.getPrdSpec()==null)?"":Utils.TransferToHtmlEntity( art.getPrdSpec()) %>">
          </td>
          </tr>
          
          
          <tr>
          <td width="15%" align=center>品牌</td>
          <td  width=35%>
          
          <select name="prd_brandid" onchange="javascript:document.inputFrm.prd_brandname.value=document.inputFrm.prd_brandid.options[document.inputFrm.prd_brandid.selectedIndex].text;">
          
          <option value=""  ></option>
          <% ITG_BRANDINFO tempBrand = null;
          for(int i=0;vBrand!=null&&i<vBrand.size();i++){
            tempBrand = (ITG_BRANDINFO)vBrand.get(i);
            if(tempBrand!=null){
              
          %>
           <option value="<%=tempBrand.getId() %>" <%=(art!=null&&art.getPrdUnitid()!=null&&art.getPrdBrandid().equals(tempBrand.getId()))?"selected":"" %> ><%=tempBrand.getName() %></option>
          <%}} %>
          </select>
          
          <input type="hidden"   name="prd_brandname" value="<%= (art==null || art.getPrdBrandname()==null)?"":Utils.TransferToHtmlEntity( art.getPrdBrandname()) %>"  style="width:100%"  >
          
          </td>
          
          <td width="15%" align=center>单位</td>
          <td  width=35%>
          
          
          
          <select id="prd_unitid" name="prd_unitid" onchange="javascript:document.inputFrm.prd_unitname.value=document.inputFrm.prd_unitid.options[document.inputFrm.prd_unitid.selectedIndex].text;">
          
          <option value=""  ></option>
          <% ITG_UNITINFO tempUnit = null;
          for(int i=0;vUnit!=null&&i<vUnit.size();i++){
            tempUnit = (ITG_UNITINFO)vUnit.get(i);
            if(tempUnit!=null){
              
          %>
           <option value="<%=tempUnit.getId() %>" <%=(art!=null&&art.getPrdUnitid()!=null&&art.getPrdUnitid().equals(tempUnit.getId()))?"selected":"" %> ><%=tempUnit.getName() %></option>
          <%}} %>
          </select>
          
          <input type="hidden"   name="prd_unitname" value="<%= (art==null || art.getPrdUnitname()==null)?"":Utils.TransferToHtmlEntity( art.getPrdUnitname()) %>"  style="width:100%"  >
           
          </td>
          </tr>
          
           <tr>
          <td width="15%" align=center>运费</td>
          <td  width=35%>
          <input type="text" name="prd_shipfee" style="width:100%" value= "<%= (art==null )?"":String.valueOf( art.getPrdShipfee()) %>">
          
          </td>
          
          <td width="15%" align=center>&nbsp;</td>
          <td  width=35%>&nbsp;</td>
          </tr>
          </table>
          <div id='div_lbcp' style="display:none">
            <table id="tab_subproduct" width="100%" cellpadding="0" border="1" cellspacing="0">
              <tr>
                <td width="100%" align=left colspan="4">
                <input type="button" onclick="addSubProduct()" value="添加产品" >
                </td>
              </tr>
              <tr>
                <td width="25%" align=center >产品</td>
                <td width="25%" align=center >数量</td>
                <td width="25%" align=center >单位</td>
                <td width="25%" align=center >删除</td>
              </tr>
          
           </table>
          </div>
        <table width="100%" cellpadding="0" border="1" cellspacing="0">
          
          <tr>
          <td width="15%" align=center>详细参数</td>
          <td colspan="3" ><textarea name="prd_parameter" rows="3" cols="60" style="width:100%"><%=bNew?"":Utils.Null2Empty(art.getPrdParameter())%></textarea></td>
          </tr>
       
      <tr height=30>
        <td align=center><%=bundle.getString("ARTICLE_CREATOR")%></td>
        <td><%= bNew?creator:art.GetCreatorFN()%></td>
        <td align=center><%=bundle.getString("ARTICLE_CREATEDATE")%></td>
        <td>
            <%= bNew?create_date:art.GetCreateDate()%>
        </td>
      </tr>
<%
      if(art!=null)
      {
%>      
    <tr height=30>
        <td align=center><%=bundle.getString("ARTICLE_PUBLISHDATE")%></td>
        <td>&nbsp;
            <%
                if(art.GetState()==3)
                {
                    out.print(Utils.Null2Empty(art.GetApproverCN()));
                    out.print(" ");
                    out.print(art.GetPublishDate());
                }
            %>
        </td>
        <td align=center><%=bundle.getString("ARTICLE_SCORE")%></td>
        <td>
            <%
                if(art.GetState()>0 && (bCheckable || bPublishable || bRepublishable))
                {
            %>
            &nbsp;<input type="text" name="score" value= "<%=art.GetScore()%>">
            <%
                }
                else
                {
                    out.print(art.GetScore());
                }
            %>
        </td>
      </tr>      
<%
      }
%>
    <tr>
        <td colspan=4>
            <table width=100% height="100%" border="0" cellpadding="0" cellspacing="1">
              <TBODY>
                <%
                  //发布后不能修改
                  if(bChangeable)
                  {
                %>
                      <tr height=30>
                        <td align="left">
                            &nbsp;&nbsp;
                            <input type="button" class="button" value="<%=bundle.getString("ARTICLE_BUTTON_ATTACH_FILE")%>" onClick="javascript:uploadfiles()" >
                            <input type="button" class="button" value="<%=bundle.getString("ARTICLE_BUTTON_ATTACH_LIST")%>" onClick="javascript:attachlist()" >
                            <font color="red"><%=bundle.getString("ARTICLE_HINT_ATTACH")%></font>
                        </td>
                      </tr>
                <%
                  }
                %>
                  <tr><td id="table_fj">
                <%
                 if(!bNew)
                 {
                     java.util.List attaches = art.GetAttach(null);
                     if(attaches!=null)
                     {
                         int max_att_index = 1;
                         for(Object obj:attaches)
                         {
                             Attach att = (Attach) obj;

                             out.print("<span style='padding:5px 10px;'>");
                             out.print("&nbsp;<input type='text' name='att_idx_"+att.GetId()+"' value='"+att.GetIndex()+"' style='width:20px;text-align:center;'>");
                             out.print("<input type='hidden' name='att_id' value='"+att.GetId()+"'>");
                             out.print("&nbsp;<a href='");
                             //out.print(att.GetURL());
                             out.print("/resource/viewattach.jsp?id="+att.GetID());
                             out.print("' target='_blank'>");
                             out.print(att.GetName());
                             if(att.GetSuffix()!=null) out.print(att.GetSuffix());
                             out.print("</a>");
                             if(bDeletable)
                             {
                                 out.print("<a href=\"");
                                 out.print("javascript:FCKeditor_addImage('"+ att.GetURL()+"','"+att.GetTitle()+"');");
                                 out.print("\" title="+bundle.getString("ARTICLE_HINT_ADDIMAGE") + ">");
                                 out.print("<img src='/images/arrow_down.gif' border=0>");
                                 out.print("</a>");

                                 out.print("<a href=\"");
                                 out.print("javascript:delatt('"+ att.GetID()+"');");
                                 out.print("\" title="+bundle.getString("ARTICLE_HINT_DELIMAGE") + ">");
                                 out.print("<img src='/images/delete.gif' border=0>");
                                 out.print("</a>");
                             }

                             out.println("</span>");

                             if(att.GetIndex()>max_att_index) max_att_index = att.GetIndex();
                         }

                         out.print("<script language='javascript'>max_index_att="+max_att_index+";</script>");
                     }
                 }
               %>
               </td></tr>
             </TBODY>
            </table>
        </td>
    </tr>

</table>
</form>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td>
		<div id="FCKeditor">
            <textarea id="DataFCKeditor" cols="80" rows="20"><% if(art!=null) art.GetContent(out); %></textarea>
		</div>
    </td>
  </tr>
</table>
<form name="resFrm" action="selectresource.jsp" target="_blank">
    <input type="hidden" name="multiple" value="1">
    <input type="hidden" name="func" value="">    
    <input type="hidden" name="siteid" value="<%=Utils.Null2Empty(site_id)%>">
    <input type="hidden" name="type" value="-1">
</form>
</body>
</html>

<%
    if(art!=null) art.Clear();
    if(wrapper!=null) wrapper.Clear();
%>