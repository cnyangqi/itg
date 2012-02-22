<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="nps.core.*" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_articleinfo",user.GetLocale(), nps.core.Config.RES_CLASSLOADER);

    String id=request.getParameter("id");//如果为null，将在保存时使用序列生成ID号
    if(id!=null) id=id.trim();
    
    String site_id = request.getParameter("site_id");
    if(site_id!=null) site_id = site_id.trim();

    String creator = user.GetName()+"("+user.GetDeptName()+ "/" +user.GetUnitName()+")";    
    String create_date = nps.util.Utils.FormateDate(new java.util.Date(),"yyyy-MM-dd HH:mm:ss");
    
    boolean  bNew=(id==null || id.length()==0);

    NormalArticle art = null;
    NpsWrapper wrapper = null;


    if(!bNew)  //需要从数据库中加载信息
    {
        try
        {
            wrapper = new NpsWrapper(user,site_id);
            art = wrapper.GetArticle(id);
            if(art==null) throw new NpsException(ErrorHelper.SYS_NOARTICLE);
        }
        catch(Exception e)
        {
            art = null;
            if(wrapper!=null) wrapper.Clear();

            java.io.CharArrayWriter cw = new java.io.CharArrayWriter();
            java.io.PrintWriter pw = new java.io.PrintWriter(cw,true);
            e.printStackTrace(pw);
            out.println(cw.toString());
            
            return;
        }
    }  //if(!bNew)
%>

