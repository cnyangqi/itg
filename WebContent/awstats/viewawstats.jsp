<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.core.NormalArticle" %>
<%@ page import="nps.core.NpsWrapper" %>
<%@ page import="nps.core.Attach" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.core.Site" %>
<%@ page import="java.io.*" %>
<%@ page import="nps.job.awstats.*" %>
<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    String siteid = request.getParameter("siteid");
    if(siteid!=null) siteid = siteid.trim();
    if(siteid==null || siteid.length()==0) throw new NpsException(ErrorHelper.INPUT_ERROR);

    String output = request.getParameter("output");
    if(output!=null) output = output.trim();
    if(output.length()==0) output = null;

    String lang = request.getParameter("lang");
    if(lang!=null) lang = lang.trim();
    if(lang==null || lang.length()==0) throw new NpsException(ErrorHelper.INPUT_ERROR);

    String year = request.getParameter("year");
    if(year!=null) year = year.trim();
    if(year==null || year.length()==0) throw new NpsException(ErrorHelper.INPUT_ERROR);

    String month = request.getParameter("month");
    if(month!=null) month = month.trim();
    if(month.length()==0) month = null;

    String day = request.getParameter("day");
    if(day!=null) day = day.trim();
    if(day.length()==0) day = null;

    String hour = request.getParameter("hour");
    if(hour!=null) hour = hour.trim();
    if(hour.length()==0) hour = null;

    //校验权限,只有站点管理员和系统管理员能看到
    if(!(user.IsSiteAdmin(siteid) || user.IsSysAdmin()))
       throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE); 


    String content_type = "text/html";
    File  output_file = null;

    Site site = user.GetSite(siteid);

    if(month==null)
    {
        AwstatsYear awstats_year = new AwstatsYear(site,lang,Integer.parseInt(year));
        output_file = awstats_year.GetOutputFile(output);
    }
    else if(day==null)
    {
        AwstatsMonth awstats_month = new AwstatsMonth(site,lang,Integer.parseInt(year),Integer.parseInt(month));
        output_file = awstats_month.GetOutputFile(output);
    }
    else if(hour==null)
    {
        AwstatsDay awstats_day = new AwstatsDay(site,lang,Integer.parseInt(year),Integer.parseInt(month),Integer.parseInt(day));
        output_file = awstats_day.GetOutputFile(output);
    }
    else
    {
        AwstatsHour awstats_hour = new AwstatsHour(site,lang,Integer.parseInt(year),Integer.parseInt(month),Integer.parseInt(day),Integer.parseInt(hour));
        output_file = awstats_hour.GetOutputFile(output);
    }

    if(!output_file.exists())
         throw new NpsException("awstats file "+output_file.getName()+" not exist.",ErrorHelper.SYS_FILE_NOT_EXIST);


    response.reset();
    response.setContentType(content_type);
    response.setCharacterEncoding(AwstatsLang.GetCharset(lang));

    BufferedReader br = null;
    try
    {
        InputStreamReader fin = new InputStreamReader(new FileInputStream(output_file), "UTF-8");
        br = new BufferedReader(fin);
        OutputStreamWriter fout = new OutputStreamWriter(response.getOutputStream(),AwstatsLang.GetCharset(lang));
        String line;
        
        while ((line = br.readLine()) != null)
        {
            fout.write(line);
        }
    }
    finally
    {
        try{br.close();}catch(Exception e){}
    }

    response.flushBuffer();
    out.clear();
    out = pageContext.pushBody();
%>