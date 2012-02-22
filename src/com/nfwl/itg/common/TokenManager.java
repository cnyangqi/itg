package com.nfwl.itg.common;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import com.gemway.util.JUtil;

/**
 * 
 * @Project：ithinkgo
 * @Type： TokenManager
 * @Author: yjw
 * @Email: y.jinwei@gmail.com
 * @Mobile: 13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date: 2011-8-13 下午10:14:41
 * @Comment  此token存在内存泄露
 * 
 */

public class TokenManager {

	public static final String TOKEN_KEY = "token";

	public static synchronized boolean isTokenValid(HttpServletRequest request,
			boolean reset) {
		HttpSession session = request.getSession(false);
		if (session == null) {
			return false;
		}

		String token = request.getParameter(TOKEN_KEY);
		if (token == null) {
			return false;
		}
		
		String saved = (String) session.getAttribute(token);
		if (saved == null) {
			return false;
		}

		if (reset) {
			resetToken(request);
		}

		return saved.equals(token);
	}

	public static synchronized void resetToken(HttpServletRequest request) {

		HttpSession session = request.getSession(false);
		if (session == null) {
			return;
		}
		String token = request.getParameter(TOKEN_KEY);
		session.removeAttribute(token);
	}

	public static synchronized String saveToken(HttpServletRequest request) {    
		        HttpSession session = request.getSession();    
		        String token = JUtil.createUNID();    
		        if (token != null) {    
		            session.setAttribute(token, token);    
		            request.setAttribute(TOKEN_KEY,token);    
		        }
		        return token;
		   
	}	
}