<html>
<head>
    <title><%=bNew?bundle.getString("ARTICLE_HTMLTITLE"):art.GetTitle()%></title>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <script type="text/javascript" src="/jscript/ajax_common.js"></script>
    <script type="text/javascript" src="/FCKeditor/fckeditor.js"></script>    
    <LINK href="/css/style.css" rel = stylesheet>
  
    <script language="Javascript">
      function createFCKEditor()
      {
            var oFCKeditor = new FCKeditor( 'DataFCKeditor' ) ;
            oFCKeditor.BasePath = "/FCKeditor/";
            oFCKeditor.Width = '98%' ;
            oFCKeditor.Height = '650' ;
            oFCKeditor.ToolbarSet = "Image";
            oFCKeditor.Config['ImageBrowserURL'] = '/info/selectresource.jsp?type=0&siteid=<%=Utils.Null2Empty(site_id)%>&id=<%=Utils.Null2Empty(id)%>';
            oFCKeditor.Config['LinkBrowserURL'] = '/info/selectresource.jsp?siteid=<%=Utils.Null2Empty(site_id)%>&id=<%=Utils.Null2Empty(id)%>';
            oFCKeditor.Config['FlashBrowserURL'] = '/info/selectresource.jsp?type=4&siteid=<%=Utils.Null2Empty(site_id)%>&id=<%=Utils.Null2Empty(id)%>';
            oFCKeditor.Config['MediaBrowserURL'] = '/info/selectresource.jsp?type=2&siteid=<%=Utils.Null2Empty(site_id)%>&id=<%=Utils.Null2Empty(id)%>';
          
            oFCKeditor.ReplaceTextarea() ;
      }

      function FCKeditor_OnComplete( editorInstance )
      {
            document.getElementById("pbar").style.display = 'block';
      }

      function endsWith(str, suffix)
      {
          return str.indexOf(suffix, str.length - suffix.length) !== -1;
      }

      function FCKeditor_addImage(src,title)
      {
          var oFckeditor=FCKeditorAPI.GetInstance('DataFCKeditor');
          var html = "";
          if(endsWith(src,".jpg") || endsWith(src,".gif") || endsWith(src,".bmp") || endsWith(src,".png") || endsWith(src,".jpeg") || endsWith(src,".tif"))
          {
              html = '<img src="'+src+'" alt="'+title+'"><br /><span>'+title+'</span>';
          }
          else
          {
              html = '<a href="'+src+'" target=_blank>'+title+'</a>';
          }
          oFckeditor.InsertHtml(html);
      }

      function popupDialog(url)
      {
         var isMSIE= (navigator.appName == "Microsoft Internet Explorer");

         if (isMSIE)
         {
             return window.showModalDialog(url);
         }
         else
         {
             var win = window.open(url, "mcePopup","dialog=yes,modal=yes" );             
             win.focus();
         }
     }

      function selectTopics()
      {
          var rc = popupDialog("selecttopics.jsp?isBusiness=0");
    	  if (rc == null || rc.length==0) return false;

          f_settopic(rc[0],rc[1],rc[2],rc[3]);
      }

      function f_settopic(siteid,sitename,topid,topname)
      {
          document.inputFrm.site_id.value= siteid;
    	  document.inputFrm.topic.value = topname + "(" + sitename + ")";
    	  document.inputFrm.top_id.value = topid;

          var template =  document.inputFrm.template;
          while(template.hasChildNodes()) template.removeChild(template.lastChild);
          
          template.options.add(new Option("<%=bundle.getString("TEMPLATE_HINT")%>",""));
          xmlGet('./ajaxtopictemplates.jsp?control=template&site=' + siteid + "&top=" + topid + "&callback=template_callback");
      }

      function template_callback(objName,id,text)
      {
            var ctrl = document.getElementById(objName);
            if(ctrl)  ctrl.options.add(new Option(text, id));
      }

      function addTopics()
      {
          var rc = popupDialog("selectmycompanytopics.jsp");
    	  if (rc == null || rc.length==0) return false;

          f_addslavetopic(rc[0],rc[1],rc[2],rc[3]);
      }

      var slavetopics = 0;
      function f_addslavetopic(siteid,sitename,topid,topname)
      {
            var tr_st = document.getElementById("tr_st");
        	var intRowIndex = tr_st.cells.length;
        	var tdnew=tr_st.insertCell(intRowIndex);

            for(var i=0;i<slavetopics;i++)
            {
                 var ele_topic = document.getElementById("slave_topic_"+i);
                 if(ele_topic)
                 {
                     if(topid==ele_topic.value)
                     {
                         return false;
                     }
                 }
            }

            tdnew.innerHTML= "<input type=hidden name='slave_site_" + slavetopics + "' value='" + siteid + "'>"
                           +  "<input type=hidden name='slave_topic_" + slavetopics + "' value='" + topid + "'>"
                           +  "<input type=checkbox name='slave_idx' value='" + slavetopics + "'>"
                           + topname+"("+sitename+")";
          
            slavetopics = slavetopics + 1;
      }
      
      function fill_check()
      {
        if (document.inputFrm.title.value.trim() == ""){
          alert("<%=bundle.getString("ARTICLE_ALERT_NO_TITLE")%>");
          document.inputFrm.title.focus();
          return false;		  		  
        }
        if (document.inputFrm.top_id.value == ""){
          alert("<%=bundle.getString("ARTICLE_ALERT_NO_TOPIC")%>");
          document.inputFrm.topic.focus();
          return false;
        }

        var oEditor = FCKeditorAPI.GetInstance('DataFCKeditor') ;
        if(document.inputFrm.external_url.value == ""){
            //Get the editor contents in XHTML.
            if( oEditor.GetXHTML(true) == "")
            {
                alert("<%=bundle.getString("ARTICLE_ALERT_NO_CONTENT")%>");
                return false;
            }
        }

        document.inputFrm.content.value = oEditor.GetXHTML(true);
        return true;
      }     

      function delatt(attid)
      {
        var elements_new = document.getElementsByName("new_"+attid);
        if(elements_new && elements_new.length>0)
        {
            var span = document.getElementById("row_"+attid);
            if(span!=null) span.parentNode.removeChild(span);
        }
        else
        {
             if(!fill_check()) return;
             document.inputFrm.del_att_id.value = attid;
             document.inputFrm.act.value=0;
             document.inputFrm.action='articlesave.jsp';
             document.inputFrm.target="_self";
             document.inputFrm.submit();
        }
      }
      
      function saveArticle()
      {
         if(!fill_check()) return;      
         document.inputFrm.act.value=0;
         document.inputFrm.action='articlesave.jsp';
         document.inputFrm.target="_self";
         document.inputFrm.submit();
      }
      
      function submitArticle()
      {
         if(!fill_check()) return;   
         document.inputFrm.act.value=1;
         document.inputFrm.action='articlesave.jsp';
         document.inputFrm.target="_self";
         document.inputFrm.submit();
      }

      function previewArticle()
      {
          document.inputFrm.action='articlepreview.jsp';
          document.inputFrm.target="_blank";
          document.inputFrm.submit();
      }

      function checkArticle()
      {
         if(!fill_check()) return;
         document.inputFrm.act.value=2;
         document.inputFrm.action='articlesave.jsp';
         document.inputFrm.target="_self";
         document.inputFrm.submit();
      }    

      function publishArticle()
      {
          if(!fill_check()) return;
          document.inputFrm.act.value=3;
          document.inputFrm.action='articlesave.jsp';
          document.inputFrm.target="_self";
          document.inputFrm.submit();
      }

      function timedPublish()
      {
          if(!fill_check()) return;
          document.getElementById("div_time").style.display = "block";
      }

      function submitTimedPublish()
      {
          if(!fill_check()) return;
          if (document.inputFrm.job_year.value.trim() == ""){
            alert("<%=bundle.getString("ARTICLE_ALERT_NO_YEAR")%>");
            document.inputFrm.job_year.focus();
            return;
          }
          if (document.inputFrm.job_month.value.trim() == ""){
            alert("<%=bundle.getString("ARTICLE_ALERT_NO_MONTH")%>");
            document.inputFrm.job_month.focus();
            return;
          }
          if (document.inputFrm.job_day.value.trim() == ""){
            alert("<%=bundle.getString("ARTICLE_ALERT_NO_DAY")%>");
            document.inputFrm.job_day.focus();
            return;
          }
          if (document.inputFrm.job_hour.value.trim() == ""){
            alert("<%=bundle.getString("ARTICLE_ALERT_NO_HOUR")%>");
            document.inputFrm.job_hour.focus();
            return;
          }
          if (document.inputFrm.job_minute.value.trim() == ""){
            alert("<%=bundle.getString("ARTICLE_ALERT_NO_MINUTE")%>");
            document.inputFrm.job_minute.focus();
            return;
          }
          if (document.inputFrm.job_second.value.trim() == ""){
            alert("<%=bundle.getString("ARTICLE_ALERT_NO_SECOND")%>");
            document.inputFrm.job_second.focus();
            return;
          }
          document.inputFrm.act.value=7;
          document.inputFrm.action='articlesave.jsp';
          document.inputFrm.target="_self";
          document.inputFrm.submit();
      }

      function cancelTimedPublish()
      {
          document.getElementById("div_time").style.display = "none";
      }

      function deleteArticle()
      {
        var r=confirm('<%=bundle.getString("ARTICLE_ALERT_DELETE")%>');
        if( r ==1 )
        {
          document.inputFrm.act.value=4;
          document.inputFrm.action='articlesave.jsp';
          document.inputFrm.target="_self";
          document.inputFrm.submit();
        }
      }

      function republishArticle()
      {
          if(!fill_check()) return;
          document.inputFrm.act.value=5;
          document.inputFrm.action='articlesave.jsp';
          document.inputFrm.target="_self";
          document.inputFrm.submit();
      }

      function cancelArticle()
      {
          document.inputFrm.act.value=6;
          document.inputFrm.action='articlesave.jsp';
          document.inputFrm.target="_self";
          document.inputFrm.submit();
      }

      function postArticle()
      {
          var rc = popupDialog("postremote.jsp?art_id=<%=Utils.Null2Empty(id)%>");
          return false;
      }

      function uploadimage()
      {
          var siteid = document.inputFrm.site_id.value;
          if (siteid == "")
          {
             alert("<%=bundle.getString("ARTICLE_ALERT_NO_TOPIC")%>");
             document.inputFrm.topic.focus();
             return false;
          }

          document.resFrm.siteid.value = siteid;
          document.resFrm.multiple.value = "0";
          document.resFrm.func.value = "SetImage";
          document.resFrm.action="uploadresource.jsp";
          document.resFrm.submit();
      }

      function attachimage()
      {
          var siteid = document.inputFrm.site_id.value;
          if (siteid == "")
          {
             alert("<%=bundle.getString("ARTICLE_ALERT_NO_TOPIC")%>");
             document.inputFrm.topic.focus();
             return false;
          }

          document.resFrm.siteid.value = siteid;
          document.resFrm.multiple.value = "0";
          document.resFrm.type.value = "0";
          document.resFrm.func.value = "SetImage";
          document.resFrm.action="selectresource.jsp";
          document.resFrm.submit();
      }

      function SetImage(res_id,res_name,res_url)
      {
          if(endsWith(res_url,".jpg") || endsWith(res_url,".gif") || endsWith(res_url,".bmp") || endsWith(res_url,".png") || endsWith(res_url,".jpeg") || endsWith(res_url,".tif"))
          {
              document.inputFrm.pic_url.value = res_url;
          }
          else
          {
              alert('<%=bundle.getString("ARTICLE_IMAGE_ALERT_NOT_IMAGE")%>');
          }
      }

      function attachlist()
      {
          var siteid = document.inputFrm.site_id.value;
          if (siteid == "")
          {
             alert("<%=bundle.getString("ARTICLE_ALERT_NO_TOPIC")%>");
             document.inputFrm.topic.focus();
             return false;
          }

          document.resFrm.siteid.value = siteid;
          document.resFrm.multiple.value = "1";
          document.resFrm.func.value = "AddResource";
          document.resFrm.action="selectresource.jsp";
          document.resFrm.submit();
      }

      function uploadfiles()
      {
          var siteid = document.inputFrm.site_id.value;
          if (siteid == "")
          {
             alert("<%=bundle.getString("ARTICLE_ALERT_NO_TOPIC")%>");
             document.inputFrm.topic.focus();
             return false;
          }

          document.resFrm.siteid.value = siteid;
          document.resFrm.multiple.value = "1";
          document.resFrm.func.value = "AddResource";
          document.resFrm.action="uploadresource.jsp";
          document.resFrm.submit();
      }      

      var max_index_att = 0;
      function AddResource(res_id,res_name,res_url)
      {
          max_index_att++;
          var table_fj = document.getElementById("table_fj");
          var span = document.createElement("SPAN");
          span.setAttribute("id","row_" + res_id);
          span.setAttribute("style","padding: 5px 10px;");
          span.innerHTML='&nbsp;<input type="text" name="att_idx_'+res_id+'" value="'+max_index_att+'"  style="width:20px;text-align:center;">'
                          + '<input type="hidden" name="att_id" value="' + res_id + '">'
                          + '<input type="hidden" name="new_'+res_id+'" value="">'
                          + '&nbsp;<a href="/resource/viewattach.jsp?id='+ res_id + '" target="_blank">' + res_name + '</a>'
                          + '<a href=\'javascript:FCKeditor_addImage("' + res_url + '","' + res_name + '")\' title="<%=bundle.getString("ARTICLE_HINT_ADDIMAGE")%>"><img src="/images/arrow_down.gif" border="0"></a>'
                          + '<a href="javascript:delatt(' + res_id + ')" title="<%=bundle.getString("ARTICLE_HINT_DELIMAGE")%>"><img src="/images/delete.gif" border="0"></a>';

          table_fj.appendChild(span);
      }
    </script>    
