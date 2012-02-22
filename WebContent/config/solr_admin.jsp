<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.net.URL" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.List" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.exception.*" %>
<%@ page import="nps.util.*" %>
<%@ page import="org.apache.solr.client.solrj.impl.CommonsHttpSolrServer" %>
<%@ page import="org.apache.solr.client.solrj.SolrRequest" %>
<%@ page import="org.apache.solr.client.solrj.SolrQuery" %>
<%@ page import="org.apache.solr.client.solrj.response.QueryResponse" %>
<%@ page import="org.apache.solr.common.SolrDocumentList" %>
<%@ page import="org.apache.solr.common.SolrDocument" %>
<%@ page import="org.apache.solr.client.solrj.response.UpdateResponse" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.PreparedStatement" %>

<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    int rowperpage = 10;
    int currpage = 1, startnum = 0, endnum = 0, totalpages = 0, rownum=0;
    long totalrows = 0;
    String scrollstr = "", nextpage = "solr_admin.jsp";
    String currpg    = request.getParameter("page");
    try{ currpage = Integer.parseInt(currpg);	}catch (Exception e){currpage = 1;	}

    if(!user.IsSysAdmin()) throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);
    if(Config.SOLR_URL==null) throw new NpsException(ErrorHelper.INDEX_NO_FULLTEXT_INDEX);
                             
    String core = request.getParameter("core");
    String q = request.getParameter("q");
    String act = request.getParameter("act");

    if(core!=null && core.length()>0)
    {
        if(scrollstr.length()==0)
            scrollstr = "core="+core;
        else
            scrollstr += "&core="+core;
    }

    if(q!=null && q.length()>0)
    {
        if(scrollstr.length()==0)
            scrollstr = "q="+q;
        else
            scrollstr += "&q="+q;
    }

    if(act!=null && act.length()>0)
    {
        if(scrollstr.length()==0)
            scrollstr = "act="+act;
        else
            scrollstr += "&act="+act;
    }
