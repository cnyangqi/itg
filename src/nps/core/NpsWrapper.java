package nps.core;

import nps.compiler.*;
import nps.event.*;
import nps.exception.NpsException;
import nps.exception.ErrorHelper;
import nps.processor.JobScheduler;
import nps.util.DefaultLog;
import nps.util.tree.Node;

import java.io.*;
import java.sql.*;
import java.util.zip.ZipOutputStream;
import java.util.zip.ZipFile;
import java.util.Iterator;
import java.util.List;

/**
 * 2008.06.30 jialin
 * 1.增加通用模板执行操作
 *
 * 2008.05.23 jialin
 * 1.NpsContext增加User信息，记录当前运行用户
 * 
 * 总调用入口
 *   1.重建站点
 *       public void GenerateSite(boolean rebuildall)
 *   2.根据top及上级(递归)页面模版生成页面
 *       public void GenerateAllPages(Topic top)
 *       public void GenerateAllPages(String topid)
 *   3.仅生成当前top指定栏目的页面
 *       public void GeneratePages(Topic top)
 *       public void GeneratePages(String topid)
 *   4.重建某个栏目下的所有文章
 *       public void GenerateArticle(Topic top,boolean rebuildall)
 *       public void GenerateArticle(String topid,boolean rebuildall)
 *   4.重建某个模板相关的所有栏目
 *       public void GenerateArticle(ArticleTemplate template);
 *       public void GeneratePages(PageTemplate template);
 *   5.重建指定的文章art
 *       public void GenerateArticle(Article art) throws Exception
 *       public void GenerateArticle(Article art,File output) throws Exception
 *   6.编译文章模版
 *       GenerateArticleClassThenCompile(ArticleTemplate template)
 *   7.编译页面模版
 *       GeneratePageClassThenCompile(PageTemplate template)
 *   8.编译所有模板
 *       GenerateAllClassThenCompile()
 *   9.导出站点
 *       Export(String filename);
 *       Export(String site,String filename);
 *       Export(OutputStream out);
 *       Export(String site,OutputStream out);
 *   10.导入站点
 *       Site Import(String filename,User importer) throws Exception
 *       Site Import(File f,User importer) throws Exception
 *   11.执行通用模板
 *       public String RunTemplate(CommonTemplate template) throws Exception
 *       public void RunTemplate(CommonTemplate template,File output) throws Exception
 *   12.自顶向下生成所有页面模板
 *        public void GenerateAllPagesTopDown(Topic top)
 *        public void GenerateAllPagesTopDown(String top_id)
 * Help方法
 *   1.产生新文章
 *     NormalArticle NewNormalArticle(String title,String top_id,String creator) throws Exception
 *   3.加载文章
 *     NormalArticle GetArticle(String id) throws Exception
 *   4.新建文章模版
 *     ArticleTemplate NewArticleTemplate(String siteid,String name) throws Exception
 *   5.新建页面模版
       PageTemplate NewPageTemplate(String siteid,String name,String fname) throws Exception
 *   6.加载模版
       ArticleTemplate GetArticleTemplate(String id) throws Exception
       PageTemplate GetPageTemplate(String id) throws Exception
 *   7.为新栏目生成唯一ID号
         public String GenerateTopicId()  throws NpsException
 *   8.新建栏目，但未包含页面模板
        public Topic NewTopic(String parentid,String name,String alias,int index,String tname,String art_template,int art_state,float art_score) throws Exception
 *   9.保存栏目信息
        public void SaveTopic(Topic t,boolean bNew) throws NpsException
*   10.删除栏目
        public void DeleteTopic(String id) throws NpsException
*   11.删除栏目
        public void DeleteTopic(Topic t) throws NpsException
*   12.保存站点信息
        public void SaveSite(Site site,boolean bNew) throws NpsException
*   13.删除站点信息
        public void DeleteSite(Site site) throws NpsException
 * NPS - a new publishing system
 * Copyright (c) 2007
 *
 * @author jialin, lanxi justa network co.,ltd.
 * @version 1.0
 */
public class NpsWrapper implements Constants
{
    private NpsContext ctxt = null;
    private String line_seperator = System.getProperty("line.separator");
    private PrintWriter error_handler = null;
    private boolean bError = false;

    public NpsWrapper(NpsContext ctxt,String siteid) throws Exception
    {
        this.ctxt = ctxt;
        ctxt.GetSite(siteid);
    }

    public NpsWrapper(User user,String siteid) throws Exception
    {
        Connection conn = Database.GetDatabase("nps").GetConnection();
        ctxt = new NpsContext(conn,user);
        ctxt.GetSite(siteid);
    }

    //缺省构造函数，使用中仅初始化Context，需要调用GetSite()方法Load站点信息
    public NpsWrapper(User user) throws Exception
    {
        Connection conn = Database.GetDatabase("nps").GetConnection();
        ctxt = new NpsContext(conn,user);
    }

    public NpsContext GetContext()
    {
        return ctxt;
    }

    //自动加载所有有自定义数据源的站点
    public void AutoLoadSiteContainCustomTopic()
    {
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try
        {
            String sql = "Select siteid,id From Topic Where tname Is Not Null";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            rs = pstmt.executeQuery();
            while(rs.next())
            {
                Site asite = ctxt.GetSite(rs.getString("siteid"));
                Topic aTopic = asite.GetTopicTree().GetTopic(rs.getString("id"));

                //2008.01.19 贾林，订阅事件
                String key = aTopic.GetTable().toUpperCase();//对表的各类更新事件感兴趣

                EventSubscriber.GetSubscriber().AddListener((Ready2PublishEventListener)aTopic,key);
                EventSubscriber.GetSubscriber().AddListener((InsertEventListener)aTopic,key);
                EventSubscriber.GetSubscriber().AddListener((UpdateEventListener)aTopic,key);
                EventSubscriber.GetSubscriber().AddListener((DeleteEventListener)aTopic,key);
                EventSubscriber.GetSubscriber().AddListener((PublishEventListener)aTopic,key);
                EventSubscriber.GetSubscriber().AddListener((CancelEventListener)aTopic,key);
            }
        }
        catch(Exception e)
        {
            nps.util.DefaultLog.error_noexception(e);
        }
        finally
        {
            if(rs!=null) try{rs.close();}catch(Exception e1){};
            if(pstmt!=null) try{pstmt.close();}catch(Exception e1){};
        }                
    }

