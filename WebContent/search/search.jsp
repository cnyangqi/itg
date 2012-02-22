<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.core.Config" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.net.URL" %>
<%@ page import="nps.core.Site" %>
<%@ page import="org.apache.solr.client.solrj.impl.CommonsHttpSolrServer" %>
<%@ page import="org.apache.solr.client.solrj.SolrQuery" %>
<%@ page import="org.apache.solr.client.solrj.response.QueryResponse" %>
<%@ page import="org.apache.solr.common.SolrDocumentList" %>
<%@ page import="org.apache.solr.common.SolrDocument" %>
<%@ page import="java.util.List" %>
<%@ page import="org.apache.solr.client.solrj.response.FacetField" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="org.apache.solr.client.solrj.SolrRequest" %>
<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_search",user.GetLocale(), Config.RES_CLASSLOADER);

    String keywords = request.getParameter("keywords");

    String site = request.getParameter("site");
    
    int rowperpage = 25;
    int currpage = 1, startnum = 0, endnum = 0, totalpages = 0, rownum=0;
    long totalrows = 0;
    String scrollstr = "", nextpage = "search.jsp";
    String currpg    = request.getParameter("page");
    try{ currpage = Integer.parseInt(currpg);	}catch (Exception e){currpage = 1;	}

    scrollstr += "&site="+site;
    
    if(keywords!=null)
    {
        keywords = keywords.trim();
        scrollstr += "&keywords="+keywords;
    }
%>
<html>
<HEAD>
    <TITLE><%=bundle.getString("SEARCH_HTMLTILE")%></TITLE>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>
    <script type="text/javascript">
        function f_search()
        {
            if(document.search_form.keywords.value.trim()=="")
            {
                alert("<%=bundle.getString("SEARCH_HINT_NOKEYWORD")%>");
                return false;
            }

            document.search_form.submit();
            return true;
        }
    </script>
</HEAD>
<body>

<form name="search_form" action="search.jsp" method="post">
<table width = "100% " border = "0" cellpadding = "0" cellspacing = "0" class="PositionBar">
  <tr>
     <td>
      &nbsp;<%=bundle.getString("SEARCH_HINT_KEYWORDINPUT")%>
      <input type="text" name="keywords" value="<%=Utils.Null2Empty(keywords)%>">
      <select name="site">
          <%
            java.util.Hashtable sites = user.GetOwnSites();
            if(sites==null) sites = user.GetUnitSites();
            if((sites!=null) && !sites.isEmpty())
            {
               java.util.Enumeration sitekeys = sites.keys();
               while(sitekeys.hasMoreElements())
               {
                   String site_id = (String)sitekeys.nextElement();
                   String site_caption = (String)sites.get(site_id);

                   Site asite = user.GetSite(site_id);
                   if(asite==null) continue;
                   if(!asite.IsFulltextIndex()) continue;
          %>
                   <option value='<%=site_id%>' <% if(site_id.equals(site)) out.print("selected");%>><%=site_caption%></option>
          <%
               }
            }
          %>
      </select>
      <input type="button" class="button" value="<%=bundle.getString("SEARCH_BUTTON_SEARCH")%>" onclick="javascript:f_search();">
    </td>
  </tr>
