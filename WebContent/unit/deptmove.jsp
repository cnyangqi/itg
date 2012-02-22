<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.sql.Connection" %>
<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    //不能 复制，仅能移动
    String unit_fromid = request.getParameter("unit_fromid");
    if(unit_fromid!=null) unit_fromid = unit_fromid.trim();

    String dept_fromid = request.getParameter("dept_fromid");
    if(dept_fromid!=null) dept_fromid = dept_fromid.trim();

    String unit_toid = request.getParameter("unit_toid");
    if(unit_toid!=null) unit_toid = unit_toid.trim();

    String dept_toid = request.getParameter("dept_toid");
    if(dept_toid!=null) dept_toid = dept_toid.trim();

    if( unit_fromid == null || unit_fromid.length() == 0 )   throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    if( unit_toid == null || unit_toid.length() == 0 )   throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

    if(!user.IsSysAdmin())
    {
        if(!(user.IsLocalAdmin() && unit_fromid.equalsIgnoreCase(user.GetUnitId()) && unit_toid.equalsIgnoreCase(user.GetUnitId())))
            throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);
    }

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_deptmove",user.GetLocale(), Config.RES_CLASSLOADER);

    Connection conn = null;
    try
    {
         conn = Database.GetDatabase("nps").GetConnection();
         conn.setAutoCommit(false);
        
         DeptTree dept_src = DeptPool.GetPool().get(unit_fromid);
         DeptTree dept_dest = DeptPool.GetPool().get(unit_toid);
         dept_src.MoveTo(conn,dept_fromid,dept_dest,dept_toid);

         conn.commit();
         out.println(bundle.getString("DEPTMOVE_SUCCESS"));
%>
            <script type="text/javascript">
                if(parent)
                {
                    parent.frames["deptList"].window.location.reload();
                }
            </script>
<%
    }
    catch(Exception e)
    {
        conn.rollback();
        throw e;
    }
    finally
    {
        if(conn!=null) try{conn.close();}catch(Exception e){};
    }
%>