    //重建站点
    public void GenerateSite(boolean rebuildall)
    {
        Iterator topics = ctxt.GetSite().GetTopicTree().GetChilds(null);
        if(topics==null) return;

        while(topics.hasNext())
        {
            Node node_topic = (Node)topics.next();
            Topic topic = (Topic)node_topic.GetValue();

            try{ GenerateAllArticlesTopDown(topic,rebuildall); }catch(Exception e){}
            try{ GenerateAllPagesTopDown(topic); } catch(Exception e){}
        }
    }

    //重新编译所有模板
    public void GenerateAllClassThenCompile()
    {
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try
        {
            //1.加载所有模板信息
            String sql = "select a.id,a.name,a.fname,a.type,a.scope,a.siteid,a.suffix,a.creator,a.createdate,b.name uname,c.name deptname,d.name unitname from template a,users b,dept c,unit d where a.creator=b.id and b.dept=c.id and c.unit=d.id";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            rs = pstmt.executeQuery();

            while(rs.next())
            {
                TemplateBase  template = null;
                switch(rs.getInt("type"))
                {
                    case 0: //文章模版
                        template = new ArticleTemplate(rs.getString("id"),
                                                       rs.getString("name"),
                                                       rs.getString("suffix")
                                                       );
                        break;
                    case 2: //页面模版
                        template = new PageTemplate(rs.getString("id"),
                                                     rs.getString("name"),
                                                     rs.getString("fname")
                                                    );
                        break;
                }

                template.SetScope(rs.getInt("scope"));
                template.SetSiteId(rs.getString("siteid"));
                //设置创建人ID号
                template.SetCreator(rs.getString("creator"));
                template.SetCreatedate(rs.getTimestamp("createdate"));
                //设置用户名
                template.SetCreator( rs.getString("uname") , rs.getString("deptname") , rs.getString("unitname"));

                //清空JAVA文件，要求重新生成、编译
                template.DeleteJavaFiles();
                try
                {
                    switch(rs.getInt("type"))
                    {
                        case 0: //文章模板
                            GenerateArticleClassThenCompile((ArticleTemplate)template);
                            break;
                        case 2: //页面模板
                            GeneratePageClassThenCompile((PageTemplate)template);
                            break;
                    }

                    PrintError(template.GetName()+"("+template.GetId()+") Compiled.<br>");
                }
                catch(Exception e_compile)
                {
                     nps.util.DefaultLog.error_noexception(e_compile);
                     PrintError("<font color=red>Error occurred during compile:"+template.GetName()+"("+template.GetId()+")<br>");
                     PrintError(e_compile);
                     PrintError("</font>");
                }
                finally
                {
                    if(template!=null) try{template.Clear();}catch(Exception e1){}
                    template = null;
                }
            }
        }
        catch(Exception e)
        {
           nps.util.DefaultLog.error_noexception(e);
           PrintError(e);
        }
        finally
        {
            if(rs!=null) try{rs.close();}catch(Exception e){}
            if(pstmt!=null)try{pstmt.close();}catch(Exception e){}
        }
    }

    //产生某个栏目及上级栏目的所有页面模版
    public void GenerateAllPages(String topid)
    {
        //顶级栏目不生成,是一个虚拟节点
        if(topid==null || topid.length()==0 || topid.equalsIgnoreCase("-1")) return;

        GenerateAllPages(ctxt.GetSite().GetTopicTree().GetTopic(topid));
    }

    public void GenerateAllPagesByTopicCode(String top_code)
    {
        if(top_code==null || top_code.length()==0) return;
        GenerateAllPages(ctxt.GetSite().GetTopicTree().GetTopicByCode(top_code));
    }

    //产生某个栏目及上级栏目的所有页面模版
    public void GenerateAllPages(Topic top)
    {
        //bugfix: 2008.05.23 jialin
        //递归调用生成所有上级栏目的页面模板
        if(top==null) return;
        
        GeneratePages(top);
        GenerateAllPages(top.GetParent());
    }

    //自顶向下生成所有页面模板
    public void GenerateAllPagesTopDown(String topid)
    {
       if(topid==null || topid.length()==0 || topid.equalsIgnoreCase("-1"))
       {
           GenerateAllPagesTopDown((Topic)null);
       }
       else
       {
           GenerateAllPagesTopDown(ctxt.GetSite().GetTopicTree().GetTopic(topid));
       }
    }

    public void GenerateAllPagesTopDownByTopicCode(String top_code)
    {
       if(top_code==null || top_code.length()==0)
       {
           GenerateAllPagesTopDown((Topic)null);
       }
       else
       {
           GenerateAllPagesTopDown(ctxt.GetSite().GetTopicTree().GetTopicByCode(top_code));
       }
    }
    
    //自顶向下生成所有页面模板
    public void GenerateAllPagesTopDown(Topic top)
    {
        if(top!=null)  GeneratePages(top);

        //生成下级栏目
        Iterator childs = ctxt.GetSite().GetTopicTree().GetChilds(top);
        while(childs!=null && childs.hasNext())
        {
           Node node = (Node)childs.next();
           Topic topic_child = (Topic)node.GetValue();
           GenerateAllPagesTopDown(topic_child);
        }
    }

    //产生某个栏目下所有页面模版
    public void GeneratePages(String topid)
    {
        //顶级栏目不生成,是一个虚拟节点
        if(topid==null || topid.length()==0 || topid.equalsIgnoreCase("-1")) return;
        GeneratePages(ctxt.GetSite().GetTopicTree().GetTopic(topid));
    }

    public void GeneratePagesByTopicCode(String top_code)
    {
        //顶级栏目不生成,是一个虚拟节点
        if(top_code==null || top_code.length()==0) return;
        GeneratePages(ctxt.GetSite().GetTopicTree().GetTopicByCode(top_code));
    }

