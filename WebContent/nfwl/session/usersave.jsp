<%@page import="tools.AjaxUtils"%>
<%@page import="tools.Pub"%>
<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.util.Utils" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.*" %>
<%@ page import="java.sql.*" %>

<%
    request.setCharacterEncoding("UTF-8");    
    String act = Pub.getString(request.getParameter("act"),"0"); //act=0保存  act=1删除

    String logincode = Pub.getString(request.getParameter("logincode"),"");
    String sessioncode = (String)session.getAttribute("rand");
    if(!logincode.equals(sessioncode) ){
      //System.out.println("验证码不对");
     %>
    <script type="text/javascript">
    <!--
    alert("验证码错误");  
    window.history.back();
    //-->
    </script>
      <%
      //response.sendRedirect("/reglog.shtml");
      return;
    }
    
    String id = request.getParameter("id");
    if(id!=null) id = id.trim();
    
    String useraccount = request.getParameter("useraccount");
    if(useraccount!=null) useraccount = useraccount.trim();
    
    AjaxUtils ajaxutil = new AjaxUtils();
    String oldid = ajaxutil.checkNo(useraccount);
    if(oldid!=null&&oldid.length()>0){
      //System.out.println("验证码不对");
     %>
    <script type="text/javascript">
    <!--
    alert("该邮件已经被注册,请更换！");  
    window.history.back();
    //-->
    </script>
      <%
      //response.sendRedirect("/reglog.shtml");
      return;
    }
    
    String unitid = Pub.getString(request.getParameter("unitid"),"1");
    if(unitid!=null) unitid = unitid.trim();

    String deptid =  Pub.getString(request.getParameter("deptid"),"2");
    if(deptid!=null) deptid = deptid.trim();

    Connection conn = null;


    PreparedStatement pstmt = null;
    String sql = null;
    try
    {
      conn = Database.GetDatabase("nps").GetConnection();
      conn.setAutoCommit(false);
      if("0".equals(act)){
        
        
        //保存
        String username = request.getParameter("username");
        if(username!=null) username = username.trim();
        //
        String itg_fixedpoint = request.getParameter("itg_fixedpoint");
        if(itg_fixedpoint!=null) itg_fixedpoint = itg_fixedpoint.trim();
        
        

        String userpass = request.getParameter("userpass1");
        String phone = request.getParameter("phone");
        if(phone!=null) phone = phone.trim();

        String email = request.getParameter("email");
        if(email!=null) email = email.trim();

        String mobile = request.getParameter("mobile");
        if(mobile!=null) mobile = mobile.trim();

        String fax = request.getParameter("fax");
        if(fax!=null) fax = fax.trim();

        String s_index = Pub.getString(request.getParameter("index"),"0");
        int index = 0;
        try{index=Integer.parseInt(s_index);}catch(Exception e1){}

        String s_type = Pub.getString(request.getParameter("usertype"),"0");
        int utype = 1;
        try{utype = Integer.parseInt(s_type);}catch(Exception e1){}
        String[] roles = {"role2"};
        
        
        
        try
        {
          sql = "insert into users(id,name,account,password,telephone,itg_fixedpoint,fax,email,mobile,face,cx,dept,utype) "
              + " values(?,?,upper(?),?,?,?,?,?,?,?,?,?,?)";
          pstmt = conn.prepareStatement(sql);
          
          if(id == null ) id = Pub.createUNID();
          int colIndex =1;
          pstmt.setString(colIndex ++,id);
          pstmt.setString(colIndex ++,username);
          pstmt.setString(colIndex ++,useraccount);
          pstmt.setString(colIndex ++,userpass);
          pstmt.setString(colIndex ++,"");
          pstmt.setString(colIndex ++,itg_fixedpoint);
          pstmt.setString(colIndex ++,"");
          pstmt.setString(colIndex ++,useraccount);
          pstmt.setString(colIndex ++,"");
          pstmt.setString(colIndex ++,"");
          pstmt.setInt(colIndex ++,index);
          pstmt.setString(colIndex ++, deptid);
          pstmt.setInt(colIndex ++,1);
          pstmt.executeUpdate();
          
          
          
          if(roles!=null && roles.length>0)
          {
              try{pstmt.close();}catch(Exception e1){}
              sql="insert into userrole(userid,roleid) values(?,?)";
              pstmt = conn.prepareStatement(sql);
              for(int i=0;i<roles.length;i++)
              {
                  if(roles[i]!=null && roles[i].length()>0)
                  {
                      pstmt.setString(1,id);
                      pstmt.setString(2,roles[i]);
                      pstmt.executeUpdate();

                  }
              }
          }
          

          //user.SetLocale(Utils.GetLocale("CHINA"));
          session.setAttribute("user", User.LoadInternal(conn, id));
          response.sendRedirect("/user/loaduser.do?cmd=acctountInfo");
          return;
        }
        catch(Exception e)
        {
          nps.util.DefaultLog.error(e);
        }
        finally
        {
          try{pstmt.close();}catch(Exception e1){}
        }
        conn.commit();
      }
        
       
    }
    catch(Exception e)
    {
      e.printStackTrace();
        conn.rollback();
        throw e;
    }
    finally
    {
        if(conn!=null) try{conn.close();}catch(Exception e){}
    }    
%>