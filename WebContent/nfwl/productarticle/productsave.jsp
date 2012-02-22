<%@page import="com.nfwl.itg.product.SUBPRODUCT"%>
<%@page import="tools.Pub"%>
<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.*" %>
<%@ page import="nps.processor.Job" %>
<%@ page import="nps.processor.JobScheduler" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_articlesave",user.GetLocale(), nps.core.Config.RES_CLASSLOADER);
    
    List slave_idx_deletes = new ArrayList();
    List slave_topics = new ArrayList();
    Enumeration enum_params = request.getParameterNames();
    while(enum_params.hasMoreElements())
    {
        String fieldName = (String)enum_params.nextElement();
        if(fieldName.equals("slave_idx"))
        {
            slave_idx_deletes.add(request.getParameter(fieldName));
        }
        else if(fieldName.startsWith("slave_topic_"))
        {
            slave_topics.add(fieldName);
        }
    }

    String id= request.getParameter("id");//如果为null，将再保存时使用序列生成ID号
    if(id!=null) id=id.trim();
    
    String site_id = request.getParameter("site_id");
    if(site_id!=null)  site_id=site_id.trim();
    
    int act=0; //默认保存处理，//0保存 1提交  2审核通过  3发布 4删除  5修改重发布 6撤销 7定时发布
    try
    {
       act=Integer.parseInt(request.getParameter("act")); 
    }
    catch(Exception e1)
    {
    }

    boolean bNew = false;
    NpsWrapper wrapper = null;
    Site site = null;
    TopicTree tree = null;
    Topic top = null;
    Topic old_top = null;
    NormalArticle art = null;

    try
    {
        wrapper = new NpsWrapper(user,site_id);
        wrapper.SetErrorHandler(response.getWriter());
        wrapper.SetLineSeperator("\n<br>\n");
        
        site = wrapper.GetSite();
        if(site==null) throw new NpsException(ErrorHelper.SYS_NOSITE);
        tree = site.GetTopicTree();
        if(tree==null) throw new NpsException(ErrorHelper.SYS_NOTOPICTREE);
        top = tree.GetTopic(request.getParameter("top_id"));
        if(top==null) throw new NpsException(ErrorHelper.SYS_NOTOPIC);

        if(id==null || id.length()==0)
        {
            bNew = true;
            art = wrapper.NewNormalArticle(request.getParameter("title"),
                                           request.getParameter("top_id"),
                                           user
                                           );
            old_top = top;            
        }
        else
        {
            art = wrapper.GetArticle(id);

            //权限校验
            switch(act)
            {
                case 1: //提交
                    boolean bSubmitable = false; //是否能够提交
                    bSubmitable = art.GetState()==0 && user.GetUID().equals(art.GetCreatorID()); //草稿状态,只有自己能提交
                    if(!bSubmitable) throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);
                    break;
                case 0: //保存
                case 4: //4删除
                case 6: //6撤销
                    boolean bDeletable = false;
                    if(art.GetState()==0)
                    {
                        //草稿状态只有自己、站点管理员、系统管理员能删除
                        bDeletable = user.GetUID().equals(art.GetCreatorID())
                                || user.IsSiteAdmin(art.GetSite().GetId())
                                || user.IsSysAdmin();
                    }
                    else
                    {
                        //属主、站点管理员、版主可以删除文章
                        bDeletable = user.GetUID().equals(art.GetCreatorID())
                                  || art.GetTopic().IsOwner(user.GetUID())
                                  || user.IsSiteAdmin(art.GetSite().GetId())
                                  || user.IsSysAdmin();
                    }

                    if(!bDeletable) throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);
                    break;
                case 2: //2审核通过
                case 3: //3发布
                case 5: //5修改重发布
                case 7: //定时发布
                    boolean bCheckable = false; //是否能够审核
                    //只有站点管理员、版主、系统管理员可以操作
                    bCheckable = art.GetTopic().IsOwner(user.GetUID()) || user.IsSiteAdmin(art.GetSite().GetId()) || user.IsSysAdmin();
                    if(!bCheckable) throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);
            }

            //删除整个文章
            if(act==4)
            {
                art.Delete();
                if(art.IsPublished())
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
                            if(!t.IsSortEnabled()) wrapper.GenerateAllPages(t);
                        }
                    }
                }
                
                out.println(art.GetTitle()+" "+bundle.getString("ARTICLE_HINT_DELETED"));                
                return;
            }

            //撤销文章
            if(act==6)
            {
                //没有发布，不用撤销
                if(!art.IsPublished())  return;

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
                        if(!t.IsSortEnabled()) wrapper.GenerateAllPages(t);
                    }
                }
                
                out.println(art.GetTitle()+" "+bundle.getString("ARTICLE_HINT_CANCELED"));                
                return;
            }
            if(act==9)
            {//下架产品
                //没有发布，不用撤销
                if(!art.IsPublished())  return;

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
                        if(!t.IsSortEnabled()) wrapper.GenerateAllPages(t);
                    }
                }
                art.ChangeState(9);
                
                out.println(art.GetTitle()+"  成功下架");                
                return;
            }

            //设置标题
            art.SetTitle(request.getParameter("title"));

            //切换栏目过程中如果已经发布的，需要撤销，并重建栏目
            old_top = art.GetTopic();
            if(art.IsPublished() && !old_top.equals(top))
            {
                art.Cancel(false);
                //2009.04.02 如果发布后更改栏目，原有栏目自动重建
                if(!old_top.IsSortEnabled())  wrapper.GenerateAllPages(old_top);

                //重建所有从栏目
                Hashtable topic_slaves = art.GetSlaveTopics();
                if(topic_slaves!=null && !topic_slaves.isEmpty())
                {
                    Enumeration enum_topic_slaves = topic_slaves.elements();
                    while(enum_topic_slaves.hasMoreElements())
                    {
                        Topic t = (Topic)enum_topic_slaves.nextElement();
                        if(!t.IsSortEnabled()) wrapper.GenerateAllPages(t);
                    }
                }                
            }
            art.SetTopic(top);
        }

        art.SetSubtitle(request.getParameter("subtitle"));
        art.SetAbtitle(request.getParameter("abtitle"));
        art.SetKeyword(request.getParameter("keywords"));
        art.SetAuthor(request.getParameter("author"));
        art.SetImportant(Integer.parseInt(Pub.getString(request.getParameter("important"),"0")));
        art.SetSource(request.getParameter("source"));
        String s_validdays = request.getParameter("validdays");
        if(s_validdays!=null && s_validdays.length()>0)
        {
            try{art.SetValiddays(Integer.parseInt(s_validdays));}catch(Exception e2){}
        }
        String s_score = request.getParameter("score");
        if(s_score!=null && s_score.length()>0)
        {
          try{art.SetScore(Float.parseFloat(s_score));}catch(Exception e){}
        }
        String s_abstract = request.getParameter("content_abstract");
        if(s_abstract!=null && s_abstract.trim().length()>0)
        {
            art.SetAbstract(s_abstract);
        }
        else
        {
            art.SetAbstract(null);
        }

        String external_url = request.getParameter("external_url");
        if(external_url!=null && external_url.trim().length()>0)
        {
            art.SetURL(external_url.trim());
        }
        else
        {
            art.SetURL(null);
        }

        String image_url = request.getParameter("pic_url");
        if(image_url!=null && image_url.trim().length()>0)
        {
            art.SetImageURL(image_url.trim());
        }
        else
        {
            art.SetImageURL(null);
        }
        try{
          art.setPrdName(Pub.getString(request.getParameter("title"),""));
          art.setPrdCode(Pub.getString(request.getParameter("prd_code"),""));
          art.setPrdNewlevel(Pub.getInteger(request.getParameter("prd_newlevel"),5).intValue());
          art.setPrdMarketprice(Pub.getDouble(request.getParameter("prd_marketprice"),0).doubleValue());
          art.setPrdSaleprice(Pub.getDouble(request.getParameter("prd_saleprice"),0).doubleValue());
          art.setPrdSaleend(Pub.getSqlDate(request.getParameter("prd_saleend")));
          art.setPrdLocalprice(Pub.getDouble(request.getParameter("prd_localprice"),0).doubleValue());
          art.setPrdPoint(Pub.getInteger(request.getParameter("prd_point"),0).intValue());
          art.setPrdBrandid(Pub.getString(request.getParameter("prd_brandid"),""));
          art.setPrdBrandname(Pub.getString(request.getParameter("prd_brandname"),""));
          art.setPrdUnitid(Pub.getString(request.getParameter("prd_unitid"),""));
          art.setPrdUnitname(Pub.getString(request.getParameter("prd_unitname"),""));
          art.setPrdSpec(Pub.getString(request.getParameter("prd_spec"),""));
          art.setPrdOrigincountryid(Pub.getString(request.getParameter("prd_origincountryid"),""));
          art.setPrdOrigincountryname(Pub.getString(request.getParameter("prd_origincountryname"),""));
          art.setPrdOriginprovinceid(Pub.getString(request.getParameter("prd_originprovinceid"),""));
          art.setPrdOriginprovincename(Pub.getString(request.getParameter("prd_originprovincename"),""));
          art.setPrdParameter(Pub.getString(request.getParameter("prd_parameter"),""));
          art.setPrdShipfee(Pub.getDouble(request.getParameter("prd_shipfee"),0).doubleValue());
          

          art.setPrdSeason(Pub.getInteger(request.getParameter("prd_season"),0).intValue());
          art.setPrdNutrition(Pub.getInteger(request.getParameter("prd_nutrition"),0).intValue());
          art.setPrdBeauty(Pub.getInteger(request.getParameter("prd_beauty"),0).intValue());
          art.setPrdReduce(Pub.getInteger(request.getParameter("prd_reduce"),0).intValue());
          art.setPrdImport(Pub.getInteger(request.getParameter("prd_import"),0).intValue());
          art.setPrdJit(Pub.getInteger(request.getParameter("prd_jit"),0).intValue());
          
        
        }catch(Exception e){
         e.printStackTrace();
        }

        //设置模板
        String template_no = request.getParameter("template");
        if(template_no!=null && template_no.length()>0)
        {
            art.SetCurrentTemplateNo(template_no);
        }
        else
        {
             art.SetCurrentTemplateNo(null);
        }

        //处理从栏目
        if(!slave_topics.isEmpty())
        {
            //如果文章已发布的，撤销删除的栏目
            if(!bNew && !slave_idx_deletes.isEmpty())
            {
                Hashtable current_slavetopics = art.GetSlaveTopics();
                if(current_slavetopics!=null && !current_slavetopics.isEmpty())
                {
                    for(Object topic_idx:slave_idx_deletes)
                    {
                        String topic_delete = request.getParameter("slave_topic_"+topic_idx);
                        if(current_slavetopics.containsKey(topic_delete))
                        {
                            //删除从栏目
                            Topic t_delete = (Topic)current_slavetopics.get(topic_delete);

                            art.DeleteSlaveTopic(topic_delete);

                            //重建从栏目页面模板
                            if(!t_delete.IsSortEnabled()) wrapper.GenerateAllPages(t_delete);
                        }
                    }
                }
            }

            //添加所有从栏目
            for(Object obj:slave_topics)
            {
                String topic_fieldname = (String)obj;
                String field_index = topic_fieldname.substring("slave_topic_".length());

                String site_slave_add = request.getParameter("slave_site_"+field_index);
                String topic_slave_add = request.getParameter(topic_fieldname);

                //如果从栏目是主栏目，跳过
                if(topic_slave_add.equals(top.GetId())) continue;

                //删除本次要删除的所有从栏目
                boolean bDelete = false;
                for(Object topic_idx:slave_idx_deletes)
                {
                    if(field_index.equals(topic_idx))
                    {
                        bDelete = true;
                        slave_idx_deletes.remove(topic_idx);
                        break;
                    }
                }

                if(bDelete) continue;

                Site site_slave = wrapper.GetSite(site_slave_add);
                if(site_slave==null)  continue;
                TopicTree tree_slave = site_slave.GetTopicTree();
                if(tree_slave==null) continue;
                Topic topic_slave = tree_slave.GetTopic(topic_slave_add);
                if(topic_slave==null) continue;

                art.AddSlaveTopic(topic_slave);
            }
        }


        //处理附件
        String[] att_ids = request.getParameterValues("att_id");
        if(att_ids!=null && att_ids.length>0)
        {
            for(int i=0;i<att_ids.length;i++)
            {
                String att_id = att_ids[i];
                String s_att_idx = request.getParameter("att_idx_"+att_id);
                int att_index = 0;
                try{att_index = Integer.parseInt(s_att_idx);}catch(Exception e){}

                art.AddAttach(att_id,att_index);
            }
        }

        //处理待删除附件
        String del_att_id = request.getParameter("del_att_id");
        if(del_att_id!=null && del_att_id.length()>0)
        {
            art.DeleteAttach(del_att_id);
        }
        
        art.Save();
        art.UpdateContent(request.getParameter("content"));
        
        id = art.GetId();

        if("礼包产品".equals(art.GetTopic().GetName())){
          SUBPRODUCT.clear(wrapper.GetContext().GetConnection(), id);
          SUBPRODUCT subprod = null;
          String [] subprd = request.getParameterValues("subprd_id");
          String [] subprdnum = request.getParameterValues("subprd_num");
          for(int j = 0;subprd!=null&&j<subprd.length;j++){
            subprod = new SUBPRODUCT();
            subprod.setParentid(id);
            subprod.setPrdid(subprd[j]);
            subprod.setNum(Integer.valueOf(subprdnum[j]));
            subprod.insert(wrapper.GetContext().GetConnection());
          }
          
        }
        //保存后自动处理
        switch(act)
        {
           case 1: //提交
              int topic_default_article_state = art.GetTopic().GetDefaultArticleState(); //栏目默认文章状态
              //如果为草稿就设置为提交待审核状态
              topic_default_article_state  = topic_default_article_state==0?1:topic_default_article_state;

              switch(topic_default_article_state)
              {
                  case 1: //提交待审核状态，修改状态
                      art.ChangeState(1);
                      break;
                  case 2: //审核通过
                  case 3: //发布状态，直接发布文章
                      //设置审核信息
                      art.SetApprover(user);
                      art.ChangeState(2);

                      //生成文章页面
                      wrapper.GenerateArticle(art);

                      //2010.06.11 jialin 自动重新生成上一篇文章
                      if(art.HasPrev())
                      {
                          NormalArticle prev_art = art.GetPrevArticle();
                          if(prev_art.IsPublished()) wrapper.GenerateArticle(art.GetPrevArticle());
                      }

                      //2010.07.18 如果栏目是手工排序的，不重建栏目
                      //重建所有页面模板
                      if(!top.IsSortEnabled()) wrapper.GenerateAllPages(top);

                      //重建所有从栏目
                      Hashtable topic_slaves = art.GetSlaveTopics();
                      if(topic_slaves!=null && !topic_slaves.isEmpty())
                      {
                          Enumeration enum_topic_slaves = topic_slaves.elements();
                          while(enum_topic_slaves.hasMoreElements())
                          {
                              Topic t = (Topic)enum_topic_slaves.nextElement();
                              if(!t.IsSortEnabled()) wrapper.GenerateAllPages(t);
                          }
                      }
                      break;
              }

              break;
           case 2:  //审核通过
           case 3:  //发布
           case 5: //修改重发布
               //设置审核信息
               art.SetApprover(user);
               art.ChangeState(2);

               //生成文章页面
               wrapper.GenerateArticle(art);

               //2010.06.11 jialin 自动重新生成上一篇文章
               if(art.HasPrev())
               {
                   NormalArticle prev_art = art.GetPrevArticle();
                   if(prev_art.IsPublished()) wrapper.GenerateArticle(art.GetPrevArticle());
               }
               
               //2010.07.18 如果栏目是手工排序的，不重建栏目
               //重建所有页面模板
               if(!top.IsSortEnabled()) wrapper.GenerateAllPages(top);

               //重建所有从栏目
               Hashtable topic_slaves = art.GetSlaveTopics();
               if(topic_slaves!=null && !topic_slaves.isEmpty())
               {
                  Enumeration enum_topic_slaves = topic_slaves.elements();
                  while(enum_topic_slaves.hasMoreElements())
                  {
                      Topic t = (Topic)enum_topic_slaves.nextElement();
                      if(!t.IsSortEnabled()) wrapper.GenerateAllPages(t);
                  }
               }               
              break;
           case 7: //定时发布
               //设置审核信息
               art.SetApprover(user);
               art.ChangeState(2);
               String job_cronexp =  request.getParameter("job_second")
                            + " " + request.getParameter("job_minute")
                            + " " + request.getParameter("job_hour")
                            + " " + request.getParameter("job_day")
                            + " " + request.getParameter("job_month")
                            + " ? " + request.getParameter("job_year");

               String job_code = "var site = session.GetSite(\"" + art.GetSite().GetId() + "\");\n" +
                                "var topic = site.GetTopic(\"" + art.GetTopic().GetId() +"\");\n" +
                                "var article = site.GetArticle(\""+art.GetId()+"\");\n" +
                                "try{\n" +
                                "  article.Build();\n" +
                                "  topic.BuildPagesOnly();\n" +
                                "  var slaves = article.slavetopics;\n" +
                                "  for(i=0;slaves!=null && i<slaves.length;i++) slaves[i].BuildPagesOnly();" +
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
        //如果没有错误，直接跳到articleinfo.jsp
        if(!wrapper.HasError()) response.sendRedirect("productinfo.jsp?id="+id+"&site_id="+site_id);        
    }
    catch(Exception e)
    {
      e.printStackTrace();
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