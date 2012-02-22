<%@ page language = "java" contentType = "text/html;charset=UTF-8"%>
<%@ page import="nps.module.VisualModule" %>
<%@ page import="nps.util.Utils" %>

<%
    VisualModule module = (VisualModule)request.getAttribute("module");
    String suffix = request.getParameter("suffix");
    if(suffix==null || suffix.length()==0) suffix = module.GetId();

    String effect = module.GetDataString("effect",suffix);
    if("MARQUEE".equals(effect))
    {
        //走马灯
        String content = module.GetDataString("content",suffix);
        if(content!=null && content.length()>0)
        {
            String marquee_name = "text_marquee_" + module.GetId();

            out.print("<div id=\"" + marquee_name + "\" style=\"overflow:auto;");
            String marquee_width = module.GetDataString("marquee_width",suffix);
            if(marquee_width!=null && marquee_width.length()>0)
            {
                out.print("width:" + marquee_width + "px;");
            }
            
            String marquee_height = module.GetDataString("marquee_height",suffix);
            if(marquee_height!=null && marquee_height.length()>0)
            {
                out.print("height:" + marquee_height + "px;");
            }
            out.print("\">");
            out.print(content);
            out.println("</div>");
            out.println("<script language=javascript>");
            out.println("var " + marquee_name + " = new Marquee(\"" + marquee_name + "\");");
            String marquee_direct = module.GetDataString("marquee_direct",suffix);
            if(marquee_direct!=null && marquee_direct.length()>0)
            {
                out.println(marquee_name + ".Direction = " + marquee_direct + ";");
            }

            String marquee_step = module.GetDataString("marquee_step",suffix);
            if(marquee_step!=null && marquee_step.length()>0)
            {
                out.println(marquee_name + ".Step = " + marquee_step + ";");
            }

            String marquee_timer = module.GetDataString("marquee_timer",suffix);
            if(marquee_timer!=null && marquee_timer.length()>0)
            {
                out.println(marquee_name + ".Timer = " + marquee_timer + ";");
            }

            String marquee_delaytime = module.GetDataString("marquee_delaytime",suffix);
            if(marquee_delaytime!=null && marquee_delaytime.length()>0)
            {
                out.println(marquee_name + ".DelayTime = " + marquee_delaytime + ";");
            }

            String marquee_waittime = module.GetDataString("marquee_waittime",suffix);
            if(marquee_waittime!=null && marquee_waittime.length()>0)
            {
                out.println(marquee_name + ".WaitTime = " + marquee_waittime + ";");
            }

            String marquee_scrollstep = module.GetDataString("marquee_scrollstep",suffix);
            if(marquee_scrollstep!=null && marquee_scrollstep.length()>0)
            {
                out.println(marquee_name + ".ScrollStep = " + marquee_scrollstep + ";");
            }

            out.println(marquee_name + ".start();");
            out.println("</script>");
        }
    }
    else
    {
        out.print(Utils.Null2Empty(module.GetDataString("content",suffix)));
    }
%>
