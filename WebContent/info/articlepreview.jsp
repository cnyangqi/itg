<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.core.*" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    String id= request.getParameter("id");//如果为null，将再保存时使用序列生成ID号
    if(id!=null) id=id.trim();

    String site_id = request.getParameter("site_id");
    if(site_id!=null)  site_id=site_id.trim();

    NpsWrapper wrapper = null;
    NormalArticle art = null;
    try
    {
        wrapper = new NpsWrapper(user,site_id);
        art = wrapper.GetArticle(id);
        if(art==null) throw new NpsException(ErrorHelper.SYS_NOARTICLE);

        if(art.IsPublished() || art.IsExternalLink())
        {
            response.sendRedirect(art.GetURL());
            return;
        }
        
        Topic topic = art.GetTopic();
        if(topic==null) throw new NpsException(ErrorHelper.SYS_NOTOPIC);
        if(topic.GetCascadedArticleTemplate()==null) throw new NpsException(ErrorHelper.SYS_NOTEMPLATE);

        wrapper.GenerateArticle(art,art.GetPreviewFile());
        response.sendRedirect(art.GetPreviewURL());
    }
    finally
    {
        if(art!=null) art.Clear();
        if(wrapper!=null) wrapper.Clear();
    }
%>