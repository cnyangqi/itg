<%@ page language = "java" contentType = "text/html;charset=UTF-8"%>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.module.VisualModule" %>
<%@ page import="nps.core.Config" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="org.json.JSONArray" %>

<%@ include file="/include/header.jsp" %>

<%
    out.clear();
    VisualModule module = (VisualModule)request.getAttribute("module");
    ResourceBundle bundle_module = ResourceBundle.getBundle("langs.module_image",user.GetLocale(), Config.RES_CLASSLOADER);

    String suffix = request.getParameter("suffix");
    if(suffix==null || suffix.length()==0) suffix = module.GetId();
    
%>
<script type="text/javascript">
    onedit_<%=suffix%> = function() {
        source_onchange_<%=suffix%>($F('source_<%=suffix%>'));

        var effect = $F('effect_<%=suffix%>');
        effect_onchange_<%=suffix%>(effect);
        if(effect == 'SLIDE') {
            if(slider_<%=suffix%>) slider_<%=suffix%>.stop();
        } else  if(effect=="MARQUEE") {
            if(image_marquee_<%=suffix%>) image_marquee_<%=suffix%>.stop();
        } else if(effect="FLOAT") {
            if(ad_<%=suffix%>) ad_<%=suffix%>.stop(); 
        }
    }

    onsave_<%=suffix%> = function() {
        var effect = $F('effect_<%=suffix%>');
        if(effect=="MARQUEE") {
            var marquee_direct = $F('marquee_direct_<%=suffix%>');
            if(marquee_direct=='2' || marquee_direct=='3') {
                var marquee_width = $F('marquee_width_<%=suffix%>');
                var width = $F('width_<%=suffix%>');
                if(marquee_width=="" && width=="") {
                    alert('<%=bundle_module.getString("IMAGE_ALERT_NONE_WIDTH")%>');
                    return false;
                }
                if(marquee_width=="" && width.endsWith('%')) {
                    alert('<%=bundle_module.getString("IMAGE_ALERT_INVALID_WIDTH")%>');
                    return false;
                }
            }
        }
        var source = $F('source_<%=suffix%>');
        if(source=="") {
            var table = $('image_editor_<%=suffix%>');
            if(table.rows.length==0) {
                alert('<%=bundle_module.getString("IMAGE_ALERT_NONE_DATA")%>');
                return false;
            }
        } else {
            var rows = $F('rows_<%=suffix%>');
            if(rows=="") {
                alert('<%=bundle_module.getString("IMAGE_ALERT_NONE_ROWS")%>');
                return false;
            }
            if(source=="SQL") {
                var sql = $F('sql_<%=suffix%>');
                if(sql=="") {
                    alert('<%=bundle_module.getString("IMAGE_ALERT_NONE_SQL")%>');
                    return false;
                }
            }else {
                var topic = $F('top_id_<%=suffix%>');
                if(topic=="") {
                    alert('<%=bundle_module.getString("IMAGE_ALERT_NONE_TOPIC")%>');
                    return false;
                }
            }
            if(source=="CUSTOMTOPIC" || source=="SQL") {
                var field_image = $F('field_image_<%=suffix%>');
                if(field_image=="") {
                    alert('<%=bundle_module.getString("IMAGE_ALERT_NONE_FIELD_IMAGE")%>');
                    return false;
                }
            }

            var table = $('image_editor_<%=suffix%>');
            var rowCount = table.rows.length;
            if( rowCount>0 ) {
                for(var i=rowCount-1; i>=0; i--) {
                    table.deleteRow(i);
                }
            }
        }
       
        return true;
    }

    ondiscard_<%=suffix%> = function() {
        var effect = $F('effect_<%=suffix%>');
        if(effect == 'SLIDE') {
            if(slider_<%=suffix%>) slider_<%=suffix%>.render();
        } else if(effect=="MARQUEE") {
            if(image_marquee_<%=suffix%>) image_marquee_<%=suffix%>.start();
        } else if(effect="FLOAT") {
            if(ad_<%=suffix%>) ad_<%=suffix%>.start();
        }
    }

    effect_onchange_<%=suffix%> = function(e) {
       if(e=="MARQUEE") {
          $('float_<%=suffix%>').hide();
          $('flash_<%=suffix%>').hide();
          $('marquee_<%=suffix%>').show();
       } else if(e=="FLASH") {
           $('float_<%=suffix%>').hide();
           $('marquee_<%=suffix%>').hide();
           $('flash_<%=suffix%>').show();
       } else if(e=="FLOAT") {
           $('marquee_<%=suffix%>').hide();
           $('flash_<%=suffix%>').hide();
           $('float_<%=suffix%>').show();
       }else {
          $('float_<%=suffix%>').hide();
          $('marquee_<%=suffix%>').hide();
          $('flash_<%=suffix%>').hide();
       }
    }

    floatmode_onchange_<%=suffix%> = function(e) {
        if(e=="FLOAT") {
            $('float_side_<%=suffix%>').style.display = "inline";
            if($F('float_side_<%=suffix%>')=='LEFT') {
                $('span_lr_<%=suffix%>').innerText = '<%=bundle_module.getString("IMAGE_FLOAT_LEFT")%>';
            } else
            {
                $('span_lr_<%=suffix%>').innerText = '<%=bundle_module.getString("IMAGE_FLOAT_RIGHT")%>';
            }
        } else {
            $('float_side_<%=suffix%>').style.display = "none";
            $('span_lr_<%=suffix%>').innerText = '<%=bundle_module.getString("IMAGE_FLOAT_LEFT")%>';
        }
    }

    floatside_onchange_<%=suffix%> = function(e) {
        if(e=='LEFT') {
            $('span_lr_<%=suffix%>').innerText = '<%=bundle_module.getString("IMAGE_FLOAT_LEFT")%>';
        } else
        {
            $('span_lr_<%=suffix%>').innerText = '<%=bundle_module.getString("IMAGE_FLOAT_RIGHT")%>';
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

    popupMediaDialog = function(url)
    {
        var win = window.open(url, "mcePopup","dialog=yes,modal=yes" );
        win.focus();
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

    add_image_<%=suffix%> = function() {
       popupMediaDialog("/info/selectresource.jsp?multiple=1&type=0&func=callback_add_image_<%=suffix%>");
    }

    callback_add_image_<%=suffix%> = function(id,title,url) {
        var table = $('image_editor_<%=suffix%>');
        var r = table.insertRow(-1);
        var c1 = document.createElement("td");
        c1.innerHTML  = "<input type='hidden' name='img_url_<%=suffix%>' value='" + url + "'>" +
                        "<input type='checkbox' name='statimg_<%=suffix%>'>";
        r.appendChild(c1);

        var c2 = document.createElement("td");

        c2.innerHTML = "<div class='image'><img src='" + url + "' alt='" + title + "' border=0 style='max-width:220px'></div>" +
                       "<div class='title'>" +
                       "<%=bundle_module.getString("IMAGE_URL")%><br>" +
                       "<input type='text' name='img_openurl_<%=suffix%>' style='width:80%'><br>" +
                       "<%=bundle_module.getString("IMAGE_TITLE")%><br>" +
                       "<textarea name='img_title_<%=suffix%>' rows=2 style='width:80%'>" + title + "</textarea>" +
                       "</div>";

        r.appendChild(c2);
    }

    del_image_<%=suffix%> = function() {
        var table = $('image_editor_<%=suffix%>');
        var boxes = document.getElementsByName("statimg_<%=suffix%>");
        for (var i = boxes.length-1; i>=0; i--){
            if(boxes[i].checked) {
                table.deleteRow(i);
            }
        }
    }

    up_image_<%=suffix%> = function() {
        MoveTable('<%=suffix%>',-1);
    }

    down_image_<%=suffix%> = function() {
       MoveTable('<%=suffix%>',1);
    }

    checked_image_<%=suffix%> = function() {
        var boxes = document.getElementsByName("statimg_<%=suffix%>");
        var c = document.getElementById("all_statimg_<%=suffix%>").checked;
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

        var table = document.getElementById('image_editor_' + mod_id);
        var idObjs = document.getElementsByName("statimg_" + mod_id);
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
    <%=bundle_module.getString("IMAGE_SOURCE")%>
    <select id="source_<%=suffix%>" name="source_<%=suffix%>" onchange="source_onchange_<%=suffix%>(this.options[this.options.selectedIndex].value)">
        <option value="" <%=module.GetDataString("source",suffix)==null || "".equals(module.GetDataString("source",suffix))?"selected":""%>><%=bundle_module.getString("IMAGE_SOURCE_MANUAL")%></option>
        <option value="ARTICLE" <%="ARTICLE".equals(module.GetDataString("source",suffix))?"selected":""%>><%=bundle_module.getString("IMAGE_SOURCE_ARTICLE")%></option>
        <option value="RESOURCE" <%="RESOURCE".equals(module.GetDataString("source",suffix))?"selected":""%>><%=bundle_module.getString("IMAGE_SOURCE_RESOURCE")%></option>
        <option value="CUSTOMTOPIC" <%="CUSTOMTOPIC".equals(module.GetDataString("source",suffix))?"selected":""%>><%=bundle_module.getString("IMAGE_SOURCE_CUSTOMTOPIC")%></option>
        <option value="SQL" <%="SQL".equals(module.GetDataString("source",suffix))?"selected":""%>><%=bundle_module.getString("IMAGE_SOURCE_SQL")%></option>
    </select>
    &nbsp;&nbsp;
    <%=bundle_module.getString("IMAGE_EFFECT")%>
    <select id="effect_<%=suffix%>" name="effect_<%=suffix%>" onchange="effect_onchange_<%=suffix%>(this.options[this.options.selectedIndex].value)">
        <option value="" <%=module.GetDataString("effect",suffix)==null || "".equals(module.GetDataString("effect",suffix))?"selected":""%>><%=bundle_module.getString("IMAGE_EFFECT_NONE")%></option>
        <option value="MARQUEE" <%="MARQUEE".equals(module.GetDataString("effect",suffix))?"selected":""%>><%=bundle_module.getString("IMAGE_EFFECT_MARQUEE")%></option>
        <option value="SLIDE" <%="SLIDE".equals(module.GetDataString("effect",suffix))?"selected":""%>><%=bundle_module.getString("IMAGE_EFFECT_SLIDE")%></option>
        <option value="FLASH" <%="FLASH".equals(module.GetDataString("effect",suffix))?"selected":""%>><%=bundle_module.getString("IMAGE_EFFECT_FLASH")%></option>
        <option value="FLOAT" <%="FLOAT".equals(module.GetDataString("effect",suffix))?"selected":""%>><%=bundle_module.getString("IMAGE_EFFECT_FLOAT")%></option>
    </select>
</div>

<table class="effect_table" id="marquee_<%=suffix%>" style="display:<%="MARQUEE".equals(module.GetDataString("effect",suffix))?"block":"none"%>">
    <tr>
        <td><%=bundle_module.getString("IMAGE_MARQUEE_DIRECT")%>
            <select id="marquee_direct_<%=suffix%>" name="marquee_direct_<%=suffix%>">
                <option value="0" <%="0".equals(module.GetDataString("marquee_direct",suffix))?"selected":""%>><%=bundle_module.getString("IMAGE_MARQUEE_DIRECT_UP")%></option>
                <option value="1" <%="1".equals(module.GetDataString("marquee_direct",suffix))?"selected":""%>><%=bundle_module.getString("IMAGE_MARQUEE_DIRECT_DOWN")%></option>
                <option value="2" <%="2".equals(module.GetDataString("marquee_direct",suffix))?"selected":""%>><%=bundle_module.getString("IMAGE_MARQUEE_DIRECT_LEFT")%></option>
                <option value="3" <%="3".equals(module.GetDataString("marquee_direct",suffix))?"selected":""%>><%=bundle_module.getString("IMAGE_MARQUEE_DIRECT_RIGHT")%></option>
            </select>
        </td>
        <td><%=bundle_module.getString("IMAGE_MARQUEE_TIMER")%>
            <input type="text" id="marquee_timer_<%=suffix%>" name="marquee_timer_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_timer",suffix))%>" width="5">ms
        </td>
        <td><%=bundle_module.getString("IMAGE_MARQUEE_STEP")%>
            <input type="text" id="marquee_step_<%=suffix%>" name="marquee_step_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_step",suffix))%>">
        </td>
        <td><%=bundle_module.getString("IMAGE_MARQUEE_WAITTIME")%>
            <input type="text" id="marquee_waittime_<%=suffix%>" name="marquee_waittime_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_waittime",suffix))%>" width="5">ms
        </td>
    </tr>
    <tr>
        <td><%=bundle_module.getString("IMAGE_MARQUEE_WIDTH")%>
            <input type="text" id="marquee_width_<%=suffix%>" name="marquee_width_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_width",suffix))%>" width="5">px
        </td>
        <td><%=bundle_module.getString("IMAGE_MARQUEE_HEIGHT")%>
            <input type="text" id="marquee_height_<%=suffix%>" name="marquee_height_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_height",suffix))%>" width="5">px
        </td>
        <td><%=bundle_module.getString("IMAGE_MARQUEE_DELAYTIME")%>
            <input type="text" id="marquee_delaytime_<%=suffix%>" name="marquee_delaytime_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_delaytime",suffix))%>" width="5">ms
        </td>
        <td><%=bundle_module.getString("IMAGE_MARQUEE_SCROLLSTEP")%>
            <input type="text" id="marquee_scrollstep_<%=suffix%>" name="marquee_scrollstep_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("marquee_scrollstep",suffix))%>">
        </td>
    </tr>
