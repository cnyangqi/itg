<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="com.fredck.FCKeditor.FCKeditor" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="nps.core.*" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Collection" %>
<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_report_by_dept",user.GetLocale(), nps.core.Config.RES_CLASSLOADER);

    String begin_date = request.getParameter("begin_date");
    if(begin_date!=null)
    {
        begin_date = begin_date.trim();
        if(begin_date.length()==0) begin_date = null;
    }

    String end_date = request.getParameter("end_date");
    if(end_date!=null)
    {
        end_date = end_date.trim();
        if(end_date.length()==0) end_date = null;
    }

    String[] siteids = request.getParameterValues("siteid");
%>

<html>
<head>
    <title><%=bundle.getString("REPORT_HTMLTITLE")%></title>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>
    <script type="text/javascript">
        function f_report()
        {
            frm_report.submit();
        }
    </script>
</head>

<body leftmargin=20 topmargin=0>
<table width = "100% " border = "0" align = "center" cellpadding = "0" cellspacing = "1" class="titlebar">
  <tr height=30>
     <td width="20">&nbsp;</td>
     <td align=center width="120"><%=bundle.getString("REPORT_DEPT")%></td>
     <td align=center  width="120"><%=bundle.getString("REPORT_COUNTER_SUBMIT")%></td>
     <td align=center  width="120"><%=bundle.getString("REPORT_COUNTER_PUBLISHED")%></td>
     <td align=center  width="120"><%=bundle.getString("REPORT_SCORE")%></td>
     <td>&nbsp;</td>
  </tr>
<%
    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    long total_submit =0;
    long total_publish =0;
    float total_scores = 0;

    try
    {
        con = Database.GetDatabase("nps").GetConnection();

        String sql = null;
        String sql_submit = null;
        String sql_pass = null;
        String whereclause = "";
        String whereclause_sub = "";
        String whereclause_submit = "";
        String whereclause_pass = "";

        sql = "Select a.Name,b.submit_rows,c.pass_rows,c.total_score From dept a,";
        sql_submit = "Select b3.id deptid,count(*) submit_rows From article b1,users b2,dept b3";
        sql_pass = "Select c3.id deptid,count(*) pass_rows,sum(score) total_score From article c1,users c2,dept c3";

        if(siteids!=null && siteids.length>0)
        {
            whereclause = " and (";
            whereclause_sub = " and (";
            for(int i=0;i<siteids.length;i++)
            {
                if(i==0)
                {
                    whereclause += " g.id='"+siteids[i]+"'";
                    whereclause_sub += " siteid='"+siteids[i]+"'";
                }
                else
                {
                    whereclause += " or g.id='"+siteids[i]+"'";
                    whereclause_sub += " or siteid='"+siteids[i]+"'";
                }
            }
            whereclause += " )";
            whereclause_sub += " )";
        }
        else
        {
            java.util.Hashtable sites = user.GetOwnSites();
            //key:id value:caption
            if((sites!=null) && !sites.isEmpty())
            {
               whereclause = " and ( ";
               whereclause_sub = " and ( ";
               int i=0;
               java.util.Enumeration sitekeys = sites.keys();
               while(sitekeys.hasMoreElements())
               {
                  String site_id = (String)sitekeys.nextElement();
                   if(i==0)
                   {
                       whereclause += " g.id='"+site_id+"'";
                       whereclause_sub += " siteid='"+site_id+"'";
                   }
                   else
                   {
                       whereclause += " or g.id='"+site_id+"'";
                       whereclause_sub += " or siteid='"+site_id+"'";
                   }

                  i++;
               }
               whereclause += " )";
               whereclause_sub += " )";
            }
        }

        whereclause_submit = whereclause_sub;
        whereclause_pass = whereclause_sub;
        if(begin_date!=null)
        {
            whereclause_submit +=" and b1.createdate>=to_date('"+begin_date+"','YYYY-MM-DD')";
            whereclause_pass +=" and c1.createdate>=to_date('"+begin_date+"','YYYY-MM-DD')";
        }
        if(end_date!=null)
        {
            whereclause_submit +=" and b1.createdate<=to_date('"+end_date+"','YYYY-MM-DD')";
            whereclause_pass +=" and c1.createdate<=to_date('"+end_date+"','YYYY-MM-DD')";
        }

        sql =   sql
              + "(" + sql_submit + " where state>=1 and b1.creator=b2.id and b2.dept=b3.id " + whereclause_submit + " group by b3.id " +") b,"
              + "(" + sql_pass + " where state>1 and c1.creator=c2.id and c2.dept=c3.id " + whereclause_pass + " group by c3.id " +") c"
              + " where a.id = b.deptid(+) And a.id=c.deptid(+) and exists(Select * From Site g Where a.unit=g.unit " + whereclause + ")"
              + " order by c.total_score,c.pass_rows,b.submit_rows";

        pstmt = con.prepareStatement(sql);
        rs = pstmt.executeQuery();

        int i = 1;
        while(rs.next())
        {
%>
          <tr  class="detailbar" height="30">
            <td align=center><%=i%></td>
            <td align=left><%=rs.getString("name")%></td>
            <td align=right><%=rs.getLong("submit_rows")%>&nbsp;&nbsp;</td>
            <td align=right><%=rs.getLong("pass_rows")%>&nbsp;&nbsp;</td>
            <td align=right><%=rs.getFloat("total_score")%>&nbsp;&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
<%
            total_submit += rs.getLong("submit_rows");
            total_publish += rs.getLong("pass_rows");
            total_scores += rs.getFloat("total_score");
            i++;
        }
    }
    finally
    {
        if(rs!=null) try{rs.close();}catch(Exception e){}
        if(pstmt!=null) try{pstmt.close();}catch(Exception e){}
        if(con!=null) try{con.close();}catch(Exception e){}
    }
%>
    <tr  class="detailbar" height="30">
      <td align=center>&nbsp;</td>
      <td align=center><b><%=bundle.getString("REPORT_SUMMARY")%></b></td>
      <td align=right><b><%=total_submit%></b> Row(s)&nbsp;&nbsp;</td>
      <td align=right><b><%=total_publish%></b> Row(s)&nbsp;&nbsp;</td>
      <td align=right><b><%=total_scores%></b>&nbsp;&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
</table>
</body>
</html>