package com.nfwl.itg.order;

import java.sql.Connection;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;


import com.jado.JLog;
import com.gemway.util.JUtil;
import com.jado.JadoException;
import com.nfwl.itg.common.ArtileUtil;
import com.nfwl.itg.common.Message;
import com.nfwl.itg.common.TokenManager;
import com.nfwl.itg.common.dbUtil;

import com.nfwl.itg.user.ITG_ADDRESS;
import com.nfwl.itg.user.ITG_ADDRESSForm;
import com.nfwl.itg.user.ITG_ADDRESSManager;

/**
 * 
 * @Project：ithinkgo   
 * @Type：   Order_GoAction 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-8-27 下午03:28:44
 * @Comment
 * 
 */

public class Order_GoAction extends DispatchAction {

	
	public ActionForward add(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		String amount = JUtil.convertNull(request.getParameter("num"));
		String prd_id = JUtil.convertNull(request.getParameter("prd_id"));
		Connection con = null;
		try
		{
			nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
			if(user!=null){
				if(!prd_id.equals("")){
					con = dbUtil.getNfwlCon();
					Map map = ArtileUtil.getByCart(con, prd_id);
					if(map!=null){
						Cart c = CartUtil.ArtmapToCart(map);
						c.setAmount(Double.parseDouble(amount));
						c.setId(JUtil.createUNID());
						request.setAttribute("prd", c);
						
					}
					TokenManager.saveToken(request);
				}else{
					Message ms = new Message();
					ms.setFlag(false);
					ms.setError("你没有选择产品!");
					request.setAttribute("message", ms);
					return mapping.findForward("orderError");
				}
			}else{
				String to_url="/order/buy.do?cmd=add&prd_id="+prd_id+"&num="+amount;
				request.setAttribute("to_url", to_url);
				return mapping.findForward("orderlogin");
			}
			
		}catch(Exception e){
			JLog.getLogger().error("购买的时候出错!",e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("购买的时候出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("orderError");
		}
		finally
		{
			if (con!=null) con.close();	
		}
		
		return mapping.findForward("addPrdSuccess");
	}
	public ActionForward confirm(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		Connection con= null;
		String amount = JUtil.convertNull(request.getParameter("num"));
		String prd_id = JUtil.convertNull(request.getParameter("prd_id"));
		try
		{
			if (TokenManager.isTokenValid(request, true)) {
				nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
				if(user!=null){
					con = dbUtil.getNfwlCon();
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
					String orderid = am.order_goconfirm(con, user.getId(),address,prd_id,Double.parseDouble(amount));
					if(orderid.equals("")){							
						JLog.getLogger().info("没有订单可以设置收货地址");
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
				JLog.getLogger().info("非法的购买order_go");
				Message ms = new Message();
				ms.setFlag(false);
				ms.setError("非法的购买order_go!");
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