    //产生某个栏目下所有页面模版
    public void GeneratePages(Topic top)
    {
        if(top == null)  return;
        //顶级栏目不生成,是一个虚拟节点
        if(top.GetId().equalsIgnoreCase("-1")) return;

        BuildTask task = new BuildTask(top,ctxt.GetUser());
        BuildController.AddTask(top.GetSiteId(),task);
    }

    public void _GeneratePages(Topic top)
    {
        if(top == null)  return;
        //顶级栏目不生成,是一个虚拟节点
        if(top.GetId().equalsIgnoreCase("-1")) return;

        java.util.List pts = top.GetPageTemplates();
        if(pts == null || pts.size() == 0) return;
        PageTemplate pt = null;
        for(int i=0;i<pts.size();i++)
        {
            pt = (PageTemplate)pts.get(i);
            PageClassBase aGenerator = null;
            try
            {
                try
                {
                    aGenerator = LoadPageClass(pt, top);
                }
                catch (ClassNotFoundException e)
                {
                    //未找到，生成并编译
                    GeneratePageClassThenCompile(pt);
                    aGenerator = LoadPageClass(pt, top);
                }

                //生成页面
                aGenerator.service();
            }
            catch(NpsException ne)
            {
                PrintError("site:"+ctxt.GetSite().GetName() +" topic:"+ top.GetName() +"("+top.GetId()+")" +" page template:" + pt.name +"("+ pt.id +")");
                PrintError(ne);
            }
            catch(Exception e2)
            {
                nps.util.DefaultLog.error_noexception("site:"+ctxt.GetSite().GetName()
                                                       +" topic:"+ top.GetName() +"("+top.GetId()+")"
                                                        +" page template:" + pt.name +"("+ pt.id +")");
                nps.util.DefaultLog.error_noexception(e2);

                PrintError("site:"+ctxt.GetSite().GetName() +" topic:"+ top.GetName() +"("+top.GetId()+")" +" page template:" + pt.name +"("+ pt.id +")");
                PrintError(e2);
            }
        }
    }

    //产生指定文章模板相关栏目的所有文章，已经发布的将重建
    public void GenerateArticle(ArticleTemplate template) throws Exception
    {
        if(template==null) return;

        List topics = template.GetTopics(ctxt);
        for(Object obj:topics)
        {
            TemplateBase.TopicProfile top_profile = (TemplateBase.TopicProfile)obj;

            try
            {
                Site asite = GetSite(top_profile.GetSiteId());
                if(asite==null) continue;

                Topic atopic = asite.GetTopicTree().GetTopic(top_profile.GetId());
                if(atopic==null) continue;

                GenerateArticlesByTemplate(atopic,template,false); //重建所有文章
            }
            catch(NpsException ne)
            {
                PrintError("site:"+top_profile.GetSiteName() +" topic:"+ top_profile.GetName() +"("+top_profile.GetId()+")"
                        +" article template:" + template.name +"("+ template.id +")");
                PrintError(ne);
            }
            catch(Exception e2)
            {
                nps.util.DefaultLog.error_noexception("site:"+top_profile.GetSiteName()
                                                       +" topic:"+ top_profile.GetName() +"("+top_profile.GetId()+")"
                                                        +" article template:" + template.name +"("+ template.id +")");
                nps.util.DefaultLog.error_noexception(e2);

                PrintError("site:"+top_profile.GetSiteName()
                       +" topic:"+ top_profile.GetName() +"("+top_profile.GetId()+")"
                        +" article template:" + template.name +"("+ template.id +")");
                PrintError(e2);
            }

        }
    }

    //根据文章模版生成当前栏目（包括下级）的所有文章    
    private int GenerateArticlesByTemplate(Topic top,ArticleTemplate template,boolean template_can_be_empty) throws Exception
    {
        int rows = 0;
        if(top == null)  return rows;

        boolean need_to_rebuild = false;
        ArticleTemplate my_template = top.GetArticleTemplate();
        if(my_template!=null && template.GetId().equals(my_template.GetId()))
        {
           need_to_rebuild = true;
        }

        //继承的模版
        if(my_template==null && template_can_be_empty)
        {
            need_to_rebuild = true;
        }

        if(need_to_rebuild)
        {
            //重建该栏目下的文章，并递归生成下级文章
            rows += GenerateMyArticles(top,true);
            List<Topic> childs = top.GetChilds();
            if(childs!=null)
            {
                for(Topic child:childs)
                {
                    rows += GenerateArticlesByTemplate(child,template,true);
                }
            }
        }
        else
        {
            //否则，查看下级栏目，如果下级栏目重新指定该模版，则也生成
            List<Topic> childs = top.GetChilds();
            if(childs!=null)
            {
                for(Topic child:childs)
                {
                    rows += GenerateArticlesByTemplate(child,template,false);
                }
            }
        }

        return rows;
    }

