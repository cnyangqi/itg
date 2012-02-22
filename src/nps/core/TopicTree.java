package nps.core;

import nps.exception.NpsException;
import nps.exception.ErrorHelper;
import nps.util.tree.Node;
import nps.util.tree.Tree;
import nps.util.Utils;
import nps.event.*;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.Enumeration;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;
import java.util.zip.ZipFile;
import java.io.*;

/**
 * 2010.01.25 jialin
 *  修改Visible范围为公开、本单位内可见、隐藏
 *  调整toDHXTree()函数，实现打印所有节点、打印全部公开节点、打印所有可见节点功能
 * 
 * 2009.10.08 jialin
 *   数据导入时，如果栏目已存在，不再抛出错误，而是对当前栏目信息进行覆盖
 *
 * NPS - a new publishing system
 * Copyright (c) 2007

 * @author jialin, lanxi justa network co.,ltd.
 * @version 1.0
 */

public class TopicTree implements IPortable,Serializable
{
    public enum ViewMode {PUBLIC,VISIBLE,ALL};
    
    private Site site  = null;
    private String treename = null;
    private Tree  tree = null;//树型结构存储对象

    //为了加快检索速度,同时在Hashtable中存储对象
    private Hashtable ids = new Hashtable(); //以id为索引对象
    private Hashtable codes = new Hashtable(); //以topcode为索引对象

    private Hashtable templates = new Hashtable(); //以id索引的template列表

    public TopicTree(Site site,String treename)
    {
        this.site = site;
        this.treename = treename;
        this.tree = Tree.GetTree("-1");        
    }

    //增加一个Topic
    public void AddTopic(Topic t)
    {
        if(tree == null) tree = Tree.GetTree("-1");

        String parentid = "-1";
        if(t.GetParentId()!=null)  parentid = t.GetParentId();
        tree.AddNode(t.GetId(),tree.GetNode(parentid),t);

        ids.put(t.GetId(),t);
        codes.put(t.GetCode(),t);

        AddTemplate(t.GetArticleTemplate());
        if(t.GetPageTemplates()!=null)
        {
            for(Object obj:t.GetPageTemplates())
            {
                AddTemplate((PageTemplate)obj);
            }
        }
    }

    //加入Template缓冲
    private void AddTemplate(TemplateBase t)
    {
        if(t==null) return;
        if(templates.containsKey(t.GetId())) templates.remove(t.GetId());
        templates.put(t.GetId(),t);
    }


    public TemplateBase GetTemplate(String template_id)
    {
        if(templates.containsKey(template_id)) return (TemplateBase)templates.get(template_id);
        return null;
    }

    public Tree GetTree()
    {
        return tree;
    }

    public Topic GetTopic(String id)
    {
        return (Topic)ids.get(id);
    }

    public Topic GetTopicByCode(String code)
    {
        return (Topic)codes.get(code);
    }

    private Node GetNodeByTopic(Topic t)
    {
        return tree.GetNode(t.GetId());
    }
    
    public Site GetSite()
    {
        return site;
    }

    public String GetSiteId()
    {
        return site.GetId();
    }
   
    //Load Node Info from db
    public static TopicTree LoadTree(NpsContext inCtxt,Site site,String treename) throws NpsException
    {
        TopicTree aTopicTree = new TopicTree(site,treename);

        PreparedStatement pstmt = null;
        ResultSet rs = null;
        PreparedStatement pstmt_pts = null;
        ResultSet rs_pts = null;
        try
        {
            //自动修正1.3之前版本中的layer参数
            aTopicTree.CorrectLayerInDB(inCtxt);

            //Load Topic Information
            String sql = "select * from topic where siteid=? order by layer,idx";
            pstmt = inCtxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,site.GetId());
            rs = pstmt.executeQuery();

            while(rs.next())
            {
                //将空节点都挂在rootTopic下
                String parent_top_id = rs.getString("parentid");
                parent_top_id = parent_top_id==null?"-1":parent_top_id;

                Topic aTopic = new Topic(site,
                                         parent_top_id,
                                         rs.getString("id"),
                                         rs.getString("name"),
                                         rs.getString("alias"),
                                         rs.getString("code"),
                                         rs.getInt("idx"),
                                         rs.getInt("is_business")
                                         );

                //设置文章缺省状态
                if(rs.getString("default_article_state")!=null)
                    aTopic.SetDefaultArticleState(rs.getInt("default_article_state"));

                //设置栏目缺省分值
                if(rs.getString("default_article_score")!=null)
                    aTopic.SetScore(rs.getFloat("default_article_score"));

                //其他数据源表加载table信息
                if(rs.getString("tname")!=null)
                {
                    aTopic.SetTable(rs.getString("tname"));
                }

                //文章模版
                if(rs.getString("art_template")!=null)
                {
                   ArticleTemplate aArticleTemplate = (ArticleTemplate)TemplatePool.GetPool().get(rs.getString("art_template"));
                   if(aArticleTemplate==null)   aArticleTemplate = (ArticleTemplate)TemplatePool.GetPool().LoadTemplate(inCtxt,rs.getString("art_template"));

                   aTopic.SetArticleTemplate( aArticleTemplate );
                }

                //设置用户是否可见
                aTopic.SetVisibility(rs.getInt("visible"));

                //设置归档方案
                aTopic.SetArchiveMode(rs.getInt("archive_mode"));
                if(rs.getString("archive_template")!=null)
                {
                    PageTemplate archiveTemplate = (PageTemplate) TemplatePool.GetPool().get(rs.getString("archive_template"));
                    if(archiveTemplate==null) archiveTemplate = (PageTemplate)TemplatePool.GetPool().LoadTemplate(inCtxt,rs.getString("archive_template"));

                    aTopic.SetArchiveTemplate(archiveTemplate);
                }

                aTopic.SetSolrEnabled(rs.getInt("solr_enabled"));
                aTopic.SetSolrCore(rs.getString("solr_core"));

                aTopic.SetSortEnabled(rs.getInt("sort_enabled"));
                
                //加载所有页面模版
                sql = "select b.id,b.name,b.fname from topic_pts a,template b where a.topid=? and b.type=2 and a.templateid=b.id";
                pstmt_pts = inCtxt.GetConnection().prepareStatement(sql);
                pstmt_pts.setString(1,rs.getString("id"));
                rs_pts = pstmt_pts.executeQuery();
                while(rs_pts.next())
                {
                   PageTemplate aPageTemplate = (PageTemplate)TemplatePool.GetPool().get(rs_pts.getString("id"));
                   if(aPageTemplate==null)  aPageTemplate = (PageTemplate) TemplatePool.GetPool().LoadTemplate(inCtxt,rs_pts.getString("id"));

                   aTopic.AddPageTemplate(aPageTemplate);
                }//while(rs_pts.next());

                if(rs_pts!=null) try{rs_pts.close();}catch(Exception e){}
                if(pstmt_pts!=null)try{pstmt_pts.close();}catch(Exception e){}

                //加载栏目版主
                sql = "select b.id,b.name from topic_owner a,users b where a.topid=? and a.userid=b.id order by b.cx";
                pstmt_pts = inCtxt.GetConnection().prepareStatement(sql);
                pstmt_pts.setString(1,rs.getString("id"));
                rs_pts = pstmt_pts.executeQuery();
                while(rs_pts.next())
                {
                    aTopic.AddOwner(rs_pts.getString("id"),
                                    rs_pts.getString("name"));
                }//while(rs_pts.next());

                if(rs_pts!=null) try{rs_pts.close();}catch(Exception e){}
                if(pstmt_pts!=null)try{pstmt_pts.close();}catch(Exception e){}

                //加载自定义变量信息
                sql = "select * from topic_vars where topid=? order by varname";
                pstmt_pts = inCtxt.GetConnection().prepareStatement(sql);
                pstmt_pts.setString(1,rs.getString("id"));
                rs_pts = pstmt_pts.executeQuery();
                while(rs_pts.next())
                {
                    aTopic.AddVar(rs_pts.getString("varname"),rs_pts.getString("value"),rs_pts.getString("varcomment"));
                }
                
                if(rs_pts!=null) try{rs_pts.close();}catch(Exception e){}
                if(pstmt_pts!=null)try{pstmt_pts.close();}catch(Exception e){}                

                //加载Solr Fields
                sql = "select * from topic_solr where topid=?  order by fieldname";
                pstmt_pts = inCtxt.GetConnection().prepareStatement(sql);
                pstmt_pts.setString(1,rs.getString("id"));
                rs_pts = pstmt_pts.executeQuery();
                while(rs_pts.next())
                {
                    aTopic.AddSolrField(rs_pts.getString("fieldname"),rs_pts.getString("fieldcomment"));
                }

                if(rs_pts!=null) try{rs_pts.close();}catch(Exception e){}
                if(pstmt_pts!=null)try{pstmt_pts.close();}catch(Exception e){}

                //加载热字
                sql = "select * from keyword_link where topic=?";
                pstmt_pts = inCtxt.GetConnection().prepareStatement(sql);
                pstmt_pts.setString(1,rs.getString("id"));
                rs_pts = pstmt_pts.executeQuery();
                while(rs_pts.next())
                {
                    aTopic.AddKeywordLink(rs_pts.getString("keyword"),rs_pts.getString("url"));
                }

                if(rs_pts!=null) try{rs_pts.close();}catch(Exception e){}
                if(pstmt_pts!=null)try{pstmt_pts.close();}catch(Exception e){}

                aTopicTree.AddTopic(aTopic);
            }//while(rs.next());

            //2008.05.30 增加树排序
            //aTopicTree.tree.Sort();
        }
        catch(Exception e)
        {
            //2008.01.05,即使中途出错，无论如何返回当前加载的内容
            //aTopicTree = null;
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            if(rs_pts!=null) try{rs_pts.close();}catch(Exception e){}
            if(pstmt_pts!=null)try{pstmt_pts.close();}catch(Exception e){}
            if(rs!=null) try{rs.close();}catch(Exception e){}
            if(pstmt!=null)try{pstmt.close();}catch(Exception e){}
        }

