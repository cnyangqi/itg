<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.core.Database" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="nps.workflow.*" %>
<%@ page import="java.util.List" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.Config" %>

<%@ include file = "/include/header.jsp" %>

<%
   request.setCharacterEncoding("UTF-8");
   ResourceBundle bundle = ResourceBundle.getBundle("langs.workflow_client", user.GetLocale(), Config.RES_CLASSLOADER);

   String business_type = request.getParameter("business_type");
   if(business_type==null || business_type.trim().length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
   String app_id = request.getParameter("app_id");
   if(app_id==null || app_id.trim().length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

   Connection conn = null;
   try
   {
       conn = Database.GetDatabase("nps").GetConnection();
       VirtualApp app = new VirtualApp(business_type, app_id);
       Client client = new Client(conn,user,app);
       List<String[]> list_jobs = client.GetReturnJobs();
%>
    <div id="workflow_titlebar"><div id="title"><%=bundle.getString("WORKFLOW_TITLE")%></div></div>
<%
       if(list_jobs==null || list_jobs.size()==0)
       {
           response.addHeader("X-JSON", "");
%>
            <div class="warning"><%=bundle.getString("WORKFLOW_NO_JOBS_TO_RETURN")%></div>
<%
       }
       else
       {
%>
    <div id="workflow_jobs">
         <span><%=bundle.getString("WORKFLOW_JOBS")%></span>
         <select id="job_id">
             <option value=""></option>

<%
           String json = "([";
           boolean bFirst = true;
           for(String[] job: list_jobs)
           {
               JSONObject obj = new JSONObject();
               obj.put("id",job[0]);
               obj.put("name",job[1]);

               if(bFirst)
               {
                   bFirst = false;
               }
               else
               {
                   json += ",";
               }

               json += obj.toString();
               out.println("<option value='" + job[0] + "'>" + job[1] + "</option>");

           }
           json += "])";
           response.addHeader("X-JSON", json);
%>
         </select>
     </div>
     <div id="workflow_participants"></div>
    <div id="workflow_suggest">
        <div><%=bundle.getString("WORKFLOW_SUGGEST")%></div><textarea id="suggest"></textarea>
    </div>
<%
       }
%>
    <div id="workflow_toolbar">
        <input type="button" id="btn_workflow_ok" name="btn_workflow_ok" value="<%=bundle.getString("WORKFLOW_BUTTON_OK")%>">
        <input type="button" id="btn_workflow_cancel" name="btn_workflow_cancel" value="<%=bundle.getString("WORKFLOW_BUTTON_CANCEL")%>">
    </div>
<%
   }
   finally
   {
       if(conn!=null) try{conn.close();}catch(Exception e){}
   }
%>