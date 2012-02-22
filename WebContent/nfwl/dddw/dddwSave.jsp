<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>

<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.exception.*" %>

<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String act = request.getParameter("act"); //act=0保存  act=1删除
    
    String fp_id = request.getParameter("fp_id");
    if(fp_id!=null) fp_id = fp_id.trim();

    //ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_unitsave",user.GetLocale(), Config.RES_CLASSLOADER);
    com.nfwl.itg.dddw.ITG_FIXEDPOINT pixedPoint = null;
    Connection conn = null;
    try
    {
        conn = Database.GetDatabase("nps").GetConnection();
        conn.setAutoCommit(false);
        
        if("1".equalsIgnoreCase(act)){
            //删除
            if(fp_id==null || fp_id.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
            //通过user类校验本用户权限
            //Unit unit = user.GetUnit(conn,fp_id);
            //unit.Delete(conn);
            //out.println(bundle.getString("UNITSAVE_DELETE_SUCCESS"));
        }else if("0".equalsIgnoreCase(act)){
            //保存
            String  unitname = request.getParameter("unitname");
            boolean bNew = (fp_id==null || fp_id.length()==0);
            Unit unit = null;
            if(bNew){
                //校验权限
                pixedPoint = new com.nfwl.itg.dddw.ITG_FIXEDPOINT();
                pixedPoint.setName(request.getParameter("fp_name"));
                pixedPoint.setAddress(request.getParameter("fp_address")); 
                pixedPoint.setDelday(request.getParameter("fp_delday")); 
                pixedPoint.setLinker(request.getParameter("fp_linker")); 
                pixedPoint.setPhone(request.getParameter("fp_phone")); 
                pixedPoint.setEmail(request.getParameter("fp_email")); 
                pixedPoint.setPostcode(request.getParameter("fp_postcode")); 
                pixedPoint.setCode(request.getParameter("fp_code")); 
                pixedPoint.setValid(Integer.parseInt(request.getParameter("fp_valid"))); 
                pixedPoint.setRegisterid(request.getParameter("fp_registerid")); 
                pixedPoint.setTime(new java.sql.Date(new java.util.Date().getTime())); 
                pixedPoint.insert(conn);
                
            }else{
                 //通过user类校验本用户权限
                 pixedPoint = com.nfwl.itg.dddw.ITG_FIXEDPOINT.get(conn,fp_id);
                 pixedPoint.setName(request.getParameter("fp_name"));
                 pixedPoint.setAddress(request.getParameter("fp_address")); 
                 pixedPoint.setDelday(request.getParameter("fp_delday")); 
                 pixedPoint.setLinker(request.getParameter("fp_linker")); 
                 pixedPoint.setPhone(request.getParameter("fp_phone")); 
                 pixedPoint.setEmail(request.getParameter("fp_email")); 
                 pixedPoint.setPostcode(request.getParameter("fp_postcode")); 
                 pixedPoint.setCode(request.getParameter("fp_code")); 
                 pixedPoint.setValid(Integer.parseInt(request.getParameter("fp_valid"))); 
                 pixedPoint.update(conn);
            }
            response.sendRedirect("dddwInfo.jsp?fp_id="+pixedPoint.getId());
        }
        conn.commit();
    }catch(Exception e){
        conn.rollback();
        throw e;
    }finally{
        if(conn!=null) try{conn.close();}catch(Exception e){}
    }
%>