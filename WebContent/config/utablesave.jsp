<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.job.backup.SqliteDump" %>

<%@ include file="/include/header.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");
    String act = request.getParameter("act"); //0 保存  1删除

    String site_id = request.getParameter("site");
    if(site_id!=null) site_id = site_id.trim();

    String table = request.getParameter("table");
    if(table!=null) table = table.trim();

    String sql = request.getParameter("sql");

    if( site_id == null || site_id.length() == 0)  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    if( table == null || table.length() == 0)  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    if( sql == null || sql.length() == 0)  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

    NpsWrapper wrapper = null;
    SqliteDump dump = null;
    try
    {
        wrapper = new NpsWrapper(user,site_id);

        dump = new SqliteDump(wrapper.GetContext(),wrapper.GetSite());

        //删除
        if("1".equalsIgnoreCase(act))
        {
            dump.DeleteUserTable(table);
            wrapper.Commit();
            out.println(table+" be deleted");
            return;
        }

        //保存数据
        dump.AddUserTable(sql,table);
        wrapper.Commit();

        response.sendRedirect("utable.jsp?site="+site_id+"&table="+table);
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