<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>

<%@ page import="nps.util.Utils" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.Config" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="nps.job.awstats.AwstatsLang" %>
<%@ include file = "/include/header.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_awstats",user.GetLocale(), Config.RES_CLASSLOADER);
%>
<html>
<head>
  <title><%=bundle.getString("AWSTATS_HTMLTILE")%></title>
  <script type="text/javascript" src="/jscript/global.js"></script>
  <script type="text/javascript" src="/editarea/edit_area_full.js"></script>
  <LINK href="/css/style.css" rel = stylesheet>
  <script type="text/javascript">
      function f_viewoutput(output)
      {
        var frm = document.frm_awstats;
        frm.output.value = output;
          
        frm.submit();
      }
  </script>
</head>
 
<body leftmargin="100">
<table width="100%" cellpadding = "0" cellspacing = "0" border="0">
<form name="frm_awstats" action="viewawstats.jsp" method="post" target="awstatsFrame">
  <input type="hidden" name="output" value="">
  <tr height="25">
    <td colspan="2">
       <table width="100%" cellpadding="0" cellspacing="1" border="0" class="TitleBar">
            <tr height="30"><td align="center"><b><%=bundle.getString("AWSTATS_HTMLTILE")%></b></td></tr>
            <tr height="25">
           <td align="center">
               <font color="red"><%=bundle.getString("AWSTATS_SITE")%></font>
               <select name="siteid">
                 <%
                   java.util.Hashtable sites = user.GetOwnSites();
                   //key:id value:caption
                   if((sites!=null) && !sites.isEmpty())
                   {
                      java.util.Enumeration sitekeys = sites.keys();
                      while(sitekeys.hasMoreElements())
                      {
                        String site_id = (String)sitekeys.nextElement();
                        String site_caption = (String)sites.get(site_id);
                 %>
                        <option value="<%= site_id %>"><%= Utils.TransferToHtmlEntity(site_caption) %></option>
                 <%
                      }//while(sitekeys.hasMoreElements())
                    }//if((sites!=null) && !sites.isEmpty())
                 %>
               </select>

              <font color="red"><%=bundle.getString("AWSTATS_LANG")%></font>
               <%
                   String lang = AwstatsLang.GetLang(user.GetLocale());
               %>
               <select name="lang">
                   <option value="al" <%="al".equalsIgnoreCase(lang)?"selected":""%>>al</option>
                   <option value="ar" <%="ar".equalsIgnoreCase(lang)?"selected":""%>>ar</option>
                   <option value="ba" <%="ba".equalsIgnoreCase(lang)?"selected":""%>>ba</option>
                   <option value="bg" <%="bg".equalsIgnoreCase(lang)?"selected":""%>>bg</option>
                   <option value="br" <%="br".equalsIgnoreCase(lang)?"selected":""%>>br</option>
                   <option value="ca" <%="ca".equalsIgnoreCase(lang)?"selected":""%>>ca</option>
                   <option value="cn" <%="cn".equalsIgnoreCase(lang)?"selected":""%>>cn</option>
                   <option value="cy" <%="cy".equalsIgnoreCase(lang)?"selected":""%>>cy</option>
                   <option value="cz" <%="cz".equalsIgnoreCase(lang)?"selected":""%>>cz</option>
                   <option value="de" <%="de".equalsIgnoreCase(lang)?"selected":""%>>de</option>
                   <option value="dk" <%="dk".equalsIgnoreCase(lang)?"selected":""%>>dk</option>
                   <option value="en" <%="en".equalsIgnoreCase(lang)?"selected":""%>>en</option>
                   <option value="es" <%="es".equalsIgnoreCase(lang)?"selected":""%>>es</option>
                   <option value="et" <%="et".equalsIgnoreCase(lang)?"selected":""%>>et</option>
                   <option value="eu" <%="eu".equalsIgnoreCase(lang)?"selected":""%>>eu</option>
                   <option value="fi" <%="fi".equalsIgnoreCase(lang)?"selected":""%>>fi</option>
                   <option value="fr" <%="fr".equalsIgnoreCase(lang)?"selected":""%>>fr</option>
                   <option value="gl" <%="gl".equalsIgnoreCase(lang)?"selected":""%>>gl</option>
                   <option value="gr" <%="gr".equalsIgnoreCase(lang)?"selected":""%>>gr</option>
                   <option value="he" <%="he".equalsIgnoreCase(lang)?"selected":""%>>he</option>
                   <option value="hr" <%="hr".equalsIgnoreCase(lang)?"selected":""%>>hr</option>
                   <option value="hu" <%="hu".equalsIgnoreCase(lang)?"selected":""%>>hu</option>
                   <option value="id" <%="id".equalsIgnoreCase(lang)?"selected":""%>>id</option>
                   <option value="is" <%="is".equalsIgnoreCase(lang)?"selected":""%>>is</option>
                   <option value="it" <%="it".equalsIgnoreCase(lang)?"selected":""%>>it</option>
                   <option value="jp" <%="jp".equalsIgnoreCase(lang)?"selected":""%>>jp</option>
                   <option value="ko" <%="ko".equalsIgnoreCase(lang)?"selected":""%>>ko</option>
                   <option value="lt" <%="lt".equalsIgnoreCase(lang)?"selected":""%>>lt</option>
                   <option value="lv" <%="lv".equalsIgnoreCase(lang)?"selected":""%>>lv</option>
                   <option value="mk" <%="mk".equalsIgnoreCase(lang)?"selected":""%>>mk</option>
                   <option value="nb" <%="nb".equalsIgnoreCase(lang)?"selected":""%>>nb</option>
                   <option value="nl" <%="nl".equalsIgnoreCase(lang)?"selected":""%>>nl</option>
                   <option value="nn" <%="nn".equalsIgnoreCase(lang)?"selected":""%>>nn</option>
                   <option value="pl" <%="pl".equalsIgnoreCase(lang)?"selected":""%>>pl</option>
                   <option value="pt" <%="pt".equalsIgnoreCase(lang)?"selected":""%>>pt</option>
                   <option value="ro" <%="ro".equalsIgnoreCase(lang)?"selected":""%>>ro</option>
                   <option value="ru" <%="ru".equalsIgnoreCase(lang)?"selected":""%>>ru</option>
                   <option value="se" <%="se".equalsIgnoreCase(lang)?"selected":""%>>se</option>
                   <option value="si" <%="si".equalsIgnoreCase(lang)?"selected":""%>>si</option>
                   <option value="sk" <%="sk".equalsIgnoreCase(lang)?"selected":""%>>sk</option>
                   <option value="sr" <%="sr".equalsIgnoreCase(lang)?"selected":""%>>sr</option>
                   <option value="th" <%="th".equalsIgnoreCase(lang)?"selected":""%>>th</option>
                   <option value="tr" <%="tr".equalsIgnoreCase(lang)?"selected":""%>>tr</option>
                   <option value="tw" <%="tw".equalsIgnoreCase(lang)?"selected":""%>>tw</option>
                   <option value="ua" <%="ua".equalsIgnoreCase(lang)?"selected":""%>>ua</option>
               </select>
           </td>
         </tr>
         <tr>
             <td align="center">
                 <%
                     Calendar current_calendar = java.util.Calendar.getInstance();
                     int current_year = current_calendar.get(java.util.Calendar.YEAR);
                     int current_month = current_calendar.get(java.util.Calendar.MONTH)+1; 
                 %>
                 <select name="year">
                    <%
                        for(int i=current_year-10;i<=current_year;i++)
                        {
                    %>
                        <option value="<%=i%>" <%if(i==current_year) out.print("selected");%>><%=i%></option>
                    <%
                        }
                    %>
                 </select>
                 <select name="month">
                     <option value=""><%=bundle.getString("AWSTATS_MONTH")%></option>
                     <%
                         for(int i=1;i<=12;i++)
                         {
                     %>
                         <option value="<%=i%>" <%if(i==current_month) out.print("selected");%>><%=Utils.FormateNumber(i,"00")%></option>
                     <%
                         }
                     %>
                 </select>
                 <select name="day">
                     <option value=""><%=bundle.getString("AWSTATS_DAY")%></option>
                     <%
                         for(int i=1;i<=31;i++)
                         {
                     %>
                         <option value="<%=i%>"><%=Utils.FormateNumber(i,"00")%></option>
                     <%
                         }
                     %>
                 </select>
                 <select name="hour">
                     <option value=""><%=bundle.getString("AWSTATS_HOUR")%></option>
                     <%
                         for(int i=0;i<=23;i++)
                         {
                     %>
                         <option value="<%=i%>"><%=i%></option>
                     <%
                         }
                     %>
                 </select>
             </td>
         </tr>
         <tr><td height="10"></td></tr>
       </table>
    </td>
  </tr>
  <tr>
      <td width="10"></td>
      <td>
          <table width=100% border="0" cellpadding="0" cellspacing="0">
              <tr height=20>
                <td>
                    <a href="javascript:f_viewoutput('');"><%=bundle.getString("AWSTATS_SUMMARY")%></a>
                </td>
              </tr>
              <tr height=20>

                <td>
                    <b><%=bundle.getString("AWSTATS_WHO")%></b>
                </td>
              </tr>
              <tr height=20>

                <td>
                    &nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:f_viewoutput('alldomains');"><%=bundle.getString("AWSTATS_ALLDOMAINS")%></a>
                </td>
              </tr>
              <tr height=20>

                <td>
                    &nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:f_viewoutput('allhosts');"><%=bundle.getString("AWSTATS_HOSTS")%></a>
                </td>
              </tr>
              <tr height=20>

                <td>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                           <a href="javascript:f_viewoutput('lasthosts');"><%=bundle.getString("AWSTATS_LASTHOST")%></a>
                </td>
              </tr>
              <tr height=20>

                <td>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                          <a href="javascript:f_viewoutput('unknownip');"><%=bundle.getString("AWSTATS_UNKNOWNIP")%></a>
                </td>
              </tr>
              <tr height=20>

                <td>
                    &nbsp;&nbsp;&nbsp;&nbsp; <a href="javascript:f_viewoutput('allrobots');"><%=bundle.getString("AWSTATS_ALLROBOTS")%></a>
                </td>
              </tr>
              <tr height=20>

                <td>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                          <a href="javascript:f_viewoutput('lastrobots');"><%=bundle.getString("AWSTATS_LASTROBOTS")%></a>
                </td>
              </tr>
              <tr height=20>

                <td>
                    <b><%=bundle.getString("AWSTATS_NAVIGATION")%></b>
                </td>
              </tr>
              <tr height=20>

                <td>
                    &nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:f_viewoutput('urldetail');"><%=bundle.getString("AWSTATS_URLDETAIL")%></a>
                </td>
              </tr>
              <tr height=20>

                <td>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                         <a href="javascript:f_viewoutput('urlentry');"><%=bundle.getString("AWSTATS_URLENTRY")%></a>
                </td>
              </tr>
              <tr height=20>

                <td>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                         <a href="javascript:f_viewoutput('urlexit');"><%=bundle.getString("AWSTATS_URLEXIT")%></a>
                </td>
              </tr>
              <tr height=20>

                <td>
                    &nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:f_viewoutput('osdetail');"><%=bundle.getString("AWSTATS_OSDETAIL")%></a>
                </td>
              </tr>
              <tr height=20>

                <td>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <a href="javascript:f_viewoutput('unknownos');"><%=bundle.getString("AWSTATS_UNKNOWNOS")%></a>
                </td>
              </tr>
              <tr height=20>

                <td>
                    &nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:f_viewoutput('browserdetail');"><%=bundle.getString("AWSTATS_BROWSERDETAIL")%></a>
                </td>
              </tr>
              <tr height=20>

                <td>
                     &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                         <a href="javascript:f_viewoutput('unknownbrowser');"><%=bundle.getString("AWSTATS_UNKNOWNBROWSER")%></a>
                </td>
              </tr>
              <tr height=20>

                <td>
                    <b><%=bundle.getString("AWSTATS_REFERRERS")%></b>
                </td>
              </tr>
              <tr height=20>

                <td>
                    &nbsp;&nbsp;&nbsp;&nbsp;<%=bundle.getString("AWSTATS_ORIGIN")%>
                </td>
              </tr>
              <tr height=20>

                <td>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                         <a href="javascript:f_viewoutput('refererse');"><%=bundle.getString("AWSTATS_REFERESERSE")%></a>
                </td>
              </tr>
              <tr height=20>

                <td>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <a href="javascript:f_viewoutput('refererpages');"><%=bundle.getString("AWSTATS_REFERERPAGES")%></a>
                </td>
              </tr>
              <tr height=20>

                <td>
                    &nbsp;&nbsp;&nbsp;&nbsp;<%=bundle.getString("AWSTATS_SEARCH")%>
                </td>
              </tr>
              <tr height=20>

                <td>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <a href="javascript:f_viewoutput('keyphrases');"><%=bundle.getString("AWSTATS_KEYPHRASES")%></a>
                </td>
              </tr>
              <tr height=20>

               <td>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                       <a href="javascript:f_viewoutput('keywords');"><%=bundle.getString("AWSTATS_KEYWORDS")%></a>
                </td>
              </tr>
              <tr height=20>

                <td>
                    <a href="javascript:f_viewoutput('errors404');"><%=bundle.getString("AWSTATS_ERRORS404")%></a>
                </td>
              </tr>

          </table>
      </td>
  </tr>
   </form>
  </table>
  </body>
</html>