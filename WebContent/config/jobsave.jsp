<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.processor.Job" %>
<%@ page import="nps.processor.JobScheduler" %>
<%@ page import="org.quartz.Trigger" %>
<%@ include file="/include/header.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");
    String act = request.getParameter("act"); //0 保存  1删除

    String job_id = request.getParameter("job_id");
    if(job_id!=null) job_id = job_id.trim();
    boolean bNew = (job_id==null || job_id.length()==0);

    String job_name = request.getParameter("job_name");
    if(job_name!=null) job_name = job_name.trim();

    String job_site = request.getParameter("job_site");
    String job_runas = request.getParameter("job_runas");
    String job_runas_name = request.getParameter("job_runas_name");
    String job_cronexp = request.getParameter("job_cronexp");
    String s_job_lang = request.getParameter("job_lang");
    int    job_lang = 0;
    try{job_lang=Integer.parseInt(s_job_lang);}catch(Exception e){}
    
    String job_code = request.getParameter("job_code");

    NpsWrapper wrapper = null;
    Job job = null;
    try
    {
        wrapper = new NpsWrapper(user);

        //删除
        if("1".equalsIgnoreCase(act))
        {
            job = Job.GetJob(wrapper.GetContext(),job_id);
            if(job!=null) job.Delete(wrapper.GetContext());
            wrapper.Commit();
            JobScheduler.Cancel(job.GetId());
            out.println(job.GetName()+"("+job.GetId()+") be deleted");                    
            return;
        }

        //停止作业
        if("7".equalsIgnoreCase(act))
        {
            JobScheduler.Interrupt(job_id);
            response.sendRedirect("jobinfo.jsp?id="+job_id);
            return;
        }

        //暂停作业
        if("2".equalsIgnoreCase(act))
        {
            JobScheduler.Pause(job_id);
            response.sendRedirect("jobinfo.jsp?id="+job_id);
            return;
        }

        //恢复作业
        if("3".equalsIgnoreCase(act))
        {
            if(JobScheduler.GetStatus(job_id)== Trigger.STATE_NONE)
            {
                job = Job.GetJob(wrapper.GetContext(), job_id);
                if(job!=null) JobScheduler.Add(job);                    
            }
            else
            {
                JobScheduler.Resume(job_id);
            }
            response.sendRedirect("jobinfo.jsp?id="+job_id);
            return;
        }

        //启用
        if("4".equalsIgnoreCase(act))
        {
            job = Job.GetJob(wrapper.GetContext(), job_id);
            if(job!=null)
            {
                job.Enabled();
                job.Save(wrapper.GetContext(),false);
                JobScheduler.Add(job);    
            }

            response.sendRedirect("jobinfo.jsp?id="+job_id);
            return;
        }

        //禁用
        if("5".equalsIgnoreCase(act))
        {
            job = Job.GetJob(wrapper.GetContext(), job_id);
            if(job!=null)
            {
                job.Disabled();
                job.Save(wrapper.GetContext(),false);
                JobScheduler.Cancel(job_id);
            }

            response.sendRedirect("jobinfo.jsp?id="+job_id);
            return;
        }

        //保存数据
        if( job_name == null || job_name.length() == 0)  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
        if( job_site == null || job_site.length() == 0)  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
        if( job_runas == null || job_runas.length() == 0)  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
        if( job_cronexp == null || job_cronexp.length() == 0)  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
        if( job_code == null || job_code.length() == 0)  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
        if(bNew)
        {
            job = new Job(wrapper.GetContext(),job_name,job_lang,job_runas,job_site);
            job.SetExp(job_cronexp);
            job.SetCode(job_code);
            job.SetRunAsName(job_runas_name);
            job.SetCreator(user.GetId());
            job.SeCreatorName(user.GetName());

            job_id = job.GetId();
        }
        else
        {
            job = Job.GetJob(wrapper.GetContext(),job_id);
            if(job!=null)
            {
                job.SetName(job_name);
                job.SetLang(job_lang);
                job.SetUserRunAs(job_runas);
                job.SetRunAsName(job_runas_name);
                job.SetDefaultSiteId(job_site);
                job.SetExp(job_cronexp);
                job.SetCode(job_code);
            }
        }

        job.Save(wrapper.GetContext(),bNew);
        wrapper.Commit();

        //加入调度作业
        JobScheduler.Add(job);

        //立即运行
        if("6".equalsIgnoreCase(act))
        {
            job = Job.GetJob(wrapper.GetContext(), job_id);
            if(job!=null)
            {
                job.RunImmediately(wrapper.GetContext());
            }

            out.println(job.GetName()+"("+job.GetId()+") running in background");
            return;
        }
        
        response.sendRedirect("jobinfo.jsp?id="+job_id);
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