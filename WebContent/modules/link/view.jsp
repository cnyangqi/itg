<%@ page language = "java" contentType = "text/html;charset=UTF-8"%>
<%@ page import="nps.core.*" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="nps.module.link.*" %>
<%@ page import="nps.module.VisualModule" %>

<%@ include file="/include/header.jsp" %>

<%
    out.clear();

    VisualModule module = (VisualModule)request.getAttribute("module");
    String format = request.getParameter("format");
    String suffix = request.getParameter("suffix");
    if(suffix==null || suffix.length()==0) suffix = module.GetId();

    String effect = module.GetDataString("effect",suffix);
    String source = module.GetDataString("source",suffix);

    NpsWrapper wrapper = null;
    try
    {
        Link link = null;
        if(source==null || "".equals(source))
        {
            link = new Link(module,suffix);
        }
        else
        {
            wrapper = new NpsWrapper(user);
            if("ARTICLE".equalsIgnoreCase(source))
            {
                link = new ArticleLink(wrapper.GetContext(),module,suffix);
            }
            else if("RESOURCE".equalsIgnoreCase(source))
            {
                link = new ResourceLink(wrapper.GetContext(),module,suffix);
            }
            else if("CUSTOMTOPIC".equalsIgnoreCase(source))
            {
                link = new ArticleLinkCustom(wrapper.GetContext(),module,suffix);
            }
            else if("SQL".equalsIgnoreCase(source))
            {
                link = new SQLLink(wrapper.GetContext(),module,suffix);
            }
        }

        if(effect==null || "".equals(effect))
        {
            if("TEMPLATE".equalsIgnoreCase(format))
                link.toTemplate(new PrintWriter(out));
            else
                link.toHtml(new PrintWriter(out));
        }
        else if("MARQUEE".equalsIgnoreCase(effect))
        {
            if("TEMPLATE".equalsIgnoreCase(format))
                link.toMarqueeTemplate(new PrintWriter(out));
            else
                link.toMarqueeHtml(new PrintWriter(out));
        }
    }
    finally
    {
        if(wrapper!=null) wrapper.Clear();
    }
%>