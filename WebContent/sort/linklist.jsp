<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>

<%@ include file="/include/header.jsp" %>


<%
    request.setCharacterEncoding("UTF-8");

    String site_id = request.getParameter("site_id");
    if(site_id==null || site_id.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    site_id = site_id.trim();

    String top_id = request.getParameter("top_id");
    if(top_id==null || top_id.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    top_id = top_id.trim();

    String image_preview = request.getParameter("image_preview");
    boolean bImagePreview = false;
    if(image_preview!=null && "1".equals(image_preview)) bImagePreview = true;

    String html_escape = request.getParameter("html_escape");
    boolean bHtmlEscaped = false;
    if(html_escape!=null && "1".equals(html_escape))  bHtmlEscaped = true;
    
    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_linklist",user.GetLocale(), Config.RES_CLASSLOADER);
    String job = request.getParameter("job");

    NpsWrapper wrapper  = null;
    wrapper = new NpsWrapper(user);
    wrapper.SetErrorHandler(response.getWriter());
    wrapper.SetLineSeperator("\n<br>\n");

    Site site = wrapper.GetSite(site_id);
    if(site==null) throw new NpsException(ErrorHelper.SYS_NOSITE);

    TopicTree tree = site.GetTopicTree();
    if(tree==null) throw new NpsException(ErrorHelper.SYS_NOTOPICTREE);
    Topic top = tree.GetTopic(top_id);
    if(top==null) throw new NpsException(ErrorHelper.SYS_NOTOPIC);
    if(!top.IsSortEnabled()) throw new NpsException(ErrorHelper.SYS_TOPIC_NOTSORTABLE);

    //只有系统管理员、站点管理员、版主可以使用
    if(!(user.IsSysAdmin() || user.IsSiteAdmin(site_id) || top.IsOwner(user.GetUID())))
    {
        throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);
    }

    PreparedStatement pstmt = null;
    ResultSet rs  = null;

    try
    {
        if("save".equalsIgnoreCase(job))
        {
            //保存待发信息,如果已发布状态不变，其他状态全部变为2待发布状态
            String[] publish_ids = request.getParameterValues("id_publish");
            if(publish_ids!=null)
            {
                String sql_update_state_idx = "update article_sort set idx=?,updatedate=sysdate,state=decode(sign(state-2),-1,2,state) where id=?";
                pstmt = wrapper.GetContext().GetConnection().prepareStatement(sql_update_state_idx);
                for(int i=0;i<publish_ids.length;i++)
                {
                    pstmt.setInt(1,i);
                    pstmt.setString(2,publish_ids[i]);
                    pstmt.executeUpdate();
                }

                try{pstmt.close();}catch(Exception e){}
            }

            //保存下架信息,已发、待发信息状态设置为0
            String[] pending_ids = request.getParameterValues("id_pending");
            if(pending_ids!=null)
            {
                String sql_update_state = "update article_sort set updatedate=sysdate,state=0 where id=? and (state=3 or state=2)";
                pstmt = wrapper.GetContext().GetConnection().prepareStatement(sql_update_state);
                for(int i=0;i<pending_ids.length;i++)
                {
                    pstmt.setString(1,pending_ids[i]);
                    pstmt.executeUpdate();
                }
                try{pstmt.close();}catch(Exception e){}
            }

            wrapper.Commit();

            out.println("&nbsp;&nbsp;<font color=red>"+bundle.getString("LINKLIST_HINT_SAVED") + "</font>");
        }
        else if("delete".equalsIgnoreCase(job))
        {
            //删除已发、待发信息
            String[] publish_ids = request.getParameterValues("artid");
            if(publish_ids!=null)
            {
                String sql_delete = "delete from article_sort where id=?";
                pstmt = wrapper.GetContext().GetConnection().prepareStatement(sql_delete);
                for(int i=0;i<publish_ids.length;i++)
                {
                    pstmt.setString(1,publish_ids[i]);
                    pstmt.executeUpdate();
                }

                try{pstmt.close();}catch(Exception e){}
                wrapper.Commit();

                out.println("&nbsp;&nbsp;<font color=red>"+bundle.getString("LINKLIST_HINT_DELETED") + "</font>");
            }
        }
        else if("del_pending".equalsIgnoreCase(job))
        {
            //删除下架、待选信息
            String[] pending_ids = request.getParameterValues("pending_id");
            if(pending_ids!=null)
            {
                String sql_delete = "delete from article_sort where id=?";
                pstmt = wrapper.GetContext().GetConnection().prepareStatement(sql_delete);
                for(int i=0;i<pending_ids.length;i++)
                {
                    pstmt.setString(1,pending_ids[i]);
                    pstmt.executeUpdate();
                }

                try{pstmt.close();}catch(Exception e){}
                wrapper.Commit();

                out.println("&nbsp;&nbsp;<font color=red>"+bundle.getString("LINKLIST_HINT_DELETED") + "</font>");
            }
        }
        else if("publish".equalsIgnoreCase(job))
        {
            //保存待发信息,设置为发布状态
            String[] publish_ids = request.getParameterValues("id_publish");
            if(publish_ids!=null)
            {
                String sql_update_state_idx = "update article_sort set idx=?,updatedate=sysdate,publishdate=nvl(publishdate,sysdate),state=3 where id=?";
                pstmt = wrapper.GetContext().GetConnection().prepareStatement(sql_update_state_idx);
                for(int i=0;i<publish_ids.length;i++)
                {
                    pstmt.setInt(1,i);
                    pstmt.setString(2,publish_ids[i]);
                    pstmt.executeUpdate();
                }

                try{pstmt.close();}catch(Exception e){}
            }

            //保存下架信息,已发、待发信息状态设置为0
            String[] pending_ids = request.getParameterValues("id_pending");
            if(pending_ids!=null)
            {
                String sql_update_state = "update article_sort set updatedate=sysdate,state=0 where id=? and (state=3 or state=2)";
                pstmt = wrapper.GetContext().GetConnection().prepareStatement(sql_update_state);
                for(int i=0;i<pending_ids.length;i++)
                {
                    pstmt.setString(1,pending_ids[i]);
                    pstmt.executeUpdate();
                }
                try{pstmt.close();}catch(Exception e){}
            }

            //重建所有页面模板
            wrapper.GenerateAllPages(top);

            wrapper.Commit();

            out.println("&nbsp;&nbsp;<font color=red>"+bundle.getString("LINKLIST_HINT_PUBLISHED") + "</font>");
        }
%>

<HTML>
	<HEAD>
    <TITLE><%=bundle.getString("LINKLIST_HTMLTITLE")%></TITLE>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <script type="text/javascript" src="/jscript/jquery.js"></script>
    <LINK href="/css/style.css" rel=stylesheet>
    <style type="text/css">
    <!--
    div.tableContainer
    {
        clear: both;
        border: 1px solid #963;
        height: 350px;
        width: 100%;
        overflow: auto;
    }

    /* WinIE 6.x needs to re-account for it’’s scrollbar. Give it some padding */
    \html div.tableContainer/* */ {
       padding: 0 16px 0 0
    }

    /* define width of table. IE browsers only */
    /* if width is set to 100%, you can remove the width */
    /* property from div.tableContainer and have the div scale */
    div.tableContainer table {
        float: left;
        width: 100%;
        margin: 0 -16px 0 0
    }

    /* WinIE 6.x needs to re-account for padding. Give it a negative margin */
    \html div.tableContainer table/* */ {
        margin: 0 -16px 0 0
    }

    /* set table header to a fixed position. WinIE 6.x only */
    /* In WinIE 6.x, any element with a position property set to relative and is a child of */
    /* an element that has an overflow property set, the relative value translates into fixed. */
    /* Ex: parent element DIV with a class of tableContainer has an overflow property set to auto */
    thead.fixedHeader tr {
        position: relative;
        /* expression is for WinIE 5.x only. Remove to validate and for pure CSS solution */
        top: expression(document.getElementById("tableContainer").scrollTop)
    }

    /* set THEAD element to have block level attributes. All other non-IE browsers */
    /* this enables overflow to work on TBODY element. All other non-IE, non-Mozilla browsers */
    /* Filter out Opera 5.x/6.x and MacIE 5.x */
    head:first-child+body thead[class].fixedHeader tr {
        display: block
    }

    /* make the TH elements pretty */
    thead.fixedHeader th {
        padding: 4px 3px;
    }

    /* define the table content to be scrollable */
    /* set TBODY element to have block level attributes. All other non-IE browsers */
    /* this enables overflow to work on TBODY element. All other non-IE, non-Mozilla browsers */
    /* induced side effect is that child TDs no longer accept width: auto */
    /* Filter out Opera 5.x/6.x and MacIE 5.x */
    head:first-child+body tbody[class].scrollContent {
        display: block;
        width: 100%;
        height: 327px;
        overflow: auto;
    }

    /* make TD elements pretty. Provide alternating classes for striping the table */
    /* http://www.alistapart.com/articles/zebratables/ */
    tbody.scrollContent td, tbody.scrollContent tr.normalRow td {
        background: #FFF;
        border-bottom: 1px solid #EEE;
        border-left: 1px solid #EEE;
        border-right: 1px solid #AAA;
        border-top: 1px solid #AAA;
        padding: 2px 3px
    }

    tbody.scrollContent tr.alternateRow td {
        background: #EEE;
        border-bottom: 1px solid #EEE;
        border-left: 1px solid #EEE;
        border-right: 1px solid #AAA;
        border-top: 1px solid #AAA;
        padding: 2px 3px
    }

    head:first-child+body thead[class].fixedHeader th {
        width: 40px
    }

    head:first-child+body thead[class].fixedHeader th + th {
        width:500px;
    }

    head:first-child+body thead[class].fixedHeader th + th + th {
        width: 120px;
        text-align:center;
    }

    head:first-child+body thead[class].fixedHeader th + th + th + th {
        width: 120px;
        text-align:center;
    }

    head:first-child+body thead[class].fixedHeader th + th + th + th + th {
        border-right: none;
        padding: 4px 4px 4px 3px;
        width: 120px;
        text-align:center;
    }

    head:first-child+body tbody[class].scrollContent td {
        width: 40px;
    }

    head:first-child+body tbody[class].scrollContent td + td {
        width:500px;
    }

    head:first-child+body tbody[class].scrollContent td + td + td {
        width: 120px;
        text-align:center;
    }

    head:first-child+body tbody[class].scrollContent td + td + td + td {
        width: 120px;
        text-align:center;
    }

    head:first-child+body tbody[class].scrollContent td + td + td + td + td {
        border-right: none;
        padding: 2px 4px 2px 3px;
        width: 120px;
        text-align:center;

        /* expression is for WinIE 5.x only. Remove to validate and for pure CSS solution */
        top: expression(document.getElementById("tableContainer").scrollTop);
    }
    -->
    </style>

    <script langauge = "javascript">
        function SelectArticle(checkbox_name,default_checkbox)
        {
            var rownos = document.getElementsByName(checkbox_name);
            for (var i = 0; i < rownos.length; i++)
            {
               rownos[i].checked = default_checkbox.checked;
            }
        }

        function jsDownUpRow(trObj, step)
        {
          var tblObj;
          var obj = trObj;
          while( obj.parentNode)
          {
              if( obj.tagName =='TABLE')
              {
                  tblObj = obj; break;
              }
              obj = obj.parentNode;
          }
          var newTR = $(trObj).clone();
          var newIdx = trObj.rowIndex + step;
          if( newIdx <1 || newIdx >=tblObj.rows.length) return;
          if( step > 0)
          {
              $( tblObj.rows[newIdx]).after(newTR);
          }
          else
          {
              $( tblObj.rows[newIdx]).before(newTR);
          }
          $(trObj).remove();
        }

        function jsDownUp(obj, step)
        {
           var tdObj, trObj;
           while( obj.parentNode)
           {
              obj = obj.parentNode;
              if( obj.tagName =='TD') tdObj = obj;
              if( obj.tagName =='TR') trObj = obj;
           }
           jsDownUpRow(trObj, step);
        }

        function jsDownUpRows(step)
        {
            if( step ==0) return;

            var table = document.getElementById('table_publish');
            var trObj = null;
            var trArray = new Array();

            var idObjs = document.getElementsByName("artid");
            if( !idObjs ) return;
            for(var i =0; i < idObjs.length; i++)
            {
                if( !idObjs[i].checked ) continue;

                var obj = idObjs[i];
                while( obj.parentNode)
                {
                    if( obj.tagName =='TR'){ trObj = obj; break; }
                    obj = obj.parentNode;
                }
                if(trObj) trArray.push(trObj);
            }
            if( trArray.length ==0) return;

            if( step >0)
            {
                trObj = trArray[ trArray.length -1];
                if( trObj.rowIndex >= table.rows.length -1) return;
                for(var i = trArray.length -1; i>=0; i --) jsDownUpRow(trArray[i], step);
            }
            else
            {
                trObj = trArray[0];
                if( trObj.rowIndex <=1) return;
                for(var i =0; i < trArray.length; i ++) jsDownUpRow(trArray[i], step);
            }
        }

        function f_add2publish()
        {
            var idObjs = document.getElementsByName("pending_id") ;
            if( !idObjs ) return;

            var table_pending = document.getElementById('table_pending');
            var table_publish = document.getElementById('table_publish');
            var tdObj, trObj;
            var insertIdx = -1;
            for (var i = idObjs.length-1;  i>=0; i--)
            {
                if( !idObjs[i].checked ) continue;
                tdObj = idObjs[i].parentNode;
                while( tdObj.parentNode){ if( tdObj.tagName =='TD') break; }
                trObj = tdObj.parentNode;

                var tr, td =null;
                var tr = table_publish.insertRow(insertIdx);
                insertIdx = tr.rowIndex;
                var szHtml;

                for(var colIdx=0; colIdx<5; colIdx++)
                {
                    var srcTD = trObj.cells[colIdx];
                    cell = tr.insertCell(-1);
                    $(cell).css('text-align', $(srcTD).css('text-align') );
                    $(cell).css('color', $(srcTD).css('color') );
                    $(cell).css('width', $(srcTD).css('width') );
                    if(colIdx == 0)
                    {
                        szArtId = $(srcTD).find("input").val();
                        szHtml = "<input type='checkBox' name='artid' value ='" + szArtId + "'>";
                        szHtml += "<input type='hidden' name='id_publish' value='" + szArtId + "'>";
                        szHtml += "<image src='/images/pending.jpg' border=0/>";
                        $(cell).html( szHtml );
                    }
                    else
                    {
                        $(cell).html( srcTD.innerHTML );
                    }
                }
                table_pending.deleteRow( trObj.rowIndex);
            }
        }

        function f_off()
        {
            var idObjs = document.getElementsByName("artid");
            if( !idObjs ) return;

            var table_publish = document.getElementById('table_publish');
            var table_pending = document.getElementById('table_pending');
            var tdObj, trObj;
            var insertIdx = -1;

            for (var i=idObjs.length-1;  i>=0; i--)
            {
                if( !idObjs[i].checked ) continue;
                tdObj = idObjs[i].parentNode;
                while( tdObj.parentNode){ if( tdObj.tagName =='TD') break; }
                trObj = tdObj.parentNode;
                var tr, td =null;
                var tr = table_pending.insertRow(insertIdx);

                insertIdx = tr.rowIndex;
                var szHtml;
                for(var colIdx=0; colIdx<5; colIdx++)
                {
                    var srcTD = trObj.cells[colIdx];

                    cell = tr.insertCell( tr.cells.length);
                    $(cell).css('text-align', $(srcTD).css('text-align') );
                    $(cell).css('color', $(srcTD).css('color') );
                    $(cell).css('width', $(srcTD).css('width') );
                    if(colIdx == 0)
                    {
                       szArtId = $(srcTD).find("input").val();
                       szHtml = "<input type='checkBox' name='pending_id' value ='" + szArtId + "'>";
                       szHtml += "<input type='hidden' name='id_pending' value='" + szArtId + "'>";
                       szHtml += "<image src='/images/off.jpg' border=0/>";
                       $(cell).html( szHtml );
                    }
                    else
                    {
                        $(cell).html( srcTD.innerHTML );
                    }
                }
                table_publish.deleteRow(trObj.rowIndex);
            }
        }

        function f_new()
        {
            document.frm.action	= "linkinfo.jsp";
            document.frm.target="_blank";
            document.frm.submit();
        }

        function f_delete()
        {
            var rownos = document.getElementsByName("artid");
            var hasChecked = false;
            for (var i = 0; i < rownos.length; i++)
            {
               if( rownos[i].checked ){ hasChecked = true; break; }
            }
            if( !hasChecked ) return false;

            r = confirm("<%=bundle.getString("LINKLIST_DELALERT")%>");
            if( r !=1 ) return false;

            document.frm.action = "linklist.jsp?job=delete";
            document.frm.target="_self";
            document.frm.submit();
        }

        function f_delete2()
        {
            var rownos = document.getElementsByName("pending_id");
            var hasChecked = false;
            for (var i = 0; i < rownos.length; i++)
            {
               if( rownos[i].checked ){ hasChecked = true; break; }
            }
            if( !hasChecked ) return false;

            r = confirm("<%=bundle.getString("LINKLIST_DELALERT")%>");
            if( r !=1 ) return false;

            document.frm.action = "linklist.jsp?job=del_pending";
            document.frm.target="_self";
            document.frm.submit();
        }

        function f_save()
        {
            document.frm.action="linklist.jsp?job=save";
            document.frm.target="_self";
            document.frm.submit();
        }

        function f_publish()
        {
            document.frm.action="linklist.jsp?job=publish";
            document.frm.target="_self";
            document.frm.submit();
        }

        function f_addart()
        {
            document.frm.action	= "selectarticles.jsp";
            document.frm.target="_blank";
            document.frm.submit();
        }

        function f_refresh()
        {
            if(parent)
            {
                parent.frames["topicNav"].window.f_setpreview(document.frm.image_preview.checked);
                parent.frames["topicNav"].window.f_sethtmlescape(document.frm.html_escape.checked);
            }

            document.frm.action="linklist.jsp";
            document.frm.target="_self";
            document.frm.submit();
        }
    </script>
    </HEAD>
<BODY>
<%
    String sql = "select * from article_sort where siteid=? and topic=? and (state=2 or state=3) order by idx";
    pstmt = wrapper.GetContext().GetConnection().prepareStatement(sql);
    pstmt.setString(1,site.GetId());
    pstmt.setString(2,top.GetId());
    rs = pstmt.executeQuery();
%>
<form name="frm" method = "post">
<input type="hidden" name="site_id" value="<%=site_id%>">
<input type="hidden" name="top_id" value="<%=top_id%>">
  <table width = "100% " border = "0" cellpadding = "0" cellspacing = "0" class="PositionBar">
    <tr height="30">
      <td valign="middle">&nbsp;
    <%
        if(user.IsSysAdmin() || user.IsSiteAdmin(site_id) || top.IsOwner(user.GetUID()))
        {
    %>
        <input name="saveBtn" type="button" onClick="f_save()" value="<%=bundle.getString("LINKLIST_SAVEBUTTON")%>" class="button">
        <input name="offBut" type="button" onclick="f_off()" value="<%=bundle.getString("LINKLIST_OFFBUTTON")%>" class="button">
        <input name="delBtn" type="button" onClick="f_delete()" value="<%=bundle.getString("LINKLIST_DELBUTTON")%>" class="button">
        <input name="publishBtn" type="button" onClick="f_publish()" value="<%=bundle.getString("LINKLIST_PUBLISHBUTTON")%>" class="button">
        <input name="newBtn" type="button" onClick="f_new()" value="<%=bundle.getString("LINKLIST_NEWBUTTON")%>" class="button">
        <input name="addArtBtn" type="button" onClick="f_addart()" value="<%=bundle.getString("LINKLIST_ADDARTBUTTON")%>" class="button">
        <%@ include file="toolbar_extend.jsp" %>
    <%
        }
    %>
      </td>
      <td style="float:right;padding-right:20px;color:red;font-weight:bold"><%=top.GetName()%></td>
    </tr>
    <tr height="30">
        <td colspan="2">&nbsp;
            <input type="checkbox" name="image_preview" value="1" <% if(bImagePreview) out.print("checked");%>><%=bundle.getString("LINKLIST_IMAGE_PREVIEWED")%>
            <input type="checkbox" name="html_escape" value="1" <% if(bHtmlEscaped) out.print("checked");%>><%=bundle.getString("LINKLIST_HTML_ESCAPED")%>
            <input name="refreshBtn" type="button" onClick="f_refresh()" value="<%=bundle.getString("LINKLIST_REFRESHBUTTON")%>" class="button">
        </td>
    </tr>
  </table>

<div id="tableContainer" class="tableContainer">
  <table id="table_publish" width="100%" border="0" cellpadding="0" cellspacing="0" class="scrollTable">
    <thead class="fixedHeader TitleBar">
      <tr height=30>
	      <th>
    		<input type = "checkBox" name = "AllId" value = "0" onclick = "SelectArticle('artid',this)">
		  </th>
          <th><%=bundle.getString("LINKLIST_TITLE")%>
            &nbsp;&nbsp;
    <%
       if(user.IsSysAdmin() || user.IsSiteAdmin(site_id) || top.IsOwner(user.GetUID()))
       {
    %>
            <a href="javascript:void(0)" onclick="jsDownUpRows(-1)"><img src='/images/up.gif' border='0'></a>
		    <a href="javascript:void(0)" onclick="jsDownUpRows(1)"><img src='/images/down.gif' border='0'></a>
    <%
        }
    %>
          </th>
		  <th><%=bundle.getString("LINKLIST_CREATOR")%></th>
          <th><%=bundle.getString("LINKLIST_SOURCE")%></th>
          <th><%=bundle.getString("LINKLIST_UPDATEDATE")%></th>
      </tr>
  </thead>

  <tbody class="scrollContent">
<%
    while (rs.next())
    {
%>
      <tr height=25 class="<%=rs.getRow()%2==1?"normalRow":"alternateRow"%>">
        <td>
          <input type = "checkBox" name="artid" value = "<%= rs.getString("id") %>"><%if(rs.getInt("state")==2){%><image src="/images/pending.jpg" alt="<%=bundle.getString("LINKLIST_HINT_PENDING")%>" border=0/><%}%><input type="hidden" name="id_publish" value="<%=rs.getString("id")%>">
        </td>
        <td valign=middle>
       <%
           if(bImagePreview && rs.getString("img_url")!=null)
           {
       %>
            <img src="<%=rs.getString("img_url")%>" border="0" style="max-width:220px;max-height: 220px;vertical-align: middle;">
       <%
           }

           if(bHtmlEscaped)
           {
       %>
           <span style="font-weight:bold;"><%=rs.getRow()%>.</span><a href="linkinfo.jsp?id=<%=rs.getString("id")%>" target="_blank"><%=Utils.TransferToHtmlEntity(rs.getString("title"))%></a>
       <%
           }
           else
           {
       %>
             [<a href="linkinfo.jsp?id=<%=rs.getString("id")%>" target="_blank"><%=bundle.getString("LINKLIST_EDIT")%></a>] <span style="font-weight:bold;"><%=rs.getRow()%>.</span><%=rs.getString("title")%>
       <%
           }
       %>
        </td>
        <td>
           <%=Utils.Null2Empty(rs.getString("creator_name"))%>
        </td>
        <td>&nbsp;
         <%
             if(rs.getString("src_url")!=null)
             {
         %>
              <a href="<%=rs.getString("src_url")%>" target="_blank">
              <%=bundle.getString("LINKLIST_VIEW_SOURCE")%>
              </a>
         <%
             }
         %>
        </td>
        <td>
           <%= Utils.FormateDate(rs.getDate("UPDATEDATE"),"yyyy-MM-dd") %>
        </td>
      </tr>
<%
    }
%>
    </tbody>
 </table>
</div>

<%
    try{rs.close();}catch(Exception e){}
    try{pstmt.close();}catch(Exception e){}

    sql = "select * from article_sort where siteid=? and topic=? and (state=0 or state=1) order by updatedate desc";
    pstmt = wrapper.GetContext().GetConnection().prepareStatement(sql);
    pstmt.setString(1,site.GetId());
    pstmt.setString(2,top.GetId());
    rs = pstmt.executeQuery();
%>

<table style="padding-top:20px;padding-bottom:5px;" width="100%" border = "0" cellpadding = "0" cellspacing = "0" class="PositionBar">
    <tr>
      <td valign="middle">&nbsp;
        <input name="addBtn" type="button" onClick="f_add2publish()" value="<%=bundle.getString("LINKLIST_ADDBUTTON")%>" class="button">
        <input name="delBtn" type="button" onClick="f_delete2()" value="<%=bundle.getString("LINKLIST_DELBUTTON")%>" class="button">
      </td>
      <td style="float:right;padding-right:5px;color:red;font-weight:bold;"><%=bundle.getString("LINKLIST_ZONE_PENDING")%></td>
    </tr>
</table>

<table id="table_pending" width="100%" border = "0" cellpadding = "0" cellspacing = "1" class="TitleBar">
    <tbody>
    <tr height=30>
        <td width="35">
          <input type = "checkBox" name = "AllId" value = "0" onclick = "SelectArticle('pending_id',this)">
        </td>
        <td width="300"><%=bundle.getString("LINKLIST_TITLE")%></td>
        <td width="80" align="center"><%=bundle.getString("LINKLIST_CREATOR")%></td>
        <td width="80" align="center"><%=bundle.getString("LINKLIST_SOURCE")%></td>
        <td align="center"><%=bundle.getString("LINKLIST_UPDATEDATE")%></td>
    </tr>

      <%
          while(rs.next())
          {
      %>
            <tr height=25 class="DetailBar">
              <td width="45">
                <input type = "checkBox" name="pending_id" value = "<%= rs.getString("id") %>"><%if(rs.getInt("state")==0){%><image src="/images/off.jpg" alt="<%=bundle.getString("LINKLIST_HINT_OFF")%>" border=0/><%}%><input type="hidden" name="id_pending" value="<%=rs.getString("id")%>">
              </td>
              <td width="300" valign="middle">
                   <%
                       if(bImagePreview && rs.getString("img_url")!=null)
                       {
                   %>
                       <img src="<%=rs.getString("img_url")%>" border="0" style="max-width:220px;max-height: 220px;vertical-align: middle;">
                   <%
                       }
                      if(bHtmlEscaped)
                      {
                  %>
                      <a href="linkinfo.jsp?id=<%=rs.getString("id")%>" target="_blank"><%=Utils.TransferToHtmlEntity(rs.getString("title"))%></a>
                  <%
                      }
                      else
                      {
                  %>
                        [<a href="linkinfo.jsp?id=<%=rs.getString("id")%>" target="_blank"><%=bundle.getString("LINKLIST_EDIT")%></a>] <%=rs.getString("title")%>
                  <%
                      }
                  %>
              </td>
              <td width="80" align="center">
                 <%=Utils.Null2Empty(rs.getString("creator_name"))%>
              </td>
              <td width="80" align="center">&nbsp;
                 <%
                     if(rs.getString("src_url")!=null)
                     {
                 %>
                      <a href="<%=rs.getString("src_url")%>" target="_blank">
                      <%=bundle.getString("LINKLIST_VIEW_SOURCE")%>
                      </a>
                 <%
                     }
                 %>
              </td>
              <td align="center">
                 <%= Utils.FormateDate(rs.getDate("UPDATEDATE"),"yyyy-MM-dd") %>
              </td>
            </tr>
      <%
           }
     %>
    </tbody>
 </table>
 </form>
<br><br><br><br><br><br>
</BODY>
</HTML>
<%
    }
    catch(Exception e)
    {
        if(wrapper!=null) wrapper.Rollback();
        throw e;
    }
    finally
    {
        if(rs != null) try{ rs.close();}catch(Exception e){}
        if(pstmt != null) try{ pstmt.close();}catch(Exception e){}
        if(wrapper!=null) wrapper.Clear();
    }
%>
