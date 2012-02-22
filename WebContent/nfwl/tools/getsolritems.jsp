<%@page import="nps.util.Utils"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.net.URL"%>
<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@page import="com.gemway.util.JUtil"%>
<%@ page import="java.io.*" %>
<%@page import="org.apache.solr.client.solrj.*"%>
<%@page import="org.apache.solr.client.solrj.impl.*"%>
<%@page import="org.apache.solr.client.solrj.response.*"%>
<%@page import="org.apache.solr.common.*"%>
<%@page import="com.nfwl.itg.product.*"%>
<%@page import=" tools.Pub"%>
<%

   try{
    
     response.setContentType("text/xml;charset=UTF-8");
     response.setCharacterEncoding("UTF-8");
     String key = request.getParameter("key");
     
     System.out.println("key = ["+key+"]");
     SolrServer solrServer = new CommonsHttpSolrServer(Pub.SOLR_URL);
     SolrQuery query = new SolrQuery();
      query.setQuery(key);
      query.setStart(0);
      query.setRows(30);
       QueryResponse rsp = solrServer.query(query);
       SolrDocumentList docs = rsp.getResults();
       ProductSolrItem pitm = null;
       PrintWriter writer = response.getWriter();
       //writer.write("alert('["+key+"]');\n");
      // writer.write("addSolrItem('aaa','bbb','ccc','ddd');");
      if(docs!=null){
        System.out.println("docs.size = "+docs.size());
      
       for (SolrDocument doc : docs) {
         
         pitm = new ProductSolrItem(doc);
         System.out.println("pitm.getTitle() = ["+pitm.getTitle()+"]");
         //writer.write("alert('["+pitm.getTitle()+"]');\n");
          //writer.write("addSolrItem('["+pitm.getTitle()+"]');\n");
         //addSolrItem(prd_name,prd_picurl,prd_url,prd_content){
         writer.write("addSolrItem('"+pitm.getId().replaceAll("article", "")+"','"+pitm.getTitle()+"','"+pitm.getPic_url()+"','"+pitm.getUrl()+"','"+pitm.getContent().replaceAll("\n", "")+"');\n");
         //writer.write("addSolrItem('"+pitm.getTitle()+"','"+pitm.getPic_url()+"','"+pitm.getUrl()+"','"+JUtil.htmlEncode(pitm.getContent())+"');\n");
         //System.out.println("addSolrItem('"+pitm.getTitle()+"','"+pitm.getPic_url()+"','"+pitm.getUrl()+"','"+pitm.getTopic()+"');\n");
         //writer.write("addSolrItem('"+pitm.getTitle()+"','"+pitm.getPic_url()+"','"+pitm.getUrl()+"','"+pitm.getContent()+"');\n");

          writer.flush();
       }
     
       }  
      writer.flush();
    }catch (Exception e){
      e.printStackTrace();
      
    }
    finally
    {
       
    }    
%>