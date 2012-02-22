<%@page import="com.gemway.util.JUtil"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@ page contentType="application/vnd.ms-excel; charset=UTF-8" errorPage="/error.jsp" %>
<%response.setHeader("Content-disposition","attachment; filename=Rep_SaveCard_.xls" );%>
<html xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:x="urn:schemas-microsoft-com:office:excel"
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 
<meta name=ProgId content=Excel.Sheet>
<meta name=Generator content="Microsoft Excel 9">
<title>储值卡</title>
  
</head>
<body>
<table align=center border="1" width="100%" cellspacing="1" cellpadding="0">
<tr>
<td>卡号</td>
<td>密码</td>
<td>金额</td>
<td>余额</td>
<td>创建时间</td>
<td>销售时间</td>
<td>使用时间</td>
<td>状态</td>
</tr>
<%
request.setCharacterEncoding("UTF-8");
String ids=JUtil.convertNull(request.getParameter("ids"),"''");//如果为null，将再保存时使用序列生成ID号

Connection con = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
String sql = "select sc_cardno, sc_cardpwd, sc_money, sc_balance, "
+"nvl(to_char(sc_time,'YYYY-MM-DD'),' ') sc_time, nvl(to_char(sc_publishtime,'YYYY-MM-DD'),' ') sc_publishtime, nvl(to_char(sc_usetime,'YYYY-MM-DD'),' ') sc_usetime, sc_creatorid, sc_status,decode(sc_status,0,'新建',1,'已销售',2,'已使用',-1,'删除','未知') cnstatus from itg_savecard where sc_cardno in ("+ids+")";
try{
  con = nps.core.Database.GetDatabase("nps").GetConnection();
  pstmt = con.prepareStatement(sql);
  rs = pstmt.executeQuery();

  while(rs.next()){

%>
<tr>
<td><%=rs.getString("sc_cardno") %></td>
<td><%=rs.getString("sc_cardpwd") %></td>
<td><%=rs.getString("sc_money") %></td>
<td><%=rs.getString("sc_balance") %></td>
<td><%=rs.getString("sc_time") %></td>
<td><%=rs.getString("sc_publishtime") %></td>
<td><%=rs.getString("sc_usetime") %></td>
<td><%=rs.getString("cnstatus") %></td>
</tr>
<%
  }
  }catch(Exception e){



}finally{
  if(rs!=null)try{rs.close();}catch(Exception ex){}
  if(pstmt!=null)try{pstmt.close();}catch(Exception ex){}
  if(con!=null)try{con.close();}catch(Exception ex){}
}

%>

</table>
</body>
</html>