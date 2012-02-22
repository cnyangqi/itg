<%@ page language = "java" contentType = "text/html;charset=UTF-8"%>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.module.VisualModule" %>
<%@ page import="nps.core.Config" %>
<%@ page import="nps.util.Utils" %>

<%@ include file="/include/header.jsp" %>

<%
    VisualModule module = (VisualModule)request.getAttribute("module");
    ResourceBundle bundle_module = ResourceBundle.getBundle("langs.module_video",user.GetLocale(), Config.RES_CLASSLOADER);

    String suffix = request.getParameter("suffix");
    if(suffix==null || suffix.length()==0) suffix = module.GetId();
    
%>
<script type="text/javascript">
    onedit_<%=suffix%> = function() {
        source_onchange_<%=suffix%>($F('source_<%=suffix%>'));
        var effect = $F('effect_<%=suffix%>');
        effect_onchange_<%=suffix%>(effect);
        if(effect=="MARQUEE") {
            if(video_marquee_<%=suffix%>) video_marquee_<%=suffix%>.stop();
        } else if(effect="FLOAT") {
            if(ad_<%=suffix%>) ad_<%=suffix%>.stop(); 
        }
    }

    onsave_<%=suffix%> = function() {
        var source = $F('source_<%=suffix%>');
        if(source=="") {
            if($F('url_<%=suffix%>')=="") {
                alert('<%=bundle_module.getString("VIDEO_ALERT_NONE_URL")%>');
                return false;
            }
        } else {
            var rows = $F('rows_<%=suffix%>');
            if(rows=="") {
                alert('<%=bundle_module.getString("VIDEO_ALERT_NONE_ROWS")%>');
                return false;
            }
            if(source=="SQL") {
                var sql = $F('sql_<%=suffix%>');
                if(sql=="") {
                    alert('<%=bundle_module.getString("VIDEO_ALERT_NONE_SQL")%>');
                    return false;
                }
            }else {
                var topic = $F('top_id_<%=suffix%>');
                if(topic=="") {
                    alert('<%=bundle_module.getString("VIDEO_ALERT_NONE_TOPIC")%>');
                    return false;
                }
            }
        }
        alert("ok");
        return true;
    }

    ondiscard_<%=suffix%> = function() {
        var effect = $F('effect_<%=suffix%>');
        if(effect=="MARQUEE") {
            if(video_marquee_<%=suffix%>) video_marquee_<%=suffix%>.start();
        } else if(effect="FLOAT") {
            if(ad_<%=suffix%>) ad_<%=suffix%>.start();
        }
    }

    source_onchange_<%=suffix%> = function(e) {
        if(e=="") {
           $('source_topic_<%=suffix%>').hide();
           $('source_sql_<%=suffix%>').hide();
           $('source_rows_<%=suffix%>').hide();
           $('source_manual_<%=suffix%>').show();
        } else if(e=="SQL") {
            $('source_manual_<%=suffix%>').hide();
            $('source_topic_<%=suffix%>').hide();
            $('source_rows_<%=suffix%>').show();
            $('source_sql_<%=suffix%>').show();
        } else if(e=="RESOURCE") {
            $('source_manual_<%=suffix%>').hide();
            $('source_sql_<%=suffix%>').hide();
            $('source_rows_<%=suffix%>').show();
            $('source_topic_<%=suffix%>').show();
        }
    }

    effect_onchange_<%=suffix%> = function(e) {
       if(e=="MARQUEE") {
          $('float_<%=suffix%>').hide();
          $('marquee_<%=suffix%>').show();
      } else if(e=="FLOAT") {
          $('marquee_<%=suffix%>').hide();
          $('float_<%=suffix%>').show();
       } else {
          $('marquee_<%=suffix%>').hide();
          $('float_<%=suffix%>').hide();
       }
    }

    floatmode_onchange_<%=suffix%> = function(e) {
        if(e=="FLOAT") {
            $('float_side_<%=suffix%>').style.display = "inline";
            if($F('float_side_<%=suffix%>')=='LEFT') {
                $('span_lr_<%=suffix%>').innerText = '<%=bundle_module.getString("VIDEO_FLOAT_LEFT")%>';
            } else
            {
                $('span_lr_<%=suffix%>').innerText = '<%=bundle_module.getString("VIDEO_FLOAT_RIGHT")%>';
            }
        } else {
            $('float_side_<%=suffix%>').style.display = "none";
            $('span_lr_<%=suffix%>').innerText = '<%=bundle_module.getString("VIDEO_FLOAT_LEFT")%>';
        }
    }

    floatside_onchange_<%=suffix%> = function(e) {
        if(e=='LEFT') {
            $('span_lr_<%=suffix%>').innerText = '<%=bundle_module.getString("VIDEO_FLOAT_LEFT")%>';
        } else
        {
            $('span_lr_<%=suffix%>').innerText = '<%=bundle_module.getString("VIDEO_FLOAT_RIGHT")%>';
        }
    }
    
    popupDialog = function(url)
    {
        var isMSIE= (navigator.appName == "Microsoft Internet Explorer");

        if (isMSIE)
        {
            return window.showModalDialog(url,"","resizable=yes; scroll=yes;");
        }
        else
        {
            var win = window.open(url, "mcePopup","dialog=yes,modal=yes" );
            win.focus();
        }
    }

    selecttopic_<%=suffix%> = function(e) {
        var rc = popupDialog("/info/selectalltopics.jsp");
        if (rc == null || rc.length==0) return false;

        settopic_<%=suffix%>(rc[0],rc[1],rc[2],rc[3]);
    }

    settopic_<%=suffix%> = function(siteid,sitename,topid,topname)
    {
        $('site_id_<%=suffix%>').value= siteid;
        $('top_id_<%=suffix%>').value = topid;
        $('topic_<%=suffix%>').value = topname==""?sitename:topname+"("+sitename+")";
    }
