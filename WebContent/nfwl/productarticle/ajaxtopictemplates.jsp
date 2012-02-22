<%@ page contentType="text/plain; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.exception.*" %>
<%@ include file = "/include/header.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");

    String site_id = request.getParameter("site");
    String top_id = request.getParameter("top");
    String req_control_name = request.getParameter("control");
    String func_callback = request.getParameter("callback");

    if(site_id==null || site_id.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    if(top_id==null || top_id.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    if(req_control_name==null || req_control_name.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    if(func_callback==null || func_callback.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

    NpsWrapper wrapper = null;
    Site site = null;
    Topic top = null;

    out.clear();

    try
    {
        wrapper = new NpsWrapper(user,site_id);
        site = wrapper.GetSite();
        if(site==null) throw new NpsException(ErrorHelper.SYS_NOSITE);
        top = site.GetTopicTree().GetTopic(top_id);
        if(top==null) throw new NpsException(ErrorHelper.SYS_NOTOPIC);

        Template template = top.GetCascadedArticleTemplate();
        if(template==null) return;

        StringBuffer buf = new StringBuffer();
        buf.append(func_callback);
        buf.append("\r\n");

        buf.append(req_control_name);
        buf.append("\r\n");

        buf.append("2"); //字段个数
        buf.append("\r\n");

        for(int i=0;i<3;i++)
        {
            String template_name = template.GetTemplateName(i);
            if(template_name==null || template_name.length()==0) continue;

            buf.append(i);
            buf.append("\r\n");
            buf.append(template_name);
            buf.append("\r\n");            
        }

        out.print(buf);
    }
    catch(Exception e)
    {
        wrapper.Clear();
    }
%>