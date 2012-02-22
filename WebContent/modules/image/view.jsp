<%@ page language = "java" contentType = "text/html;charset=UTF-8"%>

<%@ page import="nps.module.VisualModule" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="nps.core.NpsWrapper" %>
<%@ page import="nps.module.image.*" %>

<%@ include file="/include/header.jsp" %>

<%
    out.clear();
    VisualModule module = (VisualModule)request.getAttribute("module");
    String format = request.getParameter("format");
    String suffix = request.getParameter("suffix");
    if(suffix==null || suffix.length()==0) suffix = module.GetId();

    String source = module.GetDataString("source",suffix);
    String effect = module.GetDataString("effect",suffix);

    NpsWrapper wrapper = null;
    try
    {
        Image image = null;
        if(source==null || "".equals(source))
        {
            image = new Image(module,suffix);
        }
        else
        {
            wrapper = new NpsWrapper(user);
            if("ARTICLE".equalsIgnoreCase(source))
            {
                image = new ArticleImage(wrapper.GetContext(),module,suffix);
            }
            else if("RESOURCE".equalsIgnoreCase(source))
            {
                image = new ResourceImage(wrapper.GetContext(),module,suffix);
            }
            else if("CUSTOMTOPIC".equalsIgnoreCase(source))
            {
                image = new ArticleImageCustom(wrapper.GetContext(),module,suffix);
            }
            else if("SQL".equalsIgnoreCase(source))
            {
                image = new SQLImage(wrapper.GetContext(),module,suffix);
            }
        }

        if(effect==null || "".equals(effect))
        {
            if("TEMPLATE".equalsIgnoreCase(format))
                image.toTemplate(new PrintWriter(out));
            else
                image.toHtml(new PrintWriter(out));
        }
        else if("MARQUEE".equalsIgnoreCase(effect))
        {
            if("TEMPLATE".equalsIgnoreCase(format))
                image.toMarqueeTemplate(new PrintWriter(out));
            else
                image.toMarqueeHtml(new PrintWriter(out));
        }
        else if("SLIDE".equalsIgnoreCase(effect))
        {
            if("TEMPLATE".equalsIgnoreCase(format))
                image.toSlideTemplate(new PrintWriter(out));
            else
                image.toSlideHtml(new PrintWriter(out));
        }
        else if("FLOAT".equalsIgnoreCase("float"))
        {
            if("TEMPLATE".equalsIgnoreCase(format))
                image.toFloatTemplate(new PrintWriter(out));
            else
                image.toFloatHtml(new PrintWriter(out));
        }
        else if("FLASH".equalsIgnoreCase(effect))
        {
            if("TEMPLATE".equalsIgnoreCase(format))
                image.toFlashTemplate(new PrintWriter(out));
            else
                image.toFlashHtml(new PrintWriter(out));
        }
    }
    finally
    {
        if(wrapper!=null) wrapper.Clear();
    }
%>