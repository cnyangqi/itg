<%@ page language = "java" contentType = "text/html;charset=UTF-8"%>
<%@ page import="nps.module.VisualModule" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.Config" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="org.json.JSONArray" %>

<%@ include file="/include/header.jsp" %>

<%
    out.clear();
    VisualModule module = (VisualModule)request.getAttribute("module");
    ResourceBundle bundle_module = ResourceBundle.getBundle("langs.module_link",user.GetLocale(), Config.RES_CLASSLOADER);

    String suffix = request.getParameter("suffix");
    if(suffix==null || suffix.length()==0) suffix = module.GetId();
%>
<script type="text/javascript">
    onedit_<%=suffix%> = function() {
        source_onchange_<%=suffix%>($F('source_<%=suffix%>'));
        image_onchange_<%=suffix%>($F('image_<%=suffix%>'));
        var effect = $F('effect_<%=suffix%>');
        effect_onchange_<%=suffix%>(effect);
        if(effect=="MARQUEE") {
            if(link_marquee_<%=suffix%>) link_marquee_<%=suffix%>.stop();
        }
    }

    onsave_<%=suffix%> = function() {
        var source = $F('source_<%=suffix%>');
        if(source=="") {
            var table = $('link_editor_<%=suffix%>');
            if(table.rows.length==1) {
                alert('<%=bundle_module.getString("LINK_ALERT_NONE_DATA")%>');
                return false;
            }
        } else {
            var rows = $F('rows_<%=suffix%>');
            if(rows=="") {
                alert('<%=bundle_module.getString("LINK_ALERT_NONE_ROWS")%>');
                return false;
            }
            if(source=="SQL") {
                var sql = $F('sql_<%=suffix%>');
                if(sql=="") {
                    alert('<%=bundle_module.getString("LINK_ALERT_NONE_SQL")%>');
                    return false;
                }
            }else {
                var topic = $F('top_id_<%=suffix%>');
                if(topic=="") {
                    alert('<%=bundle_module.getString("LINK_ALERT_NONE_TOPIC")%>');
                    return false;
                }
            }
            if(source=="CUSTOMTOPIC" || source=="SQL") {
                var field_url = $F('field_url_<%=suffix%>');
                if(field_url=="") {
                    alert('<%=bundle_module.getString("LINK_ALERT_NONE_FIELD_URL")%>');
                    return false;
                }
                if($F('source_<%=suffix%>')){
                    var field_image = $F('field_image_<%=suffix%>');
                    if(field_image=="") {
                        alert('<%=bundle_module.getString("LINK_ALERT_NONE_FIELD_IMAGE")%>');
                        return false;
                    }
                }
                if($F('date_<%=suffix%>')) {
                    var field_date = $F('field_date_<%=suffix%>');
                    if(field_date=="") {
                        alert("<%=bundle_module.getString("LINK_ALERT_NONE_FIELD_DATE")%>");
                        return false;
                    }
                }
            }

            var table = $('link_editor_<%=suffix%>');
            var rowCount = table.rows.length;
            if( rowCount>1 ) {
                for(var i=rowCount-1; i>=1; i--) {
                    table.deleteRow(i);
                }
            }
        }

        return true;
    }

    ondiscard_<%=suffix%> = function() {
        var effect = $F('effect_<%=suffix%>');
        if(effect=="MARQUEE") {
            if(link_marquee_<%=suffix%>) link_marquee_<%=suffix%>.start();
        }
    }

    effect_onchange_<%=suffix%> = function(e) {
       if(e=="MARQUEE") {
          $('marquee_<%=suffix%>').show();
       } else {
          $('marquee_<%=suffix%>').hide();
       }
    }

    source_onchange_<%=suffix%> = function(e) {
        if(e=="") {
           $('source_topic_<%=suffix%>').hide();
           $('source_field_<%=suffix%>').hide();
           $('source_sql_<%=suffix%>').hide();
           $('source_rows_<%=suffix%>').hide();
           $('source_manual_<%=suffix%>').show();
        } else if(e=="SQL") {
            $('source_manual_<%=suffix%>').hide();
            $('source_topic_<%=suffix%>').hide();
            $('source_rows_<%=suffix%>').show();
            $('source_sql_<%=suffix%>').show();
            $('source_field_<%=suffix%>').show();
        } else if(e=="ARTICLE" || e=="RESOURCE") {
            $('source_manual_<%=suffix%>').hide();
            $('source_sql_<%=suffix%>').hide();
            $('source_field_<%=suffix%>').hide();
            $('source_rows_<%=suffix%>').show();
            $('source_topic_<%=suffix%>').show();
        } else if (e=="CUSTOMTOPIC") {
            $('source_manual_<%=suffix%>').hide();
            $('source_sql_<%=suffix%>').hide();
            $('source_rows_<%=suffix%>').show();
            $('source_topic_<%=suffix%>').show();
            $('source_field_<%=suffix%>').show();
        }
    }

    image_onchange_<%=suffix%> = function() {
        if($F("image_<%=suffix%>"))
        {
            $("imgbar_<%=suffix%>").show();
        }
        else
        {
            $("imgbar_<%=suffix%>").hide();
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

    add_link_<%=suffix%> = function() {
        var table = $('link_editor_<%=suffix%>');
        var r = table.insertRow(-1);
        var c1 = document.createElement("td");
        c1.innerHTML  = "<input type='checkbox' name='stat_<%=suffix%>'>";
        r.appendChild(c1);

        var c2 = document.createElement("td");
        c2.innerHTML = "<textarea name='link_url_<%=suffix%>' rows=3 style='width:90%'></textarea>";
        r.appendChild(c2);

        var c3 = document.createElement("td");
        c3.innerHTML = "<textarea name='link_title_<%=suffix%>' rows=3 style='width:90%'></textarea>";
        r.appendChild(c3);

        var c4 = document.createElement("td");
        c4.innerHTML = "<textarea name='link_desc_<%=suffix%>' rows=3 style='width:90%'></textarea>";
        r.appendChild(c4);

        var c4 = document.createElement("td");
        c4.innerHTML = "<textarea name='link_imgurl_<%=suffix%>' rows=3 style='width:90%'></textarea>";
        r.appendChild(c4);
    }

    del_link_<%=suffix%> = function() {
        var table = $('link_editor_<%=suffix%>');
        var boxes = document.getElementsByName("stat_<%=suffix%>");
        for (var i = boxes.length-1; i>=0; i--){
            if(boxes[i].checked) {
                table.deleteRow(i);
            }
        }
    }

    up_link_<%=suffix%> = function() {
        MoveTable('<%=suffix%>',-1);
    }

    down_link_<%=suffix%> = function() {
       MoveTable('<%=suffix%>',1);
    }

    checked_link_<%=suffix%> = function() {
        var boxes = document.getElementsByName("stat_<%=suffix%>");
        var c = document.getElementById("allstat_<%=suffix%>").checked;
        for (var i = 0; i < boxes.length; i++){
            boxes[i].checked = c;
        }
    }

    MoveRow = function(tblObj,trObj, step) {
        var tbody = tblObj.getElementsByTagName("TBODY")[0];
        var newIdx = trObj.rowIndex + step;
        if( newIdx<0 || newIdx >= tblObj.rows.length) return;
        Element.remove(trObj);
        if( step > 0) {
            newIdx = newIdx - step;
            var destTR = tblObj.rows[newIdx];
            if( tbody.lastChild == destTR ) {
               tbody.appendChild(trObj);
            } else {
               tbody.insertBefore(trObj,destTR.nextSibling);
            }
        } else {
            tbody.insertBefore(trObj, tblObj.rows[newIdx]);
        }
    }

    MoveTable = function(mod_id,step)
    {
        if(step==0) return;

        var table = document.getElementById('link_editor_' + mod_id);
        var idObjs = document.getElementsByName("stat_" + mod_id);
        if( !idObjs ) return;

        var trObj = null;
        var trArray = new Array();
        for(var i =0; i < idObjs.length; i++) {
            if( !idObjs[i].checked ) continue;

            var obj = idObjs[i];
            while( obj.parentNode) {
                if( obj.tagName =='TR'){ trObj = obj; break; }
                obj = obj.parentNode;
            }
            if(trObj) trArray.push(trObj);
        }
        if( trArray.length ==0) return;

        if( step >0) {
            trObj = trArray[ trArray.length -1];
            if( trObj.rowIndex >= table.rows.length -1) return;
            for(var i = trArray.length -1; i>=0; i --) MoveRow(table,trArray[i], step);
        } else {
            trObj = trArray[0];
            if(trObj.rowIndex<1) return;
            for(var i =0; i < trArray.length; i ++) MoveRow(table,trArray[i], step);
        }
    }
</script>
<div class="effectbar">
    <%=bundle_module.getString("LINK_SOURCE")%>
    <select id="source_<%=suffix%>" name="source_<%=suffix%>" onchange="source_onchange_<%=suffix%>(this.options[this.options.selectedIndex].value)">
        <option value="" <%=module.GetDataString("source",suffix)==null || "".equals(module.GetDataString("source",suffix))?"selected":""%>><%=bundle_module.getString("LINK_SOURCE_MANUAL")%></option>
        <option value="ARTICLE" <%="ARTICLE".equals(module.GetDataString("source",suffix))?"selected":""%>><%=bundle_module.getString("LINK_SOURCE_ARTICLE")%></option>
        <option value="RESOURCE" <%="RESOURCE".equals(module.GetDataString("source",suffix))?"selected":""%>><%=bundle_module.getString("LINK_SOURCE_RESOURCE")%></option>
        <option value="CUSTOMTOPIC" <%="CUSTOMTOPIC".equals(module.GetDataString("source",suffix))?"selected":""%>><%=bundle_module.getString("LINK_SOURCE_CUSTOMTOPIC")%></option>
        <option value="SQL" <%="SQL".equals(module.GetDataString("source",suffix))?"selected":""%>><%=bundle_module.getString("LINK_SOURCE_SQL")%></option>
    </select>
    &nbsp;&nbsp;
    <%=bundle_module.getString("LINK_EFFECT")%>
    <select id="effect_<%=suffix%>" name="effect_<%=suffix%>" onchange="effect_onchange_<%=suffix%>(this.options[this.options.selectedIndex].value)">
        <option value="" <%=module.GetDataString("effect",suffix)==null || "".equals(module.GetDataString("effect",suffix))?"selected":""%>><%=bundle_module.getString("LINK_EFFECT_NONE")%></option>
        <option value="MARQUEE" <%="MARQUEE".equals(module.GetDataString("effect",suffix))?"selected":""%>><%=bundle_module.getString("LINK_EFFECT_MARQUEE")%></option>
    </select>    
</div>

<table class="effect_table" id="marquee_<%=suffix%>" style="display:<%="MARQUEE".equals(module.GetDataString("effect",suffix))?"block":"none"%>">
    <tr>
        <td><%=bundle_module.getString("LINK_MARQUEE_DIRECT")%>
            <select id="marquee_direct_<%=suffix%>" name="marquee_direct_<%=suffix%>">
                <option value="0" <%="0".equals(module.GetDataString("marquee_direct",suffix))?"selected":""%>><%=bundle_module.getString("LINK_MARQUEE_DIRECT_UP")%></option>
                <option value="1" <%="1".equals(module.GetDataString("marquee_direct",suffix))?"selected":""%>><%=bundle_module.getString("LINK_MARQUEE_DIRECT_DOWN")%></option>
                <option value="2" <%="2".equals(module.GetDataString("marquee_direct",suffix))?"selected":""%>><%=bundle_module.getString("LINK_MARQUEE_DIRECT_LEFT")%></option>
                <option value="3" <%="3".equals(module.GetDataString("marquee_direct",suffix))?"selected":""%>><%=bundle_module.getString("LINK_MARQUEE_DIRECT_RIGHT")%></option>
            </select>
        </td>
        <td><%=bundle_module.getString("LINK_MARQUEE_TIMER")%>
            <input type="text" id="marquee_timer_<%=suffix%>" name="marquee_timer_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_timer",suffix))%>" width="5">ms
        </td>
        <td><%=bundle_module.getString("LINK_MARQUEE_STEP")%>
            <input type="text" id="marquee_step_<%=suffix%>" name="marquee_step_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_step",suffix))%>">
        </td>
        <td><%=bundle_module.getString("LINK_MARQUEE_WAITTIME")%>
            <input type="text" id="marquee_waittime_<%=suffix%>" name="marquee_waittime_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_waittime",suffix))%>" width="5">ms
        </td>
    </tr>
    <tr>
        <td><%=bundle_module.getString("LINK_MARQUEE_WIDTH")%>
            <input type="text" id="marquee_width_<%=suffix%>" name="marquee_width_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_width",suffix))%>" width="5">px
        </td>
        <td><%=bundle_module.getString("LINK_MARQUEE_HEIGHT")%>
            <input type="text" id="marquee_height_<%=suffix%>" name="marquee_height_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_height",suffix))%>" width="5">px
        </td>
        <td><%=bundle_module.getString("LINK_MARQUEE_DELAYTIME")%>
            <input type="text" id="marquee_delaytime_<%=suffix%>" name="marquee_delaytime_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_delaytime",suffix))%>" width="5">ms
        </td>
        <td><%=bundle_module.getString("LINK_MARQUEE_SCROLLSTEP")%>
            <input type="text" id="marquee_scrollstep_<%=suffix%>" name="marquee_scrollstep_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_scrollstep",suffix))%>">
        </td>
    </tr>
