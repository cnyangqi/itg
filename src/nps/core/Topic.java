package nps.core;

import nps.util.Utils;
import nps.util.tree.TreeNode;
import nps.util.tree.Node;

import java.util.*;
import java.util.zip.ZipOutputStream;
import java.util.zip.ZipEntry;
import java.io.File;
import java.io.Serializable;

import nps.exception.NpsException;
import nps.event.*;
import nps.PublishableObject;

/**
 *  6.2010.07.21 jialin
 *     增加热字管理
 * 
 *  5.2010.04.02 jialin
 *     增加归档方案设置
 *
 *  4.2010.01.25 jialin
 *     修改Visible范围为公开、本单位内可见、隐藏
 * 
 *  3.2009.08.22 jialin
 *     增加对 ORG_  头的识别
 * 
 *  2.2008.10.18 jialin
 *     当设置自定义数据源时自动增加事件的监听，取消时则自动取消
 * 
 *  1.2008.09.28 jialin
 *     增加栏目自定义变量
 * 
 *  NPS - a new publishing system
 *  Copyright (c) 2007
 *
 * @author jialin, lanxi justa network co.,ltd.
 * @version 1.0
 */
public class Topic extends PublishableObject implements TreeNode,IPortable,Serializable,
                                                    InsertEventListener, UpdateEventListener,
                                                    DeleteEventListener,Ready2PublishEventListener,
                                                    PublishEventListener,CancelEventListener
{
    private Site   site; //站点
    private String id; //栏目id
    private String parentid; //父id
    private String alias = null; //栏目别名
    private String code = null; //栏目代号，为parent栏目别名+"."+本栏目别名
    private String name = null; //栏目名称
    private int order = 0; //次序
    private int default_article_state = ARTICLE_DRAFT; //文章录入后的缺省状态
    private float default_article_score = 0; //默认积分
    private String table = null;   //外部数据源，使用article表为NULL
    private int visibility = TOPIC_PUBLIC_COMPANY; //可见范围,默认为本单位内用户可见

    private ArticleTemplate article_template = null;   //文章模板
    private List page_templates = null;   //页面模板

    private int archive_mode = ARCHIVE_NO; //归档模式
    private PageTemplate archive_template = null; //归档模版
    
    private Hashtable owners = null; //版主
    private Hashtable vars = null; //栏目自定义变量

    private String comment = null; //注释

    private Boolean solr_enabled = null; //是否启用Solr索引, null表示根据站点配置决定，false表示不启用，true表示启用
    private int is_business = 0; //是否业务数据
    private String solr_core = null; //null表示根据站点配置
    private Hashtable solr_fields = null; //SOLR自定义字段

    private Boolean sort_enabled = null; //是否手工排序, null表示根据上级栏目决定，false表示自动排序，true表示手工排序

    private KeywordLinkGroup keyword_links = null; //热字

    public Topic(Site site,String parentid,String id,String name,String alias,String code,int order,int isBusiness)
    {
        this.site = site;
        this.parentid = parentid;
        this.id = id;
        this.name = name;
        this.alias = alias;
        if(code!=null) this.code = code.toLowerCase(); 
        this.order = order;
        this.is_business = isBusiness;
    }
    public Topic(Site site,String parentid,String id,String name,String alias,String code,int order)
    {
        this.site = site;
        this.parentid = parentid;
        this.id = id;
        this.name = name;
        this.alias = alias;
        if(code!=null) this.code = code.toLowerCase(); 
        this.order = order;
    }
    //复制src的Topic到parent下    
    public Topic(String newid,Topic parent,Topic src)
    {
        this.site = parent.GetSite();
        this.parentid = parent.GetId();
        this.id = newid;
        this.name = src.GetName();
        this.alias = src.GetAlias();
        this.code = parent.GetCode()+"."+src.GetAlias().toLowerCase();
        this.order = src.GetOrder();
        this.default_article_state = src.GetDefaultArticleState();
        this.default_article_score = src.GetScore();
        this.table = src.GetMyTable();
        this.visibility = src.visibility;

        this.article_template = src.GetArticleTemplate();

        this.archive_mode = src.archive_mode;
        this.archive_template = src.archive_template;

        this.solr_enabled = src.solr_enabled;
        this.is_business = src.is_business;
        this.solr_core = src.solr_core;

        this.sort_enabled = src.sort_enabled;

        //复制页面模板
        this.page_templates = null;
        List src_page_templates = src.GetPageTemplates();
        if(src_page_templates!=null && !src_page_templates.isEmpty())
        {
            this.page_templates = Collections.synchronizedList(new ArrayList(src_page_templates.size()));
            for(Object obj:src_page_templates)
            {
                 this.AddPageTemplate((PageTemplate)obj);
            }
        }

        //复制owner对象
        this.owners = null;
        Hashtable src_owners = src.GetOwner();
        if(src_owners!=null && !src_owners.isEmpty())
        {
            this.owners = new Hashtable(src_owners.size());
            java.util.Enumeration src_owners_list = src_owners.elements();
            while(src_owners_list.hasMoreElements())
            {
                Owner aOwner = (Owner)src_owners_list.nextElement();
                this.owners.put(aOwner.uid,aOwner.uname);
            }
        }

        //复制自定义变量
        this.vars = null;
        Hashtable src_vars = src.GetVars();
        if(src_vars!=null && !src_vars.isEmpty())
        {
            this.vars = new Hashtable(src_vars.size());
            java.util.Enumeration src_vars_list = src_vars.elements();
            while(src_vars_list.hasMoreElements())
            {
                Var var = (Var)src_vars_list.nextElement();
                this.vars.put(var.name,new Var(var.name,var.value,var.comment));
            }
        }

        //复制Solr Fields
        this.solr_fields = null;
        Hashtable src_fields = src.solr_fields;
        if(src_fields!=null && !src_fields.isEmpty())
        {
            this.solr_fields = new Hashtable(src_fields.size());
            Enumeration enum_fields = src_fields.elements();
            while(enum_fields.hasMoreElements())
            {
                SolrField field = (SolrField)enum_fields.nextElement();
                this.solr_fields.put(field.name,new SolrField(field.name, field.comment));
            }
        }

        //复制Keyword links
        this.keyword_links = null;
        if(src.keyword_links!=null) AddKeywordLinks(src.keyword_links.toString());
    }

    //复制src的topic到指定的siteid站点的根目录下
    public Topic(String newid,Site site,Topic src)
    {
        this.site = site;
        this.parentid = "-1";
        this.id = newid;
        this.name = src.GetName();
        this.alias = src.GetAlias();
        this.code = src.GetAlias();
        this.code = this.code.toLowerCase();
        this.order = src.GetOrder();
        this.default_article_state = src.GetDefaultArticleState();
        this.default_article_score = src.GetScore();
        this.table = src.GetMyTable();
        this.visibility = src.visibility;

        this.article_template = src.GetArticleTemplate();

        this.archive_mode = src.archive_mode;
        this.archive_template = src.archive_template;

        this.solr_enabled = src.solr_enabled;
        this.solr_core = src.solr_core;

        this.sort_enabled = src.sort_enabled;
        
        //复制页面模板
        this.page_templates = null;
        List src_page_templates = src.GetPageTemplates();
        if(src_page_templates!=null && !src_page_templates.isEmpty())
        {
            this.page_templates = Collections.synchronizedList(new ArrayList(src_page_templates.size()));
            for(Object obj:src_page_templates)
            {
                 this.AddPageTemplate((PageTemplate)obj);
            }
        }

        //复制owner对象
        this.owners = null;
        Hashtable src_owners = src.GetOwner();
        if(src_owners!=null && !src_owners.isEmpty())
        {
            this.owners = new Hashtable(src_owners.size());
            java.util.Enumeration src_owners_list = src_owners.elements();
            while(src_owners_list.hasMoreElements())
            {
                Owner aOwner = (Owner)src_owners_list.nextElement();

                owners.put(aOwner.uid,aOwner.uname);
            }
        }

        //复制自定义变量
        this.vars = null;
        Hashtable src_vars = src.GetVars();
        if(src_vars!=null && !src_vars.isEmpty())
        {
            this.vars = new Hashtable(src_vars.size());
            java.util.Enumeration src_vars_list = src_vars.elements();
            while(src_vars_list.hasMoreElements())
            {
                Var var = (Var)src_vars_list.nextElement();
                vars.put(var.name,new Var(var.name,var.value,var.comment));
            }
        }

        //复制Solr Fields
        this.solr_fields = null;
        Hashtable src_fields = src.solr_fields;
        if(src_fields!=null && !src_fields.isEmpty())
        {
            this.solr_fields = new Hashtable(src_fields.size());
            Enumeration enum_fields = src_fields.elements();
            while(enum_fields.hasMoreElements())
            {
                SolrField field = (SolrField)enum_fields.nextElement();
                this.solr_fields.put(field.name,new SolrField(field.name, field.comment));
            }
        }

        //复制Keyword links
        this.keyword_links = null;
        if(src.keyword_links!=null) AddKeywordLinks(src.keyword_links.toString());
    }

    //是否继承
    public boolean IsInherit()
    {
        if(table==null || table.length()==0) return true;
        return false;
    }

    //判断是否自定义数据源栏目
    public boolean IsCustom()
    {
        if(table!=null  && table.length()>0) return true;
        Topic parent = GetParent();
        if(parent==null) return false;

        return parent.IsCustom();
    }

    //判断是否需要归档
    public boolean IsArchive()
    {
        return archive_mode!=ARCHIVE_NO;
    }

    public Site GetSite()
    {
        return site;
    }

    public String GetSiteId()
    {
        return site.GetId();
    }
       
    protected void SetSite(Site site)
    {
        this.site = site;
    }

    public String GetCode()
    {
        return code;
    }

    public void SetCode(String c)
    {
        if(c!=null) c = c.toLowerCase();
        code = c;
    }

    public void SetName(String n)
    {
        name = n;
    }

    public String GetName()
    {
        return name;
    }

    public void SetAlias(String s)
    {
        alias = s;
    }

    public String GetAlias()
    {
        return alias;
    }

    public void SetOrder(int i)
    {
        order =i;
    }

    public int GetOrder()
    {
        return order;    
    }

    public int GetVisibility()
    {
        return visibility;
    }

    public boolean IsPublic()
    {
        return visibility==TOPIC_PUBLIC;
    }
    
    public boolean IsHidden()
    {
        return visibility==TOPIC_HIDDEN;
    }

    public void SetVisibility(int i)
    {
        this.visibility = i;
    }

    public void SetDefaultArticleState(int state)
    {
        this.default_article_state = state;
    }

    public int GetDefaultArticleState()
    {
        return default_article_state;
    }

    public float GetScore()
    {
        return default_article_score;
    }

    public void SetScore(float x)
    {
        default_article_score = x;
    }

    public Boolean GetMySolrEnable()
    {
        return solr_enabled;
    }

    public void SetSolrEnabled(int i)
    {
        switch(i)
        {
            case 0: //默认跟站点配置
                solr_enabled = null;
                break;
            case 1:// 不启用
                solr_enabled = Boolean.FALSE;
                break;
            case 2: //启用
                solr_enabled = Boolean.TRUE;
                break;
        }
    }

    public void SetSolrEnabled(Boolean b)
    {
        solr_enabled = b;
    }   

    public boolean IsSolrEnabled()
    {
        //根据判断全局nps.conf是否启用
        if(Config.SOLR_URL==null || Config.SOLR_URL.length()==0) return false;
        //递归查看上级栏目
        if(solr_enabled==null)
        {
            Topic parent = GetParent();

            //缺省使用站点全局配置
            return parent==null?site.IsFulltextIndex():parent.IsSolrEnabled();
        }

        return solr_enabled;
    }

    public String GetMySolrCore()
    {
        return solr_core;
    }

    public Boolean GetMySortEnable()
    {
        return sort_enabled;
    }

    public void SetSortEnabled(int i)
    {
        switch(i)
        {
            case 0: //默认跟上级配置
                sort_enabled = null;
                break;
            case 1:// 不启用
                sort_enabled = Boolean.FALSE;
                break;
            case 2: //启用
                sort_enabled = Boolean.TRUE;
                break;
        }
    }

    public void SetSortEnabled(Boolean b)
    {
        sort_enabled = b;
    }

    public boolean IsSortEnabled()
    {
        //递归查看上级栏目
        if(sort_enabled==null)
        {
            Topic parent = GetParent();

            //缺省使用站点全局配置
            return parent==null?false:parent.IsSortEnabled();
        }

        return sort_enabled;
    }

    //判断是否是自定义变量
    public boolean IsReversedSolrField(String field_name)
    {
        //根据判断全局nps.conf是否启用
        if(Config.SOLR_URL==null || Config.SOLR_URL.length()==0) return false;

        if(solr_enabled!=null && !solr_enabled) return false;

        //当前栏目优先
        if(solr_fields!=null && !solr_fields.isEmpty()) return HasSolrField(field_name.toUpperCase());

        //递归查看上级栏目
        Topic parent = GetParent();
        if(parent==null)
        {
            //查看站点全局配置
            //如果站点是全文索引的并且当前栏目的Core和站点Core相同，则可以使用当前站点的自定义字段
            if(site.IsFulltextIndex() && (solr_core==null || solr_core.length()==0 || solr_core.equals(site.GetSolrCore())))
                return site.HasSolrField(field_name.toUpperCase());

            return false;
        }

        return parent.IsReversedSolrField(field_name);
    }

    //递归查看Solr Core的配置
    public String GetSolrCore()
    {
        //根据判断全局nps.conf是否启用
        if(Config.SOLR_URL==null || Config.SOLR_URL.length()==0) return null;

        //禁用的，返回null
        if(solr_enabled!=null && !solr_enabled) return null;

        if(solr_core!=null && solr_core.length()>0) return solr_core;

        //递归查看上级栏目
        if(solr_enabled==null)
        {
            Topic parent = GetParent();
            if(parent==null)
            {
                //查看站点全局配置
                if(!site.IsFulltextIndex()) return null;
                return site.GetSolrCore();
            }

            return parent.GetSolrCore();
        }

        //强制打开情况
        Topic parent = GetParent();
        if(parent==null)
        {
            //查看站点全局配置
            if(!site.IsFulltextIndex()) return "npscore";
            return site.GetSolrCore();
        }

        return parent.GetSolrCore();
    }

    public void SetSolrCore(String s)
    {
        solr_core = s;
    }
    
    //2010.04.30 jialin 增加站点SOLR自定义字段配置
    public Hashtable GetSolrFields()
    {
        return solr_fields;
    }

    public SolrField GetSolrField(String key)
    {
        if(key==null || key.length()==0) return null;
        if(solr_fields==null || solr_fields.isEmpty()) return null;
        return (SolrField)solr_fields.get(key.toUpperCase());
    }

    public void AddSolrField(String name,String comment)
    {
        String key = name.toUpperCase();
        SolrField field = new SolrField(key,comment);
        if(solr_fields==null)
        {
            solr_fields = new Hashtable();
        }
        else if(!solr_fields.isEmpty())
        {
            solr_fields.remove(key);
        }

        solr_fields.put(key,field);
    }

    public void RemoveSolrField(String name)
    {
        if(name==null || name.length()==0) return;
        if(solr_fields==null || solr_fields.isEmpty()) return;
        solr_fields.remove(name.toUpperCase());
    }

    public boolean HasSolrField(String name)
    {
        if(name==null || name.length()==0) return false;
        if(solr_fields!=null && solr_fields.containsKey(name.toUpperCase())) return true;
        return false;
    }

    public void ClearSolrFields()
    {
        if(solr_fields!=null) solr_fields.clear();
    }

    public void AddKeywordLink(String keyword,String url)
    {
        if(keyword_links == null) keyword_links = new KeywordLinkGroup();
        keyword_links.add(keyword,url);
    }

    public void AddKeywordLink(String line)
    {
        if(keyword_links == null) keyword_links = new KeywordLinkGroup();
        keyword_links.add(line);
    }

    public void AddKeywordLinks(String lines)
    {
        if(keyword_links==null)
        {
            keyword_links = new KeywordLinkGroup(lines);
        }
        else
        {
            keyword_links.addAll(lines);
        }
    }

    public int RemoveKeywordLink(String keyword,String url)
    {
        if(keyword_links==null) return 0;
        return keyword_links.remove(keyword,url);
    }

    public int RemoveKeywordLinks(String url)
    {
        if(keyword_links==null) return 0;
        return keyword_links.remove(url);
    }
    
    public KeywordLinkGroup GetKeywordLinks()
    {
        return keyword_links;
    }

    public void ClearKeywordLinks()
    {
        if(keyword_links!=null) keyword_links.clear();
    }

    public void SetArticleTemplate(ArticleTemplate t)
    {
        this.article_template = t;
    }

    public ArticleTemplate GetArticleTemplate()
    {
        return article_template;
    }

    //一直回溯得到级联的上级Article Template
    public ArticleTemplate GetCascadedArticleTemplate()
    {
        if(article_template!=null)  return article_template;

        Topic parent = GetParent();
        if(parent==null) return null;

        return parent.GetCascadedArticleTemplate();
    }

    public int GetArchiveMode()
    {
        return archive_mode;
    }

    public void SetArchiveMode(int mode)
    {
        this.archive_mode = mode;
        
        //如果是不归档模式，取消当前归档栏目模版设置
        if(mode==ARCHIVE_NO) archive_template = null;
    }

    public void SetArchiveTemplate(PageTemplate t)
    {
        if(archive_mode==ARCHIVE_NO)
            archive_template = null;
        else
            archive_template = t;
    }

    public PageTemplate GetArchiveTemplate()
    {
        if(archive_mode==ARCHIVE_NO) return null;
        
        return archive_template; 
    }

    public void SetComment(String comment)
    {
        this.comment = comment;
    }

    public String GetComment()
    {
        return comment;
    }

    public void ClearPageTemplates()
    {
         page_templates = null;
    }

    public void AddPageTemplate(PageTemplate t)
    {
       if(t==null) return;
       if(page_templates==null) page_templates = Collections.synchronizedList(new ArrayList());
       page_templates.add(t);
    }

    public List GetPageTemplates()
    {
        return page_templates;
    }

    public PageTemplate GetPageTemplate(int i)
    {
        if(page_templates==null || page_templates.isEmpty()) return null;
        return (PageTemplate)page_templates.get(i);
    }

    public PageTemplate GetPageTemplate(String id)
    {
        if (page_templates == null || page_templates.isEmpty())  return null;
        PageTemplate aTemplate = null;
        Iterator i_page_templates = page_templates.iterator();
        while(i_page_templates.hasNext())
        {
            aTemplate = (PageTemplate)i_page_templates.next();
            if(aTemplate.GetId().equalsIgnoreCase(id))
            {
                return aTemplate;
            }
        }

        return null;
    }

    //2008.10.01 jialin
    //  根据id删除指定模板
    public void RemovePageTemplate(String id)
    {
        if(page_templates == null || page_templates.isEmpty()) return;
        if(id==null || id.length()==0) return;

        for(int i=0;i<page_templates.size();i++)
        {
            PageTemplate aTemplate = (PageTemplate)page_templates.get(i);
            if(aTemplate.GetId().equalsIgnoreCase(id))
            {
                page_templates.remove(i);
                return;
            }
        }
    }

    public String GetMyTable()
    {
        return table;
    }

    public String GetTable()
    {
        if(table!=null && table.length()>0) return table;

        Topic parent = GetParent();
        if(parent==null) return null;
        return parent.GetTable();
    }

    public void SetTable(String t)
    {
        if(t!=null && t.length()==0) t = null;

        if(table!=null)
        {
            //取消事件的监听
            EventSubscriber.GetSubscriber().RemoveListener(Ready2PublishEventListener.class,this);
            EventSubscriber.GetSubscriber().RemoveListener(InsertEventListener.class,this);
            EventSubscriber.GetSubscriber().RemoveListener(UpdateEventListener.class,this);
            EventSubscriber.GetSubscriber().RemoveListener(DeleteEventListener.class,this);
            EventSubscriber.GetSubscriber().RemoveListener(PublishEventListener.class,this);
            EventSubscriber.GetSubscriber().RemoveListener(CancelEventListener.class,this);
        }
        
        if(t!=null)
        {
            //设置监听程序
            String key = t.toUpperCase();//对表的各类更新事件感兴趣

            EventSubscriber.GetSubscriber().AddListener((Ready2PublishEventListener)this,key);
            EventSubscriber.GetSubscriber().AddListener((InsertEventListener)this,key);
            EventSubscriber.GetSubscriber().AddListener((UpdateEventListener)this,key);
            EventSubscriber.GetSubscriber().AddListener((DeleteEventListener)this,key);
            EventSubscriber.GetSubscriber().AddListener((PublishEventListener)this,key);
            EventSubscriber.GetSubscriber().AddListener((CancelEventListener)this,key);
        }

        table = t;
    }

    public Hashtable GetOwner()
    {
        return owners;
    }
    
    public void ClearOwner()
    {
        owners = null;
    }

    public void AddOwner(String uid,String uname)
    {
        Owner aOwner = new Owner(uid,uname);
        if(owners==null)
        {
            owners = new Hashtable();
        }
        else if(!owners.isEmpty())
        {
            owners.remove(uid);   
        }
        
        owners.put(uid,aOwner);
    }

    public void RemoveOwner(String uid)
    {
        if(uid==null || uid.length()==0) return;
        if(owners==null || owners.isEmpty()) return;
        owners.remove(uid);        
    }

    public boolean IsOwner(String uid)
    {
        if(owners!=null && owners.containsKey(uid)) return true;
        Topic parent = GetParent();
        if(parent!=null)
        {
            return parent.IsOwner(uid);
        }
        return false;
    }    

    //2008.09.28 jialin 增加栏目自定义变量
    public Hashtable GetVars()
    {
        return vars;
    }

    public Var GetVar(String key)
    {
        if(key==null || key.length()==0) return null;
        if(vars==null || vars.isEmpty()) return null;
        return (Var)vars.get(key.toUpperCase()); 
    }

    public String GetVarValue(String key)
    {
        if(key==null || key.length()==0) return null;
        if(vars==null || vars.isEmpty()) return null;
        Var var = (Var)vars.get(key.toUpperCase());
        if(var!=null) return var.value;
        return null;
    }

    public void AddVar(String name,String value)
    {
        AddVar(name,value,null);
    }

    public void AddVar(String name,String value,String comment)
    {
        String key = name.toUpperCase();
        Var var = new Var(key,value,comment);
        if(vars==null)
        {
            vars = new Hashtable();
        }
        else if(!vars.isEmpty())
        {
            vars.remove(key);
        }

        vars.put(key,var);
    }

    public void RemoveVar(String name)
    {
        if(name==null || name.length()==0) return;
        if(vars==null || vars.isEmpty()) return;
        vars.remove(name.toUpperCase());
    }

    public boolean HasVar(String name)
    {
        if(name==null || name.length()==0) return false;
        if(vars!=null && vars.containsKey(name.toUpperCase())) return true;
        return false;
    }

    public void ClearVars()
    {
        if(vars!=null) vars.clear();        
    }

    //2008.05.23 jialin
    //获得上级节点
    public Topic GetParent()
    {
        if(parentid==null || "-1".equals(parentid) || parentid.length()==0)
            return null;

        return site.GetTopicTree().GetTopic(parentid);
    }
    
    //TreeNode方法
    public String GetId()
    {
        return id;
    }

    public String GetParentId()
    {
        return parentid;
    }

    public void SetParentId(String s)
    {
        this.parentid = s;
    }

    public int GetIndex()
    {
        return order;
    }

    public int GetLayer()
    {
        int layer = 0;
        int pos_dot = code.indexOf(".");
        if(pos_dot==-1) return layer;

        while(pos_dot!=-1)
        {
            layer++;
            pos_dot = code.indexOf(".",pos_dot+1);
        }

        return layer;
    }

    //2008.05.27 jialin
    public String GetNavCode(Topic topic)
    {
        return GetNavCode(topic," > ");
    }

    //得到导航目录
    public String GetNavCode(Topic topic,String split)
    {
        if(topic==null) return null;

        //注意,Utils将转换< > & "，在此使用转义符
        String nav_code = "<a href=\""+topic.GetURL()+"\">"+topic.GetName()+"</a>";
        String nav_parent = GetNavCode(topic.GetParent(),split);

        if(nav_parent==null) return nav_code;
        return nav_parent + split + nav_code;
    }

    //2010.04.28 jialin
    //返回下级栏目列表
    public List<Topic> GetChilds()
    {
        List<Topic> childs = new ArrayList();

        TopicTree tree = site.GetTopicTree();
        Iterator childs_iterator = tree.GetChilds(this);
        if(childs_iterator==null) return null;
        while(childs_iterator.hasNext())
        {
            Node n = (Node)childs_iterator.next();
            childs.add((Topic)n.GetValue());
        }

        if(childs.isEmpty()) return null;
        return childs;
    }

    //返回Topic根路径
    public String GetURL()
    {
        String url = site.GetRootURL() + "/" + code.replaceAll("[.]","/") + "/";
        url = Utils.FixURL(url);
        return url;
    }

    //得到相对路径
    public String GetRelativeURL()
    {
        String url = "/" + code.replaceAll("[.]","/") + "/";
        url = Utils.FixURL(url);
        return url;
    }

    //等于相对路径
    public String GetPath()
    {
        String path = code.replaceAll("[.]","/");
        path = "/" + path+"/";
        path = Utils.FixURL(path);
        return path;
    }

    //IPublishable系列方法
    public File   GetOutputFile()
    {
        String temp_filepath = code.replaceAll("[.]","/");

        File temp_file = new File( site.GetArticleDir(),
                                   temp_filepath
                                  );

        temp_file.mkdirs();

        return temp_file;
    }

    public boolean HasField(String fieldName)
    {
        if(fieldName==null || fieldName.length()==0) return false;

        String key = fieldName.trim();
        if(key.length()==0) return false;

        key = key.toUpperCase();

        if(key.equalsIgnoreCase("top_id")) return true;
        if(key.equalsIgnoreCase("top_name")) return true;
        if(key.equalsIgnoreCase("top_code")) return true;
        if(key.equalsIgnoreCase("top_alias")) return true;
        if(key.equalsIgnoreCase("top_url")) return true;
        if(key.equalsIgnoreCase("top_path")) return true;

        //2008.05.27 新增top_navigator标签
        if(key.equalsIgnoreCase("top_navigator")) return true;
        if(key.equalsIgnoreCase("top_nav")) return true;
        
        //2008.05.27 新增parent标签
        if(key.equalsIgnoreCase("top_parentid")) return true;
        if(key.equalsIgnoreCase("top_parentname")) return true;
        if(key.equalsIgnoreCase("top_parentcode")) return true;
        if(key.equalsIgnoreCase("top_parentalias")) return true;
        if(key.equalsIgnoreCase("top_parenturl")) return true;
        if(key.equalsIgnoreCase("top_parentpath")) return true;
        if(key.equalsIgnoreCase("top_parent")) return true;

        //2008.11.15 新增top_layer标签
        if(key.equalsIgnoreCase("top_layer")) return true;

        //2008.09.28 新增自定义变量查询
        return HasVar(key);
    }

    public Field GetField(String fieldName) throws NpsException
    {
        if(fieldName==null || fieldName.length()==0) return Field.Null;

        String key = fieldName.trim();
        if(key.length()==0) return Field.Null;

        key = key.toUpperCase();

        if(key.equalsIgnoreCase("top_id")) return new Field(id);
        if(key.equalsIgnoreCase("top_name")) return new Field(name);
        if(key.equalsIgnoreCase("top_code")) return new Field(code);
        if(key.equalsIgnoreCase("top_alias")) return new Field(alias);
        if(key.equalsIgnoreCase("top_url")) return new Field(GetURL());
        if(key.equalsIgnoreCase("top_path")) return new Field(GetPath());

        //2008.05.27 新增top_navigator标签
        if(key.equalsIgnoreCase("top_navigator")) return new Field(GetNavCode(this));
        if(key.equalsIgnoreCase("top_nav")) return new Field(GetNavCode(this));
        
        //2008.05.27 新增parent标签
        if(key.equalsIgnoreCase("top_parentid"))
        {
            Topic parent = GetParent();
            return new Field(parent==null?"":parent.GetId());
        }
        
        if(key.equalsIgnoreCase("top_parentname"))
        {
            Topic parent = GetParent();
            return new Field(parent==null?"":parent.GetName());
        }
        
        if(key.equalsIgnoreCase("top_parentcode"))
        {
            Topic parent = GetParent();
            return new Field(parent==null?"":parent.GetCode());
        }
        
        if(key.equalsIgnoreCase("top_parentalias"))
        {
            Topic parent = GetParent();
            return new Field(parent==null?"":parent.GetAlias());
        }

        if(key.equalsIgnoreCase("top_parenturl"))
        {
            Topic parent = GetParent();
            return new Field(parent==null?"":parent.GetURL());
        }
        
        if(key.equalsIgnoreCase("top_parentpath"))
        {
            Topic parent = GetParent();
            return new Field(parent==null?"":parent.GetPath());
        }

        if(key.equalsIgnoreCase("top_parent")) return new Field(GetParent());

        //2008.11.15 新增top_layer标签
        if(key.equalsIgnoreCase("top_layer"))  return new Field(GetLayer());

        //站点变量
        if(key.startsWith("SITE_") && site.HasField(key))  return site.GetField(key);

        //单位变量
        if((key.startsWith("UNIT_") || key.startsWith("ORG_")) && site.GetUnit().HasField(key))  return site.GetUnit().GetField(key);

        //2008.09.28 jialin 增加自定义变量支持
        if(HasVar(key))
        {
            return new Field(GetVarValue(key));
        }

        //站点自定义变量
        if(site.HasField(key))  return site.GetField(key);

        return Field.Null;
    }

    public String GetField(String fieldName,String format) throws NpsException
    {
        //2008.06.06 jialin
        // 增加对top_navigator分隔符处理
        if("top_navigator".equalsIgnoreCase(fieldName) || "top_nav".equalsIgnoreCase(fieldName))
        {
            return GetNavCode(this,format);
        }

        return super.GetField(fieldName,format);
    }
    
    //导出模板数据，写入out数据流
    public void  Zip(NpsContext ctxt,ZipOutputStream out) throws Exception
    {
        ZipInfo(out);
        ZipPageTemplates(out);
        ZipOwners(out);
        ZipVars(out);
        ZipSolrFields(out);
        ZipKeywordLinks(out);

        if(article_template!=null && !"0".equals(article_template.GetId()))   article_template.Zip(ctxt,out);
        if(archive_template!=null)   archive_template.Zip(ctxt,out);
        if(page_templates!=null && !page_templates.isEmpty())
        {
            for(Object obj:page_templates)
            {
                PageTemplate pt = (PageTemplate)obj;
                if(pt!=null)   pt.Zip(ctxt,out);
            }            
        }
    }

    //导出基本信息
    private void ZipInfo(ZipOutputStream out) throws Exception
    {
        String filename = "TOPIC" + GetId() + ".topic";
        out.putNextEntry(new ZipEntry(filename));

        try
        {
            //每个信息一行，开始序列化
            ZipWriter writer = new ZipWriter(out);
            writer.println(id);
            writer.println(parentid);
            writer.println(site.GetId());
            writer.println(name);
            writer.println(alias);
            writer.println(code);
            writer.println(order);
            writer.println(default_article_state);
            writer.println(default_article_score);
            writer.println(table);
            if(article_template==null)
                writer.println();
            else
                writer.println(article_template.GetId());
            writer.println(visibility);

            writer.println(archive_mode);
            writer.println(archive_template==null?"":archive_template.GetId());
            writer.println(Utils.Null2Empty(comment));

            writer.println(Utils.Null2Empty(solr_enabled));
            writer.println(Utils.Null2Empty(is_business));
            writer.println(Utils.Null2Empty(solr_core));

            writer.println(Utils.Null2Empty(sort_enabled));
        }
        finally
        {
            out.closeEntry();
        }
    }

    //导出页面模板列表
    private void ZipPageTemplates(ZipOutputStream out) throws Exception
    {
        if(page_templates==null || page_templates.isEmpty()) return;
        
        String filename = "TOPIC" + GetId() + ".pts";
        out.putNextEntry(new ZipEntry(filename));

        try
        {
            //每个信息一行，开始序列化
            ZipWriter writer = new ZipWriter(out);
            for(Object obj:page_templates)
            {
                PageTemplate pt = (PageTemplate)obj;
                if(pt!=null)
                {
                    writer.println(pt.GetId());
                }
            }
        }
        finally
        {
            out.closeEntry();
        }
    }

    //导出版主信息
    private void ZipOwners(ZipOutputStream out) throws Exception
    {
        if(owners==null || owners.isEmpty()) return;

        String filename = "TOPIC" + GetId() + ".owners";
        out.putNextEntry(new ZipEntry(filename));

        try
        {
            //每个信息一行，开始序列化
            ZipWriter writer = new ZipWriter(out);
            java.util.Enumeration owners_enum = owners.elements();
            while(owners_enum.hasMoreElements())
            {
                Owner owner = (Owner)owners_enum.nextElement();
                if(owner!=null)  writer.println(owner.GetID());
            }
        }
        finally
        {
            out.closeEntry();
        }
    }

    //导出自定义变量
    private void ZipVars(ZipOutputStream out) throws Exception
    {
        if(vars==null || vars.isEmpty()) return;

        String filename = "TOPIC" + GetId() + ".vars";
        out.putNextEntry(new ZipEntry(filename));

        try
        {
            //每个信息一行，开始序列化
            ZipWriter writer = new ZipWriter(out);
            java.util.Enumeration vars_enum = vars.elements();
            while(vars_enum.hasMoreElements())
            {
                Var var = (Var)vars_enum.nextElement();
                if(var!=null)
                {
                    writer.println(var.name);
                    writer.println(Utils.Null2Empty(var.value));
                    writer.println(Utils.Null2Empty(var.comment));
                }
            }
        }
        finally
        {
            out.closeEntry();
        }
    }

    //导出Solr自定义字段
    private void ZipSolrFields(ZipOutputStream out) throws Exception
    {
        if(solr_fields==null || solr_fields.isEmpty()) return;

        String filename = "TOPIC" + GetId() + ".solr";
        out.putNextEntry(new ZipEntry(filename));

        try
        {
            //每个信息一行，开始序列化
            ZipWriter writer = new ZipWriter(out);
            java.util.Enumeration fields_enum = solr_fields.elements();
            while(fields_enum.hasMoreElements())
            {
                SolrField field = (SolrField)fields_enum.nextElement();
                if(field!=null)
                {
                    writer.println(field.name);
                    writer.println(Utils.Null2Empty(field.comment));
                }
            }
        }
        finally
        {
            out.closeEntry();
        }
    }

    //导出Solr自定义字段
    private void ZipKeywordLinks(ZipOutputStream out) throws Exception
    {
        if(solr_fields==null || solr_fields.isEmpty()) return;

        String filename = "TOPIC" + GetId() + ".keys";
        out.putNextEntry(new ZipEntry(filename));

        try
        {
            ZipWriter writer = new ZipWriter(out);
            writer.print(keyword_links.toString());            
        }
        finally
        {
            out.closeEntry();
        }
    }


    //版主，对栏目具有管理权限
    public class Owner
    {
        protected String uid;
        protected String uname;
        
        public Owner(String uid,String uname)
        {
            this.uid = uid;
            this.uname = uname;
        }

        public String GetID()
        {
            return uid;
        }

        public String GetName()
        {
            return uname;
        }
    }

    //自定义变量
    public class Var
    {
        protected String name;
        protected String value;
        protected String comment;

        public Var(String name,String value,String comment)
        {
            this.name = name;
            this.value = value;
            this.comment = comment;
        }

        public String GetName()
        {
            return name;
        }

        public String GetValue()
        {
            return value;
        }

        public String GetComment()
        {
            return comment;
        }
    }

    public class SolrField
    {
        protected String name;
        protected String comment;

        public SolrField(String name,String comment)
        {
            this.name = name;
            this.comment = comment;
        }

        public String GetName()
        {
            return name;
        }

        public String GetComment()
        {
            return comment;
        }
    }
    
    //事件处理
    public void DataInserted(InsertEvent e)
    {
        IEventAction act = (IEventAction)e.getSource();
        act.Insert(this,e);
    }

    public void DataUpdated(UpdateEvent e)
    {
        IEventAction act = (IEventAction)e.getSource();
        act.Update(this,e);
    }

    public void DataDeleted(DeleteEvent e)
    {
        IEventAction act = (IEventAction)e.getSource();
        act.Delete(this,e);
    }

    public void DataReady(Ready2PublishEvent e)
    {
        IEventAction act = (IEventAction)e.getSource();
        act.Ready(this,e);
    }

    public void DataPublished(PublishEvent e)
    {
        IEventAction act = (IEventAction)e.getSource();
        act.Publish(this,e);
    }

    public void DataCancelled(CancelEvent e)
    {
        IEventAction act = (IEventAction)e.getSource();
        act.Cancel(this,e);        
    }

    public String toString()
    {
        return name;
    }

    public boolean equals(Topic t)
    {
        if(t==null) return false;
        return id.equals(t.id);
    }

    public int getIs_business() {
      return is_business;
    }

    public void setIs_business(int is_business) {
      this.is_business = is_business;
    }
    
    
}