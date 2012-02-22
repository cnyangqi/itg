<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.Config" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.job.crawler.URLGenerator" %>
<%@ page import="java.util.ArrayList" %>
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
    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_crawltask_page",user.GetLocale(), Config.RES_CLASSLOADER);

    Connection conn = null;
    URLGenerator generator = null;
    if(act==null || act.length()==0)
    {
        //新建或者查看
        if(!bNew)
        {
            try
            {
                conn = Database.GetDatabase("nps").GetConnection();
                generator = new URLGenerator(conn,id);
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
                String url = request.getParameter("url");
                String page_way = request.getParameter("page_way");
                String sql = null;
                if("1".equals(page_way)) sql = request.getParameter("sql");

                if(!bNew)
                {
                    generator = new URLGenerator(conn,id);
                    generator.SetSQL(sql);
                }
                else
                {
                    generator = new URLGenerator(url,sql);
                    generator.SetTaskId(task_id);
                }

                if("0".equals(page_way))
                {
                    String var_ids[] = request.getParameterValues("var_id");
                    String var_starts[] = request.getParameterValues("var_start");
                    String var_ends[] = request.getParameterValues("var_end");
                    String var_incs[] = request.getParameterValues("var_inc");
                    String var_minlengths[] = request.getParameterValues("var_minlength");
                    String var_pads[] = request.getParameterValues("var_pad");

                    if(!bNew) generator.ClearVars();
                    int size = var_ids==null?0:var_ids.length;
                    for(int i=0;i<size;i++)
                    {
                        if( (var_starts[i]==null || var_starts[i].length()==0)
                           && (var_ends[i]==null || var_ends[i].length()==0))
                            continue;

                        if(var_starts[i]==null || var_starts[i].length()==0)
                            throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

                        if(var_ends[i]==null || var_ends[i].length()==0)
                            throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

                        int type = 1;//字母
                        int start=0,end=0;
                        try
                        {
                            start = Integer.parseInt(var_starts[i]);
                            end = Integer.parseInt(var_ends[i]);
                            type = 0; //数字
                        }
                        catch(Exception e1)
                        {
                        }

                        int var_start;
                        int var_end;
                        switch(type)
                        {
                            case 0: //数字
                                var_start = start;
                                var_end = end;
                                break;
                            default:
                                var_start = (int)var_starts[i].charAt(0);
                                var_end = (int)var_ends[i].charAt(0);
                                break;
                        }

                        int var_inc = 1;
                        try{var_inc = Integer.parseInt(var_incs[i]);}catch(Exception e1){}
                        if(var_pads[i]!=null && var_pads[i].length()>0)
                        {
                            int var_min = 1;
                            try{var_min = Integer.parseInt(var_minlengths[i]);}catch(Exception e1){}
                            generator.AddVar(var_ids[i],type,var_start,var_end,var_inc,var_min,var_pads[i]);
                        }
                        else
                        {
                            generator.AddVar(var_ids[i],type,var_start,var_end,var_inc);
                        }
                    }
                }
                else
                {
                    //SQL
                    if(!bNew) generator.ClearVars();
                }

                //保存到数据库
                generator.Save(conn);
                conn.commit();
                out.println("<font color=red>" + bundle.getString("PAGE_HINT_SAVED") + "</font>");
%>
               <script type="text/javascript">
                   var isMSIE= (navigator.appName == "Microsoft Internet Explorer");
                   if(parent)
                   {
                        if (isMSIE)
                        {
                            var   rt = new Array(4);
                            rt[0] = "<%=generator.GetId()%>";
                            rt[1] = "<%=url%>";
                            parent.window.returnValue = rt;
                            parent.window.close();
                        }
                        else
                        {
                            parent.opener.f_addpage('<%=generator.GetId()%>','<%=url%>');
                        }

                        top.close();
                   }
                   else
                   {
                       window.location="task_page.jsp?task=<%=generator.GetTaskId()%>&id=<%=generator.GetId()%>";
                   }
                </script>
<%

                return;
            }
            else if("del".equalsIgnoreCase(act))
            {
                //删除
                generator = new URLGenerator(conn,id);
                generator.Delete(conn);
                conn.commit();
                out.println("<font color=red>" + bundle.getString("PAGE_HINT_DELETED") + "</font>");
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
    <title><%=bNew?bundle.getString("PAGE_HTMLTILE"):generator.GetPattern()%></title>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>

    <script language="javascript">
        var var_rowNo = 0;
        function onchange_getway(mode)
        {
            if(mode=="0")
            {
                document.getElementById("div_manual").style.display = "block";
                document.getElementById("div_sql").style.display = "none";
            }
            else
            {
                document.getElementById("div_manual").style.display = "none";
                document.getElementById("div_sql").style.display = "block";
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

        function add_var()
        {
            var_rowNo = var_rowNo + 1;
            var tbody = document.getElementById("div_manual").getElementsByTagName("TBODY")[0];

            var row = document.createElement("TR");
            row.setAttribute("id","VarRow_" + var_rowNo);

            var td = document.createElement("TD");
            var input1 = document.createElement("INPUT");
            input1.setAttribute("type","hidden");
            input1.setAttribute("name","var_id");
            input1.setAttribute("value","");
            td.appendChild(input1);
            input1 = document.createElement("INPUT");
            input1.setAttribute("type","checkbox");
            input1.setAttribute("id","Varrowno");
            input1.setAttribute("name","Varrowno");
            input1.setAttribute("value",var_rowNo);
            td.appendChild(input1);
            row.appendChild(td);

            td = document.createElement("TD");
            input1 = document.createElement("INPUT");
            input1.setAttribute("type","text");
            input1.setAttribute("name","var_start");
            input1.setAttribute("value","");
            input1.setAttribute("size","5");
            td.appendChild(input1);
            row.appendChild(td);

            td = document.createElement("TD");
            input1 = document.createElement("INPUT");
            input1.setAttribute("type","text");
            input1.setAttribute("name","var_end");
            input1.setAttribute("value","");
            input1.setAttribute("size","5");
            td.appendChild(input1);
            row.appendChild(td);

            td = document.createElement("TD");
            input1 = document.createElement("INPUT");
            input1.setAttribute("type","text");
            input1.setAttribute("name","var_inc");
            input1.setAttribute("value","");
            input1.setAttribute("size","5");
            td.appendChild(input1);
            row.appendChild(td);

            td = document.createElement("TD");
            input1 = document.createElement("INPUT");
            input1.setAttribute("type","text");
            input1.setAttribute("name","var_minlength");
            input1.setAttribute("value","");
            input1.setAttribute("size","5");
            td.appendChild(input1);
            row.appendChild(td);

            td = document.createElement("TD");
            input1 = document.createElement("INPUT");
            input1.setAttribute("type","text");
            input1.setAttribute("name","var_pad");
            input1.setAttribute("value","");
            input1.setAttribute("size","5");
            td.appendChild(input1);
            row.appendChild(td);

            tbody.appendChild(row);
        }

        function del_var()
        {
            var rows = document.getElementsByName("Varrowno");
            if( rows == null) return false;
            for(var i = 0; i < rows.length; i++)
            {
                if(rows[i].checked)
                {
                    var tr = document.getElementById("VarRow_" + rows[i].value);
                    if( tr == null) continue;
                    tr.parentNode.removeChild(tr);
                }
            }
        }
        
        function f_save()
        {
            if(document.frm.url.value=="")
            {
                alert("<%=bundle.getString("PAGE_ALERT_URL_IS_NULL")%>");
                return false;
            }

            var var_starts = document.getElementsByName("var_start");
            if( var_starts != null)
            {
                for(var i = 0; i < var_starts.length; i++)
                {
                    if(var_starts[i]=="")
                    {
                        alert("<%=bundle.getString("PAGE_ALERT_START_IS_NULL")%>");
                        return false;
                    }
                }
            }

            var var_ends = document.getElementsByName("var_end");
            if( var_ends != null)
            {
                for(var i = 0; i < var_ends.length; i++)
                {
                    if(var_ends[i]=="")
                    {
                        alert("<%=bundle.getString("PAGE_ALERT_END_IS_NULL")%>");
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
  <form name="frm" method="post" action ="task_page.jsp">
     <input type="hidden" name="task" value="<%= bNew?task_id:generator.GetTaskId() %>">
     <input type="hidden" name="id" value="<%= bNew?"":id %>">
     <input type="hidden" name="act" value="">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr height=30>
        <td>&nbsp;
           <input type="button" name="savebtn" value="<%=bundle.getString("PAGE_BUTTON_SAVE")%>" class="button" onclick="f_save()">
        <%
            if(!bNew)
            {
        %>
           <input type="button" name="delbtn" value="<%=bundle.getString("PAGE_BUTTON_DELETE")%>" class="button" onclick="f_delete()">
        <%
            }
        %>
           <input type="button" name="closebtn" value="<%=bundle.getString("PAGE_BUTTON_CLOSE")%>" class="button" onclick="javascript:window.close();">
        </td>
      </tr>
  </table>

  <table width="100%" cellpadding = "0" cellspacing = "0" border="1">
    <tr height="25">
      <td width=100 align=center><font color="red"><%=bundle.getString("PAGE_URL")%></font></td>
      <td>
        <input type=text name="url" value="<%= generator==null?"":generator.GetPattern() %>" style="width:98%">
        <br>
        <font color="red"><%=bundle.getString("PAGE_URL_SAMPLE")%></font>
        <br>
        <%=bundle.getString("PAGE_URL_HINT")%>  
      </td>
    </tr>
    <tr height="25">
      <td align=center><font color="red"><%=bundle.getString("PAGE_GETWAY")%></font></td>
      <td>
          <select name="page_way" onchange="onchange_getway(this.options[this.selectedIndex].value)">
              <option value="0" <% if(bNew || (generator!=null && generator.GetSQL()==null)) out.print("selected"); %>><%=bundle.getString("PAGE_GETWAY_MANUAL")%></option>
              <option value="1" <% if(generator!=null && generator.GetSQL()!=null) out.print("selected"); %>><%=bundle.getString("PAGE_GETWAY_SQL")%></option>
          </select>
      </td>
    </tr>
    <tr id="div_sql" height="25" style="display:<%=(generator!=null && generator.GetSQL()!=null)?"block":"none"%>">
        <td align=center><%=bundle.getString("PAGE_SQL")%></td>
        <td>
            <textarea id="sql" name="sql" rows="10" cols="50" style="width:100%"><% if(generator!=null && generator.GetSQL()!=null) out.print(generator.GetSQL()); %></textarea>
        </td>
    </tr>
  </table>

  <table id="div_manual" width="100%" cellpadding = "0" cellspacing = "1" border="0" style="display:<%=(bNew||(generator!=null && generator.GetSQL()==null))?"block":"none"%>">
  <TBODY>
  <tr >
    <td colspan="6">
       <b><%=bundle.getString("PAGE_VARS")%></b>
       &nbsp;&nbsp;
       <input type=button class="button" value="<%=bundle.getString("PAGE_BUTTON_ADD_VAR")%>" onclick="javascript:add_var();">
       <input type=button class="button" value="<%=bundle.getString("PAGE_BUTTON_DEL_VAR")%>" onclick="javascript:del_var();">
    </td>
  </tr>
  <tr>
     <td width=25><input type = "checkBox" name = "VarAllId" value = "0" onclick = "javascript:selectvar();"></td>
     <td width=60 align="left"><%=bundle.getString("PAGE_VAR_START")%></td>
     <td width=60 align="left"><%=bundle.getString("PAGE_VAR_END")%></td>
     <td width=60 align="left"><%=bundle.getString("PAGE_VAR_INC")%></td>
     <td width=60 align="left"><%=bundle.getString("PAGE_VAR_MINLENGTH")%></td>
     <td align="left"><%=bundle.getString("PAGE_VAR_PAD")%></td>
  </tr>
  <%
      int rows = 0;
      if(generator!=null)
      {
          ArrayList<URLGenerator.Var> vars = generator.GetVars();
          if(vars!=null && !vars.isEmpty())
          {
            for(URLGenerator.Var var: vars)
            {
  %>
    <tr id='VarRow_<%=rows%>'>
      <td>
          <input type="hidden" name="var_id" value="<%=var.GetId()%>">
          <input type="checkbox" id="Varrowno" name="Varrowno" value="<%=rows%>">
      </td>
      <td>
          <input type="text" name="var_start" value="<%=var.GetStartString()%>" style="width:40px">
      </td>
      <td>
          <input type="text" name="var_end" value="<%=var.GetEndString()%>"  style="width:40px">
      </td>
      <td>
          <input type="text" name="var_inc" value="<%=var.GetIncrement()%>"  style="width:40px">
      </td>
      <td>
          <input type="text" name="var_minlength" value="<%=var.GetMinLength()%>"  style="width:40px">
      </td>
      <td>
          <input type="text" name="var_pad" value="<%=Utils.Null2Empty(var.GetPad())%>"  style="width:40px">
      </td>
    </tr>
  <%
                   rows++;
               }
          }
      }
  %>
      <script language="javascript">var_rowNo = <%= rows %>;</script>
    </TBODY>
  </table>
 </form>
</body>
</html>