<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.io.Writer,java.io.IOException" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.util.Utils" %>
<%@ include file = "/include/header.jsp" %>
<%!
  private void FixHtml(Writer out,String data)  throws IOException
  {
        if(data==null || data.length()==0) return;

        boolean bJava = false;
        int max_guess_step = 10;
        char[] LA=new char[max_guess_step];
        int total_length = data.length();
        for (int i=0;i<total_length;i++)
        {

            if(data.charAt(i)=='&' || data.charAt(i)=='<' || data.charAt(i)=='%')
            {
                //防止字符串数组越界
                int j;
                for(j=0;i+j+1<total_length && j<max_guess_step;j++)
                {
                    LA[j] = data.charAt(i+j+1);
                }
                for(;j<max_guess_step;j++)
                {
                    LA[j] = '\0';
                }

                //JAVA语法内的不进行转换
                if(data.charAt(i)=='<' && LA[0]=='%')
                {
                    bJava = true;
                }
                
                if(bJava && data.charAt(i)=='%' && LA[0]=='>')
                {
                    bJava = false;
                }
                
                if(!bJava && data.charAt(i)=='&')
                {
                    if(
                         //&amp;
                         ((LA[0]=='a' || LA[0]=='A') && (LA[1]=='m' || LA[1]=='M') && (LA[2]=='p' || LA[2]=='P'))
                      || //&nbsp;
                         ((LA[0]=='n' || LA[0]=='N') && (LA[1]=='b' || LA[1]=='B') && (LA[2]=='s' || LA[2]=='S') && (LA[3]=='p' || LA[3]=='P'))
                      || //&lt;
                         ((LA[0]=='l' || LA[0]=='L') && (LA[1]=='t' || LA[1]=='T'))
                      || //&gt;
                         ((LA[0]=='g' || LA[0]=='G') && (LA[1]=='t' || LA[1]=='T'))
                      || //&quot;
                         ((LA[0]=='q' || LA[0]=='Q') && (LA[1]=='u' || LA[1]=='U') && (LA[2]=='o' || LA[2]=='O') && (LA[3]=='t' || LA[3]=='T'))
                      || //&reg;
                         ((LA[0]=='r' || LA[0]=='R') && (LA[1]=='e' || LA[1]=='E') && (LA[2]=='g' || LA[2]=='G'))
                      || //&copy;
                         ((LA[0]=='c' || LA[0]=='C') && (LA[1]=='o' || LA[1]=='O') && (LA[2]=='p' || LA[2]=='P') && (LA[3]=='y' || LA[3]=='Y'))
                      || //&trade;
                         ((LA[0]=='t' || LA[0]=='T') && (LA[1]=='r' || LA[1]=='R') && (LA[2]=='a' || LA[2]=='A') && (LA[3]=='d' || LA[3]=='D') && (LA[4]=='e' || LA[4]=='E'))
                      || //&ensp;
                         ((LA[0]=='e' || LA[0]=='E') && (LA[1]=='n' || LA[1]=='N') && (LA[2]=='s' || LA[2]=='S') && (LA[3]=='p' || LA[3]=='P'))
                      || //&emsp;
                         ((LA[0]=='e' || LA[0]=='E') && (LA[1]=='m' || LA[1]=='M') && (LA[2]=='s' || LA[2]=='S') && (LA[3]=='p' || LA[3]=='P'))
                       )
                    {
                        out.write("&amp;");
                        continue;
                    }
                }
                else if(data.charAt(i)=='<')
                {
                    if(  //<textarea 或<textarea>
                         ((LA[0]=='t' || LA[0]=='T') && (LA[1]=='e' || LA[1]=='E') && (LA[2]=='x' || LA[2]=='X') && (LA[3]=='t' || LA[3]=='T') && (LA[4]=='a' || LA[4]=='A') && (LA[5]=='r' || LA[5]=='R') && (LA[6]=='e' || LA[6]=='E') && (LA[7]=='a' || LA[7]=='A') && (LA[8]==' ' || LA[8]=='>'))
                      || //</textarea>
                         ((LA[0]=='/') && (LA[1]=='t' || LA[1]=='T') && (LA[2]=='e' || LA[2]=='E') && (LA[3]=='x' || LA[3]=='X') && (LA[4]=='t' || LA[4]=='T') && (LA[5]=='a' || LA[5]=='A') && (LA[6]=='r' || LA[6]=='R') && (LA[7]=='e' || LA[7]=='E') && (LA[8]=='a' || LA[8]=='A') && (LA[9]=='>'))
                      )
                    {
                        out.write("&lt;");
                        continue;
                    }
                }
            }

            out.write(data.charAt(i));
    	}
  }
