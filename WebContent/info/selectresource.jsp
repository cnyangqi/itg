<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.core.*" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Calendar" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    final int IMAGES_PER_ROW = 3;
    int rowperpage = 25;
    int currpage = 1, startnum = 0, endnum = 0, totalrows = 0, totalpages = 0, rownum=0;
    String scrollstr = "", nextpage = "selectresource.jsp";
    String currpg    = request.getParameter("page");
    try{ currpage = Integer.parseInt(currpg);	}catch (Exception e){currpage = 1;	}

    //站点id，站点id将作为默认的宿主站点
    String siteid = request.getParameter("siteid");
    if(siteid!=null) siteid = siteid.trim();
    boolean bAccessible = false;
    if(siteid!=null && siteid.length()>0) bAccessible = user.IsAccessibleSite(siteid);
    if(!bAccessible)
    {
        //如果当前用户对该站点没有权限查看，那么使用缺省站点
        // 如果没有缺省站点（该单位有多个站点时没有设置缺省站点），则取第一个站点作为宿主站点
        siteid = user.GetDefaultSiteId();
        if(siteid==null)
        {
            Hashtable sites_myunits = user.GetUnitSites();
            if(sites_myunits!=null && !sites_myunits.isEmpty())
            {
                siteid = (String)sites_myunits.keys().nextElement();
            }
        }
    }
    if(siteid==null) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

    scrollstr = "siteid="+siteid;

    //回调函数
    String func = request.getParameter("func");
    if(func!=null)
    {
        func = func.trim();
        if(func.length()==0) func = null;
    }
    if(func!=null) scrollstr += "&func="+func;

    //是否可以多选
    boolean bMultiple = false;
    String multiple = request.getParameter("multiple");
    if("1".equals(multiple))
    {
        bMultiple = true;
        scrollstr += "&multiple=1";
    }

    //关键字
    String keyword = request.getParameter("keyword");
    if(keyword!=null)
    {
        keyword = keyword.trim();
        scrollstr += "&keyword="+keyword;
    }

    //查询的日期类型
    String sDatetype = request.getParameter("datetype");
    int date_type = -1; //默认全部 -1全部 0今天 1昨天 2最近7天 3最近30天
    try{date_type = Integer.parseInt(sDatetype);}catch(Exception e){}
    scrollstr += "&datetype="+date_type;

    //查看的文件类型
    int type = -1; //缺省为所有类型 -1全部 0图片 1文档 2视频 3音频 4Flash 5其他
    String sType = request.getParameter("type");
    try{type = Integer.parseInt(sType);}catch(Exception e){}
    scrollstr += "&type="+type;
    
    //如果是图片，采用缩略图显示
    if(type==0)
    {
        rowperpage = IMAGES_PER_ROW * 4;
    }

    //操作
    int act = 0;
    String sAct = request.getParameter("act");
    try{act = Integer.parseInt(sAct);}catch(Exception e){}

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_selectresource",user.GetLocale(), nps.core.Config.RES_CLASSLOADER);
%>

<html>
<head>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <link href="/css/style.css" rel = stylesheet>
    <title>Resources</title>
    <script type="text/javascript">
         function f_new()
         {
             document.frm_res.action="/resource/resource.jsp";
             document.frm_res.target="_blank";
             document.frm_res.submit();
         }

         function f_search()
         {
             document.frm_res.action="selectresource.jsp";
             document.frm_res.target="_self";
             document.frm_res.act.value="0";
             document.frm_res.submit();
         }

         function f_select()
         {
             var count = 0;
             var rownos = document.getElementsByName("rowno");
             for (var i = 0; i < rownos.length; i++)
             {
                if(rownos[i].checked) count++;
             }

             if(count==0)
             {
                 alert("<%=bundle.getString("ALERT_NO_RESOURCE_SELECTED")%>");
                 return false;
             }

       <%
         if(!bMultiple)
         {
       %>
             if(count>1)
             {
                alert("<%=bundle.getString("ALERT_MULTI_RESOURCE_SELECTED")%>");
                return false;
             }
       <%
         }
       %>

             document.frm_res.action="selectresource.jsp";
             document.frm_res.target="_self";
             document.frm_res.act.value="1";
             document.frm_res.submit();
         }

         function SelectResource()
         {
            var rownos = document.getElementsByName("rowno");
   		    for (var i = 0; i < rownos.length; i++)
		    {
			   rownos[i].checked = document.frm_res.AllId.checked;
			}
         }
    </script>
