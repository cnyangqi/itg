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
    String sqlResult = "select fp_id, fp_name, fp_address, fp_linker, fp_phone, fp_email, fp_postcode, fp_code, fp_valid, fp_registerid, fp_time from itg_fixedpoint where 1=1 ";
   try{
     con = Database.GetDatabase("nps").GetConnection();
     pstmt = con.prepareStatement(sqlResult);
     
     response.setContentType("text/xml;charset=UTF-8");
     response.setCharacterEncoding("UTF-8");
     PrintWriter writer = response.getWriter();
    
     rs = pstmt.executeQuery();
     StringBuffer sb = new StringBuffer(1024);
     while(rs.next()){
     
       //sb.append("<option value=\""+rs.getString("fp_id")+"\">"+rs.getString("fp_name")+"</option> \n");
       writer.write("addOptionfp('"+rs.getString("fp_id")+"','"+rs.getString("fp_name")+"');");
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