<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.core.Database" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.Config" %>
<%@ page import="nps.util.Utils" %>
<%@ include file="/include/header.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");
    String sTemplateType = request.getParameter("type");  //0文章模板  2页面模板
    String siteid = request.getParameter("siteid");
	
	if( siteid == null)  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

    int templateType = 0;
    try{templateType=Integer.parseInt(sTemplateType);}catch(Exception e1){}

    String keyword = request.getParameter("keyword");
    if(keyword!=null && keyword.length()>0 && !keyword.endsWith("%")) keyword = keyword + "%";

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_selecttemplate",user.GetLocale(), Config.RES_CLASSLOADER);
%>
<html>
<head>
<title><%=bundle.getString("SELTEMPLATE_HTMLTITLE")%></title>
    <script language = "javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>
    
   <script language="javascript">
     function f_return(id, name, outfilename)
     {
         var isMSIE= (navigator.appName == "Microsoft Internet Explorer");
          if (isMSIE)
          {
             var   rt = new Array(3);
             rt[0] = id;
             rt[1] = name;
             rt[2] = outfilename;
             window.returnValue= rt;
          }
          else
          {
<%
            if(templateType==0)
            {
%>
                 parent.opener.f_setArticleTemplate(id,name);
<%
            }
            else
            {
%>
                 parent.opener.f_setPageTemplate(id,name,outfilename);
<%
            }
%>
          }

          top.close();
      }

     function f_returnMulti()
     {
         var isMSIE= (navigator.appName == "Microsoft Internet Explorer");
         var pages = document.getElementsByName("pg_check");
         for(var i = 0; i < pages.length; i++)
         {
           if (pages[i].checked) {
<%
            if(templateType==0)
            {
%>
	         if (isMSIE)
	         {
                 window.dialogArguments.f_setArticleTemplate(pages[i].mod_id,pages[i].mod_name);
             }
             else
             {
                 parent.opener.f_setArticleTemplate(pages[i].mod_id,pages[i].mod_name);
             }
<%
            }
            else
            {
%>
	         if (isMSIE)
	         {
                 window.dialogArguments.f_setPageTemplate(pages[i].mod_id,pages[i].mod_name,pages[i].file_name);
             }
             else
             {
                 parent.opener.f_setPageTemplate(pages[i].mod_id,pages[i].mod_name,pages[i].file_name);
             }
<%
            }
%>
            }
          }
          top.close();
     }
   </script>
</head>
<body leftmargin="20" topmargin="0">
  <table width = "100% " border = "0" align = "center" cellpadding = "0" cellspacing = "0" class="positionbar">
      <form name="frm_search" method="post" action="selecttemplate.jsp">
          <input type="hidden" name="siteid" value="<%=siteid%>">
          <input type="hidden" name="type" value="<%=sTemplateType%>">
      <tr>
        <td valign="middle">&nbsp;
            <%=bundle.getString("SELTEMPLATE_NAME")%><input type="text" name="keyword" value="<%=Utils.Null2Empty(keyword)%>">
            <input name='btn_search' type="submit" class="button" value="<%=bundle.getString("BUTTON_SEARCH")%>">
        </td>
      </tr>
      </form>    
  </table>

  <table border="0" cellpadding="0" cellspacing="1" width="100%" class="titlebar">
    <tr height=30>
      <td width="5"></td>
      <td width=150><b><%=bundle.getString("SELTEMPLATE_NAME")%></b></td>
      <td width=120>
          <b><%=bundle.getString("SELTEMPLATE_OUTPUTFILENAME")%></b>
          <%
                  if(templateType!=0)
                  {
          %>
                    &nbsp;<input name="fin2" type="button" value="<%=bundle.getString("BUTTON_OK")%>" onclick="javascript:f_returnMulti()">
          <%
                  }
          %>                  
      </td>
    </tr>  
    <%	  
	  Connection con = null;
	  PreparedStatement pstmt = null;
	  ResultSet rs = null;	  
	  try
      {
	    con = Database.GetDatabase("nps").GetConnection();
        String sql = "select id,name,fname,suffix from template a where type=? and (scope=0 or siteid=? or (scope=1 and exists(\n"+
                        "Select a1.unit  from dept a1,users a2,dept b1,users b2\n" +
                        "where a1.Id=a2.dept\n" +
                        "  And b1.Id=b2.dept\n" +
                        "  And a1.unit = b1.unit\n" +
                        "  And b2.Id=a.creator\n" +
                        "  And a2.Id=?)))";
        if(keyword!=null && keyword.length()>0) sql += " and name like ?";          
        sql += " order by createdate desc";
        pstmt = con.prepareStatement(sql);
        pstmt.setInt(1,templateType);
        pstmt.setString(2,siteid);
        pstmt.setString(3,user.GetUID());
        if(keyword!=null && keyword.length()>0)  pstmt.setString(4,keyword);       

        rs = pstmt.executeQuery();	    
	    while( rs.next() )
        {
  	        String mod_id = rs.getString("id");
	        String mod_name = rs.getString("name");
	        String outFileName = null;
            if(templateType==0)
                outFileName = rs.getString("suffix");
            else
                outFileName = rs.getString("fname");
            
            if(outFileName==null)
            {
                outFileName = "";
            }
            else
            {
                outFileName = Utils.TransferToHtmlEntity(outFileName);
            }
%>
        <tr height="25" class="detailbar">
          <td align="center"><%if(templateType!=0){%><input type="checkbox" id="_p_<%=mod_id%>" name="pg_check" mod_id="<%=mod_id%>" mod_name="<%=mod_name%>" file_name="<%=outFileName%>"><%}%></td>
          <td>
                <a onclick="javascript:f_return('<%=mod_id%>','<%=mod_name%>','<%=outFileName%>');"><%= mod_name %></a>
          </td>
          <td ><%= outFileName %>&nbsp;</td>
        </tr>  
<%	      
	    }
        if(templateType==0)
        {
            //内置空白文章模版
%>
          <tr height="25" class="detailbar">
              <td align="center"></td>
              <td>
                    <a onclick="javascript:f_return('0','<%=bundle.getString("SELTEMPLATE_EMBEDDED_TEMPLATE")%>','');"><%=bundle.getString("SELTEMPLATE_EMBEDDED_TEMPLATE")%></a>
              </td>
              <td >&nbsp;</td>
          </tr>
<%
        }
        else
        {
%>
            <tr height="25" class="detailbar">
              <td colspan="3" align="right"><input name="fin" type="button" value="<%=bundle.getString("BUTTON_OK")%>" onclick="javascript:f_returnMulti()"></td>
            </tr>  
<%
        }
	  }
	  finally
      {	
	    if( rs   != null) rs.close();
	    if( pstmt != null) pstmt.close();
	    if( con  != null) con.close();
	  }
  %>
  </table>
</body>
</html>