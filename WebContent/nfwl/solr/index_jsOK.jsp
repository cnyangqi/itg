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
<%@page import="org.apache.solr.common.SolrDocument"%>
<script type="text/javascript">
<!--
function xmlhttpPost(strURL) {
  var xmlHttpReq = false;
  var self = this;
  if (window.XMLHttpRequest) { // Mozilla/Safari
      self.xmlHttpReq = new XMLHttpRequest(); 
  }
  else if (window.ActiveXObject) { // IE
      self.xmlHttpReq = new ActiveXObject("Microsoft.XMLHTTP");
  }
  
  var params = getstandardargs().concat(getquerystring());
  var strData = params.join('&');
  
  var header = document.getElementById("response");
  header.innerHTML = strURL+'?'+strData;

  self.xmlHttpReq.open('get', strURL+'?'+strData+'&time='+new Date().getTime(), true);
  self.xmlHttpReq.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
  self.xmlHttpReq.onreadystatechange = function() {
      if (self.xmlHttpReq.readyState == 4) {
          updatepage(self.xmlHttpReq.responseText);
      }
  }
  self.xmlHttpReq.send(null);
}

function getstandardargs() {
  var params = [
      'wt=json'
      , 'indent=on'
      , 'hl=true'
      , 'hl.fl='
      , 'fl=*,score'
      , 'start=0'
      , 'rows=10'
      ];

  return params;
}
function getquerystring() {
var form = document.forms['f1'];
var query = form.q.value;
qstr = 'q=' + encodeURI(query);    //escape
return qstr;
}

//this function does all the work of parsing the solr response and updating the page.
function updatepage(str){
//document.getElementById("response").innerHTML = str;
var rsp = eval("("+str+")"); // use eval to parse Solr's JSON response
parse(rsp);
}

function parse(j) {
  var header = document.getElementById("header");
  var rh = j.responseHeader;
  var header_str = " 搜索: \""+rh.params.q+"\", 花了: "+rh.QTime+"ms, 共显示: "+j.response.numFound+"条记录, 总共有: "+rh.params.rows;
  header.innerHTML = header_str;
  var docs = j.response.docs;
  var tab = document.getElementById("docs");
  for(; tab.rows.length >1; ) {
      tab.deleteRow(-1);
  }
  var tr;
  var td;
  for(var i=0; i<docs.length; i++) {
      tr = tab.insertRow(-1);
      td = tr.insertCell(-1);
      td.innerHTML = docs[i].title;
      
      td = tr.insertCell(-1);
      td.innerHTML = docs[i].subtitle;
      
      td = tr.insertCell(-1);
      td.innerHTML = docs[i].topicname;
      
      td = tr.insertCell(-1);
      td.innerHTML = docs[i].url;
  }
 }
//-->
</script>

<body>
<form action="select/" name="f1" method="get" onsubmit="xmlhttpPost('http://localhost:8983/solr/npscore/select'); return false;" >
      Chenlb: 
      <input type="text" name="q" size="80" value="图片">
      <input name="start" type="hidden" value="0">
    <input name="rows" type="hidden" value="10">
    <input name="indent" type="hidden" value="on">
    <input name="wt" type="hidden" value="">
      <input type="button" value=" 搜 索 " onclick="xmlhttpPost('http://localhost:8983/solr/npscore/select');">
      <input type="button" value=" get json " onclick="document.forms['f1'].wt.value='json';document.forms['f1'].submit();">
      <input type="button" value=" get xml " onclick="document.forms['f1'].wt.value='';document.forms['f1'].submit();">
  </form>
  <div style="background-color: #ccccff; height: 15px;"></div>
  <p>
    <div id="header"></div>
    <div id="response"></div>
    <table id="docs" class="tab" cellspacing="1">
        <tr height="25" style="background-color: #cccccc; color: #0000ff;">
            <td>作者</td>
            <td>简介</td>
            <td>标题</td>
            <td>score</td>
        </tr>
    </table>
</body>    