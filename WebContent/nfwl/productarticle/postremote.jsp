<%@ page contentType="text/html;charset=UTF-8" language="java" errorPage="/error.jsp"%>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.exception.*" %>
<%@ page import="nps.job.atom.*" %>
<%@ page import="nps.util.Utils" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_postremote",user.GetLocale(), nps.core.Config.RES_CLASSLOADER);

    String art_id = request.getParameter("art_id");
    String res_id = request.getParameter("res_id");
    if((art_id==null || art_id.length()==0) && (res_id==null || res_id.length()==0)) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
%>

<html>
  <head>
      <title><%=bundle.getString("POST_HTMLTITLE")%></title>
      <base target='_self'>
      <LINK href="/css/style.css" rel = stylesheet>
      <style type="text/css">
          body {background-color:#e3e3c7}
          #tags { height:23px; width:400px; margin:0; padding:0; margin-left:10px;}
          #tags li { float:left; margin-right:1px; background-color:#e3e3c7; height:23px; list-style-type:none;overflow:hidden;border:1px #d5d59d solid}
          #tags li a { text-decoration:none; float:left; background-color:#e3e3c7; height:23px; padding:0px 10px; line-height:23px; color:#737357}
          #tags li.emptyTag { width:4px; background:none}
          #tags li.selectTag { font-weight:bold;background-color:#f1f1e3;background-position: left top; position:relative; height:25px; margin-bottom:-2px}
          #tags li.selectTag a { background-position: right top; color:#737357; height:25px; line-height:25px;} 
          #tagContent { padding:1px; background-color:#f1f1e3; border:1px solid #aecbd4;}
          .tagContent { padding:10px; color:#474747; width:576px; display:none}
          #tagContent div.selectTag{ display:block}
          #btn { height:23px; padding-top:10px; width:400px; text-align:right;}
      </style>

      <script type="text/javascript">
          function selectTag(showContent,selfObj)
          {
              var tag = document.getElementById("tags").getElementsByTagName("li");
              var taglength = tag.length;
              for(i=0; i<taglength; i++)
              {
                tag[i].className = "";
              }

              selfObj.parentNode.className = "selectTag";
              for(i=0; j=document.getElementById("tagContent"+i); i++)
              {
                  j.style.display = "none";
              }
              document.getElementById(showContent).style.display = "block";

              if(showContent="tagContent0")
              {
                  document.frm_post.nps_or_advance.value="0";
              }
              else
              {
                  document.frm_post.nps_or_advance.value="1";
              }
          }

          function querytopic()
          {
              var remote_host = document.frm_post.nps_host.value;
              if(remote_host=="")
              {
                  alert("<%=bundle.getString("POST_ALERT_NO_NPSHOST")%>");
                  document.frm_post.nps_host.focus();
                  return false;
              }


              var uid = document.frm_post.nps_username.value;
              if(uid=="")
              {
                  alert("<%=bundle.getString("POST_ALERT_NO_UID")%>");
                  document.frm_post.nps_username.focus();
                  return false;
              }

              var pwd = document.frm_post.nps_pwd.value;
              if(pwd=="")
              {
                  alert("<%=bundle.getString("POST_ALERT_NO_PWD")%>");
                  document.frm_post.nps_pwd.focus();
                  return false;
              }
              var nps_http = document.frm_post.nps_http.value;

              frm_topics.remote_host.value = nps_http+remote_host;
              frm_topics.uid.value = uid;
              frm_topics.pwd.value = pwd;
              frm_topics.submit();
          }

          function f_settopic(siteid,sitename,topid,topname)
          {
              document.frm_post.remote_site.value = siteid;
              document.frm_post.remote_topic.value = topid;
          }

          function show_login(auth)
          {
              if(auth=="0")
              {
                  document.getElementById("table_loginurl").style.display="none";
                  document.getElementById("table_uidpwd").style.display="none";
                  document.getElementById("table_google").style.display="none";
                  document.getElementById("vartable").style.display="none";
              }
              if(auth=="1")
              {
                  document.getElementById("vartable").style.display="none";
                  document.getElementById("table_loginurl").style.display="block";
                  document.getElementById("table_uidpwd").style.display="block";
                  document.getElementById("table_google").style.display="block";
              }
              else if(auth=="2")
              {
                  document.getElementById("vartable").style.display="none";
                  document.getElementById("table_google").style.display="none";
                  document.getElementById("table_loginurl").style.display="block";
                  document.getElementById("table_uidpwd").style.display="block";
              }
              else if(auth=="3")
              {
                  document.getElementById("table_uidpwd").style.display="none";
                  document.getElementById("table_google").style.display="none";
                  document.getElementById("table_loginurl").style.display="block";
                  document.getElementById("vartable").style.display="block";
              }
          }

          function SelectVar()
          {
            var vrownos = document.getElementsByName("vrowno");
            if(vrownos == null) return false;
            for(var i = 0; i < vrownos.length; i++)
            {
                vrownos[i].checked = document.frm.vAllId.checked;
            }
          }

          var totalVarRows =0;
          function  addVar()
          {
              var tbody = document.getElementById("vartable").getElementsByTagName("TBODY")[0];

              totalVarRows = totalVarRows+1;

              var row = document.createElement("TR");
              row.setAttribute("id","vrow_" + totalVarRows);

              var td1 = document.createElement("TD");
              var input1 = document.createElement("INPUT");
              input1.setAttribute("id","vrowno");
              input1.setAttribute("name", "vrowno");
              input1.setAttribute("type","checkbox");
              input1.setAttribute("value", totalVarRows);
              td1.appendChild(input1);
              row.appendChild(td1);

              td1 = document.createElement("TD");
              input1=document.createElement("INPUT");
              input1.setAttribute("name", "var_name");
              input1.setAttribute("type", "text");
              td1.appendChild(input1);
              row.appendChild(td1);

              td1 = document.createElement("TD");
              input1=document.createElement("INPUT");
              input1.setAttribute("name", "var_value");
              input1.setAttribute("type", "text");
              td1.appendChild(input1);
              row.appendChild(td1);

              tbody.appendChild(row);
          }

          function deleteVar()
          {
              var vrownos = document.getElementsByName("vrowno");
              if(vrownos==null) return false;

              for(var i = vrownos.length-1; i >=0 ; i--)
              {
                  if(vrownos[i].checked)
                  {
                      var row=document.getElementById("vrow_" + vrownos[i].value);
                      if(row==null) continue;
                      row.parentNode.removeChild(row);
                  }
              }
          }

          function ok()
          {
              var nps_or_advance = frm_post.nps_or_advance.value;
              if(nps_or_advance=="0")
              {
                  if(document.frm_post.nps_host.value=="")
                  {
                      alert("<%=bundle.getString("POST_ALERT_NO_NPSHOST")%>");
                      document.frm_post.nps_host.focus();
                      return false;
                  }


                  if(document.frm_post.nps_username.value=="")
                  {
                      alert("<%=bundle.getString("POST_ALERT_NO_UID")%>");
                      document.frm_post.nps_username.focus();
                      return false;
                  }

                  if(document.frm_post.nps_pwd.value=="")
                  {
                      alert("<%=bundle.getString("POST_ALERT_NO_PWD")%>");
                      document.frm_post.nps_pwd.focus();
                      return false;
                  }

                  if(document.frm_post.art_id.value!="" && document.frm_post.remote_topic.value=="")
                  {
                      alert("<%=bundle.getString("POST_ALERT_NO_TOPIC")%>");
                      return false;
                  }
              }
              else
              {
                  if(document.frm_post.adv_url.value=="")
                  {
                      alert("<%=bundle.getString("POST_ALERT_NO_ADVANCE_URL")%>");
                      document.frm_post.adv_url.focus();
                      return false;
                  }
                  var auth = document.frm_post.adv_login.value;
                  if(auth!="0")
                  {
                      if(document.frm_post.adv_loginuri.value=="")
                      {
                          alert("<%=bundle.getString("POST_ALERT_NO_ADVANCE_LOGINURL")%>");
                          document.frm_post.adv_loginuri.focus();
                          return false;
                      }
                      if(auth=="1")  //google
                      {
                          if(document.frm_post.adv_username.value="")
                          {
                              alert("<%=bundle.getString("POST_ALERT_NO_UID")%>");
                              document.frm_post.adv_username.focus();
                              return false;
                          }

                          if(document.frm_post.adv_pwd.value="")
                          {
                              alert("<%=bundle.getString("POST_ALERT_NO_PWD")%>");
                              document.frm_post.adv_pwd.focus();
                              return false;
                          }
                          if(document.frm_post.adv_google_service.value="")
                          {
                              alert("<%=bundle.getString("POST_ALERT_NO_SERVICE")%>");
                              document.frm_post.adv_google_service.focus();
                              return false;
                          }
                      }
                      else if(auth=="2")  //basic
                      {
                          if(document.frm_post.adv_username.value="")
                          {
                              alert("<%=bundle.getString("POST_ALERT_NO_UID")%>");
                              document.frm_post.adv_username.focus();
                              return false;
                          }

                          if(document.frm_post.adv_pwd.value="")
                          {
                              alert("<%=bundle.getString("POST_ALERT_NO_PWD")%>");
                              document.frm_post.adv_pwd.focus();
                              return false;
                          }
                      }
                      else if(auth=="3") //form
                      {
                          if(totalVarRows<=0)
                          {
                              alert("<%=bundle.getString("POST_ALERT_NO_FIELDS")%>");
                              return false;
                          }
                      }
                  }
              }

              document.frm_post.btn_ok.disabled = true;
              document.frm_post.submit();
          }

          function cancel()
          {
              window.close();
          }
      </script>
  </head>
  <body>
  <br>
  <h2>&nbsp;&nbsp;<%=bundle.getString("POST_TITLE_HINT")%></h2>
  <form name="frm_post" action="postremotesave.jsp" method="post">
      <input type="hidden" name="nps_or_advance" value="0">
      <input type="hidden" name="remote_site" value="">
      <input type="hidden" name="remote_topic" value="">
      <input type="hidden" name="art_id" value="<%=Utils.Null2Empty(art_id)%>">
      <input type="hidden" name="res_id" value="<%=Utils.Null2Empty(res_id)%>">

  <div id="con">
    <ul id="tags">
      <li class="selectTag"><a href="javascript:void(0)" onclick="selectTag('tagContent0',this)"><%=bundle.getString("POST_NPS")%></a></li>
      <li><a href="javascript:void(0)" onclick="selectTag('tagContent1',this)"><%=bundle.getString("POST_ADVANCE")%></a></li>
    </ul>
  </div>

  <div id="tagContent">
      <div id="tagContent0" class="tagContent selectTag">
          <table cellSpacing="0" cellPadding="0" width="100%" border="0">
              <tr height=30>
                  <td>
                      <b><%=bundle.getString("POST_NPS_HOST")%></b>
                      <select id="nps_http" name="nps_http">
                          <option value="http://">http://</option>
                          <option value="https://">https://</option>
                      </select>

                      <input type="text" id="nps_host" name="nps_host" value="" style="width:300px">
                      <span style="width:450px">
                      <%=bundle.getString("POST_NPS_HOST_HINT")%>
                      </span>
                  </td>
              </tr>
              <tr height=30>
                  <td>
                      <b><%=bundle.getString("POST_USER")%></b>
                      <input type="text" id="nps_username" name="nps_username" value="" style="width:80px">
                      <b><%=bundle.getString("POST_PASSWORD")%></b>
                      <input type="password" id="nps_pwd" name="nps_pwd" value="" style="width:80px">
                      <input type="button" class="button" name="btn_querytopic" value="<%=bundle.getString("POST_QUERYTOPICS")%>" onclick="querytopic()">
                  </td>
              </tr>
              <tr>
                  <td>
                      <iframe id="iframe_topics" name="iframe_topics" src="" frameborder="no" width="450px" height="255px"></iframe>
                  </td>
              </tr>
          </table>
      </div>
      <div id="tagContent1" class="tagContent">
          <table cellspacing="1" cellpadding="1" width="100%" border="0">
              <tr height=30>
                  <td>
                      <b><%=bundle.getString("POST_ADVANCE_URL")%></b>
                      <select id="adv_http" name="adv_http">
                          <option value="http://">http://</option>
                          <option value="https://">https://</option>
                      </select>                      
                      <input type="text" name="adv_url" style="width:300px">
                  </td>
              </tr>
              <tr height=30>
                  <td>
                      <b><%=bundle.getString("POST_ADVANCE_LOGIN")%></b>
                      <select id="adv_login" name="adv_login" onchange="show_login(this.value)">
                          <option value="0"><%=bundle.getString("POST_ADVANCE_LOGIN_NONE")%></option>
                          <option value="1"><%=bundle.getString("POST_ADVANCE_LOGIN_GOOGLE")%></option>
                          <option value="2"><%=bundle.getString("POST_ADVANCE_LOGIN_HTTPBASIC")%></option>
                          <option value="3"><%=bundle.getString("POST_ADVANCE_LOGIN_HTTPFORM")%></option>
                      </select>
                  </td>
              </tr>
           </table>
          <table id="table_loginurl" width="100%" cellpadding="1" cellspacing="1" border="0" style="display:none">
              <tr height=30>
                  <td>
                      <b><%=bundle.getString("POST_LOGIN_URL")%></b>
                      <input type="text" id="adv_loginuri" name="adv_loginuri">
                  </td>
              </tr>
          </table>

          <table id="table_uidpwd" width="100%" cellpadding="1" cellspacing="1" border="0" style="display:none">
          <tr height=30>
              <td>
                  <b><%=bundle.getString("POST_USER")%></b>
                  <input type="text" id="adv_username" name="adv_username">
              </td>
          </tr>
          <tr height=30>
              <td>
                  <b><%=bundle.getString("POST_PASSWORD")%></b>
                  <input type="password" id="adv_pwd" name="adv_pwd">
              </td>
          </tr>
          </table>

          <table id="table_google" width="100%" cellpadding="1" cellspacing="1" border="0" style="display:none">
          <tr height=30>
              <td>
                  <b><%=bundle.getString("POST_GOOGLE_SERVICE")%></b>
                  <input type="text" id="adv_google_service" name="adv_google_service">
              </td>
          </tr>
          </table>

          <table id="vartable" width="100%" cellpadding="1" cellspacing="1" border="0" style="display:none">
           <TBody>
            <tr>
                <td colspan="3">
                    <%=bundle.getString("POST_HINT_VARS")%>
                    <input type="button" class="button" value="<%=bundle.getString("POST_BUTTON_ADD_VAR")%>" onclick="addVar()">
                    <input type="button" class="button" value="<%=bundle.getString("POST_BUTTON_DEL_VAR")%>" onclick="deleteVar()">
                </td>
            </tr>
            <tr height=30 class="titlebar">
              <td width="25">
                <input type = "checkBox" name = "vAllId" value = "0" onclick = "SelectVar()">
              </td>
              <td><%=bundle.getString("POST_VAR_NAME")%></td>
              <td><%=bundle.getString("POST_VAR_VALUE")%></td>
            </tr>
           </TBody>
           </table>
      </div>
  </div>

  <div id="btn">
      <input type="button" class="button" name="btn_ok" value="<%=bundle.getString("POST_BUTTON_OK")%>" onclick="ok()">
      <input type="button" class="button" name="btn_cancel" value="<%=bundle.getString("POST_BUTTON_CANCEL")%>" onclick="cancel()">
  </div>

  </form>
  
  <form name="frm_topics" action="selectremotetopics.jsp" method="post" target="iframe_topics">
      <input type="hidden" name="remote_host">
      <input type="hidden" name="uid">
      <input type="hidden" name="pwd">
  </form>
  </body>
</html>