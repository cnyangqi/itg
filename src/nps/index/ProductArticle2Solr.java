package nps.index;

import nps.exception.NpsException;
import nps.core.NormalArticle;
import nps.core.Attach;
import nps.core.Field;
import nps.core.Topic;

import java.util.List;
import java.util.Enumeration;

/**
 *  将NormalArticle送SOLR索引
 *
 *  1.2009.08.25 jialin
 *    增加摘要字段
 * 
 * NPS - a new publishing system
 * Copyright: Copyright (c) 2007
 *
 * @author jialin, lanxi justa network co.,ltd.
 * @version 1.0
*/
public class ProductArticle2Solr extends Index2Solr
{
    public ProductArticle2Solr(String core,int mode) throws NpsException
    {
        super(core,mode);
    }

    //是否保留字段判断，默认全部不是保留，重载
    protected boolean IsReserved(String fieldname)
    {
        if(fieldname.equalsIgnoreCase("id")) return true;
        if(fieldname.equalsIgnoreCase("title")) return true;
        if(fieldname.equalsIgnoreCase("subtitle")) return true;
        if(fieldname.equalsIgnoreCase("site")) return true;
        if(fieldname.equalsIgnoreCase("sitename")) return true;
        if(fieldname.equalsIgnoreCase("topic")) return true;
        if(fieldname.equalsIgnoreCase("topiccode")) return true;
        if(fieldname.equalsIgnoreCase("topicname")) return true;
        if(fieldname.equalsIgnoreCase("keyword")) return true;
        if(fieldname.equalsIgnoreCase("author")) return true;
        if(fieldname.equalsIgnoreCase("source")) return true;
        if(fieldname.equalsIgnoreCase("important")) return true;
        if(fieldname.equalsIgnoreCase("createdate")) return true;
        if(fieldname.equalsIgnoreCase("publishdate")) return true;
        if(fieldname.equalsIgnoreCase("creator")) return true;
        if(fieldname.equalsIgnoreCase("artscore")) return true;
        if(fieldname.equalsIgnoreCase("abstract")) return true;
        if(fieldname.equalsIgnoreCase("content")) return true;
        if(fieldname.equalsIgnoreCase("attach")) return true;
        if(fieldname.equalsIgnoreCase("url")) return true;
        if(fieldname.equalsIgnoreCase("url_gen")) return true;
        if(fieldname.equalsIgnoreCase("pic_url")) return true;

        return false;
    }

    //索引一个NormalArticle
    public void Add(NormalArticle art)  throws NpsException
    {
        //写入本地XML文件
        AddSolrCore();
        AddXMLHeader();
        AddXMLDocHeader();

        AddField("id",new Field(GetUNID(art.GetId())));
        AddField("title",new Field(art.GetTitle()));
        AddField("subtitle",new Field(art.GetSubtitle()));
        AddField("site",new Field(art.GetTopic().GetSiteId()));
        AddField("sitename",new Field(art.GetTopic().GetSite().GetName()));
        AddField("topic",new Field(art.GetTopic().GetId()));
        AddField("topiccode",new Field(art.GetTopic().GetCode()));        
        AddField("topicname",new Field(art.GetTopic().GetName()));
        AddField("keyword",new Field(art.GetKeyword()));
        AddField("author",new Field(art.GetAuthor()));
        AddField("source",new Field(art.GetSource()));
        AddField("important",new Field(art.GetImportant()));
        AddField("createdate",new Field(art.GetCreateDate()));
        AddField("publishdate",new Field(art.GetPublishDate()));
        AddField("creator",new Field(art.GetCreatorID()));
        AddField("artscore",new Field(art.GetScore()));
        AddField("url",new Field(art.GetURL()));
        AddField("abstract",new Field(art.GetAbstract()));
        AddField("pic_url",new Field(art.GetImageURL()));
        AddField("content",art.GetField("art_content"));
        AddField("localprice",new Field(art.getPrdLocalprice()));
        AddField("marketprice",new Field(art.getPrdMarketprice()));

        //添加自定义字段
        Enumeration custom_fields = art.GetCustomFields();
        if(custom_fields!=null)
        {
              Topic topic = art.GetTopic();
              while(custom_fields.hasMoreElements())
              {
                  String field_name = (String)custom_fields.nextElement();
                  if(topic.IsReversedSolrField(field_name))
                  {
                       AddField(field_name.toLowerCase(),new Field(art.GetCustomField(field_name)));
                  }
                  else
                  {
                       AddField(field_name.toLowerCase()+"_s",new Field(art.GetCustomField(field_name)));
                  }
              }
        }

        //2009.01.05 自动索引附件
        List attaches = art.GetAttach();
        if(attaches!=null && attaches.size()>0)
        {
            for(Object obj:attaches)
            {
                AddAttachField((Attach)obj);
            }
        }

        AddXMLDocFooter();
        AddXMLFooter();

        Clear();
    }

    //删除一篇文章
    public void Delete(NormalArticle art) throws NpsException
    {
        //写入本地XML文件
        AddSolrCore();
        AddXMLHeader();
        AddXMLDocHeader();

        AddField("id",new Field(GetUNID(art.GetId())));
        
        AddXMLDocFooter();
        AddXMLFooter();

        Clear();
    }

    private String GetUNID(String id)
    {
        return "article"+id;
    }
}