</table>

<div class="databar">
    <p>
        <span id="source_rows_<%=suffix%>" style="display:<%=module.GetDataString("source",suffix)!=null && !"".equals(module.GetDataString("source",suffix))?"block":"none"%>">
            <%=bundle_module.getString("LINK_ROWS")%><font color="red">*</font>
            <input type="text" id="rows_<%=suffix%>" name="rows_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("rows",suffix))%>" style="width:40px">
            &nbsp;&nbsp;
        </span>
        <input type="checkbox" id="image_<%=suffix%>" name="image_<%=suffix%>" <%="1".equals(module.GetDataString("image",suffix))?"checked=true":""%>" value="1" onclick="image_onchange_<%=suffix%>()">
        <%=bundle_module.getString("LINK_IMAGE")%>
        &nbsp;&nbsp;
        <input type="checkbox" id="date_<%=suffix%>" name="date_<%=suffix%>" <%="1".equals(module.GetDataString("date",suffix))?"checked=true":""%>" value="1">
        <%=bundle_module.getString("LINK_DATE")%>
        <%=bundle_module.getString("LINK_DATE_FORMAT")%>
        <input type="text" id="date_format_<%=suffix%>" name="date_format_<%=suffix%>" value="<%=Utils.NVL(module.GetDataString("date_format",suffix),"yyyy-MM-dd")%>" style="width:60px">
        &nbsp;&nbsp;
        <%=bundle_module.getString("LINK_TARGET")%>
        <input type="text" id="link_target_<%=suffix%>" name="link_target_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("link_target",suffix))%>" style="width:40px">
        &nbsp;&nbsp;
        <%=bundle_module.getString("LINK_COLS")%>
        <input type="text" id="cols_<%=suffix%>" name="cols_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("cols",suffix))%>" style="width:20px">
    </p>
    
    <p>
        <%=bundle_module.getString("LINK_LISTSTYLE")%>
        <input type="text" id="liststyle_<%=suffix%>" name="liststyle_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("liststyle",suffix))%>">
        &nbsp;&nbsp;
        <%=bundle_module.getString("LINK_WIDTH")%>
        <input type="text" id="link_width_<%=suffix%>" name="link_width_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("link_width",suffix))%>" style="width:40px;">px
        &nbsp;&nbsp;
        <%=bundle_module.getString("LINK_FONT")%>
        <input type="text" id="font_<%=suffix%>" name="font_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("font",suffix))%>" style="width:100px;">
        &nbsp;&nbsp;
        <%=bundle_module.getString("LINK_COLOR")%>
        <input type="text" id="color_<%=suffix%>" name="color_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("color",suffix))%>" style="width:60px;">
    </p>

    <p id="imgbar_<%=suffix%>" style="display:<%="1".equals(module.GetDataString("image",suffix))?"block":"none"%>">
        <%=bundle_module.getString("LINK_IMAGE_WIDTH")%>
        <input type="text" id="image_width_<%=suffix%>" name="image_width_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("image_width",suffix))%>" style="width:25px">px
        &nbsp;&nbsp;
        <%=bundle_module.getString("LINK_IMAGE_HEIGHT")%>
        <input type="text" id="image_height_<%=suffix%>" name="image_height_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("image_height",suffix))%>" style="width:25px">px
        &nbsp;&nbsp;
        <%=bundle_module.getString("LINK_IMAGE_PADDING_LEFT")%>
        <input type="text" id="padding_left_<%=suffix%>" name="padding_left_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("padding_left",suffix))%>" style="width:20px">px
        &nbsp;&nbsp;
        <%=bundle_module.getString("LINK_IMAGE_PADDING_RIGHT")%>
        <input type="text" id="padding_right_<%=suffix%>" name="padding_right_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("padding_right",suffix))%>" style="width:20px">px
        &nbsp;&nbsp;
        <%=bundle_module.getString("LINK_IMAGE_PADDING_UP")%>
        <input type="text" id="padding_up_<%=suffix%>" name="padding_up_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("padding_up",suffix))%>" style="width:20px">px
        &nbsp;&nbsp;
        <%=bundle_module.getString("LINK_IMAGE_PADDING_DOWN")%>
        <input type="text" id="padding_down_<%=suffix%>" name="paddingn_down_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("padding_down",suffix))%>" style="width:20px">px
    </p>
