<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.core.*" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.List" %>
<%@ page import="nps.job.backup.SqliteDump" %>
<%@ include file="/include/header.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");
    String id = request.getParameter("id");
    String cmd = request.getParameter("cmd");
    if( id!=null ) id = id.trim();
    if(id==null || id.length()==0)
        throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

    boolean bNew = false;
    if("add".equalsIgnoreCase(cmd)) bNew = true;
    
    String site_name = request.getParameter("name");
    if(site_name!=null) site_name = site_name.trim();
    if(site_name==null || site_name.length()==0)
        throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

    String unitid = request.getParameter("unitid");
    if(unitid!=null) unitid = unitid.trim();
    if(unitid==null || unitid.length()==0)
        throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

    String domain = request.getParameter("domain");
    String rooturl = request.getParameter("rooturl");
    String publishdir = request.getParameter("publishdir");
    String imgpublishdir = request.getParameter("imgpublishdir");
    String imgrooturl = request.getParameter("imgrooturl");
    String encoding = request.getParameter("encoding");
    String suffix = request.getParameter("suffix");
    String threads = request.getParameter("threads");

    if(publishdir!=null)   publishdir = publishdir.trim();    
    if(publishdir==null || publishdir.length()==0)
        throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

    if(!bNew && !user.IsSiteAdmin(id))
        throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_sitesave",user.GetLocale(), Config.RES_CLASSLOADER);
    
    NpsWrapper wrapper = null;
    Site site = null;
    try
    {
        wrapper = new NpsWrapper(user);
        site = wrapper.GetSite(id);

        //删除
        if("delete".equalsIgnoreCase(cmd))
        {
            if(site==null) throw new NpsException(ErrorHelper.SYS_NOSITE);
            wrapper.DeleteSite(site);
            out.println(bundle.getString("SITE_HINT_DELETED"));
            
            //当前用户列表中增加
            user.RemoveSite(site);
            return;
        }

        //冻结
        if("freeze".equalsIgnoreCase(cmd))
        {
             if(site==null) throw new NpsException(ErrorHelper.SYS_NOSITE);
             wrapper.FreezeSite(site);
             response.sendRedirect("siteinfo.jsp?id="+id);
             return;
        }

        //解冻
        if("defreeze".equalsIgnoreCase(cmd))
        {
             if(site==null) throw new NpsException(ErrorHelper.SYS_NOSITE);
             wrapper.DefreezeSite(site);
             response.sendRedirect("siteinfo.jsp?id="+id);
             return;
        }

        //导出
        if("export".equalsIgnoreCase(cmd))
        {
            if(site==null) throw new NpsException(ErrorHelper.SYS_NOSITE);
            response.reset();
            response.setContentType("application/zip");
            response.setHeader("Content-disposition","inline;filename=site" + id + ".zip");//定义文件名

            try
            {
                wrapper.Export(response.getOutputStream());
            }
            finally
            {
                response.flushBuffer();
                out.clear();
                out = pageContext.pushBody();
            }
            return;
        }

        //备份数据
        if("dump".equalsIgnoreCase(cmd))
        {
            if(site==null) throw new NpsException(ErrorHelper.SYS_NOSITE);
            response.reset();
            response.setContentType("application/zip");
            response.setHeader("Content-disposition","inline;filename=dmp" + id + ".zip");//定义文件名

            try
            {
                SqliteDump dump = new SqliteDump(wrapper.GetContext(),site);
                dump.Dump(response.getOutputStream());
            }
            finally
            {
                response.flushBuffer();
                out.clear();
                out = pageContext.pushBody();
            }
            return;
        }

        //归档
        if("archive".equalsIgnoreCase(cmd))
        {
             if(site==null) throw new NpsException(ErrorHelper.SYS_NOSITE);
             wrapper.ArchiveSite(site);
             out.println(bundle.getString("SITE_HINT_ARCHIVED"));
             return;
        }

        //新增或保存
        Unit unit = user.GetUnit(unitid);
        if(unit==null)   throw new NpsException(ErrorHelper.SYS_NOUNIT);
        
        if(bNew)
        {
            if(site!=null) throw new NpsException(ErrorHelper.SYS_SITE_ALREADY_EXIST);

            site = Site.GetSite(id,site_name,domain,publishdir,unit,imgpublishdir,suffix,rooturl,imgrooturl);
        }
        else
        {
            if(site==null) //站点没有找到
            {                
                //新建站点
                site = Site.GetSite(id,site_name,domain,publishdir,unit,imgpublishdir,suffix,rooturl,imgrooturl);
            }
            else
            {
                site.SetDomain(domain);
                site.SetName(site_name);
                site.SetUnit(unit);
                site.SetSuffix(suffix);
                site.SetArticleDir(publishdir);
                site.SetRootURL(rooturl);
                site.SetImgURL(imgrooturl);
                site.SetImgDir(imgpublishdir);
            }
        }

        site.SetEncoding(encoding);
        
        String fulltext = request.getParameter("fulltext");
        if(fulltext!=null && fulltext.length()>0)
            site.SetFulltextIndex(true);
        else
            site.SetFulltextIndex(false);

        String solr_core = request.getParameter("solr_core");
        if(solr_core==null || solr_core.length()==0)
            site.SetSolrCore(null);
        else
            site.SetSolrCore(solr_core);

        String write_buffered = request.getParameter("write_buffered");
        if(write_buffered!=null && write_buffered.length()>0)
            site.SetWriteBuffered(true);
        else
            site.SetWriteBuffered(false);

        if(threads!=null && threads.length()>0)
        {
            try{site.SetThreads(Integer.parseInt(threads));}catch(Exception e){}
        }

        //1.FTP服务器
        site.ClearFtps4Article();
        site.ClearFtps4Image();
        String[] img_ftp_host  = request.getParameterValues( "img_ftp_host" );
        String[] img_ftp_port  = request.getParameterValues( "img_ftp_port" );
        String[] img_ftp_remotedir = request.getParameterValues( "img_ftp_remotedir" );
        String[] img_ftp_username = request.getParameterValues( "img_ftp_username" );
        String[] img_ftp_userpwd  = request.getParameterValues( "img_ftp_userpwd" );

        //1.1.如果有图片服务器，加载之
        for(int i=0;img_ftp_host!=null && i<img_ftp_host.length;i++)
        {
            if(img_ftp_host[i]==null || img_ftp_host[i].length()==0) continue;
            int port = 0;
            try{port=Integer.parseInt(img_ftp_port[i]);}catch(Exception e1){}

            site.AddFtp4Image(img_ftp_host[i],
                              img_ftp_remotedir[i],
                              port,
                              img_ftp_username[i],
                              img_ftp_userpwd[i]);
        }

        String[] ftp_host  = request.getParameterValues( "ftp_host" );
        String[] ftp_port  = request.getParameterValues( "ftp_port" );
        String[] ftp_remotedir = request.getParameterValues( "ftp_remotedir" );
        String[] ftp_username = request.getParameterValues( "ftp_username" );
        String[] ftp_userpwd  = request.getParameterValues( "ftp_userpwd" );

        //如果没有图片服务器，一旦有文章服务器，就建在文章服务器的/images/目录下
        List imgFtpHosts = site.GetImageFtpHosts();
        boolean bAddImgFtps = (imgFtpHosts==null || imgFtpHosts.isEmpty());

        //1.2.加载文章服务器
        for(int i=0; ftp_host !=null && i<ftp_host.length; i++)
        {
            if(ftp_host[i]==null || ftp_host[i].length()==0) continue;
            int port = 0;
            try{port=Integer.parseInt(ftp_port[i]);}catch(Exception e1){}

            site.AddFtp4Article(ftp_host[i],
                                ftp_remotedir[i],
                                port,
                                ftp_username[i],
                                ftp_userpwd[i]);

            if(bAddImgFtps)
            {
                //图片服务器同文章服务器，建立在/images/目录下
                site.AddFtp4Image(ftp_host[i],
                                  ftp_remotedir[i]+"/images/",
                                  port,
                                  ftp_username[i],
                                  ftp_userpwd[i]);
            }
        }

        //2.站点管理员
        site.ClearOwner();
        String site_admin[]  = request.getParameterValues( "userId" );
        String site_adminname[] = request.getParameterValues("userName");
        for(int i=0; site_admin !=null && i<site_admin.length; i++)
        {
            if(site_admin[i]==null || site_admin[i].length()==0) continue;

            site.AddOwner(site_admin[i], site_adminname[i]);
        }

        //3.全局变量
        site.ClearVars();
        String var_names[] = request.getParameterValues("var_name");
        String var_values[] = request.getParameterValues("var_value");
        String var_comments[] = request.getParameterValues("var_comment");
        for(int i=0;var_names!=null && i<var_names.length;i++)
        {
            if(var_names[i]==null || var_names[i].length()==0) continue;

            site.AddVar(var_names[i],var_values[i],var_comments[i]);
        }

        //4.全局Solr Fields
        site.ClearSolrFields();
        String solr_names[] = request.getParameterValues("solrfield_name");
        String solr_comments[] = request.getParameterValues("solrfield_comment");
        for(int i=0;solr_names!=null && i<solr_names.length;i++)
        {
            if(solr_names[i]==null || solr_names[i].length()==0) continue;

            site.AddSolrField(solr_names[i],solr_comments[i]);
        }

        //5.热字
        String keylink_enabled = request.getParameter("keylink_enabled");
        if(keylink_enabled!=null && keylink_enabled.length()>0)
            site.SetKeywordLinkEnabled(true);
        else
            site.SetKeywordLinkEnabled(false);

        String keylink_ignorecase = request.getParameter("keylink_ignorecase");
        if(keylink_ignorecase!=null && keylink_ignorecase.length()>0)
            site.SetKeywordLinkIgnoreCase(true);
        else
            site.SetKeywordLinkIgnoreCase(false);

        String keylink_css = request.getParameter("keylink_css");
        if(keylink_css!=null && keylink_css.length()>0)
            site.SetKeywordLinkCSS(keylink_css);
        else
            site.SetKeywordLinkCSS(null);

        String keylink_target = request.getParameter("keylink_target");
        if(keylink_target!=null && keylink_target.length()>0)
            site.SetKeywordLinkTarget(keylink_target);
        else
            site.SetKeywordLinkTarget(null);

        site.ClearKeywordLinks();
        String keylink_words = request.getParameter("keylink_words");
        site.AddKeywordLinks(keylink_words);

        //5.保存或更新
        wrapper.SaveSite(site,bNew);
        wrapper.Commit();

        //当前用户列表中增加
        user.Add2OwnSite(site);
        user.Add2UnitSite(site);
        
        response.sendRedirect("siteinfo.jsp?id="+id);
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