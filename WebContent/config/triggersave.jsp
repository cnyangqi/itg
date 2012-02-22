<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ include file="/include/header.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");
    String act = request.getParameter("act"); //0 保存  1删除

    String trigger_id = request.getParameter("trigger_id");
    if(trigger_id!=null) trigger_id = trigger_id.trim();
    boolean bNew = (trigger_id==null || trigger_id.length()==0);

    String trigger_name = request.getParameter("trigger_name");
    if(trigger_name!=null) trigger_name = trigger_name.trim();

    String trigger_site = request.getParameter("siteid");
    String trigger_topic = request.getParameter("topid");
    String s_trigger_event = request.getParameter("trigger_event");
    String s_trigger_lang = request.getParameter("trigger_lang");
    int    trigger_lang = 0;
    try{trigger_lang=Integer.parseInt(s_trigger_lang);}catch(Exception e){}
    
    int trigger_event = 0;
    try{trigger_event=Integer.parseInt(s_trigger_event);}catch(Exception e){}

    String trigger_code = request.getParameter("trigger_code");

    if( trigger_name == null || trigger_name.length() == 0)  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    if( trigger_site == null || trigger_site.length() == 0)  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    if( trigger_topic == null || trigger_topic.length() == 0)  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    if( trigger_code == null || trigger_code.length() == 0)  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

    NpsWrapper wrapper = null;
    TriggerManager manager = null;
    Trigger trigger = null;
    try
    {
        wrapper = new NpsWrapper(user);
        manager = TriggerManager.LoadTriggers((wrapper.GetContext()));
        
        //删除
        if("1".equalsIgnoreCase(act))
        {
            manager.DeleteTrigger(wrapper.GetContext(),trigger_id);
            wrapper.Commit();
            out.println("Trigger "+trigger_id+" be deleted");
            return;
        }

        //启用
        if("4".equalsIgnoreCase(act))
        {
            trigger = manager.GetTrigger(wrapper.GetContext(),trigger_id);
            if(trigger!=null)
            {
                trigger.Enable();
                trigger.Save(wrapper.GetContext());
            }

            response.sendRedirect("triggerinfo.jsp?id="+trigger_id);
            return;
        }

        //禁用
        if("5".equalsIgnoreCase(act))
        {
            trigger = manager.GetTrigger(wrapper.GetContext(),trigger_id);
            if(trigger!=null)
            {
                trigger.Disable();
                trigger.Save(wrapper.GetContext());
            }

            response.sendRedirect("triggerinfo.jsp?id="+trigger_id);
            return;
        }

        //保存数据
        Topic top = wrapper.GetSite(trigger_site).GetTopicTree().GetTopic(trigger_topic);
        if(bNew)
        {                                  
            trigger = new Trigger(trigger_name,trigger_event,top,true,user);
            trigger.SetCode(trigger_lang,trigger_code);

            trigger.Save(wrapper.GetContext());

            //新建的开始侦听
            trigger.Listen();
            manager.Add2Pool(trigger);

            trigger_id = trigger.GetId();
        }
        else
        {
            trigger = manager.GetTrigger(wrapper.GetContext(),trigger_id);
            if(trigger!=null)
            {
                trigger.SetName(trigger_name);
                trigger.SetTopic(top);
                trigger.SetEvent(trigger_event);
                trigger.SetCode(trigger_lang,trigger_code);
                trigger.Save(wrapper.GetContext());
            }
        }

        wrapper.Commit();

        response.sendRedirect("triggerinfo.jsp?id="+trigger_id);
    }
    catch(Exception e)
    {
        wrapper.Rollback();
        e.printStackTrace();
        throw e;
    }
    finally
    {
        if(wrapper!=null) wrapper.Clear();
    }
%>