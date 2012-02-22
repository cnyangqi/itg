<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.Vector" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.io.*" %>
<%@ page import="nps.module.VisualModule" %>
<%@ page import="nps.module.VisualTemplate" %>
<%@ page import="nps.module.ServletResponseWrapperModuleInclude" %>

<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    String template_id = request.getParameter("template_id");
    String publishas = request.getParameter("publishas");
    String format = request.getParameter("format");
    String site_id = request.getParameter("site_id");
    String top_id = request.getParameter("top_id");
    String url = request.getParameter("url");
    url = Utils.FixURL(url);

    if( template_id==null || template_id.length()==0
        || publishas==null || publishas.length()==0)
    {
        throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    }

    VisualTemplate template = null;
    NpsWrapper wrapper = null;
    Site site = null;
    Topic topic = null;  //发布HTML文件时允许只选择站点，但是路径必须是绝对路径，以/开头

    ServletResponseWrapperModuleInclude output_wrapper = null;
    PrintWriter output = null;
    try
    {
        wrapper = new NpsWrapper(user);

        if(site_id!=null && site_id.length()>0)
        {
            site = wrapper.GetSite(site_id);
            if(top_id!=null && top_id.length()>0)
            {
                topic = wrapper.GetSite(site_id).GetTopicTree().GetTopic(top_id);
            }
        }

        template = VisualTemplate.Load(wrapper.GetContext().GetConnection(),template_id);

        //publish as: HTML/TEMPLATE/FCKTEMPLATE
        Writer writer = null;
        if("HTML".equalsIgnoreCase(publishas))
        {
            if(format==null || format.length()==0) format = "HTML";
            writer = template.PublishHTML(wrapper.GetContext(),format,site,topic,url);
        }
        else if("TEMPLATE".equalsIgnoreCase(publishas))
        {
            if(format==null || format.length()==0) format = "TEMPLATE";
            writer = template.PublishNpsTemplate(wrapper.GetContext(),format,topic,url);
        }
        else if("FCKTEMPLATE".equalsIgnoreCase(publishas))
        {
            if(format==null || format.length()==0) format = "HTML";
            writer = template.PublishFCKTemplate(wrapper.GetContext(),format);
        }
        else if("ARTICLE".equalsIgnoreCase(publishas))
        {
            if(format==null || format.length()==0) format = "HTML";
            writer = template.PublishArticle(wrapper.GetContext(),format,topic);
        }
        else
        {
            throw new NpsException(ErrorHelper.INPUT_ERROR);
        }

        output_wrapper = new ServletResponseWrapperModuleInclude(response,writer);
        output = output_wrapper.getWriter();

        String charset = "UTF-8";
        if(site!=null) charset = site.GetEncoding();
        
        output.println("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\" \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">");
        output.println("<HTML>");
        output.println("<HEAD>");
        output.println("<TITLE>");
        output.println(template.GetTitle());
        output.println("</TITLE>");
        output.println("<META content=\"text/html; charset="+charset+"\" http-equiv=Content-Type>");
        output.println("<LINK rel=stylesheet type=text/css href=\"/css/modules.css\">");

        File dir_css = new File(Config.WEB_ROOT + "modules/css/");
        if(dir_css.exists())
        {
            File[] list_css = dir_css.listFiles();
            if(list_css!=null)
            {
                for(int i=0; i<list_css.length; i++)
                {
                    File cs_file = list_css[i];
                    if(!cs_file.isFile()) continue;
                    if(!cs_file.getName().endsWith(".css")) continue;
                    output.print("<link rel='stylesheet' type='text/css' href='/modules/css/");
                    output.print(cs_file.getName());
                    output.println("'>");
                }
            }
        }
        
        output.println("<SCRIPT type=text/javascript src='/jscript/prototype.js'></SCRIPT>");
        output.println("<SCRIPT type=text/javascript src='/jscript/jquery.js'></SCRIPT>");
        output.println("<script type=text/javascript>var $j = jQuery.noConflict();</script>");

        File dir_js = new File(Config.WEB_ROOT + "modules/jscript/");
        if(dir_js.exists())
        {
            File[] list_js = dir_js.listFiles();
            if(list_js!=null)
            {
                for(int i=0; i<list_js.length; i++)
                {
                    File js_file = list_js[i];
                    if(!js_file.isFile()) continue;
                    if(!js_file.getName().endsWith(".js")) continue;
                    output.print("<script type='text/javascript' src='/modules/jscript/");
                    output.print(js_file.getName());
                    output.println("'></script>");
                }
            }
        }

        output.println("</HEAD>");
        output.println("<BODY class=page>");
        output.print("<DIV id=container_wrap");
        if(template.GetBackgroundColor()!=null)
        {
            output.print(" style=\"background:" + template.GetBackgroundColor() + ";\"");
        }
        output.println(">");
        output.println("<DIV id=container>");
        output.println("<DIV id=content>");
        output.println("<DIV class=editor>");
        output.println("<DIV id=modules>");

        Vector<VisualModule> modules = template.GetModules();
        if(modules!=null)
        {
            int test_align = -1;
            String test_width = null;
            int size_modules = modules.size();
            for(int i=0;i<size_modules;i++)
            {
                VisualModule module = modules.get(i);
                int align = module.GetAlign();
                if(i==size_modules-1) align = VisualModule.FLOAT_NONE;//最后一个没有Float属性

                String modfloat = "full";
                switch(align)
                {
                    case VisualModule.FLOAT_LEFT:
                        modfloat = "left";
                        break;
                    case VisualModule.FLOAT_NONE:
                        modfloat = "full";
                        break;
                    case VisualModule.FLOAT_RIGHT:
                        modfloat = "right";
                        break;
                }

                if (    align!=test_align
                    || (test_width!=null && module.GetWidth()!=null && !test_width.equals(module.GetWidth()))
                    || (test_width==null && module.GetWidth()!=null))
                {
                    if(test_align!=-1)
                    {
                        output.println("</DIV>");

                        if(align==VisualModule.FLOAT_RIGHT ||  "100%".equals(module.GetWidth()))
                        {
                           output.println("<div class=\"floatclear\"></div>");
                        }
                    }
                    
                    output.print("<DIV class=\"modfloat " + modfloat + "\"");

                    String style_width = null;
                    if(module.GetWidth()!=null && module.GetWidth().length()>0)
                    {
                        style_width = "width:" + module.GetWidth() + ";";
                    }

                    String style_display = "display:inline-block;";
                    if(module.GetAlign()== VisualModule.FLOAT_NONE)
                    {
                        style_display = null;
                    }

                    if(style_width!=null || style_display!=null )
                    {
                        output.print(" style=\"");
                        if(style_display!=null) output.print(style_display);
                        if(style_width!=null) output.print(style_width);
                        output.print("\"");
                    }
                    output.println(">");
                }

                test_align = align;
                test_width = module.GetWidth();

                output.println("<DIV class=mod>");

                String style_backgroundcolor = null;
                if(module.GetBackgroundColor()!=null && module.GetBackgroundColor().length()>0)
                {
                    style_backgroundcolor = "background:" + module.GetBackgroundColor() + ";";
                }

                String style_height = null;
                if(module.GetHeight()!=null && module.GetHeight().length()>0)
                {
                    style_height = "height:" + module.GetHeight() + ";";
                }

                String style_overflow = null;
                if(module.GetOverflow()!=null && module.GetOverflow().length()>0)
                {
                    style_overflow = "overflow:" + module.GetOverflow() + ";";
                }

                String style_module = null;
                if(style_backgroundcolor!=null || style_height!=null || style_overflow!=null)
                {
                    style_module = " style=\"";
                    if(style_backgroundcolor!=null) style_module += style_backgroundcolor;
                    if(style_height!=null) style_module += style_height;
                    if(style_overflow!=null) style_module += style_overflow;
                    style_module += "\"";
                }
                output.print("<DIV class=\"module\"");
                if(style_module!=null) output.print(style_module);
                output.println(">");

                if(module.GetDisplayTitle() && !module.IsNullTitle())
                {
                    output.print("<H2>");
                    output.print(module.GetTitle());
                    output.println("</H2>");
                }


                String style_textalign = null;
                if(module.GetTextAlign()!=null && module.GetTextAlign().length()>0)
                {
                    style_textalign = "text-align:" + style_textalign + ";";
                }

                String style_txtd = null;
                if(style_textalign!=null)
                {
                    style_txtd = "style=\"" + style_textalign + "\"";
                }
                //Load view.jsp, format=HTML always
                request.setAttribute("module",module);
                RequestDispatcher dispatcher_view = request.getRequestDispatcher(module.GetViewPage() + "?format=" + format);
                output.println("<DIV class='txtd' " + nps.util.Utils.Null2Empty(style_txtd) + ">");
                output.flush();
                dispatcher_view.include(request, output_wrapper);
                output.flush();
                output.println("</DIV>");
                request.removeAttribute("module");

                output.println("</DIV>");
                output.println("</DIV>");
            }
            output.println("</DIV>");            
        }

        output.println("</DIV>");
        output.println("</DIV>");
        output.println("</DIV>");
        output.println("</DIV>");
        output.println("</DIV>");
        output.println("</BODY>");
        output.println("</HTML>");
        output.flush();

        wrapper.Commit();
    }
    catch(Exception e)
    {
        wrapper.Rollback();

        //清除页面模板勾连关系
        if("TEMPLATE".equalsIgnoreCase(publishas))
        {
            SitePool.GetPool().remove(topic.GetSiteId());
        }

        throw e;
    }
    finally
    {
        if(output!=null) try{output.close();}catch(Exception e1){}
        if(wrapper!=null) wrapper.Clear();
    }
%>