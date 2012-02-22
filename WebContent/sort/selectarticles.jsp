<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Enumeration" %>

<%@ include file="/include/header.jsp" %>


<%
    request.setCharacterEncoding("UTF-8");
    int rowperpage = 20;
    int currpage = 1, startnum = 0, endnum = 0, totalrows = 0, totalpages = 0, rownum=0;
    String scrollstr = "", nextpage = "selectarticles.jsp";
    String currpg    = request.getParameter("page");
    try{ currpage = Integer.parseInt(currpg);	}catch (Exception e){currpage = 1;	}

    String s_rows = request.getParameter("rows");
    try { rowperpage =Integer.parseInt(s_rows);}catch(Exception e){}

    String site_id = request.getParameter("site_id");
    if(site_id==null || site_id.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    scrollstr = "site_id="+site_id;

    String top_id = request.getParameter("top_id");
    if(top_id==null || top_id.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    scrollstr += "&top_id="+top_id;

    String q_site_id = request.getParameter("q_site_id");
    if(q_site_id==null)
    {
        q_site_id = site_id;
    }
    else
    {
        q_site_id = q_site_id.trim();
        scrollstr += "&q_site_id="+q_site_id;
    }

    String q_top_id = request.getParameter("q_top_id");
    if(q_top_id==null)
    {
        q_top_id = top_id;
    }
    else
    {
        q_top_id = q_top_id.trim();
        scrollstr += "&q_top_id="+q_top_id;
    }

    String keyword = request.getParameter("keyword");
    if(keyword!=null && keyword.length()>0)
    {
        keyword = keyword.trim();
        if(!keyword.endsWith("%")) keyword += "%";
        scrollstr += "&keyword=" + java.net.URLEncoder.encode(keyword,"UTF-8");
    }

    String creator = request.getParameter("creator");
    if(creator!=null && creator.length()>0)
    {
        creator = creator.trim();
        if(!creator.endsWith("%")) creator += "%";
        scrollstr += "&creator=" + java.net.URLEncoder.encode(creator,"UTF-8");
    }

    String from_date = request.getParameter("from_date");
    if(from_date!=null && from_date.length()>0)
    {
        from_date = from_date.trim();
        scrollstr += "&from_date="+from_date;
    }

    String to_date = request.getParameter("to_date");
    if(to_date!=null && to_date.length()>0)
    {
        to_date = to_date.trim();
        scrollstr += "&to_date="+to_date;
    }

    String from_pdate = request.getParameter("from_pdate");
    if(from_pdate!=null && from_pdate.length()>0)
    {
        from_pdate = from_pdate.trim();
        scrollstr += "&from_pdate="+from_pdate;
    }

    String to_pdate = request.getParameter("to_pdate");
    if(to_pdate!=null && to_pdate.length()>0)
    {
        to_pdate = to_pdate.trim();
        scrollstr += "&to_pdate="+to_pdate;
    }

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_selectarticles",user.GetLocale(), Config.RES_CLASSLOADER);
    String job = request.getParameter("job");

    NpsWrapper wrapper  = null;
    wrapper = new NpsWrapper(user);
    wrapper.SetErrorHandler(response.getWriter());
    wrapper.SetLineSeperator("\n<br>\n");

    Site site = null;
    Topic topic = null; //当前栏目

    Site q_site = null;
    Topic q_topic = null; //查询栏目
    PreparedStatement pstmt   = null;
    ResultSet rs     = null;

    try
    {
        site = wrapper.GetSite(site_id);
        if(site==null) throw new NpsException(site_id,ErrorHelper.SYS_NOSITE);
        topic = site.GetTopicTree().GetTopic(top_id);
        if(topic==null) throw new NpsException(top_id,ErrorHelper.SYS_NOTOPIC);

        if(q_site_id!=null && q_site_id.length()>0)
        {
            q_site = wrapper.GetSite(q_site_id);
            if(q_site==null) throw new NpsException(q_site_id,ErrorHelper.SYS_NOSITE);
        }
        if(q_top_id!=null && q_top_id.length()>0)
        {
            q_topic = q_site.GetTopicTree().GetTopic(q_top_id);
            if(q_topic==null) throw new NpsException(q_top_id,ErrorHelper.SYS_NOTOPIC);
        }

        if("add".equalsIgnoreCase(job))
        {
            String[] rownos = request.getParameterValues("rowno");
            if(rownos!=null)
            {
                try
                {
                    for(int i=0;i<rownos.length;i++)
                    {
                        String add_art_id = request.getParameter("art_id_" + rownos[i]);
                        String add_site_id = request.getParameter("site_id_" + rownos[i]);
                        String add_top_id = request.getParameter("top_id_" + rownos[i]);

                        Site site_add = wrapper.GetSite(add_site_id);
                        if(site_add==null) continue;

                        Topic topic_add = site_add.GetTopicTree().GetTopic(add_top_id);
                        if(topic_add==null) continue;

                        String src = null;
                        String src_url = null;
                        Article art = null;
                        try
                        {
                            src = topic_add.GetName();
                            if(topic_add.IsCustom())
                            {
                                art = wrapper.GetArticle(add_art_id,topic_add);
                                src_url = "/info/customartinfo.jsp?id="+add_art_id+"&site_id="+add_site_id+"&top_id="+add_top_id;
                            }
                            else
                            {
                                art = wrapper.GetArticle(add_art_id);
                                src_url = "/info/articleinfo.jsp?id="+add_art_id+"&site_id="+add_site_id+"&top_id="+add_top_id;
                            }

                            ArticleRefer art_ref = new ArticleRefer(wrapper.GetContext(),topic,art,src,src_url);
                            art_ref.Save();
                        }
                        finally
                        {
                            art.Clear();
                        }
                    }
                }
                catch(Exception e)
                {
                    if(wrapper!=null) wrapper.Rollback();
                    e.printStackTrace();
                    throw e;
                }

                out.println("<p>"+bundle.getString("SELECTART_HINT_ADDED")+"</p>");
            }
        }
%>

<HTML>
	<HEAD>
		<TITLE><%=bundle.getString("SELECTART_HTMLTITLE")%> </TITLE>
        <script type="text/javascript" src="/jscript/global.js"></script>
        <LINK href="/css/style.css" rel = stylesheet>
        <script langauge = "javascript">
            function f_search()
            {
                document.frm.job.value="";
                document.frm.submit();
            }

            function f_add()
            {
                document.frm.job.value="add";
                document.frm.submit();
            }

            function selectTopics()
            {
                var rc = popupDialog("/info/selectalltopics.jsp");
                if (rc == null || rc.length==0) return false;

                f_setsearchtopic(rc[0],rc[1],rc[2],rc[3]);
            }

            function f_setsearchtopic(siteid,sitename,topid,topname)
            {
                document.frm.q_site_id.value= siteid;
                document.frm.q_top_id.value = topid;
                document.frm.topic.value = topname==""?sitename:topname+"("+sitename+")";
            }

            function clearTopic()
            {
                document.frm.q_site_id.value= "";
                document.frm.q_top_id.value = "";
                document.frm.topic.value = "";
            }

            function popupDialog(url)
             {
                var isMSIE= (navigator.appName == "Microsoft Internet Explorer");  //判断浏览器

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

            function SelectArticle()
			{
                var rownos = document.getElementsByName("rowno");
				for (var i = 0; i < rownos.length; i++)
				{
					rownos[i].checked = document.frm.AllId.checked;
				}
			}
		</script>
        <script type="text/javascript" src="/jscript/calendar.js"></script>
    </HEAD>
<BODY>
<%
        String sql = null;

        String table_name = "article";
        if(q_topic!=null && q_topic.GetTable()!=null && q_topic.GetTable().length()>0)  table_name = q_topic.GetTable()+"_prop";

        String sql_sites_view = null;
        if(!user.IsSysAdmin())
        {
            //查看可管理的站点或者本单位站点
            Hashtable sites_view = user.GetOwnSites();
            if(sites_view==null) sites_view = user.GetUnitSites();
            if(sites_view!=null && !sites_view.isEmpty())
            {
                Enumeration sites_view_ids = sites_view.keys();
                while(sites_view_ids.hasMoreElements())
                {
                    if(sql_sites_view==null)
                        sql_sites_view = " a.siteid='" + sites_view_ids.nextElement() + "'";
                    else
                        sql_sites_view += " or a.siteid='" + sites_view_ids.nextElement() + "'";
                }
            }

            //加入公开站点的栏目
            sites_view = user.GetPublicSites();
            if(sites_view!=null && !sites_view.isEmpty())
            {
                Enumeration sites_view_ids = sites_view.keys();
                while(sites_view_ids.hasMoreElements())
                {
                    if(sql_sites_view==null)
                        sql_sites_view = " a.topic in (select id from topic where siteid='" + sites_view_ids.nextElement() + "')";
                    else
                        sql_sites_view += " or a.topic in (select id from topic where siteid='" + sites_view_ids.nextElement() + "')";
                }
            }
        }

        sql = "select count(*) from "+table_name+" a where a.state=3";
        if(q_site_id!=null && q_site_id.length()>0)   sql +=" and a.siteid=?";
        if(sql_sites_view!=null)   sql += " and (" + sql_sites_view + " )";
        if(q_top_id!=null && q_top_id.length()>0)
        {
            if(table_name.equalsIgnoreCase("article"))
            {
                sql += " and a.id in (" +
                    "    select w.id from article w,topic y where w.topic=y.id and (y.id=? or y.code like ?) " +
                    "union " +
                    "    select z.artid from topic y,article_topics z where y.id=z.topid and y.siteid=z.siteid " +
                    "    and (y.id=? or y.code like ?)" +
                    ")";
            }
            else
            {
                sql += " and a.id in (select w.id from "+ table_name + " w,topic y where w.topic=y.id and (y.id=? or y.code like ?))";
            }
        }
        if(keyword!=null && keyword.length()>0) sql += " and a.title like ? ";
        if(creator!=null && creator.length()>0) sql += " and a.creator_name like ? ";
        if(from_date!=null && from_date.length()>0) sql += " and a.createdate>=to_date(?,'YYYY-MM-DD')";
        if(to_date!=null && to_date.length()>0) sql += " and a.createdate<=to_date(?,'YYYY-MM-DD')";
        if(from_pdate!=null && from_pdate.length()>0) sql += " and a.publishdate>=to_date(?,'YYYY-MM-DD')";
        if(to_pdate!=null && to_pdate.length()>0) sql += " and a.publishdate<=to_date(?,'YYYY-MM-DD')";

        pstmt = wrapper.GetContext().GetConnection().prepareStatement(sql);
        int i=1;
        if(q_site_id!=null && q_site_id.length()>0)  pstmt.setString(i++,q_site_id);
        if(q_top_id!=null && q_top_id.length()>0)
        {
            if(table_name.equalsIgnoreCase("article"))
            {
                 pstmt.setString(i++,q_top_id);
                 pstmt.setString(i++,q_topic.GetCode()+".%");
                 pstmt.setString(i++,q_top_id);
                 pstmt.setString(i++,q_topic.GetCode()+".%");
            }
            else
            {
                pstmt.setString(i++,q_top_id);
                pstmt.setString(i++,q_topic.GetCode()+".%");
            }
        }
        if(keyword!=null && keyword.length()>0) pstmt.setString(i++,keyword);
        if(creator!=null && creator.length()>0) pstmt.setString(i++,creator);
        if(from_date!=null && from_date.length()>0) pstmt.setString(i++,from_date);
        if(to_date!=null && to_date.length()>0) pstmt.setString(i++,to_date);
        if(from_pdate!=null && from_pdate.length()>0) pstmt.setString(i++,from_pdate);
        if(to_pdate!=null && to_pdate.length()>0) pstmt.setString(i++,to_pdate);

        rs = pstmt.executeQuery();
        if (rs.next())  totalrows = rs.getInt(1);
        try{rs.close();}catch(Exception e){}
        try{pstmt.close();}catch(Exception e){}
%>
<form name="frm" method="post" action="selectarticles.jsp">
    <input type="hidden" name="site_id" value="<%=site_id%>">
    <input type="hidden" name="top_id" value="<%=top_id%>">
    <input type="hidden" name="job" value="">
  <table width = "100% " border = "0" cellpadding = "0" cellspacing = "0" class="PositionBar">
    <tr>
      <td valign="middle">&nbsp;
        <input name="searchBtn" type="button" onClick="f_search()" value="<%=bundle.getString("SELECTART_SEARCHBUTTON")%>" class="button">
        <input type="button" class="button" name="chooseBtn" value="<%=bundle.getString("SELECTART_CHOOSEBUTTON")%>" onclick="f_add()">
      </td>
      <td align="right">
        <%=topic.GetName()%> - <%=site.GetName()%>&nbsp;&nbsp;
      </td>
    </tr>
    <tr height="25" style="padding-top:5px">
        <td colspan="2">
            <%=bundle.getString("SELECTART_TITLE")%>:
            <input type="text" name="keyword" value="<%=Utils.Null2Empty(keyword)%>">
            &nbsp;&nbsp;
            <%=bundle.getString("SELECTART_TOPIC")%>:
            <input type="hidden" name="q_site_id" value="<%=Utils.Null2Empty(q_site_id)%>">
            <input type="hidden" name="q_top_id" value="<%=Utils.Null2Empty(q_top_id)%>">
            <input type="text" name="topic" value="<% if(q_topic!=null) out.print(q_topic.GetName() + "(" + q_site.GetName() + ")"); else if(q_site!=null) out.print(q_site.GetName()); %>" readonly>
            <input type="button" value="<%=bundle.getString("SELECTART_SELTOPIC_BUTTON")%>" class="button" name="btn_topic" onclick='selectTopics()'>
            <input type="button" value="<%=bundle.getString("SELECTART_CLEAR_BUTTON")%>" class="button" name="btn_clear" onclick='clearTopic()'>
        </td>
    </tr>
    <tr height="25" style="padding-top:5px;padding-bottom:5px">
        <td colspan="2">
            <%=bundle.getString("SELECTART_CREATOR")%>:<input type="text" name="creator" style="width:80px" value="<%=Utils.Null2Empty(creator)%>">
            &nbsp;
            <%=bundle.getString("SELECTART_CREATEDATE")%>:<input type="text" id="from_date" name="from_date" style="width:80px" value="<%=Utils.Null2Empty(from_date)%>" onClick="getDateString(this,<% if("zh".equalsIgnoreCase(user.GetLocale().getLanguage())) out.print("oCalendarChs"); else out.print("oCalendarEn");%>)">
            -
            <input type="text" id="to_date" name="to_date" style="width:80px" value="<%=Utils.Null2Empty(to_date)%>"  onClick="getDateString(this,<% if("zh".equalsIgnoreCase(user.GetLocale().getLanguage())) out.print("oCalendarChs"); else out.print("oCalendarEn");%>)">
            &nbsp;
            <%=bundle.getString("SELECTART_PUBLISHDATE")%>:<input type="text" id="from_pdate" name="from_pdate" style="width:80px" value="<%=Utils.Null2Empty(from_pdate)%>" onClick="getDateString(this,<% if("zh".equalsIgnoreCase(user.GetLocale().getLanguage())) out.print("oCalendarChs"); else out.print("oCalendarEn");%>)">
            -
            <input type="text" id="to_pdate" name="to_pdate" style="width:80px" value="<%=Utils.Null2Empty(to_pdate)%>"  onClick="getDateString(this,<% if("zh".equalsIgnoreCase(user.GetLocale().getLanguage())) out.print("oCalendarChs"); else out.print("oCalendarEn");%>)">
        </td>
    </tr>
  </table>

  <table width = "100% " border = "0" cellpadding = "0" cellspacing = "1" class="TitleBar">
      <tr height=30>
	      <td width="25">
    		<input type = "checkBox" name = "AllId" value = "0" onclick = "SelectArticle()">
		  </td>
 	      <td width=160><%=bundle.getString("SELECTART_TITLE")%></td>
		  <td width="80"><%=bundle.getString("SELECTART_TOPIC")%></td>
          <td width="80"><%=bundle.getString("SELECTART_SITE")%></td>
<%
     if("article".equalsIgnoreCase(table_name))
     {
%>
          <td width="80"><%=bundle.getString("SELECTART_CREATOR")%></td>
<%
    }
%>
          <td width="80"><%=bundle.getString("SELECTART_CREATEDATE")%></td>
          <td width="80"><%=bundle.getString("SELECTART_PUBLISHDATE")%></td>
      </tr>
<%
        if (totalrows > 0)
        {
            totalpages = (int )((totalrows - 1) / rowperpage) + 1;
            startnum = rowperpage * (currpage - 1) + 1;
            endnum = currpage * rowperpage;

            if(table_name.equals("article"))
                sql = "select a.Id,a.title,a.creator_name creator,a.createdate,a.publishdate,b.id top_id,b.Name top_name,c.id site_id,c.name site_name from article a,topic b,site c Where a.topic=b.Id And a.siteid=c.Id ";
            else
                sql = "select a.Id,a.title,a.createdate,a.publishdate,b.id top_id,b.Name top_name,c.id site_id,c.name site_name from " + table_name + " a,topic b,site c Where a.topic=b.Id And a.siteid=c.Id ";

            sql += " and a.state=3";
            if(q_site_id!=null && q_site_id.length()>0)   sql +=" and a.siteid=?";
            if(sql_sites_view!=null)   sql += " and (" + sql_sites_view + " )";
            if(q_top_id!=null && q_top_id.length()>0)
            {
                if(table_name.equalsIgnoreCase("article"))
                {
                    sql += " and a.id in (" +
                        "    select w.id from article w,topic y where w.topic=y.id and (y.id=? or y.code like ?) " +
                        "union " +
                        "    select z.artid from topic y,article_topics z where y.id=z.topid and y.siteid=z.siteid " +
                        "    and (y.id=? or y.code like ?)" +
                        ")";
                }
                else
                {
                    sql += " and a.id in (select w.id from "+ table_name + " w,topic y where w.topic=y.id and (y.id=? or y.code like ?))";
                }
            }
            if(keyword!=null && keyword.length()>0) sql += " and a.title like ? ";
            if(creator!=null && creator.length()>0) sql += " and a.creator_name like ? ";
            if(from_date!=null && from_date.length()>0) sql += " and a.createdate>=to_date(?,'YYYY-MM-DD')";
            if(to_date!=null && to_date.length()>0) sql += " and a.createdate<=to_date(?,'YYYY-MM-DD')";
            if(from_pdate!=null && from_pdate.length()>0) sql += " and a.publishdate>=to_date(?,'YYYY-MM-DD')";
            if(to_pdate!=null && to_pdate.length()>0) sql += " and a.publishdate<=to_date(?,'YYYY-MM-DD')";

            sql += " order by a.publishdate desc,a.createdate desc";
            pstmt = wrapper.GetContext().GetConnection().prepareStatement(sql);
            i=1;
            if(q_site_id!=null && q_site_id.length()>0)  pstmt.setString(i++,q_site_id);
            if(q_top_id!=null && q_top_id.length()>0)
            {
                if(table_name.equalsIgnoreCase("article"))
                {
                    pstmt.setString(i++,q_top_id);
                    pstmt.setString(i++,q_topic.GetCode()+".%");
                    pstmt.setString(i++,q_top_id);
                    pstmt.setString(i++,q_topic.GetCode()+".%");
                }
                else
                {
                    pstmt.setString(i++,q_top_id);
                    pstmt.setString(i++,q_topic.GetCode()+".%");
                }
            }
            if(keyword!=null && keyword.length()>0) pstmt.setString(i++,keyword);
            if(creator!=null && creator.length()>0) pstmt.setString(i++,creator);
            if(from_date!=null && from_date.length()>0) pstmt.setString(i++,from_date);
            if(to_date!=null && to_date.length()>0) pstmt.setString(i++,to_date);
            if(from_pdate!=null && from_pdate.length()>0) pstmt.setString(i++,from_pdate);
            if(to_pdate!=null && to_pdate.length()>0) pstmt.setString(i++,to_pdate);

            rs = pstmt.executeQuery();

            String articleId = "", siteId = null, topId = null;
            rownum = 0;
            while (rs.next() && (rs.getRow() <= endnum))
            {
                if (rs.getRow() < startnum) continue;

                articleId = rs.getString("id");
                siteId  = rs.getString("site_id");
                topId = rs.getString("top_id");
%>
              <tr class="DetailBar">
                <td>
                  <input type = "checkBox" id="rowno" name="rowno" value = "<%= rs.getRow() %>">
                  <input type = "hidden" name = "art_id_<%= rs.getRow() %>" value = "<%= articleId %>">
                  <input type = "hidden" name = "top_id_<%= rs.getRow() %>" value = "<%= topId %>">
                  <input type = "hidden" name = "site_id_<%= rs.getRow() %>" value = "<%= siteId %>">
                </td>
                <td>
                  <%
                       if(table_name.equals("article"))
                       {
                  %>
                            <a href="javascript:openArt('<%= siteId %>','<%= topId %>','<%= articleId %>');"><%= Utils.TransferToHtmlEntity(rs.getString("title")) %></a>
                  <%
                      }
                      else
                      {
                  %>
                           <a href="javascript:openCustomArt('<%= siteId %>','<%= topId %>','<%= articleId %>');"><%= rs.getString("title") %></a>
                   <%
                       }
                   %>
                </td>
                <td>
                  <%= rs.getString("top_name") %>
                </td>
                <td>
                   <%= rs.getString("site_name") %>
                </td>
<%
   if("article".equalsIgnoreCase(table_name))
   {
       out.print("<td>"+rs.getString("creator")+"</td>");
   }
%>
                <td>
                   <%= Utils.FormateDate(rs.getDate("createdate"),"yyyy-MM-dd") %>
                </td>

                <td>
                    <%
                         if(rs.getString("publishdate")!=null)
                            out.print(Utils.FormateDate(rs.getDate("publishdate"),"yyyy-MM-dd"));
                    %>
                </td>
              </tr>
          <%
              }
            }  //end of if (totalrows >0)
 %>
 </table>
</form>
<form name=frmOpen action="/info/articleinfo.jsp" target="_blank">
  <input type = "hidden" name = "id">
  <input type = "hidden" name = "site_id">
  <input type="hidden" name="top_id">
</form>
<script language="JavaScript" type="text/JavaScript">
  function openArt(siteid,topid,idvalue){
    document.frmOpen.id.value = idvalue;
    document.frmOpen.site_id.value = siteid;
    document.frmOpen.top_id.value = topid;
    document.frmOpen.action="/info/articleinfo.jsp";
    document.frmOpen.submit();
}
  function openCustomArt(siteid,topid,idvalue){
      document.frmOpen.id.value = idvalue;
      document.frmOpen.site_id.value = siteid;
      document.frmOpen.top_id.value = topid;
      document.frmOpen.action = "/info/customartinfo.jsp";
      document.frmOpen.submit();
  }
</script>
<%@ include file="/include/scrollpage.jsp" %>
</BODY>
</HTML>
<%
    }
    finally
    {
        if (rs != null) try{ rs.close();}catch(Exception e){}
        if (pstmt != null) try{ pstmt.close();}catch(Exception e){}
        if (wrapper!=null) wrapper.Clear();
    }
%>