<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>

<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    
    String cmd = request.getParameter("cmd");
    String site_id = request.getParameter("siteid");
    String top_id = request.getParameter("topid");
    if(top_id!=null) top_id = top_id.trim();
    
    String top_parentid = request.getParameter("top_parentid");
    String top_name = request.getParameter("top_name");
    String top_alias = request.getParameter("top_alias");
    String sIndex = request.getParameter("top_index");
    String sTopScore = request.getParameter("top_score");
    String sArtState = request.getParameter("art_def_state");
    String art_table  = request.getParameter("art_table");
    String s_top_visible = request.getParameter("top_visible");
    int top_visible = 1;
    try{top_visible = Integer.parseInt(s_top_visible);}catch(Exception e){}
    if(art_table!=null) art_table = art_table.trim();
    String art_tmpid = request.getParameter("top_art_tmp_id");
    String s_archive_mode = request.getParameter("archive_mode");
    int archive_mode = 0;
    try{archive_mode = Integer.parseInt(s_archive_mode);}catch(Exception e){}
    String archive_tmpid = request.getParameter("top_archive_tmp_id");
    String s_solr_enabled = request.getParameter("solr_enabled");
    int solr_enabled = 0;
    try{solr_enabled = Integer.parseInt(s_solr_enabled);}catch(Exception e){}
    String solr_core = request.getParameter("solr_core");
    String s_sort_enabled = request.getParameter("sort_enabled");
    int sort_enabled = 0;
    try{sort_enabled = Integer.parseInt(s_sort_enabled);}catch(Exception e){}
    
    String s_is_business = request.getParameter("is_business");
    int is_business = 0;
    try{is_business = Integer.parseInt(s_is_business);}catch(Exception e){}

    
    //is_business
    float art_score = 0f;
    int index = 0;
    int art_state = 0;    
    String relate_ids[] = request.getParameterValues("rt_tmp_id");
    String user_ids[] = request.getParameterValues("user_id");
    String user_names[] = request.getParameterValues("user_name");
    String var_names[] = request.getParameterValues("var_name");
    String var_values[] = request.getParameterValues("var_value");
    String var_comments[] = request.getParameterValues("var_comment");
    String solrfield_names[] = request.getParameterValues("solrfield_name");
    String solrfield_comments[] = request.getParameterValues("solrfield_comment");
    
    boolean bNew = (top_id==null || top_id.length()==0);
    
    try{art_score = Float.parseFloat(sTopScore);}catch(Exception e1){}
    try{index = Integer.parseInt(sIndex);}catch(Exception e1){}
    try{art_state = Integer.parseInt(sArtState);}catch(Exception e1){}
        
    if( site_id == null || site_id.length() == 0)  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    if( top_name == null || top_name.length() == 0)  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    if( top_alias == null || top_alias.length() == 0)  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);


    NpsWrapper wrapper = null;
    Site site = null;
    TopicTree tree = null;
    Topic topic = null;
    try
    {
        wrapper = new NpsWrapper(user,site_id);
        site = wrapper.GetSite();
        if(site==null) throw new NpsException(ErrorHelper.SYS_NOSITE);
        tree = site.GetTopicTree();
        if(tree==null) throw new NpsException(ErrorHelper.SYS_NOTOPICTREE);
        
        //删除
        if("delete".equalsIgnoreCase(cmd))
        {
            topic = tree.GetTopic(top_id);
            wrapper.DeleteTopic(topic);            
            response.sendRedirect("topicinfo.jsp?delete=1&siteid="+site_id+"&topid="+top_id);
            return;
        }

        //保存数据
        if(bNew)
        {
            //自动编号
            if(index==0)  index = tree.GenerateTopicIndex(top_parentid);

            topic = wrapper.NewTopic(site_id,top_parentid,top_name,top_alias,index,art_table,art_tmpid,art_state,art_score);
            topic.SetVisibility(top_visible);
            topic.SetArchiveMode(archive_mode);
            topic.SetSolrEnabled(solr_enabled);
            topic.SetSolrCore(solr_core);
            topic.SetSortEnabled(sort_enabled);
            topic.setIs_business(is_business);
            if(archive_mode!=0 && archive_tmpid!=null && archive_tmpid.trim().length()>0)
            {
                PageTemplate archive_template = (PageTemplate)tree.GetTemplate(archive_tmpid);
                topic.SetArchiveTemplate(archive_template);
            }

            top_id = topic.GetId();
        }
        else
        {
            topic = tree.GetTopic(top_id);
            if(topic!=null)
            {
                topic.SetName(top_name);
                topic.SetOrder(index);
                topic.SetTable(art_table);
                topic.SetDefaultArticleState(art_state);
                topic.SetScore(art_score);
                topic.SetArticleTemplate(wrapper.GetArticleTemplate(art_tmpid));
                topic.SetVisibility(top_visible);
                topic.SetArchiveMode(archive_mode);
                topic.SetSolrEnabled(solr_enabled);
                topic.SetSolrCore(solr_core);
                topic.SetSortEnabled(sort_enabled);
                topic.setIs_business(is_business);
                if(archive_mode!=0 && archive_tmpid!=null && archive_tmpid.trim().length()>0)
                {
                    PageTemplate archive_template = wrapper.GetPageTemplate(archive_tmpid);
                    topic.SetArchiveTemplate(archive_template);
                }
            }

            topic.ClearPageTemplates();
            topic.ClearOwner();
            topic.ClearVars();
            topic.ClearSolrFields();
            topic.ClearKeywordLinks();
        }

        //新增热字
        String keyword_links = request.getParameter("keyword_link");
        if(keyword_links!=null && keyword_links.length()>0)
        {
            topic.AddKeywordLinks(keyword_links);
        }


        //设置注释
        String comment = request.getParameter("top_comment");
        if(comment!=null && comment.length()>0)
        {
            comment = comment.replaceAll("(\r\n|\r|\n|\n\r)", "");
            topic.SetComment(comment);
        }

        //新增页面模板
        for(int i=0;relate_ids!=null && i<relate_ids.length;i++)
        {
            String pt_id = relate_ids[i];
            PageTemplate pt = wrapper.GetPageTemplate(pt_id);
            topic.AddPageTemplate(pt);
        }

        //新增版主
        for(int i=0;user_ids!=null && i<user_ids.length;i++)
        {
            String user_id = user_ids[i];
            String user_name = user_names[i];
            topic.AddOwner(user_id,user_name);            
        }

        //新增自定义变量
        for(int i=0;var_names!=null && i<var_names.length;i++)
        {
            topic.AddVar(var_names[i],var_values[i],var_comments[i]);
        }

        //新增Solr Field
        for(int i=0;solrfield_names!=null && i<solrfield_names.length;i++)
        {
            topic.AddSolrField(solrfield_names[i],solrfield_comments[i]);
        }

        wrapper.SaveTopic(topic,bNew);
        if(!bNew) tree.UpdateTopicAlias(wrapper.GetContext(),topic,top_alias);

        wrapper.Commit();
        response.sendRedirect("topicinfo.jsp?refresh=1&siteid="+site_id+"&topid="+top_id);

    }
    catch(Exception e)
    {
        wrapper.Rollback();
        e.printStackTrace();
        throw e;
    }
    finally
    {
        if(wrapper!=null) wrapper.Clear();
    }
%>