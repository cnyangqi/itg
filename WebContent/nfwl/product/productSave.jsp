<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="nps.processor.Job" %>
<%@ page import="nps.processor.JobScheduler" %>
<%@ page import="com.nfwl.itg.product.*" %>
<%@ page import="tools.*" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    
    List slave_idx_deletes = new ArrayList();
    List slave_topics = new ArrayList();
    Enumeration enum_params = request.getParameterNames();
    while(enum_params.hasMoreElements())
    {
        String fieldName = (String)enum_params.nextElement();
        if(fieldName.equals("slave_idx"))
        {
            slave_idx_deletes.add(request.getParameter(fieldName));
        }
        else if(fieldName.startsWith("slave_topic_"))
        {
            slave_topics.add(fieldName);
        }
    }

    String prd_id= request.getParameter("prd_id");//如果为null，将再保存时使用序列生成ID号
    if(prd_id!=null) prd_id=prd_id.trim();
    
    String what= request.getParameter("what");//如果为null，将再保存时使用序列生成ID号
    if(what!=null) what=what.trim();
    ITG_PRODUCT product = null;
    int act=0; //默认保存处理，//0保存 1提交  2审核通过  3发布 4删除  5修改重发布 6撤销 7定时发布
    try
    {
       act=Integer.parseInt(request.getParameter("act")); 
    }
    catch(Exception e1)
    {
    }

    boolean bNew = false;
   
Connection con = null;
    try
    {
    con = nps.core.Database.GetDatabase("nfwl").GetConnection();
        if(prd_id==null || prd_id.length()==0){
          product = new ITG_PRODUCT();
        }else{
          product = ITG_PRODUCT.get(con,prd_id);
        }
        
       // art.SetSubtitle(request.getParameter("subtitle"));
       product.setName(request.getParameter("prd_name"));
       product.setPsid(request.getParameter("prd_psid"));
       product.setPsname(request.getParameter("prd_psname"));
       product.setCode(request.getParameter("prd_code"));
       product.setNewlevel(Pub.getInteger(request.getParameter("prd_newlevel")));
       product.setMarketprice(Pub.getDouble(request.getParameter("prd_marketprice")));
       product.setLocalprice(Pub.getDouble(request.getParameter("prd_localprice")));
       product.setPoint(Pub.getInteger(request.getParameter("prd_point")));
       product.setBrandid(request.getParameter("prd_brandid"));
       product.setBrandname(request.getParameter("prd_brandname"));
       product.setUnitid(request.getParameter("prd_unitid"));
       product.setUnitname(request.getParameter("prd_unitname"));
       product.setSpec(request.getParameter("prd_spec"));
       product.setOriginprovinceid(request.getParameter("prd_originprovinceid"));
       product.setShipfee(Pub.getDouble(request.getParameter("prd_shipfee")));
       product.setContent(request.getParameter("prd_content"));
       product.setParameter(request.getParameter("prd_parameter"));
       
       
       
        if(prd_id==null || prd_id.length()==0){
          product.setRegisterid(request.getParameter("prd_registerid"));
          product.setTime(Pub.currentDate(con));
          product.setRegisterid(user.GetId());
          product.insert(con);
        }else{
          
          product.setEditorid(user.GetId());
          product.setEdittime(Pub.currentDate(con));
          product.update(con);
        }
        
        product.updateOrigin(con);
        
        if(product.getContent()!=null&&product.getContent().trim().length()>0)
          product.updateContent(con,request.getParameter("prd_content"));
        if(product.getParameter()!=null&&product.getParameter().trim().length()>0)
          product.updateParameter(con,request.getParameter("prd_parameter"));
          
        con.commit();
        response.sendRedirect("productInfo.jsp?prd_id="+product.getId()+"&what="+what);        
        
    }
    catch(Exception e)
    {
        e.printStackTrace();
        throw e;
    }
    finally
    {
      if(con!=null) try{con.close();}catch(Exception e){}
    }
%>