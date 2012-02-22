package nps.core;

import nps.exception.NpsException;
import nps.exception.ErrorHelper;
import nps.index.ProductArticle2Solr;
import nps.index.IndexScheduler;
import nps.event.*;
import nps.util.DefaultLog;
import nps.util.Utils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;
import java.io.*;

import com.gemway.partner.JLog;
import com.gemway.util.JError;


/**
 * 文章类
 *
 * 2009.08.23  jialin
 *   1.增加正文摘要功能
 *
 * 2008.10.18  jialin
 *  1.增加缺省事件处理方法IEventAction
 *  2.增加各阶段的事件通知
 *  3.Copy函数记录源文章ID号
 *  4.根据源文章ID号加载文章列表
 *  
 * NPS - a new publishing system
 * Copyright (c) 2007
 * @author jialin, lanxi justa network co.,ltd.
 * @version 1.0
 */
public class NormalArticle extends Article implements IEventAction
{
    private String subtitle = null;  //副标题
    private String abtitle = null; //短标题
    private String keyword = null; //关键字
    private String author = null;  //作者
    private int    important = 0;  //重要度 0一般  1重要  2比较重要 3重要
    private String source = null; //来源
    private int    validdays = 0;  //有效天数 0长期有效
    private float  score = 0; //积分
    private String creator = null;  //创建人id号
    private String creator_cn = null; //创建人简称，只有用户名
    private String approver = null; //审稿人
    private String approver_cn = null; //审稿人姓名    
    private String source_id = null; //源ID，标记从哪里复制来的
    private boolean bNew = true;
    private String content_abstract = null; //摘要
    private String pic_url = null; //导读图片

    private String prd_name;
    private String prd_code;
    private int prd_newlevel;
    private double prd_marketprice;
    private double prd_saleprice;
    private Date  prd_saleend;
    
    private double prd_localprice;
    private int prd_point;
    private String prd_brandid;
    private String prd_brandname;
    private String prd_unitid;
    private String prd_unitname;
    private String prd_spec;
    private String prd_origincountryid;
    private String prd_origincountryname;
    private String prd_originprovinceid;
    private String prd_originprovincename;
    private String prd_parameter;
    private double prd_shipfee;
    
    private int prd_season;
    private int prd_import;
    private int prd_reduce;
    private int prd_beauty;
    private int prd_nutrition;
    private int prd_jit;
    
    
    
    
    
    
    private Hashtable<String,String> custom_fields = null; //自定义字段

    //Constructor
    public NormalArticle(NpsContext inCtxt,String id,String title,Topic top,String creator)
    {
        super(inCtxt,id,title,top);
        this.creator = creator;
        this.score = top.GetScore();
        this.bNew = false;
    }

    public NormalArticle(NpsContext inCtxt,String id,String title,Topic top,User creator)
    {
        super(inCtxt,id,title,top);
        this.creator = creator.GetUID();
        this.creator_cn = creator.GetName();
        this.score = top.GetScore();
        this.bNew = false;
    }

    public NormalArticle(NpsContext inCtxt,String title,Topic top,User creator)  throws NpsException
    {
        super(inCtxt,null,title,top);
        id = GenerateArticleID();
        this.creator = creator.GetUID();
        this.creator_cn = creator.GetName();
        this.score = top.GetScore();
        this.bNew = true;
    }
    
    public NormalArticle(NpsContext inCtxt,Topic top,ResultSet rs)  throws Exception
    {
        super(inCtxt,rs.getString("id"),rs.getString("title"),top);
        creator = rs.getString("creator");
        creator_cn = rs.getString("creator_name");
        score = rs.getFloat("score");
        subtitle = rs.getString("subtitle");
        abtitle = rs.getString("abtitle");
        keyword = rs.getString("keyword");
        author = rs.getString("author");
        important = rs.getInt("important");
        source = rs.getString("source");
        validdays = rs.getInt("validdays");
        createdate = rs.getTimestamp("createdate");
        publishdate = rs.getTimestamp("publishdate");
        state = rs.getInt("state");
        source_id = rs.getString("srcid");
        content_abstract = rs.getString("abstract");
        url = rs.getString("url");
        approver = rs.getString("approver");
        approver_cn = rs.getString("approver_name");
        current_template_no = rs.getString("currenttemplate");
        pic_url = rs.getString("pic_url");

        prd_name = rs.getString("prd_name");
        prd_code = rs.getString("prd_code");
        prd_newlevel = rs.getInt("prd_newlevel");
        prd_marketprice = rs.getDouble("prd_marketprice");
        prd_saleprice = rs.getDouble("prd_saleprice");
        prd_saleend = rs.getDate("prd_saleend");
        prd_localprice = rs.getDouble("prd_localprice");
        prd_point = rs.getInt("prd_point");
        prd_brandid = rs.getString("prd_brandid");
        prd_brandname = rs.getString("prd_brandname");
        prd_unitid = rs.getString("prd_unitid");
        prd_unitname = rs.getString("prd_unitname");
        prd_spec = rs.getString("prd_spec");
        prd_origincountryid = rs.getString("prd_origincountryid");
        prd_origincountryname = rs.getString("prd_origincountryname");
        prd_originprovinceid = rs.getString("prd_originprovinceid");
        prd_originprovincename = rs.getString("prd_originprovincename");
        prd_parameter = rs.getString("prd_parameter");
        prd_shipfee = rs.getDouble("prd_shipfee");
        
        prd_season = rs.getInt("prd_season");
        prd_nutrition = rs.getInt("prd_nutrition");
        prd_beauty = rs.getInt("prd_beauty");
        prd_reduce = rs.getInt("prd_reduce");
        prd_import = rs.getInt("prd_import");
        prd_jit = rs.getInt("prd_jit");
        
        rowno = rs.getRow();
        bNew = false;

        //加载扩展字段
        LoadCustomFields(rs);
    }