        return aTopicTree;
    }

    //在当前站点下新建栏目，但未包含页面模板
    public Topic NewTopic(NpsContext ctxt,String parentid,String name,String alias,int index,String tname,ArticleTemplate art_template,int art_state,float art_score,int isBusiness) throws Exception
    {
        if(parentid==null || parentid.length()==0)  parentid = "-1";
        String code = GenerateTopicCode(parentid,alias);
        String id = GenerateTopicId(ctxt);
        Topic aTopic = new Topic(site,parentid,id,name,alias,code,index,isBusiness);
        aTopic.SetArticleTemplate(art_template);
        aTopic.SetTable(tname);
        aTopic.SetDefaultArticleState(art_state);
        aTopic.SetScore(art_score);
        return aTopic;
    }
  //在当前站点下新建栏目，但未包含页面模板
    public Topic NewTopic(NpsContext ctxt,String parentid,String name,String alias,int index,String tname,ArticleTemplate art_template,int art_state,float art_score) throws Exception
    {
        if(parentid==null || parentid.length()==0)  parentid = "-1";
        String code = GenerateTopicCode(parentid,alias);
        String id = GenerateTopicId(ctxt);
        Topic aTopic = new Topic(site,parentid,id,name,alias,code,index);
        aTopic.SetArticleTemplate(art_template);
        aTopic.SetTable(tname);
        aTopic.SetDefaultArticleState(art_state);
        aTopic.SetScore(art_score);
        return aTopic;
    }
    //为新栏目生成唯一ID号
    private String GenerateTopicId(NpsContext ctxt)  throws NpsException
    {
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try
        {
            //Load Topic Information
            String sql = "select seq_topic.nextval topid from dual";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            rs = pstmt.executeQuery();
            if(rs.next())
            {
                return  rs.getString("topid");
            }
        }
        catch(Exception e)
        {
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            if(rs!=null) try{rs.close();}catch(Exception e){}
            if(pstmt!=null)try{pstmt.close();}catch(Exception e){}
        }

        return null;
    }

    //topic code总是以父节点的code+"."+当前节点的alias命名
    public String GenerateTopicCode(String top_parentid,String alias) throws NpsException
    {
        //如果是根节点
        if("-1".equals(top_parentid)) return alias;
        
        Topic parent = GetTopic(top_parentid);
        return GenerateTopicCode(parent,alias);
    }

    public String GenerateTopicCode(Topic parent,String alias) throws NpsException
    {
        if(parent==null) return alias;
        if("-1".equals(parent.GetId())) return alias;
        if(parent.GetCode()==null)  return alias;

        String code_try = parent.GetCode() + "." + alias;
        if(GetTopicByCode(code_try)!=null)
        {
            //已经有栏目使用同名的alias了
            throw new NpsException("alias for topic exists:"+alias,ErrorHelper.SYS_INVALIDTOPICALIAS);
        }
        return code_try;
    }

    //为栏目自动排序计数
    public int GenerateTopicIndex(String top_parentid)
    {
        //为空就转换为根节点
        if(top_parentid==null || top_parentid.length()==0)  top_parentid="-1";

        Node parent_node = tree.GetNode(top_parentid);
        if(parent_node==null) return 1;
        
        Iterator childs = parent_node.GetChilds();
        if(childs==null) return 1;
        int max_index = 0;
        while(childs.hasNext())
        {
            Node top_node = (Node)childs.next();
            Topic top = (Topic)top_node.GetValue();
            if(top.GetIndex()>max_index)  max_index=top.GetIndex();
        }

        return max_index+1;
    }

    public int GenerateTopicIndex(Topic parent)
    {
        if(parent==null) return 1;
        return  GenerateTopicIndex(parent.GetId());
    }

    //得到当前栏目所在的层数
    // layer从0开始计数
    public int GetLayer(Topic topic)
    {
        return GetLayer(topic.GetCode());
    }

    //计算当前栏目代号中包含.的个数
    public int GetLayer(String top_code)
    {
        int layer = 0;
        int pos_dot = top_code.indexOf(".");
        if(pos_dot==-1) return layer;

        while(pos_dot!=-1)
        {
            layer++;
            pos_dot = top_code.indexOf(".",pos_dot+1);
        }

        return layer;
    }

    //保存Topic
    public void Save(NpsContext inCtxt,Topic t,boolean bNew)  throws NpsException
    {
        if(bNew)
        {
            SaveTopic(inCtxt,t);
        }
        else
        {
           UpdateTopic(inCtxt,t);
        }

        UpdateTopicPageTemplate(inCtxt,t);
        UpdateTopicOwners(inCtxt,t);
        UpdateTopicVars(inCtxt,t);
        UpdateTopicSolrFields(inCtxt,t);
        UpdateTopicKeywordLinks(inCtxt,t);

        //inCtxt.Commit();

        //如果保存成功，自动加入TopicTree
        if(bNew)
        {
            //新增时候增加侦听，其他时候仅在Config首次启动时加载
            if(t.GetMyTable()!=null && t.GetMyTable().length()>0)
            {
                //2008.01.19 贾林，订阅事件
                String key = t.GetMyTable().toUpperCase();

                //对表的各类更新事件感兴趣
                EventSubscriber.GetSubscriber().AddListener((InsertEventListener)t,key);
                EventSubscriber.GetSubscriber().AddListener((UpdateEventListener)t,key);
                EventSubscriber.GetSubscriber().AddListener((DeleteEventListener)t,key);
                EventSubscriber.GetSubscriber().AddListener((Ready2PublishEventListener)t,key);
                EventSubscriber.GetSubscriber().AddListener((PublishEventListener)t,key);
                EventSubscriber.GetSubscriber().AddListener((CancelEventListener)t,key);
            }
            
            AddTopic(t);
        }

        //2009.06.26 如果为顶级节点，对-1下的所有节点排序
        tree.Sort(t.GetParent()==null?"-1":t.GetParent().GetId());

        //创建外部数据源状态记录表
        //CREATE,ALTER,DROP,GRANT,REVOKE 隐含的提交当前事务，并且开始一个自动提交的事务
        CreateDsTable(inCtxt,t);
    }

    //更新Topic
    public void Update(NpsContext inCtxt,Topic t) throws NpsException
    {
        Save(inCtxt,t,false);
    }

    //删除栏目，将自动删除下级所有栏目
    public void Delete(NpsContext ctxt,Topic t) throws NpsException
    {
        if(t==null) return;
        
        Node node = GetNodeByTopic(t);
        if(node==null) return;

        //1.从数据库和IDS、CODES索引中删除对象
        DeleteNode(ctxt,node);

        //Attention:一旦有外部数据源，以上事务将自动提交
        //2.如果是外部数据源，删除外部数据源表
        //不放在DeleteNode中删除是为了事务回滚
        try
        {
            DeleteNodeTables(ctxt,node);
        }
        catch(Exception e)
        {
            nps.util.DefaultLog.error_noexception(e);
        }

        //3.从内存中删除id/codes索引
        DeleteNode(node);

        //4.删除树型节点
        tree.RemoveNode(node);
    }

    //从最下级节点开始删除，一直回溯
    private void DeleteNode(NpsContext ctxt,Node node) throws NpsException
    {
        if(node.HasChilds())
        {
            Iterator childs = node.GetChilds();
            while(childs.hasNext())
            {
                Node child_node = (Node)childs.next();
                DeleteNode(ctxt,child_node);
            }
        }

        Topic t = (Topic)node.GetValue();

        //2008.01.19 贾林，自定义数据源删除事件订阅
        if(t.GetMyTable()!=null && t.GetMyTable().length()>0)
        {
            EventSubscriber.GetSubscriber().RemoveListener(InsertEventListener.class,t);
            EventSubscriber.GetSubscriber().RemoveListener(UpdateEventListener.class,t);
            EventSubscriber.GetSubscriber().RemoveListener(DeleteEventListener.class,t);
            EventSubscriber.GetSubscriber().RemoveListener(Ready2PublishEventListener.class,t);
            EventSubscriber.GetSubscriber().RemoveListener(PublishEventListener.class,t);
            EventSubscriber.GetSubscriber().RemoveListener(CancelEventListener.class,t);
        }

        //2008.10.19 卸载内存中所有触发器，删除数据库中的所有触发器
        TriggerManager manager = TriggerManager.LoadTriggers(ctxt);
        manager.DeleteTriggersInTopic(ctxt,t);

        PreparedStatement pstmt = null;
        try
        {
            //2010.04.04 删除所有归档日志
            String sql = "Delete from archive_log Where siteid=? and topid=?";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,site.GetId());
            pstmt.setString(2,t.GetId());
            pstmt.executeUpdate();
            try{pstmt.close();}catch(Exception e){}

            //2010.04.04 删除所有Atom Entry记录
            sql = "Delete from AtomEntry Where siteid=? and topid=?";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,site.GetId());
            pstmt.setString(2,t.GetId());
            pstmt.executeUpdate();
            try{pstmt.close();}catch(Exception e){}

            //删除附件信息
            sql = "delete from attach where artid in (select id from article where topic=?)";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,t.GetId());
            pstmt.executeUpdate();
            try{pstmt.close();}catch(Exception e1){}

            //1.删除article
            sql = "delete from article Where topic=?";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,t.GetId());
            pstmt.executeUpdate();
            try{pstmt.close();}catch(Exception e){}

            //2.删除从栏目信息
            sql = "delete from article_topics where topid=?";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,t.GetId());
            pstmt.executeUpdate();
            try{pstmt.close();}catch(Exception e){}
            
            //2.删除页面模板关联表
            sql = "delete from topic_pts where topid=?";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,t.GetId());
            pstmt.executeUpdate();
            try{pstmt.close();}catch(Exception e){}

            //3.删除版主关联表
            sql = "delete from topic_owner where topid=?";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,t.GetId());
            pstmt.executeUpdate();
            try{pstmt.close();}catch(Exception e){}            

            //4.删除变量表
            sql = "delete from topic_vars where topid=?";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,t.GetId());
            pstmt.executeUpdate();
            try{pstmt.close();}catch(Exception e){}

            //5.删除Solr自定义字段
            sql = "delete from topic_solr where topid=?";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,t.GetId());
            pstmt.executeUpdate();
            try{pstmt.close();}catch(Exception e){}

            //5.删除Keyword link
            sql = "delete from keyword_link where siteid=? and topic=?";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,t.GetSiteId());
            pstmt.setString(2,t.GetId());
            pstmt.executeUpdate();
            try{pstmt.close();}catch(Exception e){}

            //删除手工排序article_sort
            sql = "delete from article_sort where siteid=? and topic=?";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,t.GetSiteId());
            pstmt.setString(2,t.GetId());
            pstmt.executeUpdate();
            try{pstmt.close();}catch(Exception e){}
            
            //5.删除栏目信息
            sql = "delete from topic where id=?";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,t.GetId());
            pstmt.executeUpdate();
        }
        catch(Exception e)
        {
            ctxt.Rollback();
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            if(pstmt!=null)try{pstmt.close();}catch(Exception e){}
        }     
    }

    //删除TOPIC建立的外部数据源表
    private void DeleteNodeTables(NpsContext ctxt,Node node)
    {
        Topic t = (Topic)node.GetValue();
        PreparedStatement pstmt = null;
        try
        {
            if(t.GetMyTable()!=null && t.GetMyTable().length()>0)
            {
                //CREATE,ALTER,DROP,GRANT,REVOKE 隐含的提交当前事务，并且开始一个自动提交的事务
                String dstable_name = t.GetMyTable()+"_prop";
                String sql = "drop table "+dstable_name;
                pstmt = ctxt.GetConnection().prepareStatement(sql);
                pstmt.executeUpdate();
            }
        }
        catch(Exception e)
        {
            e.printStackTrace();
        }
        finally
        {
            if(pstmt!=null) try{pstmt.close();}catch(Exception e){}
        }

        if(node.HasChilds())
        {
            Iterator childs = node.GetChilds();
            while(childs.hasNext())
            {
                Node child_node = (Node)childs.next();
                DeleteNodeTables(ctxt,child_node);
            }
        }
    }

    //删除内存中的TREENODE、IDS、codes对象
    private void DeleteNode(Node node) throws NpsException
    {
        if(node.HasChilds())
        {
            Iterator childs = node.GetChilds();
            while(childs.hasNext())
            {
                Node child_node = (Node)childs.next();
                DeleteNode(child_node);
            }
        }

        Topic topic = (Topic)node.GetValue();
        ids.remove(topic.GetId());
        codes.remove(topic.GetCode());
    }
    
    //保存模板基本信息
    private void SaveTopic(NpsContext inCtxt,Topic t)  throws NpsException
    {
        if(t==null)  return;
        PreparedStatement pstmt = null;

        //校验topic code是否已经存在
        Topic try_topic_by_code = GetTopicByCode(t.GetCode());
        if(try_topic_by_code!=null && !try_topic_by_code.GetId().equalsIgnoreCase(t.GetId()))
            throw new NpsException("alias for topic exists:"+t.GetAlias(),ErrorHelper.SYS_INVALIDTOPICALIAS);
        
        try
        {
            //1.TOPIC主表
            String sql = "insert into topic(id,name,siteid,alias,code,parentid,idx,tname,art_template,default_article_state,default_article_score,layer,visible,archive_mode,archive_template,top_comment,solr_enabled,solr_core,sort_enabled,is_business) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
            pstmt = inCtxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,t.GetId());
            pstmt.setString(2,t.GetName());
            pstmt.setString(3,site.GetId());
            pstmt.setString(4,t.GetAlias());
            pstmt.setString(5,t.GetCode());
            pstmt.setString(6,"-1".equalsIgnoreCase(t.GetParentId())?null:t.GetParentId());
            pstmt.setInt(7,t.GetIndex());
            pstmt.setString(8,t.GetMyTable());
            if(t.GetArticleTemplate()!=null)
                pstmt.setString(9,t.GetArticleTemplate().GetId());
            else
                pstmt.setNull(9,java.sql.Types.VARCHAR);

            pstmt.setInt(10,t.GetDefaultArticleState());
            pstmt.setFloat(11,t.GetScore());
            pstmt.setInt(12,GetLayer(t));
            pstmt.setInt(13,t.GetVisibility());
            pstmt.setInt(14,t.GetArchiveMode());
            if(t.GetArchiveTemplate()!=null)
                pstmt.setString(15,t.GetArchiveTemplate().GetId());
            else
                pstmt.setNull(15,java.sql.Types.VARCHAR);

            pstmt.setString(16,t.GetComment());
            if(t.GetMySolrEnable()==null)
            {
                pstmt.setNull(17,java.sql.Types.NUMERIC);
            }
            else
            {
                pstmt.setInt(17,t.GetMySolrEnable()?2:1);
            }
            pstmt.setString(18,t.GetMySolrCore());

            if(t.GetMySortEnable()==null)
            {
                pstmt.setNull(19,java.sql.Types.NUMERIC);
            }
            else
            {
                pstmt.setInt(19,t.GetMySortEnable()?2:1);
            }
            pstmt.setInt(20,t.getIs_business());
            pstmt.executeUpdate();
        }
        catch(Exception e)
        {
            inCtxt.Rollback();
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            if(pstmt!=null)try{pstmt.close();}catch(Exception e){}
        }
    }

    //更新模板基本信息
    private void UpdateTopic(NpsContext inCtxt,Topic t)  throws NpsException
    {
        if(t==null)  return;
        PreparedStatement pstmt = null;
        try
        {
            String sql = "update topic set name=?,idx=?,tname=?,art_template=?,default_article_state=?,default_article_score=?,siteid=?,code=?,parentid=?,layer=?,visible=?,archive_mode=?,archive_template=?,top_comment=?,solr_enabled=?,solr_core=?,sort_enabled=?,is_business = ? where id=?";
            pstmt = inCtxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,t.GetName());
            pstmt.setInt(2,t.GetIndex());
            pstmt.setString(3,t.GetMyTable());
            if(t.GetArticleTemplate()!=null)
                pstmt.setString(4,t.GetArticleTemplate().GetId());
            else
                pstmt.setNull(4,java.sql.Types.VARCHAR);

            pstmt.setInt(5,t.GetDefaultArticleState());
            pstmt.setFloat(6,t.GetScore());
            pstmt.setString(7,t.GetSiteId());
            pstmt.setString(8,t.GetCode());
            pstmt.setString(9,"-1".equalsIgnoreCase(t.GetParentId())?null:t.GetParentId());
            pstmt.setInt(10,GetLayer(t));//2008.09.28增加layer参数
            pstmt.setInt(11,t.GetVisibility());
            pstmt.setInt(12,t.GetArchiveMode());
            if(t.GetArchiveTemplate()!=null)
                pstmt.setString(13,t.GetArchiveTemplate().GetId());
            else
                pstmt.setNull(13,java.sql.Types.VARCHAR);
            pstmt.setString(14,t.GetComment());
            if(t.GetMySolrEnable()==null)
            {
                pstmt.setNull(15,java.sql.Types.NUMERIC);
            }
            else
            {
                pstmt.setInt(15,t.GetMySolrEnable()?2:1);
            }
            pstmt.setString(16,t.GetMySolrCore());

            if(t.GetMySortEnable()==null)
            {
                pstmt.setNull(17,java.sql.Types.NUMERIC);
            }
            else
            {
                pstmt.setInt(17,t.GetMySortEnable()?2:1);
            }

            pstmt.setInt(18,t.getIs_business());
            pstmt.setString(19,t.GetId());

            pstmt.executeUpdate();
        }
        catch(Exception e)
        {
            inCtxt.Rollback();
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            if(pstmt!=null)try{pstmt.close();}catch(Exception e){}
        }
    }

    //更新栏目相关页面模板
    private void UpdateTopicPageTemplate(NpsContext inCtxt,Topic t)  throws NpsException
    {
        if(t==null)  return;
        PreparedStatement pstmt = null;
        try
        {
            //1.删除当前所有关联的页面
            String sql = "delete from topic_pts where topid=?";
            pstmt = inCtxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,t.GetId());
            pstmt.executeUpdate();
            try{pstmt.close();}catch(Exception e){}

            //2.插入模板
            java.util.List pts = t.GetPageTemplates();
            if(pts==null || pts.isEmpty()) return;
            
            sql="insert into topic_pts(topid,templateid) values(?,?)";
            pstmt = inCtxt.GetConnection().prepareStatement(sql);

            for(Object obj:pts)
            {
                PageTemplate pt = (PageTemplate)obj;
                pstmt.setString(1,t.GetId());
                pstmt.setString(2,pt.GetId());
                pstmt.executeUpdate();
            }
        }
        catch(Exception e)
        {
            inCtxt.Rollback();
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            if(pstmt!=null)try{pstmt.close();}catch(Exception e){}
        }
    }

    //更新版主信息
    private void UpdateTopicOwners(NpsContext inCtxt,Topic t) throws NpsException
    {
        if(t==null)  return;
        PreparedStatement pstmt = null;
        try
        {
            //2.保存版主信息
            //2.1清空版主信息
            String sql = "delete from topic_owner where topid=?";
            pstmt = inCtxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,t.GetId());
            pstmt.executeUpdate();
            if(pstmt!=null)try{pstmt.close();}catch(Exception e){}

            //2.2重新插入版主
            Hashtable owners = t.GetOwner();
            if(owners!=null && !owners.isEmpty())
            {
                sql = "insert into topic_owner(topid,userid) values(?,?)";
                pstmt = inCtxt.GetConnection().prepareStatement(sql);
                Enumeration owners_elements = owners.elements();
                while(owners_elements.hasMoreElements())
                {
                    Topic.Owner  owner = (Topic.Owner)owners_elements.nextElement();
                    pstmt.setString(1,t.GetId());
                    pstmt.setString(2,owner.GetID());
                    pstmt.executeUpdate();
                }
            }
        }
        catch(Exception e)
        {
            inCtxt.Rollback();
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            if(pstmt!=null)try{pstmt.close();}catch(Exception e){}
        }            
    }

    //更新栏目自定义变量
    public void UpdateTopicVars(NpsContext inCtxt,Topic t) throws NpsException
    {
        if(t==null)  return;
        PreparedStatement pstmt = null;
        try
        {
            //2.保存栏目自定义变量
            //2.1清空栏目自定义变量
            String sql = "delete from topic_vars where topid=?";
            pstmt = inCtxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,t.GetId());
            pstmt.executeUpdate();
            if(pstmt!=null)try{pstmt.close();}catch(Exception e){}

            //2.2重新插入栏目自定义变量
            Hashtable vars = t.GetVars();
            if(vars!=null && !vars.isEmpty())
            {
                sql = "insert into topic_vars(topid,varname,value,varcomment) values(?,?,?,?)";
                pstmt = inCtxt.GetConnection().prepareStatement(sql);
                Enumeration vars_elements = vars.elements();
                while(vars_elements.hasMoreElements())
                {
                    Topic.Var var = (Topic.Var)vars_elements.nextElement();
                    pstmt.setString(1,t.GetId());
                    pstmt.setString(2,var.name);
                    pstmt.setString(3,var.value);
                    pstmt.setString(4,var.comment);
                    pstmt.executeUpdate();
                }
            }
        }
        catch(Exception e)
        {
            inCtxt.Rollback();
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            if(pstmt!=null)try{pstmt.close();}catch(Exception e){}
        }
    }

    //更新Solr自定义字段
    public void UpdateTopicSolrFields(NpsContext inCtxt,Topic t) throws NpsException
    {
        if(t==null)  return;
        PreparedStatement pstmt = null;
        try
        {
            //清空Solr自定义字段
            String sql = "delete from topic_solr where topid=?";
            pstmt = inCtxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,t.GetId());
            pstmt.executeUpdate();
            if(pstmt!=null)try{pstmt.close();}catch(Exception e){}

            //2重新插入自定义字段
            Hashtable solr_fields = t.GetSolrFields();
            if(solr_fields!=null && !solr_fields.isEmpty())
            {
                sql = "insert into topic_solr(topid,fieldname,fieldcomment) values(?,?,?)";
                pstmt = inCtxt.GetConnection().prepareStatement(sql);
                Enumeration fields_elements = solr_fields.elements();
                while(fields_elements.hasMoreElements())
                {
                    Topic.SolrField field = (Topic.SolrField)fields_elements.nextElement();
                    pstmt.setString(1,t.GetId());
                    pstmt.setString(2,field.name);
                    pstmt.setString(3,field.comment);
                    pstmt.executeUpdate();
                }
            }
        }
        catch(Exception e)
        {
            inCtxt.Rollback();
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            if(pstmt!=null)try{pstmt.close();}catch(Exception e){}
        }
    }

    //更新Solr自定义字段
    public void UpdateTopicKeywordLinks(NpsContext inCtxt,Topic t) throws NpsException
    {
        if(t==null)  return;
        PreparedStatement pstmt = null;
        try
        {
            //清空keyword link
            String sql = "delete from keyword_link where siteid=? and topic=?";
            pstmt = inCtxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,t.GetSiteId());
            pstmt.setString(2,t.GetId());
            pstmt.executeUpdate();
            if(pstmt!=null)try{pstmt.close();}catch(Exception e){}

            //2重新插入
            if(t.GetKeywordLinks()!=null)
            {
                sql = "insert into keyword_link(siteid,topic,keyword,url) values(?,?,?,?)";
                pstmt = inCtxt.GetConnection().prepareStatement(sql);
                for(KeywordLink link:t.GetKeywordLinks().GetKeywordLinks())
                {
                    Iterator<String> keywords = link.keys();
                    while(keywords.hasNext())
                    {
                        String keyword = keywords.next();
                        pstmt.setString(1,t.GetSiteId());
                        pstmt.setString(2,t.GetId());
                        pstmt.setString(3,keyword);
                        pstmt.setString(4,link.GetURL());
                        pstmt.executeUpdate();
                    }
                }
            }
        }
        catch(Exception e)
        {
            inCtxt.Rollback();
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            if(pstmt!=null)try{pstmt.close();}catch(Exception e){}
        }
    }

    //重新设置栏目别名
    public void UpdateTopicAlias(NpsContext ctxt,Topic t,String new_alias) throws NpsException
    {
        if(new_alias==null || new_alias.length()==0) return;

        new_alias = new_alias.trim().toLowerCase();
        if(new_alias.length()==0) return;

        //如果是新栏目，直接返回
        if(t.GetId()==null || !ids.containsKey(t.GetId())) return;

        //如果前后别名一致，就无需更改了
        String old_alias = t.GetAlias();
        if(old_alias.equalsIgnoreCase(new_alias)) return;

        String sql = "update topic set alias=?,code=? where id=?";
        PreparedStatement pstmt = null;
        try
        {
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            UpdateTopicAlias(pstmt,t,new_alias);
        }
        catch(Exception e)
        {
            ctxt.Rollback();
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            if(pstmt!=null) try{pstmt.close();}catch(Exception e){}
        }
    }

    private void UpdateTopicAlias(PreparedStatement pstmt,Topic t,String alias) throws Exception
    {
        //设置当前栏目
        String new_code = GenerateTopicCode(t.GetParent(),alias);
        pstmt.setString(1,alias);
        pstmt.setString(2,new_code);
        pstmt.setString(3,t.GetId());
        pstmt.executeUpdate();

        codes.remove(t.GetCode());
        t.SetAlias(alias);
        t.SetCode(new_code);
        codes.put(t.GetCode(),t);

        Iterator childs = GetChilds(t);
        if(childs==null) return;

        while(childs.hasNext())
        {
            Node top_node = (Node)childs.next();
            Topic top = (Topic)top_node.GetValue();

            UpdateTopicAlias(pstmt,top,top.GetAlias());
        }
    }

    //为所有节点创建外部数据源表
    public void CreateDsTable(NpsContext ctxt) throws NpsException
    {
        CreateDsTable(ctxt,tree.GetChilds());
    }

    private void CreateDsTable(NpsContext ctxt,Iterator childs)  throws NpsException
    {        
        while(childs.hasNext())
        {
            Node node = (Node)childs.next();
            Topic t = (Topic)node.GetValue();
            if(t!=null && !"-1".equalsIgnoreCase(t.GetId()))
            {
                  CreateDsTable(ctxt,t);
            }

            if(node.HasChilds())   CreateDsTable(ctxt,node.GetChilds());
        }        
    }
    
    //创建外部数据源表
    private void CreateDsTable(NpsContext ctxt,Topic t) throws NpsException
    {
        if(t==null) return;
        String tablename = t.GetMyTable();
        if(tablename==null || tablename.length()==0) return;

        String dstable_name = tablename + "_prop";
        dstable_name = dstable_name.toUpperCase();
        
        PreparedStatement pstmt = null;
        Statement stmt = null;
        ResultSet rs = null;
        try
        {
            boolean bTable = false;
            boolean bView = false;
            
            //1.查看当前表名是否存在
            String sql = "select count(*) from user_tables where table_name=?";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,dstable_name);
            rs = pstmt.executeQuery();
            rs.next();
            if(rs.getInt(1)>0)
            {
                bTable = true;
            }
            else
            {
                try{rs.close();}catch(Exception e){}
                try{pstmt.close();}catch(Exception e){}

                sql = "select count(*) from user_views where view_name=?";
                pstmt = ctxt.GetConnection().prepareStatement(sql);
                pstmt.setString(1,dstable_name);
                rs = pstmt.executeQuery();
                rs.next();
                if(rs.getInt(1)>0) bView = true;
            }
            
            if(bTable)
            {
                try{rs.close();}catch(Exception e){}
                try{pstmt.close();}catch(Exception e){}

                //如果已存在，校验数据结构是否正确
                sql = "select id,title,siteid,topic,state,createdate,publishdate,url,url_gen from "+dstable_name+" where rownum<2";
                try
                {
                     pstmt = ctxt.GetConnection().prepareStatement(sql);
                     rs = pstmt.executeQuery();
                     try{rs.close();}catch(Exception e1){}
                     try{pstmt.close();}catch(Exception e1){}

                     //数据结构正确，修改siteid和topic默认值
                     stmt = ctxt.GetConnection().createStatement();                    
                     sql = "Alter Table "+dstable_name+" Modify siteid default('"+t.GetSiteId()+"')";
                     stmt.executeUpdate(sql);

                     sql = "Alter Table "+dstable_name+" Modify topic default('"+t.GetId()+"')";
                     stmt.executeUpdate(sql);

                      //修改备注
                     sql = "COMMENT ON COLUMN "+dstable_name+".SITEID IS 'site id,default:"+treename+"'";
                     stmt.executeUpdate(sql);

                     sql = "COMMENT ON COLUMN "+dstable_name+".TOPIC IS 'topic id,default:"+t.GetName()+"'";
                     stmt.executeUpdate(sql);

                     try{stmt.close();}catch(Exception e1){}
                     return;
                }
                catch(Exception e)
                {
                    try{rs.close();}catch(Exception e1){}
                    try{pstmt.close();}catch(Exception e1){}

                    //数据结构有误，drop table
                    sql = "drop table "+dstable_name;
                    pstmt = ctxt.GetConnection().prepareStatement(sql);
                    pstmt.executeUpdate(sql);
                }
            }

            //是一个视图
            if(bView)
            {
                try{rs.close();}catch(Exception e){}
                try{pstmt.close();}catch(Exception e){}

                //如果已存在，校验数据结构是否正确
                sql = "select id,title,siteid,topic,state,createdate,publishdate,url,url_gen from "+dstable_name+" where rownum<2";
                try
                {
                     pstmt = ctxt.GetConnection().prepareStatement(sql);
                     rs = pstmt.executeQuery();
                     return;
                }
                catch(Exception e)
                {
                    try{rs.close();}catch(Exception e1){}
                    try{pstmt.close();}catch(Exception e1){}
                    throw new NpsException(dstable_name + " : Table structure NOT correct",ErrorHelper.SYS_UNKOWN);
                }
            }
            try{rs.close();}catch(Exception e){}
            try{pstmt.close();}catch(Exception e){}

            //3.新建表
            stmt = ctxt.GetConnection().createStatement();
            sql = "CREATE TABLE "+dstable_name +" (ID VARCHAR2(36) NOT NULL," +
                                                        "TITLE VARCHAR2(1000) NOT NULL," +
                                                        "SITEID VARCHAR2(36) DEFAULT '" + t.GetSiteId() +"' NOT NULL," +
                                                        "TOPIC VARCHAR2(36) DEFAULT '" + t.GetId() +"' NOT NULL," +
                                                        "STATE NUMBER," +
                                                        "CREATEDATE DATE DEFAULT SYSDATE NOT NULL," +
                                                        "PUBLISHDATE DATE," +
                                                        "URL VARCHAR2(1000)," +
                                                        "URL_GEN varchar2(1000)," +
                                                        "CONSTRAINT PK_"+dstable_name+" PRIMARY KEY (ID,TOPIC)" +
                                                    ")";
            stmt.executeUpdate(sql);

            sql = "COMMENT ON COLUMN "+dstable_name+".ID IS 'id'";
            stmt.executeUpdate(sql);

            sql = "COMMENT ON COLUMN "+dstable_name+".TITLE IS 'title'";
            stmt.executeUpdate(sql);

            sql = "COMMENT ON COLUMN "+dstable_name+".SITEID IS 'site id,site name is:"+treename+"'";
            stmt.executeUpdate(sql);

            sql = "COMMENT ON COLUMN "+dstable_name+".TOPIC IS 'topic id,topic name is:"+t.GetName()+"'";
            stmt.executeUpdate(sql);

            sql = "COMMENT ON COLUMN "+dstable_name+".STATE IS 'status'";
            stmt.executeUpdate(sql);

            sql = "COMMENT ON COLUMN "+dstable_name+".CREATEDATE IS 'create date'";
            stmt.executeUpdate(sql);

            sql = "COMMENT ON COLUMN "+dstable_name+".PUBLISHDATE IS 'publish date'";
            stmt.executeUpdate(sql);

            sql = "COMMENT ON COLUMN "+dstable_name+".URL IS 'URL:link to other page'";            
            stmt.executeUpdate(sql);

            sql = "COMMENT ON COLUMN "+dstable_name+".URL_GEN IS 'URL generated'";
            stmt.executeUpdate(sql);

            //4.新建索引
            String oracle_index_name = "idx_"+dstable_name+"_topstate";
            if(oracle_index_name.length()>30) oracle_index_name = oracle_index_name.substring(0,30);
            sql = "select count(*) from user_indexes Where index_name=?";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,dstable_name);
            rs = pstmt.executeQuery();
            rs.next();
            if(rs.getInt(1)==0)
            {
                try{rs.close();}catch(Exception e){}
                try{pstmt.close();}catch(Exception e){}

                sql = "create index "+oracle_index_name+" on "+dstable_name+"(siteid,topic,state)";
                stmt.executeUpdate(sql);

                try{stmt.close();}catch(Exception e){}
            }
        }
        catch(Exception e)
        {
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            if(rs!=null)try{rs.close();}catch(Exception e){}
            if(pstmt!=null)try{pstmt.close();}catch(Exception e){}
            if(stmt!=null)try{stmt.close();}catch(Exception e){}
        }
    }

  //将src_topid节点移到dest_topid下
  // src_topid ==null || src_topid == ""，表明将整颗树挂在dest_topid下
  // dest_topid == null || dest_topid == ""，表明直接挂在根节点下  
  public void MoveTo(NpsContext ctxt,String src_topid,TopicTree dest,String dest_topid) throws NpsException
  {
      if(site.GetId().equals(dest.GetSiteId()))
      {
          //本站点内移动
          MoveTo(ctxt,src_topid,dest_topid);
          return;
      }

      try
      {
           Node node_src = null;
           Node node_dest = null;
           Topic topic_dest  = null;
           if(dest_topid!=null && dest_topid.length()>0)
           {
               topic_dest = dest.GetTopic(dest_topid);
               if(topic_dest==null) throw new NpsException(dest_topid, ErrorHelper.SYS_NOTOPIC);

               node_dest = dest.GetNodeByTopic(topic_dest);
           }

           if(src_topid==null || src_topid.length()==0)
           {
               Iterator node_src_list = tree.GetChilds();
               //移动根目录下的所有节点
               while(node_src_list.hasNext())
               {
                   node_src = (Node)node_src_list.next();
                   MoveTo(ctxt,node_src,dest,node_dest);
               }

               node_src_list = tree.GetChilds();
               while(node_src_list.hasNext())
               {
                   node_src = (Node)node_src_list.next();
                   tree.RemoveNode(node_src);
               }
           }
           else
           {
               Topic topic_src = GetTopic(src_topid);
               if(topic_src==null) throw new NpsException(src_topid,ErrorHelper.SYS_NOTOPIC);

               node_src = GetNodeByTopic(topic_src);

               //1.内存中目标树增加
               MoveTo(ctxt,node_src,dest,node_dest);

               //2.内存中剔除
               tree.RemoveNode(node_src);
           }
      }
      catch(NpsException e)
      {
          //发生异常重新加载数据
          nps.util.DefaultLog.error_noexception(e);          
          site.ReloadTopicTree(ctxt);
          dest.site.ReloadTopicTree(ctxt);
          throw e;
      }      
  }

  //内存中复制树，不改变任何属性
  private void MoveTo(NpsContext ctxt,Node node_src,TopicTree tree_dest,Node node_dest) throws NpsException
  {
       Topic topic = (Topic)node_src.GetValue();
       //如果没有目标节点，自动全部挂在根下
       if(node_dest !=null)
       {
            Topic topic_parent=(Topic)node_dest.GetValue();
            topic.SetSite(tree_dest.GetSite());
            topic.SetParentId(topic_parent.GetId());
            topic.SetCode(topic_parent.GetCode()+"."+topic.GetAlias());
       }
       else
       {
            topic.SetSite(tree_dest.GetSite());
            topic.SetParentId("-1");
            topic.SetCode(topic.GetAlias());
       }

       tree_dest.AddTopic(topic);
       tree_dest.Save(ctxt,topic,false);

       if(node_src.HasChilds())
       {
           Node copyNode = tree_dest.GetNodeByTopic(topic);
           Iterator childs = node_src.GetChilds();
           while(childs.hasNext())
           {
               Node node_src_child = (Node)childs.next();
               MoveTo(ctxt,node_src_child,tree_dest,copyNode);
           }
       }
  }

  //同个站点内移动栏目，必须指定src_topid
  private void MoveTo(NpsContext ctxt,String src_topid,String dest_topid) throws NpsException
  {
      try
      {
          Node node_dest = null;
          Topic topic_dest  = null;
          if(dest_topid!=null && dest_topid.length()>0)
          {
              topic_dest = GetTopic(dest_topid);
              if(topic_dest==null) throw new NpsException(dest_topid, ErrorHelper.SYS_NOTOPIC);

              node_dest = GetNodeByTopic(topic_dest);
          }

          if(src_topid==null || src_topid.length()==0)   throw new NpsException(src_topid,ErrorHelper.SYS_NOTOPIC);
          Topic topic_src = GetTopic(src_topid);
          if(topic_src==null) throw new NpsException(src_topid,ErrorHelper.SYS_NOTOPIC);
          Node node_src = GetNodeByTopic(topic_src);

          if(dest_topid==null || dest_topid.length()==0) dest_topid = "-1";

          //1.删除当前节点
          tree.RemoveNode(node_src);

          //2.更新数据库Code字段、重新添加节点、H更新CODE哈希表
          MoveTo(ctxt,node_src,node_dest);
      }
      catch(NpsException e)
      {
          nps.util.DefaultLog.error_noexception(e);
          site.ReloadTopicTree(ctxt);
          throw e;
      }
  }

  //同个站点内移动栏目，node_dest为null表明移到根节点下  
  private void MoveTo(NpsContext ctxt,Node node_src,Node node_dest) throws NpsException
  {
      Topic topic = (Topic)node_src.GetValue();

      //1.从codes表中删除索引
      codes.remove(topic.GetCode());

       //如果没有目标节点，自动全部挂在根下
       if(node_dest !=null)
       {
            Topic topic_parent=(Topic)node_dest.GetValue();
            topic.SetParentId(topic_parent.GetId());
            topic.SetCode(topic_parent.GetCode()+"."+topic.GetAlias());
       }
       else
       {
            topic.SetParentId("-1");
            topic.SetCode(topic.GetAlias());
       }

       //2.重新添加节点
       AddTopic(topic);

       //3.更新topic数据到数据库
       Save(ctxt,topic,false);

       //4.添加code索引
       codes.put(topic.GetCode(),topic);
      
       if(node_src.HasChilds())
       {
           Node copyNode = GetNodeByTopic(topic);
           Iterator childs = node_src.GetChilds();
           while(childs.hasNext())
           {
               Node node_src_child = (Node)childs.next();
               MoveTo(ctxt,node_src_child,copyNode);
           }
       }
  }

  //将src_topid节点复制到dest_topid下
  // src_topid ==null || src_topid == ""，表明将整颗树挂在dest_topid下
  // dest_topid == null || dest_topid == ""，表明直接挂在根节点下
  public void CopyTo(NpsContext ctxt,String src_topid,TopicTree dest,String dest_topid) throws NpsException
  {
      try
      {
          Node node_src = null;
          Node node_dest = null;
          Topic topic_dest  = null;
          if(dest_topid!=null && dest_topid.length()>0)
          {
              topic_dest = dest.GetTopic(dest_topid);
              if(topic_dest==null) throw new NpsException(dest_topid,ErrorHelper.SYS_NOTOPIC);

              node_dest = dest.GetNodeByTopic(topic_dest);
          }

          if(src_topid==null || src_topid.length()==0)
          {
              Iterator node_src_list = tree.GetChilds();
              //复制根目录下的所有节点
              while(node_src_list.hasNext())
              {
                  node_src = (Node)node_src_list.next();
                  CopyTo(ctxt,node_src,dest,node_dest);
              }
          }
          else
          {
              Topic topic_src = GetTopic(src_topid);
              if(topic_src==null) throw new NpsException(src_topid,ErrorHelper.SYS_NOTOPIC);

              node_src = GetNodeByTopic(topic_src);
              CopyTo(ctxt,node_src,dest,node_dest);
          }
      }
      catch(NpsException e)
      {
          nps.util.DefaultLog.error_noexception(e);
          site.ReloadTopicTree(ctxt);
          if(!site.GetId().equals(dest.GetSiteId()))  dest.site.ReloadTopicTree(ctxt);
          throw e;          
      }
  }

    //复制树，新产生ID号
    private void CopyTo(NpsContext ctxt,Node node_src,TopicTree tree_dest,Node node_dest) throws NpsException
    {
         String new_id = GenerateTopicId(ctxt);
         Topic topic_src = (Topic)node_src.GetValue();
         Topic topic = null;
         if(node_dest!=null)
              topic = new Topic(new_id,(Topic)node_dest.GetValue(),topic_src);
         else
              topic = new Topic(new_id,tree_dest.GetSite(),topic_src);

         //保存新产生的栏目信息，自动加入节点
         tree_dest.Save(ctxt,topic,true);

         if(node_src.HasChilds())
         {
             Node copyNode = tree_dest.GetNodeByTopic(topic);
             Iterator childs = node_src.GetChilds();
             while(childs.hasNext())
             {
                 Node node_src_child = (Node)childs.next();
                 CopyTo(ctxt,node_src_child,tree_dest,copyNode);
             }
         }
    }

    //动态加载DHXTree，采用XML格式
    public void AjaxDHXTree(PrintWriter out,String top_id,ViewMode mode)
    {
       //返回顶级栏目
       if(top_id==null || top_id.length()==0 || "-1".equals(top_id))
       {
           String xml_treeid = site.GetId();
           String xml_treename = AjaxDHXFixXMLEscapeProblem(treename);
           
           out.println("<item child=\""+(tree.HasChilds()?"1":"0")+"\" id=\""+xml_treeid+"\" text=\""+xml_treename+"\">");
           out.println("<userdata name='siteid'>"+site.GetId()+"</userdata>");
           out.println("<userdata name='sitename'>"+xml_treename+"</userdata>");
           out.println("<userdata name='topid'>"+"</userdata>");
           out.println("<userdata name='topname'>"+"</userdata>");

           //打印顶级栏目
           if(tree.HasChilds()) AjaxDHXTreeItem(out,tree.GetChilds(),mode);

           out.println("</item>");
       }
       else   //加载子栏目
       {
           Node node = tree.GetNode(top_id);
           if(node!=null && node.HasChilds())
           {
               AjaxDHXTreeItem(out,node.GetChilds(),mode);
           }
       }
    }
  //动态加载DHXTree，采用XML格式
    public void AjaxDHXTree(PrintWriter out,String top_id,ViewMode mode,int isBusiness)
    {
       //返回顶级栏目
       if(top_id==null || top_id.length()==0 || "-1".equals(top_id))
       {
           String xml_treeid = site.GetId();
           String xml_treename = AjaxDHXFixXMLEscapeProblem(treename);
           
           out.println("<item child=\""+(tree.HasChilds()?"1":"0")+"\" id=\""+xml_treeid+"\" text=\""+xml_treename+"\">");
           out.println("<userdata name='siteid'>"+site.GetId()+"</userdata>");
           out.println("<userdata name='sitename'>"+xml_treename+"</userdata>");
           out.println("<userdata name='topid'>"+"</userdata>");
           out.println("<userdata name='topname'>"+"</userdata>");

           //打印顶级栏目
           if(tree.HasChilds()) AjaxDHXTreeItem(out,tree.GetChilds(),mode,isBusiness);

           out.println("</item>");
       }
       else   //加载子栏目
       {
           Node node = tree.GetNode(top_id);
           if(node!=null && node.HasChilds())
           {
               AjaxDHXTreeItem(out,node.GetChilds(),mode);
           }
       }
    }
    private void  AjaxDHXTreeItem(PrintWriter out,Iterator childs,ViewMode mode)
    {
        String site_name = AjaxDHXFixXMLEscapeProblem(treename);
        
        while(childs.hasNext())
        {
            Node node = (Node)childs.next();

            String id=node.GetId();
            Topic topic = (Topic)node.GetValue();
            //System.out.println("topic.getIs_business() = "+topic.getIs_business());
            
            switch(mode)
            {
                case VISIBLE: //ALL VISIBLE
                    if(topic.IsHidden()) continue;
                    break;
                case PUBLIC: //ALL PUBLIC
                    if(!topic.IsPublic()) continue;
                case ALL: //ALL
                    //显示所有节点
            }

            String xml_itemid = site.GetId()+"."+id;
            String xml_itemname = AjaxDHXFixXMLEscapeProblem(topic.GetName());

            out.println("<item child=\""+(node.HasChilds()?"1":"0")+"\" id=\""+xml_itemid+"\" text=\""+xml_itemname+"\">");
            out.println("<userdata name='siteid'>"+site.GetId()+"</userdata>");
            out.println("<userdata name='sitename'>"+site_name+"</userdata>");
            out.println("<userdata name='topid'>"+id+"</userdata>");
            out.println("<userdata name='topname'>"+xml_itemname+"</userdata>");
            if(topic.GetMyTable()!=null && topic.GetMyTable().length()>0)
                out.println("<userdata name='tname'>"+topic.GetMyTable()+"</userdata>");

            out.println("</item>");
        }
    }
    
    private void  AjaxDHXTreeItem(PrintWriter out,Iterator childs,ViewMode mode,int isBusiness)
    {
        String site_name = AjaxDHXFixXMLEscapeProblem(treename);
        
        while(childs.hasNext())
        {
            Node node = (Node)childs.next();

            String id=node.GetId();
            Topic topic = (Topic)node.GetValue();
            //System.out.println("topic.getIs_business() = "+topic.getIs_business());
            if(topic.getIs_business()!=isBusiness){
             
              continue;
            }
            switch(mode)
            {
                case VISIBLE: //ALL VISIBLE
                    if(topic.IsHidden()) continue;
                    break;
                case PUBLIC: //ALL PUBLIC
                    if(!topic.IsPublic()) continue;
                case ALL: //ALL
                    //显示所有节点
            }

            String xml_itemid = site.GetId()+"."+id;
            String xml_itemname = AjaxDHXFixXMLEscapeProblem(topic.GetName());

            out.println("<item child=\""+(node.HasChilds()?"1":"0")+"\" id=\""+xml_itemid+"\" text=\""+xml_itemname+"\">");
            out.println("<userdata name='siteid'>"+site.GetId()+"</userdata>");
            out.println("<userdata name='sitename'>"+site_name+"</userdata>");
            out.println("<userdata name='topid'>"+id+"</userdata>");
            out.println("<userdata name='topname'>"+xml_itemname+"</userdata>");
            if(topic.GetMyTable()!=null && topic.GetMyTable().length()>0)
                out.println("<userdata name='tname'>"+topic.GetMyTable()+"</userdata>");

            out.println("</item>");
        }
    }

    //修复DHXTree加载问题，XML内容在生成树时没有进行ASCII特殊字符转换
    private String AjaxDHXFixXMLEscapeProblem(String s)
    {
        if(s==null) return null;

        int len = s.length();
        StringBuffer new_str = new StringBuffer(len*2);
        for(int i=0;i<len;i++)
        {
            char ch = s.charAt(i);
            switch(ch)
            {
                case '&':
                    new_str.append("&amp;amp;");
                    break;
                case '<':
                    new_str.append("&amp;lt;");
                    break;
                case '>':
                    new_str.append("&amp;gt;");
                    break;
                case '\'':
                    new_str.append("&amp;apos;");
                    break;
                case '"':
                    new_str.append("&amp;quot;");
                    break;
                default:
                    //ASCII控制字符或者ASCII special character
                    if(((ch>=0 && ch<32) || ch==127) || (ch>=128 && ch<=255))
                        new_str.append("&amp;#"+(int)ch+";");
                    else
                        new_str.append(ch);
            }
        }

        return new_str.toString();
    }

   //转换为DHTMLX Tree
   // show_all==0,打印所有节点
   // show_all==1,打印所有可见节点
   // show_all==2,打印所有公开节点
   public String toDHXTree(String dhxtree,String rootId,ViewMode mode)
   {
        String site_nodeid = "site"+ site.GetId();
        String jstree = dhxtree+".insertNewItem(\"" + rootId + "\","
                                                  + "\""+ site_nodeid +"\","
                                                  +"\""+Utils.TransferToHtmlEntity(treename)+"\");";
        jstree += dhxtree+".setUserData(\""+site_nodeid+"\","
                                            +"\"siteid\","
                                            +"\""+ site.GetId() +"\");";

       jstree += dhxtree+".setUserData(\""+site_nodeid+"\","
                                           +"\"sitename\","
                                           +"\""+ Utils.TransferToHtmlEntity(treename) +"\");";

       jstree += dhxtree+".setUserData(\""+site_nodeid+"\","
                                           +"\"topid\","
                                           +"\"\");";

       jstree += dhxtree+".setUserData(\""+site_nodeid+"\","
                                           +"\"topname\","
                                           +"\"\");";

       jstree += PaintDHXTree(dhxtree,site_nodeid,tree.GetChilds(),mode);

       //仅打开第一层目录
       jstree += dhxtree + ".closeAllItems(\""+site_nodeid+"\");";
       jstree += dhxtree + ".openItem(\""+site_nodeid+"\");";
       return jstree;
   }

    //打印
    // show_all==0,打印所有节点
    // show_all==1,打印所有可见节点
    // show_all==2,打印所有公开节点    
    private String PaintDHXTree(String dhxtree,String parentid,Iterator childs,ViewMode mode)
    {
        String jstree = "";
        while(childs.hasNext())
        {
            Node node = (Node)childs.next();

            String id=node.GetId();
            if(!"-1".equalsIgnoreCase(id))
            {
                Topic topic = (Topic)node.GetValue();
                switch(mode)
                {
                    case VISIBLE: //ALL VISIBLE
                        if(topic.IsHidden()) continue;
                        break;
                    case PUBLIC: //ALL PUBLIC
                        if(!topic.IsPublic()) continue;
                    case ALL: //ALL
                        //显示所有节点
                }

                String top_nodeid = "topic"+id;
                jstree += dhxtree+".insertNewItem(\"" + parentid + "\","
                                                          + "\""+ top_nodeid +"\","
                                                          +"\""+ Utils.TransferToHtmlEntity(topic.GetName()) +"\");";
                jstree += dhxtree+".setUserData(\""+top_nodeid+"\","
                                                    +"\"siteid\","
                                                    +"\""+ site.GetId() +"\");";

                jstree += dhxtree+".setUserData(\""+top_nodeid+"\","
                                                    +"\"sitename\","
                                                    +"\""+ Utils.TransferToHtmlEntity(treename) +"\");";

               jstree += dhxtree+".setUserData(\""+top_nodeid+"\","
                                                   +"\"topid\","
                                                   +"\"" + id +"\");";

                jstree += dhxtree+".setUserData(\""+top_nodeid+"\","
                                                    +"\"topname\","
                                                    +"\"" + Utils.TransferToHtmlEntity(topic.GetName()) +"\");";

                if(topic.GetMyTable()!=null && topic.GetMyTable().length()>0)
                    jstree += dhxtree+".setUserData(\""+top_nodeid+"\","
                                                        +"\"tname\","
                                                        +"\"" + topic.GetMyTable() +"\");";

               if(node.HasChilds())  jstree += PaintDHXTree(dhxtree,top_nodeid,node.GetChilds(),mode);
            }
            else
            {
                if(node.HasChilds())  jstree += PaintDHXTree(dhxtree,parentid,node.GetChilds(),mode);
            }
        }

        return jstree;
    }

    //返回Node列表
    public Iterator GetChilds(Topic top)
    {
        if(top==null) return tree.GetChilds();
        
        Node node = GetNodeByTopic(top);
        if(node==null || !node.HasChilds()) return null;

        return node.GetChilds();
    }

    public java.util.List getChilds(Topic top)
    {
      if(top==null) return tree.getChilds();

      Node node = GetNodeByTopic(top);
      if(node==null || !node.HasChilds()) return null;

      return node.getChilds();
    }

    //转换为select选择框
    public String toSelectBox(String name,String selected,ViewMode mode)
    {
        String html = "<select name=\""+name+"\">";
        html += PaintSelectOption(selected,tree.GetChilds(),mode);
        html += "</select>";
        return html;
    }

    private String PaintSelectOption(String selected, Iterator childs,ViewMode mode)
    {
        String options = "";
        while(childs.hasNext())
        {
            Node node = (Node)childs.next();

            String id=node.GetId();
            if(!"-1".equalsIgnoreCase(id))
            {
                Topic topic = (Topic)node.GetValue();
                switch(mode)
                {
                    case VISIBLE: //ALL VISIBLE
                        if(topic.IsHidden()) continue;
                        break;
                    case PUBLIC: //ALL PUBLIC
                        if(!topic.IsPublic()) continue;
                    case ALL: //ALL
                        //显示所有节点
                }
            }

            //只有最底层的栏目能够选择
            if(node.HasChilds())
            {
                options += PaintSelectOption(selected,node.GetChilds(),mode);
            }
            else
            {
                Topic topic = (Topic)node.GetValue();
                options += "<option value=\""+topic.GetId()+"\"";
                if(topic.GetId().equals(selected))   options += " selected ";
                options +=">";
                options += Utils.TransferToHtmlEntity(topic.GetName());
                options +="</option>";
            }
        }

        return options;
    }

    //生成XML格式文档
    public String toXML(ViewMode mode)
    {
        String xml = "<site>\r\n";
        xml += "  <id>"+site.GetId()+"</id>\r\n";
        xml += "  <url>" + site.GetURL() + "</url>\r\n";
        xml += "  <title>" + Utils.TranferToXmlEntity(site.GetName()) + "</title>\r\n";

        xml += PaintXMLTree(tree.GetChilds(),mode);

        xml +="</site>\r\n";

        return xml;
    }

    //打印
    // show_all==0,打印所有节点
    // show_all==1,打印所有可见节点
    // show_all==2,打印所有公开节点
    private String PaintXMLTree(Iterator childs,ViewMode mode)
    {
        String xml = "";
        while(childs.hasNext())
        {
            Node node = (Node)childs.next();

            String id=node.GetId();
            if(!"-1".equalsIgnoreCase(id))
            {
                Topic topic = (Topic)node.GetValue();
                switch(mode)
                {
                    case VISIBLE: //ALL VISIBLE
                        if(topic.IsHidden()) continue;
                        break;
                    case PUBLIC: //ALL PUBLIC
                        if(!topic.IsPublic()) continue;
                    case ALL: //ALL
                        //显示所有节点
                }

                xml += "<topic>\r\n";

                String parentid = topic.GetParentId();
                if("-1".equals(parentid)) parentid = null;
                if(parentid!=null && parentid.length()>0)
                {
                    xml += "  <parent>"+Utils.Null2Empty(parentid)+"</parent>\r\n";
                }

                xml += "  <id>"+topic.GetId()+"</id>\r\n";
                xml += "  <code>"+topic.GetCode()+"</code>\r\n";
                xml += "  <title>"+Utils.TranferToXmlEntity(topic.GetName())+"</title>\r\n";

                if(topic.GetMyTable()!=null && topic.GetMyTable().length()>0)
                {
                    xml += "  <table>"+Utils.Null2Empty(topic.GetMyTable())+"</table>\r\n";
                }

                xml += "</topic>\r\n";

               if(node.HasChilds())  xml += PaintXMLTree(node.GetChilds(),mode);
            }
            else
            {
                if(node.HasChilds())  xml += PaintXMLTree(node.GetChilds(),mode);
            }
        }

        return xml;
    }

    //导出模板数据，写入out数据流
    public void  Zip(NpsContext ctxt, ZipOutputStream out) throws Exception
    {
        //写入topic清单文件
        String filename = "TOPIC.list";
        out.putNextEntry(new ZipEntry(filename));
        try
        {
            ZipWriter writer = new ZipWriter(out);
            ZipSummary(writer,tree.GetChilds());
        }
        finally
        {
            out.closeEntry();
        }

        //写入topic数据
        Zip(ctxt,out,tree.GetChilds());
    }

    //输出topic数据
    private void Zip(NpsContext ctxt,ZipOutputStream out,Iterator childs) throws Exception
    {
        while(childs.hasNext())
        {
            Node node = (Node)childs.next();
            if(node==null) continue;
            
            Topic topic = (Topic)node.GetValue();
            
            if(topic!=null && !"-1".equalsIgnoreCase(topic.GetId()))   topic.Zip(ctxt,out);
            
            if(node.HasChilds())  Zip(ctxt,out,node.GetChilds());
        }
    }

    //输出topic清单
    private void ZipSummary(ZipWriter writer,Iterator childs)  throws Exception
    {
        while(childs.hasNext())
        {
            Node node = (Node)childs.next();
            if(node==null) continue;
            
            Topic topic = (Topic)node.GetValue();

            if(topic!=null && !"-1".equalsIgnoreCase(topic.GetId()))
            {
                writer.println(topic.GetId());
            }

            if(node.HasChilds())  ZipSummary(writer,node.GetChilds());
        }
    }

    //从数据库中按栏目代号查询栏目id号
    public String GetIdFromDatabase(NpsContext ctxt,String top_code)
    {
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try
        {
            String sql = "select id from topic where siteid=? and code=?";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,site.GetId());
            pstmt.setString(2,top_code);
            rs = pstmt.executeQuery();
            if(!rs.next()) return null;

            return rs.getString("id");
        }
        catch(Exception e)
        {
            return null;
        }
        finally
        {
            try{rs.close();}catch(Exception e){}
            try{pstmt.close();}catch(Exception e){}
        }
    }

    //导入zip文件
    //  templates是以老的id号索引的template数组
    public static TopicTree LoadTree(NpsContext ctxt,Site asite,Hashtable templates, ZipFile file)  throws Exception
    {
        if(file==null || asite==null)  return null;
        TopicTree aTopicTree = new TopicTree(asite,asite.GetName());

        Hashtable topic_indexby_oldid = new Hashtable();
        ZipEntry entry_list = file.getEntry("TOPIC.list");
        if(entry_list==null)  return aTopicTree;

        InputStream list_in = file.getInputStream(entry_list);
        //java.io.InputStreamReader list_r = new InputStreamReader(list_in,Config.ENCODING_JAVA);
        java.io.InputStreamReader list_r = new InputStreamReader(list_in,"UTF-8");
        java.io.BufferedReader list_br = new BufferedReader(list_r);     

        String top_oldid = null;
        while((top_oldid = list_br.readLine())!=null)
        {
            top_oldid = top_oldid.trim();
            if(top_oldid.length()==0) continue;
            
            ZipEntry entry = file.getEntry("TOPIC"+top_oldid+".topic");
            InputStream in = file.getInputStream(entry);
            //java.io.InputStreamReader r = new InputStreamReader(in,Config.ENCODING_JAVA);
            java.io.InputStreamReader r = new InputStreamReader(in,"UTF-8");
            java.io.BufferedReader br = new BufferedReader(r);

            br.readLine();

            String top_parentid = null;
            String s = br.readLine();
            if(s!=null)  top_parentid = s.trim();
            if("-1".equalsIgnoreCase(top_parentid)) top_parentid = null;

            //site id
            br.readLine();

            String top_name = null;
            s = br.readLine();
            if(s!=null)  top_name = s.trim();

            String top_alias = null;
            s = br.readLine();
            if(s!=null)  top_alias = s.trim();

            String top_code = null;
            s = br.readLine();
            if(s!=null)  top_code = s.trim();

            int top_order = 0;
            s = br.readLine();
            if(s!=null)  try{top_order = (int) Float.parseFloat(s);}catch(Exception e1){}

            int top_default_article_state = 0;
            s = br.readLine();
            if(s!=null)  try{top_default_article_state = (int) Float.parseFloat(s);}catch(Exception e1){}

            float top_default_article_score = 0.0f;
            s = br.readLine();
            if(s!=null)  try{top_default_article_score = Float.parseFloat(s);}catch(Exception e1){}

            String top_table =null;
            s = br.readLine();
            if(s!=null)  top_table = s.trim();

            String top_articletemplateid = null;
            s = br.readLine();
            if(s!=null)  top_articletemplateid = s.trim();

            int top_visible = 1;
            s = br.readLine();
            if(s!=null)  try{top_visible = (int) Float.parseFloat(s);}catch(Exception e1){}            

            //2010.04.02 jialin
            //新增栏目归档模式设置
            int top_archivemode = 0;
            s = br.readLine();
            if(s!=null)  try{top_archivemode = (int) Float.parseFloat(s);}catch(Exception e1){}

            String top_archivetemplateid = null;
            s = br.readLine();
            if(s!=null)  top_archivetemplateid = s.trim();

            //2010.04.30 jialn
            //新增Solr Core配置
            String top_solrenabled = null;
            s = br.readLine();
            if(s!=null)  top_solrenabled = s.trim();

            String top_solrcore = null;
            s = br.readLine();
            if(s!=null)  top_solrcore = s.trim();

            //2010.07.12 jialin
            //新增sort_enabled
            String top_sortenabled = null;
            s = br.readLine();
            if(s!=null)  top_sortenabled = s.trim();
            try{br.close();}catch(Exception e1){}

            //2009.10.08 栏目已存在的进行覆盖
            boolean bOverwrite = true;
            String top_newid = aTopicTree.GetIdFromDatabase(ctxt,top_code);
            if(top_newid==null)
            {
                bOverwrite = false;
                top_newid = aTopicTree.GenerateTopicId(ctxt);
            }

            //我们总是从最上层往下存，所以肯定能找到parent topic
            Topic aTopic = new Topic(asite,
                                     top_parentid==null?null:((Topic)topic_indexby_oldid.get(top_parentid)).GetId(),
                                     top_newid,
                                     top_name,
                                     top_alias,
                                     top_code,
                                     top_order,
                                     0
                                );

             aTopic.SetDefaultArticleState(top_default_article_state);
             aTopic.SetScore(top_default_article_score);
             if(top_table!=null && top_table.length()>0)
             {
                 aTopic.SetTable(top_table);
             }

             if(top_articletemplateid!=null && top_articletemplateid.length()>0 && templates!=null)
             {
                  aTopic.SetArticleTemplate((ArticleTemplate)templates.get(top_articletemplateid));
             }

             aTopic.SetVisibility(top_visible);

             aTopic.SetArchiveMode(top_archivemode);
             if(top_archivetemplateid!=null && top_archivetemplateid.length()>0 && templates!=null)
             {
                aTopic.SetArchiveTemplate((PageTemplate)templates.get(top_archivetemplateid));
             }

            if(top_solrenabled!=null && top_solrenabled.length()>0)
            {
                aTopic.SetSolrEnabled("true".equalsIgnoreCase(top_solrenabled));
            }

            aTopic.SetSolrCore(top_solrcore);

            if(top_sortenabled!=null && top_sortenabled.length()>0)
            {
                aTopic.SetSortEnabled("true".equalsIgnoreCase(top_sortenabled));
            }

            //加载页面模板信息
            String entry_ptsname = "TOPIC" + top_oldid + ".pts";
            ZipEntry entry_pts = file.getEntry(entry_ptsname);
            if(entry_pts!=null)
            {
                InputStream in_pts = file.getInputStream(entry_pts);
                //java.io.InputStreamReader r_pts = new InputStreamReader(in_pts,Config.ENCODING_JAVA);
                java.io.InputStreamReader r_pts = new InputStreamReader(in_pts,"UTF-8");
                java.io.BufferedReader br_pts = new BufferedReader(r_pts);

                String pt_oldid =null;
                while( (s = br_pts.readLine())!=null)
                {
                    pt_oldid = s.trim();
                    if(pt_oldid.length()>0 && templates!=null)
                    {
                        aTopic.AddPageTemplate((PageTemplate)templates.get(pt_oldid));
                    }
                }

                try{br_pts.close();}catch(Exception e1){}
            }

            //2008.09.28 加载自定义变量
            String entry_varsname = "TOPIC" + top_oldid + ".vars";
            ZipEntry entry_vars = file.getEntry(entry_varsname);
            if(entry_vars!=null)
            {
                InputStream in_vars = file.getInputStream(entry_vars);
                java.io.InputStreamReader r_vars = new InputStreamReader(in_vars,"UTF-8");
                java.io.BufferedReader br_vars = new BufferedReader(r_vars);

                while( (s = br_vars.readLine())!=null)
                {
                    String var_name = s.trim();
                    String var_value = br_vars.readLine();
                    String var_comment = br_vars.readLine();
                    aTopic.AddVar(var_name,var_value,var_comment);
                }

                try{br_vars.close();}catch(Exception e1){}
            }

            //2010.04.30 加载Solr自定义字段
            String entry_solrfieldname = "TOPIC" + top_oldid + ".solr";
            ZipEntry entry_solrfields = file.getEntry(entry_solrfieldname);
            if(entry_solrfields!=null)
            {
                InputStream in_fields = file.getInputStream(entry_solrfields);
                java.io.InputStreamReader r_fields = new InputStreamReader(in_fields,"UTF-8");
                java.io.BufferedReader br_fields = new BufferedReader(r_fields);

                while( (s = br_fields.readLine())!=null)
                {
                    String field_name = s.trim();
                    String field_comment = br_fields.readLine();
                    aTopic.AddSolrField(field_name,field_comment);
                }

                try{br_fields.close();}catch(Exception e1){}
            }

            //2010.07.22 加载Keyword links
            String entry_keywordlinkname = "TOPIC" + top_oldid + ".keys";
            ZipEntry entry_keywordlink = file.getEntry(entry_keywordlinkname);
            if(entry_keywordlink!=null)
            {
                InputStream in_fields = file.getInputStream(entry_keywordlink);
                java.io.InputStreamReader r_fields = new InputStreamReader(in_fields,"UTF-8");
                java.io.BufferedReader br_fields = new BufferedReader(r_fields);

                while( (s = br_fields.readLine())!=null)
                {
                   s = s.trim();
                   if(s.length()==0) continue;

                   aTopic.AddKeywordLink(s);
                }

                try{br_fields.close();}catch(Exception e1){}
            }


            //保存数据，不能使用缺省的SAVE方法,因为create table语句将自动提交事务。
            // 外部数据源以后创建
            //2009.10.08 栏目已存在的进行覆盖
            if(bOverwrite)
            {
                aTopicTree.UpdateTopic(ctxt,aTopic);
            }
            else
            {
                aTopicTree.SaveTopic(ctxt,aTopic);
            }

            aTopicTree.UpdateTopicPageTemplate(ctxt,aTopic);
            //bugfix:2008.11.29保存自定义变量
            aTopicTree.UpdateTopicVars(ctxt,aTopic);

            aTopicTree.AddTopic(aTopic);

            //加入old索引
            topic_indexby_oldid.put(top_oldid,aTopic);

        }

        try{list_br.close();}catch(Exception e1){}
        return aTopicTree;
    }

    //修正数据库中没有正确设置的layer值
    private void CorrectLayerInDB(NpsContext inCtxt) throws NpsException
    {
        PreparedStatement pstmt = null;
        PreparedStatement pstmt_update = null;
        ResultSet rs = null;
        String sql = null;
        try
        {
            sql = "select id,code,layer from topic where layer is null";
            pstmt = inCtxt.GetConnection().prepareStatement(sql);
            rs = pstmt.executeQuery();

            sql = "update topic set layer=? where id=?";
            pstmt_update = inCtxt.GetConnection().prepareStatement(sql);
            while(rs.next())
            {
                pstmt_update.setInt(1,GetLayer(rs.getString("code")));
                pstmt_update.setString(2,rs.getString("id"));
                pstmt_update.executeUpdate();
            }

            inCtxt.Commit();
        }
        catch(Exception e)
        {
            inCtxt.Rollback();
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            if(rs!=null) try{rs.close();}catch(Exception e){};
            if(pstmt!=null) try{pstmt.close();}catch(Exception e){};
            if(pstmt_update!=null) try{pstmt_update.close();}catch(Exception e){};
        }
    }
}
