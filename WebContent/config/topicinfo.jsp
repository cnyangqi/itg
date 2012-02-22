<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.util.List" %>
<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String siteid = request.getParameter("siteid");
    if( siteid == null) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    siteid = siteid.trim();

    String cmd = request.getParameter("cmd");
    String refresh_cmd = request.getParameter("refresh");
    String delete_cmd = request.getParameter("delete");
    String top_parentid = request.getParameter("top_parentid");
    String topid = request.getParameter("topid");
    if(topid!=null) topid = topid.trim();
    if("addchild".equalsIgnoreCase(cmd))
    {
        //添加下级栏目
        top_parentid = topid;
        topid = "";        
    }

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_topicinfo",user.GetLocale(), Config.RES_CLASSLOADER);
    
    int art_state = 0;
    NpsWrapper wrapper = null;
    Site site = null;
    Topic topic = null;

    boolean bNew = (topid==null || topid.length()==0);

    try
    {
        wrapper = new NpsWrapper(user,siteid);
        site = wrapper.GetSite();
        if(site==null) throw new NpsException(ErrorHelper.SYS_NOSITE);
        if(!bNew && (delete_cmd==null || delete_cmd.length()==0))
        {
            TopicTree tree = site.GetTopicTree();
            if(tree==null) throw new NpsException(ErrorHelper.SYS_NOTOPIC);
            topic = tree.GetTopic(topid);
            if(topic==null) throw new NpsException(ErrorHelper.SYS_NOTOPIC);
            if(topic!=null)   art_state = topic.GetDefaultArticleState();

            wrapper.SetErrorHandler(response.getWriter());
            wrapper.SetLineSeperator("<br>");
            if("rebuild_downtop".equalsIgnoreCase(cmd))
            {
                //重建栏目
                out.println("<br>");
                out.println("&nbsp;&nbsp;"+bundle.getString("TOPIC_BUILD_INPROGRESS")+"<b><font color=red>"+topic.GetName()+"</font></b>......");
                out.println("<br>");
                int rows = wrapper.GenerateAllArticles(topic,true);
                wrapper.GenerateAllPages(topic);
                out.println("&nbsp;&nbsp;<b>rows="+rows+" updated</b><br>");
                out.println("&nbsp;&nbsp;<font color=red><b>"+topic.GetName()+"</b></font>"+bundle.getString("TOPIC_BUILD_SUCCESS"));
                out.println("<br>");
            }
            else if("rebuild_topdown".equalsIgnoreCase(cmd))
            {
                //重建栏目
                out.println("<br>");
                out.println("&nbsp;&nbsp;"+bundle.getString("TOPIC_BUILD_INPROGRESS")+"<b><font color=red>"+topic.GetName()+"</font></b>......");
                out.println("<br>");
                int rows =  wrapper.GenerateAllArticlesTopDown(topic,true);
                wrapper.GenerateAllPagesTopDown(topic);
                out.println("&nbsp;&nbsp;<b>rows="+rows+" updated</b><br>");
                out.println("&nbsp;&nbsp;<font color=red><b>"+topic.GetName()+"</b></font>"+bundle.getString("TOPIC_BUILD_SUCCESS"));
                out.println("<br>");
            }
            else if("sync".equalsIgnoreCase(cmd))
            {
                int rows = wrapper.SyncDatasource(topic);
                out.println("<br>");
                out.println("&nbsp;&nbsp;<font color=red><b>"+ rows + bundle.getString("TOPIC_SYNC_SUCCESS") + "</font>");
                out.println("<br>");
            }
            else if("archive".equalsIgnoreCase(cmd))
            {
                wrapper.ArchiveTopic(topic);
                out.println("<br>");
                out.println("&nbsp;&nbsp;<font color=red><b>"+ topic.GetName() + bundle.getString("TOPIC_ARCHIVE_SUCCESS") + "</font>");
                out.println("<br>");
            }
        }
%>

<html>
<head>
  <title><%=topic==null?bundle.getString("TOPIC_HTMLTITLE"):topic.GetName()%></title>
    <script language = "javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>

  <SCRIPT language="JavaScript">
    var totalRows =0;
    var totalUserRows =0;
    var totalVarRows =0;
    var totalTriggerRows =0;
    var totalSolrRows =0;
<%  
    //如果需要刷新左侧树型结构
    if(refresh_cmd!=null && refresh_cmd.length()>0 && topic!=null)
    {
%>
        if(parent)
        {
            var topictree = parent.frames["topicList"].window.topictree;

            var node = topictree.getItemText('<%=siteid%>.<%=topid%>');
            if(node)
            {
                 topictree.setItemText('<%=siteid%>.<%=topid%>','<%=topic.GetName()%>');
                 topictree.setUserData('<%=siteid%>.<%=topid%>','siteid','<%=siteid%>');
                 topictree.setUserData('<%=siteid%>.<%=topid%>','sitename','<%=Utils.TransferToHtmlEntity(site.GetName())%>');
                 topictree.setUserData('<%=siteid%>.<%=topid%>','topid','<%=topid%>');
                 topictree.setUserData('<%=siteid%>.<%=topid%>','topname','<%=Utils.TransferToHtmlEntity(topic.GetName())%>');
            }
            else  //是新增的节点
            {
<%
            String node_parentname = null;
            if(topic.GetParentId()==null || topic.GetParentId().length()==0 ||"-1".equalsIgnoreCase(topic.GetParentId()))
            {
                node_parentname = siteid;
            }
            else
            {
                node_parentname = siteid+"."+topic.GetParentId();
            }

            String node_id = siteid + "." + topid;
            String jstree = "topictree.insertNewItem('" + node_parentname + "',"
                                                      + "'"+ node_id +"',"
                                                      +"\""+ Utils.TranferToXmlEntity(topic.GetName()) +"\",0,0,0,0,'SELECT');";
            jstree += "topictree.setUserData('"+node_id+"',"
                                                +"'siteid',"
                                                +"'"+ siteid +"');";

            jstree += "topictree.setUserData('"+node_id+"',"
                                                +"'sitename',"
                                                +"\""+ Utils.TranferToXmlEntity(site.GetName()) +"\");";

            jstree += "topictree.setUserData('"+node_id+"',"
                                               +"'topid',"
                                               +"'" + topid +"');";

            jstree += "topictree.setUserData('"+node_id+"',"
                                               +"'topname',"
                                               +"\"" + Utils.TranferToXmlEntity(topic.GetName()) +"\");";
             out.println(jstree);
%>
            }
          }
<%
    }

    if(delete_cmd!=null && delete_cmd.length()>0)
    {
%>
        if(parent)
        {
            var topictree = parent.frames["topicList"].window.topictree;

            var node = topictree.getItemText('<%=siteid%>.<%=topid%>');
            if(node)
            {
                topictree.deleteItem('<%=siteid%>.<%=topid%>');
            }
        }
<%
       topid="";
       bNew=true;
    }
%>
    function f_submit()
    {
        if( document.frm.top_alias.value.trim() == '' )
        {
            alert("<%=bundle.getString("TOPIC_ALERT_NO_ALIAS")%>");
            document.frm.top_alias.focus();
            return false;
        }
        if(document.frm.archive_mode.value!="0")
        {
            if(document.frm.top_archive_tmp_id.value=="")
            {
                alert("<%=bundle.getString("TOPIC_ALERT_NO_ARCHIVE")%>");
                return false;
            }
        }
        if( document.frm.top_name.value.trim() == '' )
        {
            alert("<%=bundle.getString("TOPIC_ALERT_NO_NAME")%>");
            document.frm.top_name.focus();
            return false;
        }
        var var_names = document.getElementsByName("var_name");
        if(var_names!=null && var_names.length>0)
        {
            for(var i=0;i<var_names.length;i++)
            {
                if(var_names[i].value.trim()=="")
                {
                    alert("<%=bundle.getString("TOPIC_ALERT_NO_VARNAME")%>%>");
                    return false;
                }
            }
        }

        document.frm.cmd.value = "save";
        document.frm.action="topicsave.jsp";
        document.frm.submit();
    }  
    
    function f_addchild()
    {
        document.frm.cmd.value = "addchild";
        document.frm.action = "topicinfo.jsp";
        document.frm.submit();
    }
    
    function f_delTopic()
    {
      var r = confirm("<%=bundle.getString("TOPIC_ALERT_DELETE")%>");
      if( r ==1 )
      {
          document.frm.cmd.value = "delete";
          document.frm.action = "topicsave.jsp";
          document.frm.submit();
      }  
    }

    function f_rebuildTopicDownTop()
    {
        var r = confirm("<%=bundle.getString("TOPIC_ALERT_REBUILD")%>");
        if( r ==1 )
        {
            document.frm.cmd.value = "rebuild_downtop";
            document.frm.action = "topicinfo.jsp";
            document.frm.submit();
        }
    }

    function f_sync()
    {
        document.frm.cmd.value = "sync";
        document.frm.action = "topicinfo.jsp";
        document.frm.submit();
    }

    function f_archive()
    {
        document.frm.cmd.value = "archive";
        document.frm.action = "topicinfo.jsp";
        document.frm.submit();
    }
    
    function f_rebuildTopicTopDown()
    {
        var r = confirm("<%=bundle.getString("TOPIC_ALERT_REBUILD")%>");
        if( r ==1 )
        {
            document.frm.cmd.value = "rebuild_topdown";
            document.frm.action = "topicinfo.jsp";
            document.frm.submit();
        }
    }

    function popupDialog(url)
    {
         var isMSIE= (navigator.appName == "Microsoft Internet Explorer");

         if (isMSIE)
         {
             return window.showModalDialog(url,window);
         }
         else
         {
             var win = window.open(url, "mcePopup","dialog=yes,modal=yes,menubar=no,location=no,resizable=yes,scrollbars=yes,status=no" );
             win.focus();
         }
    }
    
    function selectTemplate(type)
    {
        var url = "selecttemplate.jsp?type=" + type + "&siteid=" + document.frm.siteid.value;
        var pop_url = 'popupwindow.jsp?src='+escape(url);
        var rc = popupDialog(pop_url);
        //var rc = window.showModalDialog(url);
        if(rc!=null && rc.length>0)
        {
            if(type==2)
            {
                f_setPageTemplate(rc[0],rc[1],rc[2]);
            }
            else if(type==0)
            {
                f_setArticleTemplate(rc[0],rc[1]);
            }
            else if(type==1)
            {
                f_setArchiveTemplate(rc[0],rc[1]);
            }
        }
    }

    function selectArchiveTemplate()
    {
        var url = "selecttemplate.jsp?type=2&siteid=" + document.frm.siteid.value;
        var rc = popupDialog(url);
        //var rc = window.showModalDialog(url);
        if(rc!=null && rc.length>0)
        {
           f_setArchiveTemplate(rc[0],rc[1]);
        }
    }

    function f_setArticleTemplate(id,name)
    {
        document.frm.top_art_tmp_id.value = id;
        document.frm.top_art_tmp_name.value = name;
    }

    function f_setArchiveTemplate(id,name)
    {
        document.frm.top_archive_tmp_id.value = id;
        document.frm.top_archive_tmp_name.value = name;
    }

    function f_setPageTemplate(id,name,fname)
    {      
        var tbody = document.getElementById("pttable").getElementsByTagName("TBODY")[0];
      
        totalRows = totalRows+1;

        var row = document.createElement("TR");
        row.setAttribute("id","row_" + id);

        var td1 = document.createElement("Td");
        var input1 = document.createElement("INPUT");
        input1.setAttribute("id","rowno");
        input1.setAttribute("name", "rowno");
        input1.setAttribute("type", "checkbox");
        input1.setAttribute("value", id);
        td1.appendChild(input1);

        input1=document.createElement("INPUT");
        input1.setAttribute("name", "rt_tmp_id" );
        input1.setAttribute("type", "hidden");
        input1.setAttribute("value", id);
        td1.appendChild(input1);
        row.appendChild(td1);

        td1 = document.createElement("TD");
        td1.innerHTML = "<a href=# onclick=\"f_alterTemplate('" + id + "')\" >" + name +"</a>";;
        row.appendChild(td1);

        td1 = document.createElement("TD");
        td1.innerHTML = fname;
        row.appendChild(td1);

        tbody.appendChild(row);
    }
        
    function deleteTemplate()
    {
        var rownos = document.getElementsByName("rowno");
        if(rownos==null) return;
        
        for (var i = rownos.length-1; i >=0 ; i--)
        {
            if(rownos[i].checked)
            {
                var row=document.getElementById("row_" + rownos[i].value)
                if( row == null) continue;
                row.parentNode.removeChild(row);
            }
        }
    }

    function clearArtTemplate( )
    {
        document.frm.top_art_tmp_id.value ="";
        document.frm.top_art_tmp_name.value ="";
    }

    function clearArchiveTemplate( )
    {
        document.frm.top_archive_tmp_id.value ="";
        document.frm.top_archive_tmp_name.value ="";
    }

    function f_alterArtTemplate()
    {
        var tmp_id = document.frm.top_art_tmp_id.value;
        if( tmp_id.length >0 )  f_alterTemplate( tmp_id );
    } 

    function f_alterArchiveTemplate()
    {
        var tmp_id = document.frm.top_archive_tmp_id.value;
        if( tmp_id.length >0 )  f_alterTemplate( tmp_id );
    }

    function f_alterTemplate(tmp_id)
    {
        document.template_form.id.value = tmp_id;
        document.template_form.submit();
    }

    function f_checktemplate()
    {
        var rownos = document.getElementsByName("rowno");
        if(rownos == null) return false;
        //var rownos = document.all["rowno"];
        //var rownos = document.getElementsByName("rowno");
        for(var i = 0; i < rownos.length; i++)
        {
            rownos[i].checked = document.frm.AllId.checked;
        }
    }

    function SelectUser()
    {
      var urownos = document.getElementsByName("urowno");
      if(urownos == null) return false;
      if( urownos.length == 1)
      {
            urownos[0].checked = document.frm.uAllId.checked;
      }
      else
      {
        for(var i = 0; i < urownos.length; i++)
        {
            urownos[i].checked = document.frm.uAllId.checked;
        }
      }
    }

    function addUser(unitid)
    {
        var url = "selectuser.jsp?unitid=" + unitid;
        var pop_url = 'popupwindow.jsp?src='+escape(url);

        var rc = popupDialog(pop_url);
        //var rc = window.showModalDialog(url);

        if(rc!=null && rc.length>0)
            f_adduser(rc[0],rc[1]);
    }

    function  f_adduser(userid,username)
    {
        var tbody = document.getElementById("ownertable").getElementsByTagName("TBODY")[0];

        totalUserRows = totalUserRows+1;

        var row = document.createElement("TR");
        row.setAttribute("id","urow_" + totalUserRows);

        var td1 = document.createElement("TD");
        var input1 = document.createElement("INPUT");
        input1.setAttribute("id","urowno");
        input1.setAttribute("name", "urowno");
        input1.setAttribute("type","checkbox");        
        input1.setAttribute("value", totalUserRows);
        td1.appendChild(input1);

        input1=document.createElement("INPUT");
        input1.setAttribute("name", "user_id");
        input1.setAttribute("type", "hidden");
        input1.setAttribute("value", userid);
        td1.appendChild(input1);

        input1=document.createElement("INPUT");
        input1.setAttribute("name", "user_name");
        input1.setAttribute("type", "hidden");
        input1.setAttribute("value", username);
        td1.appendChild(input1);
        row.appendChild(td1);
        
        td1 = document.createElement("TD");
        td1.innerHTML =  username;
        row.appendChild(td1);

        tbody.appendChild(row);        
    }

    function deleteUser()
    {
        var urownos = document.getElementsByName("urowno");
        if(urownos==null) return false;

        for(var i = urownos.length-1; i >=0 ; i--)
        {
            if(urownos[i].checked)
            {
                var row=document.getElementById("urow_" + urownos[i].value);
                if( row == null) return;
                row.parentNode.removeChild(row);
            }
        }
    }

    function SelectVar()
    {
      var vrownos = document.getElementsByName("vrowno");
      if(vrownos == null) return false;
      for(var i = 0; i < vrownos.length; i++)
      {
          vrownos[i].checked = document.frm.vAllId.checked;
      }
    }

    function  addVar()
    {
        var tbody = document.getElementById("vartable").getElementsByTagName("TBODY")[0];

        totalVarRows = totalVarRows+1;

        var row = document.createElement("TR");
        row.setAttribute("id","vrow_" + totalVarRows);

        var td1 = document.createElement("TD");
        var input1 = document.createElement("INPUT");
        input1.setAttribute("id","vrowno");
        input1.setAttribute("name", "vrowno");
        input1.setAttribute("type","checkbox");
        input1.setAttribute("value", totalVarRows);
        td1.appendChild(input1);
        row.appendChild(td1);

        td1 = document.createElement("TD");
        input1=document.createElement("INPUT");
        input1.setAttribute("name", "var_name");
        input1.setAttribute("type", "text");
        td1.appendChild(input1);
        row.appendChild(td1);

        td1 = document.createElement("TD");
        input1=document.createElement("INPUT");
        input1.setAttribute("name", "var_value");
        input1.setAttribute("type", "text");
        input1.style.width="100%";
        td1.appendChild(input1);
        row.appendChild(td1);

        td1 = document.createElement("TD");
        input1=document.createElement("INPUT");
        input1.setAttribute("name", "var_comment");
        input1.setAttribute("type", "text");
        td1.appendChild(input1);
        row.appendChild(td1);

        tbody.appendChild(row);
    }

    function deleteVar()
    {
        var vrownos = document.getElementsByName("vrowno");
        if(vrownos==null) return false;

        for(var i = vrownos.length-1; i >=0 ; i--)
        {
            if(vrownos[i].checked)
            {
                var row=document.getElementById("vrow_" + vrownos[i].value);
                if(row==null) continue;
                row.parentNode.removeChild(row);
            }
        }
    }

    function SelectSolrFields()
    {
      var solrrowno = document.getElementsByName("solrrowno");
      if(solrrowno == null) return false;
      for(var i = 0; i < solrrowno.length; i++)
      {
          solrrowno[i].checked = document.frm.solrAllId.checked;
      }
    }

    function  addSolrField()
    {
        var tbody = document.getElementById("solrtable").getElementsByTagName("TBODY")[0];

        totalSolrRows = totalSolrRows+1;

        var row = document.createElement("TR");
        row.setAttribute("id","solrrow_" + totalSolrRows);

        var td1 = document.createElement("TD");
        var input1 = document.createElement("INPUT");
        input1.setAttribute("id","solrrowno");
        input1.setAttribute("name", "solrrowno");
        input1.setAttribute("type","checkbox");
        input1.setAttribute("value", totalSolrRows);
        td1.appendChild(input1);
        row.appendChild(td1);

        td1 = document.createElement("TD");
        input1=document.createElement("INPUT");
        input1.setAttribute("name", "solrfield_name");
        input1.setAttribute("type", "text");
        td1.appendChild(input1);
        row.appendChild(td1);

        td1 = document.createElement("TD");
        input1=document.createElement("INPUT");
        input1.setAttribute("name", "solrfield_comment");
        input1.setAttribute("type", "text");
        td1.appendChild(input1);
        row.appendChild(td1);

        tbody.appendChild(row);
    }

    function f_loadoraclefield()
    {
        var siteid = document.frm.siteid.value;
        var topid = document.frm.topid.value;
        var table_name = document.frm.oracle_table.value;
        if(table_name.trim()=="")  table_name = document.frm.art_table.value;
        if(table_name.trim()=="")
        {
            alert("No oracle table");
            return false;
        }
        var url = "topic_loadsolrfields.jsp?siteid="+siteid+"&topid="+topid+"&t="+table_name;
        var win = window.open(url, "mcePopup","dialog=yes,modal=yes");
        win.focus();
    }

    function f_addsolrfield(col_name,col_comment)
    {
        var tbody = document.getElementById("solrtable").getElementsByTagName("TBODY")[0];

        totalSolrRows = totalSolrRows+1;

        var row = document.createElement("TR");
        row.setAttribute("id","solrrow_" + totalSolrRows);

        var td1 = document.createElement("TD");
        var input1 = document.createElement("INPUT");
        input1.setAttribute("id","solrrowno");
        input1.setAttribute("name", "solrrowno");
        input1.setAttribute("type","checkbox");
        input1.setAttribute("value", totalSolrRows);
        td1.appendChild(input1);
        row.appendChild(td1);

        td1 = document.createElement("TD");
        input1=document.createElement("INPUT");
        input1.setAttribute("name", "solrfield_name");
        input1.setAttribute("type", "text");
        input1.setAttribute("value", col_name);
        td1.appendChild(input1);
        row.appendChild(td1);

        td1 = document.createElement("TD");
        input1=document.createElement("INPUT");
        input1.setAttribute("name", "solrfield_comment");
        input1.setAttribute("type", "text");
        input1.setAttribute("value", col_comment);        
        td1.appendChild(input1);
        row.appendChild(td1);

        tbody.appendChild(row);
    }

    function deleteSolrField()
    {
        var solrrownos = document.getElementsByName("solrrowno");
        if(solrrownos==null) return false;

        for(var i = solrrownos.length-1; i >=0 ; i--)
        {
            if(solrrownos[i].checked)
            {
                var row=document.getElementById("solrrow_" + solrrownos[i].value);
                if(row==null) continue;
                row.parentNode.removeChild(row);
            }
        }
    }

    function newTrigger()
    {
        var win = window.open("triggerinfo.jsp");
        win.focus();
    }
  </script>
</head>

<body leftmargin="20" topmargin="10" >
<form name="frm" method="post" action ="topicsave.jsp">
  <table width="100%"  border=0 cellspacing=0 cellpadding=0>
    <tr height="30">
     <td> &nbsp;
       <input type="button" name=okbtn value="<%=bundle.getString("TOPIC_BUTTON_SAVE")%>" onclick="f_submit()" class="button">
<%
       if(  !bNew && user.IsSiteAdmin(siteid) )
       {
           //只有站点管理员可以配置栏目
%>
         <input type="button" name=childbtn value="<%=bundle.getString("TOPIC_BUTTON_ADDCHILD")%>" onclick="f_addchild()" class="button">
         <input type="button" name=delbtn value="<%=bundle.getString("TOPIC_BUTTON_DELETE")%>" onclick="f_delTopic()" class="button">
<%
       } 
            if(topic!=null && (topic.IsOwner(user.GetId()) || user.IsSiteAdmin(siteid)))
            {
                //站点管理员或版主可以重建
%>

         <input type="button" name=rebuildtn value="<%=bundle.getString("TOPIC_BUTTON_REBUILD_DOWNTOP")%>" onclick="f_rebuildTopicDownTop()" class="button">
         <input type="button" name=rebuildtn2 value="<%=bundle.getString("TOPIC_BUTTON_REBUILD_TOPDOWN")%>" onclick="f_rebuildTopicTopDown()" class="button">

<%
               //自定义数据源可以同步数据
               if(topic.IsCustom())
               {
%>
         <input type="button" name=synctn value="<%=bundle.getString("TOPIC_BUTTON_SYNC")%>" onclick="f_sync()" class="button">
<%
               }

                //归档
                if(topic.IsArchive())
                {
%>
          <input type="button" name=archivebtn value="<%=bundle.getString("TOPIC_BUTTON_ARCHIVE")%>" onclick="f_archive()" class="button">
 <%
                }
            }
 %>

     </td>
   </tr>
  </table> 
  
   <table width="100%" border=1 cellspacing=0 cellpadding=0>
       <input type="hidden" name="topid" value="<%= topid==null?"":topid %>">
       <input type="hidden" name="top_parentid" value="<%= top_parentid==null?"":top_parentid %>">
       <input type="hidden" name="siteid" value="<%= siteid %>" >
       <input type="hidden" name="cmd" value="">
     <tr>
         <td align=center width="120" ><font color="red"><b><%=bundle.getString("TOPIC_NAME")%></b></font></td>
         <td >
             <input type=text name="top_name" value="<%= topic==null?"":topic.GetName() %>" size=25>
         </td>
         <td align=center width="120"><font color="red"><b><%=bundle.getString("TOPIC_ALIAS")%></b></font></td>
         <td >
            <input type=text name="top_alias" onkeyup="this.value=this.value.replace(/[\u4e00-\u9fa5]/g,'')" value="<%= topic==null?"":topic.GetAlias() %>" size=10>
         </td>
        <td align=center width="120"><%=bundle.getString("TOPIC_CODE")%></td>
        <td>
          <%= topic==null?"&nbsp;":topic.GetCode() %>
        </td>
     </tr>
     <tr>
        <td align="center"><%=bundle.getString("TOPIC_DEFAULT_ARTICLE_STATE")%></td>
        <td>
           <select name="art_def_state">
             <option value="0" <%= art_state ==0?"selected":"" %> ><%=bundle.getString("TOPIC_ARTICLE_STATE_DRAFT")%></option>
             <option value="1" <%= art_state ==1?"selected":"" %> ><%=bundle.getString("TOPIC_ARTICLE_STATE_SUBMIT")%></option>
             <option value="2" <%= art_state ==2?"selected":"" %> ><%=bundle.getString("TOPIC_ARTICLE_STATE_PUBLISH")%></option>
             <option value="3" <%= art_state ==3?"selected":"" %> ><%=bundle.getString("TOPIC_ARTICLE_STATE_PUBLISHED")%></option>
           </select>            
        </td>
        <td align=center><%=bundle.getString("TOPIC_DEFAULT_ARTICLE_SCORE")%></td>
        <td>
            <input type="text" name="top_score" value="<%= topic==null?0:topic.GetScore() %>" size="6"   maxlength="4">
        </td>
         <td align=center><%=bundle.getString("TOPIC_ORDER")%></td>
         <td >
            <input type="text" name="top_index" value="<%= topic==null?0:topic.GetIndex() %>" size="6"  maxlength="3">
         </td>
     </tr>
    <tr>
       <td align="center"><%=bundle.getString("TOPIC_TABLENAME")%></td>
       <td >
         <input type="text" size="50" name="art_table" value="<%= (topic==null || topic.GetMyTable()==null)?"":topic.GetMyTable() %>" style="width:160px">
         <%=bundle.getString("TOPIC_TABLENAME_HINT")%>
         <%
             if(topic!=null && topic.IsInherit() && topic.IsCustom())
             {
                 out.print("<font color=red>default=<b>"+topic.GetTable()+"</b></font>");
             }
         %>
       </td>
       <td align=center>是否为商品</td>
         <td >
            <input  type = "checkBox" name = "is_business" value = "1" <%= (topic==null||topic.getIs_business()!=1)?"":"checked" %>  >
         </td>
       <td align=center width="120"><%=bundle.getString("TOPIC_VISIBLE")%></td>
       <td>
          <select name="top_visible">
              <option value="2" <% if(topic!=null&&topic.IsPublic()) out.print("selected");%>><%=bundle.getString("TOPIC_VISIBLE_PUBLIC")%></option>
              <option value="1" <% if(topic==null||topic.GetVisibility()==1) out.print("selected");%>><%=bundle.getString("TOPIC_VISIBLE_COMPANY")%></option>
              <option value="0" <% if(topic!=null&&topic.IsHidden()) out.print("selected");%>><%=bundle.getString("TOPIC_VISIBLE_HIDDEN")%></option>
          </select>
       </td>
    </tr>
    <tr>
       <td align="center"><%=bundle.getString("TOPIC_SOLR_CORE")%></td>
       <td  colspan="3">
           <input type="text" size="50" name="solr_core" value="<% if(topic!=null) out.print(Utils.Null2Empty(topic.GetMySolrCore()));%>" style="width:160px">
         <%
             if(Config.SOLR_URL==null || Config.SOLR_URL.length()==0)
             {
                 out.print("<font color=red>default=<b>"+bundle.getString("TOPIC_SOLR_DISABLED")+"</b></font>");
             }
             else if(topic!=null && (topic.GetMySolrEnable()==null || topic.GetMySolrEnable()))
             {
                 if(topic.GetMySolrCore()==null || topic.GetMySolrCore().length()==0)
                 {
                     String solr_core = topic.GetSolrCore();
                     if(solr_core!=null)
                     {
                        out.print("<font color=red>default=<b>"+solr_core+"</b></font>");
                     }
                     else if(topic.GetMySolrEnable()==null)
                     {
                        out.print("<font color=red>default=<b>"+bundle.getString("TOPIC_SOLR_DISABLED")+"</b></font>");
                     }
                 }
             }
         %>
       </td>
       <td align=center width="120"><%=bundle.getString("TOPIC_SOLR")%></td>
       <td>
           <select name="solr_enabled">
               <option value="2" <% if(topic!=null && topic.GetMySolrEnable()!=null && topic.GetMySolrEnable()) out.print("selected");%>><%=bundle.getString("TOPIC_SOLR_ENABLED")%></option>
               <option value="1" <% if(topic!=null && topic.GetMySolrEnable()!=null && !topic.GetMySolrEnable()) out.print("selected");%>><%=bundle.getString("TOPIC_SOLR_DISABLED")%></option>
               <option value="0" <% if(topic==null || topic.GetMySolrEnable()==null) out.print("selected");%>><%=bundle.getString("TOPIC_SOLR_DEFAULT")%></option>
           </select>
       </td>
    </tr>
   </table>

  <table width="100%" cellpadding="0" cellspacing="0" border="0">
      <tr><td width="10"></td></tr>
      <tr height="30">
         <td align=left>
<%
    ArticleTemplate art_template = null;
    if(topic!=null) art_template = topic.GetArticleTemplate();
%>
           <b><%=bundle.getString("TOPIC_ARTICLETEMPLATE")%></b>

               <input type=text name="top_art_tmp_name" size=50 value="<%=art_template==null?"":art_template.GetName()%>" style="width:250px"  readonly>
               <input type="hidden" name="top_art_tmp_id" value="<%= art_template==null?"":art_template.GetId() %>" >
               <input type=button class=button value="<%=bundle.getString("TOPIC_BUTTON_TEMPLATE_SELECT")%>" onclick="selectTemplate(0);" >
               <input type=button class=button value="<%=bundle.getString("TOPIC_BUTTON_TEMPLATE_CLEAR")%>" onclick="clearArtTemplate( )" >
               <input type="button" class="button" value="<%=bundle.getString("TOPIC_BUTTON_TEMPLATE_OPEN")%>" onclick="f_alterArtTemplate()">
               <%
                   if(!bNew && art_template==null)
                   {
                       art_template = topic.GetCascadedArticleTemplate();
                       if(art_template!=null)
                       {
                           out.println("&nbsp;<font color=red>default=<b>"+art_template.GetName()+"</b></font>");
                       }
                   }
               %>
         </td>
     </tr>
   </table>

  <table width="100%" cellpadding="0" cellspacing="1" border="0">
      <tr height="30">
          <td align="left" width="160">
              <%=bundle.getString("TOPIC_ARCHIVE_MODE")%>
             <select name="archive_mode">
               <option value="0" <%= topic!=null&&topic.GetArchiveMode()==0?"selected":"" %> ><%=bundle.getString("TOPIC_ARCHIVE_NO")%></option>
               <option value="1" <%= topic!=null&&topic.GetArchiveMode()==1?"selected":"" %> ><%=bundle.getString("TOPIC_ARCHIVE_DAILY")%></option>
               <option value="2" <%= topic!=null&&topic.GetArchiveMode()==2?"selected":"" %> ><%=bundle.getString("TOPIC_ARCHIVE_MONTHLY")%></option>
               <option value="3" <%= topic!=null&&topic.GetArchiveMode()==3?"selected":"" %> ><%=bundle.getString("TOPIC_ARCHIVE_ANNUALLY")%></option>
             </select>
          </td>
          <td align="left"><%=bundle.getString("TOPIC_ARCHIVE_TEMPLATE")%>
            <%
                PageTemplate archive_template = null;
                if(topic!=null) archive_template = topic.GetArchiveTemplate();
            %>
                   <input type=text name="top_archive_tmp_name" size=25 value="<%=archive_template==null?"":archive_template.GetName()%>" style="width:250px"  readonly>
                   <input type="hidden" name="top_archive_tmp_id" value="<%= archive_template==null?"":archive_template.GetId() %>" >
                   <input type=button class=button value="<%=bundle.getString("TOPIC_BUTTON_TEMPLATE_SELECT")%>" onclick="selectArchiveTemplate();" >
                   <input type=button class=button value="<%=bundle.getString("TOPIC_BUTTON_TEMPLATE_CLEAR")%>" onclick="clearArchiveTemplate( )" >
                   <input type="button" class="button" value="<%=bundle.getString("TOPIC_BUTTON_TEMPLATE_OPEN")%>" onclick="f_alterArchiveTemplate()">
          </td>
      </tr>
      <tr height="30">
         <td  align="left" width="160">
             <%=bundle.getString("TOPIC_SORT")%>
             <select name="sort_enabled">
                 <option value="0" <% if(topic==null || topic.GetMySortEnable()==null) out.print("selected"); %>><%=bundle.getString("TOPIC_SORT_INHERIT")%></option>
                 <option value="1" <% if(topic!=null && topic.GetMySortEnable()!=null && !topic.GetMySortEnable()) out.print("selected"); %>><%=bundle.getString("TOPIC_SORT_AUTO")%></option>
                 <option value="2" <% if(topic!=null && topic.GetMySortEnable()!=null && topic.GetMySortEnable()) out.print("selected"); %>><%=bundle.getString("TOPIC_SORT_MANUAL")%></option>
             </select>
         </td>
         <td align="left">
             <font color=red>default =<b>
             <%
               if(topic!=null)
               {
                   if(topic.IsSortEnabled())
                   {
                       out.print(bundle.getString("TOPIC_HINT_SORT_MANUAL"));
                   }
                   else
                   {
                       out.print(bundle.getString("TOPIC_HINT_SORT_AUTO"));
                   }
               }
               else
               {
                   out.print(bundle.getString("TOPIC_HINT_SORT_AUTO"));
               }
             %>
              </b></font>
         </td>
      </tr>
  </table>

  <table width="100%" cellpadding="0" cellspacing="1" border="0">
      <tr>
          <td style="width:40px;vertical-align:middle" align="center"><%=bundle.getString("TOPIC_COMMENT")%></td>
          <td>
              <textarea name="top_comment" rows="2" cols="10" style="width:100%"><%=topic==null?"":Utils.Null2Empty(topic.GetComment())%></textarea>
          </td>
      </tr>
  </table>

  <table width="100%" cellpadding="0" cellspacing="1" border="0" class="DetailBar">
      <tr height="5"><td></td></tr>
      <tr height="30">
         <td align=left>
           <b><%=bundle.getString("TOPIC_VARS")%></b>
           <input type="button" class="button" value="<%=bundle.getString("TOPIC_BUTTON_ADD_VAR")%>" onclick="addVar()">
           <input type="button" class="button" value="<%=bundle.getString("TOPIC_BUTTON_DEL_VAR")%>" onclick="deleteVar()">
         </td>
     </tr>
  </table>
  <table id="vartable"  width="100%" cellpadding="0" cellspacing="1" border="0">
   <TBody>
    <tr height=30 class="titlebar">
      <td width="25">
          <input type = "checkBox" name = "vAllId" value = "0" onclick = "SelectVar()">
      </td>
      <td width="160"><%=bundle.getString("TOPIC_VAR_NAME")%></td>
      <td style='width:320px'><%=bundle.getString("TOPIC_VAR_VALUE")%></td>
      <td ><%=bundle.getString("TOPIC_VAR_COMMENT")%></td>  
    </tr>
   <%
       if(!bNew)
       {
           if(topic!=null)
           {
                java.util.Hashtable vars = topic.GetVars();
                int i = 0;
                if(vars!=null)
                {
                    Object[] keys = vars.keySet().toArray();
                    java.util.Arrays.sort(keys);
                    for(int key_index=0;key_index<keys.length;key_index++)
                    {
                        Topic.Var var = ( Topic.Var)vars.get(keys[key_index]);
                        i++;
   %>
        <tr height=30 id="vrow_<%= i%>">
          <td><input type = "checkBox" name = "vrowno" value = "<%= i %>"></td>
          <td><input type="text" name="var_name" value="<%= var.GetName() %>"></td>
          <td><input type="text" name="var_value" value="<%= var.GetValue() %>" style="width:100%"></td>
          <td><input type="text" name="var_comment" value="<%= Utils.Null2Empty(var.GetComment()) %>"></td>
        </tr>
   <%
                   }
   %>
                 <script type="text/javascript">totalVarRows=<%=i%>;</script>
   <%
               }
           }
       }
   %>
       </TBody>
     </table>


  <table width="100%" cellpadding="0" cellspacing="1" border="0" class="DetailBar">
      <tr height="5"><td></td></tr>
      <tr height="30">
         <td align=left>
           <b><%=bundle.getString("TOPIC_ADMINS")%></b>
           <input type="button" class="button" value="<%=bundle.getString("TOPIC_BUTTON_ADD_ADMIN")%>" onclick="addUser('<%=site.GetUnit().GetId()%>')">
           <input type="button" class="button" value="<%=bundle.getString("TOPIC_BUTTON_DEL_ADMIN")%>" onclick="deleteUser()">
         </td>
     </tr>
   </table>
   <table id="ownertable"  width="100%" cellpadding="0" cellspacing="1" border="0">
    <TBody>
     <tr height=30 class="titlebar">
       <td width="25"><input type = "checkBox" name = "uAllId" value = "0" onclick = "SelectUser()"></td>
       <td><%=bundle.getString("TOPIC_ADMIN_NAME")%></td>
     </tr>

<%
    if(!bNew)
    {
        if(topic!=null)
        {
             java.util.Hashtable owners = topic.GetOwner();
             int i = 0;
             if(owners!=null)
             {
                 Object[] keys = owners.keySet().toArray();
                 java.util.Arrays.sort(keys);
                 for(int key_index=0;key_index<keys.length;key_index++)
                 {
                     Topic.Owner aowner = ( Topic.Owner)owners.get(keys[key_index]);
                     i++;
%>
     <tr height=30 id="urow_<%= i%>">
       <td>
           <input type = "checkBox" name = "urowno" value = "<%= i %>">
           <input type="hidden" name="user_id" value="<%= aowner.GetID() %>">
           <input type="hidden" name="user_name" value="<%= aowner.GetName() %>">
       </td>
       <td>
         <%= aowner.GetName()  %>
       </td>
     </tr>
<%
                }
%>
              <script type="text/javascript">totalUserRows=<%=i%>;</script>
<%
            }
        }
    }
%>
    </TBody>
  </table>


  <table width="100%" cellpadding="0" cellspacing="1" border="0" class="DetailBar">
      <tr height="5"><td></td></tr>
      <tr height="30">
         <td align=left>
           <b><%=bundle.getString("TOPIC_PAGETEMPLATES")%></b>
           <input type="button" class="button" value="<%=bundle.getString("TOPIC_BUTTON_ADD_PAGETEMPLATE")%>" onclick="selectTemplate(2)">
           <input type="button" class="button" value="<%=bundle.getString("TOPIC_BUTTON_DEL_PAGETEMPLATE")%>" onclick="deleteTemplate()">
         </td>
     </tr>
   </table>

   <table id="pttable" name="pttable"  width="100%" cellpadding="0" cellspacing="1" border="0" >
    <TBody>
     <tr height=30 class="titlebar">
       <td width="25">
    		<input type = "checkBox" name = "AllId" value = "0" onclick = "f_checktemplate()">
	   </td>
       <td><%=bundle.getString("TOPIC_PAGETEMPLATES_NAME")%></td> 
       <td><%=bundle.getString("TOPIC_PAGETEMPLATES_OUTPUT_FILENAME")%></td> 
     </tr>
     
<%
    if(!bNew)
    {
        if(topic!=null)
        {
             java.util.List pts = topic.GetPageTemplates();
             int i = 0;
             if(pts!=null)
             {
                 for(Object obj:pts)
                 {
                     PageTemplate pt = (PageTemplate)obj;
                     i++;
%>
     <tr id="row_<%= pt.GetId() %>" class="detailbar">
       <td width="25">
          <input type = "checkBox" name="rowno" value = "<%= pt.GetId() %>">
          <input type="hidden" name="rt_tmp_id" value="<%= pt.GetId() %>">
       </td>
       <td>
          <a href="#" onclick="f_alterTemplate('<%= pt.GetId() %>')"><%= pt.GetName()  %></a>          
       </td>                  
       <td><%= pt.GetOutputFileName() %></td>       
     </tr> 
<%
                }
            }
%>
              <script type="text/javascript">totalRows=<%=i%>;</script>
<%            
        }
    }
%>
    </TBody>
  </table>

  <table width="100%" cellpadding="0" cellspacing="1" border="0" class="DetailBar">
      <tr height="5"><td></td></tr>
      <tr height="30">
         <td align=left>
           <b><%=bundle.getString("TOPIC_KEYWORDLINK")%></b>
           <font color="red"><%=bundle.getString("TOPIC_KEYWORDLINK_HINT")%></font>
         </td>
     </tr>
     <tr>
       <td>
         <textarea name="keyword_link" rows="5" cols="10" style="width:100%"><% if(topic!=null && topic.GetKeywordLinks()!=null) out.print(Utils.Null2Empty(topic.GetKeywordLinks().toString()));%></textarea>
       </td>
     </tr>
  </table>

  <table width="100%" cellpadding="0" cellspacing="1" border="0" class="DetailBar">
      <tr height="5"><td></td></tr>
      <tr height="30">
         <td align=left>
           <b><%=bundle.getString("TOPIC_SOLR_FIELDS")%></b>
           <input type="button" class="button" value="<%=bundle.getString("TOPIC_BUTTON_ADD_SOLRFIELD")%>" onclick="addSolrField()">
           <input type="button" class="button" value="<%=bundle.getString("TOPIC_BUTTON_DEL_SOLRFIELD")%>" onclick="deleteSolrField()">
           &nbsp;&nbsp;
           <input type="text" name="oracle_table" value="">
           <input type="button" class="button" value="<%=bundle.getString("TOPIC_BUTTON_LOADORACLETABLE")%>" onclick="f_loadoraclefield()">
         </td>
     </tr>
   </table>

  <table id="solrtable"  width="100%" cellpadding="0" cellspacing="1" border="0">
   <TBody>
    <tr height=30 class="titlebar">
      <td width="25">
          <input type = "checkBox" name = "solrAllId" value = "0" onclick = "SelectSolrFields()">
      </td>
      <td width="160"><%=bundle.getString("TOPIC_SOLR_FIELDNAME")%></td>
      <td ><%=bundle.getString("TOPIC_SOLR_FIELDCOMMENT")%></td>
    </tr>
   <%
       if(!bNew)
       {
           if(topic!=null)
           {
                java.util.Hashtable solrfields = topic.GetSolrFields();
                int i = 0;
                if(solrfields!=null)
                {
                    Object[] keys = solrfields.keySet().toArray();
                    java.util.Arrays.sort(keys);
                    for(int key_index=0;key_index<keys.length;key_index++)
                    {
                        Topic.SolrField field = ( Topic.SolrField)solrfields.get(keys[key_index]);
                        i++;
   %>
        <tr height=30 id="solrrow_<%= i%>">
          <td><input type = "checkBox" name = "solrrowno" value = "<%= i %>"></td>
          <td><input type="text" name="solrfield_name" value="<%= field.GetName() %>"></td>
          <td><input type="text" name="solrfield_comment" value="<%= Utils.Null2Empty(field.GetComment()) %>"></td>
        </tr>
   <%
                   }
   %>
                 <script type="text/javascript">totalSolrRows=<%=i%>;</script>
   <%
               }
           }
       }
   %>
       </TBody>
     </table>

   <table width="100%" cellpadding="0" cellspacing="1" border="0" class="DetailBar">
      <tr height="5"><td></td></tr>
      <tr height="30">
         <td align=left>
           <b><%=bundle.getString("TOPIC_TRIGGERS")%></b>
           <input type="button" class="button" value="<%=bundle.getString("TOPIC_BUTTON_ADD_TRIGGER")%>" onclick="newTrigger()">
         </td>
     </tr>
   </table>

   <table name="triggertable"  width="100%" cellpadding="0" cellspacing="1" border="0" >
    <TBody>
     <tr height=30 class="titlebar">
       <td width="25">
    		<input type = "checkBox" name = "AllTriggerId" value = "0">
	   </td>
       <td><%=bundle.getString("TOPIC_TRIGGER_NAME")%></td>
       <td><%=bundle.getString("TOPIC_TRIGGER_EVENT")%></td>  
       <td><%=bundle.getString("TOPIC_TRIGGER_STATUS")%></td>
       <td><%=bundle.getString("TOPIC_TRIGGER_CREATOR")%></td>
       <td><%=bundle.getString("TOPIC_TRIGGER_LASTRUN_STATE")%></td>
     </tr>

<%
    if(!bNew)
    {
        if(topic!=null)
        {
             TriggerManager manager = TriggerManager.LoadTriggers(wrapper.GetContext());
             List triggers = manager.GetTriggers(wrapper.GetContext(),topic);
             int i = 0;
             if(triggers!=null)
             {
                 for(Object obj:triggers)
                 {
                     Trigger trigger = (Trigger)obj;
                     i++;
%>
     <tr id="trigger_row_<%= trigger.GetId() %>" class="detailbar">
       <td width="25">
          <input type = "checkBox" name="trigger_rowno" value = "<%= trigger.GetId() %>">
          <input type="hidden" name="trigger_id" value="<%= trigger.GetId() %>">
       </td>
       <td>
          <a href="triggerinfo.jsp?id=<%= trigger.GetId() %>" target="_blank"><%= trigger.GetName()  %></a>
       </td>
       <td>
           <%
             switch(trigger.GetEvent())
             {
                 case 0:
                     out.print(bundle.getString("TOPIC_TRIGGER_EVENT_INSERT"));
                     break;
                 case 1:
                     out.print(bundle.getString("TOPIC_TRIGGER_EVENT_UPDATE"));
                     break;
                 case 2:
                     out.print(bundle.getString("TOPIC_TRIGGER_EVENT_READY"));
                     break;
                 case 3:
                     out.print(bundle.getString("TOPIC_TRIGGER_EVENT_PUBLISH"));
                     break;
                 case 4:
                     out.print(bundle.getString("TOPIC_TRIGGER_EVENT_CANCEL"));
                     break;
                 case 5:
                     out.print(bundle.getString("TOPIC_TRIGGER_EVENT_DELETE"));
                     break;
             }
           %>
       </td>
       <td>
           <%
                if(trigger.IsEnable())
                    out.print(bundle.getString("TOPIC_TRIGGER_STATUS_ENABLED"));
                else
                    out.print(bundle.getString("TOPIC_TRIGGER_STATUS_DISABLED"));
           %>
       </td>
       <td><%= trigger.GetCreatorName() %></td>
       <td>
           <%
            switch(trigger.GetLastRunState())
            {
              case 0:
                  out.print(bundle.getString("TOPIC_TRIGGER_LASTRUN_STATUS_NORMAL"));
                  break;
              case 1:
                  out.print(bundle.getString("TOPIC_TRIGGER_LASTRUN_STATUS_ERROR"));
                  break;
            }
           %>
       </td>
     </tr>
<%
                }
            }
%>
              <script type="text/javascript">totalTriggerRows=<%=i%>;</script>
<%
        }
    }
%>
    </TBody>
  </table>
  </form>

<form name="template_form" action="templateinfo.jsp" method="post" target="_blank">
    <input type="hidden" name="id"  value="">
</form>
</body>
</html>

<%
    }
    catch(Exception e)
    {
        out.println(e.getMessage());
        throw e;
    }
    finally
    {
       if(wrapper!=null) wrapper.Clear();
    }
%>