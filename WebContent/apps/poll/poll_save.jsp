<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.apps.poll.Poll" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.core.NpsWrapper" %>
<%@ page import="nps.core.Site" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String poll_id = request.getParameter("poll_id");
    boolean bNew = poll_id==null || poll_id.length()==0;

    String act = request.getParameter("act");
    Poll poll = null;
    NpsWrapper wrapper = null;
    try
    {
        wrapper = new NpsWrapper(user);
        if("save".equals(act))
        {
            String question = request.getParameter("question");
            if(question==null || question.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

            String site_id = request.getParameter("site");
            if(site_id==null || site_id.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
            Site site = wrapper.GetSite(site_id);
            if(site==null)  throw new NpsException(ErrorHelper.INPUT_ERROR, "site id=" + site_id);

            int poll_type = Poll.TYPE_SINGLE_ANSWER;
            String s_poll_type = request.getParameter("poll_type");
            if(s_poll_type==null || s_poll_type.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
            try{poll_type = Integer.parseInt(s_poll_type);}catch(Exception e){}
            
            int view_type = Poll.VIEW_HORIZONTAL_BAR;
            String s_view_type = request.getParameter("view_type");
            if(s_view_type==null || s_view_type.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
            try{view_type = Integer.parseInt(s_view_type);}catch(Exception e){}

            boolean bMemberOnly = false;
            String member_only = request.getParameter("member_only");
            if("1".equals(member_only)) bMemberOnly = true;

            int iAllowSameIp = Poll.ALLOW_NONE_SAME_IP;
            String allow_same_ip = request.getParameter("allow_same_ip");
            int i_same_ip_interval = 0;
            String same_ip_interval = request.getParameter("same_ip_interval");
            try{i_same_ip_interval = Integer.parseInt(same_ip_interval);}catch(Exception e){}
            if("1".equals(allow_same_ip))
            {
                if(i_same_ip_interval>0)
                {
                    iAllowSameIp = Poll.ALLOW_SAME_IP_CONDITIONAL;
                }
                else
                {
                    iAllowSameIp = Poll.ALLOW_SAME_IP;
                }
            }

            String[] option_ids = request.getParameterValues("option_id");
            String[] option_values = request.getParameterValues("option_value");

            if(bNew)
            {
                poll = new Poll(site,question,poll_type,view_type);
                poll.SetCreator(user);
            }
            else
            {
                poll = new Poll(wrapper.GetContext(), poll_id);
                poll.SetQuestion(question);
                poll.SetType(poll_type);
                poll.SetViewType(view_type);
                poll.SetSite(site);
                poll.ClearOptions();
            }
            poll.SetAllowSameIP(iAllowSameIp);
            poll.SetSameIPInternal(i_same_ip_interval);
            poll.SetMemberOnly(bMemberOnly);

            if(option_ids!=null && option_ids.length>0)
            {
                for(int i=0;i<option_ids.length;i++)
                {
                    String option_id = option_ids[i];
                    String option_value = option_values[i];
                    if(option_value==null || option_value.length()==0) continue;

                    if(option_id==null || option_id.length()==0)
                    {
                        poll.AddOption(option_value);
                    }
                    else
                    {
                        poll.AddOption(option_id,option_value);
                    }
                }
            }
            poll.Save(wrapper.GetContext());

            response.sendRedirect("poll.jsp?id="+poll.GetId());
            return;
        }

        if("start".equals(act))
        {
            poll = new Poll(wrapper.GetContext(), poll_id);
            poll.Start(wrapper.GetContext());
            response.sendRedirect("poll.jsp?id="+poll.GetId());
            return;
        }

        if("stop".equals(act))
        {
            poll = new Poll(wrapper.GetContext(), poll_id);
            poll.Stop(wrapper.GetContext());
            response.sendRedirect("poll.jsp?id="+poll.GetId());
            return;
        }

        if("abort".equals(act))
        {
            poll = new Poll(wrapper.GetContext(), poll_id);
            poll.Abort(wrapper.GetContext());
            response.sendRedirect("poll.jsp?id="+poll.GetId());
            return;
        }

        wrapper.Commit();
    }
    catch(Exception e)
    {
        try{wrapper.Rollback();}catch(Exception e1){}
        throw e;
    }
    finally
    {
        if(wrapper!=null) wrapper.Clear();
    }
%>