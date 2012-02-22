package com.nfwl.itg.order;

import java.sql.Connection;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;


import com.jado.JLog;
import com.gemway.util.JUtil;
import com.jado.JadoException;
import com.nfwl.itg.common.Message;
import com.nfwl.itg.common.TokenManager;
import com.nfwl.itg.common.dbUtil;
import com.nfwl.itg.user.ITG_ORDERRECManager;
import com.nfwl.itg.user.ITG_PAY;

/**
 * 
 * @Project：ithinkgo   
 * @Type：   CarrymodeAction 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-8-7 下午10:33:47
 * @Comment
 * 
 */

public class CarrymodeAction extends DispatchAction {

	public ActionForward init(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		Connection con=null;
		try{
			nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
			if(user!=null){
			    con=dbUtil.getNfwlCon();
				String session_order=JUtil.convertNull((String)request.getSession().getAttribute("order"));
				boolean falg = OrderUtil.isNewAndSelfOrder(con, session_order, user.getId());
				if(falg){
					TokenManager.saveToken(request);
				}else{
					request.getSession().removeAttribute("order");
					return mapping.findForward("myorder");
				}
				
			}else{
				 return mapping.findForward("nologing");
			}
		}catch(Exception e){
			JLog.getLogger().error("初始化送货方式出错!",e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("初始化送货方式出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("orderError");
		}
		return mapping.findForward("initSuccess");
		
		
	}
	
	public ActionForward setCarrymode(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		
		Connection con= null;
		try{
			if (TokenManager.isTokenValid(request, true)) {
				nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
				if(user!=null){
					String session_order=JUtil.convertNull((String)request.getSession().getAttribute("order"));
					con = dbUtil.getNfwlCon();
					boolean falg = OrderUtil.isNewAndSelfOrder(con, session_order, user.getId());
					if(falg){
						String carrymode = JUtil.convertNull(request.getParameter("carrymode"));
						ITG_ORDERRECManager iom = new ITG_ORDERRECManager();
						if(carrymode.equals("")) carrymode="1";
						Integer _carrymode = Integer.parseInt(carrymode);
						iom.setCarrymode(con, session_order, _carrymode);
					}else{
						request.getSession().removeAttribute("order");
						return mapping.findForward("myorder");
					}
				}else{
					 return mapping.findForward("nologing");
				}
			}else{
				JLog.getLogger().error("非法的设置运送方式!");
				Message ms = new Message();
				ms.setFlag(false);
				ms.setError("非法的设置运送方式!");
				request.setAttribute("message", ms);
				return mapping.findForward("orderFailed");
			}
			
		}catch(Exception e){
			JLog.getLogger().error("设置运送方式出错!",e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("设置运送方式出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("orderError");
		}
		finally
		{
			if (con!=null) con.close();	
		}
	
		return new ActionForward("/order/paymode.do?cmd=init");
	}
}

