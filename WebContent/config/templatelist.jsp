<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.core.NpsWrapper" %>
<%@ page import="nps.core.TemplateBase" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.Config" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.net.URLEncoder" %>
<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    int rowperpage = 25;
    int currpage = 1, startnum = 0, endnum = 0, totalrows = 0, totalpages = 0, rownum=0;
    String scrollstr = "", nextpage = "templatelist.jsp";
    String currpg    = request.getParameter("page");
    try{ currpage = Integer.parseInt(currpg);	}catch (Exception e){currpage = 1;	}
    String id = null;
    Connection con   = null;
    PreparedStatement pstmt   = null;
    ResultSet rs     = null;
    String sql 		 = null;

    String act = request.getParameter("act");
    if(act!=null)  act = act.trim();

    String site = request.getParameter("site");
    if(site!=null)
    {
        site = site.trim();
        if(site.length()==0) site = null;
    }

    String type = request.getParameter("type");
    if(type!=null)
    {
        type = type.trim();
        if(type.length()==0) type = null;
    }

    String template_name = request.getParameter("template_name");
    if(template_name!=null)
    {
        template_name = template_name.trim();
        if(template_name.length()==0) template_name = null;
        if(template_name!=null && !template_name.endsWith("%")) template_name = template_name + "%";
    }
    
    if(site!=null)
    {
        if(scrollstr.length()>0)
           scrollstr += "&site="+site;
        else
           scrollstr += "site="+site;
    }

    if(type!=null)
    {
        if(scrollstr.length()>0)
           scrollstr += "&type="+type;
        else
           scrollstr += "type="+type;
    }

    if(template_name!=null)
    {
        if(scrollstr.length()>0)
           scrollstr += "&template_name=" + URLEncoder.encode(template_name,"UTF-8");
        else
           scrollstr += "template_name="+ URLEncoder.encode(template_name,"UTF-8");
    }

    if(!(user.IsSysAdmin() || user.IsLocalAdmin()))
       throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_templatelist",user.GetLocale(), Config.RES_CLASSLOADER);    
    NpsWrapper wrapper = null;

    if("recompile".equalsIgnoreCase(act))
    {
        try
        {
            wrapper = new NpsWrapper(user);
            wrapper.SetErrorHandler(response.getWriter());
            wrapper.SetLineSeperator("<br>\n");
            wrapper.GenerateAllClassThenCompile();
        }
        catch(Exception e)
        {
            throw e;
        }
        finally
        {
           if(wrapper!=null) wrapper.Clear();
           wrapper = null;
        }
    }
%>

<HTML>
	<HEAD>
		<TITLE><%=bundle.getString("TEMPLATELIST_HTMLTILE")%></TITLE>
        <script type="text/javascript" src="/jscript/global.js"></script>
        <LINK href="/css/style.css" rel = stylesheet>        
		<script langauge = "javascript">
			function f_new()
			{
				document.listFrm.action	= "templateinfo.jsp";
                document.listFrm.target="_blank";
                document.listFrm.submit();
            }

            function f_search()
            {
                document.searchFrm.submit();
            }
            
            function f_recompile()
            {
                document.listFrm.action = "templatelist.jsp";
                document.listFrm.act.value = "recompile";
                document.listFrm.target ="_self";
                document.listFrm.submit();
            }

            function openTemplate(idvalue)
            {
                document.frmOpen.id.value = idvalue;
                document.frmOpen.submit();
            }

            function selectTemplate()
            {
                var rownos = document.getElementsByName("rowno");
                for (var i = 0; i < rownos.length; i++)
                {
                   rownos[i].checked = document.listFrm.AllId.checked;
                }
            }
        </script>
	</HEAD>	
	
  <BODY leftMargin="20" topMargin = "0">
  <table width = "100% " border = "0" align = "center" cellpadding = "0" cellspacing = "0" class="positionbar">
    <tr>
      <td valign="middle">&nbsp;
        <input name="newBtn" type="button" onClick="f_new()" value="<%=bundle.getString("TEMPLATELIST_BUTTON_NEW")%>" class="button">
        <input name="searchBtn" type="button" onClick="f_search()" value="<%=bundle.getString("TEMPLATELIST_BUTTON_SEARCH")%>" class="button">          
