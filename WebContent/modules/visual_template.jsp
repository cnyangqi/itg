<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.io.File" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="nps.core.Config" %>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.module.VisualTemplate" %>
<%@ page import="nps.module.VisualModule" %>
<%@ page import="nps.module.ModuleClassPool" %>
<%@ page import="nps.module.ModuleClass" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>

<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_visualtemplate",user.GetLocale(), Config.RES_CLASSLOADER);

    String id = request.getParameter("id");
    if(id==null || id.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

    Connection conn = null;
    VisualTemplate template = null;
    try
    {
        conn = Database.GetDatabase("nps").GetConnection();
        template = VisualTemplate.Load(conn,id);

        if(template==null) throw new NpsException("id="+id,ErrorHelper.SYS_NOVISUALTEMPLATE);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<HTML>
<HEAD>
    <TITLE><%=template.GetTitle()%></TITLE>
    <META content="text/html; charset=utf-8" http-equiv=Content-Type>
    <LINK rel=stylesheet type="text/css" href="/css/module_control.css">
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
    <SCRIPT type=text/javascript src="/jscript/jquery.dragsort.js"></SCRIPT>
    <SCRIPT type=text/javascript src="/jscript/moo.fx.js"></SCRIPT>
    <SCRIPT type=text/javascript src="/jscript/moo.fx.pack.js"></SCRIPT>
    <SCRIPT type=text/javascript src="/jscript/moo.fx.util.js"></SCRIPT>
    <SCRIPT type="text/javascript" src="/FCKeditor/fckeditor.js"></script>
    <SCRIPT type=text/javascript src="/jscript/modules.js"></SCRIPT>    
    <SCRIPT type=text/javascript src="/jscript/tabs.js"></SCRIPT>
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
    <SCRIPT language="javascript">
        function f_preview()
        {
            document.frm_preview.submit();
        }

        function f_delete()
        {
            var r=confirm('<%=bundle.getString("TEMPLATE_ALERT_DELETE")%>');
            if( r ==1 ) document.frm_delete.submit();
        }

        function toggleSavebar()
        {
            var savebar = $("savebar");
            if(savebar.style.display!="none")
            {
                $("menu_box").hide();
                savebar.hide();
            }
            else
            {
                var divs = $("menu_area").childElements();
                divs.each(function(ele) {ele.hide();});
                savebar.show();
                $("menu_box").show();
            }
        }

        function togglePublish()
        {
            var publishbar = $("publishbar");
            if(publishbar.style.display!="none")
            {
                $("menu_box").hide();
                publishbar.hide();
            }
            else
            {
                var divs = $("menu_area").childElements();
                divs.each(function(ele) {ele.hide();});
                publishbar.show();
                $("menu_box").show();
            }
        }
        
        function saveas_submit()
        {
            if(document.frm_saveas.title.value=="")
            {
                alert("<%=bundle.getString("TEMPLATE_ALERT_NONETITLE")%>");
                return false;
            }
            
            document.frm_saveas.submit();
        }

        function selectTopics()
        {
            var rc = popupDialog("/info/selectalltopics.jsp");
            if (rc == null || rc.length==0) return false;

            f_settopic(rc[0],rc[1],rc[2],rc[3]);
        }

        function f_settopic(siteid,sitename,topid,topname)
        {
            $('site_id').value= siteid;
            $('top_id').value = topid;
            $('topic').value = topname==""?sitename:topname+"("+sitename+")";
        }

        function popupDialog(url)
         {
            var isMSIE= (navigator.appName == "Microsoft Internet Explorer");  //判断浏览器

           if (isMSIE)
           {
               return window.showModalDialog(url);
           }
           else
           {
               var win = window.open(url, "mcePopup","dialog=yes,modal=yes" );
               win.focus();
           }
        }

        function onchange_publish(m)
        {
            var url = $("div_publish_url");
            var topic = $("div_publish_topic");
            if(m=="FCKTEMPLATE")
            {
                topic.hide();
                url.hide();
            }
            else if(m=="ARTICLE")
            {
                topic.show();
                url.hide();
            }
            else
            {
                topic.show();
                url.show();
            }
        }

        function f_viewpublish()
        {
            var pathbar = $("pathbar");
            if(pathbar.style.display!="none")
            {
                $("menu_box").hide();
                pathbar.hide();
            }
            else
            {
                var divs = $("menu_area").childElements();
                divs.each(function(ele) {ele.hide();});
                pathbar.show();
                $("menu_box").show();
                new Ajax.Updater({success:"pathbar"}, "/modules/load_path_vt.jsp", {method:"post",parameters:"id="+document.frm_saveas.template_id.value,evalScripts:true});
            }
        }

        function toggleTitle()
        {
            var title = $("template_title");
            var title_editor = $("template_title_editor");
            if(title.style.display!='none')
            {
                title.hide();
                title_editor.show();
                title_editor.focus();
            }
            else
            {
                if(title_editor.value=="")
                {
                    alert("<%=bundle.getString("TEMPLATE_ALERT_TITLE")%>");
                    return false;
                }
                title.innerText = title_editor.value;
                title_editor.hide();
                title.show();
            }
        }
    </SCRIPT>
</HEAD>

<BODY class=page>
<div id="header_wrap">
    <div id="header">
        <div id="title">
            <span id="template_title" title="Click to edit title" onclick="toggleTitle()"><%=template.GetTitle()%></span>
            <textarea id="template_title_editor" style="display:none" onblur="toggleTitle()"><%=template.GetTitle()%></textarea>
        </div>        
        &nbsp;&nbsp;&nbsp;&nbsp;
        <input name="previewBtn" type="button" onClick="f_preview()" value="<%=bundle.getString("TEMPLATE_PREVIEWBUTTON")%>" class="button">
        <input name="publishBtn" type="button" onClick="togglePublish()" value="<%=bundle.getString("TEMPLATE_PUBLISHBUTTON")%>" class="button">
        <input name="saveasBtn" type="button" onClick="toggleSavebar()" value="<%=bundle.getString("TEMPLATE_SAVEASBUTTON")%>" class="button">
        <input name="deleteBtn" type="button" onClick="f_delete()" value="<%=bundle.getString("TEMPLATE_DELETEBUTTON")%>" class="button">
        <input name="viewpublishBtn" type="button" onClick="f_viewpublish()" value="<%=bundle.getString("TEMPLATE_VIEWPUBLISHBUTTON")%>" class="button">
    </div>
    <div id=options>
        <%=bundle.getString("TEMPLATE_BACKGROUND")%>
        <input type="text" name="global_bgcolor" id="global_bgcolor" value="<%=Utils.Null2Empty(template.GetBackgroundColor())%>" size="25">
        <input name="saveBtn" type="button" value="<%=bundle.getString("TEMPLATE_SAVEBUTTON")%>" class="button" onclick="man.save_template();">
    </div>
</div>
<DIV id=container_wrap <% if(template.GetBackgroundColor()!=null) out.print("style=\"background:" + template.GetBackgroundColor() + ";\""); %>>
<DIV id=wrapper>
<DIV style="POSITION: fixed; DISPLAY: none" id=floating_menu class=floating_box>
    <DIV id=shadow>
        <UL class=addcaps>
            <LI><A href="javascript:void(0)" onclick="man.toggleSidebar()"><img src="/images/modules/max.png" title="<%=bundle.getString("TEMPLATE_MODULE_MAX")%>"></A></LI>
            <%
                List<ModuleClass> classes = ModuleClassPool.instance(conn).getAll();
                if(classes!=null)
                {
                    for(ModuleClass mod:classes)
                    {
                        out.print("<li>");
                        out.print("<a id=add" + mod.GetType() + "Mod");
                        out.print(" href=\"javascript:void(0)\"");
                        out.print(" onclick=\"man.addNew('"+ mod.GetType() + "'); return false;\"");
                        out.print(">");
                        out.print("<img src=\"" + mod.GetIcon() + "\" title=\"" + mod.GetDisplayType() + "\">");
                        out.print("</a>");
                        out.println("</li>");
                    }
                }
            %>
        </UL>
    </DIV>
</DIV>
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
                || (test_width==null && module.GetWidth()!=null)
                )
            {
                if(test_align!=-1)
                {
                    out.println("</DIV>");

                    if(align==VisualModule.FLOAT_RIGHT || "100%".equals(module.GetWidth()))
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
%>
            <%@ include file = "load_module_include.jsp" %>
<%
            out.println("</DIV>");
        }
    }
%>
</DIV>
<SCRIPT type=text/javascript>
    man = new ModuleManager('modules', '<%=template.GetId()%>', '<%=template.toJSONString()%>');
</SCRIPT>
</DIV>
</DIV>
<DIV id=sidebar style="display:none;position:absolute;top:20px;right:10px">
    <DIV id=addMoreStuff class=sidebar_box>
        <H3><%=bundle.getString("TEMPLATE_SIDEBAR_MODULES")%></H3>
        <UL class=addcaps>
            <%
                if(classes!=null)
                {
                    int total_modules = 0;
                    for(ModuleClass mod:classes)
                    {
                        out.println("<li>");
                        out.print("<a id=add" + mod.GetType() + "Mod2");
                        out.print(" href=\"javascript:void(0)\"");
                        out.print(" onclick=\"man.addNew('"+ mod.GetType() + "'); return false;\"");
                        out.println(">");
                        out.print("<img src=\"" + mod.GetIcon() + "\" title=\"" + mod.GetDisplayType() + "\">");
                        out.println(mod.GetDisplayType());
                        out.println("</a>");
                        out.println("</li>");

                        total_modules++;
                    }
    
                    if(total_modules%2==1) out.println("<li><a>&nbsp;</a></li>");
                }
            %>
        </UL>
    </DIV>
    <DIV class=sidebar_box>
        <H3><%=bundle.getString("TEMPLATE_SIDEBAR_MODULEORDER")%></H3>
        <%
            int reorder_canvas_height = 400;
            if(modules!=null) reorder_canvas_height = (modules.size()+2)*(25+10) + 70;
        %>
        <DIV style="HEIGHT: <%=reorder_canvas_height%>px" id=caps_reorder_canvas>
          <%
              if(modules!=null)
              {
                  int bar_top = 35;
                  for(VisualModule module:modules)
                  {
                      String bar_width = "130px";
                      switch(module.GetAlign())
                      {
                          case VisualModule.FLOAT_NONE:  //float: none
                              bar_width = "240px";
                              break;
                      }
          %>
                        <DIV style="Z-INDEX: <%=module.GetIndex()%>; LINE-HEIGHT: 25px; WIDTH: <%=bar_width%>; BACKGROUND: url(<%=module.GetIcon()%>) #e5e5e5 no-repeat 2px 50%; HEIGHT: 25px; TOP: <%=bar_top%>px"
                             id="<%=module.HTML_ReorderBar()%>" onselectstart="return false"
                             class=reorder_bar><B><%=module.GetDisplayType()%></B>: <%=Utils.Null2Empty(module.GetTitle())%>
                        </DIV>
            <%
                        bar_top += 25;

                        if(module.GetAlign()==VisualModule.FLOAT_NONE) bar_top += 20;
                    }
                }
            %>
            <SCRIPT type=text/javascript>
                man.reorder = new ModuleReorder('<%=template.GetId()%>');
                man.onmove = man.reorder.resetorder.bind(man.reorder);
             <%
              if(modules!=null)
              {
                  for(VisualModule module:modules)
                  {
                     out.print("man.reorder.add(new ReorderItem(");
                     out.print("\"" + module.HTML_ReorderBar() + "\",");
                     out.print("\"" + module.GetId() + "\",");
                     if(module.GetAlign()==VisualModule.FLOAT_NONE)
                         out.print("false");
                     else
                         out.print("true");
                     out.println("));");
                  }
               }
             %>

            </SCRIPT>
        </DIV>
        <INPUT onclick="man.reorder.save();return false;" value="<%=bundle.getString("TEMPLATE_SIDEBAR_REORDERBUTTON")%>" type=submit><BR><BR></DIV>
</DIV>
</DIV>
</DIV>
<DIV id=ajaxing>
    <DIV id=ajaxing_box><IMG src="/images/modules/spnr.gif"><SPAN>working</SPAN></DIV>
</DIV>
<DIV id=ajaxing_big><IMG src="/images/modules/loader.gif"></DIV>
</DIV>

<DIV id="menu_box" style="position:fixed;display:none">
    <div id="menu_area">
        <form name="frm_preview" action="preview_vt.jsp" method="get" target="_blank">
            <input type="hidden" name="id" value="<%=template.GetId()%>">
        </form>

        <form name="frm_delete" action="del_vt.jsp" method="post">
            <input type="hidden" name="template_id" value="<%=template.GetId()%>">
        </form>

        <DIV id="savebar" style="display:none">
            <form name="frm_saveas" method="post" action="save_vt.jsp">
                 <input type="hidden" name="template_id" value="<%=template.GetId()%>">
                 <div class="menu_title">
                    <%=bundle.getString("TEMPLATE_TITLE")%>
                    <input type="text" name="title" size="50" value="">
                 </div>
                 <div class="menu_button">
                    <input type="button" name="btn_saveassubmit" class="button" value="<%=bundle.getString("TEMPLATE_OKBUTTON")%>" onclick="saveas_submit()">
                    <input type="button" name="btn_saveascancel" class="button" value="<%=bundle.getString("TEMPLATE_CANCELBUTTON")%>" onclick="toggleSavebar()">
                 </div>    
            </form>
        </DIV>

        <DIV id="publishbar" style="display:none">
            <div class="menu_title">
                <%=bundle.getString("TEMPLATE_PUBLISHAS")%><font color=red>*</font>
                <select id="publishas" name="publishas" onchange="onchange_publish(this.options[this.options.selectedIndex].value)">
                    <option value="HTML"><%=bundle.getString("TEMPLATE_PUBLISH_HTML")%></option>
                    <option value="TEMPLATE"><%=bundle.getString("TEMPLATE_PUBLISH_TEMPLATE")%></option>
                    <option value="ARTICLE"><%=bundle.getString("TEMPLATE_PUBLISH_ARTICLE")%></option>
                    <option value="FCKTEMPLATE"><%=bundle.getString("TEMPLATE_PUBLISH_FCKTEMPLATE")%></option>
                </select>
                <span class="menu_hint"><%=bundle.getString("TEMPLATE_PUBLISH_HINT")%></span>
            </div>

            <div class="menu_title">
                <%=bundle.getString("TEMPLATE_FORMAT")%><font color=red>*</font>
                <select id="format" name="format">
                    <option value="HTML"><%=bundle.getString("TEMPLATE_FORMAT_HTML")%></option>
                    <option value="TEMPLATE"><%=bundle.getString("TEMPLATE_FORMAT_TEMPLATE")%></option>
                </select>
                <span class="menu_hint"><%=bundle.getString("TEMPLATE_FORMAT_HINT")%></span>
            </div>

            <div id="div_publish_topic" class="menu_title">
                <%=bundle.getString("TEMPLATE_TOPIC")%>
                <input type="hidden" id="site_id" name="site_id" value="">
                <input type="hidden" id="top_id" name="top_id" value="">
                <input type="text" id="topic" name="topic" value="" readonly onclick='selectTopics()'>
                <input type="button" value="<%=bundle.getString("TEMPLATE_TOPIC_SELECT")%>" class="button" name="btn_topic" onclick='selectTopics()'>
                <span class="menu_hint"><%=bundle.getString("TEMPLATE_TOPIC_HINT")%></span>
            </div>

            <div id="div_publish_url" class="menu_title">
                <%=bundle.getString("TEMPLATE_PATH")%>
                <input type="text" id="url" name="url" value="" size="50">
                <p class="menu_hint"><%=bundle.getString("TEMPLATE_PATH_HINT")%></p>
            </div>

            <div class="menu_button">
                <input type="button" name="btn_publishsubmit" class="button" value="<%=bundle.getString("TEMPLATE_OKBUTTON")%>" onclick="man.publish()">
                &nbsp;&nbsp;
                <input type="button" name="btn_publishcancel" class="button" value="<%=bundle.getString("TEMPLATE_CANCELBUTTON")%>" onclick="togglePublish()">
            </div>
         </DIV>

        <DIV id="pathbar" style="display:none">
        </DIV>
    </DIV>
</DIV>

<script language="javascript">
    Event.observe(window,'load',_floatMenu);
    Event.observe(window,'resize',_floatMenu);
</script>
</BODY>
</HTML>
<%
    }
    finally
    {
        if(conn!=null) try{conn.close();}catch(Exception e){}
    }
%>