<%@page import="com.gemway.util.JLog"%>
<%@page import="com.gemway.util.JError"%>
<%@page import="nps.core.Database"%>
<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.core.Config" %>
<%@ page import="java.sql.*" %>
<%@ page import="nps.util.Utils" %>
<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String or_id=request.getParameter("or_id");//如果为null，将再保存时使用序列生成ID号
    if(or_id==null) or_id="'201107081611182609430541270000000001'";
    if(or_id!=null) or_id=or_id.trim();   
    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 
<meta http-equiv="Content-Language" content="zh-CN" /> 
  <title>打印发货单</title>
  <LINK href="/css/style.css" rel = stylesheet />
  <script type="text/javascript">
  function doPrint(){
    var headstr = "<html><head><title></title></head><body>";
    var footstr = "</body>";
    var newstr = document.getElementById("div_print").innerHTML;
    var oldstr = document.body.innerHTML;
    document.body.innerHTML = headstr+newstr+footstr;
    window.print(); 
    document.body.innerHTML = oldstr;
    //return false;

  }
  
  </script>
</head>

<body leftmargin=20 topmargin=0>

<table align=center border="0" class="positionbar" cellpadding="0" cellspacing="0">
  <tr>
    <td>  &nbsp;

      <input type="button" class="button" name="save" value="打印" onClick="doPrint()" >
      <input type="button" class="button" name="close" value="关闭" onclick="javascript:window.close();">
    </td>
  </tr>
</table>
<%
String sql = "select nvl(fp.fp_name,'无定点单位') fp_name ,\n" +
"       u.name,\n" + 
"       nvl(u.worknum,' ') worknum,\n" + 
"       or_no,\n" + 
"       od.od_detail ,\n" + 
"       sum_string('itg_orderdetail', 'od_prdname||-od_num','where od_orid = ' || or_id) product\n" + 
"  from itg_orderrec o,itg_orderrecdelivery od,users u ,itg_fixedpoint fp\n" + 
"  where o.or_userid = u.id and u.itg_fixedpoint = fp.fp_id(+) \n" + 
//"    and o.or_status = 2\n" +//状态为2 标识已付款
"   and o.or_id = od.od_orid "+
"   and o.or_id in ("+or_id+")";

try{
  
 con = Database.GetDatabase("nps").GetConnection();
 pstmt = con.prepareStatement(sql);
 rs = pstmt.executeQuery();

%>
<div id="div_print">
<table align=center border="1" width="100%" cellspacing="1" cellpadding="0" >
  <tr>
    <td width="10%" >  单位 </td>
    <td width="10%" >  职工 </td>
    <td width="10%" >  工号 </td>
    <td width="10%" >  订单号 </td>
    <td width="20%" >  产品 </td>
    <td width="30%" >  详细地址 </td>
    <td width="10%" >  签收 </td>
  </tr>
<% while(rs.next()){ %>
  <tr>
    <td> <%=rs.getString("fp_name") %>&nbsp; </td>
    <td> <%=rs.getString("name") %>&nbsp; </td>
    <td> <%=rs.getString("worknum") %>&nbsp; </td>
    <td> <%=rs.getString("or_no") %>&nbsp; </td>
    <td> <%=rs.getString("product") %>&nbsp; </td>
    <td> <%=rs.getString("od_detail") %>&nbsp; </td>
    <td> &nbsp; </td>
    
  </tr>
  <%} %>
</table>
</div>

<% 
}catch(Exception ex){
  if(ex instanceof JError) throw (JError) ex;
  JLog.getLogger().error("读取产品信息表时出错:",ex);
  throw new JError("读取产品信息表时出错！");
}
finally{
  if(rs!=null) try{rs.close();}catch(Exception ex){}
  if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
  if(con!=null) try{con.close();}catch(Exception ex){}
}

%>
</body>
</html>