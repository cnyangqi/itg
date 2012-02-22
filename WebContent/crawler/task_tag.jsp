<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="nps.core.Config" %>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.job.crawler.Tag" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String task_id = request.getParameter("task");
    String id = request.getParameter("id");
    String act = request.getParameter("act");

    boolean bNew = id==null || id.length()==0;
    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_crawltask_tag",user.GetLocale(), Config.RES_CLASSLOADER);

    Connection conn = null;
    Tag tag = null;
    if(act==null || act.length()==0)
    {
        //新建或者查看
        if(!bNew)
        {
            try
            {
                conn = Database.GetDatabase("nps").GetConnection();
                tag = new Tag(conn,id);
            }
            finally
            {
                try{conn.close();}catch(Exception e1){}
            }
        }
    }
    else
    {

        //保存或删除
        try
        {
            conn = Database.GetDatabase("nps").GetConnection();
            conn.setAutoCommit(false);
            if("save".equalsIgnoreCase(act))
            {
                //保存
                String title = request.getParameter("title");
                if(title==null || title.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
                String tag_name = request.getParameter("tag_name");
                if(tag_name==null || tag_name.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
                String way = request.getParameter("way");
                if(way==null || way.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
                String is_nullable = request.getParameter("is_nullable");
                boolean bNullable = "1".equals(is_nullable);

                if(bNew)
                {
                    tag = new Tag(title,tag_name,bNullable);
                    tag.SetTaskId(task_id);
                }
                else
                {
                    tag = new Tag(conn,id);
                    tag.SetTitle(title);
                    tag.SetTagName(tag_name);
                    tag.SetNullable(bNullable);
                    tag.ClearTagClears();
                }

                if("0".equals(way))
                {
                    String tag_start = request.getParameter("tag_start");
                    if(tag_start==null || tag_start.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
                    String tag_end = request.getParameter("tag_end");
                    if(tag_end==null || tag_end.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
                    int page_mode = 0;
                    String s_page_mode = request.getParameter("page_mode");
                    try{page_mode=Integer.parseInt(s_page_mode);}catch(Exception e){}
                    String page_break = request.getParameter("page_break");
                    String s_match_loop = request.getParameter("match_loop");
                    boolean match_loop = "1".equals(s_match_loop);
                    String s_match_page = request.getParameter("match_page");
                    boolean match_page = "1".equals(s_match_page);
                    String s_download_image = request.getParameter("download_image");
                    boolean download_image = "1".equals(s_download_image);
                    String s_download_flash = request.getParameter("download_flash");
                    boolean download_flash = "1".equals(s_download_flash);
                    String s_download_file = request.getParameter("download_file");
                    boolean download_file = "1".equals(s_download_file);
                    String download_file_suffix = request.getParameter("file_suffix");
                    String[] reg_exprs = request.getParameterValues("clear_expression");
                    String[] reg_replacestrs = request.getParameterValues("clear_replacestr");

                    tag.SetHtml();
                    tag.SetTagStart(tag_start);
                    tag.SetTagEnd(tag_end);
                    tag.SetPageMode(page_mode);
                    if(page_mode==Tag.PAGE_MODE_PAGINATOR)
                    {
                        tag.SetPageBreak(Utils.NVL(page_break,Tag.DEFAULT_PAGEBREAK));
                    }
                    tag.SetLoopFlag(match_loop);
                    tag.SetPageFlag(match_page);
                    tag.SetDownloadImageFlag(download_image);
                    tag.SetDownloadFlashFlag(download_flash);
                    tag.SetDownloadFileFlag(download_file);
                    tag.SetDownloadFileSuffix(download_file_suffix);

                    if(reg_exprs!=null && reg_exprs.length>0)
                    {
                        for(int i=0;i<reg_exprs.length;i++)
                        {
                            tag.AddTagClear(reg_exprs[i],reg_replacestrs[i]);
                        }
                    }
                }
                else if("1".equals(way))
                {
                    String const_way = request.getParameter("const_way");
                    if(const_way==null || const_way.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
                    if("0".equals(const_way))
                    {
                        String const_value = request.getParameter("const_value");
                        if(const_value==null || const_value.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
                        tag.SetConst(const_value);
                    }
                    else if("1".equals(const_way))
                    {
                        String const_sysdate_format = request.getParameter("const_sysdate_format");
                        if(const_sysdate_format==null || const_sysdate_format.length()==0) const_sysdate_format = Tag.DEFAULT_DATEFORMAT;
                        tag.SetConst(1,const_sysdate_format);
                    }
                    else if("2".equals(const_way))
                    {
                        String const_random_min = request.getParameter("const_random_min");
                        if(const_random_min==null || const_random_min.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
                        String const_random_max = request.getParameter("const_random_max");
                        if(const_random_max==null || const_random_max.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

                        int min = 0;
                        int max = 0;
                        try { min = Integer.parseInt(const_random_min);} catch(Exception e1){}
                        try { max = Integer.parseInt(const_random_max);} catch(Exception e1){}

                        tag.SetConst(min,max);
                    }
                }

               //保存到数据库
                tag.Save(conn);
                conn.commit();
                out.println("<font color=red>" + bundle.getString("TAG_HINT_SAVED") + "</font>");
%>
               <script type="text/javascript">
                   var isMSIE= (navigator.appName == "Microsoft Internet Explorer");
                   if(parent)
                   {
                        if (isMSIE)
                        {
                            var   rt = new Array(4);
                            rt[0] = "<%=tag.GetId()%>";
                            rt[1] = "<%=Utils.TransferToHtmlEntity(tag.GetTitle())%>";
                            rt[2] = "<%=tag.GetTagName()%>";
                        <%
                            if(tag.isConst())
                            {
                        %>
                            rt[3] = "<%=Utils.TransferToHtmlEntity(tag.GetConstValue())%>";
                            rt[4] = "";
                        <%
                            }
                            else
                            {
                        %>
                            rt[3] = "<%=Utils.TransferToHtmlEntity(tag.GetTagStartString())%>";
                            rt[4] = "<%=Utils.TransferToHtmlEntity(tag.GetTagEndString())%>";
                        <%
                            }
                        %>
                            parent.window.returnValue = rt;
                            parent.window.close();
                        }
                        else
                        {
                        <%
                            if(tag.isConst())
                            {
                        %>
                            parent.opener.f_addtag( "<%=tag.GetId()%>",
                                                    "<%=Utils.TransferToHtmlEntity(tag.GetTitle())%>",
                                                    "<%=tag.GetTagName()%>",
                                                    "<%=Utils.TransferToHtmlEntity(tag.GetConstValue())%>",
                                                    "");
                        <%
                            }
                            else
                            {
                        %>
                            parent.opener.f_addtag( "<%=tag.GetId()%>",
                                                    "<%=Utils.TransferToHtmlEntity(tag.GetTitle())%>",
                                                    "<%=tag.GetTagName()%>",
                                                    "<%=Utils.TransferToHtmlEntity(tag.GetTagStartString())%>",
                                                    "<%=Utils.TransferToHtmlEntity(tag.GetTagEndString())%>");
                        <%
                        }
                        %>
                        }

                        top.close();
                   }
                   else
                   {
                       window.location="task_tag.jsp?id=<%=tag.GetId()%>";
                   }
                </script>
<%

                return;
            }
            else if("del".equalsIgnoreCase(act))
            {
                //删除
                tag = new Tag(conn,id);
                tag.Delete(conn);
                conn.commit();
                out.println("<font color=red>" + bundle.getString("TAG_HINT_DELETED") + "</font>");
                return;
            }
        }
        catch(Exception e1)
        {
            try{conn.rollback();}catch(Exception e2){}
            e1.printStackTrace();
            throw e1;
        }
        finally
        {
            try{conn.close();}catch(Exception e1){}
        }
    }
%>

<html>
  <head>
    <title><%=bNew?bundle.getString("TAG_HTMLTILE"):tag.GetTitle()%></title>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>

    <script language="javascript">
        var clear_rowNo = 0;
        function onclick_way(mode)
        {
            if(mode=="0")
            {
                document.getElementById("div_html").style.display = "block";
                document.getElementById("div_const").style.display = "none";
            }
            else
            {
                document.getElementById("div_html").style.display = "none";
                document.getElementById("div_const").style.display = "block";
            }
        }

        function selectvar()
        {
            var rows = document.getElementsByName("Varrowno");
            if( rows == null) return false;
            for(var i = 0; i < rows.length; i++)
            {
                rows[i].checked = document.frm.VarAllId.checked;
            }
        }

        function add_clear()
        {
            clear_rowNo = clear_rowNo + 1;
            var tbody = document.getElementById("div_clear").getElementsByTagName("TBODY")[0];

            var row = document.createElement("TR");
            row.setAttribute("id","ClearRow_" + clear_rowNo);

            var td = document.createElement("TD");
            var input1 = document.createElement("INPUT");
            input1.setAttribute("type","checkbox");
            input1.setAttribute("id","Clearrowno");
            input1.setAttribute("name","Clearrowno");
            input1.setAttribute("value",clear_rowNo);
            td.appendChild(input1);
            row.appendChild(td);

            td = document.createElement("TD");
            input1 = document.createElement("TEXTAREA");
            input1.setAttribute("name","clear_expression");
            input1.setAttribute("rows","3");
            input1.setAttribute("cols","20");
            td.appendChild(input1);
            row.appendChild(td);

            td = document.createElement("TD");
            input1 = document.createElement("TEXTAREA");
            input1.setAttribute("name","clear_replacestr");
            input1.setAttribute("rows","3");
            input1.setAttribute("cols","20");
            td.appendChild(input1);
            row.appendChild(td);
            
            tbody.appendChild(row);
        }

        function del_clear()
        {
            var rows = document.getElementsByName("Clearrowno");
            if( rows == null) return false;
            for(var i = 0; i < rows.length; i++)
            {
                if(rows[i].checked)
                {
                    var tr = document.getElementById("ClearRow_" + rows[i].value);
                    if( tr == null) continue;
                    tr.parentNode.removeChild(tr);
                }
            }
        }

        function f_save()
        {
            if(document.frm.title.value=="")
            {
                alert("<%=bundle.getString("TAG_ALERT_TITLE_IS_NULL")%>");
                return false;
            }

            if(document.frm.tag_name.value=="")
            {
                alert("<%=bundle.getString("TAG_ALERT_TAGNAME_IS_NULL")%>");
                return false;
            }

            var way="";
            var ways = document.getElementsByName("way");
            if( ways != null)
            {
                for(var i = 0; i < ways.length; i++)
                {
                    if(ways[i].checked)
                    {
                        way = ways[i].value;
                        break;
                    }
                }
                if(way=="")
                {
                    alert("<%=bundle.getString("TAG_ALERT_WAY_IS_NULL")%>");
                    return false;
                }
            }

            if(way=="0")
            {
                if(document.frm.tag_start.value=="")
                {
                    alert("<%=bundle.getString("TAG_ALERT_TAGSTART_IS_NULL")%>");
                    return false;
                }

                if(document.frm.tag_end.value=="")
                {
                    alert("<%=bundle.getString("TAG_ALERT_TAGEND_IS_NULL")%>");
                    return false;
                }
            }
            else if(way=="1")
            {
                var const_way = "";
                var const_ways = document.getElementsByName("const_way");
                if( const_ways != null)
                {
                  for(var i = 0; i < const_ways.length; i++)
                    {
                        if(const_ways[i].checked)
                        {
                            const_way = const_ways[i].value;
                            break;
                        }
                    }
                    if(const_way=="")
                    {
                        alert("<%=bundle.getString("TAG_ALERT_CONSTWAY_IS_NULL")%>");
                        return false;
                    }
                }

                if(const_way=="0")
                {
                    if(document.frm.const_value.value=="")
                    {
                        alert("<%=bundle.getString("TAG_ALERT_CONSTVALUE_IS_NULL")%>");
                        return false;    
                    }
                }
                else if(const_way=="1")
                {
                    if(document.frm.const_sysdate_format.value=="")
                    {
                        alert("<%=bundle.getString("TAG_ALERT_CONST_SYSDATE_FORMAT_IS_NULL")%>");
                        return false;
                    }
                }
                else if(const_way=="2")
                {
                    var min = document.frm.const_random_min.value;
                    var max = document.frm.const_random_max.value;
                    if(min=="" || max=="")
                    {
                        alert("<%=bundle.getString("TAG_ALERT_CONST_RANDOM_IS_NULL")%>");
                        return false;    
                    }

                    if (!min.isNumber() || !max.isNumber())
                    {
                        alert("<%=bundle.getString("TAG_ALERT_CONST_RANDOM_IS_NOT_NUMBER")%>");
                        return false;
                    }
                }
            }

            document.frm.act.value = "save";
            document.frm.submit();
        }

        function f_delete()
        {
            document.frm.act.value = "del";
            document.frm.submit();
        }
    </script>
  </head>

  <body leftmargin="20">
  <form name="frm" method="post" action ="task_tag.jsp">
     <input type="hidden" name="task" value="<%= bNew?task_id:tag.GetTaskId() %>">
     <input type="hidden" name="id" value="<%= bNew?"":id %>">
     <input type="hidden" name="act" value="">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr height=30>
        <td>&nbsp;
           <input type="button" name="savebtn" value="<%=bundle.getString("TAG_BUTTON_SAVE")%>" class="button" onclick="f_save()">
        <%
            if(!bNew)
            {
        %>
           <input type="button" name="delbtn" value="<%=bundle.getString("TAG_BUTTON_DELETE")%>" class="button" onclick="f_delete()">
        <%
            }
        %>
           <input type="button" name="closebtn" value="<%=bundle.getString("TAG_BUTTON_CLOSE")%>" class="button" onclick="javascript:window.close();">
        </td>
      </tr>
  </table>

  <table width="100%" cellpadding = "0" cellspacing = "0" border="1">
    <tr height="25">
      <td width=100 align=center><font color="red"><%=bundle.getString("TAG_TITLE")%></font></td>
      <td>
        <input type=text name="title" value="<%= tag==null?"":tag.GetTitle() %>" style="width:98%">
      </td>
    </tr>
    <tr height="25">
      <td align=center><font color="red"><%=bundle.getString("TAG_NAME")%></font></td>
      <td>
          <input type=text name="tag_name" value="<%= tag==null?"":tag.GetTagName() %>">
          <input type=checkbox name="is_nullable" value="1" <% if(bNew || tag.isNullable()) out.print("checked"); %>><%=bundle.getString("TAG_NULL")%>
      </td>
    </tr>
    <tr height="25">
        <td align=center><font color="red"><%=bundle.getString("TAG_WAY")%></font></td>
        <td>
            <input type="radio" name="way" value="0" onclick="onclick_way(0)" <% if(bNew || tag.GetWay()==0) out.print("checked"); %>><%=bundle.getString("TAG_WAY_HTML")%>
            <input type="radio" name="way" value="1" onclick="onclick_way(1)" <% if(tag!=null && tag.GetWay()==1) out.print("checked"); %>><%=bundle.getString("TAG_WAY_CONST")%>
        </td>
    </tr>
  </table>

  <table id="div_html" width="100%" cellpadding = "0" cellspacing = "0" border="1" style="display:<%=(bNew||(tag!=null && !tag.isConst()))?"block":"none"%>">
      <tr height="25">
          <td align=center><%=bundle.getString("TAG_MATCH")%></td>
          <td colspan=3>
              <input type=checkbox name="match_loop" value="1" <% if(tag!=null && tag.matchLoop()) out.print("checked"); %>><%=bundle.getString("TAG_MATCH_LOOP")%>
              <input type=checkbox name="match_page" value="1" <% if(tag!=null && tag.matchPage()) out.print("checked"); %>><%=bundle.getString("TAG_MATCH_PAGE")%>
          </td>
      </tr>
      <tr height="25">
          <td align=center><%=bundle.getString("TAG_DOWNLOAD")%></td>
          <td colspan=3>
              <input type=checkbox name="download_image" value="1" <% if(tag!=null && tag.downloadImage()) out.print("checked"); %>><%=bundle.getString("TAG_DOWNLOAD_IMAGE")%>
              <input type=checkbox name="download_flash" value="1" <% if(tag!=null && tag.downloadFlash()) out.print("checked"); %>><%=bundle.getString("TAG_DOWNLOAD_FLASH")%>
              <input type=checkbox name="download_file" value="1" <% if(tag!=null && tag.downloadFile()) out.print("checked"); %>><%=bundle.getString("TAG_DOWNLOAD_FILE")%>
              <input type="text" name="file_suffix" value="<% if(tag!=null) out.print(Utils.Null2Empty(tag.GetDownloadFileSuffix())); %>" style="width:80px">
          </td>
      </tr>
      <tr height="25">
          <td width=100 align=center><font color="red"><%=bundle.getString("TAG_START")%></font></td>
          <td width="200">
              <textarea name="tag_start" rows="3" cols="10" style="width:100%"><% if(tag!=null) out.print(Utils.Null2Empty(tag.GetTagStartString())); %></textarea>
          </td>
          <td width=100 align=center><font color="red"><%=bundle.getString("TAG_END")%></font></td>
          <td width="200">
              <textarea name="tag_end"  rows="3" cols="10" style="width:100%"><% if(tag!=null) out.print(Utils.Null2Empty(tag.GetTagEndString())); %></textarea>
          </td>
      </tr>
      <tr height="25">
          <td align=center><font color="red"><%=bundle.getString("TAG_MULTI_RECORDS")%></font></td>
          <td colspan=3>
              <input type=radio name="page_mode" value="0" <% if(tag!=null && tag.GetPageMode()==0) out.print("checked"); %>><%=bundle.getString("TAG_MULTI_RECORDS_NEW")%>
              <br>
              <input type=radio name="page_mode" value="1" <% if(tag!=null && tag.GetPageMode()==1) out.print("checked"); %>><%=bundle.getString("TAG_MULTI_RECORDS_JOIN")%>
              &nbsp;<%=bundle.getString("TAG_MULTI_RECORDS_JOIN_STRING")%><br>
              <textarea name="page_break" rows=3 cols=10 style="width:100%"><% if(tag!=null && tag.GetPageMode()==1) out.print(tag.GetPageBreak()); %></textarea>
          </td>
      </tr>
      <tr>
          <td colspan="4">
              <table id="div_clear" width="100%" cellpadding = "0" cellspacing = "1" border="0">
              <TBODY>
              <tr >
                <td colspan="3">
                   <b><%=bundle.getString("TAG_CLEAR")%></b>
                   <input type=button class="button" value="<%=bundle.getString("TAG_BUTTON_ADD_CLEAR")%>" onclick="javascript:add_clear();">
                   <input type=button class="button" value="<%=bundle.getString("TAG_BUTTON_DEL_CLEAR")%>" onclick="javascript:del_clear();">
                </td>
              </tr>
              <tr>
                 <td width=25><input type = "checkBox" name = "ClearAllId" value = "0" onclick = "javascript:selectclear();"></td>
                 <td width=240 align="left"><%=bundle.getString("TAG_CLEAR_EXPRESSION")%></td>
                 <td width=240 align="left"><%=bundle.getString("TAG_CLEAR_REPLACE_STRING")%></td>
              </tr>
              <%
                  int rows = 0;
                  if(tag!=null)
                  {
                      ArrayList<Tag.TagClear> clears = tag.GetTagClears();
                      if(clears!=null && !clears.isEmpty())
                      {
                        for(Tag.TagClear clear: clears)
                        {
              %>
                <tr id='ClearRow_<%=rows%>'>
                  <td>
                      <input type="checkbox" id="Clearrowno" name="Clearrowno" value="<%=rows%>">
                  </td>
                  <td>
                      <textarea name="clear_expression" rows=3 cols=20><%=clear.GetPattern()%></textarea>
                  </td>
                  <td>
                      <textarea name="clear_replacestr" rows=3 cols=20><%=Utils.Null2Empty(clear.GetReplaceString())%></textarea>
                  </td>
                </tr>
              <%
                               rows++;
                           }
                      }
                  }
              %>
                  <script language="javascript">clear_rowNo = <%= rows %>;</script>
                </TBODY>
              </table>
          </td>
      </tr>
  </table>

  <table id="div_const" width="100%" cellpadding = "0" cellspacing = "0" border="1" style="display:<%=tag!=null && tag.isConst()?"block":"none"%>">
     <tr height="25">
         <td width="100">
             <input type="radio" name="const_way" value="0" <% if(tag!=null && tag.isConst() && tag.GetWayFixed()==0) out.print("checked"); %>><%=bundle.getString("TAG_CONST_STRING")%>
         </td>
         <td>
             <textarea name="const_value" rows="3" cols="40"><% if(tag!=null && tag.isConst() && tag.GetWayFixed()==0) out.print(Utils.Null2Empty(tag.GetFixedString())); %></textarea>
         </td>
     </tr>
     <tr height="25">
         <td>
             <input type="radio" name="const_way" value="1" <% if(tag!=null && tag.isConst() && tag.GetWayFixed()==1) out.print("checked"); %>><%=bundle.getString("TAG_CONST_SYSDATE")%>
         </td>
         <td>
             <input type="text" name="const_sysdate_format" value="<% if(tag!=null && tag.isConst() && tag.GetWayFixed()==1) out.print(Utils.Null2Empty(tag.GetSysDateFormat())); %>">
             <font color="red"><%=bundle.getString("TAG_HINT_CONST_SYSDATE")%></font>
         </td>
     </tr>
     <tr height="25">
         <td>
             <input type="radio" name="const_way" value="2" <% if(tag!=null && tag.isConst() && tag.GetWayFixed()==2) out.print("checked"); %>><%=bundle.getString("TAG_CONST_RANDOM_NUMBER")%>
         </td>
         <td>
             <%=bundle.getString("TAG_CONST_RANDOM_NUMBER_FROM")%>
             <input type="text" name="const_random_min" value="<% if(tag!=null && tag.isConst() && tag.GetWayFixed()==2) out.print(tag.GetRandomMin()); %>">
             <%=bundle.getString("TAG_CONST_RANDOM_NUMBER_TO")%>
             <input type="text" name="const_random_max" value="<% if(tag!=null && tag.isConst() && tag.GetWayFixed()==2) out.print(tag.GetRandomMax()); %>">
         </td>
     </tr>
  </table>
 </form>
</body>
</html>