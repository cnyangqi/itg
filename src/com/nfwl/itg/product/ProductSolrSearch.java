package com.nfwl.itg.product;

import java.net.MalformedURLException;

import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.SolrQuery.ORDER;
import org.apache.solr.client.solrj.SolrServer;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.impl.CommonsHttpSolrServer;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.apache.solr.common.SolrDocument;
import org.apache.solr.common.SolrDocumentList;

import tools.Pub;

public class ProductSolrSearch {

  public static void main(String[] args) throws MalformedURLException {
    SolrServer solrServer = new CommonsHttpSolrServer(Pub.SOLR_URL);
    SolrQuery query = new SolrQuery();
    query.setSortField("name", ORDER.asc);
    query.setQuery("黄瓜");
    try {
      QueryResponse rsp = solrServer.query(query);
      SolrDocumentList docs = rsp.getResults();
      ProductSolrItem pitm = null;
      for (SolrDocument doc : docs) {
        
        pitm = new ProductSolrItem(doc);
        System.out.println(pitm.getTitle());
        System.out.println(pitm.getContent());
        System.out.println(pitm.getUrl());
      }
    } catch (SolrServerException e) {
      e.printStackTrace();
    }

  }

}