</div>

<div id="source_manual_<%=suffix%>" class="databar" style="height:400px;overflow:auto;display:none">
    <p>
        <input type="button" class="button" value="<%=bundle_module.getString("LINK_BUTTON_ADD")%>" onclick="add_link_<%=suffix%>()">
        <input type="button" class="button" value="<%=bundle_module.getString("LINK_BUTTON_DELETE")%>" onclick="del_link_<%=suffix%>()">
        <input type="button" class="button" value="<%=bundle_module.getString("LINK_BUTTON_UP")%>" onclick="up_link_<%=suffix%>()">
        <input type="button" class="button" value="<%=bundle_module.getString("LINK_BUTTON_DOWN")%>" onclick="down_link_<%=suffix%>()">
    </p>
    <table id="link_editor_<%=suffix%>" class="link_editor">
        <tbody>
            <tr>
                <th width="25"><input type="checkbox" id="allstat_<%=suffix%>" name="allstat_<%=suffix%>" onclick="checked_links_<%=suffix%>()"></th>
                <th width="20%"><%=bundle_module.getString("LINK_URL")%></th>
                <th width="20%"><%=bundle_module.getString("LINK_TITLE")%></th>
                <th><%=bundle_module.getString("LINK_DESCRIPTION")%></th>
                <th width="20%"><%=bundle_module.getString("LINK_IMAGEURL")%></th>
            </tr>
