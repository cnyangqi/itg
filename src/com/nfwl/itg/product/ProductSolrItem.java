package com.nfwl.itg.product;

import org.apache.solr.common.SolrDocument;



import tools.Pub;


public class ProductSolrItem {

  private Float artscore ;
  private Float localprice ;
  private Float marketprice ;
  private String content; 
  private java.util.Date createdate;
  private String creator;
  private String id;
  private Integer important;
  private String pic_url;
  private java.util.Date publishdate;
  private String site;
  private String sitename;
  private String title;
  private String topic;
  private String topiccode;
  private String topicname;
  private String url;
  
  public ProductSolrItem(){
    
  }
  
  public ProductSolrItem(SolrDocument doc){
    artscore = (Float)doc.getFieldValue("artscore");
    localprice = (Float)doc.getFieldValue("localprice");
    marketprice = (Float)doc.getFieldValue("marketprice");
    url = (String)doc.getFieldValue("url");
    topicname = (String)doc.getFieldValue("topicname");
    topiccode = (String)doc.getFieldValue("topiccode");
    topic = (String)doc.getFieldValue("topic");
    title = (String)doc.getFieldValue("title");
    sitename = (String)doc.getFieldValue("sitename");
    site = (String)doc.getFieldValue("site");
    publishdate = (java.util.Date)doc.getFieldValue("publishdate");
    pic_url = (String)doc.getFieldValue("pic_url");
    important = (Integer)doc.getFieldValue("important");
    id = (String)doc.getFieldValue("id");
    creator = (String)doc.getFieldValue("creator");
    createdate = (java.util.Date)doc.getFieldValue("createdate");
    content = (String)doc.getFieldValue("content");
    
  }

  public Float getArtscore() {
    return artscore;
  }

  public void setArtscore(Float artscore) {
    this.artscore = artscore;
  }

  public String getContent() {
    return content;
  }

  public void setContent(String content) {
    this.content = content;
  }

  public java.util.Date getCreatedate() {
    return createdate;
  }

  public void setCreatedate(java.util.Date createdate) {
    this.createdate = createdate;
  }

  public String getCreator() {
    return creator;
  }

  public void setCreator(String creator) {
    this.creator = creator;
  }

  public String getId() {
    return id;
  }

  public void setId(String id) {
    this.id = id;
  }

  public Integer getImportant() {
    return important;
  }

  public void setImportant(Integer important) {
    this.important = important;
  }

  public String getPic_url() {
    return pic_url;
  }

  public void setPic_url(String pic_url) {
    this.pic_url = pic_url;
  }

  public java.util.Date getPublishdate() {
    return publishdate;
  }

  public void setPublishdate(java.util.Date publishdate) {
    this.publishdate = publishdate;
  }

  public String getSite() {
    return site;
  }

  public void setSite(String site) {
    this.site = site;
  }

  public String getSitename() {
    return sitename;
  }

  public void setSitename(String sitename) {
    this.sitename = sitename;
  }

  public String getTitle() {
    return title;
  }

  public void setTitle(String title) {
    this.title = title;
  }

  public String getTopic() {
    return topic;
  }

  public void setTopic(String topic) {
    this.topic = topic;
  }

  public String getTopiccode() {
    return topiccode;
  }

  public void setTopiccode(String topiccode) {
    this.topiccode = topiccode;
  }

  public String getTopicname() {
    return topicname;
  }

  public void setTopicname(String topicname) {
    this.topicname = topicname;
  }

  public String getUrl() {
    return url;
  }

  public void setUrl(String url) {
    this.url = url;
  }

  public Float getLocalprice() {
    return localprice;
  }

  public void setLocalprice(Float localprice) {
    this.localprice = localprice;
  }

  public Float getMarketprice() {
    return marketprice;
  }

  public void setMarketprice(Float marketprice) {
    this.marketprice = marketprice;
  }

  
}  