<%
   if(user.IsSysAdmin())
   {
%>          
        <input name="recompileBtn" type="button" onclick="f_recompile()" value="<%=bundle.getString("TEMPLATELIST_BUTTON_RECOMPILEALL")%>" class="button">
<%
    }
%>          
      </td>
	</tr>
  </table>

  <table width = "100% " border = "0" align = "center" cellpadding = "0" cellspacing = "0" class="positionbar">
    <form name = "searchFrm" method = "post" action="templatelist.jsp">
      <tr align="center">
          <td width="80"><%=bundle.getString("TEMPLATELIST_SITE")%></td>
          <td width=120 align="left">
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
          <td width="80"><%=bundle.getString("TEMPLATELIST_TYPE")%></td>
          <td width=120  align="left">
              <select name="type">
                  <option value=""></option>
                  <option value="0" <% if("0".equals(type)) out.print("selected");%>><%=bundle.getString("TEMPLATELIST_TYPE_ARTICLE")%></option>
                  <option value="2" <% if("2".equals(type)) out.print("selected");%>><%=bundle.getString("TEMPLATELIST_TYPE_PAGE")%></option>
              </select>
          </td>
          <td width="80"><%=bundle.getString("TEMPLATELIST_NAME")%></td>
          <td width=120  align="left">
              <input type="text" name="template_name" value="<%=Utils.Null2Empty(template_name)%>">
          </td>
          <td>&nbsp;</td>
      </tr>
      </form>  
  </table>

  
  <table width = "100%" border = "0" align = "center" cellpadding = "0" cellspacing = "1" class="titlebar">
  <form name = "listFrm" method = "post">
     <input type="hidden" name="act" value="">
      <tr height=30>
	      <td width="25">
    		<input type = "checkBox" name = "AllId" value = "0" onclick = "selectTemplate()">
		  </td>
 	      <td><%=bundle.getString("TEMPLATELIST_NAME")%></td>
		  <td width = "120"><%=bundle.getString("TEMPLATELIST_TYPE")%></td>
          <td width = "120"><%=bundle.getString("TEMPLATELIST_SCOPE")%></td>
          <td width = "80"><%=bundle.getString("TEMPLATELIST_CREATOR")%></td>
          <td width = "80"><%=bundle.getString("TEMPLATELIST_CREATEDATE")%></td>
      </tr>
