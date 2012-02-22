package tools;
import java.net.MalformedURLException;

import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.SolrServer;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.impl.CommonsHttpSolrServer;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.apache.solr.common.SolrDocument;
import org.apache.solr.common.SolrDocumentList;


public class SolrJSearche {

 private static final String SOLR_URL = "http://localhost:8983/solr/npscore/";

 public SolrServer getSolrServer() throws MalformedURLException {
  // 远程服务
  return new CommonsHttpSolrServer(SOLR_URL);
  // 本地服务
  // return new EmbeddedSolrServer();
 }
     
     public void SolrJSearch(){  
         try {  
          SolrServer solrServer = getSolrServer();
         } catch (MalformedURLException e) {  
             e.printStackTrace();  
         }  
     }  
       
     public void search(String String) throws MalformedURLException{  
      SolrServer solrServer = getSolrServer();
         SolrQuery query = new SolrQuery();  
         query.setQuery(String); 
         
    //新加条件（and的作用对TERM_VAL的6到8折的限制）
  //query.addFilterQuery("TERM_VAL:{6 TO 8折}");
  //排序用的  
  //query.addSortField( "price", SolrQuery.ORDER.asc );  
   //System.out.println("xxxxxxxxxxxxxx");  
         try {  
             QueryResponse rsp = solrServer.query(query);  
               
             SolrDocumentList docs = rsp.getResults();  
             System.out.println("文档个数：" + docs.getNumFound());  
             System.out.println("查询时间：" + rsp.getQTime());  
             for (SolrDocument doc : docs) {  
                 String pic_url = (String) doc.getFieldValue("pic_url");  
                 String title = (String) doc.getFieldValue("title");  
                 System.out.println(title);  
                 System.out.println(pic_url);  
                 System.out.println(doc.getFieldValue("topicname"));  
             }  
         } catch (SolrServerException e) {  
             e.printStackTrace();  
         }   
     }  
       
     public static void main(String[] args) throws MalformedURLException {  
      SolrJSearche sj = new SolrJSearche(); 
        // String Query ="name_mnecode:l*";
         String Query ="橙";
         sj.search(Query);  
     }  
 }  
