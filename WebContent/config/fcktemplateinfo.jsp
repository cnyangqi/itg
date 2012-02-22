<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.Config" %>
<%@ page import="nps.core.NpsWrapper" %>
<%@ page import="nps.core.FCKTemplate" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String template_id = request.getParameter("id");
    if(template_id!=null) template_id = template_id.trim();
    boolean bNew=(template_id==null || template_id.length()==0);

    String creator = user.GetName()+"("+user.GetDeptName()+ "/" +user.GetUnitName()+")";
    String create_date = nps.util.Utils.FormateDate(new java.util.Date(),"yyyy-MM-dd HH:mm:ss");

    NpsWrapper wrapper = null;
    FCKTemplate template = null;
    try
    {
        if(!bNew)
        {
            wrapper = new NpsWrapper(user);
            template = FCKTemplate.GetTemplate(wrapper.GetContext(),template_id);
            if(template==null) throw new NpsException(ErrorHelper.SYS_NOFCKTEMPLATE);
            
            creator = template.GetCreatorCN();
            create_date = nps.util.Utils.FormateDate(template.GetCreateDate(),"yyyy-MM-dd");
        }

        ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_fcktemplateinfo",user.GetLocale(), Config.RES_CLASSLOADER);
%>

<html>
  <head>
    <title><%=bNew?bundle.getString("FCKTEMPLATE_HTMLTILE"):template.GetTitle()%></title>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>

    <script language="javascript">
        function f_save()
        {
          var frm = document.templateFrm;
          if( frm.template_title.value.trim() == "")
          {
            alert("<%=bundle.getString("FCKTEMPLATE_ALERT_TITLE_IS_NULL")%>");
            frm.template_name.focus();
            return false;
          }
          if( frm.template_data.value.trim() == "")
          {
            alert( "<%=bundle.getString("FCKTEMPLATE_ALERT_CONTENT_IS_NULL")%>");
            return false;
          }
          frm.act.value='0';
          frm.action ="fcktemplatesave.jsp";
          frm.target="_self";
          frm.submit();
        }

        function f_delete()
        {
            var r = confirm("<%=bundle.getString("FCKTEMPLATE_ALERT_DELETE")%>");
            if( r !=1 ) return false;

            var frm = document.templateFrm;
            frm.act.value='1';
            frm.action ="fcktemplatesave.jsp";
            frm.target="_self";
            frm.submit();
        }
    </script>
  </head>

  <body leftmargin="20">
  <table width="100%" border=0 cellspacing=0 cellpadding=0>
      <tr height=30>
        <td>&nbsp;
      <%
           boolean bSavable = false;
           boolean bDeletable = false;
           if(bNew)
           {
               if(user.IsLocalAdmin() || user.IsSysAdmin())  bSavable = true;
               bDeletable = false;
           }
           else
           {
               //仅在以下情况下可以修改
               //1.系统管理员
               //2.作者
               if(user.IsSysAdmin() || user.GetId().equals(template.GetCreator()))  bSavable = true;
               if(user.IsSysAdmin() || user.GetId().equals(template.GetCreator()))  bDeletable = true;
           }

           if(bSavable)
           {
      %>
           <input type="button" name="okbtn" value="<%=bundle.getString("FCKTEMPLATE_BUTTON_SAVE")%>" class="button" onclick="f_save()">
<%
           }
           if(bDeletable)
           {
%>
           <input type="button" name="deletebtn" value="<%=bundle.getString("FCKTEMPLATE_BUTTON_DELETE")%>" class="button" onclick="f_delete()">
<%
            }
%>
           <input type="button" name="closebtn" value="<%=bundle.getString("FCKTEMPLATE_BUTTON_CLOSE")%>" class="button" onclick="javascript:window.close();">
        </td>
      </tr>
    </table>
   <table width="100%" cellpadding = "0" cellspacing = "0" border="1">
    <form name="templateFrm" method="post" action ="fcktemplatesave.jsp" encType="multipart/form-data">
     <input type="hidden" name="template_id" value="<%= template_id==null?"":template_id %>">
     <input type="hidden" name="act" value="0">
     <tr height="25">
       <td width=80 align=center><font color="red"><%=bundle.getString("FCKTEMPLATE_TITLE")%></font></td>
       <td>
         <input type=text name="template_title" value="<%= template==null?"":template.GetTitle() %>" size=50>
       </td>
       <td width=80 align=center><%=bundle.getString("FCKTEMPLATE_SCOPE")%></td>
       <td>
           <input type="radio" name="template_scope" value="0" <%= (template!=null && template.GetScope()==0)?"checked":""%>><%=bundle.getString("FCKTEMPLATE_SCOPE_FULL")%>
           <input type="radio" name="template_scope" value="1" <%= (template!=null && template.GetScope()==1)?"checked":""%> <%= bNew?"checked":""%>><%=bundle.getString("FCKTEMPLATE_SCOPE_MYUNIT")%>
       </td>
     </tr>
     <tr height="25">
         <td width=80 align="center"><%=bundle.getString("FCKTEMPLATE_IMAGE")%></td>
         <td>&nbsp;&nbsp;
             <img src="/userdir/fcktemplate/<%= template==null?"no.jpg":template.GetId()+".jpg"%>" border="0">
             <br>
             &nbsp;&nbsp;<input type="file" name="template_image">
         </td>
         <td width="80" align="center"><%=bundle.getString("FCKTEMPLATE_DESC")%></td>
         <td><textarea name="template_desc" style="width:100%;height:100;"><% if(template!=null) out.print(template.GetDescription()); %></textarea></td>
     </tr>
     <tr height="25">
        <td width=80  align=center>
           <%=bundle.getString("FCKTEMPLATE_CREATOR")%>
        </td>
        <td><%= creator %></td>
        <td width=80  align=center><%=bundle.getString("FCKTEMPLATE_CREATEDATE")%></td>
        <td><%= create_date %></td>
     </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="1" class="titlebar">
    <tr height="25">
       <td >&nbsp;&nbsp;&nbsp;&nbsp;<%=bundle.getString("FCKTEMPLATE_CONTENT")%></td>
    </tr>
    <tr>
        <td>
             <textarea name="template_data" style="width:996px;height:1000px;"><% if(template!=null) template.GetHtml(wrapper.GetContext(),out); %></textarea>
        </td>
    </tr>
  </table>
 </form>
</body>
</html>
<%
    }
    finally
    {
        if(wrapper!=null) wrapper.Clear();
    }
%>