<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.util.Utils" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.*" %>
<%@ page import="java.sql.Connection" %>
<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");    
    String act = request.getParameter("act"); //act=0保存  act=1删除

    String id = request.getParameter("id");
    if(id!=null) id = id.trim();

    String unitid = request.getParameter("unitid");
    if(unitid!=null) unitid = unitid.trim();

    String deptid = request.getParameter("deptid");
    if(deptid!=null) deptid = deptid.trim();

    Connection conn = null;
    try
    {
        conn = Database.GetDatabase("nps").GetConnection();
        conn.setAutoCommit(false);

        Unit unit = user.GetUnit(conn,unitid);
        if(unit==null)  throw new NpsException(ErrorHelper.SYS_NOUNIT);

        ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_usersave",user.GetLocale(), Config.RES_CLASSLOADER);

        //更新缓存的Dept用户清单信息
        DeptTree tree = unit.GetDeptTree(conn);
        Dept dept = tree.GetDept(deptid);

        if("2".equalsIgnoreCase(act))
        {
            //重置密码
            if(id==null || id.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
            String userpass = request.getParameter("userpass1");
            user.ResetPassword(conn,id,userpass);
            out.println(bundle.getString("USERSAVE_CHANGEPASSWORD_SUCCESS"));
            return;
        }
        else if("1".equalsIgnoreCase(act))
        {
            //删除
            if(id==null || id.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
            user.Delete(conn,new String[]{id});
            out.println(bundle.getString("USERSAVE_DELETE_SUCCESS"));
            return;
        }
        else if("0".equalsIgnoreCase(act))
        {
            //保存
            String username = request.getParameter("username");
            if(username!=null) username = username.trim();

            String useraccount = request.getParameter("useraccount");
            if(useraccount!=null) useraccount = useraccount.trim();

            String userpass = request.getParameter("userpass1");
            String phone = request.getParameter("phone");
            if(phone!=null) phone = phone.trim();

            String email = request.getParameter("email");
            if(email!=null) email = email.trim();

            String mobile = request.getParameter("mobile");
            if(mobile!=null) mobile = mobile.trim();

            String fax = request.getParameter("fax");
            if(fax!=null) fax = fax.trim();

            String s_index = request.getParameter("index");
            int index = 0;
            try{index=Integer.parseInt(s_index);}catch(Exception e1){}

            String s_type = request.getParameter("usertype");
            int utype = 0;
            try{utype = Integer.parseInt(s_type);}catch(Exception e1){}

            String[] roles = request.getParameterValues("roleid");

            String[] roles_grantable = request.getParameterValues("role_grant_id");

            boolean bNew = (id==null || id.length()==0);
            User auser = null;

            if(bNew)
            {
                auser = user.NewUser(conn,username,useraccount,userpass,unitid,deptid,utype);
                auser.SetTelephone(phone);
                auser.SetMobile(mobile);
                auser.SetFax(fax);
                auser.SetEmail(email);
                auser.SetIndex(index);
                auser.Save(conn,bNew);
                user.SetRoles(conn,auser,roles);
                user.SetGrantableRoles(conn,auser,roles_grantable);
            }
            else
            {
                 auser = user.GetUser(conn,id);
                 if(auser==null) throw new NpsException(ErrorHelper.SYS_NOUSER);
                 auser.SetName(username);
                 auser.SetDept(dept);
                 auser.SetAccount(useraccount);
                 auser.SetTelephone(phone);
                 auser.SetMobile(mobile);
                 auser.SetFax(fax);
                 auser.SetEmail(email);
                 auser.SetIndex(index);
                 user.SetType(auser,utype);

                 auser.Save(conn,bNew);
                 user.SetRoles(conn,auser,roles);
                 user.SetGrantableRoles(conn,auser,roles_grantable);
            }
%>
   <script type="text/javascript">
       var isMSIE= (navigator.appName == "Microsoft Internet Explorer");
       if(parent)
       {
            if (isMSIE)
            {
                var   rt = new Array(4);
                rt[0] = "<%=auser.GetId()%>";
                rt[1] = "<%=auser.GetName()%>";
                rt[2] = "<%=auser.GetAccount()%>";
                rt[3] = "<%=dept.GetName()%>";
                parent.window.returnValue = rt;
                parent.window.close();
            }
            else
            {
                parent.opener.f_adduser('<%=auser.GetId()%>','<%=auser.GetName()%>','<%=auser.GetAccount()%>','<%=dept.GetName()%>');
            }

            top.close();
       }
       else
       {
           window.location="userinfo.jsp?id=<%=auser.GetId()%>";
       }
    </script>
<%
        //response.sendRedirect("userinfo.jsp?id="+auser.GetId());
        }
        
        conn.commit();
    }
    catch(Exception e)
    {
        conn.rollback();
        throw e;
    }
    finally
    {
        if(conn!=null) try{conn.close();}catch(Exception e){}
    }    
%>