</table>

<table class="effect_table" id="float_<%=suffix%>" style="display:<%="FLOAT".equals(module.GetDataString("effect",suffix))?"block":"none"%>">
    <tr>
        <td>
            <%=bundle_module.getString("IMAGE_FLOAT_MODE")%>
            <select id="float_mode_<%=suffix%>" name="float_mode_<%=suffix%>" onchange="floatmode_onchange_<%=suffix%>(this.options[this.options.selectedIndex].value)">
                <option value="FLOAT" <%="FLOAT".equals(module.GetDataString("float_mode",suffix))?"selected":""%>><%=bundle_module.getString("IMAGE_FLOAT_MODE_SIDE")%></option>
                <option value="MOVE" <%="MOVE".equals(module.GetDataString("float_mode",suffix))||module.GetDataString("float_mode",suffix)==null?"selected":""%>><%=bundle_module.getString("IMAGE_FLOAT_MODE_MOVE")%></option>
            </select>
            <select id="float_side_<%=suffix%>" name="float_side_<%=suffix%>" style="display:<%="FLOAT".equals(module.GetDataString("float_mode",suffix))?"inline":"none"%>" onchange="floatside_onchange_<%=suffix%>(this.options[this.options.selectedIndex].value)">
                <option value="LEFT" <%="LEFT".equals(module.GetDataString("float_side",suffix))?"selected":""%>><%=bundle_module.getString("IMAGE_FLOAT_SIDE_LEFT")%></option>
                <option value="RIGHT" <%="RIGHT".equals(module.GetDataString("float_side",suffix))?"selected":""%>><%=bundle_module.getString("IMAGE_FLOAT_SIDE_RIGHT")%></option>
            </select>
            &nbsp;&nbsp;
            <span id="span_lr_<%=suffix%>"><%="FLOAT".equals(module.GetDataString("float_mode",suffix)) && "RIGHT".equals(module.GetDataString("float_side",suffix))?bundle_module.getString("IMAGE_FLOAT_RIGHT"):bundle_module.getString("IMAGE_FLOAT_LEFT")%></span>
            <input type="text" id="float_left_<%=suffix%>" name="float_left_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("float_left",suffix))%>" width="5">px
            &nbsp;&nbsp;
            <%=bundle_module.getString("IMAGE_FLOAT_TOP")%>
            <input type="text" id="float_top_<%=suffix%>" name="float_top_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("float_top",suffix))%>" width="5">px
            &nbsp;&nbsp;
            <%=bundle_module.getString("IMAGE_FLOAT_DELAY")%>
            <input type="text" id="float_delay_<%=suffix%>" name="float_delay_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("float_delay",suffix))%>" width="5">ms
        </td>
    </tr>
