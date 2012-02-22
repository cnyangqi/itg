<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.sql.Connection" %>
<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    
    String cmd = request.getParameter("cmd");
    if(cmd!=null) cmd = cmd.trim();
    if(cmd==null || cmd.length()==0) cmd="save";  //默认是删除

    String unit_id = request.getParameter("unitid");
    if(unit_id!=null) unit_id = unit_id.trim();

    String dept_id = request.getParameter("deptid");
    if(dept_id!=null) dept_id = dept_id.trim();

    String dept_parentid = request.getParameter("dept_parentid");
    if(dept_parentid!=null) dept_parentid = dept_parentid.trim();

    String dept_name = request.getParameter("dept_name");
    if(dept_name!=null)  dept_name = dept_name.trim();

    String dept_code = request.getParameter("dept_code");
    if(dept_code!=null) dept_code = dept_code.trim();
    
    String s_dept_index = request.getParameter("dept_index");
    int dept_index=0;
    try{dept_index=Integer.parseInt(s_dept_index);}catch(Exception e){}
    
    boolean bNew = (dept_id ==null || dept_id.length()==0);

    Connection conn = null;
    try
    {
        conn = Database.GetDatabase("nps").GetConnection();
        conn.setAutoCommit(false);
        
        if( unit_id == null)  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
        Unit unit = user.GetUnit(conn,unit_id);
        //校验权限
        if(unit ==null) throw new NpsException(ErrorHelper.SYS_NOUNIT);

        DeptTree tree = unit.GetDeptTree(conn);
        if(tree == null) throw new NpsException(ErrorHelper.SYS_NODEPTTREE);

        if("save".equalsIgnoreCase(cmd))
        {
            //保存
            //校验输入的数据
            if(dept_name == null) throw new NpsException(ErrorHelper.INPUT_ERROR);
            if(dept_code == null) throw new NpsException(ErrorHelper.INPUT_ERROR);

            Dept dept = null;
            if(bNew)
            {
                //自动计数
                if(dept_index==0)  dept_index = tree.GenerateIndex(dept_parentid);
                dept = tree.NewDept(conn,dept_parentid,dept_name,dept_code,dept_index);
                dept_id = dept.GetId();
            }
            else
            {
                dept = tree.GetDept(dept_id);
                dept.SetName(dept_name);
                dept.SetCode(dept_code);
                dept.SetIndex(dept_index);
            }

            tree.SaveDept(conn,dept,bNew);
            response.sendRedirect("deptinfo.jsp?refresh=1&unitid="+unit_id+"&deptid="+dept_id);
            return;
        }

        if("delete".equalsIgnoreCase(cmd))
        {
           //删除
           if( dept_id == null)  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

           tree.DeleteDept(conn,dept_id);

           response.sendRedirect("deptinfo.jsp?refresh=1&delete=1&unitid="+unit_id+"&deptid="+dept_id);
           return;
        }

        conn.commit();
    }
    catch(Exception e)
    {
        if(conn!=null) conn.rollback();
        throw e;
    }
    finally
    {
        if(conn!=null) try{conn.close();}catch(Exception e){}
    }
%>