<%@ page language = "java" contentType = "text/html;charset=UTF-8"%>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.module.VisualModule" %>
<%@ page import="nps.core.Config" %>
<%@ page import="nps.util.Utils" %>

<%@ include file="/include/header.jsp" %>

<%
    VisualModule module = (VisualModule)request.getAttribute("module");
    ResourceBundle bundle_module = ResourceBundle.getBundle("langs.module_include",user.GetLocale(), Config.RES_CLASSLOADER);

    String suffix = request.getParameter("suffix");
    if(suffix==null || suffix.length()==0) suffix = module.GetId();
%>
<script type="text/javascript">
    onsave_<%=suffix%> = function() {
        var url = $F('ssi_url_<%=suffix%>');
        if(url=='') {
            alert("<%=bundle_module.getString("INCLUDE_ALERT_NO_URL")%>");
            return false;
        } else{
            url = url.toLowerCase();
            if(url.startsWith('http://') || url.startsWith('https://')) {
                alert("<%=bundle_module.getString("INCLUDE_ALERT_INVALID_URL")%>");
                return false;
            }
        }
        return true;
    }

    url_onchange_<%=suffix%> = function(u) {
        $("ssi_hint_<%=suffix%>").innerText = '<!--#include virtual="'+u+'"-->';
    }
</script>

<div class="databar">
    <%=bundle_module.getString("INCLUDE_URL")%><font color=red>*</font>
    <input type="text" id="ssi_url_<%=suffix%>" name="ssi_url_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("ssi_url",suffix))%>" style="width:400px" onchange="url_onchange_<%=suffix%>(this.value)">
    <br>
    <span id="ssi_hint_<%=suffix%>" style="color:red;padding-left:85px;">
    <%
        if(module.GetDataString("ssi_url",suffix)!=null)
        {
    %>
        &lt;!--#include virtual="<%=module.GetDataString("ssi_url",suffix)%>"--&gt;
    <%
        }
    %>
    </span>
</div>
<div class="databar">
    <%=bundle_module.getString("INCLUDE_BASE_URL")%>
    <input type="text" id="ssi_base_url_<%=suffix%>" name="ssi_base_url_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("ssi_base_url",suffix))%>" style="width:160px">
    &nbsp;&nbsp;
    <font color="red"><%=bundle_module.getString("INCLUDE_BASE_URL_HINT")%></font>
</div>
