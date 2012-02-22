<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="nps.core.*" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.io.Reader" %>
<%@ page import="oracle.sql.CLOB" %>
<%@ page import="oracle.jdbc.driver.OracleResultSet" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_bulletin",user.GetLocale(), Config.RES_CLASSLOADER);

    String id = request.getParameter("id");
    if(id!=null) id = id.trim();
    boolean bNew=(id==null || id.length()==0);

    String creator = user.GetName()+"("+user.GetDeptName()+ "/" +user.GetUnitName()+")";
    String create_date = nps.util.Utils.FormateDate(new java.util.Date(),"yyyy-MM-dd HH:mm:ss");

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String sql = null;
    try
    {
        if(!bNew)
        {
            sql = "select a.*,b.name from bulletin a,users b"
                 + " Where a.creator=b.id and a.id=?";
            if(!user.IsSysAdmin())
            {
                sql += "  and b.id=?";
            }

            conn = Database.GetDatabase("nps").GetConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1,id);
            if(!user.IsSysAdmin())
            {
                pstmt.setString(2,user.GetUID());
            }

            rs = pstmt.executeQuery();
            if(!rs.next()) throw new NpsException(ErrorHelper.SYS_NOARTICLE);
        }

%>

<html>
  <head>
    <title><%=bNew?bundle.getString("BULLETIN_HTMLTILE"):rs.getString("title")%></title>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <script type="text/javascript" src="/FCKeditor/fckeditor.js"></script>
      
    <LINK href="/css/style.css" rel = stylesheet>

    <script language="javascript">
      function createFCKEditor()
      {
          var oFCKeditor = new FCKeditor( 'DataFCKeditor' ) ;
          oFCKeditor.BasePath = "/FCKeditor/";
          oFCKeditor.Width = '100%' ;
          oFCKeditor.Height = '5000' ;

          oFCKeditor.ToolbarSet = "Basic";
          oFCKeditor.ReplaceTextarea() ;
      }
      function FCKeditor_OnComplete( editorInstance )
      {
            document.getElementById("pbar").style.display = 'block';
      }

      function f_view()
      {
        document.frm.act.value='0';
        document.frm.action ="view.jsp";
        document.frm.target="_blank";
        document.frm.submit();
      }

      function f_save()
      {
        if( document.frm.title.value.trim() == "")
        {
           alert( "<%=bundle.getString("BULLETIN_ALERT_TITLE_IS_NULL")%>");
           document.frm.title.focus();
           return false;
        }

        var bScope = false;
        var scopes=document.getElementsByName("visibility");
        for(var i=0; i<scopes.length; i++)
        {
            if(scopes[i].checked)
            {
              bScope = true;
              break;
            }
         }

        if( !bScope )
        {
           alert("<%=bundle.getString("BULLETIN_ALERT_NO_SCOPE")%>");
           return false;
        }

        if( document.frm.validdays.value.trim() == "")
        {
           alert("<%=bundle.getString("BULLETIN_ALERT_NO_VALIDDAYS")%>");
           return false;
        }

        var oEditor = FCKeditorAPI.GetInstance('DataFCKeditor') ;
        if( oEditor.GetXHTML(true) == "")
        {
           alert("<%=bundle.getString("BULLETIN_ALERT_NO_CONTENT")%>");
           return false;
        }

        document.frm.content.value = oEditor.GetXHTML(true);
        document.frm.act.value='0';
        document.frm.action ="save.jsp";
        document.frm.target="_self";
        document.frm.submit();
      }

      function f_delete()
      {
        var r = confirm("<%=bundle.getString("BULLETIN_ALERT_DELETE")%>");
        if( r !=1 ) return false;

        document.frm.act.value='1';
        document.frm.action ="save.jsp";
        document.frm.target="_self";
        document.frm.submit();
      }
    </script>
  </head>

  <body leftmargin="20" onload="javascript:createFCKEditor();">
  <table id="pbar" border="0" class="positionbar" cellpadding="0" cellspacing="0" style="display:none">
      <tr>
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
               if(user.IsSysAdmin() || user.GetId().equals(rs.getString("creator")))
               {
                   bSavable = true;
                   bDeletable = true;
               }
           }

           if(bSavable)
           {
      %>
           <input type="button" name="okbtn" value="<%=bundle.getString("BULLETIN_BUTTON_SAVE")%>" class="button" onclick="f_save()">
<%
           }
           if(!bNew)
           {
%>
            <input type="button" name="viewbtn" value="<%=bundle.getString("BULLETIN_BUTTON_VIEW")%>" class="button" onclick="f_view()">
<%
           }
           if(bDeletable)
           {
%>
           <input type="button" name="deletebtn" value="<%=bundle.getString("BULLETIN_BUTTON_DELETE")%>" class="button" onclick="f_delete()">
<%
           }