<%
    if(module.GetDataString("source",suffix)==null || "".equals(module.GetDataString("source",suffix)))
    {
        Object obj = module.GetDataValue("link_url",suffix);
        if(obj!=null && obj instanceof String)
        {
%>
            <tr>
                <td width="25">
                    <input type="checkbox" name="stat_<%=suffix%>">
                </td>
                <td>
                    <textarea name="link_url_<%=suffix%>" rows=3 style='width:90%'><%=module.GetDataString("link_url",suffix)%></textarea>
                </td>
                <td>
                    <textarea name="link_title_<%=suffix%>" rows="3" cols="5" style="width:90%"><%=module.GetDataString("link_title",suffix)%></textarea>
                </td>
                <td>
                    <textarea name="link_desc_<%=suffix%>" rows="3" cols="5" style="width:90%"><%=module.GetDataString("link_desc",suffix)%></textarea>
                </td>
                <td>
                    <textarea name="link_imgurl_<%=suffix%>" rows="3" cols="5" style="width:90%"><%=module.GetDataString("link_imgurl",suffix)%></textarea>
                </td>
            </tr>
<%
        }
        else if(obj!=null)
        {
            JSONArray urls = (JSONArray)module.GetDataValue("link_url",suffix);
            JSONArray titles = (JSONArray)module.GetDataValue("link_title",suffix);
            JSONArray descs = (JSONArray)module.GetDataValue("link_desc",suffix);
            JSONArray imgurls = (JSONArray)module.GetDataValue("link_imgurl",suffix);

            for(int i=0;i<urls.length();i++)
            {
%>
                <tr>
                    <td width="25">
                        <input type="checkbox" name="stat_<%=suffix%>">
                    </td>
                    <td>
                        <textarea name="link_url_<%=suffix%>" rows=3 style='width:90%'><%=urls.getString(i)%></textarea>
                    </td>
                    <td>
                        <textarea name="link_title_<%=suffix%>" rows="3" cols="5" style="width:90%"><%=titles.getString(i)%></textarea>
                    </td>
                    <td>
                        <textarea name="link_desc_<%=suffix%>" rows="3" cols="5" style="width:90%"><%=descs.getString(i)%></textarea>
                    </td>
                    <td>
                        <textarea name="link_imgurl_<%=suffix%>" rows="3" cols="5" style="width:90%"><%=imgurls.getString(i)%></textarea>
                    </td>
                </tr>
<%
            }
        }
    }
