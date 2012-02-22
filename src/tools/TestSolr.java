package tools;
import java.io.File;  
import java.io.IOException;  
import java.net.MalformedURLException;

import org.apache.solr.client.solrj.SolrServer;  
import org.apache.solr.client.solrj.SolrServerException;  

import org.apache.solr.client.solrj.request.AbstractUpdateRequest;  
import org.apache.solr.client.solrj.response.QueryResponse;  
import org.apache.solr.client.solrj.SolrQuery;  
import org.apache.solr.client.solrj.impl.CommonsHttpSolrServer;  
import org.apache.solr.client.solrj.request.ContentStreamUpdateRequest;  


public class TestSolr {

  /**
   * @param args
   */
  public static void main(String[] args) {
    // TODO Auto-generated method stub
    SolrQuery query = new SolrQuery();  
    String urlString = "http://localhost:8983/solr";  
           SolrServer server = null;
          try {
            server = new CommonsHttpSolrServer(urlString);
          } catch (MalformedURLException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
          }  

            query.setQuery("npscore");  
            query.setHighlight(true).setHighlightSnippets(1);                                                     
            query.setParam("q", "黄瓜");  
      
            QueryResponse ret = null;
            try {
              ret = server.query(query);
            } catch (SolrServerException e) {
              // TODO Auto-generated catch block
              e.printStackTrace();
            }  
      
            System.out.println(ret);  

  }

}
