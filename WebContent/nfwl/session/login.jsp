<%@page import="com.nfwl.itg.user.User"%>
<%@page import="java.sql.Connection"%>
<%@page import="nps.core.Database"%>
<%@page import="com.nfwl.itg.user.UserManager"%>
<%@page import="tools.Pub"%>
<%@ page language = "java" contentType = "text/html; charset=UTF-8"%>
<%@ page import="nps.util.Utils" %>
<%@ page import="com.gemway.util.JUtil" %>
<%
    request.setCharacterEncoding("UTF-8");

    session.removeAttribute("user");
    
    String account = request.getParameter("user");
    String passwd  = request.getParameter("password");
    String to_url = JUtil.convertNull(request.getParameter("to_url"));
    String logincode = Pub.getString(request.getParameter("logincode"),"");
    String sessioncode = (String)session.getAttribute("rand");
    String language = "CHINA";

    try
    {
      if(!logincode.equals(sessioncode) ){
        System.out.println("验证码不对");
        //return;%>
              <script type="text/javascript">
      <!--
      alert("验证码不对");   
      //window.opener.showMsg('验证码不对');
      window.history.back();
      //window.opener.location=window.opener.location;
      //window.close();
      //-->
      </script>
        <%
        //response.sendRedirect("/index.shtml");
        return;
      }else{
        //System.out.println("验证码对了");
       // return;
        nps.core.User user = nps.core.User.Login(account,passwd);
        if( user == null  )
        {
          %>
          <script type="text/javascript">
          <!--
          alert("用户名或者密码不对");   
          //window.opener.showMsg('验证码不对');
          window.history.back();
          //window.opener.location=window.opener.location;
          //window.close();
          //-->
          </script>
            <%
            return;
        }
        user.SetLocale(Utils.GetLocale(language));
        session.setAttribute("user", user);
        if(to_url.equals("")){
        	response.sendRedirect("/index_login.shtml");	
        }else{
        	response.sendRedirect(to_url);
        }
        
    }
    }
    catch(Exception e)
    {
        response.sendRedirect("/index.shtml");
    }
%>