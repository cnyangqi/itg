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
    String scrollstr = "", nextpage = "articlelist.jsp";
    String currpg    = request.getParameter("page");
    try{ currpage = Integer.parseInt(currpg);	}catch (Exception e){currpage = 1;	}

    int status = 1; //默认为待审核
    String s_status =request.getParameter("status");
    try { status =Integer.parseInt(s_status);}catch(Exception e){ status = 1; }
    scrollstr = "status="+status;

    String s_rows = request.getParameter("rows");
    try { rowperpage =Integer.parseInt(s_rows);}catch(Exception e){}

    String site_id = request.getParameter("site_id");
    if(site_id!=null && site_id.length()>0)
    {
        site_id = site_id.trim();
        scrollstr += "&site_id="+site_id;
    }
    
    String top_id = request.getParameter("top_id");
    if(top_id!=null && top_id.length()>0)
    {
        top_id = top_id.trim();
        scrollstr += "&top_id="+top_id;
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

    String copysite_id = request.getParameter("copy_site");
    if(copysite_id!=null) copysite_id = copysite_id.trim();

    String copytopic_id = request.getParameter("copy_topic");
    if(copytopic_id!=null) copytopic_id = copytopic_id.trim();

    String slavesite_id = request.getParameter("slave_site");
    if(slavesite_id!=null) slavesite_id = slavesite_id.trim();

    String slavetopic_id = request.getParameter("slave_topic");
    if(slavetopic_id!=null) slavetopic_id = slavetopic_id.trim();    

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_articlelist",user.GetLocale(), Config.RES_CLASSLOADER);
    String job = request.getParameter("job");
    
    NpsWrapper wrapper  = null;
    wrapper = new NpsWrapper(user);
    wrapper.SetErrorHandler(response.getWriter());
    wrapper.SetLineSeperator("\n<br>\n");
    
    PreparedStatement pstmt   = null;
    ResultSet rs     = null;
    
    try
    {
    	if("cancel".equalsIgnoreCase(job))
        {
            String[] rownos = request.getParameterValues("rowno");
            try
            {
            	for(int i=0;i<rownos.length;i++)
                {
                    String cancel_art_id = request.getParameter("art_id_" + rownos[i]);
                    String cancel_site_id = request.getParameter("site_id_" + rownos[i]);

                    wrapper.GetSite(cancel_site_id);
                    NormalArticle art = wrapper.GetArticle(cancel_art_id);
                    boolean bCancel  = false;  //是否能够撤消
                    bCancel = user.GetUID().equals(art.GetCreatorID()) || art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(cancel_site_id) || user.IsSysAdmin();
                    if(art==null || !bCancel) continue;
                    //没有发布，不用撤销
                    if(art.GetState() == 3)
                    {
                        try
                        {
                            art.Cancel();

                            //重建栏目所有页面模板
                            wrapper.GenerateAllPages(art.GetTopic());

                            //重建所有从栏目
                            Hashtable topic_slaves = art.GetSlaveTopics();
                            if(topic_slaves!=null && !topic_slaves.isEmpty())
                            {
                                Enumeration enum_topic_slaves = topic_slaves.elements();
                                while(enum_topic_slaves.hasMoreElements())
                                {
                                    Topic t = (Topic)enum_topic_slaves.nextElement();
                                    wrapper.GenerateAllPages(t);
                                }
                            }
                        }
                        finally
                        {
                            art.Clear();
                        }
                    }
                }
            }
            catch(Exception e)
            {
                if(wrapper!=null) wrapper.Rollback();
                e.printStackTrace();
            }
        }
    	
    	if("republish".equalsIgnoreCase(job))
        {
            String[] rownos = request.getParameterValues("rowno");
            try
            {
                for(int i=0;i<rownos.length;i++)
                {
                    String republish_art_id = request.getParameter("art_id_" + rownos[i]);
                    String republish_site_id = request.getParameter("site_id_" + rownos[i]);

                    wrapper.GetSite(republish_site_id);
                    NormalArticle art = wrapper.GetArticle(republish_art_id);
                    boolean bRepublishable  = false;  //是否能够发布
                    bRepublishable = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(republish_site_id) || user.IsSysAdmin();
                    if(art==null || !bRepublishable) continue;

                    try
                    {
                        art.ChangeState(2);

                        //生成文章页面
                        wrapper.GenerateArticle(art);
                        //重建所有页面模板
                        wrapper.GenerateAllPages(art.GetTopic());

                        //重建所有从栏目
                        Hashtable topic_slaves = art.GetSlaveTopics();
                        if(topic_slaves!=null && !topic_slaves.isEmpty())
                        {
                            Enumeration enum_topic_slaves = topic_slaves.elements();
                            while(enum_topic_slaves.hasMoreElements())
                            {
                                Topic t = (Topic)enum_topic_slaves.nextElement();
                                wrapper.GenerateAllPages(t);
                            }
                        }
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
            }
        }
    	
    	if("publish".equalsIgnoreCase(job))
        {
            String[] rownos = request.getParameterValues("rowno");
            try
            {
                for(int i=0;i<rownos.length;i++)
                {
                    String publish_art_id = request.getParameter("art_id_" + rownos[i]);
                    String publish_site_id = request.getParameter("site_id_" + rownos[i]);

                    wrapper.GetSite(publish_site_id);
                    NormalArticle art = wrapper.GetArticle(publish_art_id);
                    boolean bPublishable  = false;  //是否能够发布
                    bPublishable = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(publish_site_id) || user.IsSysAdmin();
                    if(art==null || !bPublishable) continue;

                    try
                    {
                        art.ChangeState(2);

                        //生成文章页面
                        wrapper.GenerateArticle(art);
                        //重建所有页面模板
                        wrapper.GenerateAllPages(art.GetTopic());

                        //重建所有从栏目
                        Hashtable topic_slaves = art.GetSlaveTopics();
                        if(topic_slaves!=null && !topic_slaves.isEmpty())
                        {
                            Enumeration enum_topic_slaves = topic_slaves.elements();
                            while(enum_topic_slaves.hasMoreElements())
                            {
                                Topic t = (Topic)enum_topic_slaves.nextElement();
                                wrapper.GenerateAllPages(t);
                            }
                        }
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
            }
        }
    	
    	if("check".equalsIgnoreCase(job))
        {
            String[] rownos = request.getParameterValues("rowno");
            try
            {
                for(int i=0;i<rownos.length;i++)
                {
                    String check_art_id = request.getParameter("art_id_" + rownos[i]);
                    String check_site_id = request.getParameter("site_id_" + rownos[i]);

                    wrapper.GetSite(check_site_id);
                    NormalArticle art = wrapper.GetArticle(check_art_id);
                    boolean bCheckable = false; //是否能够审核
					//只有站点管理员、版主可以审核 
                    bCheckable = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(check_site_id) || user.IsSysAdmin();
                    if(art==null || !bCheckable) continue;

                    try
                    {
                        art.ChangeState(2);

                        //生成文章页面
                        wrapper.GenerateArticle(art);
                        //重建所有页面模板
                        wrapper.GenerateAllPages(art.GetTopic());

                        //重建所有从栏目
                        Hashtable topic_slaves = art.GetSlaveTopics();
                        if(topic_slaves!=null && !topic_slaves.isEmpty())
                        {
                            Enumeration enum_topic_slaves = topic_slaves.elements();
                            while(enum_topic_slaves.hasMoreElements())
                            {
                                Topic t = (Topic)enum_topic_slaves.nextElement();
                                wrapper.GenerateAllPages(t);
                            }
                        }
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
            }
        }
    	
    	if("submit".equalsIgnoreCase(job))
        {
            String[] rownos = request.getParameterValues("rowno");
            try
            {
                for(int i=0;i<rownos.length;i++)
                {
                    String submit_art_id = request.getParameter("art_id_" + rownos[i]);
                    String submit_site_id = request.getParameter("site_id_" + rownos[i]);

                    wrapper.GetSite(submit_site_id);
                    NormalArticle art = wrapper.GetArticle(submit_art_id);
                    boolean bSubmitable = false; //是否能够提交
                    bSubmitable = user.GetUID().equals(art.GetCreatorID()); //草稿状态,只有自己能提交
                    if(art==null || !bSubmitable) continue;

                    int topic_default_article_state = art.GetTopic().GetDefaultArticleState(); //栏目默认文章状态
                    //如果为草稿就设置为提交待审核状态
                    topic_default_article_state  = topic_default_article_state==0?1:topic_default_article_state;

                    try
                    {
                        switch(topic_default_article_state)
                        {
                            case 1: //提交待审核状态，修改状态
                                art.ChangeState(1);
                                break;
                            case 2: //审核通过
                            case 3: //发布状态，直接发布文章
                                art.ChangeState(2);

                                //生成文章页面
                                wrapper.GenerateArticle(art);
                                //重建所有页面模板
                                wrapper.GenerateAllPages(art.GetTopic());
                                //重建所有从栏目
                                Hashtable topic_slaves = art.GetSlaveTopics();
                                if(topic_slaves!=null && !topic_slaves.isEmpty())
                                {
                                    Enumeration enum_topic_slaves = topic_slaves.elements();
                                    while(enum_topic_slaves.hasMoreElements())
                                    {
                                        Topic t = (Topic)enum_topic_slaves.nextElement();
                                        wrapper.GenerateAllPages(t);
                                    }
                                }
                                break;
                        }
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
            }
        }
    	
        if("delete".equalsIgnoreCase(job))
        {
            String[] rownos = request.getParameterValues("rowno");
            try
            {
                for(int i=0;i<rownos.length;i++)
                {
                    String delete_art_id = request.getParameter("art_id_" + rownos[i]);
                    String delete_site_id = request.getParameter("site_id_" + rownos[i]);

                    wrapper.GetSite(delete_site_id);
                    NormalArticle art = wrapper.GetArticle(delete_art_id);
                    if(art==null) continue;

                    //校验是否能删除
                    boolean bDeletable = false;
                    if(art.GetState()==0)
                    {
                        //草稿状态只有自己能删除
                        bDeletable = user.GetUID().equals(art.GetCreatorID());
                    }
                    else
                    {
                        //属主、站点管理员、版主可以删除文章
                        bDeletable = user.GetUID().equals(art.GetCreatorID()) || art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(delete_site_id) || user.IsSysAdmin();
                    }

                    if(bDeletable)
                    {
                        try
                        {
                            art.Delete();
                            if(art.GetState()==3)
                            {
                                //重建栏目所有页面模板
                                wrapper.GenerateAllPages(art.GetTopic());
                                //重建所有从栏目
                                Hashtable topic_slaves = art.GetSlaveTopics();
                                if(topic_slaves!=null && !topic_slaves.isEmpty())
                                {
                                    Enumeration enum_topic_slaves = topic_slaves.elements();
                                    while(enum_topic_slaves.hasMoreElements())
                                    {
                                        Topic t = (Topic)enum_topic_slaves.nextElement();
                                        wrapper.GenerateAllPages(t);
                                    }
                                }
                            }
                        }
                        finally
                        {
                            art.Clear();
                        }
                    }
                }
            }
            catch(Exception e)
            {
                if(wrapper!=null) wrapper.Rollback();
                e.printStackTrace();
            }
        }

        if("copy".equalsIgnoreCase(job))
        {
            String[] rownos = request.getParameterValues("rowno");
            Site copysite = null;
            Topic copytopic = null;

            if(copysite_id!=null && copysite_id.length()>0 && copytopic_id!=null && copytopic_id.length()>0 && rownos!=null && rownos.length>0)
            {
                try
                {
                    copysite = wrapper.GetSite(copysite_id);
                    if(copysite!=null)
                    {
                        copytopic = copysite.GetTopicTree().GetTopic(copytopic_id);
                        if(copytopic!=null)
                        {
                            for(int i=0;i<rownos.length;i++)
                            {
                                String copy_art_id = request.getParameter("art_id_" + rownos[i]);
                                String copy_art_siteid = request.getParameter("site_id_" + rownos[i]);

                                wrapper.GetSite(copy_art_siteid);
                                NormalArticle art = wrapper.GetArticle(copy_art_id);
                                if(art==null) continue;
                                
                                //创建人设置为自己
                                NormalArticle new_art = art.Copy(copytopic,user);
                                if(new_art==null) continue;
                                try
                                {
                                    new_art.Save();
                                    new_art.UpdateContent(art);
                                }
                                finally
                                {
                                    new_art.Clear();
                                }
                            }
                            wrapper.Commit();
                        }
                    }
                }
                catch(Exception e)
                {
                    if(wrapper!=null) wrapper.Rollback();
                    e.printStackTrace();
                }
            }
        }

        if("addtopic".equalsIgnoreCase(job))
        {
            String[] rownos = request.getParameterValues("rowno");
            Site slavesite = null;
            Topic slavetopic = null;

            if(slavesite_id!=null && slavesite_id.length()>0 && slavetopic_id!=null && slavetopic_id.length()>0 && rownos!=null && rownos.length>0)
            {
                try
                {
                    slavesite = wrapper.GetSite(slavesite_id);
                    if(slavesite!=null)
                    {
                        slavetopic = slavesite.GetTopicTree().GetTopic(slavetopic_id);
                        if(slavetopic!=null)
                        {
                            for(int i=0;i<rownos.length;i++)
                            {
                                String art_id = request.getParameter("art_id_" + rownos[i]);
                                String art_siteid = request.getParameter("site_id_" + rownos[i]);

                                wrapper.GetSite(art_siteid);
                                NormalArticle art = wrapper.GetArticle(art_id);
                                if(art==null) continue;

                                Hashtable art_slavetopics = art.GetSlaveTopics();
                                boolean bDuplicate = art_slavetopics!=null && !art_slavetopics.isEmpty()  && art_slavetopics.containsKey(slavetopic_id);
                                art.AddSlaveTopic(slavetopic);
                                if(!bDuplicate)
                                {
                                    try
                                    {
                                        art.Save();
                                         //如果已经发布，需要重建从栏目模板
                                         if(art.GetState()==3) wrapper.GenerateAllPages(slavetopic);
                                    }
                                    finally
                                    {
                                        art.Clear();
                                    }
                                }
                            }
                            wrapper.Commit();
                        }
                    }
                }
                catch(Exception e)
                {
                    if(wrapper!=null) wrapper.Rollback();
                    e.printStackTrace();
                }
            }
        }
%>

<HTML>
	<HEAD>
		<TITLE><%=bundle.getString("ARTLIST_HTMLTITLE")%> </TITLE>
        <script type="text/javascript" src="/jscript/global.js"></script>
        <LINK href="/css/style.css" rel = stylesheet>
        <script langauge = "javascript">
            function f_search()
            {
                document.frm_search.submit();
            }

            function selectTopics()
            {
                var rc = popupDialog("selectalltopics.jsp");
                if (rc == null || rc.length==0) return false;

                f_setsearchtopic(rc[0],rc[1],rc[2],rc[3]);
            }

            function f_setsearchtopic(siteid,sitename,topid,topname)
            {
                document.frm_search.site_id.value= siteid;
                document.frm_search.topic.value = topname==""?sitename:topname+"("+sitename+")";
                document.frm_search.top_id.value = topid;
            }
    
            function changestatus(status)
            {
                if(parent)
                {
                    parent.frames["topicNav"].window.f_setstatus(status);
                }
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
            
            function f_new()
			{
				document.listFrm.action	= "articleinfo.jsp";
                document.listFrm.target="_blank";
                document.listFrm.submit();
			}

            function f_copy()
			{
              var rownos = document.getElementsByName("rowno");
              var hasChecked = false;
              for (var i = 0; i < rownos.length; i++)
              {
                  if( rownos[i].checked )
                  {
                      hasChecked = true;
                      break;
                  }
              }
              if( !hasChecked ) return false;

              var r = confirm("<%=bundle.getString("ARTLIST_COPYALERT")%>");
              if(r==1)
              {
                  var rc = popupDialog("selecttopics.jsp");
                  if( rc != null && rc.length >0 )
                  {
                        f_settopic(rc[0],rc[1],rc[2],rc[3]);
                  }
              }
              return false;
			}

            function f_settopic(siteid,sitename,topid,topname)
            {
                document.listFrm.action = "articlelist.jsp?job=copy&copy_site="+siteid+"&copy_topic="+topid;
                document.listFrm.target = "_self";
                document.listFrm.submit();
            }

           function f_addslavetopic(siteid,sitename,topid,topname)
           {
               document.listFrm.action = "articlelist.jsp?job=addtopic&slave_site="+siteid+"&slave_topic="+topid;
               document.listFrm.target = "_self";
               document.listFrm.submit();
           }

            function f_addtopic()
            {
                var rownos = document.getElementsByName("rowno");
                var hasChecked = false;
                for (var i = 0; i < rownos.length; i++)
                {
                    if( rownos[i].checked )
                    {
                        hasChecked = true;
                        break;
                    }
                }
                if( !hasChecked ) return false;

                var rc = popupDialog("selectmycompanytopics.jsp");
                if( rc != null && rc.length >0 )
                {
                      f_addslavetopic(rc[0],rc[1],rc[2],rc[3]);
                }
                return false;
            }

            function f_submit(actiontype)
			{
                var rownos = document.getElementsByName("rowno");
                var hasChecked = false;
                for (var i = 0; i < rownos.length; i++)
                {
                   if( rownos[i].checked ){ hasChecked = true; break; }
                }
                if( !hasChecked ) return false;

			    var rc = true; 
				if( actiontype == 'delete')
                {
			  	    r = confirm("<%=bundle.getString("ARTLIST_DELALERT")%>");
				    if( r !=1 ) return false;
				    document.listFrm.action = "articlelist.jsp?job=delete";
                    document.listFrm.target="_self";
                }
                if( actiontype == 'submit')
                {
				    document.listFrm.action = "articlelist.jsp?job=submit";
                    document.listFrm.target="_self";
                }
                if( actiontype == 'check')
                {
				    document.listFrm.action = "articlelist.jsp?job=check";
                    document.listFrm.target="_self";
                }
                if( actiontype == 'publish')
                {
				    document.listFrm.action = "articlelist.jsp?job=publish";
                    document.listFrm.target="_self";
                }
                if( actiontype == 'republish')
                {
				    document.listFrm.action = "articlelist.jsp?job=republish";
                    document.listFrm.target="_self";
                }
                if( actiontype == 'cancel')
                {
				    document.listFrm.action = "articlelist.jsp?job=cancel";
                    document.listFrm.target="_self";
                }
				if( rc) document.listFrm.submit();
			}

            function f_toggle()
            {
                if(parent)
                {
                    if(parent.document.all.leftFrameSet.cols=="0,*")
                    {
                        parent.document.all.leftFrameSet.cols = "160,*";
                    }
                    else
                    {
                        parent.document.all.leftFrameSet.cols = "0,*";
                    }
                }
            }

            function SelectArticle()
			{
                var rownos = document.getElementsByName("rowno");
				for (var i = 0; i < rownos.length; i++)
				{
					rownos[i].checked = document.listFrm.AllId.checked;
				}
			}
		</script>
        <script type="text/javascript" src="/jscript/calendar.js"></script>
    </HEAD>
<BODY>
<%
        String sql = null;
        Site site = null;
        Topic top = null;
        if(site_id!=null && site_id.length()>0)
        {
            site =wrapper.GetSite(site_id);
            if(site==null) throw new NpsException(ErrorHelper.SYS_NOSITE);
        }

        if(top_id!=null && top_id.length()>0)
        {
            TopicTree tree = site.GetTopicTree();
            if(tree==null) throw new NpsException(ErrorHelper.SYS_NOTOPICTREE);
            top = tree.GetTopic(top_id);
            if(top==null) throw new NpsException(ErrorHelper.SYS_NOTOPIC);
        }

        String table_name = "article";
        if(top!=null && top.GetTable()!=null && top.GetTable().length()>0)  table_name = top.GetTable()+"_prop";

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

        switch(status)
        {
            case 0: //查询草稿状态，默认加入作者判断
                sql = "select count(*) from " + table_name +" a where a.state=? ";
                if(table_name.equalsIgnoreCase("article")) sql += "and a.creator=?";
                if(site_id!=null && site_id.length()>0)   sql +=" and a.siteid=?";
                if(sql_sites_view!=null)   sql += " and (" + sql_sites_view + " )";
                if(top_id!=null && top_id.length()>0)
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
                pstmt.setInt(i++,status);
                if(table_name.equals("article"))  pstmt.setString(i++,user.GetUID());
                if(site_id!=null && site_id.length()>0)  pstmt.setString(i++,site_id);
                if(top_id!=null && top_id.length()>0)
                {
                    if(table_name.equalsIgnoreCase("article"))
                    {
                        pstmt.setString(i++,top_id);
                        pstmt.setString(i++,top.GetCode()+".%");
                        pstmt.setString(i++,top_id);
                        pstmt.setString(i++,top.GetCode()+".%");
                    }
                    else
                    {
                        pstmt.setString(i++,top_id);
                        pstmt.setString(i++,top.GetCode()+".%");
                    }
                }
                if(keyword!=null && keyword.length()>0) pstmt.setString(i++,keyword);
                if(creator!=null && creator.length()>0) pstmt.setString(i++,creator);
                if(from_date!=null && from_date.length()>0) pstmt.setString(i++,from_date);
                if(to_date!=null && to_date.length()>0) pstmt.setString(i++,to_date);
                if(from_pdate!=null && from_pdate.length()>0) pstmt.setString(i++,from_pdate);
                if(to_pdate!=null && to_pdate.length()>0) pstmt.setString(i++,to_pdate);
                         
                break;
            case 1: //提交待审核
            case 2: //审核通过待发布
            case 3: //已发布成功
                sql = "select count(*) from "+table_name+" a where a.state=?";
                if(site_id!=null && site_id.length()>0)   sql +=" and a.siteid=?";
                if(sql_sites_view!=null)   sql += " and (" + sql_sites_view + " )";
                if(top_id!=null && top_id.length()>0)
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
                i=1;
                pstmt.setInt(i++,status);
                if(site_id!=null && site_id.length()>0)  pstmt.setString(i++,site_id);
                if(top_id!=null && top_id.length()>0)
                {
                    if(table_name.equalsIgnoreCase("article"))
                    {
                         pstmt.setString(i++,top_id);
                         pstmt.setString(i++,top.GetCode()+".%");
                         pstmt.setString(i++,top_id);
                         pstmt.setString(i++,top.GetCode()+".%");
                    }
                    else
                    {
                        pstmt.setString(i++,top_id);
                        pstmt.setString(i++,top.GetCode()+".%");
                    }
                }
                if(keyword!=null && keyword.length()>0) pstmt.setString(i++,keyword);
                if(creator!=null && creator.length()>0) pstmt.setString(i++,creator);
                if(from_date!=null && from_date.length()>0) pstmt.setString(i++,from_date);
                if(to_date!=null && to_date.length()>0) pstmt.setString(i++,to_date);
                if(from_pdate!=null && from_pdate.length()>0) pstmt.setString(i++,from_pdate);
                if(to_pdate!=null && to_pdate.length()>0) pstmt.setString(i++,to_pdate);
        }

        rs = pstmt.executeQuery();
        if (rs.next())  totalrows = rs.getInt(1);
        try{rs.close();}catch(Exception e){}
        try{pstmt.close();}catch(Exception e){}
%>
  <table width = "100% " border = "0" cellpadding = "0" cellspacing = "0" class="PositionBar">
    <form name="frm_search" method="post" action="articlelist.jsp">
    <tr>
      <td colspan=3 valign="middle">&nbsp;
<%
       //只有正常文章才能新建、删除与复制，其他只能查看
       if("article".equalsIgnoreCase(table_name))
       {
%>
        <input name="newBtn" type="button" onClick="f_new()" value="<%=bundle.getString("ARTLIST_NEWBUTTON")%>" class="button">          
        <input name="delBtn" type="button" onClick="f_submit('delete')" value="<%=bundle.getString("ARTLIST_DELBUTTON")%>" class="button">
        <% if(status==0){ %>
        <input name="submitBtn" type="button" onClick="f_submit('submit')" value="<%=bundle.getString("ARTLIST_SUBMITBUTTON")%>" class="button">
        <% } %>
        <% if(status==1){ %>
        <input name="submitBtn" type="button" onClick="f_submit('check')" value="<%=bundle.getString("ARTLIST_CHECKBUTTON")%>" class="button">
        <% } %>
        <% if(status==2){ %>
        <input name="submitBtn" type="button" onClick="f_submit('publish')" value="<%=bundle.getString("ARTLIST_PUBLISHBUTTON")%>" class="button">
        <% } %>
        <% if(status==3){ %>
        <input name="submitBtn" type="button" onClick="f_submit('republish')" value="<%=bundle.getString("ARTLIST_REPUBLISHBUTTON")%>" class="button">
        <input name="submitBtn" type="button" onClick="f_submit('cancel')" value="<%=bundle.getString("ARTLIST_CANCELBUTTON")%>" class="button">        
        <% } %>
		<input name="copyBtn" type="button" onclick="f_copy()" value="<%=bundle.getString("ARTLIST_COPYBUTTON")%>" class="button">
        <input name="addTopicBtn" type="button" onclick="f_addtopic()" value="<%=bundle.getString("ARTLIST_ADDTOPICBUTTON")%>" class="button"> 
<%
      }
%>
        <input name="toggleBtn" type="button" onClick="f_toggle()" value="<%=bundle.getString("ARTLIST_TREEBUTTON")%>" class="button">
        <input type="hidden" name="urlTo" value="articlelist.jsp?page=<%=currpage%>" >
      </td>
    </tr>
    <tr height="25" style="padding-top:5px">
        <td>
            <%=bundle.getString("ARTLIST_TITLE")%>:
            <input type="text" name="keyword" value="<%=Utils.Null2Empty(keyword)%>">
            <input type="button" class="button" name="searchBtn" value="<%=bundle.getString("ARTLIST_SEARCHBUTTON")%>" onclick="f_search()">
        </td>
        <td>
            <%=bundle.getString("ARTLIST_TOPIC")%>:
            <input type="hidden" name="site_id" value="<%=site_id==null?"":site_id%>">
            <input type="hidden" name="top_id" value="<%=top_id==null?"":top_id%>">
            <input type="text" name="topic" value="<% if(top!=null) out.print(top.GetName() + "(" + site.GetName() + ")"); else if(site!=null) out.print(site.GetName()); %>" readonly onclick='selectTopics()'>
            <input type="button" value="<%=bundle.getString("ARTLIST_SELTOPIC_BUTTON")%>" class="button" name="btn_topic" onclick='selectTopics()'>
        </td>
        <td>
            <%=bundle.getString("ARTLIST_STATUS")%>:
            <select name="status" onchange="changestatus(this.value)">
                <option value="0" <% if(status==0) out.print("selected");%>><%=bundle.getString("ARTLIST_STATUS_DRAFT")%></option>
                <option value="1" <% if(status==1) out.print("selected");%>><%=bundle.getString("ARTLIST_STATUS_SUBMIT")%></option>
                <option value="2" <% if(status==2) out.print("selected");%>><%=bundle.getString("ARTLIST_STATUS_CHECKED")%></option>
                <option value="3" <% if(status==3) out.print("selected");%>><%=bundle.getString("ARTLIST_STATUS_PUBLISHED")%></option>
            </select>
        </td>        
    </tr>
    <tr height="25" style="padding-top:5px;padding-bottom:5px">
        <td colspan="3">
            <%=bundle.getString("ARTLIST_CREATOR")%>:<input type="text" name="creator" style="width:80px" value="<%=Utils.Null2Empty(creator)%>">
            &nbsp;
            <%=bundle.getString("ARTLIST_CREATEDATE")%>:<input type="text" id="from_date" name="from_date" style="width:80px" value="<%=Utils.Null2Empty(from_date)%>" onClick="getDateString(this,<% if("zh".equalsIgnoreCase(user.GetLocale().getLanguage())) out.print("oCalendarChs"); else out.print("oCalendarEn");%>)">
            -
            <input type="text" id="to_date" name="to_date" style="width:80px" value="<%=Utils.Null2Empty(to_date)%>"  onClick="getDateString(this,<% if("zh".equalsIgnoreCase(user.GetLocale().getLanguage())) out.print("oCalendarChs"); else out.print("oCalendarEn");%>)">
            &nbsp;
            <%=bundle.getString("ARTLIST_PUBLISHDATE")%>:<input type="text" id="from_pdate" name="from_pdate" style="width:80px" value="<%=Utils.Null2Empty(from_pdate)%>" onClick="getDateString(this,<% if("zh".equalsIgnoreCase(user.GetLocale().getLanguage())) out.print("oCalendarChs"); else out.print("oCalendarEn");%>)">
            -
            <input type="text" id="to_pdate" name="to_pdate" style="width:80px" value="<%=Utils.Null2Empty(to_pdate)%>"  onClick="getDateString(this,<% if("zh".equalsIgnoreCase(user.GetLocale().getLanguage())) out.print("oCalendarChs"); else out.print("oCalendarEn");%>)">
        </td>
    </tr>
    </form>
  </table>

  <table width = "100% " border = "0" cellpadding = "0" cellspacing = "1" class="TitleBar">
  <form name = "listFrm" method = "post">
      <input type="hidden" name="status" value="<%=status%>">
      <tr height=30>
	      <td width="25">
    		<input type = "checkBox" name = "AllId" value = "0" onclick = "SelectArticle()">
		  </td>
 	      <td><%=bundle.getString("ARTLIST_TITLE")%></td>
		  <td width="80"><%=bundle.getString("ARTLIST_TOPIC")%></td>
          <td width="80"><%=bundle.getString("ARTLIST_SITE")%></td>
<%
     if("article".equalsIgnoreCase(table_name))
     {
%>
          
          <td width="80"><%=bundle.getString("ARTLIST_CREATOR")%></td>
<%
    }
%>          <td width="80"><%=bundle.getString("ARTLIST_CREATEDATE")%></td>
<%
        if(status==3)
        {
%>
          <td width="80"><%=bundle.getString("ARTLIST_PUBLISHDATE")%></td>
<%
        }
%>
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
            switch(status)
            {
                case 0: //查询草稿状态，默认加入作者判断
                    sql += " and a.state=?";
                    if(table_name.equals("article")) sql += " and a.creator=?";
                    if(site_id!=null && site_id.length()>0)   sql +=" and a.siteid=?";
                    if(sql_sites_view!=null)   sql += " and (" + sql_sites_view + " )";
                    if(top_id!=null && top_id.length()>0)
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
                    int i=1;
                    pstmt.setInt(i++,status);
                    if(table_name.equals("article")) pstmt.setString(i++,user.GetUID());
                    if(site_id!=null && site_id.length()>0)  pstmt.setString(i++,site_id);
                    if(top_id!=null && top_id.length()>0)
                    {
                        if(table_name.equalsIgnoreCase("article"))
                        {
                            pstmt.setString(i++,top_id);
                            pstmt.setString(i++,top.GetCode()+".%");
                            pstmt.setString(i++,top_id);
                            pstmt.setString(i++,top.GetCode()+".%");
                        }
                        else
                        {
                            pstmt.setString(i++,top_id);
                            pstmt.setString(i++,top.GetCode()+".%");
                        }
                    }
                    if(keyword!=null && keyword.length()>0) pstmt.setString(i++,keyword);
                    if(creator!=null && creator.length()>0) pstmt.setString(i++,creator);
                    if(from_date!=null && from_date.length()>0) pstmt.setString(i++,from_date);
                    if(to_date!=null && to_date.length()>0) pstmt.setString(i++,to_date);
                    if(from_pdate!=null && from_pdate.length()>0) pstmt.setString(i++,from_pdate);
                    if(to_pdate!=null && to_pdate.length()>0) pstmt.setString(i++,to_pdate);

                    break;
                case 1: //提交待审核
                case 2: //审核通过待发布
                case 3: //已发布成功
                    sql += " and a.state=?";
                    if(site_id!=null && site_id.length()>0)   sql +=" and a.siteid=?";
                    if(sql_sites_view!=null)   sql += " and (" + sql_sites_view + " )";
                    if(top_id!=null && top_id.length()>0)
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
                    pstmt.setInt(i++,status);
                    if(site_id!=null && site_id.length()>0)  pstmt.setString(i++,site_id);
                    if(top_id!=null && top_id.length()>0)
                    {
                        if(table_name.equalsIgnoreCase("article"))
                        {
                            pstmt.setString(i++,top_id);
                            pstmt.setString(i++,top.GetCode()+".%");
                            pstmt.setString(i++,top_id);
                            pstmt.setString(i++,top.GetCode()+".%");
                        }
                        else
                        {
                            pstmt.setString(i++,top_id);
                            pstmt.setString(i++,top.GetCode()+".%");
                        }
                    }
                    if(keyword!=null && keyword.length()>0) pstmt.setString(i++,keyword);
                    if(creator!=null && creator.length()>0) pstmt.setString(i++,creator);
                    if(from_date!=null && from_date.length()>0) pstmt.setString(i++,from_date);
                    if(to_date!=null && to_date.length()>0) pstmt.setString(i++,to_date);
                    if(from_pdate!=null && from_pdate.length()>0) pstmt.setString(i++,from_pdate);
                    if(to_pdate!=null && to_pdate.length()>0) pstmt.setString(i++,to_pdate);
            }
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
                  <input type = "hidden" name = "top_id_<%= rs.getRow() %>" value = "<%=  rs.getString("top_id") %>">
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
              <%
                   if(status==3)
                   {
              %>

                <td>
                    <%
                         if(rs.getString("publishdate")!=null)
                            out.print(Utils.FormateDate(rs.getDate("publishdate"),"yyyy-MM-dd"));
                    %>
                </td>
              <%
                  }
              %>
              </tr>
          <%
              }
            }  //end of if (totalrows >0)
 %>
  </form>
 </table>
<form name=frmOpen action="articleinfo.jsp" target="_blank">
  <input type = "hidden" name = "id">
  <input type = "hidden" name = "site_id">
  <input type="hidden" name="top_id">
</form>
<script language="JavaScript" type="text/JavaScript">
  function openArt(siteid,topid,idvalue){
    document.frmOpen.id.value = idvalue;
    document.frmOpen.site_id.value = siteid;
    document.frmOpen.top_id.value = topid;      
    document.frmOpen.action="articleinfo.jsp";
    document.frmOpen.submit();
}
  function openCustomArt(siteid,topid,idvalue){
      document.frmOpen.id.value = idvalue;
      document.frmOpen.site_id.value = siteid;
      document.frmOpen.top_id.value = topid;
      document.frmOpen.action = "customartinfo.jsp";
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
        if(wrapper!=null) wrapper.Clear();
    }    
%>