</table>    
<%
    if(keywords!=null && keywords.length()>0)
    {
        Site site_search = user.GetSite(site);
        if(Config.SOLR_URL==null || !site_search.IsFulltextIndex())
        {
            throw new NpsException(ErrorHelper.INDEX_NO_FULLTEXT_INDEX);
        }

        CommonsHttpSolrServer server = new CommonsHttpSolrServer(new URL(Config.SOLR_URL+"/"+site_search.GetSolrCore()));
        SolrQuery query = new SolrQuery();
        if(site!=null && site.length()>0)
            query.setQuery(keywords + " AND site:" + site);
        else
            query.setQuery(keywords);
        
        query.setIncludeScore(false);
        query.setHighlight(true);

        startnum = (currpage-1) * rowperpage;
        query.setStart(startnum);
        query.setRows(rowperpage);

        query.addField("id");
        query.addField("title");
        query.addField("site");
        query.addField("sitename");
        query.addField("topic");
        query.addField("topicname");
        query.addField("url");
        query.addField("publishdate");

        query.setFacet(true);
        query.setFacetMinCount(1);
        query.setFacetLimit(20);
        query.addFacetField("topicname");
        
        QueryResponse rsp = server.query(query, SolrRequest.METHOD.POST);

        //层面搜索
        out.print("<tr height=30 class=DetailBar>");
        List<FacetField> facets = rsp.getFacetFields();
        for(FacetField facet : facets)
        {
            List<FacetField.Count> facetEntries = facet.getValues();

            int i=0;
            if(facetEntries!=null)
            {
%>
        <table width = "100% " border = "0" cellpadding = "0" cellspacing = "0" class="PositionBar">
        <tr>
           <td colspan="5"><%=bundle.getString("SEARCH_HINT_TOPICS")%></td>
        </tr>
<%
                for(FacetField.Count fcount : facetEntries)
                {
                    out.print("<td width='20%' align=center>"+fcount.getName()+"("+fcount.getCount()+")"+"</td>");
                    i++;
                    if(i%5==0)
                    {
                        out.print("</tr>");
                        out.print("<tr height=30 class=DetailBar>");
                        i=0;
                    }
                }

                if(i%5!=0)
                {
                    for(int j=0;j<5-i%5;j++)
                       out.print("<td width='20%'>&nbsp;</td>");
                }

                out.print("</tr>");
            }
%>
        </table>        
<%
        }
%>

<table width = "100% " border = "0" cellpadding = "0" cellspacing = "1" class="TitleBar">
<tr height=30>
    <td width="20"></td>
    <td><%=bundle.getString("SEARCH_TITLE")%></td>
    <td><%=bundle.getString("SEARCH_SITE")%></td>
    <td><%=bundle.getString("SEARCH_TOPIC")%></td>
    <td><%=bundle.getString("SEARCH_URL")%></td>
    <td><%=bundle.getString("SEARCH_PUBLISHDATE")%></td>
</tr>
<%
        //查询结果
        SolrDocumentList sdl = rsp.getResults();
        endnum = currpage * rowperpage;
        totalrows = sdl.getNumFound();
        totalpages = (int )((totalrows - 1) / rowperpage) + 1;

        for(SolrDocument doc : sdl)
        {
            out.print("<tr height=30 class=DetailBar>");
            out.print("<td width=20></td>");
            out.print("<td>");
            String href_link = null;
            String art_id = (String)doc.getFieldValue("id");
            String site_id = (String)doc.getFieldValue("site");
            String topic_id = (String)doc.getFieldValue("topic");
            if(art_id.startsWith("article"))
            {
                art_id = art_id.substring(7);

                //普通文章
                href_link = "javascript:openArt(";
                href_link += "'"+site_id+"'";
                href_link += ",'"+topic_id+"'";
                href_link += ",'"+art_id+"'";
                href_link += ")";
            }
            else if(art_id.startsWith("custom"))
            {
                //"custom"+topic+"-"+id;
                art_id = art_id.substring("custom".length()+topic_id.length()+1);

                //自定义数据源
                href_link = "javascript:openCustomArt(";
                href_link += "'"+site_id+"'";
                href_link += ",'"+topic_id+"'";
                href_link += ",'"+art_id+"'";
                href_link += ")";
            }
            else if(art_id.startsWith("product"))
            {
                //"product"+"-"+id;
                art_id = art_id.substring(8);

                //产品
                href_link = "javascript:openProduct(";
                href_link += "'"+site_id+"'";
                href_link += ",'"+topic_id+"'";
                href_link += ",'"+art_id+"'";
                href_link += ")";
            }

            out.print("<a href=\"");
            out.print(href_link);
            out.print("\">");
            out.print(Utils.Null2Empty(doc.getFieldValue("title")));
            out.print("</a>");
            out.print("</td>");

            out.print("<td>");
            out.print(Utils.Null2Empty(doc.getFieldValue("sitename")));
            out.print("</td>");

            out.print("<td>");
            out.print(Utils.Null2Empty(doc.getFieldValue("topicname")));
            out.print("</td>");

            out.print("<td>");
            out.print(Utils.Null2Empty(doc.getFieldValue("url")));
            out.print("</td>");

            out.print("<td>");
            if(doc.getFieldValue("publishdate")!=null)
               out.print(Utils.FormateDate((java.util.Date)doc.getFieldValue("publishdate"),"yyyy-MM-dd"));
            out.print("</td>");
            out.print("</tr>");
        }
    }
%>
</table>
</form>
<%@ include file="/include/scrollpage.jsp" %>

<form name=frmOpen action="/info/articleinfo.jsp" target="_blank">
  <input type = "hidden" name = "id">
  <input type = "hidden" name = "site_id">
  <input type="hidden" name="top_id">
</form>
<script language="JavaScript" type="text/JavaScript">
  function openArt(siteid,topid,idvalue){
    document.frmOpen.id.value = idvalue;
    document.frmOpen.site_id.value = siteid;
    document.frmOpen.top_id.value = topid;
    document.frmOpen.action="/info/articleinfo.jsp";
    document.frmOpen.submit();
  }
  function openCustomArt(siteid,topid,idvalue){
      document.frmOpen.id.value = idvalue;
      document.frmOpen.site_id.value = siteid;
      document.frmOpen.top_id.value = topid;
      document.frmOpen.action = "/info/customartinfo.jsp";
      document.frmOpen.submit();
  }
  function openProduct(siteid,topid,idvalue){
      document.frmOpen.id.value = idvalue;
      document.frmOpen.site_id.value = siteid;
      document.frmOpen.top_id.value = topid;
      document.frmOpen.action = "/extra/product/productinfo.jsp";
      document.frmOpen.submit();      
  }
</script>
</body>
</html>
