<%@ page language = "java" contentType = "text/html;charset=UTF-8"%>
<%@ page import="nps.core.*" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="nps.module.video.*" %>
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
        Video video = null;
        if(source==null || "".equals(source))
        {
            video = new Video(module,suffix);
        }
        else
        {
            wrapper = new NpsWrapper(user);
            if("RESOURCE".equalsIgnoreCase(source))
            {
                video = new ResourceVideo(wrapper.GetContext(),module,suffix);
            }
            else if("SQL".equalsIgnoreCase(source))
            {
                video = new SQLVideo(wrapper.GetContext(),module,suffix);
            }
        }

        if(effect==null || "".equals(effect))
        {
            if("TEMPLATE".equalsIgnoreCase(format))
                video.toTemplate(new PrintWriter(out));
            else
                video.toHtml(new PrintWriter(out));
        }
        else if("MARQUEE".equalsIgnoreCase(effect))
        {
            if("TEMPLATE".equalsIgnoreCase(format))
                video.toMarqueeTemplate(new PrintWriter(out));
            else
                video.toMarqueeHtml(new PrintWriter(out));
        }
        else if("FLOAT".equalsIgnoreCase(effect))
        {
            if("TEMPLATE".equalsIgnoreCase(format))
                video.toFloatTemplate(new PrintWriter(out));
            else
                video.toFloatHtml(new PrintWriter(out));
        }
    }
    finally
    {
        if(wrapper!=null) wrapper.Clear();
    }
%>