    //生成当前栏目下（不包括子栏目）的所有文章
    private int GenerateMyArticles(Topic top, boolean rebuildall)
    {
        int rows = 0;

        String art_id = null;
        String sql = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        //article表数据
        if(!top.IsCustom())
        {
            if(!rebuildall)
                sql = "select id from article where topic = ? and state = ?";
            else
                sql = "select id from article where topic = ? and state >= ?";
            try
            {
              pstmt = ctxt.GetConnection().prepareStatement(sql);
              pstmt.setString(1,top.GetId());
              pstmt.setInt(2,ARTICLE_CHECK);
              rs = pstmt.executeQuery();

              while(rs.next())
              {
                  art_id = rs.getString("id");
                  Article art = NormalArticle.GetArticle(ctxt, art_id);
                  if(rebuildall) art.EnableEvent(false); //重建整个栏目时禁用事件
                  try
                  {
                      GenerateArticle(art);
                      ctxt.Commit();

                      rows++;
                  }
                  catch(NpsException ne)
                  {
                      ctxt.Rollback();
                      PrintError("site:"+ctxt.GetSite().GetName()
                              +" topic:"+ top.GetName() +"("+top.GetId()+")"
                              +" article title:" + art.GetTitle()+"("+art_id+")");
                      PrintError(ne);
                  }
                  catch(Exception e)
                  {
                       ctxt.Rollback();
                       nps.util.DefaultLog.error_noexception("site:"+ctxt.GetSite().GetName()
                                                           +" topic:"+ top.GetName() +"("+top.GetId()+")"
                                                           +" article title:" + art.GetTitle()+"("+art_id+")");
                       nps.util.DefaultLog.error_noexception(e);

                       PrintError("site:"+ctxt.GetSite().GetName()
                               +" topic:"+ top.GetName() +"("+top.GetId()+")"
                               +" article title:" + art.GetTitle()+"("+art_id+")");
                       PrintError(e);
                  }
                  finally
                  {
                      art.Clear();
                  }
              }
            }
            catch(Exception e)
            {
               nps.util.DefaultLog.error_noexception("site:"+ctxt.GetSite().GetName()+" failed generate article in topic:"+ top.GetName() +"("+top.GetId()+")");
               nps.util.DefaultLog.error_noexception(e);

               PrintError("site:"+ctxt.GetSite().GetName()+" failed generate article in topic:"+ top.GetName() +"("+top.GetId()+")");
               PrintError(e);
            }
            finally
            {
                if(rs!=null) try{rs.close();}catch(Exception e){}
                if(pstmt!=null)try{pstmt.close();}catch(Exception e){}
            }
        }
        else  //自定义数据源
        {
          String prop_tablename = top.GetTable() + "_prop";
          if(!rebuildall)
              //sql = "select id from "+prop_tablename+" where topic=? and state=?";
              sql = "select a.*,b.title,b.topic,b.state,b.createdate,b.publishdate,b.url from "+top.GetTable()+" a,"+prop_tablename+" b where a.id=b.id and b.topic=? and b.state=?";
          else
              //sql = "select id from "+prop_tablename+" where topic=? and state>=?";
              sql = "select a.*,b.title,b.topic,b.state,b.createdate,b.publishdate,b.url from "+top.GetTable()+" a,"+prop_tablename+" b where a.id=b.id and b.topic=? and b.state>=?";

          try
          {
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,top.GetId());
            pstmt.setInt(2,ARTICLE_CHECK);
            rs = pstmt.executeQuery();

            while(rs.next())
            {
                art_id = rs.getString("id");
                //2008-04-11 jialin，调用CustomArticleHelper获得更顶级的自定义CustomArticle对象
                //Article art = CustomArticle.GetArticle(ctxt,top,art_id);
                CustomArticle art = CustomArticleHelper.GetHelper().NewInstance(ctxt,top,rs);
                if(rebuildall) art.EnableEvent(false); //重建整个栏目时禁用事件
                try
                {
                    GenerateArticle(art);
                    ctxt.Commit();

                    rows++;
                }
                catch(NpsException ne)
                {
                    ctxt.Rollback();
                    PrintError("site:"+ctxt.GetSite().GetName() +" topic:"+ top.GetName() +"("+top.GetId()+")" +" table:"+ top.GetTable() +" article id:" + art_id);
                    PrintError(ne);
                }
                catch(Exception e)
                {
                    ctxt.Rollback();
                    nps.util.DefaultLog.error_noexception("site:"+ctxt.GetSite().GetName()
                                                         +" topic:"+ top.GetName() +"("+top.GetId()+")"
                                                         +" table:"+top.GetTable()
                                                         +" article id:" + art_id);
                     nps.util.DefaultLog.error_noexception(e);

                     PrintError("site:"+ctxt.GetSite().GetName() +" topic:"+ top.GetName() +"("+top.GetId()+")" +" table:"+ top.GetTable() +" article id:" + art_id);
                     PrintError(e);
                }
                finally
                {
                    art.Clear();
                }
            }
          }
          catch(Exception e)
          {
              ctxt.Rollback();
              nps.util.DefaultLog.error_noexception("site:"+ctxt.GetSite().GetName()+" failed generate article in topic:"+ top.GetName() +"("+top.GetId()+")");
              nps.util.DefaultLog.error_noexception(e);

              PrintError("site:"+ctxt.GetSite().GetName()+" failed generate article in topic:"+ top.GetName() +"("+top.GetId()+")");
              PrintError(e);
          }
          finally
          {
              if(rs!=null) try{rs.close();}catch(Exception e){}
              if(pstmt!=null)try{pstmt.close();}catch(Exception e){}
          }
        }

