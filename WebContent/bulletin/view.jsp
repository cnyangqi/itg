<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="nps.core.*" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.io.Reader" %>
<%@ page import="oracle.sql.CLOB" %>
<%@ page import="oracle.jdbc.driver.OracleResultSet" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    String id = request.getParameter("id");
    if(id!=null) id = id.trim();
    if(id==null) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_bulletin",user.GetLocale(), Config.RES_CLASSLOADER);

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    try
    {
         String sql = "select a.*,b.name from bulletin a,users b Where a.creator=b.id and a.id=?";
         if(!user.IsSysAdmin())
         {
            sql += " and (a.visibility=0 \n" +
                    " Or (a.visibility=1 And Exists (Select * From dept c Where b.dept=c.Id And c.unit=?))\n" +
                    " Or (a.visibility=2 And b.dept=?))";
         }

         conn = Database.GetDatabase("nps").GetConnection();
         pstmt = conn.prepareStatement(sql);
         pstmt.setString(1,id);
         if(!user.IsSysAdmin())
         {
             pstmt.setString(2,user.GetUnitId());
             pstmt.setString(3,user.GetDeptId());
         }

         rs = pstmt.executeQuery();
         if(!rs.next()) throw new NpsException(ErrorHelper.SYS_NOARTICLE);
%>

<html>
  <head>
    <title><%=rs.getString("title")%></title>
    <LINK href="/css/style.css" rel = stylesheet>
  </head>

  <body leftmargin="20">
   <table width="90%" align="center" cellpadding = "0" cellspacing = "0" border="0">
     <tr height="40" valign="middle">
       <td align=center><span style="font-size:18px;font-weight:bold"><%=rs.getString("title")%></span></td>
     </tr>

    <tr height="25">
       <td align="center">
           <%=bundle.getString("BULLETIN_CREATOR")%>:
           <span style="font-weight:bold"><%=rs.getString("name")%></span>
           &nbsp;&nbsp;&nbsp;&nbsp;
           <%=bundle.getString("BULLETIN_CREATEDATE")%>:
           <span style="font-weight:bold">
               <%=Utils.FormateDate(rs.getTimestamp("publishdate"),"yyyy-MM-dd HH:mm:ss")%>
           </span>
       </td>
    </tr>
    <tr>
        <td><hr/></td>
    </tr>

    <tr>
       <td>
           <div>
            <%
               CLOB clob = ((OracleResultSet)rs).getCLOB("content");
               if(clob!=null)
               {
                   Reader is = null;
                   try
                   {
                       is = clob.getCharacterStream();
                       int b;
                       while((b=is.read())!=-1)
                       {
                           out.write(b);
                       }
                   }
                   finally
                   {
                       if(is!=null) try{is.close();}catch(Exception e){}
                   }
              }
            %>
           </div>
       </td>
    </tr>
   </table>
</body>
</html>
<%
    }
    finally
    {
        if(rs!=null) try{rs.close();}catch(Exception e){};
        if(pstmt!=null) try{pstmt.close();}catch(Exception e){};
        if(conn!=null) try{conn.close();}catch(Exception e){};
    }
%>