</head>

<body leftmargin=20 topmargin=0 onload="javascript:createFCKEditor();">   
<table id="pbar" border="0" class="positionbar" cellpadding="0" cellspacing="0" style="display:none">
  <tr>
    <td>&nbsp;
<%
  //发布后不能修改
  boolean bSavable = false;  //是否显示保存按钮
  boolean bSubmitable = false; //是否显示提交按钮
  boolean bCheckable = false; //是否显示审核按钮
  boolean bDeletable = false; //是否显示删除按钮
  boolean bPublishable  = false;  //是否显示发布按钮
  boolean bRepublishable = false;  //是否显示重发布按钮
  boolean bCancel  = false; //是否显示撤销按钮
  boolean bChangeable = false; //是否显示选择栏目及添加从栏目按钮
  boolean bPreview = false; //是否显示预览按钮

  if(bNew)
  {
     bSavable = true;
     bCheckable = false;
     bSubmitable = true;
     bDeletable = false;
     bPublishable = false;
     bRepublishable = false;
     bCancel = false;
     bChangeable = true;
     bPreview = false;
  }
  else
  {
     if(art!=null)
     {
         switch(art.GetState())
         {
             case 0:
                //草稿状态,只有自己能保存
                bSavable = user.GetUID().equals(art.GetCreatorID());
                bDeletable = user.GetUID().equals(art.GetCreatorID()); 
                bSubmitable = user.GetUID().equals(art.GetCreatorID());
                bCheckable = false;
                bRepublishable = false;
                bCancel = false;
                bChangeable = user.GetUID().equals(art.GetCreatorID());
                bPreview = true;
                break;
             case 1:
                //提交状态，只有版主或者站点管理员能保存
                //本单位管理员不能相互串位
                bSavable = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(site_id) || user.IsSysAdmin();

                //不能提交
                bSubmitable = false;

                //只有站点管理员、版主可以审核 
                bCheckable = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(site_id) || user.IsSysAdmin();

                //属主、站点管理员、版主可以删除文章
                bDeletable = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(site_id) || user.IsSysAdmin();

                bRepublishable = false;
                bCancel = false;

                bChangeable = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(site_id) || user.IsSysAdmin();
                bPreview = true; 
                break;
             case 2:
                //待发布，由于前后没有文章模板等导致需要重新发布
                 bSavable = false;
                 bSubmitable = false;
                 bCheckable = false;
                 bDeletable = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(site_id) || user.IsSysAdmin();
                 bPublishable = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(site_id) || user.IsSysAdmin();
                 bRepublishable = false;
                 bCancel = false;
                 bChangeable = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(site_id) || user.IsSysAdmin();
                 bPreview = true;
                 break;                 
             case 3:
                 //已发布状态
                 bSavable = false;
                 bSubmitable = false;
                 bCheckable = false;
                 bDeletable = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(site_id) || user.IsSysAdmin();
                 bRepublishable = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(site_id) || user.IsSysAdmin();
                 bCancel = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(site_id) || user.IsSysAdmin();
                 bChangeable = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(site_id) || user.IsSysAdmin();
                 bPreview = true;
                 break;
         }
     }

  }
    
  if(bSavable)
  {
%>        
      <input type="button" class="button" name="save" value="<%=bundle.getString("ARTICLE_BUTTON_SAVE")%>" onClick="saveArticle()" >
<%
  }

  if(bSubmitable)
  {
%>        
       <input type="button" class="button" name="submit" value="<%=bundle.getString("ARTICLE_BUTTON_SUBMIT")%>" onClick="submitArticle()" >
<%
  }

  if(bDeletable)
  {
%>
       <input type="button" class="button" name="submit" value="<%=bundle.getString("ARTICLE_BUTTON_DELETE")%>" onClick="deleteArticle()" >
<%
  }

  if(bCheckable) 
  {
%>        
       <input type="button" class="button" name="submit" value="<%=bundle.getString("ARTICLE_BUTTON_CHECK")%>" onClick="checkArticle()" >
       <input type="button" class="button" name="submit" value="<%=bundle.getString("ARTICLE_BUTTON_TIMED_PUBLISH")%>" onClick="timedPublish()" >
<%
  }

  if(bPublishable) 
  {
%>
       <input type="button" class="button" name="submit" value="<%=bundle.getString("ARTICLE_BUTTON_PUBLISH")%>" onClick="publishArticle()" >
<%
  }

  if(bRepublishable)
  {
%>
        <input type="button" class="button" name="submit" value="<%=bundle.getString("ARTICLE_BUTTON_REPUBLISH")%>" onClick="republishArticle()" >
<%
   }

  if(bCancel)
  {
%>
        <input type="button" class="button" name="submit" value="<%=bundle.getString("ARTICLE_BUTTON_CANCEL")%>" onClick="cancelArticle()" >    
<%
  }

  if(!bNew)
  {
%>
        <input type="button" class="button" name="submit" value="<%=bundle.getString("ARTICLE_BUTTON_POSTREMOTE")%>" onClick="postArticle()" >        
<%
  }
  
  if(bPreview)
  {
%>
    <input type="button" class="button" name="preview" value="<%=bundle.getString("ARTICLE_BUTTON_PREVIEW")%>" onClick="previewArticle()" >
<%
  }
