<%@ page language = "java" contentType = "text/html;charset=UTF-8"%>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.module.tabs.*" %>
<%@ page import="nps.module.VisualModule" %>
<%@ page import="nps.module.ModuleClassPool" %>
<%@ page import="nps.module.ModuleClass" %>
<%@ page import="java.util.List" %>
<%@ page import="nps.util.Utils" %>

<%@ include file="/include/header.jsp" %>

<%
    VisualModule module = (VisualModule)request.getAttribute("module");
    ResourceBundle bundle_module = ResourceBundle.getBundle("langs.module_tabs",user.GetLocale(), Config.RES_CLASSLOADER);

    String suffix = request.getParameter("suffix");
    if(suffix==null || suffix.length()==0) suffix = module.GetId();

    Tabs tabs = new Tabs(suffix,module);
%>
<script type="text/javascript">
    onedit_<%=suffix%> = function() {
        tabseditor_<%=suffix%>.onedit();           
    }
    
    onsave_<%=suffix%> = function() {
        return tabseditor_<%=suffix%>.onsave();
    }

    ondiscard_<%=suffix%> = function() {
        tabseditor_<%=suffix%>.ondiscard();
    }

    addTab_<%=suffix%> = function()
    {
        var tab_title = $F('tabs_title_<%=suffix%>');
        if(tab_title=='') {
            alert('<%=bundle_module.getString("TABS_ALERT_NO_TITLE")%>');
            return false;
        }

        tabseditor_<%=suffix%>.addTab(tab_title);
    }
</script>

<input type="hidden" id="tabs_json_<%=suffix%>" name="tabs_json_<%=suffix%>" value="">

<div class="databar">
    <%=bundle_module.getString("TABS_MODE")%>
    <select id="tabs_mode_<%=suffix%>" name="tabs_mode_<%=suffix%>">
        <option value="0" <%=module.GetDataString("tabs_mode",suffix)==null||"0".equals(module.GetDataString("tabs_mode",suffix))?"selected":""%>><%=bundle_module.getString("TABS_MODE_ONMOUSEMOVE")%></option>
        <option value="1" <%="1".equals(module.GetDataString("tabs_mode",suffix))?"selected":""%>><%=bundle_module.getString("TABS_MODE_ONCLICK")%></option>
        <option value="2" <%="2".equals(module.GetDataString("tabs_mode",suffix))?"selected":""%>><%=bundle_module.getString("TABS_MODE_ONDBLCLICK")%></option>
    </select>

    &nbsp;&nbsp;
    <%=bundle_module.getString("TABS_TABBORDER")%>
    <input type="text" id="tabs_border_<%=suffix%>" name="tabs_border_<%=suffix%>" value="<%=Utils.NVL(module.GetDataString("tabs_border",suffix),"1px solid #b1c8d6")%>" style="width:160px;">
</div>
<div class="databar">
    <span style="float:left;width:50%">
        <%=bundle_module.getString("TABS_STYLE_NORMAL")%><br>
        <textarea id="style_normal_<%=suffix%>" name="style_normal_<%=suffix%>" rows=3 cols=8 style="width:98%"><%=Utils.NVL(module.GetDataString("style_normal",suffix),"padding: 0 20px;\ncolor: #1E50A2;\nbackground: #E5EEF7;\nborder: 1px solid #b1c8d6;")%></textarea>
    </span>
    <span style="float:left;width:50%">
        <%=bundle_module.getString("TABS_STYLE_FOCUS")%><br>
        <textarea id="style_focus_<%=suffix%>" name="style_focus_<%=suffix%>" rows=3 cols=8 style="width:98%"><%=Utils.NVL(module.GetDataString("style_focus",suffix),"font-weight: bold;\nbackground:white;")%></textarea>
    </span>
</div>

<div class="databar">
    <%=bundle_module.getString("TABS_ADDMODULE")%>
    <UL class="modulebar">
        <%
            List<ModuleClass> classes = ModuleClassPool.instance().getAll();
            if(classes!=null)
            {
                for(ModuleClass mod:classes)
                {
                    out.print("<li>");
                    out.print("<img src=\"" + mod.GetIcon() + "\" title=\"" + mod.GetDisplayType() + "\">");

                    out.print("<a href=\"javascript:void(0)\"");
                    out.print(" onclick=\"tabseditor_" + suffix + ".addModule('"+ mod.GetType() +"'); return false;\"");
                    out.print(">");
                    out.print(mod.GetDisplayType());
                    out.print("</a>");
                    out.println("</li>");
                }
            }
        %>
    </UL>
</div>

<div id="tabs_<%=suffix%>" class="databar">
   <div class="tabbar_new">
    <input type="text" id="tabs_title_<%=suffix%>" name="tabs_title_<%=suffix%>" size="25" style="width:80px">
    <img src="/images/modules/plus.gif" border="0" onclick="addTab_<%=suffix%>()" style="cursor:pointer">
   </div>
   <ul id="tabsnav_<%=suffix%>" class="tabbar">
<%
   if(!tabs.isEmpty())
   {
       Vector<Tab> list_tab = tabs.GetTabs();
       for(Tab tab:list_tab)
       {
%>
        <li id="<%=tab.GetId()%>">
           <span>
               <input type=text id="tab_title_<%=tab.GetId()%>" name="tab_title_<%=tab.GetId()%>" value="<%=module.GetDataString("tab_title",tab.GetId())%>" onclick="tabseditor_<%=suffix%>.selectById('<%=tab.GetId()%>');return false;">
           </span>
           <img src="/images/modules/cross.png" onclick="tabseditor_<%=suffix%>.removeById('<%=tab.GetId()%>');return false;"/>
        </li>
<%
       }
   }
%>
   </ul>

<%
    if(!tabs.isEmpty())
    {
        Vector<Tab> list_tab = tabs.GetTabs();
        for(Tab tab:list_tab)
        {
%>
    <div display="none" id="tab_<%=tab.GetId()%>" class=tab>
        <div id="tabslink_<%=tab.GetId()%>" class="linkbar">
            <%=bundle_module.getString("TABS_LINK")%>
            <input type="text" id="tab_link_<%=tab.GetId()%>" name="tab_link_<%=tab.GetId()%>" value="<%=Utils.Null2Empty(module.GetDataString("tab_link",tab.GetId()))%>" style="width: 160px">
            &nbsp;&nbsp;
            <%=bundle_module.getString("TABS_TARGET")%>
            <input type="text" id="tab_target_<%=tab.GetId()%>" name="tab_target_<%=tab.GetId()%>" value="<%=Utils.Null2Empty(module.GetDataString("tab_target",tab.GetId()))%>" style="width: 80px">
            &nbsp;&nbsp;
            <font color="red"><%=bundle_module.getString("TABS_TABHINT")%></font>
        </div>        
        <%
            if(!tab.isEmpty())
            {
                Vector<TabModule> modules = tab.GetModules();
                for(TabModule mod:modules)
                {
                    //Load edit.jsp
                    out.flush();
                    request.setAttribute("module",mod);
                    RequestDispatcher mod_loader = request.getRequestDispatcher("/modules/load_tab.jsp?tabs_id="+suffix+"&tab_id="+tab.GetId());
                    mod_loader.include(request, response);
                    request.removeAttribute("module");
                }
                request.setAttribute("module",module);
            }
        %>
    </div>
<%
        }
    }
%>
</div>

<script type="text/javascript">
    tabseditor_<%=suffix%> = new TabsEditor("<%=suffix%>",'<%=tabs.toJSONString()%>');
</script>