</head>
<body>
<form name = "frm_res" action="selectresource.jsp" method = "post">
  <table width = "100% " border = "0" cellpadding = "0" cellspacing = "0" class="PositionBar">
      <input type="hidden" name="siteid" value="<%=siteid%>">
      <input type="hidden" name="func" value="<%=Utils.Null2Empty(func)%>">
      <input type="hidden" name="act" value="0">
      <input type="hidden" name="multiple" value="<%=bMultiple?1:0%>">
    <tr height="30">
      <td colspan="2" valign="middle">&nbsp;
          <input name="newBtn" type="button" onClick="f_new()" value="<%=bundle.getString("RESLIST_UPLOADBUTTON")%>" class="button">
          <input name="selectBtn" type="button" onClick="f_select()" value="<%=bundle.getString("RESLIST_SELECTBUTTON")%>" class="button">
      </td>
    </tr>
    <tr height="30" class="TitleBar">
      <td>&nbsp;
          <%=bundle.getString("RESLIST_KEYWORD")%>
          <input type="text" name="keyword" value="<%=Utils.Null2Empty(keyword)%>" style="width:250px">
          <input name="searchBtn" type="button" onClick="f_search()" value="<%=bundle.getString("RESLIST_SEARCHBUTTON")%>" class="button">
      </td>
      <td>
          <%=bundle.getString("RESLIST_TYPE")%>
          <input type="radio" name="type" value="-1" <% if(type==-1) out.print("checked");%>><%=bundle.getString("RESLIST_TYPE_ALL")%>
          <input type="radio" name="type" value="0" <% if(type==0) out.print("checked");%>><%=bundle.getString("RESLIST_TYPE_IMAGE")%>
          <input type="radio" name="type" value="1" <% if(type==1) out.print("checked");%>><%=bundle.getString("RESLIST_TYPE_DOCUMENT")%>
          <input type="radio" name="type" value="2" <% if(type==2) out.print("checked");%>><%=bundle.getString("RESLIST_TYPE_VIDEO")%>
          <input type="radio" name="type" value="3" <% if(type==3) out.print("checked");%>><%=bundle.getString("RESLIST_TYPE_AUDIO")%>
          <input type="radio" name="type" value="4" <% if(type==4) out.print("checked");%>><%=bundle.getString("RESLIST_TYPE_FLASH")%>
          <input type="radio" name="type" value="5" <% if(type==5) out.print("checked");%>><%=bundle.getString("RESLIST_TYPE_OTHER")%>
      </td>
    </tr>
    <tr height="30"  class="TitleBar">
       <td colspan="2">&nbsp;
          <%=bundle.getString("RESLIST_DATETYPE")%>
          <input type="radio" name="datetype" value="-1" <% if(date_type==-1) out.print("checked");%>><%=bundle.getString("RESLIST_DATETYPE_ALL")%>
          <input type="radio" name="datetype" value="0" <% if(date_type==0) out.print("checked");%>><%=bundle.getString("RESLIST_DATETYPE_TODAY")%>
          <input type="radio" name="datetype" value="1" <% if(date_type==1) out.print("checked");%>><%=bundle.getString("RESLIST_DATETYPE_YESTERDAY")%>
          <input type="radio" name="datetype" value="2" <% if(date_type==2) out.print("checked");%>><%=bundle.getString("RESLIST_DATETYPE_7DAYS")%>
          <input type="radio" name="datetype" value="3" <% if(date_type==3) out.print("checked");%>><%=bundle.getString("RESLIST_DATETYPE_30DAYS")%>
       </td>
    </tr>
  </table>