</script>

<div class="effectbar">
    <%=bundle_module.getString("VIDEO_DATASOURCE")%>
    <select id="source_<%=suffix%>" name="source_<%=suffix%>" onchange="source_onchange_<%=suffix%>(this.options[this.options.selectedIndex].value)">
        <option value="" <%=module.GetDataString("source",suffix)==null || "".equals(module.GetDataString("source",suffix))?"selected":""%>><%=bundle_module.getString("VIDEO_SOURCE_MANUAL")%></option>
        <option value="RESOURCE" <%="RESOURCE".equals(module.GetDataString("source",suffix))?"selected":""%>><%=bundle_module.getString("VIDEO_SOURCE_RESOURCE")%></option>
        <option value="SQL" <%="SQL".equals(module.GetDataString("source",suffix))?"selected":""%>><%=bundle_module.getString("VIDEO_SOURCE_SQL")%></option>
    </select>

    &nbsp;&nbsp;
    <%=bundle_module.getString("VIDEO_EFFECT")%>
    <select id="effect_<%=suffix%>" name="effect_<%=suffix%>" onchange="effect_onchange_<%=suffix%>(this.options[this.options.selectedIndex].value)">
        <option value="" <%=module.GetDataString("effect",suffix)==null || "".equals(module.GetDataString("effect",suffix))?"selected":""%>><%=bundle_module.getString("VIDEO_EFFECT_NONE")%></option>
        <option value="MARQUEE" <%="MARQUEE".equals(module.GetDataString("effect",suffix))?"selected":""%>><%=bundle_module.getString("VIDEO_EFFECT_MARQUEE")%></option>
        <option value="FLOAT" <%="FLOAT".equals(module.GetDataString("effect",suffix))?"selected":""%>><%=bundle_module.getString("VIDEO_EFFECT_FLOAT")%></option>
    </select>
    
    <span id="source_rows_<%=suffix%>" style="display:<%=module.GetDataString("source",suffix)!=null && !"".equals(module.GetDataString("source",suffix))?"block":"none"%>">
         &nbsp;&nbsp;
         <%=bundle_module.getString("VIDEO_ROWS")%><font color="red">*</font>
         <input type="text" id="rows_<%=suffix%>" name="rows_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("rows",suffix))%>" style="width:40px">
         &nbsp;&nbsp;
         <%=bundle_module.getString("VIDEO_START")%>
        <input type="text" id="start_<%=suffix%>" name="start_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("start",suffix))%>" style="width:40px">
    </span>
</div>

