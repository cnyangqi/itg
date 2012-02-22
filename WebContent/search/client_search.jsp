<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>

<%@ page import="org.apache.solr.client.solrj.SolrQuery" %>
<%@ page import="org.apache.solr.client.solrj.SolrServer" %>
<%@ page import="org.apache.solr.client.solrj.impl.CommonsHttpSolrServer" %>
<%@ page import="org.apache.solr.client.solrj.response.QueryResponse" %>
<%@ page import="org.apache.solr.common.SolrDocument" %>
<%@ page import="org.apache.solr.common.SolrDocumentList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="org.apache.solr.client.solrj.SolrRequest" %>

<%
	try {
		request.setCharacterEncoding("UTF-8");
		String keyword = request.getParameter("keyword");
		if(keyword == null) keyword = "is_lx_expert:1+shiny_code:hangzhou";
		String link = "client_search.jsp?keyword="+URLEncoder.encode(keyword,"UTF-8");
		String strStart = request.getParameter("start");
		int start = 0;
		if(strStart != null) start = Integer.valueOf(strStart).intValue();
		if(start < 0) start = 0;
		int rows = 15; // 每页显示数
		String url = "http://10.10.11.28:8993/npscore";

		SolrServer server = new CommonsHttpSolrServer(url);
		SolrQuery solrQuery = new SolrQuery();
		solrQuery.setQuery(keyword);
		solrQuery.setFacet(false);
		solrQuery.setStart(Integer.valueOf(start*rows));
		solrQuery.setRows(rows);
		//solrQuery.addFacetField("content");
		//设置高亮
		solrQuery.setHighlight(true);
		solrQuery.addHighlightField("title,content");
		QueryResponse rsp = server.query(solrQuery, SolrRequest.METHOD.POST);
		Map mapHt = rsp.getHighlighting(); // 获得高亮
		SolrDocumentList sdlist = rsp.getResults();
		int sum = Long.valueOf(sdlist.getNumFound()).intValue();
		int count = sdlist.size();
		int end = (sum/rows);
		if (sum%rows == 0 || (start+1)*rows == sum) end = (sum/rows)-1;
		if (start > (end+1)) response.sendRedirect(link);
		Long qtime = rsp.getElapsedTime();
		String queryTime = "";
		if(qtime < 1000)
			queryTime = "0."+qtime.intValue();
		else{
			int q1 = qtime.intValue()/1000;
			int q2 = qtime.intValue()%1000;
			queryTime = q1+"."+q2;
		}
%>
<!DOCTYPE html PUBLIC  "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="zh" xml:lang="zh" xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta http-equiv="content-type" content="text/html;charset=utf-8" />
  <title>搜索结果</title>
  <style type="text/css">
      .em{font-color:red;}
  </style>
</head>
<body>
  <div id="pageDiv">
    <!-- Body Div Start -->
    <div id="bodyDiv">
      <div id="infoDiv">
        <div id="infoHead">
          <div id="infoContent">
            <h2>约有<span><%=sum%></span>项符合“<span><%=keyword%></span>”的查询结果，
	<% if(sum != 0){ %>
		以下是第<span><%=start*rows+1%></span>-<span>
		<% if(start == end || sum < rows ){%>
			<%=sum%>
		<%}else{%>
			<%= (start+1)*rows%></span>项
		<%}%>
	<%}%>
	（搜索用时&nbsp;<span><%=queryTime%></span>&nbsp;秒）</h2>
            <div id="infoText">
			<table class="qrtable">
<%
		for (int i = 0; i < sdlist.size(); i++) {
			SolrDocument sd = sdlist.get(i);
			Map ht = (Map) mapHt.get(sd.getFieldValue("id"));
			List listHt = (List) ht.get("content");
			String htContent = "";
			if ((listHt!=null) && (listHt.size() > 0))
				htContent = listHt.get(0).toString();
			else
				htContent = sd.getFieldValue("content").toString();
			listHt = (List) ht.get("title");
			String htTitle = "";
			if ((listHt!=null) && (listHt.size() > 0))
				htTitle = listHt.get(0).toString();
			else
				htTitle = sd.getFieldValue("title").toString();
%>
				<tr>
					<td><b><a href="<%=sd.getFieldValue("url")%>"><%=htTitle%></a></b></td>
				</tr>
				<tr>
					<td><%=htContent%></td>
				</tr>
				<tr>
					<td class="mini"><a href="<%=sd.getFieldValue("url")%>"><%=sd.getFieldValue("url")%></a></td>
				</tr>
				<tr>
					<td>&nbsp;</td>
				</tr>
<% } %>
			</table>
      <br/><p>
	分页显示：第<%=start+1%>页 / 共<%=end+1%>页&nbsp;&nbsp;
	<%if (start == 0){ %>首页<%}else{%><a href="<%=link%>&start=0">首页</a><%}%>&nbsp;&nbsp;
	<%if (start == 0){ %>上一页<%}else{%><a href="<%=link%>&start=<%=start-1%>">上一页</a><%}%>&nbsp;&nbsp;
	<%if (start == end){ %>下一页<%}else{%><a href="<%=link%>&start=<%=start+1%>">下一页</a><%}%>&nbsp;&nbsp;
	<%if (start == end){ %>尾页<%}else{%><a href="<%=link%>&start=<%=end%>">尾页</a><%}%></p>
            </div>
          </div>
        </div>
      </div>
    </div>
    <!-- Body Div End -->

  </div>
</body>
</html>
<%
	} catch (Exception e) {
		e.printStackTrace();
	}
%>
