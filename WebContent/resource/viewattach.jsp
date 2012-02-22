<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="java.io.File" %>
<%@ page import="java.io.FileInputStream" %>
<%@ page import="java.io.OutputStream" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.core.*" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String id = request.getParameter("id");
    if(id!=null) id = id.trim();
    if(id==null || id.length()==0) throw new NpsException(ErrorHelper.INPUT_ERROR);

    String content_type = "application/octet-stream";
    String filename = null;

    NpsWrapper wrapper = null;
    Resource res = null;
    try
    {
        wrapper = new NpsWrapper(user);
        
        res = new Resource(wrapper.GetContext(),id);
        if(res==null) throw new NpsException(ErrorHelper.SYS_NORESOURCE);

        if(res.IsExternalLink())
        {
            response.sendRedirect(res.GetURL());
            return;
        }
        
        String suffix = res.GetSuffix();
        String name = res.GetName();

        //fix filename
        if(name == null || name.length()==0)
        {
            filename = id + suffix;
        }
        else
        {
            filename = name + suffix;
        }

        File f = res.GetOutputFile();
        if(f.exists())
        {
            response.reset();
            response.setContentType(content_type);
            response.setHeader("Content-disposition","inline;filename="+java.net.URLEncoder.encode(filename,"UTF-8"));

            FileInputStream fin = null;
            try
            {
                fin = new FileInputStream(f);
                OutputStream fout = response.getOutputStream();
                int b;
                while((b = fin.read())!=-1)
                {
                    fout.write(b);
                }
            }
            finally
            {
                try{fin.close();}catch(Exception e){}
            }

            response.flushBuffer();
            out.clear();
            out = pageContext.pushBody();
        }
    }
    catch(Exception e)
    {
        java.io.CharArrayWriter cw = new java.io.CharArrayWriter();
        java.io.PrintWriter pw = new java.io.PrintWriter(cw,true);
        e.printStackTrace(pw);
        out.println(cw.toString());

        return;
    }
    finally
    {
        if(res!=null) res.Clear();
        if(wrapper!=null) wrapper.Clear();
    }
%>