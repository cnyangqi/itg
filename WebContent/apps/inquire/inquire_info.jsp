<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="nps.core.Database" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="nps.util.Utils" %>
<%@ include file="/include/header.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");
    String id = request.getParameter("id");
    Connection con   = null;
    PreparedStatement pstmt   = null;
    ResultSet rs     = null;
    PreparedStatement pstmt_product   = null;
    ResultSet rs_product     = null;
    String sql 		 = null;
    try
    {
        con = Database.GetDatabase("nps").GetConnection();
        if(user.IsSysAdmin())
        {
            sql = "select a.* from FT_INQUIRE a,SITE b where a.siteid=b.id and a.id=?";
        }
        else
        {
            sql = "select a.* from FT_INQUIRE a,SITE b where a.siteid=b.id and b.unit=? and a.id=?";
        }

        String orderby = " order by a.createdate desc";
        pstmt = con.prepareStatement(sql+orderby);

        int i=1;
        if(!user.IsSysAdmin())
        {
            pstmt.setString(i++,user.GetUnitId());
        }
        pstmt.setString(i++,id);
        
        rs = pstmt.executeQuery();
        if(!rs.next())  return;
%>
<html>
<head><title><%=rs.getString("mail_subject")%></title></head>
<body>
<table width='95%' border=0 cellspacing=1 cellpadding=4 align='center'>
  <tr valign='top'>
      <td align="center">
          <font size="6">
            <%=rs.getString("mail_subject")%>
          </font>
      </td>
  </tr>
  <tr>
    <td bgcolor='#cccccc' width='560'><font face='Arial,Helvetica' size='2' color='#000066'>
      <b>Buyer's message:</b></font>
    </td>
  </tr>
  <tr>
    <td width='560'>
      <%=Utils.Null2Empty(rs.getString("inquiry_remarks"))%>
      <p>
<%
    if( rs.getInt("info_fob_price")!=0 || rs.getInt("info_delivery_time")!=0 || rs.getInt("info_min_quantity")!=0 )
    {
%>
        Prefer to receive the following information by " + response_date_year + "-" + response_date_month + "-" + response_date_day + ":<br>

<%
    }
    if( rs.getInt("info_fob_price")!=0 )
    {
%>
         - FOB prices (for minimum order quantity)<br>
<%
    }
    if( rs.getInt("info_delivery_time")!=0 )
    {
%>
        - Delivery time<br>
<%
    }
    if( rs.getInt("info_min_quantity")!=0 )
    {
%>
        - Minimum order quantity\n"); <br>
<%
    }
%>
    created at:<%=rs.getDate("createdate")%>       
    </p>
    </td>
  </tr>
</table>

<table width=95% border=0 align=center cellpadding=0 cellspacing=5>
<%
    if( rs.getString("mail_cc")!=null)
    {
%>
    <tr valign='top'>
      <td ><strong>Cc</strong>:</td>
      <td><%=rs.getString("mail_cc")%>
      </td>
    </tr>
<%
    }
%>
</table>
<table width='95%' border='0' align='center' cellpadding='0' cellspacing='5'>
  <tr>
    <td colspan='2' bgcolor='#cccccc' >
    <font face='Arial,Helvetica' size='2' color='#000066'>
      &nbsp;<b>Inquiry Details:</b></font>
     </td>
  </tr>
<%
    sql = "select * from ft_inquire_product where inquire_id=?";
    pstmt_product = con.prepareStatement(sql);
    pstmt_product.setString(1,id);
    rs_product = pstmt_product.executeQuery();
    while(rs_product.next())
    {
%>
    <tr valign='top'>
      <td colspan=2>
        <a href='<%=rs_product.getString("product_url")%>' target='_blank'><%=rs_product    .getString("product_name")%></a>
     </td>
   </tr>
<%
    }                                             

    rs_product.close();
    pstmt_product.close();
%>
  <tr>
    <td bgcolor='#eeeedd' height='20' width='30%'  valign='top'>
      <font face='Arial,Helvetica' size='2'><b>Buyer's target market for your product(s)</b></font>
    </td>
    <td bgcolor='#eeeedd' width='70%' valign='top' aligh='left'>
      <font face='Arial,Helvetica' size='2'><%=Utils.Null2Empty(rs.getString("inquiry_sales_market"))%></font>
    </td>
  </tr>

  <tr>
    <td bgcolor='#ffffff' height='20' width='30%'  valign='top'>
      <font face='Arial,Helvetica' size='2'><b>Expected Order Quantity</b></font>
    </td>
    <td bgcolor='#ffffff' width='70%' valign='top' aligh='left'>
     <font face='Arial,Helvetica' size='2'><%=Utils.Null2Empty(rs.getString("order_quantity"))+ "&nbsp;" + Utils.Null2Empty(rs.getString("unit_of_measure")) + Utils.Null2Empty(rs.getString("select_period"))%></font>
    </td>
  </tr>
</table>

<table border=0 cellspacing=1 cellpadding=4 width='95%' align=center>
  <tr>
    <td bgcolor='#cccccc'>
      <font face='Arial,Helvetica' size='2' color='#000066'><b>Buyer Details:</b></font>
    </td>
  </tr>
</table>
<table width='95%' border='0' align='center' cellpadding='0' cellspacing='5'>
<%
    if( rs.getString("company_name")!=null)
    {
%>
    <tr valign='top'>
      <td bgcolor='#eeeedd' width='30%'>
        <font face='Arial,Helvetica' size='2'><b>Company Name</b></font>
      </td>
      <td bgcolor='#eeeedd' width='70%'>
        <font face='Arial,Helvetica' size='2'><%=rs.getString("company_name")%></font>
      </td>
    </tr>
<%
    }
    if( rs.getString("headquarters_location")!=null)
    {
%>
    <tr>
      <td bgcolor='#ffffff' width='30%'>
        <font face='Arial,Helvetica' size='2'><b>Headquarters Location:</b></font>
      </td>
      <td>
        <font face='Arial,Helvetica' size='2'><%=rs.getString("headquarters_location")%></font>
      </td>
    </tr>
<%
    }
    if( rs.getString("website")!=null)
    {
%>
    <tr>
      <td ><font face='Arial,Helvetica' size='2'><b>Website:</b></font></td>
      <td>rs.getString("website")</td>
    </tr>
<%
    }
    if(rs.getString("year_established")!=null)
    {
%>
    <tr>
      <td ><font face='Arial,Helvetica' size='2'><b>Year Established(yyyy):</b></font></td>
      <td><%=rs.getString("year_established")%></td>
    </tr>
<%
    }
    if(rs.getString("business_type")!=null)
    {
%>
    <tr>
      <td ><font face='Arial,Helvetica' size='2'><b>Business type:</b></font></td>
      <td>rs.getString("business_type")</td>
    </tr>
<%
    }
    if(rs.getString("total_staff")!=null)
    {
%>    
    <tr>
      <td ><font face='Arial,Helvetica' size='2'><b>Total Number of Employees:</b></font></td>
      <td><%=rs.getString("total_staff")%></td>
    </tr>
<%
    }
    if(rs.getString("company_information")!=null)
    {
%>
    <tr valign='top'>
      <td>Company Description:</td>
      <td class=body><%=rs.getString("company_information")%></td>
    </tr>
<%
    }
%>
</table>

<table border=0 cellspacing=1 cellpadding=4 width='95%' align=center>
  <tr>
    <td bgcolor='#cccccc'>
      <font face='Arial,Helvetica' size='2' color='#000066'><b>Please reply now to:</b></font>
    </td>
  </tr>
</table>

<table width='95%' border='0' align='center' cellpadding='0' cellspacing='5'>
  <tr>
    <td >
      <%=(rs.getString("title")==null?"Mr.":rs.getString("title")) + "&nbsp;" + rs.getString("first_name") + "&nbsp;" + rs.getString("last_name")%>
      <br>
<%
    if(rs.getString("job_title")!=null)
    {
%>
        <%=rs.getString("job_title")%><br>
<%
    }
    if(rs.getString("company_name")!=null)
    {
%>
        <%=rs.getString("company_name")%><br>
<%
    }
    if(rs.getString("address_line_1")!=null)
    {
%>
        <%=rs.getString("address_line_1")%> <br>
<%
    }
    if(rs.getString("address_line_2")!=null)
    {
%>
     <%=rs.getString("address_line_2")%> <br>
<%
    }
    if(rs.getString("address_line_3")!=null)
    {
%>
       <%=rs.getString("address_line_3")%> <br>
<%
    }
    if(rs.getString("address_postal_code")!=null)
    {
%>
    Zip/Postal Code:<%=rs.getString("address_postal_code")%><br>
<%
    }
    if(rs.getString("address_city")!=null)
    {
%>
    City:<%=rs.getString("address_city")%><br>
<%
    }
    if(rs.getString("address_state")!=null)
    {
%>
    State/Province:<%=rs.getString("address_state")%><br>
<%
    }
    if(rs.getString("address_country")!=null)
    {
%>
    Country/Territory:<%=rs.getString("address_country")%><br>
<%
    }
%>    
  <p>
  Tel: &nbsp; <%=Utils.Null2Empty(rs.getString("tel_country_code"))%>
       &nbsp; <%=Utils.Null2Empty(rs.getString("tel_area_code"))%>
       &nbsp;<%=Utils.Null2Empty(rs.getString("tel_number"))%>
       &nbsp;<%=Utils.Null2Empty(rs.getString("tel_ext_number"))%>
       <br>
  Fax: &nbsp;<%=Utils.Null2Empty(rs.getString("fax_country_code"))%>
       &nbsp;<%=Utils.Null2Empty(rs.getString("fax_area_code"))%>
       &nbsp;<%=Utils.Null2Empty(rs.getString("fax_number"))%>
      <br>
  Email:<%=rs.getString("mail_from")%><br>

    </td>
  </tr>
</table>
</body>
</html>

<%
    }
    catch (Exception ee)
    {
         throw ee;
    }
    finally
    {
        if (rs_product != null) try{ rs_product.close();}catch(Exception e){}
        if (pstmt_product != null) try{ pstmt_product.close();}catch(Exception e){}
        if (rs != null) try{ rs.close();}catch(Exception e){}
        if (pstmt != null) try{ pstmt.close();}catch(Exception e){}
        if (con != null)  try{ con.close(); }catch(Exception e){}
    }
%>