%>
    </td>
    <td align="right">
        <%
            if(!bNew)
            {
        %>
        URL: <span style="width:320px;overflow:hidden;text-overflow:ellipsis;word-break:keep-all"><a href="<%=art.GetURL()%>" target='_blank' title="<%=art.GetURL()%>"><%=art.GetURL()%></a></span>            
        <%
            }
        %>
        &nbsp;&nbsp;
    </td>
  </tr>
</table>
<table width="100%" cellpadding="0" border="1" cellspacing="0">
    <form name="inputFrm" method="post" action="articlesave.jsp">
    <input type="hidden" name="id"  value="<%=Utils.Null2Empty(id)%>">
    <input type="hidden" name="del_att_id" value="">
    <input type="hidden" name="act" value="0">
    <input type="hidden" id="content" name="content" value="">

    <tr><td colspan="4">
    <div id="div_time" style="display:none">
        <table align="center" width="400" cellpadding="0" border="1" cellspacing="0">
            <tr height="30">
                <td align="center"><input type="text" name="job_year" maxlength="4" style="width:60px"></td>
                <td align="center"><input type="text" name="job_month" maxlength="2" style="width:30px"></td>
                <td align="center"><input type="text" name="job_day" maxlength="2" style="width:30px"></td>
                <td align="center"><input type="text" name="job_hour" maxlength="2" style="width:30px"></td>
                <td align="center"><input type="text" name="job_minute" maxlength="2" style="width:30px"></td>
                <td align="center"><input type="text" name="job_second" maxlength="2" style="width:30px"></td>
            </tr>
            <tr height="30">
                <td align="center"><font color="red"><b><%=bundle.getString("ARTICLE_JOB_YEAR")%></b></font></td>
                <td align="center"><font color="red"><b><%=bundle.getString("ARTICLE_JOB_MONTH")%></b></font></td>
                <td align="center"><font color="red"><b><%=bundle.getString("ARTICLE_JOB_DAY")%></b></font></td>
                <td align="center"><font color="red"><b><%=bundle.getString("ARTICLE_JOB_HOUR")%></b></font></td>
                <td align="center"><font color="red"><b><%=bundle.getString("ARTICLE_JOB_MINUTE")%></b></font></td>
                <td align="center"><font color="red"><b><%=bundle.getString("ARTICLE_JOB_SECOND")%></b></font></td>
            </tr>
            <tr height="30">
                <td colspan="6" align="center">
                    <input type="button" class="button" name="okbtn" value="<%=bundle.getString("ARTICLE_BUTTON_TIMED_OK")%>" onclick="submitTimedPublish()">
                    <input type="button" class="button" name="cancelbtn" value="<%=bundle.getString("ARTICLE_BUTTON_TIMED_CANCEL")%>" onclick="cancelTimedPublish()">
                </td>
            </tr>
        </table>
    </div>
    </td></tr>

    <tr>
        <td width="60" align=center><font color=red><%=bundle.getString("ARTICLE_TITLE")%></font></td>
        <td colspan="3">
          <input type="text" name="title" style="width:100%" value= "<%= (art==null || art.GetTitle()==null)?"":Utils.TransferToHtmlEntity(art.GetTitle()) %>">
        </td>
    </tr>
    <tr>
		<td width="60" align=center><%=bundle.getString("ARTICLE_SUBTITLE")%></td>
		<td  width=35%>
			<input type="text" name="subtitle"  style="width:100%" value="<%= (art==null || art.GetSubtitle()==null)?"":Utils.TransferToHtmlEntity(art.GetSubtitle()) %>">
	    </td>
	    <td width="60" align=center><%=bundle.getString("ARTICLE_ABTITLE")%></td>
	    <td>
			<input type="text" name="abtitle"  style="width:200px" value="<%= (art==null||art.GetAbtitle()==null)?"":Utils.TransferToHtmlEntity(art.GetAbtitle()) %>">
		</td>
    </tr>
      <tr>
        <td align=center><%=bundle.getString("ARTICLE_SOURCE")%></td>
        <td>
            <input type="text" name="source" value= "<%= (art==null||art.GetSource()==null)?"":Utils.TransferToHtmlEntity(art.GetSource()) %>" maxlength="100"  style="width:100%" >
        </td>

        <td width="60" align=center><%=bundle.getString("ARTICLE_AUTHOR")%></td>
        <td>
            <input type="text" name="author" value="<%= (art==null||art.GetAuthor()==null)?"":Utils.TransferToHtmlEntity(art.GetAuthor()) %>" maxlength="100">
        </td>
      </tr>
      <tr>
        <td align=center><%=bundle.getString("ARTICLE_KEYWORD")%></td>
        <td>
            <input type="text" name="keywords" style="width:100%" size="22" value="<%= (art==null||art.GetKeyword()==null)?"":Utils.TransferToHtmlEntity(art.GetKeyword()) %>">
        </td>
        <td width="60" align=center><font color=red><%=bundle.getString("ARTICLE_TOPIC")%></font></td>
        <td>
            <input type="text" name="topic" value="<%= art==null?"":art.GetTopic().GetName() %>" readonly>
  <%
     if(bChangeable)
     {
  %>
            <input type="button" value="<%=bundle.getString("ARTICLE_BUTTON_SELTOPIC")%>" class="button" name="btn_topic" onclick='javascript:selectTopics();'>
  <%
     }
  %>
            <select id="template" name="template">
                <option value=""><%=bundle.getString("TEMPLATE_HINT")%></option>
            <%
                if(!bNew && art!=null)
                {
                    Template template = art.GetTopic().GetCascadedArticleTemplate();
                    if(template!=null)
                    {
                        for(int i=0;i<3;i++)
                        {
                            String template_name = template.GetTemplateName(i);
                            if(template_name==null) continue;
            %>
                <option value="<%=i%>" <% if(String.valueOf(i).equals(art.GetCurrentTemplateNo())) out.print("selected"); %> ><%=template_name%></option>
           <%
                       }
                   }
                }
           %>
            </select>

            <input type="hidden" name="site_id" value="<%= site_id==null?"":site_id %>">
            <input type="hidden" name="top_id" value="<%= art==null?"":art.GetTopic().GetId() %>">
        </td>
      </tr>
      <tr height="30">
        <td align=center><%=bundle.getString("ARTICLE_IMPORTANT")%></td>
        <td>
          <select name="important">
            <option value="0" <% if(art!=null && art.GetImportant()==0) out.print("selected"); %> ><%=bundle.getString("ARTICLE_IMPORTANT_NORMAL")%></option>
            <option value="1" <% if(art!=null && art.GetImportant()==1) out.print("selected"); %> ><%=bundle.getString("ARTICLE_IMPORTANT_IMPORTANT")%></option>
            <option value="2" <% if(art!=null && art.GetImportant()==2) out.print("selected"); %> ><%=bundle.getString("ARTICLE_IMPORTANT_VERYIMPORTANT")%></option>
          </select>
          <%=bundle.getString("ARTICLE_VALIDAYS")%>
          <input type="text" name="validdays" value="<% if(art!=null && art.GetValiddays()!=0) out.print(art.GetValiddays()); %>" size="3">
          <%=bundle.getString("ARTICLE_VALIDAYS_HINT")%>
        </td>

        <td align="center">
              <%=bundle.getString("ARTICLE_SLAVETOPIC")%>
        </td>
        <td>
              <%
                  if(bChangeable)
                  {
              %>
                      &nbsp;&nbsp;<input type="button" name="btn_addslavetopic" class="button" onclick="javascript:addTopics()" value="<%=bundle.getString("ARTICLE_BUTTON_ADD_SLAVETOPIC")%>">
              <%
                  }
              %>
                     &nbsp;&nbsp;<font color="red"><%=bundle.getString("ARTICLE_HINT_SLAVETOPIC")%></font>
        </td>
      </tr>
      <tr>
          <td align=center><%=bundle.getString("ARTICLE_EXTERNAL_LINK")%></td>
          <td>
              <div style="padding-top:5px;padding-bottom:5px">&nbsp;<%=bundle.getString("ARTICLE_HINT_EXTERNAL_LINK")%></div>
              <input type="text" name="external_url" value= "<%= (art!=null&&art.IsExternalLink())?art.GetURL():"" %>" maxlength="500"  style="width:300px" >
          </td>

          <td colspan="2">
              <table id="table_slave_topic" width=100% height="100%" border="0" cellpadding="0" cellspacing="1">
                 <tr id="tr_st" height="25">
              <%
                  if(art!=null)
                  {
                      Hashtable slave_topics = art.GetSlaveTopics();
                      if(slave_topics!=null && slave_topics.size()>0)
                      {
                          Enumeration enum_topics = slave_topics.elements();
                          int slave_topic_index = 0;
                          while(enum_topics.hasMoreElements())
                          {
                              Topic slave_topic = (Topic)enum_topics.nextElement();

                              out.println("<td>");
                              out.println("<input type=hidden name='slave_site_" + slave_topic_index + "' value='" + slave_topic.GetSiteId() + "'>");
                              out.println("<input type=hidden name='slave_topic_" + slave_topic_index + "' value='" + slave_topic.GetId() + "'>");
                              out.println("<input type=checkbox name='slave_idx' value='" + slave_topic_index + "'>");
                              out.println(slave_topic.GetName()+"("+slave_topic.GetSite().GetName()+")");
                              out.println("</td>");

                              slave_topic_index++;
                          }

                          out.println("<script language=javascript>slavetopics=" + slave_topic_index + "</script>");
                      }
                  }
              %>
                  </tr>
               </table>
          </td>          
      </tr>


    <tr height="30">
      <td align="center">
          <%=bundle.getString("ARTICLE_IMAGE")%>
      </td>
      <td colspan="3">
          <input type="text" name="pic_url" maxlength="500"  style="width:350px" value="<%=bNew?"":Utils.Null2Empty(art.GetImageURL())%>">
          <input type="button" class="button" value="<%=bundle.getString("ARTICLE_IMAGE_UPLOAD")%>" onClick="javascript:uploadimage()" >
          <input type="button" class="button" value="<%=bundle.getString("ARTICLE_IMAGE_MEDIALIB")%>" onClick="javascript:attachimage()" >
      </td>
    </tr>

      <tr>
        <td align="center">
            <%=bundle.getString("ARTICLE_ABSTRACT")%>
        </td>
        <td colspan="3">
            <div style="padding-top:5px;padding-bottom:5px"><%=bundle.getString("ARTICLE_HINT_ABSTRACT")%></div>
            <textarea name="content_abstract" rows="3" cols="60" style="width:100%"><%=bNew?"":Utils.Null2Empty(art.GetAbstract())%></textarea>
        </td>  
      </tr>
      <tr height=30>
        <td align=center><%=bundle.getString("ARTICLE_CREATOR")%></td>
        <td><%= bNew?creator:art.GetCreatorFN()%></td>
        <td align=center><%=bundle.getString("ARTICLE_CREATEDATE")%></td>
        <td>
            <%= bNew?create_date:art.GetCreateDate()%>
        </td>
      </tr>
