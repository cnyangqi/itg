<%@ page contentType="text/html; charset=UTF-8" language="java" errorPage="/error.jsp" %>

<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.List" %>
<%@ page import="nps.core.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="nps.util.Utils" %>

<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String unitid = request.getParameter("unitid");
    if(unitid!=null) unitid=unitid.trim();

    String unitcode =request.getParameter("unitcode");
    if(unitcode!=null) unitcode=unitcode.trim();

    String username = request.getParameter("username");
    if(username!=null && username.length()>0)
    {
        username=username.trim();
        if(username.length()>0 && !username.endsWith("%")) username = username + "%";
    }

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_selectuser",user.GetLocale(), Config.RES_CLASSLOADER);

%>

<html>
  <head>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>
    <script language="javascript">
        function f_click(userid,username)
        {
            if(userid==null || username==null) return;
            var isMSIE= (navigator.appName == "Microsoft Internet Explorer");
             if (isMSIE)
             {
                 var   rt = new Array(2);
                 rt[0] = userid;
                 rt[1] = username;
                 window.returnValue= rt;
             }
             else
             {
                 parent.opener.f_adduser(userid,username);
             }

             top.close();
        }
    </script>
</head>
<%
  Connection con = null;
  PreparedStatement pstmt = null;
  ResultSet rs = null;
  try
  {
     con = Database.GetDatabase("nps").GetConnection();
%>
<body leftmargin="20" topmargin="0">
  <table width = "100% " border = "0" align = "center" cellpadding = "0" cellspacing = "0" class="positionbar">
      <form name="frm_search" method="post" action="selectuser.jsp">
      <tr>
        <td valign="middle">&nbsp;
            <select name="unitid" style="width:140px">
                <option value="" <% if(unitid==null || "".equals(unitid)) out.print("selected");%>><%=bundle.getString("SEL_UNIT")%></option>
                <%
                    List<Unit> units = user.GetUnits(con);
                    if(units!=null)
                    {
                        for(Unit unit:units)
                        {
                            out.print("<option value='" + unit.GetId() + "'");
                            if(unit.GetId().equals(unitid) || unit.GetCode().equals(unitcode)) out.print(" selected ");
                            out.println(">"+unit.GetName()+"</option>");
                        }
                    }
                %>
            </select>
            &nbsp;
            <%=bundle.getString("SEL_USERNAME")%><input type="text" name="username" value="<%=Utils.Null2Empty(username)%>">
            <input name='btn_search' type="submit" class="button" value="<%=bundle.getString("BUTTON_SEARCH")%>">
        </td>
      </tr>
      </form>
  </table>

  <table border="0" cellpadding="0" cellspacing="1" width="100%" class="titlebar">
    <tr height=30>
      <td width="5"></td>
      <td width=120><b><%=bundle.getString("USER_NAME")%></b></td>
      <td width=150><b><%=bundle.getString("USER_DEPT")%></b></td>
      <td><b><%=bundle.getString("USER_UNIT")%></b></td>  
    </tr>
    <%
        String sql = "Select a.*,b.Name dept_name,c.Name unit_name From users a,dept b,unit c Where a.dept=b.Id And b.unit=c.Id";
        if(unitid!=null && unitid.length()>0) sql += " and c.id=? ";
        if(unitcode!=null && unitcode.length()>0) sql += " and c.code=?";
        if(username!=null && username.length()>0) sql += " and a.name like ? ";
        sql += " order by b.cx,a.cx";

        int index = 1;
        pstmt = con.prepareStatement(sql);
        if(unitid!=null && unitid.length()>0) pstmt.setString(index++,unitid);
        if(unitcode!=null && unitcode.length()>0) pstmt.setString(index++,unitcode);
        if(username!=null && username.length()>0) pstmt.setString(index++,username);

        rs = pstmt.executeQuery();
	    while( rs.next() )
        {
%>
        <tr height="25" class="detailbar">
          <td width="5"></td>
          <td>
             <a onclick="javascript:f_click('<%=rs.getString("id")%>','<%=rs.getString("name")%>');"><%= rs.getString("name")%></a>
          </td>
          <td ><%= rs.getString("dept_name") %></td>
          <td ><%= rs.getString("unit_name") %></td>
        </tr>
<%
	    }
%>
  </table>
</body>
<%
   }
   finally
   {
      if(rs!=null) try{rs.close();}catch(Exception e){}
      if(pstmt!=null) try{pstmt.close();}catch(Exception e){}
      if(con!=null) try{con.close();}catch(Exception e){}
   }
%>
</html>