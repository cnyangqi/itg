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

   String transition_id = request.getParameter("transition_id");
   String job_id = request.getParameter("job_id");

   if(  (transition_id==null || transition_id.trim().length()==0) && (job_id==null || job_id.trim().length()==0))
       throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

   Connection conn = null;
   try
   {
       conn = Database.GetDatabase("nps").GetConnection();
       VirtualApp app = new VirtualApp(business_type, app_id);
       Client client = new Client(conn,user,app);
       List<String[]> list_participants = null;
       if(transition_id!=null)
       {
           list_participants = client.GetParticipants(transition_id);
       }
       else
       {
           list_participants = client.GetParticipantsByJob(job_id);
       }

       if(list_participants==null || list_participants.size()==0)
       {
%>
          <div class="warning"><%=bundle.getString("WORKFLOW_NO_PARTICIPANTS")%></div>
<%
       }
       else
       {
%>
          <span><%=bundle.getString("WORKFLOW_PARTICIPANTS")%></span>
          <select id="participants" multiple="1">
<%
           String json = "([";
           boolean bFirst = true;
           for(String[] participant: list_participants)
           {
               JSONObject obj = new JSONObject();
               obj.put("id",participant[0]);
               obj.put("name",participant[1]);

               if(bFirst)
               {
                   bFirst = false;
               }
               else
               {
                   json += ",";
               }

               json += obj.toString();
               out.println("<option value='" + participant[0] + "|" + participant[1] +"'>" + participant[1] + "</option>");
           }
           json += "])";
           response.addHeader("X-JSON", json);
%>
          </select>
<%
        }
   }
   finally
   {
       if(conn!=null) try{conn.close();}catch(Exception e){}
   }
%>