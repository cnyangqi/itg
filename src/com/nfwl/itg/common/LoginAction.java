package com.nfwl.itg.common;

import java.sql.Connection;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import nps.core.Database;
import nps.util.Utils;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;

import tools.Pub;


import com.gemway.util.JUtil;
import com.jado.JadoException;
import com.nfwl.itg.user.UserManager;

/**
 * 
 * @Project：ithinkgo   
 * @Type：   LoginAction 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-8-6 下午05:33:46
 * @Comment
 * 
 */

public class LoginAction extends DispatchAction {

	public ActionForward cartLogin(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		Connection con=null;
		
		try
		{
			String account = request.getParameter("user");
		    String passwd  = request.getParameter("password");
		    String to_url = JUtil.convertNull(request.getParameter("to_url"));
		    String logincode = Pub.getString(request.getParameter("logincode"),"");
		    String sessioncode = (String)request.getSession().getAttribute("rand");
		    String language = "CHINA";
		    if(!logincode.equals(sessioncode) ){
		    	request.setAttribute("msg","验证码不对");
		    }else{
		    	nps.core.User user = nps.core.User.Login(account,passwd);
		        if( user == null  )
		        {
		            request.setAttribute("msg", "用户名或密码出错");
		        }else{
		        	user.SetLocale(Utils.GetLocale(language));
		        	request.getSession().setAttribute("user", user);
		        	request.setAttribute("msg", "恭喜您，登陆成功！");
		        	request.setAttribute("flag", true);
		        }
		    }
		    request.setAttribute("to_url", to_url);
		}catch(Exception e){
			throw new JadoException("购物登陆出错!");	
		}
		finally
		{
			if (con!=null) con.close();	
		}
	
		return mapping.findForward("cartLogin_success");
		
	}
}

