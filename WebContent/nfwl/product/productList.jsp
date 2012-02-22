<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.sql.*" %>
<%@ page import="nps.core.*" %>
<%@ page import="java.io.*" %>
<%@ page import="com.nfwl.itg.common.*" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="com.nfwl.itg.product.*" %>

<%@ include file="/include/header.jsp" %>


<%
    request.setCharacterEncoding("UTF-8");
    int rowperpage = 20;
    int currpage = 1, startnum = 0, endnum = 0, totalrows = 0, totalpages = 0, rownum=0;
    String scrollstr = "", nextpage = "productList.jsp";
    String currpg    = request.getParameter("page");
    try{ currpage = Integer.parseInt(currpg); }catch (Exception e){currpage = 1;  }

    int fp_valid = 9; //默认为有效
    String s_valid =request.getParameter("fp_valid");
    try { fp_valid =Integer.parseInt(s_valid);}catch(Exception e){ fp_valid = 9; }
    //scrollstr = "fp_valid="+fp_valid;
    String s_rows = request.getParameter("rows");
    String originprovincename = request.getParameter("originprovincename");
    if(originprovincename==null||originprovincename.trim().length()==0)originprovincename = "";
    try { rowperpage =Integer.parseInt(s_rows);}catch(Exception e){}
    String sqlCount = "select count(*) from itg_product where 1=1 ";
    String sqlResult = "select prd_id, prd_name, prd_psid, prd_code, prd_newlevel, prd_marketprice, prd_localprice, prd_point,"+
    "prd_brandid, prd_brandname, prd_unitid, prd_unitname, prd_spec, prd_origincountryid, prd_origincountryname, prd_originprovinceid,"+
    " prd_originprovincename, prd_shipfee, prd_content, prd_parameter, prd_registerid, prd_time, prd_editorid, prd_edittime from itg_product where 1=1 ";
    String sqlWhere = "";
    
    if(fp_valid < 9){
      scrollstr += "&fp_valid=" + fp_valid;
      sqlWhere += " and fp_valid = ? ";
      
    }
    
    
    String prd_name = request.getParameter("prd_name");
    if(prd_name!=null && prd_name.length()>0)
    {
        prd_name = prd_name.trim();
        //if(!prd_name.endsWith("%")) prd_name += "%";
        scrollstr += "&prd_name=" + java.net.URLEncoder.encode(prd_name,"UTF-8");
        sqlWhere += " and prd_name like ? ";
    }
    
    String prd_originprovinceid = request.getParameter("prd_originprovinceid");
    if(prd_originprovinceid!=null && prd_originprovinceid.trim().length()>0)
    {
      //System.out.println("prd_originprovinceid = ["+prd_originprovinceid+"]");
      prd_originprovinceid = prd_originprovinceid.trim();
        //if(!prd_name.endsWith("%")) prd_name += "%";
        scrollstr += "&prd_originprovinceid=" + java.net.URLEncoder.encode(prd_originprovinceid,"UTF-8");
        sqlWhere += " and prd_originprovinceid like ? ";
        
        //"src/com/nfwl/itg/common/ITG_ZONEINFO.java"
        //originprovincename
        
    }
    
    
    String prd_code = request.getParameter("prd_code");
    if(prd_code!=null && prd_code.length()>0)
    {
      prd_code = prd_code.trim();
        //if(!prd_code.endsWith("%")) prd_code += "%";
        scrollstr += "&prd_code=" + java.net.URLEncoder.encode(prd_code,"UTF-8");
        sqlWhere += " and prd_code like ? ";
    }//prd_brandname
    
    String prd_brandname = request.getParameter("prd_brandname");
    if(prd_brandname!=null && prd_brandname.length()>0)
    {
      prd_brandname = prd_brandname.trim();
        //if(!prd_brandname.endsWith("%")) prd_brandname += "%";
        scrollstr += "&prd_brandname=" + java.net.URLEncoder.encode(prd_brandname,"UTF-8");
        sqlWhere += " and prd_brandname like ? ";
    }


    String from_date = request.getParameter("from_date");
    if(from_date!=null && from_date.length()>0)
    {
        from_date = from_date.trim();
        scrollstr += "&from_date="+from_date;
        sqlWhere += " and trunc(prd_time) >= to_date(?, 'YYYY-MM-DD') ";

    }

    String to_date = request.getParameter("to_date");
    if(to_date!=null && to_date.length()>0)
    {
        to_date = to_date.trim();
        scrollstr += "&to_date="+to_date;
        sqlWhere += " and trunc(prd_time) <= to_date(?, 'YYYY-MM-DD') ";
    }

    

    String job = request.getParameter("job");
    
    
    PreparedStatement pstmt   = null;
    ResultSet rs     = null;
    Connection con = null;
    
    try{
      con = Database.GetDatabase("nfwl").GetConnection();
     
      //删除
      if("delete".equalsIgnoreCase(job)){
        java.util.Vector vipimage = null;
          String[] prd_ids = request.getParameterValues("prd_ids");
          ITG_PRODUCTIMAGE tempImage = null;
          try{
            for(int i=0;prd_ids!=null&&i<prd_ids.length;i++){
              com.nfwl.itg.product.ITG_PRODUCT.delete(con,prd_ids[i]);
             
              vipimage = ITG_PRODUCTIMAGE.getByPrdid(con,prd_ids[i]);

              for(int j=0;vipimage!=null&&j<vipimage.size();j++){
                tempImage = (ITG_PRODUCTIMAGE)vipimage.get(j);
                if(tempImage!=null){
                    
                      try{
                         new File(request.getRealPath("/")+tempImage.getFilepath()+tempImage.getId()+tempImage.getExt()).delete();
                         ITG_PRODUCTIMAGE.delete(con,tempImage.getId());
                         
                      }catch(Exception e){
                        e.printStackTrace();
                      }finally{
                        
                      }
                }
              }
              
              com.nfwl.itg.product.ITG_PRODUCT.delete(con,prd_ids[i]);
            
            }
         }catch(Exception e){
           e.printStackTrace();
         }
       }
    
      if(prd_originprovinceid!=null && prd_originprovinceid.trim().length()>0)
      {
        
          ITG_ZONEINFO  tempzone =  ITG_ZONEINFO.get(con,prd_originprovinceid);
          if(tempzone!=null) originprovincename  = tempzone.getName();
      }
%>

<HTML>
  <HEAD>
    <TITLE>产品管理 </TITLE>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <script type="text/javascript" src="/jscript/ajax_common.js"></script>
    <script type="text/javascript" src="/FCKeditor/fckeditor.js"></script>   
    <script type="text/javascript" src="/nfwl/js/inputcheck.js"></script>
    <script type="text/javascript" src="/nfwl/js/xtree.js"></script>
    <script type="text/javascript" src="/nfwl/js/treeselect.js"></script>
    
    <LINK href="/nfwl/css/style.css" rel = stylesheet>
    <!-- 
    <link type="text/css" rel="stylesheet" href="/nfwl/css/xtree.css">
    <link type="text/css" rel="stylesheet" href="/nfwl/css/treeselect.css">
     -->
        <LINK href="/css/style.css" rel = stylesheet>
        <script langauge = "javascript">
            function f_search(){
              document.frm_search.submit();
            }
            function f_new(){
              document.listFrm.action = "productInfo.jsp";
              document.listFrm.target="_blank";
              document.listFrm.submit();
           }
            function f_view(prd_id){
              document.listFrm.action = "productInfo.jsp?prd_id="+prd_id;
              document.listFrm.target="_blank";
              document.listFrm.submit();
           }
            function f_submit(actiontype){
                var prd_ids = document.getElementsByName("prd_ids");
                var hasChecked = false;
                for (var i = 0; i < prd_ids.length; i++){
                   if( prd_ids[i].checked ){ hasChecked = true; break; }
                }
                if( !hasChecked ){
                  alert('请选中要操作的记录');                  
                  return false;
                }

                var rc = true; 
                if( actiontype == 'delete'){
                  r = confirm("确认删除？");
                  if( r !=1 ) return false;
                  document.listFrm.action = "productList.jsp?job=delete";
                  document.listFrm.target="_self";
                }
                if( actiontype == 'submit'){
                  document.listFrm.action = "productList.jsp?job=submit";
                  document.listFrm.target="_self";
                }
                if( actiontype == 'check'){
                  document.listFrm.action = "productList.jsp?job=check";
                  document.listFrm.target="_self";
                }
                if( actiontype == 'publish'){
                  document.listFrm.action = "productList.jsp?job=publish";
                  document.listFrm.target="_self";
                }
                if( actiontype == 'republish'){
                  document.listFrm.action = "productList.jsp?job=republish";
                  document.listFrm.target="_self";
                }
                if( actiontype == 'cancel'){
                  document.listFrm.action = "productList.jsp?job=cancel";
                  document.listFrm.target="_self";
                }
                if( rc) document.listFrm.submit();
             }

           

            function SelectArticle(){
              var prd_ids = document.getElementsByName("rowno");
              for (var i = 0; i < prd_ids.length; i++){
                prd_ids[i].checked = document.listFrm.AllId.checked;
              }
           }
    </script>
        <script type="text/javascript" src="/jscript/calendar.js"></script>
    </HEAD>
<BODY>
<%
        
        pstmt = con.prepareStatement(sqlCount+sqlWhere);
    //System.out.println(sqlCount+sqlWhere);
        int pos = 1;
        if(fp_valid < 9){
          pstmt.setInt(pos++,fp_valid);
        }
        
        if(prd_name!=null && prd_name.length()>0){
          pstmt.setString(pos++,"%"+prd_name+"%");
        }
        if(prd_originprovinceid!=null && prd_originprovinceid.trim().length()>0)
        {
          pstmt.setString(pos++,prd_originprovinceid+"%");
        }
        
        if(prd_code!=null && prd_code.length()>0){
          pstmt.setString(pos++,"%"+prd_code+"%");
        }//prd_brandname
        
        
        if(prd_brandname!=null && prd_brandname.length()>0){
          pstmt.setString(pos++,"%"+prd_brandname.trim()+"%");
        }
        if(from_date!=null && from_date.length()>0)
        {
          pstmt.setString(pos++,from_date);

        }
        if(to_date!=null && to_date.length()>0)
        {
          pstmt.setString(pos++,to_date);

        }
        rs = pstmt.executeQuery();
        if (rs.next())  totalrows = rs.getInt(1);
        try{rs.close();}catch(Exception e){}
        try{pstmt.close();}catch(Exception e){}
%>
  <table width = "100% " border = "0" cellpadding = "0" cellspacing = "0" class="PositionBar">
    <form name="frm_search" method="post" action="productList.jsp">
    <tr height="25" style="padding-top:5px">
        <td  align="right" width="10%" >名称:</td>
        <td align="left" width="15%"><input type="text" name="prd_name" value="<%=Utils.Null2Empty(prd_name)%>"></td>
        <td  align="right" width="10%" >编号:</td>
        <td align="left" width="15%"><input type="text" name="prd_code" value="<%=Utils.Null2Empty(prd_code)%>"></td>
        <td  align="right" width="10%" >品牌:</td>
        <td align="left" width="15%"><input type="text" name=prd_brandname style="width:80px" value="<%=Utils.Null2Empty(prd_brandname)%>"></td>
        <td  align="right" width="10%" >产地:</td>
        <td align="left" width="15%" >
          <script language="JavaScript" >
          <% 
          if(prd_originprovinceid==null||prd_originprovinceid.trim().length()==0)prd_originprovinceid ="";
          %>
           <%=com.nfwl.itg.common.ITG_ZONEINFO.getJSString(con,"cjgTree","prd_originprovinceid",originprovincename,prd_originprovinceid,"EXCEPT_ROOT_ELEMENT") %>     
        </script> 
        </td>
        
    </tr>
    <tr height="25" style="padding-top:5px;padding-bottom:5px">
        <td  align="right" width="10%" >录入日期:</td>
        <td align="left" colspan="2" width="25%">
          <input type="text" id="from_date" name="from_date" style="width:70px" value="<%=Utils.Null2Empty(from_date)%>" onClick="getDateString(this,<% if("zh".equalsIgnoreCase(user.GetLocale().getLanguage())) out.print("oCalendarChs"); else out.print("oCalendarEn");%>)">
            -
            <input type="text" id="to_date" name="to_date" style="width:70px" value="<%=Utils.Null2Empty(to_date)%>"  onClick="getDateString(this,<% if("zh".equalsIgnoreCase(user.GetLocale().getLanguage())) out.print("oCalendarChs"); else out.print("oCalendarEn");%>)">
        </td>
        <td align="left" width="15%">&nbsp;</td>
        <td align="right" width="10%">&nbsp;</td>
        <td align="left" width="15%">&nbsp;</td>
        <td align="center" width="10%">
            
            <input type="button" class="button" name="searchBtn" value="查询" onclick="f_search()">&nbsp;&nbsp;
            <input type="button" class="button" name="newBtn" value="新建" onclick="f_new()">&nbsp;&nbsp;
            <input type="button" class="button" name="deleteBtn" value="删除" onclick="f_submit('delete')">
        
        </td>
        <td align="center" width="15%">&nbsp;</td>
        
        
    </tr>
    </form>
  </table>

  <table width = "100% " border = "0" cellpadding = "0" cellspacing = "1" class="TitleBar">
  <form name = "listFrm" method = "post">
      <input type="hidden" name="fp_valid" value="<%=fp_valid%>">
      <tr height=30>
        <td width="25">
        <input type = "checkBox" name = "AllId" value = "0" onclick = "SelectArticle()">
      </td>
      <!-- prd_name, prd_code, prd_brandname, fp_phone, fp_email, fp_postcode, fp_code, fp_valid, fp_registerid, fp_time -->
        <td>名称</td>
        <td >编码</td>
        <td >品牌</td>
        <td >录入时间</td>
        <td >操作</td>

      </tr>
<%
        if (totalrows > 0)
        {
            totalpages = (int )((totalrows - 1) / rowperpage) + 1;
            startnum = rowperpage * (currpage - 1) + 1;
            endnum = currpage * rowperpage;

            if (pstmt != null) try{ pstmt.close();}catch(Exception e){}
            pstmt = con.prepareStatement(sqlResult+sqlWhere);
            
            pos = 1;
            if(fp_valid < 9){
              pstmt.setInt(pos++,fp_valid);
            }
            

            if(prd_name!=null && prd_name.length()>0){
              pstmt.setString(pos++,"%"+prd_name+"%");
            }
            if(prd_originprovinceid!=null && prd_originprovinceid.length()>0)
            {
              pstmt.setString(pos++,prd_originprovinceid+"%");
            }
            
            
            if(prd_code!=null && prd_code.length()>0){
              pstmt.setString(pos++,"%"+prd_code+"%");
            }//prd_brandname
            if(prd_brandname!=null && prd_brandname.length()>0){
              pstmt.setString(pos++,"%"+prd_brandname.trim()+"%");
            }
            if(from_date!=null && from_date.length()>0)
            {
              pstmt.setString(pos++,from_date);

            }
            if(to_date!=null && to_date.length()>0)
            {
              pstmt.setString(pos++,to_date);

            }
            
            rs = pstmt.executeQuery();

            String articleId = "", siteId = null, topId = null;
            rownum = 0;
            while (rs.next() && (rs.getRow() <= endnum))
            {
                if (rs.getRow() < startnum) continue;
%>
              <tr class="DetailBar">
                <td>
                  <input type = "checkBox" id="rowno" name="prd_ids" value = "<%= rs.getString("prd_id") %>">
                </td>
                <td>
                   <%= com.gemway.util.JUtil.convertNull(rs.getString("prd_name")) %>
                </td>
                <td>
                  <%= com.gemway.util.JUtil.convertNull(rs.getString("prd_code")) %>
                </td>
                <td>
                  <%= com.gemway.util.JUtil.convertNull(rs.getString("prd_brandname")) %>
                </td>
                <td>
                   <%= com.gemway.util.JUtil.convertNull(Utils.FormateDate(rs.getDate("prd_time"),"yyyy-MM-dd")) %>
                </td>
                <td>
                   <a href="javascript:f_view('<%= rs.getString("prd_id") %>')">详情</a>
                </td>
             
              </tr>
          <%
              }
            }  //end of if (totalrows >0)
 %>
  </form>
 </table>
<form name=frmOpen action="articleinfo.jsp" target="_blank">
  <input type = "hidden" name = "id">
  <input type = "hidden" name = "site_id">
  <input type="hidden" name="top_id">
</form>
<script language="JavaScript" type="text/JavaScript">
  function openArt(siteid,topid,idvalue){
    document.frmOpen.id.value = idvalue;
    document.frmOpen.site_id.value = siteid;
    document.frmOpen.top_id.value = topid;      
    document.frmOpen.action="articleinfo.jsp";
    document.frmOpen.submit();
}
  function openCustomArt(siteid,topid,idvalue){
      document.frmOpen.id.value = idvalue;
      document.frmOpen.site_id.value = siteid;
      document.frmOpen.top_id.value = topid;
      document.frmOpen.action = "customartinfo.jsp";
      document.frmOpen.submit();
  }
</script>
<%@ include file="/include/scrollpage.jsp" %>
</BODY>
</HTML>
<%
    }catch (Exception e){
      e.printStackTrace();
      
    }
    finally
    {
        if (rs != null) try{ rs.close();}catch(Exception e){}
        if (pstmt != null) try{ pstmt.close();}catch(Exception e){}
        if (con != null) try{ con.close();}catch(Exception e){}
    }    
%>