</table>

<table class="effect_table" id="flash_<%=suffix%>" style="display:<%="FLASH".equals(module.GetDataString("effect",suffix))?"block":"none"%>">
    <tr>
        <td>
            <%=bundle_module.getString("IMAGE_FLASH_WIDTH")%>
            <input type="text" id="flash_width_<%=suffix%>" name="flash_width_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("flash_width",suffix))%>" width="5">px
            &nbsp;&nbsp;
            <%=bundle_module.getString("IMAGE_FLASH_HEIGHT")%>
            <input type="text" id="flash_height_<%=suffix%>" name="flash_height_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("flash_height",suffix))%>" width="5">px
            &nbsp;&nbsp;
            <%=bundle_module.getString("IMAGE_FLASH_TEXTHEIGHT")%>
            <input type="text" id="flash_textheight_<%=suffix%>" name="flash_textheight_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("flash_textheight",suffix))%>" width="5">px
        </td>
    </tr>
</table>

<div class="databar">
   <p id="source_rows_<%=suffix%>" style="display:<%=module.GetDataString("source",suffix)!=null && !"".equals(module.GetDataString("source",suffix))?"block":"none"%>">
        <%=bundle_module.getString("IMAGE_ROWS")%><font color="red">*</font>
        <input type="text" id="rows_<%=suffix%>" name="rows_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("rows",suffix))%>" style="width:40px">
        &nbsp;&nbsp;
        <%=bundle_module.getString("IMAGE_START")%>
       <input type="text" id="start_<%=suffix%>" name="start_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("start",suffix))%>" style="width:40px">
   </p>

   <p>
        <%=bundle_module.getString("IMAGE_WIDTH")%>
        <input type="text" id="image_width_<%=suffix%>" name="image_width_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("image_width",suffix))%>" style="width:40px">px
        &nbsp;&nbsp;
        <%=bundle_module.getString("IMAGE_HEIGHT")%>
        <input type="text" id="image_height_<%=suffix%>" name="image_height_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("image_height",suffix))%>" style="width:40px">px
        &nbsp;&nbsp;
        <%=bundle_module.getString("IMAGE_TARGET")%>
        <input type="text" id="image_target_<%=suffix%>" name="image_target_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("image_target",suffix))%>" style="width:80px">
        &nbsp;&nbsp;
        <%=bundle_module.getString("IMAGE_COLS")%>
        <input type="text" id="cols_<%=suffix%>" name="cols_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("cols",suffix))%>" style="width:40px">
  </p>
  <p>
      <%=bundle_module.getString("IMAGE_PADDING_LEFT")%>
      <input type="text" id="padding_left_<%=suffix%>" name="padding_left_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("padding_left",suffix))%>" style="width:25px">px
      &nbsp;&nbsp;
      <%=bundle_module.getString("IMAGE_PADDING_RIGHT")%>
      <input type="text" id="padding_right_<%=suffix%>" name="padding_right_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("padding_right",suffix))%>" style="width:25px">px
      &nbsp;&nbsp;
      <%=bundle_module.getString("IMAGE_PADDING_UP")%>
      <input type="text" id="padding_up_<%=suffix%>" name="padding_up_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("padding_up",suffix))%>" style="width:25px">px
      &nbsp;&nbsp;
      <%=bundle_module.getString("IMAGE_PADDING_DOWN")%>
      <input type="text" id="padding_down_<%=suffix%>" name="paddingn_down_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("padding_down",suffix))%>" style="width:25px">px
  </p>
