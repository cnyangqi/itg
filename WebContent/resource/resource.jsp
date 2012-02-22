<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>

<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="nps.core.NpsWrapper" %>
<%@ page import="nps.core.Resource" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.List" %>


<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_resource",user.GetLocale(), nps.core.Config.RES_CLASSLOADER);

    String id = request.getParameter("id");
    boolean bNew = true;
    if(id!=null && id.length()>0) bNew = false;

    String siteid = request.getParameter("siteid");
    if(siteid!=null) siteid = siteid.trim();

    String creator = user.GetName()+"("+user.GetDeptName()+ "/" +user.GetUnitName()+")";
    String create_date = nps.util.Utils.FormateDate(new java.util.Date(),"yyyy-MM-dd HH:mm:ss");

    NpsWrapper wrapper = null;
    Resource res = null;
    try
    {
        if(!bNew)
        {
            wrapper = new NpsWrapper(user);
            res = new Resource(wrapper.GetContext(),id);
            if(res==null) throw new NpsException(ErrorHelper.SYS_NORESOURCE);

            if(!user.IsSysAdmin() && !res.IsAccessbile(user)) throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

            siteid = res.GetSite().GetId();
        }
%>

<html>
<head>
    <title><%=bNew?bundle.getString("RES_HTMLTITLE"):res.GetTitle()%></title>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <script type="text/javascript" src="/FCKeditor/fckeditor.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>

    <script language="Javascript">
      function createFCKEditor()
      {
            var oFCKeditor = new FCKeditor( 'DataFCKeditor' ) ;
            oFCKeditor.BasePath = "/FCKeditor/";
            oFCKeditor.Width = '98%' ;
            oFCKeditor.Height = '500' ;
            oFCKeditor.ToolbarSet = "NoImage";
            oFCKeditor.ReplaceTextarea() ;
      }

      function FCKeditor_OnComplete( editorInstance )
      {
            document.getElementById("pbar").style.display = 'block';
      }

      function fill_check()
      {
        if (document.inputFrm.title.value.trim() == ""){
          alert("<%=bundle.getString("RES_ALERT_NO_TITLE")%>");
          document.inputFrm.title.focus();
          return false;
        }
        if (document.inputFrm.siteid.value == ""){
          alert("<%=bundle.getString("RES_ALERT_NO_SITE")%>");
          document.inputFrm.siteid.focus();
          return false;
        }

<%
    if(bNew)
    {
%>
        var options_local = document.inputFrm.is_local;
        for(var i=0;i<options_local.length;i++)
        {
            if(options_local[i].checked)
            {
                if(options_local[i].value=="0")
                {
                    var oFile = document.getElementById('f');
                    if(oFile.value=="")
                    {
                        alert("<%=bundle.getString("RES_ALERT_NO_FILE")%>");
                        document.inputFrm.f.focus();
                        return false;
                    }
                    break;
                }
                else
                {
                    var url_value = document.inputFrm.url.value;
                    if(url_value=="")
                    {
                        alert("<%=bundle.getString("RES_ALERT_NO_REMOTEFILE")%>");
                        document.inputFrm.url.focus();
                        return false;
                    }
                    break;
                }
            }
        }
<%
    }
%>
          
        //Get the editor contents in XHTML.
        var oEditor = FCKeditorAPI.GetInstance('DataFCKeditor') ;
        document.inputFrm.content.value = oEditor.GetXHTML(true);
        return true;
      }

      function show_file_bar(i)
      {          
          if(i==0)
          {
              document.getElementById("div_local").style.display="block";
              document.getElementById("div_remote").style.display="none";
          }
          else
          {
              document.getElementById("div_local").style.display="none";
              document.getElementById("div_remote").style.display="block";
          }
      }

      function saveResource()
      {
         if(!fill_check()) return;
         document.inputFrm.act.value=0;
         document.inputFrm.submit();
      }

      function deleteResource()
      {
         document.inputFrm.act.value=1;
         document.inputFrm.submit();
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
      
      function addTag()
      {
          var rc = popupDialog("addtag.jsp");
    	  if (rc == null || rc.length==0) return false;

          f_addtag(rc[0]);
      }

      function f_addtag(v)
      {
          document.inputFrm.tag.value=v;          
          document.inputFrm.act.value=2;
          document.inputFrm.submit();
      }

      function publish()
      {
          var rc = popupDialog("/info/selecttopics.jsp");
    	  if (rc == null || rc.length==0) return false;

          f_settopic(rc[0],rc[1],rc[2],rc[3]);
      }

      function post()
      {
          var rc = popupDialog("/info/postremote.jsp?res_id=<%=Utils.Null2Empty(id)%>");
          return false;
      }

      function f_settopic(siteid,sitename,topid,topname)
      {
          document.inputFrm.p_site_id.value= siteid;
    	  document.inputFrm.p_top_id.value = topid;
          document.inputFrm.act.value=3;
          document.inputFrm.submit();
      }
    </script>
</head>

<body leftmargin=20 topmargin=0 onload="javascript:createFCKEditor();">
<%
    //发布后不能修改
    boolean bSavable = false;  //是否显示保存按钮
    boolean bTagable = true;  //是否显示添加标签按钮
    boolean bDeletable = false; //是否显示删除按钮
    boolean bPublishable  = true;  //是否显示发布按钮

    if(bNew)
    {
        bSavable = true;
        bTagable = false;
        bDeletable = false;
        bPublishable = false;
    }
    else if(res.IsChangable(user))
    {
        bSavable = true;
        bDeletable = true;
    }
%>
<table id="pbar" border="0" class="positionbar" cellpadding="0" cellspacing="0" style="display:none">
  <tr>
    <td>&nbsp;
<%
    if(bSavable)
    {
%>
      <input type="button" class="button" name="save" value="<%=bundle.getString("RES_BUTTON_SAVE")%>" onClick="saveResource()" >
<%
    }
    if(bDeletable)
    {
%>
      <input type="button" class="button" name="delete" value="<%=bundle.getString("RES_BUTTON_DELETE")%>" onClick="deleteResource()" >
<%
    }
    if(bTagable)
    {
%>
      <input type="button" class="button" name="btnTag" value="<%=bundle.getString("RES_BUTTON_TAG")%>" onClick="addTag()" >
<%
    }
    if(bPublishable)
    {
%>
      <input type="button" class="button" name="publish" value="<%=bundle.getString("RES_BUTTON_PUBLISH")%>" onClick="publish()" >
<%
    }
    if(!bNew)
    {
%>
        <input type="button" class="button" name="postremote" value="<%=bundle.getString("RES_BUTTON_POSTREMOTE")%>" onClick="post()" >
<%
    }
%>
    </td>
    <td align="right">
        <%
            if(!bNew)
            {
        %>
        <span style="width:450px;overflow:hidden;text-overflow:ellipsis;word-break:keep-all">URL: <a href="<%=res.GetURL()%>" target='_blank' title="<%=res.GetURL()%>"><%=res.GetURL()%></a></span>
        <%
            }
        %>
        &nbsp;&nbsp;
    </td>
  </tr>
</table>

<table width="100%" cellpadding="0" border="1" cellspacing="0">
    <form name="inputFrm" method="post" action="resourcesave.jsp" encType="multipart/form-data">
        <input type="hidden" name="act" value="0">
        <input type="hidden" name="id" value="<%=Utils.Null2Empty(id)%>">
        <input type="hidden" id="content" name="content" value="">
        <input type="hidden" name="p_site_id" value="">
        <input type="hidden" name="p_top_id" value="">
    <tr height="25">
        <td width="80" align=center><font color=red><%=bundle.getString("RES_TITLE")%></font></td>
        <td colspan="3">
          <input type="text" name="title" style="width:100%" value="<%=bNew?"":res.GetTitle()%>">
        </td>
    </tr>
    <tr height="25">
        <td width="80" align=center><font color=red><%=bundle.getString("RES_SITE")%></font></td>
        <td>
<%
    if(!bSavable)
    {
%>
        &nbsp;<%=res.GetSite().GetName()%>
        <input type="hidden" name="siteid" value="<%=res.GetSite().GetId()%>">    
<%
    }
    else
    {
        out.println("<select name=\"siteid\">");
        java.util.Hashtable site_list = null;
        if(user.IsNormalUser())
            site_list = user.GetUnitSites();
        else
            site_list = user.GetOwnSites();

        if(site_list!=null && !site_list.isEmpty())
        {
            java.util.Enumeration  site_ids = site_list.keys();
            while(site_ids.hasMoreElements())
            {
                String tmp_siteid = (String)site_ids.nextElement();
                out.print("<option value=\""+tmp_siteid+"\"");
                if(tmp_siteid.equals(siteid)) out.print(" selected");
                out.print(">");
                out.print((String)site_list.get(tmp_siteid));
                out.println("</option>");
            }
        }

        out.println("</select>");
    }
%>
        </td>
        <td width="80" align=center><%=bundle.getString("RES_SCOPE")%></td>
        <td>
              <input type="radio" name="scope" value="0" <%if(!bNew && res.GetScope()==0) out.print("checked");%>><%=bundle.getString("RES_SCOPE_GLOBAL")%>
              <input type="radio" name="scope" value="1" <% if(bNew || res.GetScope()==1) out.print("checked");%>><%=bundle.getString("RES_SCOPE_COMPNAY")%>
              <input type="radio" name="scope" value="2" <%if(!bNew && res.GetScope()==2) out.print("checked");%>><%=bundle.getString("RES_SCOPE_SITE")%>
        </td>
    </tr>
    <tr height="25">
      <td width="80" align=center><font color=red><%=bundle.getString("RES_FILE")%></font></td>
      <td colspan="3">
          <input type="radio" name="is_local" value="0" <% if(bNew || !res.IsExternalLink()) out.print("checked"); %> onclick="show_file_bar(0)"><%=bundle.getString("RES_FILE_LOCAL")%>
          <input type="radio" name="is_local" value="1" <% if(!bNew && res.IsExternalLink()) out.print("checked");%> onclick="show_file_bar(1)"><%=bundle.getString("RES_FILE_REMOTE")%>

          <br>
          <div id="div_local" style="display:<%=(bNew || !res.IsExternalLink())?"block":"none"%>">
              <%
                  if(!bNew)
                  {
                      out.print("&nbsp;<span><a href='viewattach.jsp?id="+res.GetId()+"' target=_blank>"+bundle.getString("RES_HINT_VIEWATTACH")+"</a></span>&nbsp;");
                  }

                  if(bSavable)
                  {
                      out.println("&nbsp;<input type='file' id='f' name='f' style='width:400px'>");
                  }
                  if(!bNew && res.GetType()==0)
                  {
                      String img_url = "/userdir/preview/"
                                 + Utils.FormateDate(res.GetCreateDate(),"yyyy/MM/dd/")
                                 + res.GetId() + ".jpg";
                      out.println("<div style='padding:5px 0px 10px 5px;'>");
                      out.println("<a href='viewattach.jsp?id="+res.GetId()+"' target=_blank>");
                      out.println("<img src=\"" + img_url + "\" border='0'>");
                      out.println("</a>");
                      out.println("</div>");
                  }
              %>
          </div>
          <div id="div_remote" style="display:<%=(!bNew && res.IsExternalLink())?"block":"none"%>">
              <%
                  if(!bNew && res.IsExternalLink())
                  {
                      out.print("&nbsp;<span><a href='"+res.GetURL()+"' target=_blank>"+res.GetURL()+"</a></span><br>");
                  }

                  if(bSavable)
                  {
                      out.println("&nbsp;<input type='text' id='url' name='url' style='width:400px'>");
                      out.println("<input type='checkbox' name='bdownload' value='0'>"+bundle.getString("RES_REMOTEURL_SAVE"));
                  }
              %>
          </div>
      </td>
    </tr>
    <tr height="25">
        <td width="80" align=center><%=bundle.getString("RES_TYPE")%></td>
        <td colspan="3">
            <input type="radio" name="type" value="-1" <%if(bNew) out.print("checked");%>><%=bundle.getString("RES_TYPE_AUTO")%>
            <input type="radio" name="type" value="0" <%if(!bNew && res.GetType()==0) out.print("checked");%>><%=bundle.getString("RES_TYPE_IMAGE")%>
            <input type="radio" name="type" value="1" <%if(!bNew && res.GetType()==1) out.print("checked");%>><%=bundle.getString("RES_TYPE_DOCUMENT")%>
            <input type="radio" name="type" value="2" <%if(!bNew && res.GetType()==2) out.print("checked");%>><%=bundle.getString("RES_TYPE_VIDEO")%>
            <input type="radio" name="type" value="3" <%if(!bNew && res.GetType()==3) out.print("checked");%>><%=bundle.getString("RES_TYPE_AUDIO")%>
            <input type="radio" name="type" value="4" <%if(!bNew && res.GetType()==4) out.print("checked");%>><%=bundle.getString("RES_TYPE_FLASH")%>
            <input type="radio" name="type" value="5" <%if(!bNew && res.GetType()==5) out.print("checked");%>><%=bundle.getString("RES_TYPE_OTHER")%>
        </td>
    </tr>        
    <tr height="25">
        <td width="80" align="center"><%=bundle.getString("RES_IMAGE_SCALE")%></td>
        <td colspan="3">
            &nbsp;<%=bundle.getString("RES_IMAGE_WIDTH")%>
            <input type="text" name="img_width" style="width:50px">
            <%=bundle.getString("RES_IMAGE_HEIGHT")%>
            <input type="text" name="image_height" style="width:50px">
            <%=bundle.getString("RES_IMAGE_SCLAE_HINT")%>
        </td>
    </tr>
    <tr height="25">
      <td width="80" align=center><%=bundle.getString("RES_TAG")%></td>
<%
  if(bNew)
  {
%>
      <td colspan="3">
          <div style="color:red;padding-top:5px;padding-bottom:5px">&nbsp;<%=bundle.getString("RES_HINT_TAG")%></div>
          <textarea name="tag" rows="5" cols="10" style="width:100%"></textarea>
      </td>
<%
  }
  else
  {
%>
      <td colspan="3">
        <div style='padding-left:5px;width:100%'>
          <%
            out.println(Utils.Null2Empty(res.GetTags("\r\n<br>")));
          %>
          &nbsp;
          <input type='hidden' name='tag' value=''>
        </div>
      </td>
<%
  }
%>
    </tr>

    <tr height="25">
        <td align=center>&nbsp;<%=bundle.getString("RES_CREATOR")%></td>
        <td><%=bNew?creator:res.GetCreatorCN()%></td>
        <td align=center>&nbsp;<%=bundle.getString("RES_CREATEDATE")%></td>
        <td><%=bNew?create_date:res.GetCreateDate()%></td>
    </tr>
    </form>
</table>

<%
    if(!bNew)
    {
        List<Resource.ArticleProfile> article_profiles = res.GetArticles();
        if(article_profiles!=null && !article_profiles.isEmpty())
        {
%>
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="titlebar">
    <tr height="25" colspan=3>
        <td>&nbsp;&nbsp;<%=bundle.getString("RES_HINT_ARTICLES")%></td>
    </tr>
    <%
       final int ARTICLE_PER_ROW = 3;
       int article_index = 0;
       for(Resource.ArticleProfile profile:article_profiles)
       {
           if(article_index%ARTICLE_PER_ROW==0)
           {
              out.println("<tr class=detailbar height=25>");
           }

           out.println("<td width='"+(100/ARTICLE_PER_ROW)+"%' align=left><input type=\"checkbox\" name=\"topno\" value="+profile.GetId()+">");
           out.println("<a href='/info/articleinfo.jsp?id="+profile.GetId()+"&site_id="+profile.GetSiteId()+"&top_id="+profile.GetTopicId()+"' target='_blank'>");
           out.println(profile.GetTitle() + "(" + profile.GetTopicName() + "/" + profile.GetSiteName() + ")");
           out.println("</a>");
           out.println("</td>");

           article_index++;
           if(article_index%ARTICLE_PER_ROW==0 && article_index>0)
           {
               out.println("</tr>");
           }
       }
       if(article_index%ARTICLE_PER_ROW!=0)
       {
           out.println("<td colspan="+(ARTICLE_PER_ROW-(article_index%ARTICLE_PER_ROW))+">&nbsp;</td>");
           out.println("</tr>");
       }
    %>
   </table>  
<%
    }
}
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td>
		<div id="FCKeditor">
            <textarea id="DataFCKeditor" cols="80" rows="20"><% if(!bNew) res.GetRemark(out);%></textarea>
		</div>
    </td>
  </tr>
</table>
</body>
</html>
<%
}
finally
{
    if(res!=null) res.Clear();
    if(wrapper!=null) wrapper.Clear();
}
%>