<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="nps.core.*" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_linkinfo",user.GetLocale(), nps.core.Config.RES_CLASSLOADER);

    String id=request.getParameter("id");//如果为null，将在保存时使用序列生成ID号
    if(id!=null) id=id.trim();

    boolean  bNew=(id==null || id.length()==0);

    String site_id = null;
    String top_id = null;
    if(bNew)
    {
        site_id=request.getParameter("site_id");
        if(site_id==null || site_id.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

        top_id=request.getParameter("top_id");
        if(top_id==null || top_id.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    }

    String creator = user.GetName()+"("+user.GetDeptName()+ "/" +user.GetUnitName()+")";
    String create_date = nps.util.Utils.FormateDate(new java.util.Date(),"yyyy-MM-dd HH:mm:ss");


    ArticleRefer art = null;
    NpsWrapper wrapper = null;
    Topic topic = null;

    try
    {
        wrapper = new NpsWrapper(user);
        if(!bNew)  //需要从数据库中加载信息
        {
            art = ArticleRefer.GetArticle(wrapper.GetContext(),id);
            if(art==null) throw new NpsException(ErrorHelper.SYS_NOARTICLE);

            topic = art.GetTopic();
            site_id = topic.GetSiteId();
            top_id = topic.GetId();
        }
        else
        {
            Site site = wrapper.GetSite(site_id);
            topic = site.GetTopicTree().GetTopic(top_id);
            if(topic==null) throw new NpsException(top_id,ErrorHelper.SYS_NOTOPIC);
            if(!topic.IsSortEnabled()) throw new NpsException(top_id,ErrorHelper.SYS_TOPIC_NOTSORTABLE);
        }
    }
    catch(Exception e)
    {
        art = null;

        java.io.CharArrayWriter cw = new java.io.CharArrayWriter();
        java.io.PrintWriter pw = new java.io.PrintWriter(cw,true);
        e.printStackTrace(pw);
        out.println(cw.toString());

        return;
    }
    finally
    {
        if(wrapper!=null) wrapper.Clear();
    }
%>

<html>
<head>
    <title><%=bNew?bundle.getString("LINK_HTMLTITLE"):art.GetTitle()%></title>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>

    <script language="Javascript">
      function fill_check()
      {
        if (document.inputFrm.title.value.trim() == ""){
          alert("<%=bundle.getString("LINK_ALERT_NO_TITLE")%>");
          document.inputFrm.title.focus();
          return false;
        }
        if (document.inputFrm.url.value == ""){
          alert("<%=bundle.getString("LINK_ALERT_NO_URL")%>");
          document.inputFrm.url.focus();
          return false;
        }

        return true;
      }

      function saveArticle()
      {
         if(!fill_check()) return;
         document.inputFrm.act.value=0;
         document.inputFrm.action='linksave.jsp';
         document.inputFrm.target="_self";
         document.inputFrm.submit();
      }

      function deleteArticle()
      {
        var r=confirm('<%=bundle.getString("LINK_ALERT_DELETE")%>');
        if( r ==1 )
        {
          document.inputFrm.act.value=1;
          document.inputFrm.action='linksave.jsp';
          document.inputFrm.target="_self";
          document.inputFrm.submit();
        }
      }

      function attachlist()
      {
          document.resFrm.action="/info/selectresource.jsp";
          document.resFrm.submit();
      }

      function uploadfiles()
      {
          document.resFrm.action="/info/uploadresource.jsp";
          document.resFrm.submit();
      }

      function SetUrl( url, width, height, alt)
      {
          document.inputFrm.img_url.value = url;
          var img_preview = document.getElementById("image_preview");
          if(img_preview)
          {
              img_preview.src = url;
              img_preview.style.display = "block";
          }
      }

      function AddResource(res_id,res_name,res_url)
      {
          document.inputFrm.img_url.value = res_url;
          var img_preview = document.getElementById("image_preview");
          if(img_preview)
          {
              img_preview.src = res_url;
              img_preview.style.display = "block";
          }
      }

      function title_preview(title)
      {
         document.getElementById('title_preview').innerHTML=title; 
      }
    </script>
</head>

<body leftmargin=20 topmargin=0>
<table width=100% border="0" class="positionbar" cellpadding="0" cellspacing="0">
  <tr>
    <td>&nbsp;
<%
  //发布后不能修改
  boolean bSavable = false;  //是否显示保存按钮
  boolean bDeletable = false; //是否显示删除按钮

  if(bNew)
  {
     bSavable = true;
     bDeletable = false;
  }
  else
  {
      bSavable = true;
      bDeletable = true;
  }

  if(bSavable)
  {
%>
      <input type="button" class="button" name="save" value="<%=bundle.getString("LINK_BUTTON_SAVE")%>" onClick="saveArticle()" >
<%
  }

  if(bDeletable)
  {
%>
       <input type="button" class="button" name="submit" value="<%=bundle.getString("LINK_BUTTON_DELETE")%>" onClick="deleteArticle()" >
<%
  }
%>
    </td>
    <td style="float:right;padding-left:50px;padding-right:10px;">
        Preview: <span id="title_preview" style="width:400px;overflow:hidden;text-overflow:ellipsis;word-break:keep-all"><%=art==null?"":art.GetTitle()%></span>
    </td>
  </tr>
</table>
<table width="100%" cellpadding="0" border="1" cellspacing="0">
    <form name="inputFrm" method="post" action="linksave.jsp">
    <input type="hidden" name="site_id" value="<%=site_id%>">
    <input type="hidden" name="top_id" value="<%=top_id%>">
    <input type="hidden" name="id"  value="<%=Utils.Null2Empty(id)%>">
    <input type="hidden" name="act" value="0">

    <tr height="25">
        <td width="80" align=center><font color=red><%=bundle.getString("LINK_TITLE")%></font></td>
        <td>
            <input type="text" name="title" style="width:100%" onchange="title_preview(this.value)" value="<%= art==null?"":Utils.TransferToHtmlEntity(art.GetTitle())%>">
        </td>
        <td width="80" align=center><font color=red><%=bundle.getString("LINK_TOPIC")%></font></td>
        <td width="240">&nbsp;
            <%
              out.println(topic.GetName());
            %>
        </td>
    </tr>
    <tr height="25">
		<td width="80" align=center><font color=red><%=bundle.getString("LINK_URL")%></font></td>
		<td>
			<input type="text" name="url" style="width:100%" value="<%= art==null?"":Utils.TransferToHtmlEntity(art.GetURL()) %>">
	    </td>
        <td width="80" align=center><%=bundle.getString("LINK_VIEWSOURCE")%></td>
        <td>&nbsp;
            <%
                if(art!=null && art.GetSourceURL()!=null)
                {
                    out.print("<a href=\""+art.GetSourceURL()+"\" target=_blank>" + Utils.NVL(art.GetSource(),bundle.getString("LINK_VIEWSOURCE")) + "</a>");
                }
            %>
        </td>
    </tr>
    <tr height="25">
       <td align="center">
            <%=bundle.getString("LINK_ABSTRACT")%>
        </td>
        <td colspan="3">
            <div style="padding-top:5px;padding-bottom:5px"><%=bundle.getString("LINK_HINT_ABSTRACT")%></div>
            <textarea name="content_abstract" rows="5" cols="60" style="width:100%"><%=bNew?"":Utils.Null2Empty(art.GetAbstract())%></textarea>
        </td>
    </tr>
    <tr height=25>
        <td align=center><%=bundle.getString("LINK_CREATOR")%></td>
        <td>
            &nbsp;
            <%= bNew?creator:art.GetCreatorCN()%>
            &nbsp;
            <%= bNew?create_date:art.GetCreateDate()%>
        </td>
        <td align=center><%=bundle.getString("LINK_PUBLISHDATE")%></td>
        <td>&nbsp;
            <%
                if(!bNew)
                {
                    out.print("<font color=red>");
                    out.print(bundle.getString("LINK_STATE_" + art.GetState()));
                    out.print("</font>");

                    if(art.IsPublished())
                    {
                        out.print("&nbsp;&nbsp;");
                        out.print(art.GetPublishDate());
                    }
                }
            %>
        </td>
    </tr>
    <tr height="25">
        <td align=center><%=bundle.getString("LINK_IMAGE")%></td>
        <td colspan="3" valign="top">
            <div style="padding-top:5px;padding-bottom:5px;padding-left:2px;">
            <input type="button" class="button" value="<%=bundle.getString("LINK_BUTTON_ATTACH_FILE")%>" onClick="javascript:uploadfiles()" >
            <input type="button" class="button" value="<%=bundle.getString("LINK_BUTTON_ATTACH_LIST")%>" onClick="javascript:attachlist()" >
            </div>

            <input type="text" name="img_url" style="width:500px" value="<%=art!=null?Utils.Null2Empty(art.GetImageURL()):""%>">
        </td>
    </tr>
    </form>
</table>

<table width="100%" cellpadding="0" border="0" cellspacing="0">
    <tr>
        <td align="center">
        <div style="padding-top:20px">
           <img id="image_preview" src="<% if(art!=null && art.GetImageURL()!=null) out.print(art.GetImageURL());%>" border="0" <% if(art==null || art.GetImageURL()==null) out.print("style='display:none'");%>>
        </div>
        </td>
    </tr>
</table>

<form name="resFrm" action="/info/selectresource.jsp" target="_blank">
    <input type="hidden" name="multiple" value="0">
    <input type="hidden" name="siteid" value="<%=Utils.Null2Empty(site_id)%>">
    <input type="hidden" name="type" value="0">
</form>
</body>
</html>