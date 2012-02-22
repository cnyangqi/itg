<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.util.*" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_report",user.GetLocale(), nps.core.Config.RES_CLASSLOADER);

    String begin_date = String.valueOf(java.util.Calendar.getInstance().get(java.util.Calendar.YEAR))+"-01-01";
    String end_date = Utils.FormateDate(new java.util.Date(),"yyyy-MM-dd");
%>

<html>
<head>
    <title><%=bundle.getString("REPORT_HTMLTITLE")%></title>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>
    <script type="text/javascript">
        function f_report()
        {
            frm_report.action = document.getElementById("report_type").value;
            frm_report.submit();
        }
        function viewCalendar(obj){
          showx = event.screenX;
          showy = event.screenY;
          newWINwidth = 210+4+18;

          retval = window.showModalDialog("/include/calendar.html", "", "dialogWidth:180px; dialogHeight:185px; dialogLeft:"+showx+"px; dialogTop:"+showy+"px; status:no; directories:yes;scrollbars:no;Resizable=no; "  );
          if(retval != null )
          {
             obj.value=retval;
          }
          obj.focus();
        }
    </script>
</head>

<body leftmargin=20 topmargin=0>
<form name="frm_report" method="post" target="reportFrame">
<table width = "100% " border = "0" align = "center" cellpadding = "0" cellspacing = "0" class="positionbar">
    <tr height="25">
        <td colspan="2">&nbsp;
            <input type="button" class="button" name="btn_run" value="<%=bundle.getString("REPORT_BUTTON_RUN")%>" onclick="f_report()">
        </td>
    </tr>
</table>

<table width = "95%" border = "0" align = "center" cellpadding = "0" cellspacing = "1">
  <tr height="25">
      <td width="80" align="center"><%=bundle.getString("REPORT_BEGIN")%></td>
      <td width="120">
          <input type="text" maxlength='10' readonly='true' name="begin_date" onclick="viewCalendar(this)" value='<%=begin_date%>'>
      </td>
      <td width="80" align="center"><%=bundle.getString("REPORT_END")%></td>
      <td>
          <input type="text" maxlength='10' readonly='true' name="end_date" onclick="viewCalendar(this)" value='<%=end_date%>'>
      </td>
  </tr>
  <tr height="25">
      <td align="center"><%=bundle.getString("REPORT_SITE")%></td>
      <td colspan="3">
            <%
              java.util.Hashtable sites = user.GetOwnSites();
              //key:id value:caption
              if((sites!=null) && !sites.isEmpty())
              {
                 java.util.Enumeration sitekeys = sites.keys();
                 int rows = 0;
                 while(sitekeys.hasMoreElements())
                 {
                   String site_id = (String)sitekeys.nextElement();
                   String site_caption = (String)sites.get(site_id);
            %>
                <input type="checkbox" name="siteid" value="<%=site_id%>">
                <%= Utils.TransferToHtmlEntity(site_caption) %>
                <%
                    if(rows++%6==0) out.println("<br>");
                %>
            <%
                 }//while(sitekeys.hasMoreElements())
               }//if((sites!=null) && !sites.isEmpty())
            %>
      </td>
  </tr>
  <tr height="25">
      <td align="center"><%=bundle.getString("REPORT_TYPE")%></td>
      <td colspan="3">
          <select name="report_type">
             <option value="report_by_user.jsp"><%=bundle.getString("REPORT_BY_USER")%></option>
             <option value="report_by_dept.jsp"><%=bundle.getString("REPORT_BY_DEPT")%></option>
          </select>
      </td>
  </tr>
</table>
</form>
</body>
</html>