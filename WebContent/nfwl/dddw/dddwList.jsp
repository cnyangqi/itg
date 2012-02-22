<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.sql.*" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Enumeration" %>

<%@ include file="/include/header.jsp" %>


<%
    request.setCharacterEncoding("UTF-8");
    int rowperpage = 20;
    int currpage = 1, startnum = 0, endnum = 0, totalrows = 0, totalpages = 0, rownum=0;
    String scrollstr = "", nextpage = "dddwList.jsp";
    String currpg    = request.getParameter("page");
    try{ currpage = Integer.parseInt(currpg); }catch (Exception e){currpage = 1;  }

    int fp_valid = 9; //默认为有效
    String s_valid =request.getParameter("fp_valid");
    try { fp_valid =Integer.parseInt(s_valid);}catch(Exception e){ fp_valid = 9; }
    //scrollstr = "fp_valid="+fp_valid;
    String s_rows = request.getParameter("rows");
    
    try { rowperpage =Integer.parseInt(s_rows);}catch(Exception e){}
    String sqlCount = "select count(*) from itg_fixedpoint where 1=1 ";
    String sqlResult = "select fp_id, fp_name, fp_address, fp_linker, fp_phone, fp_email, fp_postcode, fp_code, fp_valid, fp_registerid, fp_time from itg_fixedpoint where 1=1 ";
    String sqlWhere = "";
    
    if(fp_valid < 9){
      scrollstr += "&fp_valid=" + fp_valid;
      sqlWhere += " and fp_valid = ? ";
      
    }
    
    
    String fp_name = request.getParameter("fp_name");
    if(fp_name!=null && fp_name.length()>0)
    {
        fp_name = fp_name.trim();
        //if(!fp_name.endsWith("%")) fp_name += "%";
        scrollstr += "&fp_name=" + java.net.URLEncoder.encode(fp_name,"UTF-8");
        sqlWhere += " and fp_name like ? ";
    }
    
    String fp_address = request.getParameter("fp_address");
    if(fp_address!=null && fp_address.length()>0)
    {
      fp_address = fp_address.trim();
        //if(!fp_address.endsWith("%")) fp_address += "%";
        scrollstr += "&fp_address=" + java.net.URLEncoder.encode(fp_address,"UTF-8");
        sqlWhere += " and fp_address like ? ";
    }//fp_linker
    
    String fp_linker = request.getParameter("fp_linker");
    if(fp_linker!=null && fp_linker.length()>0)
    {
      fp_linker = fp_linker.trim();
        //if(!fp_linker.endsWith("%")) fp_linker += "%";
        scrollstr += "&fp_linker=" + java.net.URLEncoder.encode(fp_linker,"UTF-8");
        sqlWhere += " and fp_linker like ? ";
    }


    String from_date = request.getParameter("from_date");
    if(from_date!=null && from_date.length()>0)
    {
        from_date = from_date.trim();
        scrollstr += "&from_date="+from_date;
        sqlWhere += " and trunc(fp_time) >= to_date(?, 'YYYY-MM-DD') ";
    }

    String to_date = request.getParameter("to_date");
    if(to_date!=null && to_date.length()>0)
    {
        to_date = to_date.trim();
        scrollstr += "&to_date="+to_date;
        sqlWhere += " and trunc(fp_time) <= to_date(?, 'YYYY-MM-DD') ";
    }
    String job = request.getParameter("job");
    
    
    PreparedStatement pstmt   = null;
    ResultSet rs     = null;
    Connection con = null;
    
    try{
      con = Database.GetDatabase("nps").GetConnection();
     
      //删除
      if("delete".equalsIgnoreCase(job)){
          String[] fp_ids = request.getParameterValues("fp_ids");
          try{
            for(int i=0;fp_ids!=null&&i<fp_ids.length;i++){
              com.nfwl.itg.dddw.ITG_FIXEDPOINT.delete(con,fp_ids[i]);
            }
         }catch(Exception e){
           e.printStackTrace();
         }
       }
    
    
%>

<HTML>
  <HEAD>
    <TITLE>定点单位 </TITLE>
        <script type="text/javascript" src="/jscript/global.js"></script>
        <LINK href="/css/style.css" rel = stylesheet>
        <script langauge = "javascript">
            function f_search(){
              document.frm_search.submit();
            }
            function f_new(){
              document.listFrm.action = "dddwInfo.jsp";
              document.listFrm.target="_blank";
              document.listFrm.submit();
           }
            function f_view(fp_id){
              document.listFrm.action = "dddwInfo.jsp?fp_id="+fp_id;
              document.listFrm.target="_blank";
              document.listFrm.submit();
           }
            function f_submit(actiontype){
                var fp_ids = document.getElementsByName("fp_ids");
                var hasChecked = false;
                for (var i = 0; i < fp_ids.length; i++){
                   if( fp_ids[i].checked ){ hasChecked = true; break; }
                }
                if( !hasChecked ){
                  alert('请选中要操作的记录');                  
                  return false;
                }

                var rc = true; 
                if( actiontype == 'delete'){
                  r = confirm("确认删除？");
                  if( r !=1 ) return false;
                  document.listFrm.action = "dddwList.jsp?job=delete";
                  document.listFrm.target="_self";
                }
                if( actiontype == 'submit'){
                  document.listFrm.action = "dddwList.jsp?job=submit";
                  document.listFrm.target="_self";
                }
                if( actiontype == 'check'){
                  document.listFrm.action = "dddwList.jsp?job=check";
                  document.listFrm.target="_self";
                }
                if( actiontype == 'publish'){
                  document.listFrm.action = "dddwList.jsp?job=publish";
                  document.listFrm.target="_self";
                }
                if( actiontype == 'republish'){
                  document.listFrm.action = "dddwList.jsp?job=republish";
                  document.listFrm.target="_self";
                }
                if( actiontype == 'cancel'){
                  document.listFrm.action = "dddwList.jsp?job=cancel";
                  document.listFrm.target="_self";
                }
                if( rc) document.listFrm.submit();
             }

           

            function SelectArticle(){
              var fp_ids = document.getElementsByName("rowno");
              for (var i = 0; i < fp_ids.length; i++){
                fp_ids[i].checked = document.listFrm.AllId.checked;
              }
           }
    </script>
        <script type="text/javascript" src="/jscript/calendar.js"></script>
    </HEAD>
<BODY>
<%
        
        pstmt = con.prepareStatement(sqlCount+sqlWhere);
        int pos = 1;
        if(fp_valid < 9){
          pstmt.setInt(pos++,fp_valid);
        }
        
        if(fp_name!=null && fp_name.length()>0){
          pstmt.setString(pos++,"%"+fp_name+"%");
        }
        
        if(fp_address!=null && fp_address.length()>0){
          pstmt.setString(pos++,"%"+fp_address+"%");
        }//fp_linker
        if(fp_linker!=null && fp_linker.length()>0){
          pstmt.setString(pos++,"%"+fp_linker.trim()+"%");
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
    <form name="frm_search" method="post" action="dddwList.jsp">
    <tr height="25" style="padding-top:5px">
        <td  align="right" width="10%" >名称:</td>
        <td align="left" width="15%"><input type="text" name="fp_name" value="<%=Utils.Null2Empty(fp_name)%>"></td>
        <td  align="right" width="10%" >地址:</td>
        <td align="left" width="15%"><input type="text" name="fp_address" value="<%=Utils.Null2Empty(fp_address)%>"></td>
        <td  align="right" width="10%" >联系人:</td>
        <td align="left" width="15%"><input type="text" name="fp_linker" style="width:80px" value="<%=Utils.Null2Empty("")%>"></td>
        <td  align="right" width="10%" >是否有效:</td>
        <td align="left" width="15%">
          <select name="fp_valid" >
                <option value="9" <% if(fp_valid==9) out.print("selected");%>>全部</option>
                <option value="1" <% if(fp_valid==1) out.print("selected");%>>是</option>
                <option value="0" <% if(fp_valid==0) out.print("selected");%>>否</option>
            </select>
        </td>
        
    </tr>
    <tr height="25" style="padding-top:5px;padding-bottom:5px">
        <td  align="right" width="10%" >注册日期:</td>
        <td align="left" width="15%">
          <input type="text" id="from_date" name="from_date" style="width:70px" value="<%=Utils.Null2Empty(from_date)%>" onClick="getDateString(this,<% if("zh".equalsIgnoreCase(user.GetLocale().getLanguage())) out.print("oCalendarChs"); else out.print("oCalendarEn");%>)">
            -
            <input type="text" id="to_date" name="to_date" style="width:70px" value="<%=Utils.Null2Empty(to_date)%>"  onClick="getDateString(this,<% if("zh".equalsIgnoreCase(user.GetLocale().getLanguage())) out.print("oCalendarChs"); else out.print("oCalendarEn");%>)">
        </td>
        <td align="right" width="10%">&nbsp;</td>
        <td align="left" width="15%">&nbsp;</td>
        <td align="right" width="10%">&nbsp;</td>
        <td align="left" width="15%">&nbsp;</td>
        <td align="center" width="10%">
            
            <input type="button" class="button" name="searchBtn" value="查询" onclick="f_search()">&nbsp;&nbsp;
            <input type="button" class="button" name="newBtn" value="新建" onclick="f_new()">&nbsp;&nbsp;
            <!-- <input type="button" class="button" name="deleteBtn" value="删除" onclick="f_submit('delete')"> -->
        
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
      <!-- fp_name, fp_address, fp_linker, fp_phone, fp_email, fp_postcode, fp_code, fp_valid, fp_registerid, fp_time -->
        <td>名称</td>
        <td >地址</td>
        <td >联系人</td>
        <td >注册时间</td>
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
            

            if(fp_name!=null && fp_name.length()>0){
              pstmt.setString(pos++,"%"+fp_name+"%");
            }
            
            if(fp_address!=null && fp_address.length()>0){
              pstmt.setString(pos++,"%"+fp_address+"%");
            }//fp_linker
            if(fp_linker!=null && fp_linker.length()>0){
              pstmt.setString(pos++,"%"+fp_linker.trim()+"%");
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
                  <input type = "checkBox" id="rowno" name="fp_ids" value = "<%= rs.getString("fp_id") %>">
                </td>
                <td>
                   <%= com.gemway.util.JUtil.convertNull(rs.getString("fp_name")) %>
                </td>
                <td>
                  <%= com.gemway.util.JUtil.convertNull(rs.getString("fp_address")) %>
                </td>
                <td>
                  <%= com.gemway.util.JUtil.convertNull(rs.getString("fp_linker")) %>
                </td>
                <td>
                   <%= com.gemway.util.JUtil.convertNull(Utils.FormateDate(rs.getDate("fp_time"),"yyyy-MM-dd")) %>
                </td>
                <td>
                   <a href="javascript:f_view('<%= rs.getString("fp_id") %>')">详情</a>
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