%>
<%
    request.setCharacterEncoding("UTF-8");
    int template_type = 0;
    String template_id = request.getParameter("id");
    if(template_id!=null) template_id = template_id.trim();
    boolean bNew=(template_id==null || template_id.length()==0);

    String creator = user.GetName()+"("+user.GetDeptName()+ "/" +user.GetUnitName()+")";
    String create_date = nps.util.Utils.FormateDate(new java.util.Date(),"yyyy-MM-dd HH:mm:ss");

    if(!(user.IsSysAdmin() || user.IsLocalAdmin()))
       throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);
    
    NpsWrapper wrapper = null;
    TemplateBase template = null;
    java.util.List  topic_profiles = null;
    try
    {
        if(!bNew)
        {
            wrapper = new NpsWrapper(user);
            template = wrapper.GetTemplate(template_id);
            if(template==null) throw new NpsException(ErrorHelper.SYS_NOTEMPLATE);
            creator = template.GetCreator();
            create_date = Utils.FormateDate(template.GetCreatedate(),"yyyy-MM-dd");

            topic_profiles = template.GetTopics(wrapper.GetContext());

            if(template instanceof PageTemplate)   template_type = 2;
        }

        ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_templateinfo",user.GetLocale(), Config.RES_CLASSLOADER);
%>

<html>
  <head>
    <title><%=bNew?bundle.getString("TEMPLATE_HTMLTILE"):template.GetName()%></title>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <script type="text/javascript" src="/dhtmlxtabbar/dhtmlxcommon.js"></script>
    <script type="text/javascript" src="/dhtmlxtabbar/dhtmlxtabbar.js"></script>
    <script type="text/javascript" src="/dhtmlxtabbar/dhtmlxtabbar_start.js"></script>

    <link rel="STYLESHEET" type="text/css" href="/dhtmlxtabbar/dhtmlxtabbar.css">
    <LINK href="/css/style.css" rel = stylesheet>

    <script  language="javascript">
        window.onerror=function(){return true};
    </script>

    <script language="javascript">
        function f_save()
        {
          var frm = document.templateFrm;
          if( frm.template_name.value.trim() == "")
          {
            alert( "<%=bundle.getString("TEMPLATE_ALERT_NAME_IS_NULL")%>");
            frm.template_name.focus();
            return false;
          }
          if( frm.template_data_0.value.trim()== "" && frm.template_data_1.value== "" && frm.template_data_2.value== "")
          {
            alert( "<%=bundle.getString("TEMPLATE_ALERT_CONTENT_IS_NULL")%>");
            return false;
          }
          if( frm.template_type.value == 2)
          {
            var outfilename = frm.template_outfilename.value.trim();
            if( outfilename == "")
            {
              alert( "<%=bundle.getString("TEMPLATE_ALERT_OUTPUT_FILENAME_IS_NULL")%>");
              frm.template_outfilename.focus();
              return false;
            }
          }
          frm.act.value='0';
          frm.action ="templatesave.jsp";
          frm.target="_self";
          frm.submit();
        }

        function f_compile()
        {
            var r = confirm("<%=bundle.getString("TEMPLATE_ALERT_RECOMPILE")%>");
            if( r !=1 ) return false;

            var frm = document.templateFrm;
            frm.act.value='2';
            frm.action ="templatesave.jsp";
            frm.target="_self";
            frm.submit();
        }

        function f_delete()
        {
            var r = confirm("<%=bundle.getString("TEMPLATE_ALERT_DELETE")%>");
            if( r !=1 ) return false;

            var frm = document.templateFrm;
            frm.act.value='1';
            frm.action ="templatesave.jsp";
            frm.target="_self";
            frm.submit();
        }

        function f_viewsource()
        {
            document.templateFrm.action = "templatejavasource.jsp";
            document.templateFrm.target="_blank";
            document.templateFrm.submit();
        }

        function f_build()
        {
            var r = confirm("<%=bundle.getString("TEMPLATE_ALERT_BUILD")%>");
            if( r !=1 ) return false;

            var frm = document.templateFrm;
            frm.act.value='3';
            frm.action ="templatesave.jsp";
            frm.target="_self";
            frm.submit();
        }

        function typeChanged(newType)
        {
          var fileNameObj = document.getElementById("template_outfilename");
          var div_page_t = document.getElementById("div_page_t");
          var div_article_t = document.getElementById("div_article_t");
          var div_page_c = document.getElementById("div_page_c");
          var div_article_c = document.getElementById("div_article_c");
          if( newType == '0')
          {
            div_page_t.style.display = "none";
            div_article_t.style.display = "block";
            div_page_c.style.display = "none";
            div_article_c.style.display = "block";
          }
          else if( newType == '2')
          {
            div_page_t.style.display = "block";
            div_article_t.style.display = "none";
            div_page_c.style.display = "block";
            div_article_c.style.display = "none";  
          }
        }

        function showhelp()
        {
            window.open('/help/<%=user.GetLocale().getLanguage()%>/template.html');
        }
       
        function f_checktopic()
        {
            var topnos = document.getElementsByName("topno");
            for(var i = 0; i < topnos.length; i++)
            {
                topnos[i].checked = document.templateFrm.topcheck.checked;
            }
        }

        function f_settabbar()
        {
            var tabbar = window["templates"];
            var active_tab = tabbar.getActiveTab();
            var caption_value = document.templateFrm.tabbar_caption.value;
            if("template0"==active_tab)
            {
                document.templateFrm.name0.value = caption_value;
                document.templateFrm.template_current.options[0].text = caption_value;
            }
            else if("template1"==active_tab)
            {
                document.templateFrm.name1.value = caption_value;
                document.templateFrm.template_current.options[1].text = caption_value;
            }
            else if("template2"==active_tab)
            {
                document.templateFrm.name2.value = caption_value;
                document.templateFrm.template_current.options[2].text = caption_value;
            }
            
            tabbar.setLabel(active_tab,caption_value);
        }
     </script>
  </head>

  <body leftmargin="20">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr height=30>
        <td>&nbsp;
      <%
           String template_name0 = "template0";
           String template_name1 = "template1";
           String template_name2 = "template2";

           if(!bNew)
           {
               template_name0 = template.GetTemplateName(0);
               if(template_name0==null) template_name0 = "template0";

               template_name1 = template.GetTemplateName(1);
               if(template_name1==null) template_name1 = "template1";

               template_name2 = template.GetTemplateName(2);
               if(template_name2==null) template_name2 = "template2";
           }

           boolean bSavable = false;
           boolean bDeletable = false;
           boolean bCompilable = false;
           boolean bViewSource = false;
           boolean bBuildable = false;
           if(bNew)
           {
               if(user.IsLocalAdmin() || user.IsSysAdmin())  bSavable = true;
               bDeletable = false;
               bCompilable = false;
               bViewSource = false;
               bBuildable = false;
           }
           else
           {
               //仅在以下情况下可以修改
               //1.系统管理员
               //2.作者
               //3.使用范围为指定站点且当前用户是站点管理员
               if(  user.IsSysAdmin()
                  || user.GetId().equals(template.GetCreatorID())
                  || (template.GetScope()==2 && user.IsLocalAdmin() && user.IsSiteAdmin(template.GetSiteId()))
                 )
               {
                   bSavable = true;
                   bDeletable = true;
                   bCompilable = true;
                   bViewSource = true;
                   bBuildable = true;
               }
           }

           if(bSavable)
           {
      %>
           <input type="button" name="okbtn" value="<%=bundle.getString("TEMPLATE_BUTTON_SAVE")%>" class="button" onclick="f_save()">
<%
           }
           if(bCompilable)
           {
%>
           <input type="button" name="compilebtn" value="<%=bundle.getString("TEMPLATE_BUTTON_COMPILE")%>" class="button" onclick="f_compile()">
<%
            }
            if(bDeletable)
            {
%>
           <input type="button" name="deletebtn" value="<%=bundle.getString("TEMPLATE_BUTTON_DELETE")%>" class="button" onclick="f_delete()">
<%
            }
            if(bViewSource)
            {
%>
           <input type="button" name="viewsource" value="<%=bundle.getString("TEMPLATE_BUTTON_JAVA")%>" class="button" onclick="f_viewsource()">
 <%
            }
           if(bBuildable)
           {
 %>
          <input type="button" name="buildbtn" value="<%=bundle.getString("TEMPLATE_BUTTON_BUILD")%>" class="button" onclick="f_build()">            
<%
           }
%>
           <input type="button" name="helpbtn"  value="<%=bundle.getString("TEMPLATE_BUTTON_HELP")%>" class="button" onclick="javascript:showhelp();">
           <input type="button" name="closebtn" value="<%=bundle.getString("TEMPLATE_BUTTON_CLOSE")%>" class="button" onclick="javascript:window.close();">
        </td>
      </tr>
    </table>
  <fieldset>
  <form name="templateFrm" method="post" action ="templatesave.jsp">
   <table width="100%" cellpadding = "0" cellspacing = "0" border="1">
     <input type="hidden" name="template_id" value="<%= template_id==null?"":template_id %>">
     <input type="hidden" name="name0" value="<%=template_name0%>">
     <input type="hidden" name="name1" value="<%=template_name1%>">
     <input type="hidden" name="name2" value="<%=template_name2%>">
     <input type="hidden" name="act" value="0">
     <tr height="30">
       <td width=120 align=center><%=bundle.getString("TEMPLATE_NAME")%></td>
       <td>
         <input type=text name="template_name" value="<%= template==null?"":template.GetName() %>" size=30>
       </td>
       <td width=80 align=center><%=bundle.getString("TEMPLATE_SCOPE")%></td>
       <td>
           <input type="radio" name="template_scope" value="0" <%= (template!=null && template.GetScope()==0)?"checked":""%>><%=bundle.getString("TEMPLATE_SCOPE_FULL")%>
           <input type="radio" name="template_scope" value="1" <%= (template!=null && template.GetScope()==1)?"checked":""%> <%= bNew?"checked":""%>><%=bundle.getString("TEMPLATE_SCOPE_ALL_MYSITE")%>
           <input type="radio" name="template_scope" value="2" <%= (template!=null && template.GetScope()==2)?"checked":""%>><%=bundle.getString("TEMPLATE_SCOPE_SPECIAL_SITE")%>
           <select name="site_id">
           <%
               java.util.Hashtable site_list = user.GetUnitSites();
               if(site_list!=null && !site_list.isEmpty())
               {
                   java.util.Enumeration  site_ids = site_list.keys();
                   while(site_ids.hasMoreElements())
                   {
                       String obj_id = (String)site_ids.nextElement();
                       out.print("<option value='"+obj_id+"'");
                       if(template!=null && obj_id.equalsIgnoreCase(template.GetSiteId()))   out.print(" selected ");
                       out.print(">"+site_list.get(obj_id));
                       out.println("</option>");
                   }
               }
           %>
           </select>
       </td>
     </tr>
     <tr height="30">
       <td align=center><%=bundle.getString("TEMPLATE_TYPE")%></td>
       <td width=120>
<%
    if(bNew)
    {
%>
          <select name="template_type" onchange="typeChanged(this.value)" >
            <option value="0"><%=bundle.getString("TEMPLATE_TYPE_ARTICLE")%></option>
            <option value="2"><%=bundle.getString("TEMPLATE_TYPE_PAGE")%></option>
          </select>
<%
    }
    else
    {
        out.println("<input type=hidden name=template_type value="+template_type+">");
        switch(template_type)
        {
            case 0: //文章模版
                out.print(bundle.getString("TEMPLATE_TYPE_ARTICLE"));
                break;
            case 2: //页面模版
                out.print(bundle.getString("TEMPLATE_TYPE_PAGE"));
                break;
        }
    }
%>
       </td>
       <td align=center>
           <div id="div_article_t" style="display:<%=template_type==0?"block":"none"%>">
               <%=bundle.getString("TEMPLATE_SUFFIX")%>
           </div>
           <div id="div_page_t" style="display:<%=template_type==2?"block":"none"%>">
               <%=bundle.getString("TEMPLATE_OUTPUT_FILENAME")%>
           </div>
       </td>
       <td>
           <div id="div_article_c" style="display:<%=template_type==0?"block":"none"%>">
             <input type=text name="template_suffix" value="<% if(template_type==0 && template!=null) out.print(Utils.Null2Empty(((ArticleTemplate)template).GetSuffix())); %>" size=30 style="width:150px">
             <%=bundle.getString("TEMPLATE_SUFFIX_HINT")%>
           </div>
           <div id="div_page_c" style="display:<%=template_type==2?"block":"none"%>">
               <input type=text name="template_outfilename" value="<% if(template_type==2) out.print(Utils.TransferToHtmlEntity(((PageTemplate)template).GetOutputFileName())); %>"  size=30 style="width:350px">
               <%=bundle.getString("TEMPLATE_OUTPUT_FILENAME_HINT")%>
           </div>
       </td>
     </tr>
     <tr height="30">
        <td align=center>
            <%=bundle.getString("TEMPLATE_CURRENTTEMPLATE")%>
        </td>
        <td>
            <select name="template_current">
                <option value="0" <%if(template!=null && template.GetCurrentTemplateNo()==0) out.print("selected");%>><%=template_name0%></option>
                <option value="1" <%if(template!=null && template.GetCurrentTemplateNo()==1) out.print("selected");%>><%=template_name1%></option>
                <option value="2" <%if(template!=null && template.GetCurrentTemplateNo()==2) out.print("selected");%>><%=template_name2%></option>
            </select>
        </td>

        <td align=center><%=bundle.getString("TEMPLATE_CREATOR")%></td>
        <td>&nbsp;&nbsp;<%= Utils.Null2Empty(creator) %>&nbsp;&nbsp;&nbsp;&nbsp;<%= Utils.Null2Empty(create_date) %></td>
     </tr>
     <tr height="30">
         <td align="center"><%=bundle.getString("TEMPLATE_TABBARNAME")%></td>
         <td colspan="3">
             <input type="text" name="tabbar_caption" size=50 value="">
         <%
            if(bSavable)
            {
         %>
             <input type="button" class="button" name="btn_set" value="<%=bundle.getString("TEMPLATE_TABBARNAME_SET")%>" onclick="f_settabbar()">
         <%
             }
         %>
             &nbsp;<%=bundle.getString("TEMPLATE_HINT_TABBARNAME_SET")%>
         </td>
     </tr>
 </table>
  <table width="100%" cellpadding = "0" cellspacing = "0" border="0">
     <tr>
       <td>
           <div id="templates" class="dhtmlxTabBar" imgpath="/dhtmlxtabbar/imgs/" style="width:98%; height:480;overflow:hidden;" mode="top" align="left" offset="20" margin="-10" tabheight="25" skinColors="#FFFACD,#F4F3EE" <% if(template!=null) out.print("select=\"template"+ template.GetCurrentTemplateNo()+"\"");%>>
               <div id="template0" name="<%=template_name0%>">
                <textarea name="template_data_0" style="width: 1000;height:430;"><% if(template!=null) {java.io.StringWriter temp = new java.io.StringWriter(); template.GetTemplate(wrapper.GetContext(),0,temp); FixHtml(out,temp.toString());} %></textarea>
               </div>
               <div id="template1" name="<%=template_name1%>">
                <textarea name="template_data_1" style="width:1000;height:430;"><% if(template!=null) {java.io.StringWriter temp = new java.io.StringWriter(); template.GetTemplate(wrapper.GetContext(),1,temp); FixHtml(out,temp.toString());} %></textarea>
               </div>
               <div id="template2" name="<%=template_name2%>">
                <textarea name="template_data_2" style="width:1000;height:430;"><% if(template!=null) {java.io.StringWriter temp = new java.io.StringWriter(); template.GetTemplate(wrapper.GetContext(),2,temp); FixHtml(out,temp.toString());} %></textarea>
               </div>
           </div>
       </td>
     </tr>
  </table>
<%
     if(topic_profiles!=null && !topic_profiles.isEmpty())
     {
%>
    <table width="100%" border="0" cellpadding="0" cellspacing="1" class="titlebar">
        <tr height="25" ><td colspan="5"><input type="checkbox" name="topcheck" onclick="f_checktopic()"><%=bundle.getString("TEMPLATE_HINT_REFERENCE")%></td></tr>
<%
           int topic_index = 0;
           for(Object obj:topic_profiles)
           {
               TemplateBase.TopicProfile profile = (TemplateBase.TopicProfile)obj;
               if(topic_index%5==0)
               {
                   out.println("<tr class=detailbar height=25>");
               }

               out.println("<td width=20% align=left><input type=\"checkbox\" name=\"topno\" value="+profile.GetId()+">");
               out.println("<a href='topicinfo.jsp?siteid="+profile.GetSiteId()+"&topid="+profile.GetId()+"' target='_blank'>");
               //out.println(profile.GetName() + "(" + profile.GetSiteName() +"/" + profile.GetUnitName() +")");
               out.println(profile.GetName() + "(" + profile.GetSiteName() +")");
               out.println("</a>");
               out.println("</td>");

               topic_index++;
               if(topic_index%5==0 && topic_index>0)
               {
                   out.println("</tr>");
               }
           }
           if(topic_index%5!=0)
           {
               out.println("<td colspan="+(5-(topic_index%5))+">&nbsp;</td>");
               out.println("</tr>");
           }
%>
   </table>
<%
    }
%>
   </form>
  </fieldset>
</body>
</html>
<%
    }
    finally
    {
        if(template!=null) template.Clear();
        if(wrapper!=null) wrapper.Clear();
    }
%>