%>
<html>
<HEAD>
    <TITLE>Solr Admin</TITLE>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>
    <style type="text/css">
        .data_table
        {
        border-collapse:collapse;
        border:solid #999;
        border-width:1px 0 0 1px;
        }
        .data_table caption {font-size:14px;font-weight:bolder;}
        .data_table th,.data_table td {border:solid #999;border-width:0 1px 1px 0;padding:2px;}
        tfoot td {text-align:center;}
    </style>
    <script type="text/javascript">
        function f_setcore(core)
        {
            document.search_form.core.value = core;
        }
        
        function f_search()
        {
            if(document.search_form.core.value.trim().length==0)
            {
                alert("Core is empty");
                return false;
            }

            document.search_form.act.value="0";
            document.search_form.submit();
        }

        function f_delete()
        {
            if(document.search_form.core.value.trim().length==0)
            {
                alert("Core is empty");
                return false;
            }

            if(document.search_form.q.value.trim().length==0)
            {
                alert("Query String is empty");
                return false;
            }

            document.search_form.act.value="1";
            document.search_form.submit();
        }
    </script>
</HEAD>
<body>

<form name="search_form" action="solr_admin.jsp" method="post">
<input type="hidden" name="act" value="0">
<table width = "100% " border = "0" cellpadding = "0" cellspacing = "0" class="PositionBar">
  <tr height=30>
    <td>&nbsp;
        <input type="button" class="button" value="Search" onclick="f_search();">
        <input type="button" class="button" value="Delete" onclick="f_delete();">
    </td>
  </tr>
  <tr height=30>
     <td>
      &nbsp;Core: <input type="text" name="core" value="<%=Utils.Null2Empty(core)%>">
      &nbsp;&nbsp;
      <%
          Connection conn = null;
          PreparedStatement pstmt = null;
          ResultSet rs = null;
          try
          {
             conn = Database.GetDatabase("nps").GetConnection();
             String sql = "select nvl(solr_core,'npscore') solr_core from site where fulltext=1\n" +
                "union \n" +
                "  select solr_core from topic where solr_enabled=2 and solr_core is not null \n" +
                "union \n" +
                "  select solr_core from topic a where solr_enabled is null and solr_core is not null\n" +
                "  and exists (select * from site b where b.id=a.siteid and b.fulltext=1)";

             pstmt = conn.prepareStatement(sql);
             rs = pstmt.executeQuery();
             while(rs.next())
             {
                 out.print("<a href=\"javascript:void(0)\" onclick=\"f_setcore('" + rs.getString("solr_core") + "')\">");
                 out.print(rs.getString("solr_core"));
                 out.println("</a>");
                 out.println("&nbsp;");
             }
          }
          catch(Exception e)
          {
              e.printStackTrace();
          }
          finally
          {
              try{rs.close();}catch(Exception e1){}
              try{pstmt.close();}catch(Exception e1){}
              try{conn.close();}catch(Exception e1){}
          }
      %>
    </td>
  </tr>
  <tr>
     <td>
      &nbsp;Query String: <font color="red">default=*:*</font>
         <textarea name="q" cols="10" rows="3" style="width:98%"><%=Utils.Null2Empty(q)%></textarea>
    </td>
  </tr>
</table>
<%
    if(core!=null && core.length()>0)
    {
        CommonsHttpSolrServer server = new CommonsHttpSolrServer(new URL(Config.SOLR_URL+"/"+core));
        if("1".equals(act))
        {
            if(q==null || q.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

            UpdateResponse rsp = server.deleteByQuery(q);
            if(rsp.getStatus()==0)
            {
                server.commit();
                out.println("<font color=red>Document(s) deleted!</font>");
            }
        }
        else
        {
            if(q==null || q.length()==0) q="*:*";

            SolrQuery query = new SolrQuery();
            query.setQuery(q);
            query.setIncludeScore(true);

            startnum = (currpage-1) * rowperpage;
            query.setStart(startnum);
            query.setRows(rowperpage);

            QueryResponse rsp = server.query(query, SolrRequest.METHOD.POST);

            SolrDocumentList sdl = rsp.getResults();
            int index = 1;

            endnum = currpage * rowperpage;
            totalrows = sdl.getNumFound();
            totalpages = (int )((totalrows - 1) / rowperpage) + 1;

            out.println("<p style='color:red;font-weight:bold'>");
            out.println(" Total " + totalrows +", start " + (startnum+1) + " of " + rowperpage);
            out.println("</p>");
            for(SolrDocument doc : sdl)
            {
                Collection<String> field_names = doc.getFieldNames();

                out.println("<p style='color:red;font-weight:bold'>");
                out.print("Rows "+ (startnum+index++));
                out.print(", score=");
                out.println(doc.getFieldValue("score"));
                out.println("</p>");
                out.println("<table width=100% border='1' cellpadding='0' cellspacing='0' class='data_table'>");
                
                //打印数据
                for(String field_name : field_names)
                {
                    if(field_name.equals("score")) continue;
                    out.println("<tr height=30>");
                    out.print("<td style='width:150px'>");
                    out.print("<b>");
                    out.print(field_name);
                    out.print("</b>");
                    Object field_value = doc.getFieldValue(field_name);

                    out.println("</td>");

                    out.print("<td>");
                    if(field_value!=null)
                    {
                        String s_field_value = Utils.TransferToHtmlEntity(field_value.toString());
                        if(s_field_value.length()<=500)
                        {
                            out.print("<div title='" + field_name + "'>");
                            out.print(s_field_value);
                            out.print("</div>");
                        }
                        else
                        {
                            out.print("<div title='" + field_name + "' style='height:80px;overflow:scroll;'>");
                            out.println(s_field_value);
                            out.println("</div>");
                        }
                    }
                    
                    out.println("</td>");
                    out.println("</tr>");
                }
                
                out.println("</table>");
            }
%>
            <%@ include file="/include/scrollpage.jsp" %>
<%
        }
    }
%>
</body>
</html>