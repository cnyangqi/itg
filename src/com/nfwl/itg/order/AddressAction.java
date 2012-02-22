package com.nfwl.itg.order;

import java.sql.Connection;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;




import com.gemway.util.JUtil;
import com.jado.JLog;
import com.jado.JadoException;
import com.nfwl.itg.common.ITG_HZ_ZONE;
import com.nfwl.itg.common.Message;
import com.nfwl.itg.common.TokenManager;
import com.nfwl.itg.common.dbUtil;
import com.nfwl.itg.em.OrderStatusEnum;

import com.nfwl.itg.user.ITG_ADDRESS;
import com.nfwl.itg.user.ITG_ADDRESSForm;
import com.nfwl.itg.user.ITG_ADDRESSManager;
import com.nfwl.itg.user.ITG_CARTREC;
import com.nfwl.itg.user.ITG_CARTRECManager;
import com.nfwl.itg.user.ITG_ORDERREC;
import com.nfwl.itg.user.ITG_ORDERRECManager;

/**
 * 
 * @Project：ithinkgo   
 * @Type：   AddressAction 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-8-6 下午10:43:34
 * @Comment
 * 
 */

public class AddressAction extends DispatchAction{

	
	/*
	 * 如果从购物车过来，表已经登陆
	 */
	public ActionForward confirm(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		Connection con= null;
		try
		{
			if (TokenManager.isTokenValid(request, true)) {
				nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
				if(user!=null){
					String session_order=JUtil.convertNull((String)request.getSession().getAttribute("order"));
					con = dbUtil.getNfwlCon();
					if(!session_order.equals("")){
						boolean falg = OrderUtil.isNewAndSelfOrder(con, session_order, user.getId());
						if(!falg){
							request.getSession().removeAttribute("order");
							return mapping.findForward("myorder");
						}
					}
					
					String adr_id=JUtil.convertNull(request.getParameter("adr_id"));
					if(adr_id.equals("")){
						JLog.getLogger().info("你没有选择地址");
						Message ms = new Message();
						ms.setFlag(false);
						ms.setError("你没有选择地址!");
						request.setAttribute("message", ms);
						return mapping.findForward("orderFailed");
						
					}
					ITG_ADDRESSManager idm = new ITG_ADDRESSManager();
					ITG_ADDRESSForm idform = (ITG_ADDRESSForm)form;
		     		ITG_ADDRESS address = idm.formTObean(idform);
		     		if(address.getAdr_id().equals("itg_fixedpoint")){
		     			address.setAdr_fpid(user.getItg_fixedpoint());
		     		}
					AddressManager am = new AddressManager();
					String orderid = am.confirm(con, user.getId(),address,session_order);
					if(orderid.equals("")){
						JLog.getLogger().error("没有订单可以设置收货地址!");
						Message ms = new Message();
						ms.setFlag(false);
						ms.setError("没有订单可以设置收货地址!");
						request.setAttribute("message", ms);
						return mapping.findForward("orderFailed");
					}else{
						request.getSession().setAttribute("order", orderid);
						TokenManager.saveToken(request);
					}
					
				}else{
					 return mapping.findForward("nologing");
				}
			}else{
				JLog.getLogger().error("非法的确认地址!");
				Message ms = new Message();
				ms.setFlag(false);
				ms.setError("非法的确认地址!");
				request.setAttribute("message", ms);
				return mapping.findForward("orderFailed");
			}
			
		}catch(Exception e){
			JLog.getLogger().error("确认收货地址出错!",e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("确认收货地址出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("orderError");
		}
		finally
		{
			if (con!=null) con.close();	
		}

		return new ActionForward("/order/carrymode.do?cmd=init");
		
	}
	
}