<table class="effect_table" id="marquee_<%=suffix%>" style="display:<%="MARQUEE".equals(module.GetDataString("effect",suffix))?"block":"none"%>">
    <tr>
        <td><%=bundle_module.getString("VIDEO_MARQUEE_DIRECT")%>
            <select id="marquee_direct_<%=suffix%>" name="marquee_direct_<%=suffix%>">
                <option value="0" <%="0".equals(module.GetDataString("marquee_direct",suffix))?"selected":""%>><%=bundle_module.getString("VIDEO_MARQUEE_DIRECT_UP")%></option>
                <option value="1" <%="1".equals(module.GetDataString("marquee_direct",suffix))?"selected":""%>><%=bundle_module.getString("VIDEO_MARQUEE_DIRECT_DOWN")%></option>
                <option value="2" <%="2".equals(module.GetDataString("marquee_direct",suffix))?"selected":""%>><%=bundle_module.getString("VIDEO_MARQUEE_DIRECT_LEFT")%></option>
                <option value="3" <%="3".equals(module.GetDataString("marquee_direct",suffix))?"selected":""%>><%=bundle_module.getString("VIDEO_MARQUEE_DIRECT_RIGHT")%></option>
            </select>
        </td>
        <td><%=bundle_module.getString("VIDEO_MARQUEE_TIMER")%>
            <input type="text" id="marquee_timer_<%=suffix%>" name="marquee_timer_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_timer",suffix))%>" width="5">ms
        </td>
        <td><%=bundle_module.getString("VIDEO_MARQUEE_STEP")%>
            <input type="text" id="marquee_step_<%=suffix%>" name="marquee_step_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_step",suffix))%>">
        </td>
        <td><%=bundle_module.getString("VIDEO_MARQUEE_WAITTIME")%>
            <input type="text" id="marquee_waittime_<%=suffix%>" name="marquee_waittime_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_waittime",suffix))%>" width="5">ms
        </td>
    </tr>
    <tr>
        <td><%=bundle_module.getString("VIDEO_MARQUEE_WIDTH")%>
            <input type="text" id="marquee_width_<%=suffix%>" name="marquee_width_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_width",suffix))%>" width="5">px
        </td>
        <td><%=bundle_module.getString("VIDEO_MARQUEE_HEIGHT")%>
            <input type="text" id="marquee_height_<%=suffix%>" name="marquee_height_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_height",suffix))%>" width="5">px
        </td>
        <td><%=bundle_module.getString("VIDEO_MARQUEE_DELAYTIME")%>
            <input type="text" id="marquee_delaytime_<%=suffix%>" name="marquee_delaytime_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_delaytime",suffix))%>" width="5">ms
        </td>
        <td><%=bundle_module.getString("VIDEO_MARQUEE_SCROLLSTEP")%>
            <input type="text" id="marquee_scrollstep_<%=suffix%>" name="marquee_scrollstep_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_scrollstep",suffix))%>">
        </td>
    </tr>
</table>

<table class="effect_table" id="float_<%=suffix%>" style="display:<%="FLOAT".equals(module.GetDataString("effect",suffix))?"block":"none"%>">
    <tr>
        <td>
            <%=bundle_module.getString("VIDEO_FLOAT_MODE")%>
            <select id="float_mode_<%=suffix%>" name="float_mode_<%=suffix%>" onchange="floatmode_onchange_<%=suffix%>(this.options[this.options.selectedIndex].value)">
                <option value="FLOAT" <%="FLOAT".equals(module.GetDataString("float_mode",suffix))?"selected":""%>><%=bundle_module.getString("VIDEO_FLOAT_MODE_SIDE")%></option>
                <option value="MOVE" <%="MOVE".equals(module.GetDataString("float_mode",suffix))||module.GetDataString("float_mode",suffix)==null?"selected":""%>><%=bundle_module.getString("VIDEO_FLOAT_MODE_MOVE")%></option>
            </select>
            <select id="float_side_<%=suffix%>" name="float_side_<%=suffix%>" style="display:<%="FLOAT".equals(module.GetDataString("float_mode",suffix))?"inline":"none"%>" onchange="floatside_onchange_<%=suffix%>(this.options[this.options.selectedIndex].value)">
                <option value="LEFT" <%="LEFT".equals(module.GetDataString("float_side",suffix))?"selected":""%>><%=bundle_module.getString("VIDEO_FLOAT_SIDE_LEFT")%></option>
                <option value="RIGHT" <%="RIGHT".equals(module.GetDataString("float_side",suffix))?"selected":""%>><%=bundle_module.getString("VIDEO_FLOAT_SIDE_RIGHT")%></option>
            </select>
            &nbsp;&nbsp;
            <span id="span_lr_<%=suffix%>"><%="FLOAT".equals(module.GetDataString("float_mode",suffix)) && "RIGHT".equals(module.GetDataString("float_side",suffix))?bundle_module.getString("VIDEO_FLOAT_RIGHT"):bundle_module.getString("VIDEO_FLOAT_LEFT")%></span>
            <input type="text" id="float_left_<%=suffix%>" name="float_left_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("float_left",suffix))%>" width="5">px
            &nbsp;&nbsp;
            <%=bundle_module.getString("VIDEO_FLOAT_TOP")%>
            <input type="text" id="float_top_<%=suffix%>" name="float_top_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("float_top",suffix))%>" width="5">px
            &nbsp;&nbsp;
            <%=bundle_module.getString("VIDEO_FLOAT_DELAY")%>
            <input type="text" id="float_delay_<%=suffix%>" name="float_delay_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("float_delay",suffix))%>" width="5">ms
        </td>
    </tr>
