<%@ page language = "java" contentType = "text/html;charset=UTF-8"%>
<%@ page import="nps.module.VisualModule" %>
<%@ page import="nps.module.include.SSI" %>
<%
    out.clear();
    VisualModule module = (VisualModule)request.getAttribute("module");

    String suffix = request.getParameter("suffix");
    if(suffix==null || suffix.length()==0) suffix = module.GetId();

    String preview = request.getParameter("preview");
    
    String ssi_url = module.GetDataString("ssi_url",suffix);
    String ssi_base_url = module.GetDataString("ssi_base_url",suffix);

    if(ssi_url==null || ssi_url.length()==0) return;

    if("1".equals(preview))
    {
        //预览模式
        if(ssi_base_url==null || ssi_base_url.length()==0)
        {
            out.print("&lt;!--#include virtual=\"" + ssi_url + "\"--&gt;");
        }
        else
        {
            try
            {
                SSI mod_ssi = new SSI(ssi_base_url);
                mod_ssi.Preview(out,ssi_url);
            }
            catch(Exception e)
            {
                e.printStackTrace();
                out.print("&lt;!--#include virtual=\"" + ssi_url + "\"--&gt;");
            }
        }
    }
    else
    {
        //生成模式
        out.print("<!--#include virtual=\"" + ssi_url + "\"-->");
    }
%>
