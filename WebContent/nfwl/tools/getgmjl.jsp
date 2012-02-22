<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.sql.*" %>
<%@ page import="nps.core.*" %>
<%@ page import="java.io.*" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Enumeration" %>
<%
    PreparedStatement pstmt   = null;
    ResultSet rs     = null;
    Connection con = null;
    String sqlResult = "select u.name,d.od_num,d.od_num*d.od_price je,o.or_time from ITG_ORDERREC o,itg_orderdetail d ,users u where o.or_status = 4 and o.or_userid = u.id and  o.or_id = d.od_orid and d.od_prdid = ?";
    
    String id = request.getParameter("spid");
if(id==null||id.trim().length()<1)return;
   try{
     con = Database.GetDatabase("nps").GetConnection();
     pstmt = con.prepareStatement(sqlResult);
     
     pstmt.setString(1, id);
     response.setContentType("text/xml;charset=UTF-8");
     response.setCharacterEncoding("UTF-8");
     PrintWriter writer = response.getWriter();
    
     rs = pstmt.executeQuery();
     StringBuffer sb = new StringBuffer(1024);
     int pos = 0;
     while(rs.next()&&pos++<20){
     
       //sb.append("<option value=\""+rs.getString("fp_id")+"\">"+rs.getString("fp_name")+"</option> \n");
       writer.write("addGmjl('"+rs.getString("name")+"','"+rs.getString("od_num")+"','"+rs.getString("je")+"','"+rs.getString("or_time")+"');");
     }
     
     //writer.write(sb.toString());
     writer.flush();
         
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