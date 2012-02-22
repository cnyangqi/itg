<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>

<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.core.Config" %>
<%@ page import="java.util.ResourceBundle" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_bulletin",user.GetLocale(), Config.RES_CLASSLOADER);

    String id = request.getParameter("id");
    String act = request.getParameter("act");
    String title = request.getParameter("title");
    String visibility = request.getParameter("visibility");
    String validdays = request.getParameter("validdays");
    String content = request.getParameter("content");

    boolean bNew = (id==null || id.length()==0);
    int iact = 0;
    try{iact = Integer.parseInt(act);}catch(Exception e){}

    Connection con   = null;
    PreparedStatement pstmt   = null;
    ResultSet rs     = null;
    String sql 		 = null;

    try
    {
        con = Database.GetDatabase("nps").GetConnection();

        switch(iact)
        {
            case 0: //保存
                if(bNew)
                {
                    id = Utils.CreateUNID();
                    sql = "insert into bulletin(id,title,validdays,visibility,creator,publishdate,content) values(?,?,?,?,?,sysdate,empty_clob())";
                    pstmt = con.prepareStatement(sql);
                    pstmt.setString(1,id);
                    pstmt.setString(2,title);
                    pstmt.setString(3,validdays);
                    pstmt.setString(4,visibility);
                    pstmt.setString(5,user.GetUID());
                    pstmt.executeUpdate();

                    try{pstmt.close();}catch(Exception e){}
                }
                else
                {
                    sql = "update bulletin set title=?,validdays=?,visibility=?,creator=?,publishdate=sysdate,content=empty_clob() where id=?";
                    if(!user.IsSysAdmin()) sql += " and creator=?";
                    pstmt = con.prepareStatement(sql);
                    pstmt.setString(1,title);
                    pstmt.setString(2,validdays);
                    pstmt.setString(3,visibility);
                    pstmt.setString(4,user.GetUID());
                    pstmt.setString(5,id);
                    if(!user.IsSysAdmin()) pstmt.setString(6,user.GetUID());
                    pstmt.executeUpdate();

                    try{pstmt.close();}catch(Exception e){}
                }

                //写入正文
                sql = "select content from bulletin where id=?";
                if(!user.IsSysAdmin()) sql += " and creator=?";
                sql += " for update";

                pstmt = con.prepareStatement(sql);
                pstmt.setString(1, id);
                if(!user.IsSysAdmin()) pstmt.setString(2,user.GetUID());
                
                rs = pstmt.executeQuery();
                if( rs.next() )
                {
                  oracle.sql.CLOB clob = ( oracle.sql.CLOB) rs.getClob(1);
                  java.io.Writer writer = clob.getCharacterOutputStream();
                  writer.write(content);
                  writer.flush();
                  try{writer.close();}catch(Exception e1){}
                }

                try{rs.close();}catch(Exception e){}
                try{pstmt.close();}catch(Exception e){}

                rs = null;
                pstmt = null;

                response.sendRedirect("edit.jsp?id="+id);
                break;

            case 1://删除
                if(bNew) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

                sql = "delete from bulletin where id=?";
                if(!user.IsSysAdmin()) sql += " and creator=?";
                pstmt = con.prepareStatement(sql);
                pstmt.setString(1,id);
                if(!user.IsSysAdmin()) pstmt.setString(2,user.GetUID());
                pstmt.executeUpdate();

                out.println(bundle.getString("BULLETIN_HINT_DELETED"));
                break;
        }
    }
    finally
    {
        if (rs != null) try{ rs.close();}catch(Exception e){}
        if (pstmt != null) try{ pstmt.close();}catch(Exception e){}
        if (con != null)  try{ con.close(); }catch(Exception e){}
    }
%>