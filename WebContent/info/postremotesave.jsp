<%@ page contentType="text/html;charset=UTF-8" language="java" errorPage="/error.jsp"%>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.exception.*" %>
<%@ page import="nps.job.atom.*" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.util.Hashtable" %>

<%@ include file = "/include/header.jsp" %>
<html>
<head>
    <title>Post to remote server...</title>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <LINK href="/css/style.css" rel = stylesheet>
</head>
<body leftmargin=20 topmargin=20>    
<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_postremotesave",user.GetLocale(), nps.core.Config.RES_CLASSLOADER);

    String nps_or_advance = request.getParameter("nps_or_advance");
    String art_id = request.getParameter("art_id");
    String res_id = request.getParameter("res_id");
    if("0".equals(nps_or_advance))
    {
        String nps_http = request.getParameter("nps_http");
        String nps_host = request.getParameter("nps_host");
        String remote_site = request.getParameter("remote_site");
        String remote_topic = request.getParameter("remote_topic");
        String nps_username = request.getParameter("nps_username");
        String nps_pwd = request.getParameter("nps_pwd");

        NpsWrapper wrapper = null;
        NormalArticle doc = null;
        Resource resource = null;
        try
        {
            AtomClient client = new AtomClient(nps_http+nps_host);
            client.NpsLogin("/webapi/login",nps_username,nps_pwd);

            wrapper = new NpsWrapper(user);
            if(art_id!=null && art_id.length()>0)
            {
                doc = wrapper.GetArticle(art_id);
                if(doc==null) throw new NpsException(ErrorHelper.SYS_NOARTICLE);

                client.Post("/webapi/post/"+remote_site+"/"+remote_topic,doc);
            }
            else if(res_id!=null && res_id.length()>0)
            {
                resource = wrapper.GetResource(res_id);
                if(resource==null) throw new NpsException(ErrorHelper.SYS_NOARTICLE);

                if(remote_topic!=null && remote_topic.length()>0)
                    client.Post("/webapi/attachment/"+remote_site+"/"+remote_topic,resource);
                else
                    client.Post("/webapi/attachment/"+remote_site,resource);
            }

            out.println("<font color=red><h2>");
            if(doc!=null) out.println(doc.GetTitle());
            if(resource!=null) out.println(resource.GetTitle());
            out.println(" " +bundle.getString("POST_SUBMITTED"));
            out.println("</h2></font>");
        }
        finally
        {
            if(doc!=null) doc.Clear();
            if(resource!=null) resource.Clear();
            if(wrapper!=null) wrapper.Clear();
        }
    }
    else if("1".equals(nps_or_advance))
    {
        String adv_http = request.getParameter("adv_http");
        String adv_url = request.getParameter("adv_url");

        String adv_login = request.getParameter("adv_login");

        String login_uri = request.getParameter("adv_loginuri");
        String adv_username = request.getParameter("adv_username");
        String adv_pwd = request.getParameter("adv_pwd");

        String google_service = request.getParameter("adv_google_service");

        String var_names[] = request.getParameterValues("var_name");
        String var_values[] = request.getParameterValues("var_value");


        NpsWrapper wrapper = null;
        NormalArticle doc = null;
        Resource resource = null;
        try
        {
            AtomClient client = new AtomClient(adv_http+adv_url);
            if("1".equals(adv_login)) //Google
            {
                client.GoogleLogin(login_uri,adv_username,adv_pwd,google_service);
            }
            else if("2".equals(adv_login)) //Basic
            {
                client.HttpBasicLogin(login_uri,adv_username,adv_pwd);
            }
            else if("3".equals(adv_login)) //Form
            {
                client.FormLogin(login_uri,var_names,var_values);
            }

            wrapper = new NpsWrapper(user);
            if(art_id!=null && art_id.length()>0)
            {
                doc = wrapper.GetArticle(art_id);
                if(doc==null) throw new NpsException(ErrorHelper.SYS_NOARTICLE);

                client.Post(adv_url,doc);
            }
            else if(res_id!=null && res_id.length()>0)
            {
                resource = wrapper.GetResource(res_id);
                if(resource==null) throw new NpsException(ErrorHelper.SYS_NOARTICLE);

                client.Post(adv_url,resource);
            }

            out.println("<font color=red><h2>");
            if(doc!=null) out.println(doc.GetTitle());
            if(resource!=null) out.println(resource.GetTitle());
            out.println(" " +bundle.getString("POST_SUBMITTED"));
            out.println("</h2></font>");
        }
        finally
        {
            if(doc!=null) doc.Clear();
            if(resource!=null) resource.Clear();
            if(wrapper!=null) wrapper.Clear();
        }
    }
%>
</body>
</html>