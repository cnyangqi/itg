<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>

<%@ include file = "/include/header.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");

    String site = request.getParameter("site");
    if(site!=null) site = site.trim();

    String table = request.getParameter("table");
    if(table!=null)  table = table.trim().toUpperCase();

    boolean bNew=(site==null || site.length()==0);

    if(!(user.IsSysAdmin() || user.IsLocalAdmin()))
       throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

    NpsWrapper wrapper = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String sql = null;
    try
    {
        if(!bNew)
        {
            wrapper = new NpsWrapper(user);
            pstmt = wrapper.GetContext().GetConnection().prepareStatement("select sql from config_backup where siteid=? and table_name=?");
            pstmt.setString(1,site);
            pstmt.setString(2,table);
            rs = pstmt.executeQuery();
            if(rs.next()) sql = rs.getString("sql");

            try{rs.close();}catch(Exception e){}
            try{pstmt.close();}catch(Exception e){}
        }

        ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_utable",user.GetLocale(), Config.RES_CLASSLOADER);
%>

<html>
  <head>
    <title><%=bundle.getString("UTABLE_HTMLTILE")%></title>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>

    <script language="javascript">
        function f_save()
        {
          var frm = document.utableFrm;
          if( frm.site.value.trim() == "")
          {
              alert( "<%=bundle.getString("UTABLE_ALERT_SITE_IS_NULL")%>");
              frm.table.focus();
              return false;
          }

          if( frm.table.value.trim() == "")
          {
            alert( "<%=bundle.getString("UTABLE_ALERT_TABLE_IS_NULL")%>");
            frm.table.focus();
            return false;
          }
          if( frm.sql.value.trim()== "")
          {
            alert( "<%=bundle.getString("UTABLE_ALERT_SQL_IS_NULL")%>");
            frm.sql.focus();
            return false;
          }
          frm.act.value='0';
          frm.action ="utablesave.jsp";
          frm.target="_self";
          frm.submit();
        }

        function f_delete()
        {
            var r = confirm("<%=bundle.getString("UTABLE_ALERT_DELETE")%>");
            if( r !=1 ) return false;

            var frm = document.utableFrm;
            frm.act.value='1';
            frm.action ="utablesave.jsp";
            frm.target="_self";
            frm.submit();
        }
     </script>
  </head>

  <body leftmargin="20">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr height=30>
        <td>&nbsp;
      <%
           boolean bSavable = true;
           boolean bDeletable = bNew?false:true;

           if(bSavable)
           {
      %>
           <input type="button" name="okbtn" value="<%=bundle.getString("UTABLE_BUTTON_SAVE")%>" class="button" onclick="f_save()">
<%
           }
           if(bDeletable)
           {
%>
           <input type="button" name="deletebtn" value="<%=bundle.getString("UTABLE_BUTTON_DELETE")%>" class="button" onclick="f_delete()">
<%
           }
%>
           <input type="button" name="closebtn" value="<%=bundle.getString("UTABLE_BUTTON_CLOSE")%>" class="button" onclick="javascript:window.close();">
        </td>
      </tr>
    </table>

   <table width="100%" cellpadding = "0" cellspacing = "0" border="1">
     <form name="utableFrm" method="post" action ="utablesave.jsp">
     <input type="hidden" name="act" value="0">
     <tr height="30">
       <td width=80 align=center><b><%=bundle.getString("UTABLE_SITE")%></b></td>
       <td>
           <select name="site">
               <option value=""></option>
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
               <option value="<%=site_id%>" <% if(site_id.equals(site)) out.print("selected");%>><%=site_caption%></option>
     <%
            i++;
          }//while(sitekeys.hasMoreElements())
        }//if((sites!=null) && !sites.isEmpty())
     %>
           </select>
       </td>
     </tr>
     <tr height="30">
       <td width=80 align=center><b><%=bundle.getString("UTABLE_TABLE")%></b></td>
       <td>
           <input type="text" name="table" value="<%=Utils.Null2Empty(table)%>">
       </td>         
     </tr>
     <tr>
       <td width=80 align=center><b><%=bundle.getString("UTABLE_SQL")%></b></td>
       <td>
           <textarea name="sql" rows="25" cols="5" style="width:100%"><%=Utils.Null2Empty(sql)%></textarea>
       </td>
     </tr>
     </form>
   </table>
</body>
</html>
<%
    }
    finally
    {
        if(wrapper!=null) wrapper.Clear();
    }
%>