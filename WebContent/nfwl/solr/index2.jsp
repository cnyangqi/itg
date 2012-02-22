<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@page import="org.apache.solr.client.solrj.SolrQuery"%>   
<%@page import="java.util.Map"%>   
<%@page import="java.util.Set"%>   
<%@page import="java.util.Iterator"%>   
<%@page import="org.apache.solr.client.solrj.SolrServer"%>   
<%@page import="org.apache.solr.client.solrj.impl.CommonsHttpSolrServer"%>   
<%@page import="org.apache.solr.client.solrj.response.QueryResponse"%>   
<%@page import="org.apache.solr.common.SolrDocumentList"%>   
<%@page import="java.util.List"%>   
<%@page import="org.apache.solr.client.solrj.response.FacetField"%>   
<%@page import="org.apache.solr.common.SolrDocument"%><html>   
<head>   
    <title>Solr Example 1 - Searching Data</title>   
</head>   
<body>   
    <h1>Searching Data on the Solr Index</h1>   
  
<%   
try{
    SolrQuery solrQuery = new SolrQuery();   
    solrQuery.setFacet(true);   
    solrQuery.setFacetMinCount(1);   
    solrQuery.setRows(new Integer(5));   
    solrQuery.setStart(new Integer(0));   
    solrQuery.addFacetField("q");   
  
  
    // here I am definitely cheating!   
    solrQuery.setQuery("test");   
    //   solrQuery.set("title","test");
    Map parameterMap = request.getParameterMap();   
    Set keySet = parameterMap.keySet();   
    Iterator parameterMapIterator = keySet.iterator();   
    while(parameterMapIterator.hasNext()) {   
        String key = (String)parameterMapIterator.next();   
        String[] values = (String[])parameterMap.get(key);   
  
    }   
  
    SolrServer solrServer = new CommonsHttpSolrServer("http://localhost:8983/solr/npscore/");   
       //[npscore] webapp=/solr path=/select/ params={indent=on&start=0&q=test&rows=10&version=2.2} hits=1 status=0 QTime=15 
    QueryResponse queryResponse = solrServer.query(solrQuery);   
    pageContext.setAttribute("queryResponse", queryResponse);   
%>   
  
<h2>Returned QueryResponse Header</h2>   
  
<p><%=((QueryResponse)pageContext.getAttribute("queryResponse")).getHeader()%></p>   
  
<h2>Search Results Metadata</h2>   
  
<ul>   
    <li>Elapsed Time:<%=((QueryResponse)pageContext.getAttribute("queryResponse")).getElapsedTime() %></li>   
    <li>Query Time:<%=((QueryResponse)pageContext.getAttribute("queryResponse")).getQTime() %></li>   
    <li>Number Of Results:<%=((SolrDocumentList)((QueryResponse)pageContext.getAttribute("queryResponse")).getResponse().get("response")).getNumFound()%></li>   
</ul>   
  
<h2>Facets</h2>   
  
<ul>   
<%   
    List<FacetField> facetFields = ((QueryResponse)pageContext.getAttribute("queryResponse")).getFacetFields();   
  
    Iterator<FacetField> facetFieldIterator = facetFields.iterator();   
       
    while(facetFieldIterator.hasNext()) {   
        FacetField facetField = facetFieldIterator.next();   
        out.print("<li>" + facetField.getName());   
           
        out.print("<ul>");   
        List<FacetField.Count> facetFieldCounts = facetField.getValues();   
        Iterator<FacetField.Count> facetFieldCountIterator = facetFieldCounts.iterator();   
  
        boolean hasQueryString = false;   
        while(facetFieldCountIterator.hasNext()) {   
            FacetField.Count count = facetFieldCountIterator.next();   
            StringBuffer stringBuffer = new StringBuffer("?");   
  
            if(request.getQueryString() != null) {   
                stringBuffer.append(request.getQueryString());   
                hasQueryString = true;   
            }   
               
            if(hasQueryString) {   
                stringBuffer.append("&");   
            }   
               
            stringBuffer.append(facetField.getName() + "=" + count.getName());   
               
            // if we alread have a parameter - remove it   
            String removeLink = null;   
            if(null != request.getQueryString()) {   
                removeLink = request.getRequestURI() + "?" + request.getQueryString();   
                removeLink = removeLink.replaceAll(facetField.getName() + "=" + count.getName(), "");   
            }   
               
            if(null != request.getQueryString() && request.getQueryString().contains(facetField.getName() + "=" + count.getName())) {   
                out.print("<li>" + count.getName() + "(" + count.getCount() + ")<a href=\"" + removeLink + "\">(remove)</a></li>");   
            } else {   
                out.print("<li><a href=\"" + request.getRequestURI() + stringBuffer.toString() + "\">" + count.getName() + "(" + count.getCount() + ")</a></li>");   
            }   
               
        }   
        out.print("</ul></li>");   
    }   
%>   
</ul>   
  
<h2>Results</h2>   
<ul>   
  
<%   
    SolrDocumentList solrDocumentList = ((QueryResponse)pageContext.getAttribute("queryResponse")).getResults();   
  
    Iterator<SolrDocument> solrDocumentIterator =  solrDocumentList.iterator();   
    while(solrDocumentIterator.hasNext()) {   
  
  
  
  
  
        out.print("<li>" + solrDocumentIterator.next() + "</li>");   
  
  
    }   
}catch(Exception e){
  out.println(e.getMessage());
}
%>   
</ul>   
</body>   
</html>  
