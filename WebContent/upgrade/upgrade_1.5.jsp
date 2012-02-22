<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>

<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.io.*" %>

<%@ include file="/include/header.jsp" %>

<%!
    public static void CopyFile(File src_file, File dest_file)  throws Exception
    {
        InputStream in = null;
        OutputStream out = null;
        try
        {
            in = new FileInputStream(src_file);
            out = new FileOutputStream(dest_file);
            byte[] temp = new byte[8192];
            int len = 0;
            while((len=in.read(temp,0,8192))>0)
            {
                out.write(temp,0,len);
            }

            try{in.close();}catch(Exception e){}
            try{out.close();}catch(Exception e){}
            in = null;
            out = null;
        }
        finally
        {
            if (in != null)  try{in.close();}catch(Exception e){}
            if (out != null) try{out.close();}catch(Exception e){}
        }
    }
%>
<%
    request.setCharacterEncoding("UTF-8");

    if(!user.IsSysAdmin()) throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

    out.println("Upgrade from V1.5 to V1.6...<br>");

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String sql = null;

    try
    {
        conn = Database.GetDatabase("nps").GetConnection();

        out.println("<font color=red>Creating new attachment with lowercase suffix, old attachment keep back...</font><br>");
        sql = "select a.createdate,a.id,a.caption,a.suffix,b.img_publish_dir From resources a,site b Where a.siteid=b.Id";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        int rows=0;
        int rows_warning = 0;
        int rows_update=0;
        while(rs.next())
        {
            rows++;
            String suffix = rs.getString("suffix");
            File img_file = new File(rs.getString("img_publish_dir"),
                                       Utils.FormateDate(rs.getDate("createdate"),"yyyy/MM/dd/")
                                       + rs.getString("id") + (suffix==null?"":suffix.toUpperCase())
                                     );

            if(!img_file.exists())
            {
                out.println("Warning:"+rs.getString("caption")+"("+img_file.getAbsolutePath()+") does not exist, skip...<br>");
                rows_warning++;
                continue;
            }
            File new_file = new File(rs.getString("img_publish_dir"),
                                        Utils.FormateDate(rs.getDate("createdate"),"yyyy/MM/dd/")
                                        + rs.getString("id") + (suffix==null?"":suffix)
                                     );

            CopyFile(img_file,new_file);

            rows_update++;
        }

        out.println("<font color=red>Total "+rows+" attachments, warning "+rows_warning+", "+rows_update+" created!</font><br>");
        out.println("<font color=red>Done!</font>");
        out.flush();
    }
    finally
    {
        try{rs.close();}catch(Exception e){}
        try{pstmt.close();}catch(Exception e){}
        try{conn.close();}catch(Exception e){}
    }
%>