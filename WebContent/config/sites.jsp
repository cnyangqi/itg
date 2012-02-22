<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.core.NpsWrapper" %>
<%@ page import="nps.core.Site" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.Config" %>
<%@ page import="nps.util.Utils" %>
<%@ include file = "/include/header.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");
    String job = request.getParameter("job");

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_sites",user.GetLocale(), Config.RES_CLASSLOADER);
    
    if("rebuild".equalsIgnoreCase(job))
    {
        //重建站点
        NpsWrapper wrapper  = null;
        String[] rownos = request.getParameterValues("rowno");
        if(rownos!=null && rownos.length>0)
        {
            try
            {
                wrapper = new NpsWrapper(user);
                for(int i=0;i<rownos.length;i++)
                {
                    String site_id = request.getParameter("site_id_" + rownos[i]);
                    Site site = wrapper.GetSite(site_id);
                    if(site!=null)
                    {
                        out.println("<br>");
                        out.println("&nbsp;&nbsp;"+bundle.getString("SITES_BUILD_INPROGRESS")+"<b><font color=red>"+site.GetName()+"</font></b>......");
                        out.println("<br>");
                        wrapper.GenerateSite(true);
                        out.println("&nbsp;&nbsp;<font color=red><b>"+site.GetName()+"</b></font>"+bundle.getString("SITES_BUILD_SUCCESS"));
                        out.println("<br>");
                    }
                }
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
    }
%>
<HTML>
<HEAD>
	<TITLE><%=bundle.getString("SITES_HTMLTITLE")%></TITLE>
	<LINK href="/css/style.css" rel = stylesheet>
	<script type="text/javascript" src="/jscript/global.js"></script>
</HEAD>	
<script language="javascript">
	function f_new()
	{
        document.siteListFrm.id.value="";
        document.siteListFrm.action = "siteinfo.jsp";
        document.siteListFrm.target="_blank";
        document.siteListFrm.submit();
    }

    function f_rebuild()
    {
       var rownos = document.getElementsByName("rowno");
       var hasChecked = false;
       for (var i = 0; i < rownos.length; i++)
       {
           if( rownos[i].checked )
           {
               hasChecked = true;
               break;
           }
       }
       if( !hasChecked ) return false;

       var r = confirm("<%=bundle.getString("SITES_HINT_REBUILD")%>");
       if( r !=1 ) return false;
       document.siteListFrm.action = "sites.jsp?job=rebuild";
       document.siteListFrm.target="_self";
       document.siteListFrm.submit();
    }

    function f_showimport()
    {
        if(document.getElementById("import_bar").style.display=="none")
        {
            document.getElementById("import_bar").style.display="block";
        }
        else
        {
            document.getElementById("import_bar").style.display="none";
        }
    }

    function f_import()
	{
        document.frm_imp.submit();
    }

    function viewsite(siteid)
	{
        document.siteListFrm.id.value = siteid;
        document.siteListFrm.action = "siteinfo.jsp";
        document.siteListFrm.target="_blank";
        document.siteListFrm.submit();
    }
    
   function SelectSite()
    {
      var rownos = document.getElementsByName("rowno");
      for (var i = 0; i < rownos.length; i++)
      {
         rownos[i].checked = document.siteListFrm.AllId.checked;
      }
    }
</script>
	
<BODY leftMargin="3" topMargin = "0">
  <div id="import_bar" style="display:none">
    <table width="90%"  border = "0" align ="center" cellpadding = "0" cellspacing = "0" >
      <form name="frm_imp" action="siteimport.jsp" method="post" encType="multipart/form-data">
          <%=bundle.getString("SITES_HINTS_CHOOSE_IMPORTFILE")%><input type="file" name="import_file" value=""><br><br>
          <%=bundle.getString("SITES_HINTS_IMPORT")%>
          <input type="button" class="button" value="<%=bundle.getString("SITES_BUTTON_SUBMIT")%>" onclick="f_import()"> 
      </form>
    </table>
  </div>
  <table width ="100%" border = "0" align ="center" cellpadding = "0" cellspacing = "0" class="positionbar">
    <tr height="30" >
      <td  valign="middle" >&nbsp;
<%
   if(user.IsSysAdmin())
   {
%>
        <input name="addBtn" type="button" onClick="f_new()"  value="<%=bundle.getString("SITES_BUTTON_ADD")%>" class="button">
        <input name="impBtn" type="button" onClick="f_showimport()"  value="<%=bundle.getString("SITES_BUTTON_IMPORT")%>" class="button">
<%
    }
%>
        <input name="rebuildBtn" type="button" onClick="f_rebuild()"  value="<%=bundle.getString("SITES_BUTTON_REBUILD")%>" class="button">
    </tr>
  </table>  
  <table width = "100%" border = "0" align = "center" cellpadding = "0" cellspacing = "1" class="titlebar">
    <form name="siteListFrm" action="siteinfo.jsp" method = "post" target="_blank">
     <input type ="hidden" name ="id" value = "">
    <tr height=30>
      <td width="25"><input type = "checkBox" name = "AllId" value = "0" onclick = "SelectSite()"></td>
      <td ><%=bundle.getString("SITES_SITENAME")%></td>
    </tr>

    <%
      java.util.Hashtable sites = user.GetOwnSites();
      //key:id value:caption
      if((sites!=null) && !sites.isEmpty())
      {
         int i=0;
         java.util.Enumeration sitekeys = sites.keys();
         while(sitekeys.hasMoreElements())
         {
           String site_id = (String)sitekeys.nextElement();
           String site_caption = (String)sites.get(site_id);
    %>
              <tr height=30 class="detailbar">
                <td >
                    <input type = "checkBox" id="rowno" name="rowno" value = "<%= i %>">
                    <input type="hidden" name="site_id_<%=i%>" value="<%= site_id %>">
                </td>
                <td><a href="javascript:viewsite('<%= site_id %>');"><%= Utils.TransferToHtmlEntity(site_caption) %></a></td>
              </tr>
    <%
           i++;
         }//while(sitekeys.hasMoreElements())
       }//if((sites!=null) && !sites.isEmpty())
    %>
      </form>
    </table>
 </body>
</html>