</table>

<div class="databar">
    <%=bundle_module.getString("VIDEO_PLAYER")%>
    <select id="player_<%=suffix%>" name="player_<%=suffix%>">
        <option value="WM" <%="WM".equals(module.GetDataString("player",suffix))?"selected":""%>><%=bundle_module.getString("VIDEO_PLAYER_WINDOWSMEDIA")%></option>
        <option value="RM" <%="RM".equals(module.GetDataString("player",suffix))?"selected":""%>><%=bundle_module.getString("VIDEO_PLAYER_REALPLAY")%></option>
        <option value="QT" <%="QT".equals(module.GetDataString("player",suffix))?"selected":""%>><%=bundle_module.getString("VIDEO_PLAYER_QUICKTIME")%></option>
        <option value="FLASH" <%="FLASH".equals(module.GetDataString("player",suffix))?"selected":""%>><%=bundle_module.getString("VIDEO_PLAYER_FLASH")%></option>
        <option value="SW" <%="SW".equals(module.GetDataString("player",suffix))?"selected":""%>><%=bundle_module.getString("VIDEO_PLAYER_SHOCKWAVE")%></option>
    </select>

    &nbsp;&nbsp;
    <%=bundle_module.getString("VIDEO_WIDTH")%>
    <input type="text" id="video_width_<%=suffix%>" name="video_width_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("video_width",suffix))%>" style="width:40px">px
    &nbsp;&nbsp;
    <%=bundle_module.getString("VIDEO_HEIGHT")%>
    <input type="text" id="video_height_<%=suffix%>" name="video_height_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("video_height",suffix))%>" style="width:40px">px
    &nbsp;&nbsp;
    <input type="checkbox" id="autoplay_<%=suffix%>" name="autoplay_<%=suffix%>" <%="1".equals(module.GetDataString("autoplay",suffix))?"checked=true":""%>" value="1">
    <%=bundle_module.getString("VIDEO_AUTOPLAY")%>
    &nbsp;&nbsp;
    <input type="checkbox" id="loop_<%=suffix%>" name="loop_<%=suffix%>" <%="1".equals(module.GetDataString("loop",suffix))?"checked=true":""%>" value="1">
    <%=bundle_module.getString("VIDEO_LOOP")%>
</div>

<div id="source_manual_<%=suffix%>" class="databar" style="display:none">
    <%=bundle_module.getString("VIDEO_URL")%><font color="red">*</font>
    <input type="text" id="url_<%=suffix%>" name="url_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("url",suffix))%>" style="width:75%">
</div>

<div id="source_topic_<%=suffix%>" class="databar" style="display:none">
    <%=bundle_module.getString("VIDEO_TOPIC")%><font color="red">*</font>
    <input type="hidden" id="site_id_<%=suffix%>" name="site_id_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("site_id",suffix))%>">
    <input type="hidden" id="top_id_<%=suffix%>" name="top_id_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("top_id",suffix))%>">
    <input type="text" id="topic_<%=suffix%>" name="topic_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("topic",suffix))%>" readonly onclick='selecttopic_<%=suffix%>()' size="25">
    <input type="button" value="<%=bundle_module.getString("VIDEO_TOPIC_SELECT")%>" class="button" onclick='selecttopic_<%=suffix%>()'>
</div>

<div id="source_sql_<%=suffix%>" class="databar" style="display:none">
    <p><%=bundle_module.getString("VIDEO_SQL")%><font color="red">*</font></p>
    <textarea rows="3" cols="5" id="sql_<%=suffix%>" name="sql_<%=suffix%>" style="width:100%"><%=Utils.Null2Empty(module.GetDataString("sql",suffix))%></textarea>
</div>