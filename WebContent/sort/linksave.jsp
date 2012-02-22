<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.*" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_linksave",user.GetLocale(), nps.core.Config.RES_CLASSLOADER);

    String id= request.getParameter("id");//如果为null，将再保存时使用序列生成ID号
    if(id!=null) id=id.trim();

    String site_id = request.getParameter("site_id");
    if(site_id!=null)  site_id=site_id.trim();
    if(site_id==null || site_id.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

    String top_id = request.getParameter("top_id");
    if(top_id!=null)  top_id=top_id.trim();
    if(top_id==null || top_id.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

    String title = request.getParameter("title");
    if(title==null || title.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

    String url = request.getParameter("url");
    if(url==null || url.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

    String content_abstract = request.getParameter("content_abstract");
    String img_url = request.getParameter("img_url");

    int act=0; //默认保存处理，//0保存 1删除
    try{act=Integer.parseInt(request.getParameter("act"));}catch(Exception e1){}

    boolean bNew = (id==null || id.length()==0);

    if(bNew && act==1) throw new NpsException(ErrorHelper.SYS_NOARTICLE);

    NpsWrapper wrapper = null;
    Site site = null;
    Topic top = null;
    ArticleRefer art = null;

    try
    {
        wrapper = new NpsWrapper(user,site_id);
        wrapper.SetErrorHandler(response.getWriter());
        wrapper.SetLineSeperator("\n<br>\n");

        site = wrapper.GetSite();
        if(site==null) throw new NpsException(site_id,ErrorHelper.SYS_NOSITE);
        top = site.GetTopicTree().GetTopic(top_id);
        if(top==null) throw new NpsException(top_id,ErrorHelper.SYS_NOTOPIC);
        if(!top.IsSortEnabled()) throw new NpsException(top.GetName(),ErrorHelper.SYS_TOPIC_NOTSORTABLE);
        if(!(user.IsSysAdmin() || user.IsSiteAdmin(site_id) || top.IsOwner(user.GetUID())))
            throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

        if(bNew)
        {
            art = new ArticleRefer(wrapper.GetContext(),top,title,url);
            id = art.GetId();
            art.SetCreator(user);
        }
        else
        {
            art = ArticleRefer.GetArticle(wrapper.GetContext(),id);
            if(art==null) throw new NpsException(id,ErrorHelper.SYS_NOARTICLE);

            art.SetTitle(title);
            art.SetURL(url);
        }

        switch(act)
        {
            case 0: //保存
                art.SetAbstract(content_abstract);
                art.SetImageURL(img_url);

                if(!bNew && art.IsPublished()) art.SetState(2); //待发布状态
                art.Save();

                response.sendRedirect("linkinfo.jsp?id="+id);
                break;
            case 1: //删除
                art.Delete();
                out.print("<font color=red>");
                out.print(art.GetTitle() + " " + bundle.getString("LINK_DELETED"));
                out.println("</font>");
                break;
        }
    }
    catch(Exception e)
    {
        if(wrapper!=null) wrapper.Rollback();
        e.printStackTrace();
        throw e;
    }
    finally
    {
        if(wrapper!=null) wrapper.Clear();
    }
%>