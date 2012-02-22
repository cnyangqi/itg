<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="nps.processor.Job" %>
<%@ page import="nps.processor.JobScheduler" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String id=request.getParameter("id");
    if(id!=null) id=id.trim();

    String site_id = request.getParameter("site_id");
    if(site_id!=null)  site_id=site_id.trim();

    String top_id = request.getParameter("top_id");
    if(top_id!=null)  top_id=top_id.trim();

    if(id==null || site_id==null || top_id==null || id.length()==0 || site_id.length()==0 || top_id.length()==0)
       throw new NpsException(ErrorHelper.INPUT_ERROR);
    
    String s_act = request.getParameter("act");

    int act=3; //默认保存处理，//3发布
    try{act=Integer.parseInt(s_act);}catch(Exception e1){}

    NpsWrapper wrapper = null;
    Site site = null;
    TopicTree tree = null;
    Topic top = null;
    CustomArticle art = null;

    try
    {
        wrapper = new NpsWrapper(user,site_id);
        site = wrapper.GetSite();
        if(site==null) throw new NpsException(ErrorHelper.SYS_NOSITE);
        tree = site.GetTopicTree();
        if(tree==null) throw new NpsException(ErrorHelper.SYS_NOTOPICTREE);
        top = tree.GetTopic(top_id);
        if(top==null) throw new NpsException(ErrorHelper.SYS_NOTOPIC);
        art = wrapper.GetArticle(id,top);
        if(art==null)  throw new NpsException(ErrorHelper.SYS_NOARTICLE);

        switch(act)
        {
           case 3:  //发布
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
           case 6: //取消发布
               //撤销文章
               if(art.GetState() == 3)
               {
                   art.Cancel();
                   //重建栏目所有页面模板
                   wrapper.GenerateAllPages(art.GetTopic());

                   //重建所有从栏目
                   topic_slaves = art.GetSlaveTopics();
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
               break;
           case 7: //定时发布
              art.ChangeState(2);
              String job_cronexp =  request.getParameter("job_second")
                            + " " + request.getParameter("job_minute")
                            + " " + request.getParameter("job_hour")
                            + " " + request.getParameter("job_day")
                            + " " + request.getParameter("job_month")
                            + " ? " + request.getParameter("job_year");

              String job_code = "var site = session.GetSite(\"" + art.GetSite().GetId() + "\");\n" +
                                "var topic = site.GetTopic(\"" + art.GetTopic().GetId() +"\");\n" +
                                "var article = site.GetCustomArticle(\""+art.GetId()+"\",topic);\n" +
                                "try{\n" +
                                "  article.Build();\n" +
                                "  topic.BuildPagesOnly();\n" +
                                "}\n" +
                                "catch(e){\n" +
                                "  out.Error(e);\n" +
                                "}\n"+
                                "finally{\n" +
                                "  article.Clear();\n" +
                                "}";

              Job job = new Job(wrapper.GetContext(),art.GetTitle(),0,user.GetUID(),art.GetSite().GetId());
              job.SetExp(job_cronexp);
              job.SetCode(job_code);
              job.SetRunAsName(user.GetName());
              job.SetCreator(user.GetId());
              job.SeCreatorName(user.GetName());
              job.Save(wrapper.GetContext(),true);
              wrapper.Commit();

              //加入调度作业
              JobScheduler.Add(job);
              break;
        }
        response.sendRedirect("customartinfo.jsp?id="+id+"&site_id="+site_id+"&top_id="+top_id);
    }
    catch(Exception e)
    {
        if(wrapper!=null) wrapper.Rollback();
        e.printStackTrace();
        throw e;
    }
    finally
    {
        if(art!=null) art.Clear();
        if(wrapper!=null) wrapper.Clear();
    }
%>