%>
           <input type="button" name="closebtn" value="<%=bundle.getString("BULLETIN_BUTTON_CLOSE")%>" class="button" onclick="javascript:window.close();">
        </td>
      </tr>
    </table>
   <table width="100%" cellpadding = "0" cellspacing = "0" border="1">
       <form name="frm" method="post" action ="save.jsp">
        <input type="hidden" name="id" value="<%= id==null?"":id %>">
        <input type="hidden" name="act" value="0">
        <input type="hidden" id="content" name="content" value="">

        <tr height="25">
          <td align="center"><font color="red"><%=bundle.getString("BULLETIN_TITLE")%></font></td>
          <td colspan="3">
            <input type=text name="title" value="<%= bNew?"":rs.getString("title") %>"  style="width:100%"size=250>
          </td>
        </tr>
        <tr height="25">
           <td align=center><font color="red"><%=bundle.getString("BULLETIN_SCOPE")%></font></td>
           <td>
               <%
                   if(user.IsSysAdmin())
                   {
               %>
               <input type="radio" name="visibility" value="0" <% if(!bNew && 0==rs.getInt("visibility")) out.print("checked"); %>><%=bundle.getString("BULLETIN_SCOPE_ALL")%>
               <%
                   }
               %>
               <input type="radio" name="visibility" value="1" <% if(!bNew && 1==rs.getInt("visibility")) out.print("checked"); %>><%=bundle.getString("BULLETIN_SCOPE_ORG")%>
               <input type="radio" name="visibility" value="2" <% if(!bNew && 2==rs.getInt("visibility")) out.print("checked"); %>><%=bundle.getString("BULLETIN_SCOPE_DEPT")%>
           </td>
           <td align=center><font color="red"><%=bundle.getString("BULLETIN_VALIDDAYS")%></font></td>
           <td>
               <input type="text" name="validdays" value="<%=bNew?"":rs.getString("validdays")%>">
               <%=bundle.getString("BULLETIN_HINT_VALIDDAYS")%>
           </td>
        </tr>
        <tr height="25">
           <td width=100 align=center><%=bundle.getString("BULLETIN_CREATOR")%></td>
           <td><%=bNew?creator:rs.getString("name")%></td>
           <td width=100 align=center><%=bundle.getString("BULLETIN_CREATEDATE")%></td>
           <td><%=bNew?create_date:Utils.FormateDate(rs.getTimestamp("publishdate"),"yyyy-MM-dd HH:mm:ss")%></td>
        </tr>
     </form>
   </table>

    <table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td>
            <div id="FCKeditor">
                <textarea id="DataFCKeditor" cols="80" rows="20">
                <%
                    if(!bNew)
                    {
                        CLOB clob = ((OracleResultSet)rs).getCLOB("content");
                        if(clob!=null)
                        {
                            Reader is = null;
                            try
                            {
                                is = clob.getCharacterStream();
                                int b;
                                while((b=is.read())!=-1)
                                {
                                    out.write(b);
                                }
                            }
                            finally
                            {
                                if(is!=null) try{is.close();}catch(Exception e){}
                            }
                       }
                    }
                %>
                </textarea>
            </div>
        </td>
      </tr>
    </table>
</body>
</html>
<%
    }
    finally
    {
        if(rs!=null) try{rs.close();}catch(Exception e){};
        if(pstmt!=null) try{pstmt.close();}catch(Exception e){};
        if(conn!=null) try{conn.close();}catch(Exception e){};
    }
%>