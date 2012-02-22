<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.sql.Connection" %>

<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    if(!user.IsSysAdmin()) throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

    String cmd = request.getParameter("cmd");
    String id = request.getParameter("id");
    if(id!=null) id = id.trim();

    String parentid = request.getParameter("parentid");
    String menu_name = request.getParameter("menu_name");
    String menu_url = request.getParameter("menu_url");
    String menu_target = request.getParameter("menu_target");
    String sIndex = request.getParameter("menu_index");
    String menu_sites = request.getParameter("menu_sites");
    String menu_roles  = request.getParameter("menu_roles");
    String s_visible = request.getParameter("menu_visible");
    String s_default = request.getParameter("menu_def");

    int menu_visible = 0;
    try{menu_visible = Integer.parseInt(s_visible);}catch(Exception e){}

    int index = 0;
    try{index = Integer.parseInt(sIndex);}catch(Exception e1){}

    boolean bNew = (id==null || id.length()==0);

    if( menu_name == null || menu_name.length() == 0)  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

    Connection conn = null;
    try
    {
        conn = Database.GetDatabase("nps").GetConnection();
        MenuTree tree = MenuTree.GetInstance(conn);
        Menu menu = null;

        //删除
        if("delete".equalsIgnoreCase(cmd))
        {
            menu = tree.GetMenu(id);
            if(menu==null) throw new NpsException(id,ErrorHelper.SYS_NOMENUITEM);
            
            tree.Delete(conn,menu);
            response.sendRedirect("menuinfo.jsp?delete=1&id="+id);
            return;
        }

        //保存数据
        if(bNew)
        {
            //自动编号
            if(index==0)  index = tree.GenerateMenuIndex(parentid);
            id = tree.GenerateMenuId(conn);

            int layer = 0;
            if(parentid!=null && parentid.length()>0)
            {
                Menu menu_parent = tree.GetMenu(parentid);
                if(menu_parent==null) throw new NpsException(parentid,ErrorHelper.SYS_NOMENUITEM);

                layer = menu_parent.GetLayer()+1;
            }

            menu = new Menu(parentid,id,menu_name,index);
            menu.SetURL(menu_url);
            menu.SetTarget(menu_target);
            menu.SetVisibility(menu_visible);
            menu.SetSites(menu_sites);
            menu.SetRoles(menu_roles);
            menu.SetLayer(layer);
            menu.SetDefault("1".equals(s_default));
        }
        else
        {
            menu = tree.GetMenu(id);
            if(menu==null)  throw new NpsException(id,ErrorHelper.SYS_NOMENUITEM);

            menu.SetName(menu_name);
            menu.SetParentId(parentid);
            menu.SetURL(menu_url);
            menu.SetTarget(menu_target);
            menu.SetVisibility(menu_visible);
            menu.SetSites(menu_sites);
            menu.SetRoles(menu_roles);
            menu.SetIndex(index);
            menu.SetDefault("1".equals(s_default));
        }

        tree.Save(conn,menu,bNew);

        conn.commit();
        response.sendRedirect("menuinfo.jsp?refresh=1&id="+id);
    }
    catch(Exception e)
    {
        try{conn.rollback();}catch(Exception e1){}
        e.printStackTrace();
        throw e;
    }
    finally
    {
        if(conn!=null) conn.close();
    }
%>