    //从article表中加载数据
    public static NormalArticle GetArticle(NpsContext ctxt,String id) throws NpsException
    {
        NormalArticle art = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try
        {
            String sql = "select * from article where id=?";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,id);
            rs = pstmt.executeQuery();

            if(rs.next())
            {
                String site_id = rs.getString("siteid");
                String top_id = rs.getString("topic");
                Topic top = ctxt.GetSite(site_id).GetTopicTree().GetTopic(top_id);
                if(top==null)  throw new NpsException("topic id:"+top_id, ErrorHelper.SYS_NOTOPIC);

                art = new NormalArticle(ctxt,top,rs);

                try{rs.close();}catch(Exception e){}
                try{pstmt.close();}catch(Exception e){}
                rs = null;
                pstmt = null;

                //2010.6.10 jialin
                //为了加快加载速度，附件和从栏目在需要的时候加载
                //加载从栏目信息
                //art.LoadSlaveTopics();
                
                //加载附件信息
                //art.LoadAttaches();

                //加载上一篇、下一篇文章信息
                //art.LoadPrevAndNext();
            }
        }
        catch(Exception e)
        {
            art = null;
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            if(rs!=null) try{rs.close();}catch(Exception e){}
            if(pstmt!=null)try{pstmt.close();}catch(Exception e){}
        }
        return art;
    }

    //从article表中加载数据
    public static List<NormalArticle> GetArticlesBySourceId(NpsContext ctxt,Site site,Topic topic,String source_id) throws NpsException
    {
        List<NormalArticle> arts = new ArrayList<NormalArticle>();
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try
        {
            String sql = "select * from article where srcid=?";
            if(topic!=null)
                sql += " and siteid=? and topic=?";
            else if(site!=null)
                sql += " and siteid=?";

            pstmt = ctxt.GetConnection().prepareStatement(sql);
            int i=1;
            pstmt.setString(i++,source_id);
            if(topic!=null)
            {
                pstmt.setString(i++,topic.GetSiteId());
                pstmt.setString(i++,topic.GetId());
            }
            else if(site!=null)
            {
                pstmt.setString(i++,site.GetId());
            }
            
            rs = pstmt.executeQuery();

            while(rs.next())
            {
                Topic top = topic;
                if(topic==null)
                {
                    String site_id = rs.getString("siteid");
                    String top_id = rs.getString("topic");
                    top = ctxt.GetSite(site_id).GetTopicTree().GetTopic(top_id);
                    if(top==null)  throw new NpsException("top id:"+top_id, ErrorHelper.SYS_NOTOPIC);
                }
                
                NormalArticle art = new NormalArticle(ctxt,top,rs);

                try{rs.close();}catch(Exception e){}
                try{pstmt.close();}catch(Exception e){}
                rs = null;
                pstmt = null;

                //2010.6.10 jialin
                //为了加快加载速度，附件和从栏目在需要的时候加载                
                //加载从栏目信息
                //art.LoadSlaveTopics();
                
                //加载附件信息
                //art.LoadAttaches();

                //加载上一篇、下一篇文章信息
                //art.LoadPrevAndNext();

                arts.add(art);
            }
        }
        catch(Exception e)
        {
            arts = null;
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            if(rs!=null) try{rs.close();}catch(Exception e){}
            if(pstmt!=null)try{pstmt.close();}catch(Exception e){}
        }
        
        return arts;
    }

    //从数据库中加载附件
    protected void LoadAttaches() throws NpsException
    {
        //清空
        if(attaches!=null) attaches.clear();
        if(attaches_ids!=null) attaches_ids.clear();

        if(attaches == null) attaches = Collections.synchronizedList(new ArrayList(10));
        if(attaches_ids == null ) attaches_ids = new Hashtable();
        
        //重新加载
        PreparedStatement pstmt_atts = null;
        ResultSet rs_atts = null;
        try
        {
            String sql = "select b.*,a.idx from attach a,resources b Where b.id=a.resid and a.artid=? order by a.idx";
            pstmt_atts = ctxt.GetConnection().prepareStatement(sql);
            pstmt_atts.setString(1,id);
            rs_atts = pstmt_atts.executeQuery();
            int row_no = 1;
            while(rs_atts.next())
            {
                Resource res = new Resource(ctxt,rs_atts);
                Attach att = new Attach(ctxt,this,res);
                att.SetIndex(rs_atts.getInt("idx"));
                att.SetRowno(row_no++);

                attaches.add(att);
                attaches_ids.put(att.GetId(),att);
            }
        }
        catch(Exception e)
        {
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            if(rs_atts!=null) try{rs_atts.close();}catch(Exception e){}
            if(pstmt_atts!=null)try{pstmt_atts.close();}catch(Exception e){}
        }
    }

    //加载自定义字段扩展
    protected void LoadCustomFields(ResultSet rs) throws java.sql.SQLException
    {
        if(custom_fields==null)
        {
            custom_fields = new Hashtable();
        }
        else
        {
            custom_fields.clear();
        }

        java.sql.ResultSetMetaData rsmd = rs.getMetaData();
        for(int i=1 ;i<=rsmd.getColumnCount();i++)
        {
            String col_name = rsmd.getColumnName(i);
            col_name = col_name.toUpperCase();
            int col_type = rsmd.getColumnType(i);

            if(IsReservedField(col_name)) continue;

            if(col_type==java.sql.Types.CLOB || col_type==java.sql.Types.BLOB || col_type==java.sql.Types.JAVA_OBJECT
              || col_type==java.sql.Types.LONGVARBINARY || col_type==java.sql.Types.VARBINARY
              || col_type==java.sql.Types.STRUCT || col_type==java.sql.Types.REF
              || col_type==java.sql.Types.OTHER || col_type==java.sql.Types.DATALINK
              || col_type==java.sql.Types.DISTINCT || col_type==java.sql.Types.LONGVARCHAR)
            {
                DefaultLog.info(col_name + " not supported,skipped...");
                continue;
            }

            Object col_obj = rs.getObject(col_name);
            custom_fields.put(col_name,col_obj==null?"":col_obj.toString());
        }
    }

    protected void LoadPrevAndNext() throws NpsException
    {
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try
        {
            SetPrev(null,null,null,null);
            SetNext(null,null,null,null);

            String sql = "select * from (select id,lag(id,1) over (order by publishdate desc) next_id,lead(id,1) over (order by publishdate desc) prev_id from article  where siteid=? and topic=? and state>=2) a where id=?";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,topic.GetSiteId());
            pstmt.setString(2,topic.GetId());
            pstmt.setString(3,id);
            rs = pstmt.executeQuery();
            if(!rs.next()) return;

            String previd = rs.getString("prev_id");
            String nextid = rs.getString("next_id");

            try{rs.close();}catch(Exception e){}
            try{pstmt.close();}catch(Exception e){}
            rs = null;
            pstmt = null;

            //Prev Article
            if(previd!=null)
            {
                sql = "select id,title,createdate,url,url_gen from article where id=?";
                pstmt = ctxt.GetConnection().prepareStatement(sql);
                pstmt.setString(1,previd);
                rs = pstmt.executeQuery();

                if(rs.next())
                {
                    String url = rs.getString("url_gen");
                    if(url!=null)
                    {
                        SetPrev(rs.getString("id"),topic,rs.getString("title"),url);
                    }
                    else
                    {
                        //外链优先
                        url = rs.getString("url");
                        if(url!=null)
                        {
                            SetPrev(rs.getString("id"),topic,rs.getString("title"),url);
                        }
                        else
                        {
                            //根据URL规则计算
                            url = topic.GetURL()
                                + Utils.FormateDate(rs.getDate("createdate"),"yyyy/MM/dd/")
                                + rs.getString("id") + suffix;

                            url = Utils.FixURL(url);

                            SetPrev(rs.getString("id"),topic,rs.getString("title"),url);
                        }
                    }
                }

                if(rs!=null) try{rs.close();}catch(Exception e){}
                if(pstmt!=null)try{pstmt.close();}catch(Exception e){}
                rs = null;
                pstmt = null;
            }

            //Next Article
            if(nextid!=null)
            {
                sql = "select id,title,createdate,url,url_gen from article where id=?";
                pstmt = ctxt.GetConnection().prepareStatement(sql);
                pstmt.setString(1,nextid);
                rs = pstmt.executeQuery();

                if(rs.next())
                {
                    String url = rs.getString("url_gen");
                    if(url!=null)
                    {
                        SetNext(rs.getString("id"),topic,rs.getString("title"),url);
                    }
                    else
                    {
                        //外链优先
                        url = rs.getString("url");
                        if(url!=null)
                        {
                            SetNext(rs.getString("id"),topic,rs.getString("title"),url);
                        }
                        else
                        {
                            //根据URL规则计算
                            url = topic.GetURL()
                                + Utils.FormateDate(rs.getDate("createdate"),"yyyy/MM/dd/")
                                + rs.getString("id") + suffix;

                            url = Utils.FixURL(url);

                            SetNext(rs.getString("id"),topic,rs.getString("title"),url);
                        }
                    }
                }

                if(rs!=null) try{rs.close();}catch(Exception e){}
                if(pstmt!=null)try{pstmt.close();}catch(Exception e){}
                rs = null;
                pstmt = null;
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
    }

    public NormalArticle GetPrevArticle() throws NpsException
    {
        if(!HasPrev()) return null;
        if(prev_art!=null) return (NormalArticle)prev_art;

        prev_art = GetArticle(ctxt,prev_id);
        return (NormalArticle)prev_art;
    }

    public NormalArticle GetNextArticle() throws NpsException
    {
        if(!HasNext()) return null;
        if(next_art!=null) return (NormalArticle)next_art;

        next_art = GetArticle(ctxt,next_id);
        return (NormalArticle)next_art;
    }

   //读取正文内容
    public void GetContent(Writer writer)  throws NpsException
    {
        Reader r = null;

        try
        {
            r = GetClob("content");
            int b;
            while ((b = r.read()) != -1)
            {
                writer.write(b);
            }
        }
        catch(Exception e)
        {
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            if(r!=null) try{r.close();}catch(Exception e){}
        }
    }
    
    //变更状态
    //  将同步更新数据库状态
    public void ChangeState(int st) throws NpsException
    {
        //ARTICLE_SUBMIT
        //ARTICLE_CHECK
        //ARTICLE_PUBLISH
        if(st==ARTICLE_PUBLISH)
        {
            ChangeStatePublished();
            return;
        }

        switch(st)
        {
            case ARTICLE_SUBMIT:
                FireInsertEvent();
                break;
        }
        
        PreparedStatement pstmt = null;
        try
        {
          //审核通过或发布状态，设置审批人信息
           if(st==ARTICLE_CHECK || st==ARTICLE_PUBLISH)
           {
               String sql = "update article set state=?,approver=?,approver_name=?,url_gen=null,last_modify=?,last_modify_name=?,last_modified=? where id=?";
               pstmt = ctxt.GetConnection().prepareStatement(sql);
               pstmt.setInt(1,st);
               pstmt.setString(2,approver);
               pstmt.setString(3,approver_cn);
               pstmt.setString(4,ctxt.GetUser().GetUID());
               pstmt.setString(5,ctxt.GetUser().GetName());
               pstmt.setTimestamp(6,new java.sql.Timestamp(new Date().getTime()));
               pstmt.setString(7,id);
               pstmt.executeUpdate();
           }
           else
           {
               String sql = "update article set state=?,url_gen=null,last_modify=?,last_modify_name=?,last_modified=? where id=?";
               pstmt = ctxt.GetConnection().prepareStatement(sql);
               pstmt.setInt(1,st);
               pstmt.setString(2,ctxt.GetUser().GetUID());
               pstmt.setString(3,ctxt.GetUser().GetName());
               pstmt.setTimestamp(4,new java.sql.Timestamp(new Date().getTime()));
               pstmt.setString(5,id);
               pstmt.executeUpdate();
           }

           //已发布状态，撤销发布的 
           if(state==ARTICLE_PUBLISH && st<ARTICLE_PUBLISH)
           {
               //删除所有分页文件，注意，附件已经在外面处理
               DeletePageFiles();
           }

           state = st;
        }
        catch(Exception e)
        {
           nps.util.DefaultLog.error(e);
        }
        finally
        {
            if(pstmt!=null)try{pstmt.close();}catch(Exception e){}
        }
    }

    //2008.05.31 贾林
    //发布后状态设置
    private void ChangeStatePublished() throws NpsException
    {
        PreparedStatement pstmt = null;
        try
        {
           String sql = "update article set state=?,url_gen=?,publishdate=?,last_modify=?,last_modify_name=?,last_modified=? where id=?";

           pstmt = ctxt.GetConnection().prepareStatement(sql);
           pstmt.setInt(1,ARTICLE_PUBLISH);
           pstmt.setString(2,GetURL());
           pstmt.setTimestamp(3,new java.sql.Timestamp(publishdate.getTime()));
           pstmt.setString(4,ctxt.GetUser().GetUID());
           pstmt.setString(5,ctxt.GetUser().GetName());
           pstmt.setTimestamp(6,new java.sql.Timestamp(new Date().getTime()));
           pstmt.setString(7,id);
           pstmt.executeUpdate();

           state = ARTICLE_PUBLISH;

           //加入索引
           try
           {
               Index();
           }
           catch(Exception e)
           {
               nps.util.DefaultLog.error_noexception(e);
           }

            //发布事件通知
            FirePublishEvent();
        }
        catch(Exception e)
        {
           nps.util.DefaultLog.error(e);
        }
        finally
        {
            if(pstmt!=null)try{pstmt.close();}catch(Exception e){}
        }
    }

    public boolean HasField(String fieldName)
    {
        if(fieldName==null || fieldName.length()==0) return false;
        String key = fieldName.trim();
        if(key.length()==0) return false;

        key = key.toUpperCase();
        if(key.equalsIgnoreCase("art_id")) return true;//文章唯一标识
        if(key.equalsIgnoreCase("art_title")) return true; //标题
        if(key.equalsIgnoreCase("art_subtitle")) return true;//副标题
        if(key.equalsIgnoreCase("art_abtitle")) return true;//短标题
        if(key.equalsIgnoreCase("art_important")) return true;  //重要度
        if(key.equalsIgnoreCase("art_tag")) return true;//关键字
        if(key.equalsIgnoreCase("art_keyword")) return true;//关键字
        if(key.equalsIgnoreCase("art_author")) return true;//作者
        if(key.equalsIgnoreCase("art_source")) return true;//来源
        if(key.equalsIgnoreCase("art_validdays")) return true;//有效天数 0长期有效
        if(key.equalsIgnoreCase("art_creator")) return true;//创建人ID
        if(key.equalsIgnoreCase("art_creatorcn")) return true;//创建人简要名称
        if(key.equalsIgnoreCase("art_creatorfn")) return true;//创建人全名
        if(key.equalsIgnoreCase("art_approver")) return true;//审稿人ID
        if(key.equalsIgnoreCase("art_approvercn")) return true;//审稿人简要名称
        if(key.equalsIgnoreCase("art_createdate")) return true; //创建时间
        if(key.equalsIgnoreCase("art_publishdate")) return true;//发布时间
        if(key.equalsIgnoreCase("art_url"))  return true; //发布路径

        if(key.equalsIgnoreCase("prd_name")) return true;
        if(key.equalsIgnoreCase("prd_code")) return true;
        if(key.equalsIgnoreCase("prd_newlevel"))  return true;
        if(key.equalsIgnoreCase("prd_marketprice"))  return true;
        if(key.equalsIgnoreCase("prd_saleprice"))  return true;
        if(key.equalsIgnoreCase("prd_saleend"))  return true;
        if(key.equalsIgnoreCase("prd_localprice"))  return true;
        if(key.equalsIgnoreCase("prd_point"))  return true;
        if(key.equalsIgnoreCase("prd_brandid"))  return true;
        if(key.equalsIgnoreCase("prd_brandname"))  return true;
        if(key.equalsIgnoreCase("prd_unitid"))  return true;
        if(key.equalsIgnoreCase("prd_unitname"))  return true;
        if(key.equalsIgnoreCase("prd_spec"))  return true;
        if(key.equalsIgnoreCase("prd_origincountryid"))  return true;
        if(key.equalsIgnoreCase("prd_origincountryname"))  return true;
        if(key.equalsIgnoreCase("prd_originprovinceid"))  return true;
        if(key.equalsIgnoreCase("prd_originprovincename")) return true;
        if(key.equalsIgnoreCase("prd_parameter")) return true;
        if(key.equalsIgnoreCase("prd_shipfee"))  return true;

        if(key.equalsIgnoreCase("prd_season"))  return true;
        if(key.equalsIgnoreCase("prd_nutrition"))  return true;
        if(key.equalsIgnoreCase("prd_beauty"))  return true;
        if(key.equalsIgnoreCase("prd_reduce"))  return true;
        if(key.equalsIgnoreCase("prd_import"))  return true;
        if(key.equalsIgnoreCase("prd_jit"))  return true;
        
        
        if(key.equalsIgnoreCase("art_content"))  return true; //文章内容
        if(key.equalsIgnoreCase("art_abstract")) return true; //文章摘要
        if(key.equalsIgnoreCase("art_imgurl")) return true; //导读图片
        if(key.equalsIgnoreCase("art_topic")) return true; //栏目
        if(key.equalsIgnoreCase("art_site")) return true; //站点
        if(key.equalsIgnoreCase("art_prev")) return true; //上一篇
        if(key.equalsIgnoreCase("art_next")) return true; //下一篇
        if(key.equalsIgnoreCase("art_previd")) return true; //上一篇ID号
        if(key.equalsIgnoreCase("art_prevtopic")) return true; //上一篇的栏目
        if(key.equalsIgnoreCase("art_prevtitle")) return true; //上一篇标题
        if(key.equalsIgnoreCase("art_prevurl")) return true; //上一篇URL
        if(key.equalsIgnoreCase("art_nextid")) return true; //下一篇ID
        if(key.equalsIgnoreCase("art_nexttopic")) return true; //下一篇栏目
        if(key.equalsIgnoreCase("art_nexttitle")) return true; //下一篇标题
        if(key.equalsIgnoreCase("art_nexturl")) return true; //下一篇URL
        
        if(key.equalsIgnoreCase("rowno")) return true;
        if(custom_fields!=null&& custom_fields.containsKey(key)) return true; //自定义变量
        
        return false;
    }
    
    //IPublishable要求的方法
    public Field GetField(String fieldName) throws NpsException
    {
        if(fieldName==null || fieldName.length()==0) return Field.Null;

        String key = fieldName.trim();
        if(key.length()==0) return Field.Null;

        key = key.toUpperCase();

        //文章变量
        if(key.equalsIgnoreCase("art_id")) return new Field(id);//文章唯一标识
        if(key.equalsIgnoreCase("art_title")) return new Field(title); //标题
        if(key.equalsIgnoreCase("art_subtitle")) return new Field(subtitle);//副标题
        if(key.equalsIgnoreCase("art_abtitle")) return new Field(abtitle);//短标题
        if(key.equalsIgnoreCase("art_important")) return new Field(new Integer(important));  //重要度
        if(key.equalsIgnoreCase("art_tag")) return new Field(keyword);//关键字
        if(key.equalsIgnoreCase("art_keyword")) return new Field(keyword);//关键字
        if(key.equalsIgnoreCase("art_author")) return new Field(author);//作者
        if(key.equalsIgnoreCase("art_source")) return new Field(source);//来源
        if(key.equalsIgnoreCase("art_validdays")) return new Field(new Integer(validdays));//有效天数 0长期有效
        if(key.equalsIgnoreCase("art_creator")) return new Field(GetCreatorID());//创建人ID
        if(key.equalsIgnoreCase("art_creatorcn")) return new Field(GetCreatorCN());//创建人简要名称
        if(key.equalsIgnoreCase("art_creatorfn")) return new Field(GetCreatorFN());//创建人全名
        if(key.equalsIgnoreCase("art_createdate")) return new Field(createdate); //创建时间
        if(key.equalsIgnoreCase("art_approver")) return new Field(approver); //审稿人ID
        if(key.equalsIgnoreCase("art_approvercn")) return new Field(approver_cn); //审稿人名称
        if(key.equalsIgnoreCase("art_publishdate")) return new Field(publishdate);//发布时间
        if(key.equalsIgnoreCase("art_url"))  return new Field(GetURL()); //发布路径
        
        
        if(key.equalsIgnoreCase("prd_name"))  return new Field(getPrdName());
        if(key.equalsIgnoreCase("prd_code"))  return new Field(getPrdCode());
        if(key.equalsIgnoreCase("prd_newlevel"))  return new Field(getPrdNewlevel());
        if(key.equalsIgnoreCase("prd_marketprice"))  return new Field(getPrdMarketprice());
        if(key.equalsIgnoreCase("prd_saleprice"))  return new Field(getPrdSaleprice());
        if(key.equalsIgnoreCase("prd_saleend"))  return new Field(getPrdSaleend());
        if(key.equalsIgnoreCase("art_prd_localprice"))  return new Field(getPrdLocalprice());
        if(key.equalsIgnoreCase("prd_localprice"))  return new Field(getPrdLocalprice());
        if(key.equalsIgnoreCase("localprice"))  return new Field(getPrdLocalprice());
        if(key.equalsIgnoreCase("prd_point"))  return new Field(getPrdPoint());
        if(key.equalsIgnoreCase("prd_brandid"))  return new Field(getPrdBrandid());
        if(key.equalsIgnoreCase("prd_brandname"))  return new Field(getPrdBrandname());
        if(key.equalsIgnoreCase("prd_unitid"))  return new Field(getPrdUnitid());
        if(key.equalsIgnoreCase("prd_unitname"))  return new Field(getPrdUnitname());
        if(key.equalsIgnoreCase("prd_spec"))  return new Field(getPrdSpec());
        if(key.equalsIgnoreCase("prd_origincountryid"))  return new Field(getPrdOrigincountryid());
        if(key.equalsIgnoreCase("prd_origincountryname"))  return new Field(getPrdOrigincountryname());
        if(key.equalsIgnoreCase("prd_originprovinceid"))  return new Field(getPrdOriginprovinceid());
        if(key.equalsIgnoreCase("prd_originprovincename"))  return new Field(getPrdOriginprovincename());
        if(key.equalsIgnoreCase("prd_parameter"))  return new Field(getPrdParameter());
        if(key.equalsIgnoreCase("prd_shipfee"))  return new Field(getPrdShipfee());

        if(key.equalsIgnoreCase("prd_import"))  return new Field(getPrdImport());
        if(key.equalsIgnoreCase("prd_jit"))  return new Field(getPrdJit());
        if(key.equalsIgnoreCase("prd_reduce"))  return new Field(getPrdReduce());
        if(key.equalsIgnoreCase("prd_beauty"))  return new Field(getPrdBeauty());
        if(key.equalsIgnoreCase("prd_nutrition"))  return new Field(getPrdNutrition());
        if(key.equalsIgnoreCase("prd_season"))  return new Field(getPrdSeason());
           
        
        
        if(key.equalsIgnoreCase("art_imgurl")) return new Field(pic_url); //导读图片
        if(key.equalsIgnoreCase("art_content"))  return new Field(GetClob("content")); //文章内容
        //文章摘要,如果没有设置文章摘要，默认自动取正文前90个字
        if(key.equalsIgnoreCase("art_abstract"))
        {
            if(content_abstract!=null)
                return new Field(content_abstract);
            else
                return new Field(GetField("art_content",Config.DEFAULT_ABSTRACT_WORDS,"..."));
        }

        //2010.03.14 增加topic、site对象
        if(key.equalsIgnoreCase("art_topic")) return new Field(topic);
        if(key.equalsIgnoreCase("art_site")) return new Field(site);

        //2010.06.10 增加上一篇、下一篇
        if(key.equalsIgnoreCase("art_prev")) return new Field(GetPrevArticle());
        if(key.equalsIgnoreCase("art_next")) return new Field(GetNextArticle());
        if(key.equalsIgnoreCase("art_previd")) return new Field(GetPrevId());
        if(key.equalsIgnoreCase("art_prevtopic")) return new Field(GetPrevTopic());
        if(key.equalsIgnoreCase("art_prevtitle")) return new Field(GetPrevTitle());
        if(key.equalsIgnoreCase("art_prevurl")) return new Field(GetPrevURL());
        if(key.equalsIgnoreCase("art_nextid")) return new Field(GetNextId());
        if(key.equalsIgnoreCase("art_nexttopic")) return new Field(GetNextTopic());
        if(key.equalsIgnoreCase("art_nexttitle")) return new Field(GetNextTitle());
        if(key.equalsIgnoreCase("art_nexturl")) return new Field(GetNextURL());

        if(key.equalsIgnoreCase("rowno")) return new Field(rowno);

        //2010.03.18 新增article表扩展
        if(custom_fields!=null&& custom_fields.containsKey(key)) return new Field(custom_fields.get(key));

        //栏目变量
        if(key.startsWith("TOP_") && topic.HasField(key))   return topic.GetField(key);

        //站点变量
        if(key.startsWith("SITE_") && topic.GetSite().HasField(key))  return topic.GetSite().GetField(key);

        //单位变量
        if((key.startsWith("UNIT_") || key.startsWith("ORG_")) && topic.GetSite().GetUnit().HasField(key))  return topic.GetSite().GetUnit().GetField(key);        

        //栏目自定义变量
        if(topic.HasField(key)) return topic.GetField(key);

        //站点自定义变量
        if(topic.GetSite().HasField(key))  return topic.GetSite().GetField(key);

        //全局变量
        if(ctxt.HasField(key)) return ctxt.GetField(key);

        return Field.Null;
    }

    //附件相关方法
    //添加Resource对象，如果Resource已存在，则变更索引
    public Attach AddAttach(Resource res, int index) throws NpsException
    {
        Attach att = GetAttachById(res.GetId());
        if(att!=null)
        {
            att.SetIndex(index);
            return att;
        }

        //如果没有，就新增一个
        att = new Attach(ctxt,this,res);
        att.SetIndex(index);

        AddAttach(att);

        //复制物理文件
        att.CopyAttachFiles();

        return att;
    }

    //添加Resource对象
    public Attach AddAttach(String res_id,int index) throws NpsException
    {
        return AddAttach(new Resource(ctxt,res_id),index);
    }

    public Attach AddAttach(Resource res) throws NpsException
    {
        int index = 1;

        List<Attach> attaches = GetAttach();
        if(attaches!=null && !attaches.isEmpty()) index = attaches.size()+1;

        return AddAttach(res,index);
    }

    //根据附件ID删除附件
    @Override public void DeleteAttach(String res_id)  throws NpsException
    {
        Attach att = GetAttachById(res_id);
        if(att==null) return;

        //1.从数据库中删除
        PreparedStatement pstmt = null;
        try
        {
            String sql = "delete from attach where resid=?";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,res_id);
            pstmt.executeUpdate();
        }
        catch(Exception e)
        {
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            if(pstmt!=null) try{pstmt.close();}catch(Exception e1){}
        }

        //删除物理附件
        super.DeleteAttach(res_id);
    }

    //自定义字段管理
    //是否是保留字段
    public boolean IsReservedField(String name)
    {
        //以下是articles表字段
        if("id".equalsIgnoreCase(name)) return true;
        if("title".equalsIgnoreCase(name)) return true;
        if("subtitle".equalsIgnoreCase(name)) return true;
        if("abtitle".equalsIgnoreCase(name)) return true;
        if("siteid".equalsIgnoreCase(name)) return true;
        if("topic".equalsIgnoreCase(name)) return true;
        if("keyword".equalsIgnoreCase(name)) return true;
        if("author".equalsIgnoreCase(name)) return true;
        if("important".equalsIgnoreCase(name)) return true;
        if("source".equalsIgnoreCase(name)) return true;
        if("validdays".equalsIgnoreCase(name)) return true;
        if("abstract".equalsIgnoreCase(name)) return true;
        if("content".equalsIgnoreCase(name)) return true;
        if("createdate".equalsIgnoreCase(name)) return true;
        if("publishdate".equalsIgnoreCase(name)) return true;
        if("creator".equalsIgnoreCase(name)) return true;
        if("creator_name".equalsIgnoreCase(name)) return true;
        if("approver".equalsIgnoreCase(name)) return true;
        if("approver_name".equalsIgnoreCase(name)) return true;
        if("state".equalsIgnoreCase(name)) return true;
        if("score".equalsIgnoreCase(name)) return true;
        if("srcid".equalsIgnoreCase(name)) return true;
        if("uname".equalsIgnoreCase(name)) return true;
        if("deptname".equalsIgnoreCase(name)) return true;
        if("unitname".equalsIgnoreCase(name)) return true;
        if("url".equalsIgnoreCase(name)) return true;
        if("currenttemplate".equalsIgnoreCase(name)) return true;
        if("url_gen".equalsIgnoreCase(name)) return true;
        if("pic_url".equalsIgnoreCase(name)) return true;

        if("prd_name".equalsIgnoreCase(name)) return true;
        if("prd_code".equalsIgnoreCase(name)) return true;
        if("prd_newlevel".equalsIgnoreCase(name)) return true;
        if("prd_marketprice".equalsIgnoreCase(name)) return true;
        if("prd_saleprice".equalsIgnoreCase(name)) return true;
        if("prd_saleend".equalsIgnoreCase(name)) return true;
        if("prd_localprice".equalsIgnoreCase(name)) return true;
        if("prd_point".equalsIgnoreCase(name)) return true;
        if("prd_brandid".equalsIgnoreCase(name)) return true;
        if("prd_brandname".equalsIgnoreCase(name)) return true;
        if("prd_unitid".equalsIgnoreCase(name)) return true;
        if("prd_unitname".equalsIgnoreCase(name)) return true;
        if("prd_spec".equalsIgnoreCase(name)) return true;
        if("prd_origincountryid".equalsIgnoreCase(name)) return true;
        if("prd_origincountryname".equalsIgnoreCase(name)) return true;
        if("prd_originprovinceid".equalsIgnoreCase(name)) return true;
        if("prd_originprovincename".equalsIgnoreCase(name)) return true;
        if("prd_parameter".equalsIgnoreCase(name)) return true;
        if("prd_shipfee".equalsIgnoreCase(name)) return true;
        
        if("prd_nutrition".equalsIgnoreCase(name)) return true;
        if("prd_season".equalsIgnoreCase(name)) return true;
        if("prd_beauty".equalsIgnoreCase(name)) return true;
        if("prd_reduce".equalsIgnoreCase(name)) return true;
        if("prd_import".equalsIgnoreCase(name)) return true;
        if("prd_jit".equalsIgnoreCase(name)) return true;
        
        
        
        
        
        //2011.01.07 jialn  新增最后修改人、修改时间
        if("last_modify".equalsIgnoreCase(name)) return true;
        if("last_modify_name".equalsIgnoreCase(name)) return true;
        if("last_modified".equalsIgnoreCase(name)) return true;
        
        //以下是附件和资源内置字段
        if("att_idx".equalsIgnoreCase(name)) return true;
        if("res_id".equalsIgnoreCase(name)) return true;
        if("res_caption".equalsIgnoreCase(name)) return true;
        if("res_suffix".equalsIgnoreCase(name)) return true;
        if("res_type".equalsIgnoreCase(name)) return true;
        if("res_scope".equalsIgnoreCase(name)) return true;
        if("res_siteid".equalsIgnoreCase(name)) return true;
        if("res_creator".equalsIgnoreCase(name)) return true;
        if("res_createdate".equalsIgnoreCase(name)) return true;
        if("res_creatorcn".equalsIgnoreCase(name)) return true;
        if("res_unitid".equalsIgnoreCase(name)) return true;

        return false;
    }

    public Enumeration GetCustomFields()
    {
        if(custom_fields==null || custom_fields.isEmpty()) return null;
        return custom_fields.keys();
    }

    public String GetCustomField(String name)
    {
        if(name==null) return null;
        if(custom_fields==null || custom_fields.isEmpty()) return null;
        
        return custom_fields.get(name.toUpperCase());
    }

    public void AddCustomField(String name,String value)
    {
        if(name==null) return;

        String key = name.toUpperCase();
        key = key.trim();
        if(key.length()==0) return;

        if(IsReservedField(name)) return;

        if(custom_fields==null) custom_fields = new Hashtable();
        if(custom_fields.containsKey(key)) custom_fields.remove(key);

        custom_fields.put(key, Utils.Null2Empty(value));
    }

     public void SetCustomField(String name,String value)
     {
         AddCustomField(name,value);
     }

    //保存数据
    public void Save() throws NpsException
    {     
        //保存基本信息
        if(bNew)
        {
            SaveBasicInfo();
        }
        else
        {
            UpdateBasicInfo();
        }
        updateOrigin();
        //保存从栏目
        SaveSlaveTopics();

        //保存附件条目
        SaveAttach();
    }

    //保存基本信息到数据库
    private void SaveBasicInfo() throws NpsException
    {
        java.sql.PreparedStatement pstmt = null;
        String sql = null;

        try
        {
            sql = "insert into article("
                + " id,title,subtitle,siteid,topic,keyword,author,important,source,validdays,"
                + " creator,creator_name,createdate,score,content,state,srcid,abstract,url,"
                  + " approver,approver_name,abtitle,currenttemplate,pic_url,last_modify,last_modify_name,last_modified";
            if(custom_fields!=null && !custom_fields.isEmpty())
            {
                Enumeration<String> keys = custom_fields.keys();
                while(keys.hasMoreElements())
                {
                    String key = keys.nextElement();
                    sql += ","+ key;
                }
            }
            //产品信息
            sql +=",prd_name,prd_code,prd_newlevel,prd_marketprice,prd_saleprice,prd_saleend,prd_localprice,prd_point,prd_brandid,prd_brandname,prd_unitid,prd_unitname" +
                ",prd_spec,prd_origincountryid,prd_origincountryname,prd_originprovinceid,prd_originprovincename,prd_parameter,prd_shipfee" +
                ",prd_season,prd_import,prd_jit,prd_reduce,prd_beauty,prd_nutrition ";
            
            sql += ") values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,empty_clob(),0,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?";
            for(int i=0;custom_fields!=null && i<custom_fields.size();i++)
            {
               sql += ",?";
            }
            //产品信息
            sql +=",?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,? ,?";
            sql += ")";

            int i = 1;
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(i++,id);
            pstmt.setString(i++,title);
            pstmt.setString(i++,subtitle);
            pstmt.setString(i++,topic.GetSiteId());
            pstmt.setString(i++,topic.GetId());
            pstmt.setString(i++,keyword);
            pstmt.setString(i++,author);
            pstmt.setInt(i++,important);
            pstmt.setString(i++,source);
            pstmt.setInt(i++,validdays);
            pstmt.setString(i++,creator);
            pstmt.setString(i++,creator_cn);
            pstmt.setTimestamp(i++,new java.sql.Timestamp(createdate.getTime()));
            pstmt.setFloat(i++,score);
            pstmt.setString(i++,source_id);
            pstmt.setString(i++,content_abstract);
            pstmt.setString(i++,url);
            pstmt.setString(i++,approver);
            pstmt.setString(i++,approver_cn);
            pstmt.setString(i++,abtitle);
            pstmt.setString(i++,current_template_no);
            pstmt.setString(i++,pic_url);
            pstmt.setString(i++,creator);
            pstmt.setString(i++,creator_cn);
            pstmt.setTimestamp(i++,new java.sql.Timestamp(createdate.getTime()));
            if(custom_fields!=null && !custom_fields.isEmpty())
            {
                Enumeration keys = custom_fields.keys();
                while(keys.hasMoreElements())
                {
                    String key = (String)keys.nextElement();
                    pstmt.setString(i++,custom_fields.get(key));
                }
            }
            //产品信息
            pstmt.setString(i++,prd_name);
            pstmt.setString(i++,prd_code);
            pstmt.setInt(i++,prd_newlevel);
            pstmt.setDouble(i++,prd_marketprice);
            pstmt.setDouble(i++,prd_saleprice);
            pstmt.setDate(i++,prd_saleend==null?null:new java.sql.Date( prd_saleend.getTime()));
            pstmt.setDouble(i++,prd_localprice);
            pstmt.setInt(i++,prd_point);
            pstmt.setString(i++,prd_brandid);
            pstmt.setString(i++,prd_brandname);
            pstmt.setString(i++,prd_unitid);
            pstmt.setString(i++,prd_unitname);
            pstmt.setString(i++,prd_spec);
            pstmt.setString(i++,prd_origincountryid);
            pstmt.setString(i++,prd_origincountryname);
            pstmt.setString(i++,prd_originprovinceid);
            pstmt.setString(i++,prd_originprovincename);
            pstmt.setString(i++,prd_parameter);
            pstmt.setDouble(i++,prd_shipfee);

            pstmt.setInt(i++,prd_season);
            pstmt.setInt(i++,prd_import);
            pstmt.setInt(i++,prd_jit);
            pstmt.setInt(i++,prd_reduce);
            pstmt.setInt(i++,prd_beauty);
            pstmt.setInt(i++,prd_nutrition);
            
            pstmt.executeUpdate();
        }
        catch(Exception e)
        {
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            if(pstmt!=null) try{pstmt.close();}catch(Exception e1){}             
        }
    }

    //更新基本信息
    private void UpdateBasicInfo() throws NpsException
    {
        PreparedStatement pstmt = null;
        String sql = null;
        int i = 1;
        try
        {
            sql = "update article "
                + "    set title=?,subtitle=?,abtitle=?,siteid=?,topic=?,keyword=?,author=?,important=?,source=?,validdays=?,score=?,abstract=?,url=?,currenttemplate=?,pic_url=?,"
                  + "        last_modify=?,last_modify_name=?,last_modified=?";
            if(custom_fields!=null && !custom_fields.isEmpty())
            {
                Enumeration<String> keys = custom_fields.keys();
                while(keys.hasMoreElements())
                {
                    String key = keys.nextElement();
                    sql += ","+ key+"=?";
                }
            }
            //产品信息
            sql += ",prd_name = ?,prd_code = ?,prd_newlevel = ?,prd_marketprice = ?,prd_saleprice = ?,prd_saleend = ?,prd_localprice = ?,prd_point = ?,prd_brandid = ?,prd_brandname = ?" +
                ",prd_unitid = ?,prd_unitname = ?,prd_spec = ?,prd_origincountryid = ?,prd_origincountryname = ?,prd_originprovinceid = ?" +
                ",prd_originprovincename = ?,prd_parameter=?,prd_shipfee = ?,prd_season = ?,prd_import = ?,prd_jit = ?,prd_reduce = ?,prd_beauty = ?,prd_nutrition = ? ";
            
            sql += " where id=?";
            pstmt = ctxt.GetConnection().prepareStatement(sql);

            pstmt.setString(i++,title);
            pstmt.setString(i++,subtitle);
            pstmt.setString(i++,abtitle);            
            pstmt.setString(i++,topic.GetSiteId());
            pstmt.setString(i++,topic.GetId());
            pstmt.setString(i++,keyword);
            pstmt.setString(i++,author);
            pstmt.setInt(i++,important);
            pstmt.setString(i++,source);
            pstmt.setInt(i++,validdays);
            pstmt.setFloat(i++,score);
            pstmt.setString(i++,content_abstract);
            pstmt.setString(i++,url);
            pstmt.setString(i++,current_template_no);
            pstmt.setString(i++,pic_url);
            pstmt.setString(i++,ctxt.GetUser().GetUID());
            pstmt.setString(i++,ctxt.GetUser().GetName());
            pstmt.setTimestamp(i++,new java.sql.Timestamp(new Date().getTime()));
            if(custom_fields!=null && !custom_fields.isEmpty())
            {
                Enumeration<String> keys = custom_fields.keys();
                while(keys.hasMoreElements())
                {
                    String key = keys.nextElement();
                    pstmt.setString(i++,custom_fields.get(key));
                }
            }
            
          //产品信息
            pstmt.setString(i++,prd_name);
            pstmt.setString(i++,prd_code);
            pstmt.setInt(i++,prd_newlevel);
            pstmt.setDouble(i++,prd_marketprice);
            pstmt.setDouble(i++,prd_saleprice);
            pstmt.setDate(i++,prd_saleend==null?null:new java.sql.Date( prd_saleend.getTime()));
            pstmt.setDouble(i++,prd_localprice);
            pstmt.setInt(i++,prd_point);
            pstmt.setString(i++,prd_brandid);
            pstmt.setString(i++,prd_brandname);
            pstmt.setString(i++,prd_unitid);
            pstmt.setString(i++,prd_unitname);
            pstmt.setString(i++,prd_spec);
            pstmt.setString(i++,prd_origincountryid);
            pstmt.setString(i++,prd_origincountryname);
            pstmt.setString(i++,prd_originprovinceid);
            pstmt.setString(i++,prd_originprovincename);
            pstmt.setString(i++,prd_parameter);
            pstmt.setDouble(i++,prd_shipfee);
            
            pstmt.setInt(i++,prd_season);
            pstmt.setInt(i++,prd_import);
            pstmt.setInt(i++,prd_jit);
            pstmt.setInt(i++,prd_reduce);
            pstmt.setInt(i++,prd_beauty);
            pstmt.setInt(i++,prd_nutrition);
            
            pstmt.setString(i++,id);
            pstmt.executeUpdate();
        }
        catch(Exception e)
        {
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            if(pstmt!=null) try{pstmt.close();}catch(Exception e1){}
        }
    }

    private void UpdateLastModify() throws NpsException
    {
        PreparedStatement pstmt = null;
        String sql = null;

        try
        {
            sql = "update article set last_modify=?,last_modify_name=?,last_modified=? where id=?";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,ctxt.GetUser().GetUID());
            pstmt.setString(2,ctxt.GetUser().GetName());
            pstmt.setTimestamp(3,new java.sql.Timestamp(new Date().getTime()));
            pstmt.setString(4,id);
            pstmt.executeUpdate();
        }
        catch(Exception e)
        {
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            if(pstmt!=null) try{pstmt.close();}catch(Exception e1){}
        }
    }

    //写入正文
    public void UpdateContent(String content) throws NpsException
    {
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Writer writer = null;
        try
        {
            String sql = "select content from article where id=? for update";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1, id);
            rs = pstmt.executeQuery();
            if(!rs.next()) return;

            oracle.sql.CLOB clob = ( oracle.sql.CLOB) rs.getClob(1);
            clob.truncate(0);
            if(content!=null && content.length()>0)
            {
                writer = clob.setCharacterStream(0);
                //2010.07.22 jialin 新增替换功能
                if(site.IsKeywordLinkEnabled())
                {
                    AutoLink link_machine = new AutoLink(topic);
                    link_machine.AddLinksForHTML(content,writer);
                }
                else
                {
                    writer.write(content);
                }
                writer.flush();
            }
            
            //清空当前文件系统缓存数据，要求重新加载
            Clear("content");

            //发布事件通知
            if(!bNew && state>=ARTICLE_SUBMIT && state<=ARTICLE_CHECK)
            {
                FireUpdateEvent();
            }
        }
        catch(Exception e)
        {
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            if(writer!=null) try{writer.close();}catch(Exception e1){}
            if(rs!=null) try{rs.close();}catch(Exception e1){}
            if(pstmt!=null) try{pstmt.close();}catch(Exception e1){}
        }

        UpdateLastModify();
    }

    //写入正文
    public void UpdateContent(InputStreamReader reader) throws NpsException
    {
        if(reader==null) return;

        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Writer writer = null;
        try
        {
            //2008.05.19 bugfix:更新正文内容时仅替换了部分字符串
            String sql = "select content from article where id=? for update";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1, id);
            rs = pstmt.executeQuery();
            if(!rs.next()) return;

            oracle.sql.CLOB clob = ( oracle.sql.CLOB) rs.getClob(1);
            clob.truncate(0);
            writer = clob.setCharacterStream(0);

            //2010.07.22 jialin 新增替换功能
            if(site.IsKeywordLinkEnabled())
            {
                AutoLink link_machine = new AutoLink(topic);
                link_machine.AddLinksForHTML(reader,writer);
            }
            else
            {
                int read = 0;
                char[] buf = new char[1024];
                while ((read = reader.read(buf)) >= 0)
                {
                    writer.write(buf,0,read);
                }
            }

            writer.flush();

            //清空当前文件系统缓存数据，要求重新加载
            Clear("content");

            //发布事件通知
            if(!bNew && state>=ARTICLE_SUBMIT && state<=ARTICLE_CHECK)
            {
                FireUpdateEvent();
            }
        }
        catch(Exception e)
        {
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            if(writer!=null) try{writer.close();}catch(Exception e1){}
            if(rs!=null) try{rs.close();}catch(Exception e1){}
            if(pstmt!=null) try{pstmt.close();}catch(Exception e1){}
        }

        UpdateLastModify();
    }

    //保存附件列表
    private void SaveAttach() throws NpsException
    {
        if(attaches==null || attaches.isEmpty())  return;
        PreparedStatement pstmt_update = null;
        PreparedStatement pstmt_insert = null;
        try
        {
            String sql = "update attach set idx=?,url_gen=? where artid=? and resid=?";
            pstmt_update = ctxt.GetConnection().prepareStatement(sql);
            sql = "insert into attach(artid,resid,idx,url_gen) values(?,?,?,?)";
            pstmt_insert = ctxt.GetConnection().prepareStatement(sql);

            for(Attach att:attaches)
            {
                pstmt_update.setInt(1,att.GetIndex());
                pstmt_update.setString(2,att.GetURL());
                pstmt_update.setString(3,id);
                pstmt_update.setString(4,att.GetID());
                int rows = pstmt_update.executeUpdate();
                if(rows==0)
                {
                    pstmt_insert.setString(1,id);
                    pstmt_insert.setString(2,att.GetId());
                    pstmt_insert.setInt(3,att.GetIndex());
                    pstmt_insert.setString(4,att.GetURL());
                    pstmt_insert.executeUpdate();
                }
            }
        }
        catch(Exception e)
        {
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            try{pstmt_insert.close();}catch(Exception e1){}
            try{pstmt_update.close();}catch(Exception e1){}
        }
    }

    //复制一个
    public NormalArticle Copy() throws NpsException
    {
        return Copy(null);
    }

    //复制到指定栏目，创建人替换成user用户，创建日期为当前时间
    public NormalArticle Copy(Topic t,User user) throws NpsException
    {
        //复制一个新的，产生系列新的ID，状态变为topic指定的文章默认状态
        //默认复制到当前栏目下
        if(t==null) t=topic;

        if(t.IsCustom())
            throw new NpsException(t.GetName()+"/"+t.GetSite().GetName()+"("+t.GetId()+")",
                                   ErrorHelper.SYS_INVALIDTOPIC);

        String new_id = GenerateArticleID();

        NormalArticle new_art = new NormalArticle(ctxt,new_id,title,t,user);
        new_art.subtitle = subtitle;
        new_art.abtitle = abtitle;
        new_art.keyword = keyword;
        new_art.author = author;
        new_art.important = important;
        new_art.source = source;
        new_art.validdays = validdays;
        new_art.score = score;
        new_art.createdate = new Date();
        new_art.source_id = id;
        new_art.content_abstract = content_abstract;
        new_art.url = url;
        new_art.pic_url = pic_url;
        //2010.05.20 jialin 设置当前文章默认模板
        if(t.equals(topic))
        {
            //如果目标栏目与当前文章相同的，则新文章的当前模板和该文章相同
            new_art.current_template_no = current_template_no;
        }
        else
        {
            //否则采用栏目默认模板
            new_art.current_template_no = null;
        }
        new_art.bNew = true;

        //复制扩展属性
        if(custom_fields!=null && !custom_fields.isEmpty())
        {
            new_art.custom_fields = new Hashtable(custom_fields.size());
            new_art.custom_fields.putAll(custom_fields);
        }

        //复制附件
        List<Attach> attaches = GetAttach();
        if(attaches!=null && !attaches.isEmpty())
        {
            for(Attach att:attaches)
            {
                try
                {
                    //创建新的资源对象
                    Attach new_att = new Attach(ctxt,new_art,att.GetResource());
                    new_art.AddAttach(new_att);

                    //复制物理文件
                    new_att.CopyAttachFiles();
                }
                catch(Exception e)
                {
                    nps.util.DefaultLog.error(e);
                }
            }
        }

        return new_art;
    }
    
    //复制到指定栏目，但不改变所有者
    public NormalArticle Copy(Topic t) throws NpsException
    {
        //复制一个新的，产生系列新的ID，状态变为topic指定的文章默认状态
        //默认复制到当前栏目下
        if(t==null) t=topic;

        if(t.IsCustom())
            throw new NpsException(t.GetName()+"/"+t.GetSite().GetName()+"("+t.GetId()+")",
                                   ErrorHelper.SYS_INVALIDTOPIC);

        String new_id = GenerateArticleID();

        NormalArticle new_art = new NormalArticle(ctxt,new_id,title,t,creator);
        new_art.subtitle = subtitle;
        new_art.abtitle = abtitle;
        new_art.keyword = keyword;
        new_art.author = author;
        new_art.important = important;
        new_art.source = source;
        new_art.validdays = validdays;
        new_art.score = score;
        new_art.creator_cn = creator_cn;
        new_art.createdate = createdate;
        new_art.source_id = id;
        new_art.content_abstract = content_abstract;
        new_art.url = url;
        new_art.pic_url = pic_url;
        //产品信息
        new_art.prd_name = prd_name ;
        new_art.prd_code = prd_code ;
        new_art.prd_newlevel = prd_newlevel ;
        new_art.prd_marketprice = prd_marketprice ;
        new_art.prd_saleprice = prd_saleprice ;
        new_art.prd_saleend = prd_saleend ;
        new_art.prd_localprice = prd_localprice ;
        new_art.prd_point = prd_point ;
        new_art.prd_brandid = prd_brandid ;
        new_art.prd_brandname = prd_brandname ;
        new_art.prd_unitid = prd_unitid ;
        new_art.prd_unitname = prd_unitname ;
        new_art.prd_spec = prd_spec ;
        new_art.prd_origincountryid = prd_origincountryid ;
        new_art.prd_origincountryname = prd_origincountryname ;
        new_art.prd_originprovinceid = prd_originprovinceid ;
        new_art.prd_originprovincename= prd_originprovincename;
        new_art.prd_parameter= prd_parameter;
        new_art.prd_shipfee = prd_shipfee ; 
        
        new_art.prd_season = prd_season ; 
        new_art.prd_import = prd_import ; 
        new_art.prd_jit = prd_jit ; 
        new_art.prd_reduce = prd_reduce ; 
        new_art.prd_beauty = prd_beauty ; 
        new_art.prd_nutrition = prd_nutrition ; 
        
        
        
        
        //2010.05.20 jialin 设置当前文章默认模板
        if(t.equals(topic))
        {
            //如果目标栏目与当前文章相同的，则新文章的当前模板和该文章相同
            new_art.current_template_no = current_template_no;
        }
        else
        {
            //否则采用栏目默认模板
            new_art.current_template_no = null;
        }      
        new_art.bNew = true;

        //复制扩展属性
        if(custom_fields!=null && !custom_fields.isEmpty())
        {
            new_art.custom_fields = new Hashtable(custom_fields.size());
            new_art.custom_fields.putAll(custom_fields);
        }
        
        //复制附件
        List<Attach> attaches = GetAttach();
        if(attaches!=null && !attaches.isEmpty())
        {
            for(Attach att:attaches)
            {
                try
                {
                    //创建新的资源对象，注意不能使用之前的对象
                    Attach new_att = new Attach(ctxt,new_art,att.GetResource());
                    new_art.AddAttach(new_att);

                    //复制物理文件
                    new_att.CopyAttachFiles();
                }
                catch(Exception e)
                {
                    nps.util.DefaultLog.error(e);
                }
            }
        }

        return new_art;        
    }

    //复制已有文章的正文
    public void UpdateContent(NormalArticle art) throws NpsException
    {
        if(art==null) return;
        PreparedStatement pstmt = null;
        try
        {
            String sql = "update article set content=(select content from article where id=?),abstract=(select abstract from article where id=?) where id=?";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,art.GetId());
            pstmt.setString(2,art.GetId());
            pstmt.setString(3,id);
            pstmt.executeUpdate();
            try{pstmt.close();}catch(Exception e1){}

            //清空当前文件系统缓存数据，要求重新加载
            Clear("content");
        }
        catch(Exception e)
        {
            ctxt.Rollback();
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            try{pstmt.close();}catch(Exception e1){}
        }

        UpdateLastModify();
    }

    //撤销发布的文章
    public void Cancel(boolean bResetPublishDate) throws NpsException
    {
        if(state!=ARTICLE_PUBLISH) return;

        PreparedStatement pstmt = null;
        try
        {
            //如果已经发布的，需要删除
            //1.删除附件
            /*
            //2009.11.20 jialin
            //为了保证正文图片的可预览性，文章撤销后远程FTP文件也不删除
            //附件将再文章整个删除后才予以删除
            for(Attach att:attaches)
            {
                site.DeleteFromImageFtp(att.GetRelativeURL());

                //删除本地临时文件，如果不是FTP多台服务器部署，以下将删除WEB目录下文件
                //File local_file = att.GetOutputFile();
                //try{local_file.delete();}catch(Exception e1){}
            }
            */

            //2.删除产生的静态页面
            //2009.8.21 jialin  同时删除所有分页文件
            DeletePageFiles();

            //删除提交到SOLR的索引
            try
            {
                DeleteIndex();
            }
            catch(Exception e)
            {
                nps.util.DefaultLog.error_noexception(e);
            }

            //设置文章为待审核状态
            String sql = "update article set state=?,url_gen=null";
            if(bResetPublishDate) sql += ",publishdate=null";
            sql += ",last_modify=?,last_modify_name=?,last_modified=? ";            
            sql += " where id=?";
            
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setInt(1,ARTICLE_SUBMIT);
            pstmt.setString(2,ctxt.GetUser().GetUID());
            pstmt.setString(3,ctxt.GetUser().GetName());
            pstmt.setTimestamp(4,new java.sql.Timestamp(new Date().getTime()));
            pstmt.setString(5,id);
            pstmt.executeUpdate();

            //当前文章设置为草稿状态，发布时间为null
            state = ARTICLE_SUBMIT;
            if(bResetPublishDate) publishdate = null;

            ctxt.Commit();
        }
        catch(Exception e)
        {
            ctxt.Rollback();
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            try{pstmt.close();}catch(Exception e1){}
        }

        //发布撤销消息
        FireCancelEvent();
    }

    //删除
    public void Delete() throws NpsException
    {
        PreparedStatement pstmt = null;
        try
        {
            //删除生成的附件和静态页面
            if(state==ARTICLE_PUBLISH)
            {
                //2.删除产生的静态页面
                DeletePageFiles();

                //删除提交到SOLR的索引
                //如果已经建索引的删除索引
                try
                {
                    DeleteIndex();
                }
                catch(Exception e)
                {
                    nps.util.DefaultLog.error_noexception(e);
                }
            }

            //1.删除附件
            List<Attach> attaches = GetAttach();
            if(attaches!=null && !attaches.isEmpty())
            {
                for(Attach att:attaches)
                {
                    att.DeleteAttachFiles();
                }

                //不设置为null，防止后期触发器中重新加载
                this.attaches.clear();
                this.attaches_ids.clear();
            }
            
            //删除附件信息
            String sql = "delete from attach where artid=?";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,id);
            pstmt.executeUpdate();
            try{pstmt.close();}catch(Exception e1){}

            //删除从栏目信息
            sql = "delete from article_topics where artid=?";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,id);
            pstmt.executeUpdate();
            try{pstmt.close();}catch(Exception e1){}

            //删除文章信息
            sql = "delete from article where id=?";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,id);
            pstmt.executeUpdate();
            try{pstmt.close();}catch(Exception e1){}

            //发布删除消息
            FireDeleteEvent();
        }
        catch(Exception e)
        {
            ctxt.Rollback();
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            try{pstmt.close();}catch(Exception e1){}
        }
    }
    
    //提交Solr索引
    public void Index(int mode) throws NpsException
    {
        //无须索引
        if(!topic.IsSolrEnabled()) return;

        ProductArticle2Solr solr_task = null;
        solr_task = new ProductArticle2Solr(topic.GetSolrCore(),mode);
        switch(mode)
        {
            case ARTICLE_SOLR_DELETE:
                solr_task.Delete(this);
                break;
            default:
                solr_task.Add(this);
                break;
        }

        IndexScheduler.GetScheduler().Add(solr_task);
    }

    //Get/Set方法
    public void SetSubtitle(String s)
    {
        subtitle = s;
    }

    public String GetSubtitle()
    {
        return subtitle;
    }

    public void SetAbtitle(String s)
    {
        abtitle = s;
    }

    public String GetAbtitle()
    {
        return abtitle;
    }

    public void SetKeyword(String s)
    {
        keyword = s;
    }

    public String GetKeyword()
    {
        return keyword;
    }

    public void SetAuthor(String s)
    {
        author = s;
    }

    public String GetAuthor()
    {
        return author;
    }

    public void SetImportant(int i)
    {
        important = i;
    }

    public int GetImportant()
    {
        return important;
    }    

    public void SetSource(String s)
    {
        source = s;
    }

    public void SetAbstract(String s)
    {
        content_abstract = s;
    }

    public String GetSource()
    {
        return source;
    }

    public void SetValiddays(int i)
    {
        validdays = i;
    }

    public int GetValiddays()
    {
        return validdays;
    }

    public String GetCreatorID()
    {
        return creator;
    }

    //默认返回用户姓名
    public String GetCreator()
    {
        return GetCreatorCN();
    }

    //创建人简称，只有用户名
    public String GetCreatorCN()
    {
        return creator_cn; 
    }

    //按创建人(部门名/单位名)返回
    public String GetCreatorFN()
    {
        return creator_cn;
    }

    public void SetCreator(User user)
    {
        creator = user.GetUID();
        creator_cn = user.GetName();
    }

    //设置审核人
    public void SetApprover(User user)
    {
        approver = user.GetUID();
        approver_cn = user.GetName();
    }

    public String GetApproverID()
    {
        return approver;
    }

    public String GetApproverCN()
    {
        return approver_cn;
    }

    public float GetScore()
    {
        return score;
    }

    public void SetScore(float x)
    {
        score = x;
    }

    public String GetSourceId()
    {
        return source_id;
    }

    public String GetAbstract()
    {
        return content_abstract;
    }

    public String GetImageURL()
    {
        return pic_url;
    }

    public void SetImageURL(String s)
    {
        pic_url = s;
    }
    
    
    
    
    
    public String getPrdName() {
      return prd_name;
    }

    public void setPrdName(String prd_name) {
      this.prd_name = prd_name;
    }
    public String getPrdCode() {
      return prd_code;
    }

    public void setPrdCode(String prd_name) {
      this.prd_code = prd_name;
    }

    public int getPrdNewlevel() {
      return prd_newlevel;
    }

    public void setPrdNewlevel(int prd_newlevel) {
      this.prd_newlevel = prd_newlevel;
    }

    public double getPrdMarketprice() {
      return prd_marketprice;
    }

    public void setPrdMarketprice(double prd_marketprice) {
      this.prd_marketprice = prd_marketprice;
    }

    public double getPrdSaleprice() {
      return prd_saleprice;
    }

    public void setPrdSaleprice(double prd_saleprice) {
      this.prd_saleprice = prd_saleprice;
    }
    public Date getPrdSaleend() {
      return prd_saleend;
    }

    public void setPrdSaleend(java.sql.Date prd_saleend) {
      if(prd_saleend==null){
        this.prd_saleend = null;
        return;
      }
      this.prd_saleend = new java.util.Date(prd_saleend.getTime());
    }
    
    public double getPrdLocalprice() {
      return prd_localprice;
    }

    public void setPrdLocalprice(double prd_localprice) {
      this.prd_localprice = prd_localprice;
    }

    public int getPrdPoint() {
      return prd_point;
    }

    public void setPrdPoint(int prd_point) {
      this.prd_point = prd_point;
    }

    public String getPrdBrandid() {
      return prd_brandid;
    }

    public void setPrdBrandid(String prd_brandid) {
      this.prd_brandid = prd_brandid;
    }

    public String getPrdBrandname() {
      return prd_brandname;
    }

    public void setPrdBrandname(String prd_brandname) {
      this.prd_brandname = prd_brandname;
    }

    public String getPrdUnitid() {
      return prd_unitid;
    }

    public void setPrdUnitid(String prd_unitid) {
      this.prd_unitid = prd_unitid;
    }

    public String getPrdUnitname() {
      return prd_unitname;
    }

    public void setPrdUnitname(String prd_unitname) {
      this.prd_unitname = prd_unitname;
    }

    public String getPrdSpec() {
      return prd_spec;
    }

    public void setPrdSpec(String prd_spec) {
      this.prd_spec = prd_spec;
    }

    public String getPrdOrigincountryid() {
      return prd_origincountryid;
    }

    public void setPrdOrigincountryid(String prd_origincountryid) {
      this.prd_origincountryid = prd_origincountryid;
    }

    public String getPrdOrigincountryname() {
      return prd_origincountryname;
    }

    public void setPrdOrigincountryname(String prd_origincountryname) {
      this.prd_origincountryname = prd_origincountryname;
    }

    public String getPrdOriginprovinceid() {
      return prd_originprovinceid;
    }

    public void setPrdOriginprovinceid(String prd_originprovinceid) {
      this.prd_originprovinceid = prd_originprovinceid;
    }

    public String getPrdOriginprovincename() {
      return prd_originprovincename;
    }

    public void setPrdOriginprovincename(String prd_originprovincename) {
      this.prd_originprovincename = prd_originprovincename;
    }

    public double getPrdShipfee() {
      return prd_shipfee;
    }

    public void setPrdShipfee(double prd_shipfee) {
      this.prd_shipfee = prd_shipfee;
    }

    //为新文章生成唯一ID号
    private String GenerateArticleID()  throws NpsException
    {
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try
        {
            pstmt = ctxt.GetConnection().prepareStatement("select seq_art.nextval from dual");
            rs = pstmt.executeQuery();
            if(rs.next())
            {
               return rs.getString(1);
            }
        }
        catch(Exception e)
        {
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            try{rs.close();}catch(Exception e1){}
            try{pstmt.close();}catch(Exception e1){}
        }
        return null;        
    }

    //事件处理
    public void Insert(Object observer,InsertEvent event)
    {
        //nothing we do
    }
    
    public void Update(Object observer, UpdateEvent event)
    {
        //nothing we do
    }
    
    public void Delete(Object observer, DeleteEvent event)
    {
        //nothing we do
    }

    public void Ready(Object observer, Ready2PublishEvent event)
    {
        //nothing we do
    }

    public void Publish(Object observer, PublishEvent event)
    {
        //nothing we do
    }
    
    public void Cancel(Object observer, CancelEvent event)
    {
        //nothing we do
    }

    //从栏目相关方法
    //加载从栏目清单
    protected void LoadSlaveTopics() throws NpsException
    {
        if(topic_slaves==null)
        {
            topic_slaves = new Hashtable();
        }
        else
        {
            topic_slaves.clear();
        }

        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try
        {
            String sql = "select * from article_topics where artid=?";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,id);
            rs = pstmt.executeQuery();
            while(rs.next())
            {
                Site site_slave = ctxt.GetSite(rs.getString("siteid"));
                if(site_slave==null) continue;

                TopicTree tree_slave = site_slave.GetTopicTree();
                if(tree_slave==null) continue;

                Topic top_slave = tree_slave.GetTopic(rs.getString("topid"));
                if(top_slave==null) continue;

                topic_slaves.put(top_slave.GetId(),top_slave);
            }

            if(rs!=null) try{rs.close();}catch(Exception e){}
            if(pstmt!=null)try{pstmt.close();}catch(Exception e){}
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
    }

    //删除从栏目
    public void DeleteSlaveTopic(String top_id) throws NpsException
    {
        //1.从数据库中删除
        PreparedStatement pstmt = null;
        try
        {
            String sql = "delete from article_topics where artid=? and topid=?";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            pstmt.setString(1,id);
            pstmt.setString(2,top_id);
            pstmt.executeUpdate();
        }
        catch(Exception e)
        {
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            if(pstmt!=null) try{pstmt.close();}catch(Exception e1){}
        }

        super.DeleteSlaveTopic(top_id);
    }

    //保存附件列表
    private void SaveSlaveTopics() throws NpsException
    {
        if(topic_slaves==null || topic_slaves.isEmpty())  return;
        
        PreparedStatement pstmt = null;
        try
        {
            String sql = "insert into article_topics(siteid,topid,artid) values(?,?,?)";
            pstmt = ctxt.GetConnection().prepareStatement(sql);
            Enumeration enum_topics = topic_slaves.elements();
            while(enum_topics.hasMoreElements())
            {
                Topic slave_topic = (Topic)enum_topics.nextElement();
                try
                {
                    pstmt.setString(1,slave_topic.GetSiteId());
                    pstmt.setString(2,slave_topic.GetId());
                    pstmt.setString(3,id);
                    pstmt.executeUpdate();
                }
                catch(SQLException sql_e)
                {
                      //如果遇到ORA-00001 主键冲突就忽略错误
                      if(sql_e.getErrorCode()==1) continue;
                      throw sql_e;
                }
            }
        }
        catch(Exception e)
        {
            nps.util.DefaultLog.error(e);
        }
        finally
        {
            try{pstmt.close();}catch(Exception e1){}
        }
    }
    
    public String getPrdParameter() {
      return prd_parameter;
    }

    public void setPrdParameter(String prd_parameter) {
      this.prd_parameter = prd_parameter;
    }

    public void updateOrigin() throws  NpsException{
      String sql =  "update article t set( t.prd_origincountryid,t.prd_origincountryname,t.prd_originprovincename ,t.prd_originprovinceid)=(\n" +
        "select z2.ui_id,z2.ui_name,z1.ui_name,z1.ui_id from  itg_zoneinfo z1,itg_zoneinfo z2 where substr(z1.ui_id,0,2) = z2.ui_id and z1.ui_id = t.prd_originprovinceid)\n" + 
        "where t.id = ?";
      

      PreparedStatement pstmt=null;
      try{
          pstmt=ctxt.GetConnection().prepareStatement(sql);
          int pos=1;
          pstmt.setString(pos++,id);
          pstmt.executeUpdate();
      }
      catch(Exception ex){
        nps.util.DefaultLog.error(ex);
      }
      finally{
          if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
      }
  

    }

    public int getPrdSeason() {
      return prd_season;
    }

    public void setPrdSeason(int prd_season) {
      this.prd_season = prd_season;
    }

    public int getPrdBeauty() {
      return prd_beauty;
    }

    public void setPrdBeauty(int prd_beauty) {
      this.prd_beauty = prd_beauty;
    }

    public int getPrdReduce() {
      return prd_reduce;
    }

    public void setPrdReduce(int prd_reduce) {
      this.prd_reduce = prd_reduce;
    }

    public int getPrdImport() {
      return prd_import;
    }

    public void setPrdImport(int prd_import) {
      this.prd_import = prd_import;
    }
    public int getPrdJit() {
      return prd_jit;
    }

    public void setPrdJit(int prd_jit) {
      this.prd_jit = prd_jit;
    }

    public int getPrdNutrition() {
      return prd_nutrition;
    }

    public void setPrdNutrition(int prd_nutrition) {
      this.prd_nutrition = prd_nutrition;
    }
    
    
}