<%
    try
    {
        //只能编辑自己创建的模板
        //scope=0全局的仅可以选择，不能修改
        //scope=1属于本单位的，仅可以选择，不能修改
        con = Database.GetDatabase("nps").GetConnection();
        if(user.IsSysAdmin())
        {
            sql = "select count(*) from template a where 1=1";
        }
        else
        {
            sql = "select count(*) from template a where (a.scope=0 or a.creator=? "
                    +" or (a.scope=1 and exists(Select b.Id  From users b,dept c Where b.Id=a.creator And b.dept=c.Id And c.unit=?))"
                    +" or (a.Scope=2 And Exists (Select siteid From site_owner f Where a.siteid=f.siteid And f.userid=?))"
                    +" )";
        }

        if(site!=null)
        {
            sql += " and (a.scope=0 or (a.scope=2 and a.siteid=?) or (a.scope=1 and exists(Select b.Id  From users b,dept c,site d Where b.Id=a.creator And b.dept=c.Id And d.unit=c.unit And c.unit=? and d.id=?)))";
        }

        if(type!=null)
        {
            sql += " and type=?";
        }

        if(template_name!=null)
        {
            sql += " and name like ?";
        }

        pstmt = con.prepareStatement(sql);
        int j=1;
        if(!user.IsSysAdmin())
        {
            pstmt.setString(j++,user.GetUID());
            pstmt.setString(j++,user.GetUnitId());
            pstmt.setString(j++,user.GetUID());
        }

        if(site!=null)
        {
            pstmt.setString(j++,site);
            pstmt.setString(j++,user.GetUnitId());
            pstmt.setString(j++,site);
        }

        if(type!=null)
        {
            pstmt.setString(j++,type);
        }

        if(template_name!=null)
        {
            pstmt.setString(j++,template_name);
        }
        
        rs = pstmt.executeQuery();
        if (rs.next())  totalrows = rs.getInt(1);
        try{rs.close();}catch(Exception e){}
        try{pstmt.close();}catch(Exception e){}

        if (totalrows > 0)
        {
            totalpages = (int )((totalrows - 1) / rowperpage) + 1;
            startnum = rowperpage * (currpage - 1) + 1;
            endnum = currpage * rowperpage;
            if(user.IsSysAdmin())
            {
                sql = "select id,name,type,scope,(select name from site c where c.id=a.siteid) sitename,(select name from users b where b.id=a.creator) creator,createdate from template a where 1=1";
            }
            else
            {
                sql = "select id,name,type,scope,(select name from site c where c.id=a.siteid) sitename,(select name from users b where b.id=a.creator) creator,createdate from template a where (a.scope=0 or a.creator=?"
                     +" or (a.scope=1 and exists(Select b.Id  From users b,dept c Where b.Id=a.creator And b.dept=c.Id And c.unit=?))"
                     +" or (a.Scope=2 And Exists (Select siteid From site_owner f Where a.siteid=f.siteid And f.userid=?))"
                     +")";
            }

            if(site!=null)
            {
                sql += " and (a.scope=0 or (a.scope=2 and a.siteid=?) or (a.scope=1 and exists(Select b.Id  From users b,dept c,site d Where b.Id=a.creator And b.dept=c.Id And d.unit=c.unit And c.unit=? and d.id=?)))";
            }

            if(type!=null)
            {
                sql += " and type=?";
            }

            if(template_name!=null)
            {
                sql += " and name like ?";
            }

            pstmt = con.prepareStatement(sql);

            j=1;
            if(!user.IsSysAdmin())
            {
                pstmt.setString(j++,user.GetUID());
                pstmt.setString(j++,user.GetUnitId());
                pstmt.setString(j++,user.GetUID());
            }

            if(site!=null)
            {
                pstmt.setString(j++,site);
                pstmt.setString(j++,user.GetUnitId());
                pstmt.setString(j++,site);
            }

            if(type!=null)
            {
                pstmt.setString(j++,type);
            }

            if(template_name!=null)
            {
                pstmt.setString(j++,template_name);
            }

            rs = pstmt.executeQuery();

            String templateId = null;
            rownum = 0;
            while (rs.next() && (rs.getRow() <= endnum))
            {
                if (rs.getRow() < startnum) continue;

                templateId = rs.getString("id");
%>
	          <tr class="detailbar">
				<td> 
                  <input type = "checkBox" id="rowno" name="rowno" value = "<%= rs.getRow() %>"> 
                  <input type = "hidden" name = "template_id_<%= rs.getRow() %>" value = "<%= templateId %>"> 
				</td>
				<td>
                  <a href="javascript:openTemplate('<%= templateId %>');"><%= rs.getString("name") %></a>
				</td>				
				<td>
                  <%
                      switch(rs.getInt("type"))
                      {
                          case 0:
                              out.print(bundle.getString("TEMPLATELIST_TYPE_ARTICLE"));
                              break;
                          case 2:
                              out.print(bundle.getString("TEMPLATELIST_TYPE_PAGE"));
                              break;
                      }
                  %>
                </td>
				<td>
                  <%
                      switch(rs.getInt("scope"))
                      {
                          case 0:
                              out.print(bundle.getString("TEMPLATELIST_SCOPE_FULL"));
                              break;
                          case 1:
                              out.print(bundle.getString("TEMPLATELIST_SCOPE_ALLMYSITE"));
                              break;
                          case 2:
                              out.print(rs.getString("sitename")==null?"":rs.getString("sitename"));
                              break;
                      }
                  %>
                </td>                                 
                <td>
                   <%= rs.getString("creator")==null?"&nbsp;":rs.getString("creator") %>
                </td>
                <td>
	      		   <%= Utils.FormateDate(rs.getDate("createdate"),"yyyy-MM-dd") %>
                </td>
              </tr>
          <%
              }
			}  //end of if (totalrows >0)
    }
    catch (Exception ee)
    {
         throw ee;
    }
    finally
    {
        if (pstmt != null) try{ pstmt.close();}catch(Exception e){}
        if (con != null)  try{ con.close(); }catch(Exception e){}
    }
 %>
 </form>
 </table>
<form name=frmOpen action="templateinfo.jsp" target="_blank">
  <input type = "hidden" name = "id">
</form>
<%@ include file = "/include/scrollpage.jsp" %>
</body>
</html>