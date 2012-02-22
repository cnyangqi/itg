
<%@page import="com.nfwl.cdxx.NFWL_PESTICIDE"%>
<%@page import="com.nfwl.util.JDatabase"%>
<%@page import="java.sql.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
  pageEncoding="UTF-8"%>
  
  <%@page import="com.gemway.partner.JUtil"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>想购网</title>
<LINK href="/css/style.css" rel = stylesheet>

<%@ include file = "/include/header.jsp" %>
<%
String cmd = JUtil.convertNull(request.getParameter("cmd"));
String ui_name = JUtil.convertChinese(JUtil.convertNull(request.getParameter("ui_name")));

String pagename = "selectUnit.jsp";
//===== ====== Define for scroll page [start] ===== ======
int PageSize = 20;
int currPage = 1;
int RecCount = 0;
int TotalPages = 0;
String nextpage = pagename;
String scrollstr = "";
String ToPage="";



scrollstr = "&ui_name="+ui_name;


Connection con = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

PreparedStatement pstmtcount = null;
ResultSet rscount = null;

try{
  con = nps.core.Database.GetDatabase("nfwl").GetConnection();

}

String sql = "select ui_id, ui_name, ui_registerid, ui_time from itg_unitinfo where 1=1 " ;
String sql_count = "select count(*) from itg_unitinfo where 1=1 " ;
String clause = "";

if(ui_name.trim().length()>0){
  clause += " and ui_name like ? ";
}

pstmtcount = con.prepareStatement(sql_count+clause);
int pos = 1;
if(ui_name.trim().length()>0){
  pstmtcount.setString(pos++,"%"+ui_name.trim()+"%");
}

pstmt = con.prepareStatement(sql+clause);
pos = 1;
if(ui_name.trim().length()>0){
 pstmt.setString(pos++,"%"+ui_name.trim()+"%");
}
rscount = pstmtcount.executeQuery();
if(rscount.next())
{
    RecCount = rscount.getInt(1);
    rscount.close();

    TotalPages = (int)((RecCount - 1)/PageSize) + 1;
    ToPage = JUtil.convertNull(request.getParameter("currPage"));
    try{currPage = Integer.parseInt(ToPage);}catch(Exception e) {currPage = 1;}
    rs = pstmt.executeQuery();

%>
</head>
 
<script language="javascript">

function doQuery(){
  var doc = document.unitfrm;
  doc.cmd.value='query';
  doc.submit();
}


  function doChoose(nyid,nycode){
    var doc = document.unitfrm;
    if(!doc.txt_uiid){
      alert("没有农药信息");
      return false;
    }
    var nyidvalue = '' ;
    var nycodevalue = '' ;
    var nysyqk = '';
    var nytjgg = '';
    if(doc.txt_uiid.length){
      for(var i=0;i<doc.txt_uiid.length;i++){
        if(doc.txt_uiid[i].checked){
          nyidvalue = doc.txt_uiid[i].value;
          nycodevalue = doc.txt_uiid[i].nycode;
          nysyqk = doc.txt_uiid[i].syqk;
          nytjgg = doc.txt_uiid[i].tjgg;
        }
      }
    }else{
      if(doc.txt_uiid.checked){
        nyidvalue = doc.txt_uiid.value;
        nycodevalue = doc.txt_uiid.nycode;
        nysyqk = doc.txt_uiid.syqk;
        nytjgg = doc.txt_uiid.tjgg;
      }else{
        
      }
    }
    
    if(nyidvalue==''){
      alert("请选择农药");
      return false;
    }
    
     opener.setValue(nyidvalue,nycodevalue,nysyqk,nytjgg);
     window.close();
  }
</script>
<body>
<form name=unitfrm action="selectNY.jsp" target="_self">
<input type="hidden" name=cmd  />
<div class="card_border">
<div class="user_information">
<div class="user_title"><span>农药信息维护</span></div>
<div class="search">
<ul><li><input type="button" value="查询"  onclick="doQuery()"  /></li>
   <li><input type="button" value="选定并返回"  onclick="doChoose()" /></li>
 </ul>
<ul>
   <li>农药代号：<input name=txt_code value="<%=txt_code %>" size="10" maxlength="25" /><input type="hidden" name=txt_id  /></li>
  <li>名称：<input name=txt_name value="<%=txt_name %>" size="10" maxlength="30" /></li>
  <li>生产单位：<input name=txt_scdw value="<%=txt_scdw %>" size="10" maxlength="50" /></li>
  <!-- 
  <li>经销单位：<input name=txt_jxdw value="<%=txt_jxdw %>" size="10" maxlength="50" /></li>
  <li>规格型号：<input name=txt_type value="<%=txt_type %>" size="5" maxlength="50" /></li>
   -->
  <li>适用情况：<input name=txt_syqk value="<%=txt_syqk %>" size="5" maxlength="50" /></li>
  <li>推荐规格：<input name=txt_tjgg value="<%=txt_tjgg %>" size="5" maxlength="50" /></li>
  
</ul>
</div>
<div class="list">
<div class="user_title1">
<table width="100%" height="27px" border="0" cellpadding="0"
  cellspacing="0">
  <tr>
    <td width="5%">选择</td>
    <td width="10%">农药代号</td>
    <td width="10%">名称</td>
    <td width="8%">规格型号</td>
    <!-- 
    <td width="10%">生产单位</td>
    <td width="10%">经销单位</td>
     -->
    <td width="10%">适用情况</td>
    <td width="10%">推荐规格</td>
    
  </tr>
</table>
</div>
<div class="list_search">
<table width="100%" border="0" cellpadding="0" cellspacing="0">

<%
int posrow = 0;
while(rs.next() && rs.getRow() <= (currPage *PageSize)){
    if( rs.getRow() <= (currPage-1)*PageSize ) continue;
  
  %>
<tr <%=(posrow++%2==1)?"":"class=\"list_bg\"" %>>
    <td width="5%">
    <input type="radio" name="txt_uiid" nycode="<%=JUtil.convertNull(rs.getString("ui_id")) %>" 
    syqk="<%=JUtil.convertNull(rs.getString("syqk")) %>" tjgg="<%=JUtil.convertNull(rs.getString("tjgg")) %>" 
    value="<%=JUtil.convertNull(rs.getString("id")) %>"  /></td>
    <td width="10%" height="30"><%=JUtil.convertNull(rs.getString("code")) %></td>
    <td width="10%"><%=JUtil.convertNull(rs.getString("name")) %></td>
    <td width="8%"><%=JUtil.convertNull(rs.getString("type")) %></td>
    <!-- 
    <td width="10%"><%=JUtil.convertNull(rs.getString("scdw")) %></td>
    <td width="10%"><%=JUtil.convertNull(rs.getString("jxdw")) %></td>
     -->
    <td width="10%"><%=JUtil.convertNull(rs.getString("syqk")) %></td>
    <td width="10%"><%=JUtil.convertNull(rs.getString("tjgg")) %></td>
    
  </tr>
<%} %>
  
</table>
</div>
</div>

</div>
</div>
</form>
<%@ include file = "/scrollpage.jsp" %>
</body>
</html>
<%}}catch(Exception e){
  e.printStackTrace();
}finally{
  if(rscount!=null)try{rscount.close();}catch(Exception e){}
  if(pstmtcount!=null)try{pstmtcount.close();}catch(Exception e){}
  if(rs!=null)try{rs.close();}catch(Exception e){}
  if(pstmt!=null)try{pstmt.close();}catch(Exception e){}
  if(con!=null)try{con.close();}catch(Exception e){}
}

%>