%>
       </tbody>
    </table>
</div>

<div id="source_topic_<%=suffix%>" class="databar" style="display:none">
    <%=bundle_module.getString("LINK_TOPIC")%><font color="red">*</font>
    <input type="hidden" id="site_id_<%=suffix%>" name="site_id_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("site_id",suffix))%>">
    <input type="hidden" id="top_id_<%=suffix%>" name="top_id_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("top_id",suffix))%>">
    <input type="text" id="topic_<%=suffix%>" name="topic_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("topic",suffix))%>" readonly onclick='selecttopic_<%=suffix%>()' size="25">
    <input type="button" value="<%=bundle_module.getString("LINK_TOPIC_SELECT")%>" class="button" onclick='selecttopic_<%=suffix%>()'>
</div>

<div id="source_sql_<%=suffix%>" class="databar" style="display:none">
    <p><%=bundle_module.getString("LINK_SQL")%><font color="red">*</font></p>
    <textarea rows="3" cols="5" id="sql_<%=suffix%>" name="sql_<%=suffix%>" style="width:100%"><%=Utils.Null2Empty(module.GetDataString("sql",suffix))%></textarea>
</div>

<div id="source_field_<%=suffix%>" class="databar" style="display:none">
    <p>
        <%=bundle_module.getString("LINK_FIELD_URL")%><font color="red">*</font>
        <input type="text" id="field_url_<%=suffix%>" name="field_url_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("field_url",suffix))%>">
        &nbsp;&nbsp;
        <%=bundle_module.getString("LINK_FIELD_URL_NPS")%>
        <input type="text" id="field_url_nps_<%=suffix%>" name="field_url_nps_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("field_url_nps",suffix))%>">
    </p>
    <p>
        <%=bundle_module.getString("LINK_FIELD_TITLE")%>
        <input type="text" id="field_title_<%=suffix%>" name="field_title_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("field_title",suffix))%>">
        &nbsp;&nbsp;
        <%=bundle_module.getString("LINK_FIELD_TITLE_NPS")%>
        <input type="text" id="field_title_nps_<%=suffix%>" name="field_title_nps_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("field_title_nps",suffix))%>">
    </p>
    <p>
        <%=bundle_module.getString("LINK_FIELD_DATE")%>
        <input type="text" id="field_date_<%=suffix%>" name="field_date_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("field_date",suffix))%>">
        &nbsp;&nbsp;
        <%=bundle_module.getString("LINK_FIELD_DATE_NPS")%>
        <input type="text" id="field_date_nps_<%=suffix%>" name="field_date_nps_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("field_date_nps",suffix))%>">
    </p>
    <p>
        <%=bundle_module.getString("LINK_FIELD_DESCRIPTION")%>
        <input type="text" id="field_desc_<%=suffix%>" name="field_desc_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("field_desc",suffix))%>">
        &nbsp;&nbsp;
        <%=bundle_module.getString("LINK_FIELD_DESCRIPTION_NPS")%>
        <input type="text" id="field_desc_nps_<%=suffix%>" name="field_desc_nps_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("field_desc_nps",suffix))%>">
    </p>
    <p>
        <%=bundle_module.getString("LINK_FIELD_IMAGE")%>
        <input type="text" id="field_image_<%=suffix%>" name="field_image_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("field_image",suffix))%>">
        &nbsp;&nbsp;
        <%=bundle_module.getString("LINK_FIELD_DESCRIPTION_NPS")%>
        <input type="text" id="field_image_nps_<%=suffix%>" name="field_image_nps_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("field_image_nps",suffix))%>">
    </p>
</div>