</div>

<div id="source_manual_<%=suffix%>" class="databar" style="height:400px;overflow:auto;display:none">
    <p>
        <input type="checkbox" id="all_statimg_<%=suffix%>" name="all_statimg_<%=suffix%>" onclick="checked_image_<%=suffix%>()">
        <input type="button" class="button" value="<%=bundle_module.getString("IMAGE_BUTTON_ADD")%>" onclick="add_image_<%=suffix%>()">
        <input type="button" class="button" value="<%=bundle_module.getString("IMAGE_BUTTON_DELETE")%>" onclick="del_image_<%=suffix%>()">
        <input type="button" class="button" value="<%=bundle_module.getString("IMAGE_BUTTON_UP")%>" onclick="up_image_<%=suffix%>()">
        <input type="button" class="button" value="<%=bundle_module.getString("IMAGE_BUTTON_DOWN")%>" onclick="down_image_<%=suffix%>()">
    </p>
    <table id="image_editor_<%=suffix%>" class="image_editor">
        <tbody>
<%
    if(module.GetDataString("source",suffix)==null || "".equals(module.GetDataString("source",suffix)))
    {
        Object obj = module.GetDataValue("img_url",suffix);
        if(obj!=null && obj instanceof String)
        {
%>
            <tr>
                <td width="25">
                    <input type="hidden" name="img_url_<%=suffix%>" value="<%=module.GetDataString("img_url",suffix)%>">
                    <input type="checkbox" name="statimg_<%=suffix%>">
                </td>
                <td>
                    <div class="image">
                       <img src="<%=module.GetDataString("img_url",suffix)%>" alt="<%=module.GetDataString("img_title",suffix)%>" border="0" style='max-width:220px'>
                    </div>
                    <div class="title">
                        <%=bundle_module.getString("IMAGE_URL")%><br>
                        <input type="text" name="img_openurl_<%=suffix%>" value="<%=module.GetDataString("img_openurl",suffix)%>" style='width:80%'>
                        <br>
                        <%=bundle_module.getString("IMAGE_TITLE")%><br>
                        <textarea id="img_title_<%=suffix%>" name="img_title_<%=suffix%>" rows="3" cols="5" style="width:80%"><%=module.GetDataString("img_title",suffix)%></textarea>
                    </div>    
                </td>
            </tr>
<%
        }
        else if(obj!=null)
        {
            JSONArray urls = (JSONArray)module.GetDataValue("img_url",suffix);
            JSONArray openurls = (JSONArray)module.GetDataValue("img_openurl",suffix);
            JSONArray titles = (JSONArray)module.GetDataValue("img_title",suffix);

            for(int i=0;i<urls.length();i++)
            {
%>
                <tr>
                    <td width="25">
                        <input type="hidden" name="img_url_<%=suffix%>" value="<%=urls.getString(i)%>">
                        <input type="checkbox" name="statimg_<%=suffix%>">
                    </td>
                    <td>
                        <div class="image">
                            <img src="<%=urls.getString(i)%>" alt="<%=titles.getString(i)%>" border="0" style='max-width:220px'>
                        </div>
                        <div class="title">
                            <%=bundle_module.getString("IMAGE_URL")%><br>
                            <input type="text" name="img_openurl_<%=suffix%>" value="<%=openurls.getString(i)%>" style='width:100%'>
                            <br>
                            <%=bundle_module.getString("IMAGE_TITLE")%><br>
                            <textarea id="img_title_<%=suffix%>" name="img_title_<%=suffix%>" rows="2" cols="5" style="width:100%"><%=titles.getString(i)%></textarea>
                        </div>
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
    <%=bundle_module.getString("IMAGE_TOPIC")%><font color="red">*</font>
    <input type="hidden" id="site_id_<%=suffix%>" name="site_id_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("site_id",suffix))%>">
    <input type="hidden" id="top_id_<%=suffix%>" name="top_id_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("top_id",suffix))%>">
    <input type="text" id="topic_<%=suffix%>" name="topic_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("topic",suffix))%>" readonly onclick='selecttopic_<%=suffix%>()' size="25">
    <input type="button" value="<%=bundle_module.getString("IMAGE_TOPIC_SELECT")%>" class="button" onclick='selecttopic_<%=suffix%>()'>
</div>

<div id="source_sql_<%=suffix%>" class="databar" style="display:none">
    <p><%=bundle_module.getString("IMAGE_SQL")%><font color="red">*</font></p>
    <textarea rows="3" cols="5" id="sql_<%=suffix%>" name="sql_<%=suffix%>" style="width:100%"><%=Utils.Null2Empty(module.GetDataString("sql",suffix))%></textarea>
</div>

<div id="source_field_<%=suffix%>" class="databar" style="display:none">
    <p>
        <%=bundle_module.getString("IMAGE_FIELD_IMAGE")%><font color="red">*</font>
        <input type="text" id="field_image_<%=suffix%>" name="field_image_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("field_image",suffix))%>">
        &nbsp;&nbsp;
        <%=bundle_module.getString("IMAGE_FIELD_IMAGE_NPS")%>
        <input type="text" id="field_image_nps_<%=suffix%>" name="field_image_nps_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("field_image_nps",suffix))%>">
    </p>
    <p>
        <%=bundle_module.getString("IMAGE_FIELD_TITLE")%>
        <input type="text" id="field_title_<%=suffix%>" name="field_title_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("field_title",suffix))%>">
        &nbsp;&nbsp;
        <%=bundle_module.getString("IMAGE_FIELD_TITLE_NPS")%>
        <input type="text" id="field_title_nps_<%=suffix%>" name="field_title_nps_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("field_title_nps",suffix))%>">
    </p>
    <p>
        <%=bundle_module.getString("IMAGE_FIELD_URL")%>
        <input type="text" id="field_url_<%=suffix%>" name="field_url_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("field_url",suffix))%>">
        &nbsp;&nbsp;
        <%=bundle_module.getString("IMAGE_FIELD_URL_NPS")%>
        <input type="text" id="field_url_nps_<%=suffix%>" name="field_url_nps_<%=suffix%>" value="<%=Utils.Null2Empty(module.GetDataString("field_url_nps",suffix))%>">
    </p>
</div>