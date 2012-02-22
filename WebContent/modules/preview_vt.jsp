<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.Vector" %>
<%@ page import="nps.module.VisualTemplate" %>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.module.VisualModule" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.io.File" %>
<%@ page import="nps.core.Config" %>

<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    String template_id = request.getParameter("id");
    if(template_id==null || template_id.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

    Connection conn = null;
    VisualTemplate template = null;
    try
    {
        conn = Database.GetDatabase("nps").GetConnection();
        template = VisualTemplate.Load(conn,template_id);
    }
    finally
    {
        if(conn!=null) try{conn.close();}catch(Exception e){}
    }
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<HTML>
<HEAD>
    <TITLE>Preview: <%=template.GetTitle()%></TITLE>
    <META content="text/html; charset=utf-8" http-equiv=Content-Type>
    <LINK rel=stylesheet type=text/css href="/css/modules.css">
<%
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
                    out.print("<link rel='stylesheet' type='text/css' href='/modules/css/");
                    out.print(cs_file.getName());
                    out.println("'>");
                }
            }
        }
%>    
    <SCRIPT type=text/javascript src="/jscript/prototype.js"></SCRIPT>
    <SCRIPT type=text/javascript src="/jscript/jquery.js"></SCRIPT>
    <script type="text/javascript">
        var $j = jQuery.noConflict();
    </script>
<%
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
                out.print("<script type='text/javascript' src='/modules/jscript/");
                out.print(js_file.getName());
                out.println("'></script>");
            }
        }
    }
%>
</HEAD>

<BODY class=page>
<DIV id=container_wrap <% if(template.GetBackgroundColor()!=null) out.print("style=\"background:" + template.GetBackgroundColor() + ";\""); %>>
<DIV id=container>
<DIV id=content>
<DIV class=editor>
<DIV id=modules>
    <%
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
                        out.println("</DIV>");
                        if (align==VisualModule.FLOAT_RIGHT || "100%".equals(module.GetWidth()))
                        {
                           out.println("<div class=\"floatclear\"></div>");
                        }
                    }

                    out.print("<DIV class=\"modfloat " + modfloat + "\"");

                    String style_width = null;
                    if(module.GetWidth()!=null && module.GetWidth().length()>0)
                    {
                        style_width = "width:" + module.GetWidth() + ";";
                    }

                    String style_display = "display:inline-block;";
                    if(module.GetAlign()==VisualModule.FLOAT_NONE)
                    {
                        style_display = null;
                    }

                    if(style_width!=null || style_display!=null )
                    {
                        out.print(" style=\"");
                        if(style_display!=null) out.print(style_display);
                        if(style_width!=null) out.print(style_width);
                        out.print("\"");
                    }
                    out.println(">");
            }

            test_align = align;
            test_width = module.GetWidth();

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
                style_module = "style=\"";
                if(style_backgroundcolor!=null) style_module += style_backgroundcolor;
                if(style_height!=null) style_module += style_height;
                if(style_overflow!=null) style_module += style_overflow;
                style_module += "\"";
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
    %>
                    <DIV class=mod>
                        <DIV class="module"  <%=nps.util.Utils.Null2Empty(style_module)%>>
                            <%
                                if(module.GetDisplayTitle() && !module.IsNullTitle())
                                {
                                    out.print("<H2>");
                                    out.print(module.GetTitle());
                                    out.println("</H2>");
                                }
                                //Load view.jsp, format=HTML always
                                request.setAttribute("module",module);
                                RequestDispatcher dispatcher_view = request.getRequestDispatcher(module.GetViewPage() + "?preview=1&format=HTML");
                                out.println("<DIV class='txtd' " + nps.util.Utils.Null2Empty(style_txtd) + ">");
                                out.flush();
                                dispatcher_view.include(request, response);
                                out.flush();
                                out.println("</DIV>");
                                request.removeAttribute("module");
                            %>
                        </DIV>
                    </DIV>
    <%
            }

            out.println("</DIV>");
        }
    %>

</DIV>
</DIV>
</DIV>
</DIV>
</DIV>
</BODY>
</HTML>