<%
      if(art!=null)
      {
%>      
    <tr height=30>
        <td align=center><%=bundle.getString("ARTICLE_PUBLISHDATE")%></td>
        <td>&nbsp;
            <%
                if(art.GetState()==3)
                {
                    out.print(Utils.Null2Empty(art.GetApproverCN()));
                    out.print(" ");
                    out.print(art.GetPublishDate());
                }
            %>
        </td>
        <td align=center><%=bundle.getString("ARTICLE_SCORE")%></td>
        <td>
            <%
                if(art.GetState()>0 && (bCheckable || bPublishable || bRepublishable))
                {
            %>
            &nbsp;<input type="text" name="score" value= "<%=art.GetScore()%>">
            <%
                }
                else
                {
                    out.print(art.GetScore());
                }
            %>
        </td>
      </tr>      
<%
      }
%>
    <tr>
        <td colspan=4>
            <table width=100% height="100%" border="0" cellpadding="0" cellspacing="1">
              <TBODY>
                <%
                  //发布后不能修改
                  if(bChangeable)
                  {
                %>
                      <tr height=30>
                        <td align="left">
                            &nbsp;&nbsp;
                            <input type="button" class="button" value="<%=bundle.getString("ARTICLE_BUTTON_ATTACH_FILE")%>" onClick="javascript:uploadfiles()" >
                            <input type="button" class="button" value="<%=bundle.getString("ARTICLE_BUTTON_ATTACH_LIST")%>" onClick="javascript:attachlist()" >
                            <font color="red"><%=bundle.getString("ARTICLE_HINT_ATTACH")%></font>
                        </td>
                      </tr>
                <%
                  }
                %>
                  <tr><td id="table_fj">
                <%
                 if(!bNew)
                 {
                     java.util.List attaches = art.GetAttach(null);
                     if(attaches!=null)
                     {
                         int max_att_index = 1;
                         for(Object obj:attaches)
                         {
                             Attach att = (Attach) obj;

                             out.print("<span style='padding:5px 10px;'>");
                             out.print("&nbsp;<input type='text' name='att_idx_"+att.GetId()+"' value='"+att.GetIndex()+"' style='width:20px;text-align:center;'>");
                             out.print("<input type='hidden' name='att_id' value='"+att.GetId()+"'>");
                             out.print("&nbsp;<a href='");
                             //out.print(att.GetURL());
                             out.print("/resource/viewattach.jsp?id="+att.GetID());
                             out.print("' target='_blank'>");
                             out.print(att.GetName());
                             if(att.GetSuffix()!=null) out.print(att.GetSuffix());
                             out.print("</a>");
                             if(bDeletable)
                             {
                                 out.print("<a href=\"");
                                 out.print("javascript:FCKeditor_addImage('"+ att.GetURL()+"','"+att.GetTitle()+"');");
                                 out.print("\" title="+bundle.getString("ARTICLE_HINT_ADDIMAGE") + ">");
                                 out.print("<img src='/images/arrow_down.gif' border=0>");
                                 out.print("</a>");

                                 out.print("<a href=\"");
                                 out.print("javascript:delatt('"+ att.GetID()+"');");
                                 out.print("\" title="+bundle.getString("ARTICLE_HINT_DELIMAGE") + ">");
                                 out.print("<img src='/images/delete.gif' border=0>");
                                 out.print("</a>");
                             }

                             out.println("</span>");

                             if(att.GetIndex()>max_att_index) max_att_index = att.GetIndex();
                         }

                         out.print("<script language='javascript'>max_index_att="+max_att_index+";</script>");
                     }
                 }
               %>
               </td></tr>
             </TBODY>
            </table>
        </td>
    </tr>
</form>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td>
		<div id="FCKeditor">
            <textarea id="DataFCKeditor" cols="80" rows="20"><% if(art!=null) art.GetContent(out); %></textarea>
		</div>
    </td>
  </tr>
</table>
<form name="resFrm" action="selectresource.jsp" target="_blank">
    <input type="hidden" name="multiple" value="1">
    <input type="hidden" name="func" value="">    
    <input type="hidden" name="siteid" value="<%=Utils.Null2Empty(site_id)%>">
    <input type="hidden" name="type" value="-1">
</form>
</body>
</html>

<%
    if(art!=null) art.Clear();
    if(wrapper!=null) wrapper.Clear();
%>