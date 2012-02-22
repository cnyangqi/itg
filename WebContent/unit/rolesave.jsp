<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ include file="/include/header.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");

    String id = request.getParameter("id");
    if(id!=null) id = id.trim();
    boolean bNew = (id==null || id.length()==0);

    String s_act = request.getParameter("act");
    if(s_act!=null) s_act = s_act.trim();
    int act = 0;
    try{act=Integer.parseInt(s_act);}catch(Exception e){}

    String role_domain = request.getParameter("domain");
    if(role_domain!=null) role_domain = role_domain.trim();

    String role_name = request.getParameter("name");
    if(role_name!=null) role_name = role_name.trim();

    String role_desc = request.getParameter("desc");
    if(role_desc!=null) role_desc = role_desc.trim();

    String uid = request.getParameter("uid");
    if(uid!=null) uid = uid.trim();

    NpsWrapper wrapper = null;
    Role role = null;
    try
    {
        wrapper = new NpsWrapper(user);

        //删除
        if(act==1)
        {
            role = Role.GetRole(wrapper.GetContext(),id);
            if(role!=null) role.Delete(wrapper.GetContext());
            wrapper.Commit();
            out.println(role.GetName()+"("+role.GetId()+") be deleted");
            return;
        }

        //删除某用户权限
        if(act==2)
        {
            role = Role.GetRole(wrapper.GetContext(),id);
            if(role!=null) role.Revoke(wrapper.GetContext(),uid);
            wrapper.Commit();
            response.sendRedirect("roleinfo.jsp?id="+id);
            return;
        }

        //保存数据
        if(bNew)
        {
            role = new Role(wrapper.GetContext(),role_domain,role_name);
            role.SetDesc(role_desc);
            id = role.GetId();
        }
        else
        {
            role = Role.GetRole(wrapper.GetContext(),id);
            if(role!=null)
            {
                role.SetDomain(role_domain);
                role.SetName(role_name);
                role.SetDesc(role_desc);
            }
        }

        role.Save(wrapper.GetContext(),bNew);
        wrapper.Commit();

        response.sendRedirect("roleinfo.jsp?id="+id);
    }
    catch(Exception e)
    {
        wrapper.Rollback();
        throw e;
    }
    finally
    {
        if(wrapper!=null) wrapper.Clear();
    }
%>