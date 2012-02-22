<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.core.NpsWrapper" %>
<%@ page import="nps.core.Attach" %>
<%@ page import="java.io.File" %>
<%@ page import="java.io.FileInputStream" %>
<%@ page import="java.io.OutputStream" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.extra.trade.Product" %>
<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String id = request.getParameter("id");
    String att_id = request.getParameter("attid");
    if(id!=null) id = id.trim();
    if(att_id!=null) att_id = att_id.trim();
    if(id==null || id.length()==0) throw new NpsException(ErrorHelper.INPUT_ERROR);
    if(att_id==null || att_id.length()==0) throw new NpsException(ErrorHelper.INPUT_ERROR);

    String content_type = "application/octet-stream";
    String filename = null;

    NpsWrapper wrapper = null;
    Product product = null;
    try
    {
        wrapper = new NpsWrapper(user);
        product = Product.GetProduct(wrapper.GetContext(),id);

        Attach att = product.GetAttachById(att_id);
        if(att==null) throw new NpsException(ErrorHelper.SYS_NOATTACH);

        String att_suffix = att.GetSuffix();
        String att_name = att.GetShowName();

        //fix content type
        att_suffix = att_suffix.toUpperCase();
        if(att_suffix.startsWith(".")) att_suffix = att_suffix.substring(1);
        if("doc".equalsIgnoreCase(att_suffix) || "dot".equalsIgnoreCase(att_suffix))
        {
            content_type = "application/msword";
        }
        if("pdf".equalsIgnoreCase(att_suffix))
        {
            content_type = "application/pdf";
        }
        if("rtf".equalsIgnoreCase(att_suffix))
        {
            content_type = "application/rtf";
        }
        if("cab".equalsIgnoreCase(att_suffix))
        {
            content_type = "application/vnd.ms-cab-compressed";
        }
        if("xls".equalsIgnoreCase(att_suffix) || "xlt".equalsIgnoreCase(att_suffix) || "xlm".equalsIgnoreCase(att_suffix)  || "xla".equalsIgnoreCase(att_suffix)  || "xlc".equalsIgnoreCase(att_suffix) || "xlw".equalsIgnoreCase(att_suffix))
        {
            content_type = "application/vnd.ms-excel";
        }
        if("chm".equalsIgnoreCase(att_suffix))
        {
            content_type = "application/vnd.ms-htmlhelp";
        }
        if("ppt".equalsIgnoreCase(att_suffix) || "pps".equalsIgnoreCase(att_suffix) || "pot".equalsIgnoreCase(att_suffix))
        {
            content_type = "application/vnd.ms-powerpoint";
        }
        if("mpp".equalsIgnoreCase(att_suffix) || "mpt".equalsIgnoreCase(att_suffix))
        {
            content_type = "application/vnd.ms-project";
        }
        if("vsd".equalsIgnoreCase(att_suffix) || "vst".equalsIgnoreCase(att_suffix) || "vss".equalsIgnoreCase(att_suffix) || "vsw".equalsIgnoreCase(att_suffix))
        {
            content_type = "application/vnd.visio";
        }
        if("bz".equalsIgnoreCase(att_suffix))
        {
            content_type = "application/x-bzip";
        }
        if("bz2".equalsIgnoreCase(att_suffix) || "boz".equalsIgnoreCase(att_suffix))
        {
            content_type = "application/x-bzip2";
        }
        if("cpio".equalsIgnoreCase(att_suffix))
        {
            content_type = "application/x-cpio";
        }
        if("zip".equalsIgnoreCase(att_suffix))
        {
            content_type = "application/zip";
        }
        if("wav".equalsIgnoreCase(att_suffix))
        {
            content_type = "audio/wav";
        }
        if("wma".equalsIgnoreCase(att_suffix))
        {
            content_type = "audio/x-ms-wma";
        }
        if("bmp".equalsIgnoreCase(att_suffix))
        {
            content_type = "image/bmp";
        }
        if("gif".equalsIgnoreCase(att_suffix))
        {
            content_type = "image/gif";
        }
        if("jpeg".equalsIgnoreCase(att_suffix) || "jpg".equalsIgnoreCase(att_suffix)  || "jpe".equalsIgnoreCase(att_suffix))
        {
            content_type = "image/jpeg";
        }
        if("tiff".equalsIgnoreCase(att_suffix) || "tif".equalsIgnoreCase(att_suffix))
        {
            content_type = "image/tiff";
        }
        if("ico".equalsIgnoreCase(att_suffix))
        {
            content_type = "image/vnd.microsoft.icon";
        }
        if("html".equalsIgnoreCase(att_suffix) || "htm".equalsIgnoreCase(att_suffix))
        {
            content_type = "text/html";
        }
        if("txt".equalsIgnoreCase(att_suffix) || "text".equalsIgnoreCase(att_suffix))
        {
            content_type = "text/plain";
        }
        if("mpeg".equalsIgnoreCase(att_suffix) || "mpg".equalsIgnoreCase(att_suffix) || "mpe".equalsIgnoreCase(att_suffix)  || "m1v".equalsIgnoreCase(att_suffix)  || "m2v".equalsIgnoreCase(att_suffix) )
        {
            content_type = "video/mpeg";
        }
        if("mp4".equalsIgnoreCase(att_suffix) || "mp4v".equalsIgnoreCase(att_suffix) || "mpg4".equalsIgnoreCase(att_suffix))
        {
            content_type = "video/mp4";
        }


        //fix filename
        if(att_name == null || att_name.length()==0)
        {
            filename = att_id + "." + att_suffix;
        }
        else
        {
            att_name = att_name.toUpperCase();
            if(!att_name.endsWith("."+att_suffix))
            {
                filename = att_name + "." + att_suffix;
            }
            else
            {
                filename = att_name;
            }
        }

        File f = att.GetOutputFile();
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
        if(product!=null) product.Clear();
        if(wrapper!=null) wrapper.Clear();
    }
%>