        return rows;
    }
    
    //产生指定页面模板相关栏目的所有页面
    public void GeneratePages(PageTemplate template) throws Exception
    {
        if(template==null) return;

        List topics = template.GetTopics(ctxt);
        for(Object obj:topics)
        {
            TemplateBase.TopicProfile top_profile = (TemplateBase.TopicProfile)obj;

            try
            {
                Site asite = GetSite(top_profile.GetSiteId());
                if(asite==null) continue;

                Topic atopic = asite.GetTopicTree().GetTopic(top_profile.GetId());
                if(atopic==null) continue;

                PageClassBase aGenerator = null;
                try
                {
                    aGenerator = LoadPageClass(template, atopic);
                }
                catch (ClassNotFoundException e)
                {
                    //未找到，生成并编译
                    GeneratePageClassThenCompile(template);
                    aGenerator = LoadPageClass(template, atopic);
                }

                //生成页面
                aGenerator.service();
            }
            catch(NpsException ne)
            {
                PrintError("site:"+top_profile.GetSiteName()
                                                       +" topic:"+ top_profile.GetName() +"("+top_profile.GetId()+")"
                                                        +" page template:" + template.name +"("+ template.id +")");
                PrintError(ne);
            }
            catch(Exception e2)
            {
                nps.util.DefaultLog.error_noexception("site:"+top_profile.GetSiteName()
                                                       +" topic:"+ top_profile.GetName() +"("+top_profile.GetId()+")"
                                                        +" page template:" + template.name +"("+ template.id +")");
                nps.util.DefaultLog.error_noexception(e2);

                PrintError("site:"+top_profile.GetSiteName()
                                                       +" topic:"+ top_profile.GetName() +"("+top_profile.GetId()+")"
                                                        +" page template:" + template.name +"("+ template.id +")");
                PrintError(e2);
            }
        }
    }

    //取消文章
    public void CancelArticle(Article art) throws Exception
    {
        if(art==null) return;
        boolean can_do = false;

        //只有系统管理员、站点管理员、版主可以撤销文章
        if(    ctxt.GetUser().IsSysAdmin()
            || ctxt.GetUser().IsSiteAdmin(art.GetTopic().GetSiteId())
            || art.GetTopic().IsOwner(ctxt.GetUser().GetUID())    
          )
        {
            can_do = true;
        }

        if(!can_do)  throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

        try
        {
            art.Cancel();
        }
        finally
        {
            art.Clear();
        }
    }

    //删除文章
    public void  DeleteArticle(NormalArticle art) throws Exception
    {
        boolean can_do = false;

        //只有系统管理员、站点管理员、版主可以删除文章
        if(   ctxt.GetUser().IsSysAdmin()
            || ctxt.GetUser().IsSiteAdmin(art.GetTopic().GetSiteId())
            || art.GetTopic().IsOwner(ctxt.GetUser().GetUID())
          )
        {
            can_do = true;
        }
        else if(art.GetState()<3 && art.GetCreatorID().equals(ctxt.GetUser().GetId()))
        {
            //未发布的，作者也可以删除
            can_do = true;
        }

        if(!can_do)  throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

        try
        {
            art.Delete();
        }
        finally
        {
            art.Clear();
        }
    }

    //归档整个站点
    public void ArchiveSite(Site site)
    {
        TopicTree tree = site.GetTopicTree();
        if(tree==null) return;

        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = null;

        try
        {
            sql = "select id from topic Where archive_mode>0 And archive_template Is Not Null and siteid=?";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,site.GetId());
            rs = pstmt.executeQuery();
            while(rs.next())
            {
                String top_id = rs.getString("id");
                ArchiveTopic(tree.GetTopic(top_id));
            }
        }
        catch(Exception e)
        {
           nps.util.DefaultLog.error_noexception("Archive site:"+site.GetName()+" failed:");
           nps.util.DefaultLog.error_noexception(e);

           PrintError("Archive site:"+site.GetName()+" failed:");
           PrintError(e);
        }
        finally
        {
            if(rs!=null) try{rs.close();}catch(Exception e){}
            if(pstmt!=null)try{pstmt.close();}catch(Exception e){}
        }
    }

    //归档某个栏目
    public void ArchiveTopic(Topic top)
    {
        if(top == null)  return;
        //顶级栏目不生成,是一个虚拟节点
        if(top.GetId().equalsIgnoreCase("-1")) return;

        if(!top.IsArchive()) return;

        PageTemplate pt = top.GetArchiveTemplate();
        if(pt==null) return;

        PageClassBase aGenerator = null;
        try
        {
            try
            {
                aGenerator = LoadPageClass(pt, top);
            }
            catch (ClassNotFoundException e)
            {
                //未找到，生成并编译
                GeneratePageClassThenCompile(pt);
                aGenerator = LoadPageClass(pt, top);
            }

            //进入归档模式
            aGenerator.SetArchiveMode(top.GetArchiveMode());

            //生成页面
            aGenerator.service();
        }
        catch(NpsException ne)
        {
            PrintError("site:"+ctxt.GetSite().GetName() +" topic:"+ top.GetName() +"("+top.GetId()+")"
                   +" page template:" + pt.name +"("+ pt.id +")");
            PrintError(ne);
        }
        catch(Exception e2)
        {
            nps.util.DefaultLog.error_noexception("site:"+ctxt.GetSite().GetName()
                                                   +" topic:"+ top.GetName() +"("+top.GetId()+")"
                                                    +" page template:" + pt.name +"("+ pt.id +")");
            nps.util.DefaultLog.error_noexception(e2);

            PrintError("site:"+ctxt.GetSite().GetName() +" topic:"+ top.GetName() +"("+top.GetId()+")"
                   +" page template:" + pt.name +"("+ pt.id +")");
            PrintError(e2);
        }
    }

    //获得PageClass
    public PageClassBase GetPageClass(PageTemplate pt,Topic top) throws Exception
    {
        PageClassBase aGenerator = null;
        try
        {
            aGenerator = LoadPageClass(pt, top);
        }
        catch (ClassNotFoundException e)
        {
            //未找到，生成并编译
            GeneratePageClassThenCompile(pt);
            aGenerator = LoadPageClass(pt, top);
        }
        return aGenerator;
    }

    //根据模版生成Article类并编译
    public void GeneratePageClassThenCompile(PageTemplate template) throws Exception
    {
        PageClassGenerator aGenerator = new PageClassGenerator(ctxt, template);
        aGenerator.Generate();

        //reload class
        template.GetClass(true);
    }

    //Page class定义在nps.runtime包下，以PAGE+temlate_id命名
    private PageClassBase LoadPageClass(PageTemplate pt,Topic top) throws Exception
    {
        Class clazz = pt.GetClass(false);
        java.lang.reflect.Constructor aconstructor=clazz.getConstructor(new Class[]{NpsContext.class,Topic.class});
        return (PageClassBase)aconstructor.newInstance(new Object[]{ctxt,top});
    }

    //Page class定义在nps.runtime包下，以PAGE+temlate_id命名
    private PageClassBase LoadPageClass(PageTemplate pt,Topic top,File output) throws Exception
    {
        Class clazz = pt.GetClass(false);
        java.lang.reflect.Constructor aconstructor=clazz.getConstructor(new Class[]{NpsContext.class,Topic.class,File.class});
        return (PageClassBase)aconstructor.newInstance(new Object[]{ctxt,top,output});
    }

    //执行通用模板，根据模板替换生成字符串返回
    public String RunTemplate(CommonTemplate template) throws Exception
    {
        if(template == null)  return null;

        CommonClassBase aGenerator = null;
        try
        {
            aGenerator = LoadCommonTemplateClass(template);
        }
        catch (ClassNotFoundException e)
        {
            //未找到，生成并编译
            GenerateCommonClassThenCompile(template);
            aGenerator = LoadCommonTemplateClass(template);
        }

        aGenerator.service();
        return aGenerator.GetResult();
    }

    //执行通用模板，根据模板替换输出到指定文件
    public void RunTemplate(CommonTemplate template,File output) throws Exception
    {
        if(template == null || output == null)  return;

        CommonClassBase aGenerator = null;
        try
        {
            aGenerator = LoadCommonTemplateClass(template,output);
        }
        catch (ClassNotFoundException e)
        {
            //未找到，生成并编译
            GenerateCommonClassThenCompile(template);
            aGenerator = LoadCommonTemplateClass(template,output);
        }

        aGenerator.service();
    }

    //根据模版生成通用模板类并编译
    private void GenerateCommonClassThenCompile(CommonTemplate template) throws Exception
    {
        CommonClassGenerator aGenerator = new CommonClassGenerator(ctxt, template);
        aGenerator.Generate();

        //reload class
        GetCommonTemplateClass(template,true);
    }

    //加载通用模板
    private CommonClassBase LoadCommonTemplateClass(CommonTemplate template) throws Exception
    {
        Class clazz = GetCommonTemplateClass(template,false);
        java.lang.reflect.Constructor aconstructor=clazz.getConstructor(new Class[]{NpsContext.class});
        return (CommonClassBase)aconstructor.newInstance(new Object[]{ctxt});
    }

    private CommonClassBase LoadCommonTemplateClass(CommonTemplate template,File output) throws Exception
    {
        Class clazz = GetCommonTemplateClass(template,false);
        java.lang.reflect.Constructor aconstructor=clazz.getConstructor(new Class[]{NpsContext.class,File.class});
        return (CommonClassBase)aconstructor.newInstance(new Object[]{ctxt,output});
    }

    private Class GetCommonTemplateClass(CommonTemplate template,boolean reload) throws Exception
    {
        String class_name = "nps.runtime."+template.GetClassName();
        if(reload) return ctxt.GetClassLoader().ReloadClass(class_name);
        return ctxt.GetClassLoader().loadClass(class_name);
    }

    //自底向上生成所有栏目文章
    public int GenerateAllArticles(String top_id,boolean rebuildall)
    {
        if(top_id == null) return 0;
        return GenerateAllArticles(ctxt.GetSite().GetTopicTree().GetTopic(top_id),rebuildall);
    }

    public int GenerateAllArticles(Topic top,boolean rebuildall)
    {
        int rows = GenerateArticle(top,rebuildall);

        //重建父栏目的所有文章
        Topic parent = top.GetParent();
        if(parent!=null)  rows += GenerateAllArticles(parent,rebuildall);

        return rows;
    }

    //自顶向下生成所有栏目文章
    public int GenerateAllArticlesTopDown(String top_id,boolean rebuildall)
    {
        if(top_id == null) return 0;
        return GenerateAllArticlesTopDown(ctxt.GetSite().GetTopicTree().GetTopic(top_id),rebuildall);
    }

    public int GenerateAllArticlesTopDown(Topic top,boolean rebuildall)
    {
        int rows = GenerateArticle(top,rebuildall);

        //重建子栏目
        List<Topic> childs = top.GetChilds();
        if(childs!=null && !childs.isEmpty())
        {
            for(Topic child:childs)
            {
                rows += GenerateAllArticlesTopDown(child,rebuildall);
            }
        }
        return rows;
    }

    //生成某个栏目ID下的所有文章
    public int GenerateArticle(String top_id,boolean rebuildall)
    {
        if(top_id == null) return 0;
        return GenerateArticle(ctxt.GetSite().GetTopicTree().GetTopic(top_id),rebuildall);
    }

    //产生栏目top下的文章，但不递归生成
    public int GenerateArticle(Topic top,boolean rebuildall)
    {
        int rows = 0;
        if(top == null)  return rows;        

        //没有文章模版的，我们将不建
        if(top.GetCascadedArticleTemplate()==null) return rows;

        return GenerateMyArticles(top,rebuildall);
    }

    //生成文章，放在缺省位置
    public void GenerateArticle(Article art) throws Exception
    {
        if(art == null) return;
        
        //没有栏目信息或栏目文章模版为空
        if(art.GetTopic()==null) return;

        //2010.03.18 如果文章是外部链接，直接设置发布状态，不生成文章
        if(art.IsExternalLink())
        {
            //准备发布
            art.Prepare4Publish();

            //数据具设置为发布状态，同时更新article的publish日期等信息
            art.ChangeState(ARTICLE_PUBLISH);
            ctxt.Commit();
            return;
        }
        
        ArticleTemplate aTemplate =  art.GetTopic().GetCascadedArticleTemplate();
        if(aTemplate==null)
        {
            DefaultLog.error_noexception("Error during generation: No Article Template(id="+art.GetId()+",topic="+art.GetTopic().GetName()+")");
            PrintError("Error during generation: No Article Template(id="+art.GetId()+",topic="+art.GetTopic().GetName()+")");
            return;
        }

        //内置空白模版，不生成文章，直接发布
        if("0".equals(aTemplate.GetId()))
        {
            //准备发布
            art.Prepare4Publish();

            //数据具设置为发布状态，同时更新article的publish日期等信息
            art.ChangeState(ARTICLE_PUBLISH);
            ctxt.Commit();
            return;
        }

        //准备发布
        art.Prepare4Publish();

        //数据具设置为发布状态，同时更新article的publish日期等信息
        art.ChangeState(ARTICLE_PUBLISH);

        //提交生成页面
        BuildTask task = new BuildTask(art,ctxt.GetUser());
        BuildController.AddTask(art.GetSite().GetId(),task);
    }

    public void _GenerateArticle(Article art) throws Exception
    {
        if(art == null) return;

        //没有栏目信息或栏目文章模版为空
        if(art.GetTopic()==null) return;

        //2010.03.18 如果文章是外部链接，直接设置发布状态，不生成文章
        if(art.IsExternalLink()) return;

        ArticleTemplate aTemplate =  art.GetTopic().GetCascadedArticleTemplate();
        if(aTemplate==null) return;

        //内置空白模版，不生成文章，直接发布
        if("0".equals(aTemplate.GetId())) return;

        ArticleClassBase aGenerator = null;
        try
        {
            aGenerator = LoadArticleClass(art);
        }
        catch(ClassNotFoundException e)
        {
            //未找到，生成并编译
            GenerateArticleClassThenCompile(aTemplate);
            aGenerator = LoadArticleClass(art);
        }

        //生成页面
        aGenerator.service();
    }

    //生成文章，输出到outputFileName指定的文件,outputFileName是个绝对路径
    //  无法得知outputFileName和当前默认路径的关系，也无法得知上传路径
    //  文件生成到outputFileName后，将不被自动加载到FTP服务器，如果需要，手工上载
    //  art.GetURL()计算路径有差异，也需要手工计算
    //
    public void GenerateArticle(Article art,File output) throws Exception
    {
        if(art == null) return;
        //没有栏目信息或栏目文章模版为空
        if(art.GetTopic()==null) return;

        if(art.IsExternalLink()) return;

        ArticleTemplate aTemplate =  art.GetTopic().GetCascadedArticleTemplate();
        if(aTemplate==null)
        {
            DefaultLog.error_noexception("Error during generation: No Article Template(id="+art.GetId()+",topic="+art.GetTopic().GetName()+")");
            PrintError("Error during generation: No Article Template(id="+art.GetId()+",topic="+art.GetTopic().GetName()+")");
            return;
        }

        //内置空白模版，不生成文章
        if("0".equals(aTemplate.GetId())) return;

        ArticleClassBase aGenerator = null;
        try
        {
            aGenerator = LoadArticleClass(art,output);
        }
        catch(ClassNotFoundException e)
        {
            //未找到，生成并编译
            GenerateArticleClassThenCompile(aTemplate);
            aGenerator = LoadArticleClass(art,output);
        }

        //生成页面
        aGenerator.GenerateFilesOnly();
    }   

    //根据模版生成Article类并编译
    public void GenerateArticleClassThenCompile(ArticleTemplate template) throws Exception
    {
        //内置空白模版
        if("0".equals(template.GetId())) return;
        
        ArticleClassGenerator aGenerator = new ArticleClassGenerator(ctxt, template);
        aGenerator.Generate();

        //reload class
        template.GetClass(true);
    }

    //Article class定义在nps.runtime包下，以Article+temlate_id命名
    private ArticleClassBase LoadArticleClass(Article art) throws Exception
    {
        ArticleTemplate template = art.GetTopic().GetCascadedArticleTemplate();
        if(template==null) return null;

        //内置空白模版
        if("0".equals(template.GetId())) return null;
        
        Class clazz = template.GetClass(false);
        java.lang.reflect.Constructor aconstructor=clazz.getConstructor(new Class[]{NpsContext.class,Article.class});
        return (ArticleClassBase)aconstructor.newInstance(new Object[]{ctxt,art});
    }

    //Article class定义在nps.runtime包下，以Article+temlate_id命名
    private ArticleClassBase LoadArticleClass(Article art,File output) throws Exception
    {
        ArticleTemplate template = art.GetTopic().GetCascadedArticleTemplate();
        if(template==null) return null;

        //内置空白模版
        if("0".equals(template.GetId())) return null;

        Class clazz = template.GetClass(false);
        java.lang.reflect.Constructor aconstructor=clazz.getConstructor(new Class[]{NpsContext.class,Article.class,File.class});
        return (ArticleClassBase)aconstructor.newInstance(new Object[]{ctxt,art,output});
    }

    //获得目前默认的站点
    public Site GetSite() throws NpsException
    {
        return ctxt.GetSite();
    }
    
    //根据指定ID加载Site
    public Site GetSite(String id) throws NpsException
    {
        return ctxt.GetSite(id);    
    }

    //新建文章
    public NormalArticle NewNormalArticle(String title,String top_id,User creator) throws Exception
    {
        Topic top = GetSite().GetTopicTree().GetTopic(top_id);
        return new NormalArticle(ctxt,title,top,creator);
    }
    //新建文章
    public ProductArticle NewProductArticle(String title,String top_id,User creator) throws Exception
    {
        Topic top = GetSite().GetTopicTree().GetTopic(top_id);
        return new ProductArticle(ctxt,title,top,creator);
    }
    public NormalArticle GetArticle(String id) throws Exception
    {
        return NormalArticle.GetArticle(ctxt,id);    
    }
    public ProductArticle GetProductArticle(String id) throws Exception
    {
        return ProductArticle.GetArticle(ctxt,id);    
    }

    public CustomArticle GetArticle(String id,Topic t) throws Exception
    {
        return CustomArticle.GetArticle(ctxt,t,id);
    }

    public Resource GetResource(String id) throws Exception
    {
        return new Resource(ctxt,id);
    }

    //新建文章模版
    public ArticleTemplate NewArticleTemplate(String name,User creator,int scope,String siteid,String suffix) throws Exception
    {
        return ArticleTemplate.GetTemplate(ctxt,name,creator,scope,siteid,suffix); 
    }

    //新建页面模版
    public PageTemplate NewPageTemplate(String name,String fname,User creator,int scope,String siteid) throws Exception
    {
        return PageTemplate.GetTemplate(ctxt,name,fname,creator,scope,siteid); 
    }

    public TemplateBase GetTemplate(String id) throws NpsException
    {
        return ctxt.GetTemplate(id);    
    }

    public ArticleTemplate GetArticleTemplate(String id) throws NpsException
    {
        return ctxt.GetArticleTemplate(id);
    }

    public PageTemplate GetPageTemplate(String id) throws NpsException
    {
        return ctxt.GetPageTemplate(id);
    }    

    //在当前站点下新建栏目，但未包含页面模板
    public Topic NewTopic(String siteid,String parentid,String name,String alias,int index,String tname,String art_template,int art_state,float art_score) throws Exception
    {
        TopicTree tree = ctxt.GetSite(siteid).GetTopicTree();
        ArticleTemplate aTemplate = GetArticleTemplate(art_template);
        
        Topic aTopic = tree.NewTopic(ctxt,parentid,name,alias,index,tname,aTemplate,art_state,art_score);
        return aTopic;
    }

    public void SaveTopic(Topic t,boolean bNew) throws NpsException
    {
        if(t==null) return;
        t.GetSite().GetTopicTree().Save(ctxt,t,bNew);
    }
         
    public void DeleteTopic(Topic t) throws NpsException
    {
        TopicTree tree = t.GetSite().GetTopicTree();
        tree.Delete(ctxt,t);
    }


    //保存站点信息
    public void SaveSite(Site site,boolean bNew) throws NpsException
    {
        ctxt.SaveSite(site,bNew);    
    }

    //删除站点信息
    public void DeleteSite(Site site) throws NpsException
    {
        ctxt.DeleteSite(site);    
    }

    //冻结站点
    public void FreezeSite(Site site) throws NpsException
    {
        if(site==null) return;
        site.Freeze(ctxt);
    }

    //解冻站点
    public void DefreezeSite(Site site) throws NpsException
    {
        if(site==null) return;
        site.Defreeze(ctxt);
    }

    //导出站点到指定的文件名
    public void Export(String filename) throws Exception
    {
        Export(new FileOutputStream(filename));
    }

    //导出指定站点到指定的文件名
    public void Export(String site_id,String filename)  throws Exception
    {
         Export(GetSite(site_id),new FileOutputStream(filename));
    }

    //导出站点并写入OutputStream
    public void Export(OutputStream out_stream)  throws Exception
    {
       Export(GetSite(),out_stream);
    }

    //导出指定站点并写入outputStream
    public void Export(String site_id,OutputStream out_stream) throws Exception
    {
        Export(GetSite(site_id),out_stream);
    }

    private void Export(Site site,OutputStream out_stream)  throws Exception
    {
        if(site==null)  return;
        ZipOutputStream out = new ZipOutputStream(out_stream);
        try
        {
            //站点配置、栏目、模板信息
            site.Zip(ctxt,out);

            //FCKTemplates
            FCKTemplateManager.ZipFCKTemplates(ctxt,out,site.GetUnit().GetId());

            //Trigggers
            TriggerManager.ZipTriggers(ctxt,out,site.GetId());

            //jobs
            JobScheduler.ZipJobs(ctxt,out,site.GetId());
        }
        finally
        {
            try{out.close();}catch(Exception e){}
        }
    }

    //从指定文件导入站点
    public Site Import(String filename) throws Exception
    {
        return Import(new File(filename));
    }
    
    //从指定文件导入站点
    public Site Import(File f) throws Exception
    {
        if(!f.exists()) return null;
        ZipFile zipFile = new ZipFile(f);
        try
        {
            //1.加载单位、站点配置、栏目、模板信息
            Site asite = ctxt.GetSite(zipFile,ctxt.GetUser());

            //2.加载FCKTemplates
            FCKTemplateManager.GetTemplates(ctxt,zipFile,ctxt.GetUser());

            //3.加载Triggers
            TriggerManager.LoadTriggers(ctxt,zipFile,asite,ctxt.GetUser());

            //4.加载作业列表
            JobScheduler.GetJobs(ctxt,zipFile,asite,ctxt.GetUser());

            //5.提交
            Commit();
            
            return asite;
        }
        catch(Exception e)
        {
            Rollback();
            throw e;
        }
        finally
        {
            try{zipFile.close();}catch(Exception e){}
        }
    }

    //同步并发布文章
    public int SyncDatasource(Topic topic) throws NpsException
    {
        if(topic==null) throw new NpsException(ErrorHelper.SYS_NOTOPIC);
        if(!topic.IsCustom()) throw new NpsException(ErrorHelper.SYS_NEED_CUSTOM_TOPIC);

        PreparedStatement pstmt = null;
        String table = topic.GetTable();
        String table_prop = topic.GetTable() + "_prop";
        String sql = "insert into " + table_prop + "(id,title,siteid,topic,state,createdate)"
                + " select id,id,?,?,?,sysdate from " + table + " a where not exists(select id from " + table_prop + " b where a.id=b.id)";

        int rows = 0;

        try
        {
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,topic.GetSiteId());
            pstmt.setString(2,topic.GetId());
            pstmt.setInt(3,ARTICLE_CHECK);//默认设置为待发布状态
            rows = pstmt.executeUpdate();
            ctxt.Commit();

            //发布所有文章
            rows = GenerateArticle(topic,false);
            GeneratePages(topic);
        }
        catch(Exception e)
        {
            rows = 0;
            ctxt.Rollback();
            
            PrintError(e);
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            if(pstmt!=null) try{pstmt.close();}catch(Exception e){}
        }

        return rows;
    }
    
    //提交事务
    public void Commit()
    {
        ctxt.Commit();    
    }

    //失败后回滚
    public void Rollback()
    {
        ctxt.Rollback();
    }

    //释放所有资源
    public void Clear()
    {
        ctxt.Clear();
    }

    //错误处理函数
    public void SetLineSeperator(String s)
    {
        line_seperator = s;
    }

    public void SetErrorHandler(PrintWriter pw)
    {
        error_handler = pw;
    }

    private void PrintError(String s)
    {
        bError = true;
        if(error_handler==null) return;

        error_handler.print(line_seperator);
        error_handler.print(s);
        error_handler.print(line_seperator);        
        error_handler.flush();
    }

    private void PrintError(Exception e)
    {
        bError = true;
        if(error_handler==null) return;

        error_handler.print(line_seperator);
        error_handler.print(e.toString());
        
        StackTraceElement[] stackElements = e.getStackTrace();
        for (int index = 0; index < stackElements.length; index++)
        {
            error_handler.print(line_seperator);
            error_handler.print(" at " + stackElements[index].toString());
        }

        error_handler.print(line_seperator);
        error_handler.flush();
    }

    public boolean HasError()
    {
        return bError;
    }
}
