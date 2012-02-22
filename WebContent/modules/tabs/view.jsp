<%@ page language = "java" contentType = "text/html;charset=UTF-8"%>
<%@ page import="nps.module.VisualModule" %>
<%@ page import="nps.module.tabs.Tabs" %>
<%@ page import="nps.module.tabs.Tab" %>
<%@ page import="java.util.Vector" %>
<%@ page import="nps.module.tabs.TabModule" %>
<%
    out.clear();
    VisualModule module = (VisualModule)request.getAttribute("module");
    String suffix = request.getParameter("suffix");
    if(suffix==null || suffix.length()==0) suffix = module.GetId();

    String format = request.getParameter("format");
    String preview = request.getParameter("preview");

    Tabs tabs = new Tabs(suffix,module);
    if(tabs.isEmpty()) return;
    String style_normal = module.GetDataString("style_normal",suffix);
    String style_focus = module.GetDataString("style_focus",suffix);
%>
<div class="tabs">
<%
    if((style_normal!=null && style_normal.length()>0) || (style_focus!=null && style_focus.length()>0))
    {
        out.println("<STYLE TYPE='text/css'>");
        if(style_normal!=null && style_normal.length()>0)
        {
            out.println("#ntabs_" + tabs.GetId() + " .con {");
            out.println(style_normal);
            out.println("}");
        }

        if(style_focus!=null && style_focus.length()>0)
        {
            out.println("#ntabs_" + tabs.GetId() + " .current {");
            out.println(style_focus);
            out.println("}");
        }

        out.println("</STYLE>");
    }
%>
    <div id="ntabs_<%=tabs.GetId()%>" class="tabs_titlebar">
<%
    boolean bFirst = true;
    Vector<Tab> list_tab = tabs.GetTabs();
    for(Tab tab:list_tab)
    {
        String tab_title = module.GetDataString("tab_title",tab.GetId());
        String href = module.GetDataString("tab_link",tab.GetId());
        String target = module.GetDataString("tab_target",tab.GetId());
        String title = tab_title;
        if(href!=null && href.length()>0)
        {
            title = "<a href=\"" + href + "\"";
            if(target!=null && target.length()>0) title += " target=\"" + target + "\"";
            title += ">" + tab_title;
            title += "</a>";
        }

        out.print("<span tabid='" + tab.GetId() + "'");
        int switch_mode = 0;
        String s_switch_mode = module.GetDataString("tabs_mode",suffix);
        try{switch_mode = Integer.parseInt(s_switch_mode);}catch(Exception e){}
        switch(switch_mode)
        {
            case 1:
                out.print(" onclick='switch_tab(this);'");
                break;
            case 2:
                out.print(" ondblclick='switch_tab(this);'");
                break;
            default:
                out.print(" onmousemove='switch_tab(this);'");
        }
        out.print(" class=\"con");
        if(bFirst) out.print(" current");
        out.print("\"");
        out.print(">");
        out.print(title);
        out.print("</span>");
        bFirst = false;
    }
%>
    </div>

<%
    bFirst = true;
    String style_tab_border = module.GetDataString("tabs_border",suffix);
    for(Tab tab:list_tab)
    {
        if(!tab.isEmpty())
        {
            out.print("<div  tabid='" + tab.GetId() + "' class='tabs_tab");
            out.print(bFirst?" current":" normal");
            out.print("'");
            if(style_tab_border!=null && style_tab_border.length()>0) out.print(" style='border:" + style_tab_border + "'");
            out.println(">");

            Vector<TabModule> modules = tab.GetModules();
            int test_align = -1;
            String test_width = null;
            int size_modules = modules.size();
            for(int i=0;i<size_modules;i++)
            {
                TabModule mod = modules.get(i);
                int align = mod.GetAlign();
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
                    || (test_width!=null && mod.GetWidth()!=null && !test_width.equals(mod.GetWidth()))
                    || (test_width==null && mod.GetWidth()!=null))
                {
                    if(test_align!=-1)
                    {
                        out.println("</DIV>");
                        if (align==VisualModule.FLOAT_RIGHT || "100%".equals(mod.GetWidth()))
                        {
                           out.println("<div class=\"floatclear\"></div>");
                        }
                    }

                    out.print("<DIV class=\"modfloat " + modfloat + "\"");

                    String style_width = null;
                    if(mod.GetWidth()!=null && mod.GetWidth().length()>0)
                    {
                        style_width = "width:" + mod.GetWidth() + ";";
                    }

                    String style_display = "display:inline-block;";
                    if(mod.GetAlign()==VisualModule.FLOAT_NONE)
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
            test_width = mod.GetWidth();

            String style_backgroundcolor = null;
            if(mod.GetBackgroundColor()!=null && mod.GetBackgroundColor().length()>0)
            {
                style_backgroundcolor = "background:" + mod.GetBackgroundColor() + ";";
            }

            String style_height = null;
            if(mod.GetHeight()!=null && mod.GetHeight().length()>0)
            {
                style_height = "height:" + mod.GetHeight() + ";";
            }

            String style_overflow = null;
            if(mod.GetOverflow()!=null && mod.GetOverflow().length()>0)
            {
                style_overflow = "overflow:" + mod.GetOverflow() + ";";
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
            if(mod.GetTextAlign()!=null && mod.GetTextAlign().length()>0)
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
                        <DIV class="module" <%=nps.util.Utils.Null2Empty(style_module)%>>
                            <%
                                if(mod.GetDisplayTitle() && !mod.IsNullTitle())
                                {
                                    out.print("<H2>");
                                    out.print(mod.GetTitle());
                                    out.println("</H2>");
                                }
                                //Load view.jsp, format=HTML always
                                request.setAttribute("module",mod);

                                String params = "?format="+nps.util.Utils.Null2Empty(format);
                                if(preview!=null) params += "&preview=" + preview;
                                RequestDispatcher dispatcher_view = request.getRequestDispatcher(mod.GetViewPage() + params);

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
            out.println("</div>");
            request.setAttribute("module",module);
        }
        bFirst = false;
    }
%>
</div>