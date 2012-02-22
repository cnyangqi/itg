<%@ page language = "java" contentType = "text/html;charset=UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.core.Config" %>
<%@ page import="nps.util.Utils" %>

<%@ include file = "/include/header.jsp" %>

<%
   request.setCharacterEncoding("UTF-8");
   ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_loadpathvt",user.GetLocale(), Config.RES_CLASSLOADER);

   String template_id = request.getParameter("id");

   Connection conn = null;
   PreparedStatement pstmt = null;
   ResultSet rs = null;
   try
   {
       conn = Database.GetDatabase("nps").GetConnection();
       String sql = "select a.*,"
                   + "(select name from site b where b.id=a.siteid) site_name,"
                   + "(select name from topic c where c.id=a.topic) topic_name"
                   + " from vt_path a where vt_id=? order by publish_date";
       pstmt = conn.prepareStatement(sql);
       pstmt.setString(1,template_id);
       rs = pstmt.executeQuery();
       if(rs.next())
       {
%>
            <table class="path_table">
                <tr>
                    <th><%=bundle.getString("LOADPATH_PUBLISHAS")%></th>
                    <th><%=bundle.getString("LOADPATH_FORMAT")%></th>
                    <th><%=bundle.getString("LOADPATH_TOPIC")%></th>
                    <th><%=bundle.getString("LOADPATH_URL")%></th>
                    <th><%=bundle.getString("LOADPATH_PUBLISHER")%></th>
                    <th><%=bundle.getString("LOADPATH_PUBLISHDATE")%></th>
                </tr>

<%
            do
            {
%>
                <tr>
                    <td>
                    <%
                        if(rs.getString("fcktemplate_id")!=null)
                        {
                            out.print(bundle.getString("LOADPATH_PUBLISHAS_FCKTEMPLATE"));
                        }
                        else if(rs.getString("template_id")!=null)
                        {
                            out.print(bundle.getString("LOADPATH_PUBLISHAS_TEMPLATE"));
                        }
                        else if(rs.getString("art_id")!=null)
                        {
                            out.print(bundle.getString("LOADPATH_PUBLISHAS_ARTICLE"));
                        }
                        else
                        {
                            out.print(bundle.getString("LOADPATH_PUBLISHAS_HTML"));
                        }
                    %>
                    </td>
                    <td><%=bundle.getString("LOADPATH_FORMAT_"+rs.getString("format").toUpperCase())%></td>
                    <td>
                        <%
                            if(rs.getString("topic_name")!=null)
                            {
                                out.print(rs.getString("topic_name"));
                                if(rs.getString("site_name")!=null)
                                {
                                    out.print("(");
                                    out.print(rs.getString("site_name"));
                                    out.print(")");
                                }
                            }
                            else if(rs.getString("site_name")!=null)
                            {
                                out.print(rs.getString("site_name"));
                            }
                        %>
                    </td>
                    <td><%=Utils.Null2Empty(rs.getString("path"))%></td>
                    <td><%=rs.getString("publisher_name")%></td>
                    <td><%=rs.getDate("publish_date")%></td>
                </tr>
<%
            }while(rs.next());
%>
            </table>

<%
       }
   }
   finally
   {
       if(rs!=null) try{rs.close();}catch(Exception e){}
       if(pstmt!=null) try{pstmt.close();}catch(Exception e){}
       if(conn!=null) try{conn.close();}catch(Exception e){}
   }
%>
