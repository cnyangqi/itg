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
import com.jado.bean.Bean;
import com.nfwl.itg.common.Message;
import com.nfwl.itg.common.TokenManager;
import com.nfwl.itg.common.dbUtil;
import com.nfwl.itg.user.ITG_ADDRESS;
import com.nfwl.itg.user.ITG_ADDRESSManager;
import com.nfwl.itg.user.ITG_ORDERREC;
import com.nfwl.itg.user.ITG_ORDERRECDELIVERY;
import com.nfwl.itg.user.ITG_ORDERRECDELIVERYManager;
import com.nfwl.itg.user.ITG_ORDERRECManager;
import com.nfwl.itg.user.ITG_PAY;
import com.nfwl.itg.user.ITG_PAYManager;
import com.nfwl.itg.em.OrderStatusEnum;
import com.nfwl.itg.em.PayTypeEnum;

/**
 * 
 * @Project：ithinkgo   
 * @Type：   ConfirmOrder 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-8-10 下午09:44:12
 * @Comment
 * 
 */

public class ConfirmOrderAction extends DispatchAction {

	public ActionForward view(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		Connection con = null;
		try
		{
			nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
			if(user!=null){
				String session_order=JUtil.convertNull((String)request.getSession().getAttribute("order"));
				con = dbUtil.getNfwlCon();
				boolean falg = OrderUtil.isNewAndSelfOrder(con, session_order, user.getId());
				if(falg){
					ITG_ORDERRECManager igom =new ITG_ORDERRECManager();
					ITG_ORDERREC igo = (ITG_ORDERREC) igom.get(con, session_order);
					if(igo!=null){
					
						request.setAttribute("orderrec", igo);
						//列表信息
						CartManager cm = new CartManager();
						List<Cart> ls = cm.getUserCarts(con, user.getId(), session_order);
						request.setAttribute("list", ls);
						
						//地址信息
						ITG_ORDERRECDELIVERYManager iodm = new ITG_ORDERRECDELIVERYManager();
						ITG_ORDERRECDELIVERY iod = iodm.getByOrder(con, session_order);
						request.setAttribute("address", iod);
						
						//支付信息
						ITG_PAYManager ipm = new ITG_PAYManager();
						Bean b = ipm.getByOrder(con, session_order);
						if(b!=null){
							request.setAttribute("pay", b);
						}
						
						TokenManager.saveToken(request);
						
					}
				}else{
					request.getSession().removeAttribute("order");
					return mapping.findForward("myorder");
				}
			}else{
				 return mapping.findForward("nologing");
			}
		}catch(Exception e){
		
			JLog.getLogger().error("显示订单信息出错!",e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("显示订单信息出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("orderError");
		}
		finally
		{
			if (con!=null) con.close();	
		}

		return mapping.findForward("viewSuccess");
	}
	public ActionForward confirm(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		String url="";
		Connection con = null;
		try
		{
			if (TokenManager.isTokenValid(request, true)) {
				nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
				if(user!=null){
					String session_order=JUtil.convertNull((String)request.getSession().getAttribute("order"));
					if(session_order.equals("")){
						JLog.getLogger().info("没有订单可以确认");
						Message ms = new Message();
						ms.setFlag(false);
						ms.setError("没有订单可以确认!");
						request.setAttribute("message", ms);
						return mapping.findForward("orderFailed");
					}else{
						con = dbUtil.getNfwlCon();
						boolean falg = OrderUtil.isNewAndSelfOrder(con, session_order, user.getId());
						if(falg){
							ITG_PAYManager ipm = new ITG_PAYManager();
							ITG_PAY pay  = (ITG_PAY) ipm.getByOrder(con, session_order);
							if(pay!=null){
								ITG_ORDERRECManager igom = new ITG_ORDERRECManager();
								ITG_ORDERREC igo =  igom.get(con, session_order);
								
								String or_memo = JUtil.convertNull(request.getParameter("or_memo"));
								String or_invoicetitle = JUtil.convertNull(request.getParameter("or_invoicetitle"));
								igom.confirmOrder(con, igo, or_memo, or_invoicetitle);
								if(pay.getPay_type().equals(PayTypeEnum.DEFAULT.getCode())){
									url="/order/pay.do?cmd=pay&or_id="+session_order;
								}else{
									request.setAttribute("or_id", session_order);
									url="/order/alipayto.jsp";
								}
								request.getSession().removeAttribute("order");
							}else{
								JLog.getLogger().info("没有支付信息");
								Message ms = new Message();
								ms.setFlag(false);
								ms.setError("没有支付信息!");
								request.setAttribute("message", ms);
								return mapping.findForward("orderFailed");
							}
						}else{
							request.getSession().removeAttribute("order");
							return mapping.findForward("myorder");
						}
					}
					
				}else{
					 return mapping.findForward("nologing");
				}
			}else{
				JLog.getLogger().info("非法的确认订单");
				Message ms = new Message();
				ms.setFlag(false);
				ms.setError("非法的确认订单!");
				request.setAttribute("message", ms);
				return mapping.findForward("orderFailed");
			}
			
		}catch(Exception e){
			JLog.getLogger().error("确认订单信息出错!",e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("显示订单信息出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("orderError");
		}
		finally
		{
			if (con!=null) con.close();	
		}
		return new ActionForward(url);
	}
}

