<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.core.*" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.nio.charset.Charset" %>
<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String siteid =  request.getParameter("id");
    NpsWrapper wrapper = null;
    Site site = null;
    boolean bNew = (siteid==null || siteid.length()==0);

    if(bNew && !user.IsSysAdmin())
    {
        throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);
    }

    if(!bNew)
    {
        if(!user.IsSiteAdmin(siteid))
        {
            throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);
        }
        try
        {
            wrapper = new NpsWrapper(user,siteid);
            site = wrapper.GetSite();
            if(site==null) throw new NpsException(ErrorHelper.SYS_NOSITE);
        }
        catch(Exception e)
        {
            throw e;
        }
        finally
        {
           if(wrapper!=null) wrapper.Clear();
        }
    }

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_siteinfo",user.GetLocale(), Config.RES_CLASSLOADER);    
%>

<HTML>
	<HEAD>
		<TITLE><%= site==null?"":site.GetName() %><%=bundle.getString("SITE_HTMLTITLE")%></TITLE>
        <LINK href="/css/style.css" rel = stylesheet>
        <script type="text/javascript" src="/jscript/global.js"></script>
		<script language = "javascript">
            var adm_rowNo = 0;
            var aftp_rowno = 0;
            var iftp_rowno = 0;
            var var_rowNo = 0;
            var solr_rowNo = 0;
            function popupDialog(url)
            {
               var isMSIE= (navigator.appName == "Microsoft Internet Explorer");

               if (isMSIE)
               {
                   return window.showModalDialog(url);
               }
               else
               {
                   var win = window.open(url, "mcePopup","dialog=yes,modal=yes" );
                   win.focus();
               }
           }

            function selectiftp()
            {
                var urownos = document.getElementsByName("iftpno");
                if( urownos == null) return false;
                for(var i = 0; i < urownos.length; i++)
                {
                    urownos[i].checked = document.site_form.iftpAllId.checked;
                }
            }

            function del_iftp()
            {
                var iftpnos = document.getElementsByName("iftpno");
                for(var i = iftpnos.length-1; i >=0 ; i--)
                {
                    if(iftpnos[i].checked)
                    {
                        var row=document.getElementById("iftp_" + iftpnos[i].value);
                        if( row == null) return;
                        row.parentNode.removeChild(row);
                    }
                }
            }

            function add_iftp()
            {
                iftp_rowno = iftp_rowno + 1;
                var tbody = document.getElementById("FtpTbl_1").getElementsByTagName("TBODY")[0];

                 var row = document.createElement("TR");
                 row.setAttribute("id","iftp_" + iftp_rowno);

                 var td = document.createElement("TD");
                 var input1 = document.createElement("INPUT");
                 input1.setAttribute("id","iftpno");
                 input1.setAttribute("name","iftpno");
                 input1.setAttribute("type","checkbox");
                 input1.setAttribute("value",iftp_rowno);
                 td.appendChild(input1);
                 row.appendChild(td);

                 td = document.createElement("TD");
                 input1 = document.createElement("INPUT");
                 input1.setAttribute("name","img_ftp_host");
                 input1.setAttribute("type","text");
                 input1.setAttribute("size","25");
                 td.appendChild(input1);
                row.appendChild(td);

                 td = document.createElement("TD");
                 input1 = document.createElement("INPUT");
                 input1.setAttribute("name","img_ftp_port");
                 input1.setAttribute("type","text");
                 input1.setAttribute("size","6");
                 td.appendChild(input1);
                row.appendChild(td);

                td = document.createElement("TD");
                input1 = document.createElement("INPUT");
                input1.setAttribute("name","img_ftp_remotedir");
                input1.setAttribute("type","text");
                input1.setAttribute("size","40");
                td.appendChild(input1);
                row.appendChild(td);

                td = document.createElement("TD");
                input1 = document.createElement("INPUT");
                input1.setAttribute("name","img_ftp_username");
                input1.setAttribute("type","text");
                td.appendChild(input1);
                row.appendChild(td);

                td = document.createElement("TD");
                input1 = document.createElement("INPUT");
                input1.setAttribute("name","img_ftp_userpwd");
                input1.setAttribute("type","password");
                td.appendChild(input1);
                row.appendChild(td);

                tbody.appendChild(row);
            }

           function selectaftp()
           {
               var urownos = document.getElementsByName("aftpno");
               if( urownos == null) return false;
               for(var i = 0; i < urownos.length; i++)
               {
                   urownos[i].checked = document.site_form.aftpAllId.checked;
               }
           }
           
           function del_ftp()
           {
               var aftpnos = document.getElementsByName("aftpno");
               for(var i = aftpnos.length-1; i >=0 ; i--)
               {
                   if(aftpnos[i].checked)
                   {
                       var row=document.getElementById("aftp_" + aftpnos[i].value);
                       if( row == null) return;
                       row.parentNode.removeChild(row);
                   }
               }
           }
           
           function add_ftp()
           {
               aftp_rowno = aftp_rowno + 1;
               var tbody = document.getElementById("FtpTbl_0").getElementsByTagName("TBODY")[0];

                var row = document.createElement("TR");
                row.setAttribute("id","aftp_" + aftp_rowno);

                var td = document.createElement("TD");
                var input1 = document.createElement("INPUT");
                input1.setAttribute("id","aftpno");
                input1.setAttribute("name","aftpno");
                input1.setAttribute("type","checkbox");
                input1.setAttribute("value",aftp_rowno);
                td.appendChild(input1);
                row.appendChild(td);

                td = document.createElement("TD");
                input1 = document.createElement("INPUT");
                input1.setAttribute("name","ftp_host");
                input1.setAttribute("type","text");
                input1.setAttribute("size","25");
                td.appendChild(input1);
               row.appendChild(td);

                td = document.createElement("TD");
                input1 = document.createElement("INPUT");
                input1.setAttribute("name","ftp_port");
                input1.setAttribute("type","text");
                input1.setAttribute("size","6");
                td.appendChild(input1);
               row.appendChild(td);

               td = document.createElement("TD");
               input1 = document.createElement("INPUT");
               input1.setAttribute("name","ftp_remotedir");
               input1.setAttribute("type","text");
               input1.setAttribute("size","40");
               td.appendChild(input1);
               row.appendChild(td);

               td = document.createElement("TD");
               input1 = document.createElement("INPUT");
               input1.setAttribute("name","ftp_username");
               input1.setAttribute("type","text");
               td.appendChild(input1);
               row.appendChild(td);

               td = document.createElement("TD");
               input1 = document.createElement("INPUT");
               input1.setAttribute("name","ftp_userpwd");
               input1.setAttribute("type","password");
               td.appendChild(input1);
               row.appendChild(td);

               tbody.appendChild(row);
           }

           function del_admin()
           {
               var admrownos = document.getElementsByName("Admrowno");

                for(var i = admrownos.length-1; i >=0 ; i--)
                {
                    if(admrownos[i].checked)
                    {
                        var row=document.getElementById("AdmRow_" + admrownos[i].value);
                        if( row == null) return;
                        row.parentNode.removeChild(row);
                    }
                }
           }
           
           function add_admin()
           {
               var userid='',username='';
               if(document.site_form.unitid.value=="")
               {
                   alert("<%=bundle.getString("SITE_ALERT_SELECT_UNIT_FIRST")%>");
                   return false;
               }

               var rc = popupDialog("selectuser.jsp?unitid="+document.site_form.unitid.value);
               //var rc = window.showModalDialog("selectuser.jsp?unitid="+document.site_form.unitid.value);
               if (rc == null || rc.length==0) return false;
               f_adduser(rc[0],rc[1]);             
           }

           function selectuser()
           {
              var urownos = document.getElementsByName("Admrowno");
              if( urownos == null) return false;
              for(var i = 0; i < urownos.length; i++)
              {
                   urownos[i].checked = document.site_form.AdmAllId.checked;
              }
           }

           function f_adduser(userid,username)
           {
               var users = document.getElementsByTagName("input");
               for(var i=0;i<users.length;i++)
               {
                   if("userId"==users[i].name)
                   {
                       if(users[i].value==userid) return false;
                   }
               }

               adm_rowNo = adm_rowNo+1;

               var tbody = document.getElementById("AdmTbl").getElementsByTagName("TBODY")[0];
               var row = document.createElement("TR");
               row.setAttribute("id","AdmRow_" + adm_rowNo); 

               var td1 = document.createElement("TD");
               var input1 = document.createElement("INPUT");
               input1.setAttribute("id", "Admrowno");
               input1.setAttribute("name", "Admrowno");
               input1.setAttribute("type","checkbox");
               input1.setAttribute("value", adm_rowNo);
               td1.appendChild(input1); 

               input1=document.createElement("INPUT");
               input1.setAttribute("name", "userId");
               input1.setAttribute("type", "hidden");
               input1.setAttribute("value", userid);
               td1.appendChild(input1);
               row.appendChild(td1);

               td1 = document.createElement("TD");
               input1=document.createElement("INPUT");
               input1.setAttribute("name", "userName");
               input1.setAttribute("type", "text");
               input1.setAttribute("value", username);
               input1.setAttribute("readOnly","true");
               td1.appendChild(input1);
               row.appendChild(td1);

               tbody.appendChild(row);
           }

           function del_var()
           {
              var varrownos = document.getElementsByName("Varrowno");

               for(var i = varrownos.length-1; i >=0 ; i--)
               {
                   if(varrownos[i].checked)
                   {
                       var row=document.getElementById("VarRow_" + varrownos[i].value);
                       if( row == null) return;
                       row.parentNode.removeChild(row);
                   }
               }
           }
           function selectvar()
           {
               var varrownos = document.getElementsByName("Varrowno");
              if( varrownos == null) return false;
              for(var i = 0; i < varrownos.length; i++)
              {
                   varrownos[i].checked = document.site_form.VarAllId.checked;
              }
           }

           function add_var()
           {
               var_rowNo = var_rowNo+1;

               var tbody = document.getElementById("VarTbl").getElementsByTagName("TBODY")[0];
               var row = document.createElement("TR");
               row.setAttribute("id","VarRow_" + var_rowNo);

               var td1 = document.createElement("TD");
               var input1 = document.createElement("INPUT");
               input1.setAttribute("id", "Varrowno");
               input1.setAttribute("name", "Varrowno");
               input1.setAttribute("type","checkbox");
               input1.setAttribute("value", var_rowNo);
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
               input1.style.width="95%";
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

           function del_solrfield()
           {
              var solrrownos = document.getElementsByName("Solrrowno");

               for(var i = solrrownos.length-1; i >=0 ; i--)
               {
                   if(solrrownos[i].checked)
                   {
                       var row=document.getElementById("SolrRow_" + solrrownos[i].value);
                       if( row == null) return;
                       row.parentNode.removeChild(row);
                   }
               }
           }
           function selectsolrfield()
           {
               var solrrownos = document.getElementsByName("Solrrowno");
              if( solrrownos == null) return false;
              for(var i = 0; i < solrrownos.length; i++)
              {
                   solrrownos[i].checked = document.site_form.SolrAllId.checked;
              }
           }

           function add_solrfield()
           {
               solr_rowNo = solr_rowNo+1;

               var tbody = document.getElementById("SolrTbl").getElementsByTagName("TBODY")[0];
               var row = document.createElement("TR");
               row.setAttribute("id","SolrRow_" + solr_rowNo);

               var td1 = document.createElement("TD");
               var input1 = document.createElement("INPUT");
               input1.setAttribute("id", "Solrrowno");
               input1.setAttribute("name", "Solrrowno");
               input1.setAttribute("type","checkbox");
               input1.setAttribute("value", solr_rowNo);
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

           function f_save()
           {
             var frm = document.site_form;
             var id = frm.id.value ;
             if( id.length == 0 )
             {
               alert("<%=bundle.getString("SITE_ALERT_SITEID_NULL")%>");
               frm.id.focus();
               return;
             }

             for( var i=0; i < id.length; i++)
             {
               var ch = id.charAt(i);
               if( ( ch>='a'&& ch <= 'z') || (ch >='A' && ch <='Z' ) || (ch >='0' && ch <='9') || ch == '_' || ch == '-' )
               {

               }
               else
               {
                 alert("<%=bundle.getString("SITE_ALERT_SITEID_INVALID")%>");
                 frm.id.focus();
                 return;
               }
             }

             if( frm.name.value.trim()  == '')
             {
               alert("<%=bundle.getString("SITE_ALERT_NAME_NULL")%>");
               frm.name.focus();
               return;
             }

             if( frm.publishdir.value.trim() == '')
             {
               alert("<%=bundle.getString("SITE_ALERT_PUBLISHDIR_NULL")%>");
               frm.publishdir.focus();
               return;
             }

             var var_names = document.getElementsByName("var_name");
             if(var_names!=null && var_names.length>0)
             {
                 for(var i=0;i<var_names.length;i++)
                 {
                     if(var_names[i].value.trim()=="")
                     {
                         alert("<%=bundle.getString("SITE_ALERT_NO_VARNAME")%>%>");
                         return false;
                     }
                 }
             }

            var solrfield_names = document.getElementsByName("solrfield_name");
             if(solrfield_names!=null && solrfield_names.length>0)
             {
                 for(var i=0;i<solrfield_names.length;i++)
                 {
                     if(solrfield_names[i].value.trim()=="")
                     {
                         alert("<%=bundle.getString("SITE_ALERT_NO_SOLRFIELDNAME")%>%>");
                         return false;
                     }
                 }
             }

              document.site_form.action="sitesave.jsp";
              document.site_form.submit();
           }

           function f_freeze()
           {
              document.site_form.action="sitesave.jsp";
              document.site_form.cmd.value="freeze";
              document.site_form.submit();
           }

           function f_defreeze()
           {
              document.site_form.action="sitesave.jsp";
              document.site_form.cmd.value="defreeze";
              document.site_form.submit();
           }

           function f_delete()
           {
               var r = confirm("<%=bundle.getString("SITE_ALERT_DELETE")%>");
               if( r ==1 )
               {
                   document.site_form.action = "sitesave.jsp";
                   document.site_form.cmd.value = "delete";
                   document.site_form.submit();
               }
           }

           function f_export()
           {
               document.site_form.action="sitesave.jsp";
               document.site_form.cmd.value="export";
               document.site_form.submit();
           }

           function f_dump()
           {
               document.site_form.action="sitesave.jsp";
               document.site_form.cmd.value="dump";
               document.site_form.submit();
           }

           function f_archive()
           {
               document.site_form.action="sitesave.jsp";
               document.site_form.cmd.value="archive";
               document.site_form.submit();
           }

           function f_check()
           {
               var id = document.site_form.id.value;
               if( id.length == 0 )
               {
                 alert("<%=bundle.getString("SITE_ALERT_SITEID_NULL")%>");
                 document.site_form.id.focus();
                 return;
               }

               for( var i=0; i < id.length; i++)
               {
                 var ch = id.charAt(i);
                 if( ( ch>='a'&& ch <= 'z') || (ch >='A' && ch <='Z' ) || (ch >='0' && ch <='9') || ch == '_' || ch == '-' )
                 {

                 }
                 else
                 {
                   alert("<%=bundle.getString("SITE_ALERT_SITEID_INVALID")%>");
                   document.site_form.id.focus();
                   return;
                 }
               }

               popupDialog("sitecheck.jsp?id="+document.site_form.id.value);
               //window.showModalDialog("sitecheck.jsp?id="+document.site_form.id.value,"","dialogWidth=200px;dialogHeight=100px");
           }

           function change_color(src,clrclick,clrout)
            {
                if( src.bgColor == clrclick){
                    src.bgColor = clrout;
                }else{
                    src.bgColor = clrclick;
                }
            }
		</script>
	</HEAD>	
	
  <BODY leftMargin="10" topMargin = "0">
  <form name="site_form" action="sitesave.jsp" method="post" >  
      <table width ="100%" border = "0" align ="center" cellpadding = "0" cellspacing = "0" class="positionbar">
        <tr height="30" >
          <td  valign="middle" >&nbsp;
<%
if(user.IsSysAdmin())
{
%>
            <input name="saveBtn" type="button" class="button" onClick="f_save()"  value="<%=bundle.getString("SITE_BUTTON_SAVE")%>">
<%
     if(site!=null)
     {
          if(site.GetState()==1)
          {
%>
              <input name="freezeBtn" type="button" class="button" onClick="f_freeze()"  value="<%=bundle.getString("SITE_BUTTON_FREEZE")%>">
<%
          }
          else
          {
%>
              <input name="defreezeBtn" type="button" class="button" onClick="f_defreeze()"  value="<%=bundle.getString("SITE_BUTTON_DEFREEZE")%>">
<%
          }
%>
              <input name="deleteBtn" type="button" class="button" onClick="f_delete()"  value="<%=bundle.getString("SITE_BUTTON_DELETE")%>">

<%
     }
}

    if(site!=null)
    {
%>
              <input name="expBtn" type="button" class="button" onClick="f_export()"  value="<%=bundle.getString("SITE_BUTTON_EXPORT")%>">
              <input name="dumpBtn" type="button" class="button" onClick="f_dump()"  value="<%=bundle.getString("SITE_BUTTON_DUMP")%>">
              <input name="archiveBtn" type="button" class="button" onClick="f_archive()"  value="<%=bundle.getString("SITE_BUTTON_ARCHIVE")%>">
<%
    }
%>
             <input name="closeBtn" type="button" class="button" onClick="javascript:window.close();"  value="<%=bundle.getString("SITE_BUTTON_CLOSE")%>">
          </td>
        </tr>
      </table>
      
      <table width="100%"  border="1" cellspacing=0 cellpadding=0 >
          <input type="hidden" name="cmd" value="<%= bNew?"add":"update"%>">
        <tr height=30>
          <td align="center" width="120"><b><font color="red"><%=bundle.getString("SITE_SITEID")%></font></b></td>
          <td colspan="3">
              <input type="text" size="25" name="id" value="<%= site==null?"":site.GetId() %>"  <%= bNew?"":"readonly"%> >
              <%
                  if(bNew)
                  {
              %>
                    <input type="button" class="button" name="btn_checkid" value="<%=bundle.getString("SITE_BUTTON_CHECK")%>" onclick="f_check()">
              <%
                  }
              %>
              <%=bundle.getString("SITE_HINT_SITEID")%>
          </td>
          <td align="center" width="120"><%=bundle.getString("SITE_STATUS")%></td>
          <td>&nbsp;
              <%
                  if(site==null)
                  {
                      out.print(bundle.getString("SITE_STATUS_NEW"));
                  }
                  else
                  {
                      switch(site.GetState())
                      {
                          case 0:
                              out.print("<font color=red>"+bundle.getString("SITE_STATUS_FREEZED")+"</font>");
                              break;
                          case 1:
                              out.print(bundle.getString("SITE_STATUS_NORMAL"));
                              break;
                      }
                  }
              %>
          </td>
        </tr>
        <tr height=30 >
            <td align="center" width="120"><b><font color="red"><%=bundle.getString("SITE_NAME")%></font></b></td>
            <td>
                <input type="text" size="25" name="name" value="<%= site==null?"":Utils.TransferToHtmlEntity(site.GetName()) %>">
            </td>
            <td align="center" width="120"><b><%=bundle.getString("SITE_CHARSET")%></b></td>
            <td>
                <select name="encoding">
                <%
                    String current_encoding = "UTF-8";
                    if(site!=null) current_encoding = site.GetEncoding();

                    java.util.SortedMap charsets = Charset.availableCharsets();
                    java.util.Iterator iter = charsets.keySet().iterator();
                    while(iter.hasNext())
                    {
                        String charset_name = (String)iter.next();
                %>
                        <option value="<%=charset_name%>" <% if(current_encoding.equalsIgnoreCase(charset_name)) out.print("selected");%>><%=charset_name%></option>
                <%
                    }
                %>
                </select>
            </td>
            <td align="center" width="120"><b><%=bundle.getString("SITE_SUFFIX")%></b></td>
            <td>
              <input type="text" size="5" name="suffix" value="<%= site==null?".shtml":site.GetSuffix() %>" >
              <%=bundle.getString("SITE_HINT_SUFFIX")%>
            </td>
        </tr>
        <tr height=30 >
           <td align="center" width="120"><b><font color="red"><%=bundle.getString("SITE_DOMAIN")%></font></b></td>
           <td>
               <input type="text" size="25" name="domain" value="<%= site==null?"":Utils.Null2Empty(site.GetDomain()) %>">
           </td>
           <td colspan="4">
               <input type="checkbox" name="fulltext" value="0" <%= site==null||site.IsFulltextIndex()?"checked":""%>><b><%=bundle.getString("SITE_FULLTEXT")%></b>
               <input type="checkbox" name="write_buffered" value="0" <%= site==null||site.IsWriteBuffered()?"checked":""%>><b><%=bundle.getString("SITE_WRITE_BUFFERED")%></b>
           </td>
        </tr>
        <tr height=30 >
            <td align="center" width="120"><b><font color="red"><%=bundle.getString("SITE_UNIT")%></font></b></td>
            <td>
                <select name="unitid">
<%
    java.util.List units = user.GetUnits();
    if(units!=null)
    {
        for(Object obj:units)
        {
            Unit unit = (Unit)obj;
            boolean bChecked = false;

            if(site!=null && site.GetUnit()!=null && unit.GetId().equalsIgnoreCase(site.GetUnit().GetId()))
                bChecked = true;
%>
                    <option value="<%= unit.GetId()%>"  <%= bChecked?"selected":""%>><%=unit.GetName()%></option>
<%
        }
    }
%>
                </select>             
            </td>
            <td align="center" width="120"><b>Solr Core:</b></td>
            <td colspan="3">
                <input type="text" size="10" name="solr_core" value="<%= site==null?"":Utils.Null2Empty(site.GetSolrCore()) %>">
                <%=bundle.getString("SITE_HINT_SOLRCORE")%>
            </td>
        </tr>
        <tr height=30 >
            <td align="center" width="120"><b><%=bundle.getString("SITE_ROOT")%></b></td>
            <td colspan="5">
              <input type="text" size="45" name="rooturl" value="<%= site==null?"/":site.GetRootURL() %>" >
              <%=bundle.getString("SITE_HINT_ROOT")%>
            </td>
        </tr>
        <tr height=30 >
          <td align="center" width="120"><b><font color="red"><%=bundle.getString("SITE_PUBLISHDIR")%></font></b></td>
          <td colspan="5">
            <input type="text" size="45" name="publishdir" value="<%= site==null?"":site.GetArticleDir().getAbsolutePath() %>" >
            <%=bundle.getString("SITE_HINT_PUBLISHDIR")%>
          </td>  
        </tr>
		
         <tr height=30 >
           <td align="center" width="120"><b><%=bundle.getString("SITE_IMGROOT")%></b></td>
           <td colspan="5">
             <input type="text" size="45" name="imgrooturl" value="<%= site==null?"":site.GetImgURL() %>"  >
             <%=bundle.getString("SITE_HINT_IMGROOT")%>
           </td>
        </tr>
        <tr height=30 >
          <td align="center" width="120"><b><%=bundle.getString("SITE_IMG_PUBLISHDIR")%></b></td>
          <td colspan="5">
            <input type="text" size="45" name="imgpublishdir" value="<%= site==null?"":site.GetImgDir().getAbsolutePath() %>" >
            <%=bundle.getString("SITE_HINT_IMG_PUBLISHDIR")%>
          </td>		  
        </tr> 

      <tr height=30>
          <td align="center" width="120"><b><%=bundle.getString("SITE_THREADS")%></b></td>
          <td colspan="5">
              <input type="text" size=5 style="width:40px;" name="threads" value="<%=site==null?1:site.GetThreads()%>">
              <%=bundle.getString("SITE_THREADS_HINT")%>
          </td>
      </tr>
      <tr height=30 >
        <td colspan="2">&nbsp;
            <input type="checkbox" name="keylink_enabled" value="0" <%if(site!=null && site.IsKeywordLinkEnabled()) out.print("checked");%>>
            <b><%=bundle.getString("SITE_KEYWORDLINK_ENABLED")%></b>

            <input type="checkbox" name="keylink_ignorecase" value="0" <%if(site!=null && site.IsKeywordLinkIgnoreCase()) out.print("checked");%>>
            <b><%=bundle.getString("SITE_KEYWORDLINK_IGNORECASE")%></b>
        </td>
        <td align="center">
            <b><%=bundle.getString("SITE_KEYWORDLINK_CSS")%></b>
        </td>
        <td>
            <input type="text" name="keylink_css" value="<% if(site!=null) out.print(Utils.Null2Empty(site.GetKeywordLinkCSS()));%>">
        </td>
        <td align="center">
            <b><%=bundle.getString("SITE_KEYWORDLINK_TARGET")%></b>
        </td>
        <td>
            <input type="text" size="5" name="keylink_target" value="<% if(site!=null) out.print(Utils.Null2Empty(site.GetKeywordLinkTarget()));%>">
            <%=bundle.getString("SITE_KEYWORDLINK_TARGET_HINT")%>
        </td>
      </tr>

      <tr height=30 >
         <td colspan="6"><%=bundle.getString("SITE_KEYWORDLINK_HINT")%></td>
      </tr>
      <tr height=30 >
         <td colspan="6">
             <textarea name="keylink_words" rows="5" cols="80" style="width:100%"><%if(site!=null && site.GetKeywordLinks()!=null) out.print(Utils.Null2Empty(site.GetKeywordLinks().toString()));%></textarea>
         </td>
      </tr>

      <tr height="30"><td colspan="6"></td></tr>

      <tr height=30 >
        <td colspan="6" height="30" valign="top">
          <table id="VarTbl"  width="100%" border="0" align="left" cellpadding="0" cellspacing="1">
          <TBODY>
          <tr >
            <td colspan="4">
                  <b><%=bundle.getString("SITE_VARS")%></b>
                    <input type=button class="button" value="<%=bundle.getString("SITE_BUTTON_ADD_VAR")%>" onclick="javascript:add_var();">
                    <input type=button class="button" value="<%=bundle.getString("SITE_BUTTON_DEL_VAR")%>" onclick="javascript:del_var();">
            </td>
          </tr>
          <tr>
             <td><input type = "checkBox" name = "VarAllId" value = "0" onclick = "javascript:selectvar();"></td>
             <td width="160"><%=bundle.getString("SITE_VARS_NAME")%></td>
             <td width="300"><%=bundle.getString("SITE_VARS_VALUE")%></td>
             <td><%=bundle.getString("SITE_VARS_COMMENT")%></td>
          </tr>
          <%
              int rows = 0;
              if(site!=null)
              {
                  java.util.Hashtable vars = site.GetVars();
                  if(vars!=null && !vars.isEmpty())
                  {
                        Object[] keys = vars.keySet().toArray();
                        java.util.Arrays.sort(keys);
                        for(int key_index=0;key_index<keys.length;key_index++)
                        {
                            Site.Var var = (Site.Var)vars.get(keys[key_index]);
          %>
            <tr id='VarRow_<%=rows%>'>
              <td width="25">
                  <input type="checkbox" id="Varrowno" name="Varrowno" value="<%=rows%>">
              </td>
              <td align=left>
                  <input type=text name="var_name" value="<%=var.GetName()%>">
              </td>
              <td align="left">
                  <input type=text name="var_value" value="<%=Utils.Null2Empty(var.GetValue())%>" style="width:95%">
              </td>
              <td align="left">
                  <input type=text name="var_comment" value="<%=Utils.Null2Empty(var.GetComment())%>">
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
        </td>
      </tr>

      <tr height="30"><td colspan="6"></td></tr>

      <tr height=30 >
        <td colspan="6" height="30" valign="top">
          <table id="SolrTbl" border="0" align="left" cellpadding="0" cellspacing="1">
          <TBODY>
          <tr >
            <td colspan="3">
                  <b><%=bundle.getString("SITE_SOLRFIELDS")%></b>
                    <input type=button class="button" value="<%=bundle.getString("SITE_BUTTON_ADD_SOLRFIELD")%>" onclick="javascript:add_solrfield();">
                    <input type=button class="button" value="<%=bundle.getString("SITE_BUTTON_DEL_SOLRFIELD")%>" onclick="javascript:del_solrfield();">
            </td>
          </tr>
          <tr>
             <td width="25"><input type = "checkBox" name = "SolrAllId" value = "0" onclick = "javascript:selectsolrfield();"></td>
             <td width="160"><%=bundle.getString("SITE_SOLRFIELD_NAME")%></td>
             <td width="320"><%=bundle.getString("SITE_SOLRFIELD_COMMENT")%></td>
          </tr>
          <%
              rows = 0;
              if(site!=null)
              {
                  java.util.Hashtable fields = site.GetSolrFields();
                  if(fields!=null && !fields.isEmpty())
                  {
                      Object[] keys = fields.keySet().toArray();
                      java.util.Arrays.sort(keys);
                      for(int key_index=0;key_index<keys.length;key_index++)
                        {
                            Site.SolrField field = (Site.SolrField)fields.get(keys[key_index]);
          %>
            <tr id='SolrRow_<%=rows%>'>
              <td width="25">
                  <input type="checkbox" id="Solrrowno" name="Solrrowno" value="<%=rows%>">
              </td>
              <td align=left>
                  <input type=text name="solrfield_name" value="<%=field.GetName()%>">
              </td>
              <td align="left">
                  <input type=text name="solrfield_comment" value="<%=Utils.Null2Empty(field.GetComment())%>">
             </td>
            </tr>
          <%
                           rows++;
                       }
                  }
              }
          %>
              <script language="javascript">solr_rowNo = <%= rows %>;</script>
            </TBODY>
          </table>
        </td>
      </tr>


        <tr height="30"><td colspan="6"></td></tr>
        <tr height=30 >
          <td colspan="6" height="30" valign="top">
            <table id="AdmTbl"  width="100%" border="0" align="left" cellpadding="0" cellspacing="1">
            <TBODY>
            <tr >
			  <td height="30" valign="top" width="10">
                  <input type = "checkBox" name = "AdmAllId" value = "0" onclick = "javascript:selectuser();">
              </td>
              <td align="left">
                <b><%=bundle.getString("SITE_ADMIN")%></b>
<%
    if(user.IsSysAdmin())
    {
%>
                  <input type=button class="button" value="<%=bundle.getString("SITE_BUTTON_ADD_ADMIN")%>" onclick="javascript:add_admin();">
                  <input type=button class="button" value="<%=bundle.getString("SITE_BUTTON_DEL_ADMIN")%>" onclick="javascript:del_admin();">
<%
    }
%>
              </td>
			</tr>
            <%
                rows = 0;
                if(site!=null)
                {
                    java.util.Hashtable owners = site.GetOwner();
                    if(owners!=null && !owners.isEmpty())
                    {
                          Object[] keys = owners.keySet().toArray();
                          java.util.Arrays.sort(keys);
                          for(int key_index=0;key_index<keys.length;key_index++)
                          {
                              Site.Owner owner = (Site.Owner)owners.get(keys[key_index]);
            %>
              <tr id='AdmRow_<%=rows%>'>				
                <td>
                    <input type="checkbox" id="Admrowno" name="Admrowno" value="<%=rows%>">
                    <input type=hidden name="userId" value="<%=owner.GetID()%>">
               </td>
                <td>
                   <input type=text   name="userName" value="<%=owner.GetName()%>" readonly>
                </td>
              </tr>
            <%
                             rows++;
                         }
                    }
                }
            %>
                <input type=hidden name=curr_admin_row>
                <script language="javascript">adm_rowNo = <%= rows %>;</script>
              </TBODY>
            </table>
          </td>
        </tr>

        <tr height="30"><td colspan="6"></td></tr>
        <tr height=30>
          <td  colspan=6><%=bundle.getString("SITE_HINT_FTP")%></td>
        </tr>		    
        <tr height=30 >
          <td colspan="6" height="30" valign="top">
            <table id="FtpTbl_0" width=90% border="0" align="left" cellpadding="0" cellspacing="1">
            <tbody>
              <tr height=30>
                <td colspan="6">
                  <b><%=bundle.getString("SITE_FTP")%></b>
<%
    if(user.IsSysAdmin())
    {
%>
                  <input type=button class="button" value="<%=bundle.getString("SITE_BUTTON_ADD_FTP")%>" onclick="javascript:add_ftp();">
				  <input type=button class="button" value="<%=bundle.getString("SITE_BUTTON_DEL_FTP")%>" onclick="javascript:del_ftp();">
<%
    }
%>
                  <input type=hidden name="FtpTbl_0_curr_row">
			   </td>
		     </tr>
             <tr height=30>
               <td  valign="top">
                     <input type = "checkBox" name="aftpAllId" value = "0" onclick = "javascript:selectaftp();">
                </td>
               <td width=120 ><%=bundle.getString("SITE_FTPNAME")%></td>
               <td width=50><%=bundle.getString("SITE_FTPPORT")%></td>
               <td width=180><%=bundle.getString("SITE_FTPROOT")%></td>
               <td width=100><%=bundle.getString("SITE_FTPUSER")%></td>
               <td><%=bundle.getString("SITE_FTPPASSWORD")%></td>
             </tr>
<%
              if(site!=null)
                {
                    java.util.List hosts = site.GetArticleFtpHosts();
                    rows = 0;
                    if(hosts!=null && !hosts.isEmpty())
                    {
                          for(Object obj:hosts)
                          {
                              FtpHost host  = (FtpHost)obj;
%>
              <tr id="aftp_<%=rows%>" height=30>
                <td>
                    <input type = "checkBox" id="aftpno" name="aftpno" value = "<%= rows %>">
                </td>
                <td>
				  <input type=text name=ftp_host value="<%=host.GetHostname()%>"  size=25>
				</td>
				<td><input type=text name=ftp_port value="<%=host.GetRemoteport()%>"  size=6></td>
				<td><input type=text name=ftp_remotedir value="<%=host.GetRemotedir()%>"  size=40></td>
				<td><input type=text name=ftp_username value="<%=host.GetUsername()%>"  ></td>
				<td><input type=password name=ftp_userpwd value="<%=host.GetUserpassword()%>"  ></td>
              </tr>
<%
                            rows++;
                        }
%>
                        <script language="javascript"> aftp_rowno = <%= rows %>;</script>
<%
                    }
              }
%>
            </tbody>  
            </table>
          </td>
        </tr>  

        <tr height="30"><td colspan="6"></td></tr>
        <tr height=30>
		   <td  colspan=6><%=bundle.getString("SITE_HINT_IMG_FTP")%>
		   </td>
		 </tr>		
		 

        <tr height=30 >
          <td colspan="6" height="30" valign="top">
            <table id="FtpTbl_1" width=90% border="0" align="left" cellpadding="0" cellspacing="1">
             <tbody>
              <tr height=30>
			    <td colspan="6" height="30" valign="top">
			      <b><%=bundle.getString("SITE_FTP")%></b>
<%
    if(user.IsSysAdmin())
    {
%>
                  <input type=button class="button" value="<%=bundle.getString("SITE_BUTTON_ADD_IMG_FTP")%>" onclick="javascript:add_iftp();">
				  <input type=button class="button" value="<%=bundle.getString("SITE_BUTTON_DEL_IMG_FTP")%>" onclick="javascript:del_iftp();">
<%
    }
%>
                  <input type=hidden name="FtpTbl_1_curr_row">
			    </td>
		      </tr> 
              <tr height=30>
                <td>
                    <input type = "checkBox" name = "iftpAllId" value = "0" onclick = "javascript:selectiftp();">
                </td>
                  <td width=120 ><%=bundle.getString("SITE_FTPNAME")%></td>
                  <td width=50><%=bundle.getString("SITE_FTPPORT")%></td>
                  <td width=180><%=bundle.getString("SITE_FTPROOT")%></td>
                  <td width=100><%=bundle.getString("SITE_FTPUSER")%></td>
                  <td><%=bundle.getString("SITE_FTPPASSWORD")%></td>
              </tr>
<%
              if(site!=null)
                {
                    java.util.List hosts = site.GetImageFtpHosts();
                    rows = 0;
                    if(hosts!=null && !hosts.isEmpty())
                    {
                          for(Object obj:hosts)
                          {
                              FtpHost host  = (FtpHost)obj;
%>
             <tr id="iftp_<%=rows%>" height=30>
                <td>
                    <input type = "checkBox" id="iftpno" name="iftpno" value = "<%= rows %>">
                </td>
				<td>
				  <input type=text name=img_ftp_host value="<%=host.GetHostname()%>"  size=25>
				</td>
				<td><input type=text name=img_ftp_port value="<%=host.GetRemoteport()%>"  size=6></td>
				<td><input type=text name=img_ftp_remotedir value="<%=host.GetRemotedir()%>"  size=40></td>
				<td><input type=text name=img_ftp_username value="<%=host.GetUsername()%>"  ></td>
				<td><input type=password name=img_ftp_userpwd value="<%=host.GetUserpassword()%>"  ></td>
              </tr>
<%
                            rows++;
                        }
%>
                        <script language="javascript"> iftp_rowno = <%= rows %>;</script>
<%            
                    }
              }
%>
            </tbody>
            </table>
          </td>
        </tr>  
      </table>
  </form>          
 </body>
</html>