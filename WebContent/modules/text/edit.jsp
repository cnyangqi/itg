<%@ page language = "java" contentType = "text/html;charset=UTF-8"%>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.module.VisualModule" %>
<%@ page import="nps.core.Config" %>
<%@ page import="nps.util.Utils" %>

<%@ include file="/include/header.jsp" %>

<%
    VisualModule module = (VisualModule)request.getAttribute("module");
    ResourceBundle bundle_module = ResourceBundle.getBundle("langs.module_text",user.GetLocale(), Config.RES_CLASSLOADER);

    String suffix = request.getParameter("suffix");
    if(suffix==null || suffix.length()==0) suffix = module.GetId();
%>
<script type="text/javascript">
    onedit_<%=suffix%> = function() {
        var effect = $F('effect_<%=suffix%>');
        if(effect=="MARQUEE") {
            if(text_marquee_<%=suffix%>) text_marquee_<%=suffix%>.stop();
        }
        effect_onchange_<%=suffix%>(effect);
        var oEditor = new FCKeditor( 'content_<%=suffix%>' ) ;
        oEditor.BasePath = "/FCKeditor/";
        oEditor.Width = '100%' ;
        oEditor.Height = '350px' ;
        oEditor.ToolbarSet = "Basic";
        oEditor.ReplaceTextarea();
    }

    onsave_<%=suffix%> = function() {
        var editor = FCKeditorAPI.GetInstance('content_<%=suffix%>') ;
        var textarea = $('content_<%=suffix%>');
        var configElement = $('content_<%=suffix%>'+'___Config');
        var frameElement = $('content_<%=suffix%>'+'___Frame');
        if (editor!=null && configElement && frameElement && configElement.parentNode==textarea.parentNode && frameElement.parentNode==textarea.parentNode && document.removeChild)
        {
           textarea.value = editor.GetXHTML(true);
           editor.UpdateLinkedField();
           configElement.parentNode.removeChild(configElement);
           frameElement.parentNode.removeChild(frameElement);
           textarea.style.display = '';
           delete FCKeditorAPI.__Instances['content_<%=suffix%>'];
           delete editor;
        }

        return true;
    }

    ondiscard_<%=suffix%> = function() {
        var editor = FCKeditorAPI.GetInstance('content_<%=suffix%>') ;
        var textarea = $("content_<%=suffix%>");
        var configElement = $('content_<%=suffix%>'+'___Config');
        var frameElement = $('content_<%=suffix%>'+'___Frame');
        if (editor!=null && configElement && frameElement && configElement.parentNode==textarea.parentNode && frameElement.parentNode==textarea.parentNode && document.removeChild)
        {
           editor.UpdateLinkedField();
           configElement.parentNode.removeChild(configElement);
           frameElement.parentNode.removeChild(frameElement);
           textarea.style.display = '';
           delete FCKeditorAPI.__Instances['content_<%=suffix%>'];
           delete editor;
        }

        var effect = $F('effect_<%=suffix%>');
        if(effect=="MARQUEE") {
            if(text_marquee_<%=suffix%>) text_marquee_<%=suffix%>.start();
        }        
    }

    effect_onchange_<%=suffix%> = function(e) {
       if(e=="MARQUEE") {
          $('marquee_<%=suffix%>').show();
       } else {
          $('marquee_<%=suffix%>').hide();
       }
    }
</script>

<div class="effectbar">
    <%=bundle_module.getString("TEXT_EFFECT")%>
    <select id="effect_<%=suffix%>" name="effect_<%=suffix%>" onchange="effect_onchange_<%=suffix%>(this.options[this.options.selectedIndex].value)">
        <option value="" <%=module.GetDataString("effect",suffix)==null || "".equals(module.GetDataString("effect",suffix))?"selected":""%>><%=bundle_module.getString("TEXT_EFFECT_NONE")%></option>
        <option value="MARQUEE" <%="MARQUEE".equals(module.GetDataString("effect",suffix))?"selected":""%>><%=bundle_module.getString("TEXT_EFFECT_MARQUEE")%></option>
    </select>
</div>

<table class="effect_table" id="marquee_<%=suffix%>" style="display:<%="MARQUEE".equals(module.GetDataString("effect",suffix))?"block":"none"%>">
    <tr>
        <td><%=bundle_module.getString("TEXT_MARQUEE_DIRECT")%>
            <select id="marquee_direct_<%=suffix%>" name="marquee_direct_<%=suffix%>">
                <option value="0" <%="0".equals(module.GetDataString("marquee_direct",suffix))?"selected":""%>><%=bundle_module.getString("TEXT_MARQUEE_DIRECT_UP")%></option>
                <option value="1" <%="1".equals(module.GetDataString("marquee_direct",suffix))?"selected":""%>><%=bundle_module.getString("TEXT_MARQUEE_DIRECT_DOWN")%></option>
                <option value="2" <%="2".equals(module.GetDataString("marquee_direct",suffix))?"selected":""%>><%=bundle_module.getString("TEXT_MARQUEE_DIRECT_LEFT")%></option>
                <option value="3" <%="3".equals(module.GetDataString("marquee_direct",suffix))?"selected":""%>><%=bundle_module.getString("TEXT_MARQUEE_DIRECT_RIGHT")%></option>
            </select>
        </td>
        <td><%=bundle_module.getString("TEXT_MARQUEE_TIMER")%>
            <input type="text" id="marquee_timer_<%=suffix%>" name="marquee_timer_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_timer",suffix))%>" width="5">ms
        </td>
        <td><%=bundle_module.getString("TEXT_MARQUEE_STEP")%>
            <input type="text" id="marquee_step_<%=suffix%>" name="marquee_step_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_step",suffix))%>">
        </td>
        <td><%=bundle_module.getString("TEXT_MARQUEE_WAITTIME")%>
            <input type="text" id="marquee_waittime_<%=suffix%>" name="marquee_waittime_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_waittime",suffix))%>" width="5">ms
        </td>
    </tr>
    <tr>
        <td><%=bundle_module.getString("TEXT_MARQUEE_WIDTH")%>
            <input type="text" id="marquee_width_<%=suffix%>" name="marquee_width_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_width",suffix))%>" width="5">px
        </td>
        <td><%=bundle_module.getString("TEXT_MARQUEE_HEIGHT")%>
            <input type="text" id="marquee_height_<%=suffix%>" name="marquee_height_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_height",suffix))%>" width="5">px
        </td>
        <td><%=bundle_module.getString("TEXT_MARQUEE_DELAYTIME")%>
            <input type="text" id="marquee_delaytime_<%=suffix%>" name="marquee_delaytime_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_delaytime",suffix))%>" width="5">ms
        </td>
        <td><%=bundle_module.getString("TEXT_MARQUEE_SCROLLSTEP")%>
            <input type="text" id="marquee_scrollstep_<%=suffix%>" name="marquee_scrollstep_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_scrollstep",suffix))%>">
        </td>
    </tr>
</table>

<textarea id="content_<%=suffix%>" name="content_<%=suffix%>" rows="10" cols="50"><%=Utils.Null2Empty(module.GetDataString("content",suffix))%></textarea>