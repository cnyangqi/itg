package nps.core;

import java.sql.*;
import java.util.zip.ZipFile;
import java.io.*;

import nps.exception.NpsException;
import nps.compiler.PageClassBase;
import nps.BasicContext;

/**
 * 上下文句柄
 *
 * 2008.05.23 jialin
 * 1.增加User对象，记录当前运行用户
 * 2.
 *
 * NPS - a new publishing system
 * Copyright (c) 2007
 * @author jialin, lanxi justa network co.,ltd.
 * @version 1.0
 */

public class NpsContext extends BasicContext
{
    //private Site  site = null;  //当前Site对象
    //private Hashtable site_pool = null; //站点池

    public NpsContext(Connection con,User user) throws SQLException
    {
        super(con, user);
    }

    public Connection GetConnection()
    {
        return conn;
    }

    public User GetUser()
    {
        return user;    
    }

    public void SetUser(User user)
    {
        this.user = user;
    }
    
    //释放所有数据
    public void Clear()
    {
        super.Clear();
        site = null;
    }

    //check site and reload site named by id
    public Site GetSite(String id)
    {
        if(site!=null && site.GetId().equalsIgnoreCase(id)) return site;
        if(id==null || id.length()==0) return site;

        //从Site Pool缓存中读取
        site = SitePool.GetPool().get(id);
        if(site!=null) return site;

        try
        {
            site = Site.GetSite(this,id);
        }
        catch(Exception e)
        {
            nps.util.DefaultLog.error_noexception(e);
            return null;
        }

        if(site!=null)   SitePool.GetPool().put(site);       
        return site;
    }

    //just return site object
    public Site GetSite()
    {
        return site;
    }

    //从zip文件中加载Site
    //  file:zip文件  importer:导入者
    public Site GetSite(ZipFile file,User importer) throws Exception
    {
        Site  asite  = Site.GetSite(this,file,importer);
        if(asite!=null)  SitePool.GetPool().put(asite);        
        return asite;
    }
    
    //保存 站点信息
    public void SaveSite(Site site,boolean bNew) throws NpsException
    {
        if(site==null)  return;
        site.Save(this,bNew);

        if(bNew)  SitePool.GetPool().put(site);       
    }

    //删除Site
    public void DeleteSite(Site site) throws NpsException
    {
        if(site==null) return;

        site.Delete(this);
        SitePool.GetPool().remove(site);        
    }  
  
    //根据ID得到Template对象
    public TemplateBase  GetTemplate(String id) throws NpsException
    {
        //1.到当前缓冲池中搜索
        if(id==null || id.length()==0) return null;
        if(TemplatePool.GetPool().contains(id))  return TemplatePool.GetPool().get(id);

        //2.未找到，到数据库中加载
        return TemplatePool.GetPool().LoadTemplate(this,id);
    }

    //得到文章模版
    public ArticleTemplate GetArticleTemplate(String id) throws NpsException
    {
        TemplateBase template = GetTemplate(id);
        if(template == null) return null;

        if(template instanceof ArticleTemplate)
            return (ArticleTemplate)template;

        return null;
    }

    //得到页面模版
    public PageTemplate GetPageTemplate(String id) throws NpsException
    {
        TemplateBase template = GetTemplate(id);
        if(template == null) return null;

        if(template instanceof PageTemplate)
            return (PageTemplate)template;

        return null;
    }


    //加入FTP传输队列
    public void Add2Ftp(Article art)
    {
        if(site==null) return; 
        site.Add2Ftp(art);
    }

    public void Add2Ftp(Attach att)
    {
        if(site==null) return;
        site.Add2Ftp(att);
    }

    public void Add2Ftp(Resource res)
    {
        if(site==null) return;
        site.Add2Ftp(res);
    }

    public void Add2Ftp(Article art,File page)
    {
        if(site==null) return;
        site.Add2Ftp(art,page);
    }

    public void Add2Ftp(PageClassBase pcb)
    {
        if(site == null) return;
        site.Add2Ftp(pcb);
    }

    public void Add2Ftp(PageClassBase pcb,File page)
    {
        if(site == null) return;
        site.Add2Ftp(pcb,page);
    }

    public void Add2Ftp(File local_file)
    {
        if(site==null) return;
        site.Add2Ftp(local_file);
    }

    public void AddImage2Ftp(File local_file)
    {
        if(site==null) return;
        site.AddImage2Ftp(local_file);        
    }
    
    //增加一个删除远程remote文件
    public void DeleteFromArticleFtp(String remote)
    {
        if(site==null) return;
        site.DeleteFromArticleFtp(remote);
    }

    public void DeleteFromImageFtp(String remote)
    {
        if(site==null) return;
        site.DeleteFromImageFtp(remote);
    }

    //FTP到用户目录
    public void Add2UserDir(File local_file)
    {
        if(site==null)  return;
        site.Add2UserDir(local_file);
    }

    public String toString()
    {
        return "uid="+user.GetUID()+";site="+site.GetId();
    }
}