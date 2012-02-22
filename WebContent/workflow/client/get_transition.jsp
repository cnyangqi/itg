<%@ page language = "java" contentType = "text/html;charset=UTF-8"%>
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
   String is_restart = request.getParameter("restart");
   if("1".equals(is_restart)) app_id = null; //重新开始，设置app_id为null强制模拟新建情形

   String form_data = request.getParameter("data");

   Connection conn = null;
   try
   {
       conn = Database.GetDatabase("nps").GetConnection();
       VirtualApp app = new VirtualApp(business_type, app_id);
       app.SetData(form_data);
       Client client = new Client(conn,user,app);
       List<WorkTransition> list_transitions = client.GetTransitions();
%>
    <div id="workflow_titlebar"><div id="title"><%=bundle.getString("WORKFLOW_TITLE")%></div></div>
<%
       if(list_transitions==null || list_transitions.size()==0)
       {
%>
            <div class="warning"><%=bundle.getString("WORKFLOW_NO_TRANSITIONS")%></div>
<%
       }
       else
       {
%>
           <div id="workflow_transitions">
                <span><%=bundle.getString("WORKFLOW_TO")%></span>
                <select id="transition_id">
                    <option value=""></option>
<%
           String json = "([";
           boolean bFirst = true;
           for(WorkTransition transition: list_transitions)
           {
               JSONObject obj = new JSONObject();
               obj.put("id",transition.GetId());
               obj.put("name",transition.GetName());

               if(bFirst)
               {
                   bFirst = false;
               }
               else
               {
                   json += ",";
               }

               json += obj.toString();
               out.println("<option value='" + transition.GetId() + "'>" + transition.GetName() + "</option>");
           }
           json += "])";
           response.addHeader("X-JSON", json);
%>
                </select>
            </div>
            <div id="workflow_participants" style="display:none;"></div>
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