<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String sql = null;
    String where_clause = "";

    try
    {
        conn = Database.GetDatabase("nps").GetConnection();

        switch(act)
        {
            case 1: //选定并返回
                 //为了预览，我们复制文件到当前站点并FTP上传
                 NpsContext ctxt = new NpsContext(conn,user);
                 Site site = ctxt.GetSite(siteid);
                 if(site==null) break;

                 String[] rownos = request.getParameterValues("rowno");
                 if(rownos!=null && rownos.length>0)
                 {
                     out.println("<script language=\"javascript\">");
                     for(int i=0;i<rownos.length;i++)
                     {
                         String rsid = request.getParameter("rsid_"+rownos[i]);
                         String caption = request.getParameter("name_"+rownos[i]);
                         String suffix = request.getParameter("s_"+rownos[i]);
                         String url = request.getParameter("url_"+rownos[i]);

                         //为了预览，我们复制文件到当前站点并FTP上传
                         Resource res = new Resource(ctxt,rsid);
                         res.CopyTo(site);

                         //通过Javascript返回选定结果
                         if(!bMultiple)
                         {
                             if(func==null)
                             {
                                out.println("if(window.opener) window.opener.SetUrl(\""+ url + "\",\"\",\"\",\""+caption+"\");");
                             }
                             else
                             {
                                 out.println("if(window.opener) window.opener."+func+"(\""+rsid+"\",\""+caption+suffix+"\",\""+url+"\");");
                             }
                             break;
                         }
                         else
                         {
                             if(func==null)
                             {
                                out.println("if(window.opener) window.opener.AddResource(\""+rsid+"\",\""+caption+suffix+"\",\""+url+"\");");
                             }
                             else
                             {
                                 out.println("if(window.opener) window.opener."+func+"(\""+rsid+"\",\""+caption+suffix+"\",\""+url+"\");");
                             }
                         }
                     }

                     out.println("if(window.opener)");
                     out.println("{");
                     out.println("window.opener.focus();");
                     out.println("window.opener=null;");
                     out.println("window.open('','_self','');");
                     out.println("window.close();");
                     out.println("}");
                     out.println("</script>");
                 }
                 return;
        }

        sql = "select count(*) from resources a,site b,users c,dept d where a.siteid=b.id and a.creator=c.id and c.dept=d.id";
        if(!user.IsSysAdmin()) where_clause += " and (a.scope=0 or (a.scope=2 and a.siteid=?) or (a.scope=1 and d.unit=?))";
        if(keyword!=null && keyword.length()>0) where_clause += " and (caption like ? or exists(select * from tag c where c.id=a.id and c.tagname like ?))";
        if(type!=-1) where_clause += " and type=?";
        if(date_type!=-1) where_clause += " and (a.createdate>=? and a.createdate<?)";

        pstmt = conn.prepareStatement(sql+where_clause);
        int i=1;
        if(!user.IsSysAdmin())
        {
            pstmt.setString(i++,siteid);
            pstmt.setString(i++,user.GetUnitId());
        }

        if(keyword!=null && keyword.length()>0)
        {
            pstmt.setString(i++,"%"+keyword+"%");
            pstmt.setString(i++,"%"+keyword+"%");
        }

        if(type!=-1)
        {
            pstmt.setInt(i++,type);
        }

        //0今天 1昨天 2最近7天 3最近30天
        Date today = new Date();
        Calendar calendar_begin = Calendar.getInstance();
        calendar_begin.setTime(today);
        Calendar calendar_end = Calendar.getInstance();
        calendar_end.setTime(today);
        switch(date_type)
        {
            case 0:
                calendar_end.add(Calendar.DATE,1);
                pstmt.setDate(i++,new java.sql.Date(calendar_begin.getTimeInMillis()));
                pstmt.setDate(i++,new java.sql.Date(calendar_end.getTimeInMillis()));
                break;
            case 1:
                calendar_begin.add(Calendar.DATE,-1);
                pstmt.setDate(i++,new java.sql.Date(calendar_begin.getTimeInMillis()));
                pstmt.setDate(i++,new java.sql.Date(calendar_end.getTimeInMillis()));
                break;
            case 2:
                calendar_begin.add(Calendar.DATE,-7);
                calendar_end.add(Calendar.DATE,1);
                pstmt.setDate(i++,new java.sql.Date(calendar_begin.getTimeInMillis()));
                pstmt.setDate(i++,new java.sql.Date(calendar_end.getTimeInMillis()));
                break;
            case 3:
                calendar_begin.add(Calendar.DATE,-30);
                calendar_end.add(Calendar.DATE,1);
                pstmt.setDate(i++,new java.sql.Date(calendar_begin.getTimeInMillis()));
                pstmt.setDate(i++,new java.sql.Date(calendar_end.getTimeInMillis()));
                break;
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

            sql = "select a.*,b.rooturl,b.img_rooturl,c.name creator_cn from resources a,site b,users c,dept d where a.siteid=b.id and a.creator=c.id and c.dept=d.id";
            pstmt = conn.prepareStatement(sql+where_clause+" order by a.createdate desc");

            i=1;
            if(!user.IsSysAdmin())
            {
                pstmt.setString(i++,siteid);
                pstmt.setString(i++,user.GetUnitId());
            }

            if(keyword!=null && keyword.length()>0)
            {
                pstmt.setString(i++,"%"+keyword+"%");
                pstmt.setString(i++,"%"+keyword+"%");
            }

            if(type!=-1)
            {
                pstmt.setInt(i++,type);
            }

            if(date_type!=-1)
            {
                pstmt.setDate(i++,new java.sql.Date(calendar_begin.getTimeInMillis()));
                pstmt.setDate(i++,new java.sql.Date(calendar_end.getTimeInMillis()));
            }

            rs = pstmt.executeQuery();
%>

  <table width = "100% " border = "0" cellpadding = "0" cellspacing = "1">
   <%
       if(type==Resource.IMAGE)
       {
           int image_counter = 0;
           while (rs.next() && (rs.getRow() <= endnum))
           {
               if (rs.getRow() < startnum) continue;
               if(image_counter%IMAGES_PER_ROW==0) out.println("<tr class='DetailBar'>");
   %>
                   <td width="<%=100/IMAGES_PER_ROW%>%" align=center>
                       <%
                           String img_url = rs.getString("url");
                           String img_preview_url = null;
                           if(img_url==null)
                           {
                               String site_image_rooturl = rs.getString("img_rooturl");
                               if(site_image_rooturl.startsWith("/"))
                               {
                                  site_image_rooturl = rs.getString("rooturl") + site_image_rooturl;
                                  site_image_rooturl = Utils.FixURL(site_image_rooturl);
                               }
                               
                               img_url = site_image_rooturl
                                          + Utils.FormateDate(rs.getDate("createdate"),"yyyy/MM/dd/")
                                          + rs.getString("id") + Utils.Null2Empty(rs.getString("suffix"));

                               img_preview_url = "/userdir/preview/"
                                          + Utils.FormateDate(rs.getDate("createdate"),"yyyy/MM/dd/")
                                          + rs.getString("id") + ".jpg";
                           }
                           else
                           {
                               img_preview_url = img_url;
                           }

                       %>
                       <table border="0" width="100%" cellpadding="0" cellspacing="0">
                           <input type="hidden" name="rsid_<%=rs.getRow()%>" value="<%=rs.getString("id")%>">
                           <input type="hidden" name="url_<%=rs.getRow()%>" value="<%=img_url%>">
                           <input type="hidden" name="name_<%=rs.getRow()%>" value="<%=rs.getString("caption")%>">
                           <input type="hidden" name="s_<%=rs.getRow()%>" value="<%=rs.getString("suffix")%>">

                           <tr height="10"><td></td></tr>
                           <tr valign="middle">
                               <td align="center">
                                   <a href="<%=img_url%>" target="_blank">
                                       <img src="<%=img_preview_url%>" alt="<%=rs.getString("caption")%>" border=0>
                                   </a>
                               </td>
                           </tr>
                           <tr height="30" valign="middle">
                               <td align="center">
                                   <input type = "checkBox" id="rowno" name="rowno" value = "<%= rs.getRow() %>">
                                   <%=rs.getString("caption")%>
                               </td>
                           </tr>
                       </table>
                    </td>

   <%
               image_counter++;
               if(image_counter%IMAGES_PER_ROW==0) out.println("</tr>");
           }
           if(image_counter%IMAGES_PER_ROW>0)
           {
               out.println("<td colspan="+(IMAGES_PER_ROW-image_counter%IMAGES_PER_ROW)+"></td>");
               out.println("</tr>");
           }
       }
       else
       {
   %>
              <tr height=30 class="TitleBar">
                  <td width="25">
                    <input type = "checkBox" name = "AllId" value = "0" onclick = "SelectResource()">
                  </td>
                  <td><%=bundle.getString("RESLIST_NAME")%></td>
                  <td width="80"><%=bundle.getString("RESLIST_SUFFIX")%></td>
                  <td width="120"><%=bundle.getString("RESLIST_SITE")%></td>
                  <td width="120"><%=bundle.getString("RESLIST_CREATEDATE")%></td>
                  <td width="120"><%=bundle.getString("RESLIST_CREATOR")%></td>
              </tr>
          <%
              while (rs.next() && (rs.getRow() <= endnum))
              {
                   if (rs.getRow() < startnum) continue;

                   String img_url = rs.getString("url");
                   if(img_url==null)
                   {
                       String site_image_rooturl = rs.getString("img_rooturl");
                       if(site_image_rooturl.startsWith("/"))
                       {
                          site_image_rooturl = rs.getString("rooturl") + site_image_rooturl;
                          site_image_rooturl = Utils.FixURL(site_image_rooturl);
                       }

                       img_url = site_image_rooturl
                                  + Utils.FormateDate(rs.getDate("createdate"),"yyyy/MM/dd/")
                                  + rs.getString("id") + Utils.Null2Empty(rs.getString("suffix"));
                   }
          %>
                  <tr height=25 class="DetailBar">
                    <td>
                      <input type = "checkBox" id="rowno" name="rowno" value = "<%= rs.getRow() %>">
                      <input type="hidden" name="rsid_<%=rs.getRow()%>" value="<%=rs.getString("id")%>">
                      <input type="hidden" name="url_<%=rs.getRow()%>" value="<%=img_url%>">
                      <input type="hidden" name="name_<%=rs.getRow()%>" value="<%=rs.getString("caption")%>">
                      <input type="hidden" name="s_<%=rs.getRow()%>" value="<%=rs.getString("suffix")%>">
                    </td>
                    <td>
                       <a href="<%=img_url%>" target="_blank"><%=rs.getString("caption")%></a>
                    </td>
                    <td>
                       <%=Utils.Null2Empty(rs.getString("suffix"))%>
                    </td>
                    <td>
                       <%=rs.getString("siteid")%>
                    </td>
                    <td>
                       <%=Utils.FormateDate(rs.getDate("createdate"),"yyyy-MM-dd")%>
                    </td>
                    <td>
                       <%=rs.getString("creator_cn")%>
                    </td>
                  </tr>
  <%
             }
      }
  %>
  </table>
<%
   }
}
catch(Exception e)
{
    e.printStackTrace();
}
finally
{
    if(rs!=null) try{rs.close();}catch(Exception e){}
    if(pstmt!=null) try{pstmt.close();}catch(Exception e){}
    if(conn!=null) try{conn.close();}catch(Exception e){}
}
%>
</form>

<%@ include file="/include/scrollpage.jsp" %>
</body>
</html>