<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>

<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.exception.*" %>

<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String act = request.getParameter("act"); //act=0保存  act=1删除
    
    String id = request.getParameter("id");
    if(id!=null) id = id.trim();

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_unitsave",user.GetLocale(), Config.RES_CLASSLOADER);

    Connection conn = null;
    try
    {
        conn = Database.GetDatabase("nps").GetConnection();
        conn.setAutoCommit(false);
        
        if("1".equalsIgnoreCase(act))
        {
            //删除
            if(id==null || id.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
            //通过user类校验本用户权限
            Unit unit = user.GetUnit(conn,id);
            unit.Delete(conn);
            out.println(bundle.getString("UNITSAVE_DELETE_SUCCESS"));
        }
        else if("0".equalsIgnoreCase(act))
        {
            //保存
            String  unitname = request.getParameter("unitname");
            String  unitcode = request.getParameter("code");
            String  attachman = request.getParameter("attachman");
            String phonenum = request.getParameter("phonenum");
            String mobile = request.getParameter("mobile");
            String email = request.getParameter("email");
            String zipcode = request.getParameter("zipcode");
            String address = request.getParameter("address");

            boolean bNew = (id==null || id.length()==0);
            Unit unit = null;

            if(bNew)
            {
                //校验权限
                if(!user.IsSysAdmin()) throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

                unit = Unit.GetUnit(conn,unitname,unitcode);
                unit.SetAddress(address);
                unit.SetZipcode(zipcode);
                unit.SetMobile(mobile);
                unit.SetPhonenum(phonenum);
                unit.SetAttachman(attachman);
                unit.SetEmail(email);
            }
            else
            {
                 //通过user类校验本用户权限
                 unit = user.GetUnit(conn,id);
                 unit.SetName(unitname);
                 unit.SetCode(unitcode);
                 unit.SetAddress(address);
                 unit.SetZipcode(zipcode);
                 unit.SetMobile(mobile);
                 unit.SetPhonenum(phonenum);
                 unit.SetAttachman(attachman);
                 unit.SetEmail(email);
            }

            unit.Save(conn,bNew);
            response.sendRedirect("unitinfo.jsp?id="+unit.GetId());
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