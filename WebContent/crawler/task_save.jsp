<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.job.crawler.Task" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.job.crawler.Tag" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.*" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_crawltask_save",user.GetLocale(), Config.RES_CLASSLOADER);

    String act = request.getParameter("act");
    String task_id = request.getParameter("task_id");
    boolean bNew = (task_id==null || task_id.length()==0);

    NpsContext ctxt = null;
    //保存
    if("save".equalsIgnoreCase(act))
    {
        String name = request.getParameter("task_name");
        if(name==null || name.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
        String site_id = request.getParameter("site");
        if(site_id==null || site_id.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
        String encoding = request.getParameter("encoding");
        if(encoding==null || encoding.length()==0) encoding = Task.DEFAULT_ENCODING;
        String http_method = request.getParameter("http_method");
        if(http_method==null || http_method.length()==0) http_method= Task.DEFAULT_METHOD;
        String detect_duplicate = request.getParameter("detect_duplicate");
        String s_thread = request.getParameter("task_thread");
        int  thread = Task.DEFAULT_THREADS;
        try{thread = Integer.parseInt(s_thread);}catch(Exception e){}
        String s_internal_time = request.getParameter("internal_time");
        int internal_time = Task.DEFAULT_THREAD_INTERNAL_TIME;
        try{internal_time = Integer.parseInt(s_internal_time);}catch(Exception e){}
        String cronexp = request.getParameter("task_cronexp");
        String runas = request.getParameter("task_runas");
        if(runas==null || runas.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
        String region_start = request.getParameter("region_start");
        String region_end = request.getParameter("region_end");
        String region_nextpage_start = request.getParameter("region_nextpage_start");
        String region_nextpage_end = request.getParameter("region_nextpage_end");
        String s_save_mode = request.getParameter("save_mode");
        int save_mode = Task.SAVEAS_ARTICLE;
        try{save_mode = Integer.parseInt(s_save_mode);}catch(Exception e){}
        String top_id = request.getParameter("top_id");
        String sql = request.getParameter("sql");
        String article_urlfilter = request.getParameter("article_urlfilter");
        String article_rule = request.getParameter("article_rule");
        String article_link = request.getParameter("article_link");
        String article_nextpage_start = request.getParameter("article_nextpage_start");
        String article_nextpage_end = request.getParameter("article_nextpage_end");
        String s_page_type = request.getParameter("page_type");
        int page_type = 0;
        try{page_type = Integer.parseInt(s_page_type);}catch(Exception e){}
        String s_job_lang = request.getParameter("job_lang");
        int job_lang = 0;
        try{job_lang = Integer.parseInt(s_job_lang);}catch(Exception e){}
        String job_code = request.getParameter("job_code");

        if(save_mode==0)
        {
            if(top_id==null || top_id.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
        }
        else
        {
            if(sql==null || sql.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
        }

        if((article_link!=null && article_link.length()>0 && (article_rule==null || article_rule.length()==0))
          || ((article_link==null || article_link.length()==0) && article_rule!=null && article_rule.length()>0))
        {
            throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
        }

        try
        {
            ctxt = new NpsContext(Database.GetDatabase("nps").GetConnection(),user);
            Site site = ctxt.GetSite(site_id);
            if(site==null) throw new NpsException(ErrorHelper.SYS_NOSITE,"id="+site_id);

            Task task = null;
            if(bNew)
            {
                task = new Task(name,site,page_type);
                task.SetCreator(user);

                if(save_mode == Task.SAVEAS_ARTICLE)
                {
                    Tag tag = new Tag(bundle.getString("TASK_TAG_ART_TITLE"),"art_title",null,null);
                    tag.SetNullable(false);
                    tag.SetDownloadFileFlag(false);
                    tag.SetDownloadFlashFlag(false);
                    tag.SetDownloadImageFlag(false);
                    tag.SetLoopFlag(false);
                    tag.SetPageFlag(false);
                    tag.SetHtml();
                    task.AddTag(tag);

                    tag = new Tag(bundle.getString("TASK_TAG_ART_SUBTITLE"),"art_subtitle",null,null);
                    tag.SetNullable(true);
                    tag.SetDownloadFileFlag(false);
                    tag.SetDownloadFlashFlag(false);
                    tag.SetDownloadImageFlag(false);
                    tag.SetLoopFlag(false);
                    tag.SetPageFlag(false);
                    tag.SetHtml();
                    task.AddTag(tag);

                    tag = new Tag(bundle.getString("TASK_TAG_ART_ABTITLE"),"art_abtitle",null,null);
                    tag.SetNullable(true);
                    tag.SetDownloadFileFlag(false);
                    tag.SetDownloadFlashFlag(false);
                    tag.SetDownloadImageFlag(false);
                    tag.SetLoopFlag(false);
                    tag.SetPageFlag(false);
                    tag.SetHtml();
                    task.AddTag(tag);

                    tag = new Tag(bundle.getString("TASK_TAG_ART_TAG"),"art_tag",null,null);
                    tag.SetNullable(true);
                    tag.SetDownloadFileFlag(false);
                    tag.SetDownloadFlashFlag(false);
                    tag.SetDownloadImageFlag(false);
                    tag.SetLoopFlag(false);
                    tag.SetPageFlag(false);
                    tag.SetHtml();
                    task.AddTag(tag);

                    tag = new Tag(bundle.getString("TASK_TAG_ART_AUTHOR"),"art_author",null,null);
                    tag.SetNullable(true);
                    tag.SetDownloadFileFlag(false);
                    tag.SetDownloadFlashFlag(false);
                    tag.SetDownloadImageFlag(false);
                    tag.SetLoopFlag(false);
                    tag.SetPageFlag(false);
                    tag.SetHtml();
                    task.AddTag(tag);

                    tag = new Tag(bundle.getString("TASK_TAG_ART_IMPORTANT"),"art_important",null,null);
                    tag.SetNullable(true);
                    tag.SetDownloadFileFlag(false);
                    tag.SetDownloadFlashFlag(false);
                    tag.SetDownloadImageFlag(false);
                    tag.SetLoopFlag(false);
                    tag.SetPageFlag(false);
                    tag.SetHtml();
                    task.AddTag(tag);

                    tag = new Tag(bundle.getString("TASK_TAG_ART_SOURCE"),"art_source",null,null);
                    tag.SetNullable(true);
                    tag.SetDownloadFileFlag(false);
                    tag.SetDownloadFlashFlag(false);
                    tag.SetDownloadImageFlag(false);
                    tag.SetLoopFlag(false);
                    tag.SetPageFlag(false);
                    tag.SetHtml();
                    task.AddTag(tag);

                    tag = new Tag(bundle.getString("TASK_TAG_ART_VALIDDAYS"),"art_validdays",null,null);
                    tag.SetNullable(true);
                    tag.SetDownloadFileFlag(false);
                    tag.SetDownloadFlashFlag(false);
                    tag.SetDownloadImageFlag(false);
                    tag.SetLoopFlag(false);
                    tag.SetPageFlag(false);
                    tag.SetHtml();
                    task.AddTag(tag);

                    tag = new Tag(bundle.getString("TASK_TAG_ART_ABSTRACT"),"art_abstract",null,null);
                    tag.SetNullable(true);
                    tag.SetDownloadFileFlag(false);
                    tag.SetDownloadFlashFlag(false);
                    tag.SetDownloadImageFlag(false);
                    tag.SetLoopFlag(false);
                    tag.SetPageFlag(false);
                    tag.SetHtml();
                    task.AddTag(tag);

                    tag = new Tag(bundle.getString("TASK_TAG_ART_CONTENT"),"art_content",null,null);
                    tag.SetNullable(true);
                    tag.SetDownloadFileFlag(false);
                    tag.SetDownloadFlashFlag(true);
                    tag.SetDownloadImageFlag(true);
                    tag.SetLoopFlag(false);
                    tag.SetPageFlag(true);
                    tag.SetPageMode(Tag.PAGE_MODE_PAGINATOR);
                    tag.SetPageBreak(Tag.DEFAULT_PAGEBREAK_FCK);
                    tag.SetHtml();
                    task.AddTag(tag);
                }
            }
            else
            {
                task = Task.LoadTask(ctxt,task_id);
                task.SetName(name);
                task.SetSite(site);
                task.SetPageType(page_type);
            }

            task.SetEncoding(encoding);
            task.SetHttpMethod(http_method);
            task.SetDetectDuplicate("1".equals(detect_duplicate));
            task.SetThreads(thread);
            task.SetInternal(internal_time);
            task.SetJobCronExpr(cronexp);
            task.SetRunAs(user.GetUser(runas));
            task.SetRegionStart(region_start);
            task.SetRegionEnd(region_end);
            task.SetNextPageStart(region_nextpage_start);
            task.SetNextPageEnd(region_nextpage_end);
            task.SetSaveMode(save_mode);
            if(save_mode==0)
            {
                Topic topic = site.GetTopicTree().GetTopic(top_id);
                if(topic==null) throw new NpsException(ErrorHelper.SYS_NOTOPIC);
                if(topic.IsCustom()) throw new NpsException(ErrorHelper.SYS_INVALIDTOPIC);
                task.SetTopic(topic);
                task.SetSQL(null);
            }
            else
            {
                if(sql==null || sql.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
                task.SetTopic(null);
                task.SetSQL(sql);
            }
            task.SetArticleURLFilter(article_urlfilter);
            task.SetArticleRule(article_rule,article_link);
            task.SetArticleNextPageStart(article_nextpage_start);
            task.SetArticleNextPageEnd(article_nextpage_end);
            task.SetJobLang(job_lang);
            task.SetJobCode(job_code);
            task.Save(ctxt);

            if(bNew)
            {
                //set code
                if(job_lang==0 && (job_code==null || job_code.length()==0))
                {
                    job_code = "var crawler = new NpsWebCrawler(\"" + task.GetId() + "\");\n"
                             + "crawler.start();";
                    task.UpdateJobCode(ctxt,job_code);
                }
            }
            
            ctxt.Commit();
            
            response.sendRedirect("task.jsp?id="+task.GetId());
            return;
        }
        catch(Exception e)
        {
            if(ctxt!=null) ctxt.Rollback();
            throw e;
        }
        finally
        {
            if(ctxt!=null) try{ctxt.Clear();}catch(Exception e){}
        }
    }

    //删除网址
    else if("del_page".equalsIgnoreCase(act))
    {
        if(bNew) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
        String page_ids[] = request.getParameterValues("page_id");
        if(page_ids!=null && page_ids.length>0)
        {
            try
            {
                ctxt = new NpsContext(Database.GetDatabase("nps").GetConnection(),user);
                Task task = Task.LoadTask(ctxt,task_id);
                for(int i=0;i<page_ids.length;i++)
                {
                    task.DeleteWebPage(ctxt,page_ids[i]);
                }
                ctxt.Commit();
                response.sendRedirect("task.jsp?id="+task_id);
                return;
            }
            catch(Exception e)
            {
                if(ctxt!=null) ctxt.Rollback();
                throw e;
            }
            finally
            {
                if(ctxt!=null) try{ctxt.Clear();}catch(Exception e){}
            }
        }
    }

    //删除标签
    else if("del_tag".equalsIgnoreCase(act))
    {
        if(bNew) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
        String tag_ids[] = request.getParameterValues("tag_id");
        if(tag_ids!=null && tag_ids.length>0)
        {
            try
            {
                ctxt = new NpsContext(Database.GetDatabase("nps").GetConnection(),user);
                Task task = Task.LoadTask(ctxt,task_id);
                for(int i=0;i<tag_ids.length;i++)
                {
                    task.DeleteTag(ctxt,tag_ids[i]);
                }
                ctxt.Commit();
                response.sendRedirect("task.jsp?id="+task_id);
                return;
            }
            catch(Exception e)
            {
                if(ctxt!=null) ctxt.Rollback();
                throw e;
            }
            finally
            {
                if(ctxt!=null) try{ctxt.Clear();}catch(Exception e){}
            }
        }
    }

    //删除整个任务
    else if("del".equalsIgnoreCase(act))
    {
        if(bNew) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
        try
        {
            ctxt = new NpsContext(Database.GetDatabase("nps").GetConnection(),user);
            Task task = Task.LoadTask(ctxt,task_id);
            task.Delete(ctxt);
            ctxt.Commit();
            out.println("<font color=red>" + task.GetName() + bundle.getString("TASK_HINT_DELETED") + "</font>");
            return;
        }
        catch(Exception e)
        {
            if(ctxt!=null) ctxt.Rollback();
            throw e;
        }
        finally
        {
            if(ctxt!=null) try{ctxt.Clear();}catch(Exception e){}
        }
    }

    //进行任务调度
    else if("sche".equalsIgnoreCase(act))
    {
        if(bNew) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
        try
        {
            ctxt = new NpsContext(Database.GetDatabase("nps").GetConnection(),user);
            Task task = Task.LoadTask(ctxt,task_id);
            task.Schedule(ctxt);
            ctxt.Commit();
            out.println("<font color=red>" + task.GetName() + bundle.getString("TASK_HINT_SCHEDULED") + "</font>");
            return;
        }
        catch(Exception e)
        {
            if(ctxt!=null) ctxt.Rollback();
            throw e;
        }
        finally
        {
            if(ctxt!=null) try{ctxt.Clear();}catch(Exception e){}
        }
    }

    //暂停作业
    else if("pause".equalsIgnoreCase(act))
    {
        if(bNew) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
        try
        {
            ctxt = new NpsContext(Database.GetDatabase("nps").GetConnection(),user);
            Task task = Task.LoadTask(ctxt,task_id);
            task.PauseJob();
            ctxt.Commit();
            out.println("<font color=red>" + task.GetName() + bundle.getString("TASK_HINT_PAUSED") + "</font>");
            return;
        }
        catch(Exception e)
        {
            if(ctxt!=null) ctxt.Rollback();
            throw e;
        }
        finally
        {
            if(ctxt!=null) try{ctxt.Clear();}catch(Exception e){}
        }
    }

    //继续作业
    else if("resume".equalsIgnoreCase(act))
    {
        if(bNew) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
        try
        {
            ctxt = new NpsContext(Database.GetDatabase("nps").GetConnection(),user);
            Task task = Task.LoadTask(ctxt,task_id);
            task.ResumeJob(ctxt);
            ctxt.Commit();
            out.println("<font color=red>" + task.GetName() + bundle.getString("TASK_HINT_RESUMED") + "</font>");
            return;
        }
        catch(Exception e)
        {
            if(ctxt!=null) ctxt.Rollback();
            throw e;
        }
        finally
        {
            if(ctxt!=null) try{ctxt.Clear();}catch(Exception e){}
        }
    }

    //立即运行
    else if("run".equalsIgnoreCase(act))
    {
        if(bNew) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
        try
        {
            ctxt = new NpsContext(Database.GetDatabase("nps").GetConnection(),user);
            Task task = Task.LoadTask(ctxt,task_id);
            task.RunJob(ctxt);
            ctxt.Commit();
            out.println("<font color=red>" + task.GetName() + bundle.getString("TASK_HINT_RUN") + "</font>");
            return;
        }
        catch(Exception e)
        {
            if(ctxt!=null) ctxt.Rollback();
            throw e;
        }
        finally
        {
            if(ctxt!=null) try{ctxt.Clear();}catch(Exception e){}
        }
    }
%>